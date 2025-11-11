import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../config/radio_tujuhcahaya_config.dart';
import '../../../../core/utils/exponential_backoff.dart';
import '../../../../core/models/notification_update_state.dart';
import '../../domain/entities/radio_entity.dart';
import '../../domain/entities/radio_player_entity.dart';
import '../../domain/repositories/radio_player_repository.dart';
import '../datasources/radio_player_remote_datasource.dart';
import '../services/album_art_service.dart';
import 'package:radio_player/radio_player.dart';
import '../../../../core/logger/app_logger.dart';

/// Implementation of RadioPlayerRepository
class RadioPlayerRepositoryImpl implements RadioPlayerRepository {
  final RadioPlayerRemoteDataSource remoteDataSource;
  final AlbumArtService albumArtService;

  final StreamController<RadioPlayerEntity> _playerStateController =
      StreamController<RadioPlayerEntity>.broadcast();

  RadioPlayerEntity _currentState = const RadioPlayerEntity.initial();
  StreamSubscription<PlaybackState>? _playbackStateSubscription;
  StreamSubscription<Metadata>? _metadataSubscription;
  StreamSubscription<RemoteCommand>? _remoteCommandSubscription;
  StreamSubscription? _albumArtSubscription;

  // Guard against duplicate initialization
  bool _isInitializing = false;
  RadioEntity? _currentConfig;

  // radioCoreV2: Idempotent play mechanism
  Future<void>? _pendingPlayOperation;
  Timer? _debounceTimer;
  DateTime? _lastPlayRequest;

  // Enhanced notification update tracking
  NotificationUpdateState _notificationState = NotificationUpdateState.initial();
  Timer? _notificationUpdateTimer;
  
  // Track if audio has actually started playing (not just pre-buffering)
  bool _isAudioActuallyPlaying = false;

  // radioCoreV2: Performance tracking
  DateTime? _initializationStartTime;
  DateTime? _playStartTime;

  // radioCoreV2: Retry mechanism
  Timer? _retryTimer;
  int _currentRetryAttempt = 0;
  List<String> _availableUrls = [];
  int _currentUrlIndex = 0;

  RadioPlayerRepositoryImpl({
    required this.remoteDataSource,
    required this.albumArtService,
  }) {
    _setupStreamListeners();
    _setupAlbumArtListener();
  }

  /// Set up stream listeners to convert data source events to domain entities
  void _setupStreamListeners() {
    _playbackStateSubscription = remoteDataSource.playbackStateStream.listen(
      (playbackState) {
        final isPlaying = playbackState == PlaybackState.playing;
        
        // Set flag when audio actually starts playing (not just pre-buffering)
        if (isPlaying && !_isAudioActuallyPlaying) {
          _isAudioActuallyPlaying = true;
          if (RadioTujuhCahayaConfig.logNotificationUpdates) {
            Log.debug('[RadioPlayerRepository] Audio playback started - enabling metadata updates');
          }
        } else if (!isPlaying && _isAudioActuallyPlaying) {
          _isAudioActuallyPlaying = false;
          if (RadioTujuhCahayaConfig.logNotificationUpdates) {
            Log.debug('[RadioPlayerRepository] Audio playback stopped - disabling metadata updates');
          }
        }
        
        _updateState(_currentState.copyWith(
          isPlaying: isPlaying,
          isInitialized: true,
          errorMessage: null,
        ));
      },
      onError: (error) {
        _updateState(_currentState.copyWith(
          errorMessage: 'Playback state error: ${error.toString()}',
        ));
      },
    );

    _metadataSubscription = remoteDataSource.metadataStream.listen(
      (metadata) async {
        String? sanitizedArtist = metadata.artist;
        String? sanitizedTitle = metadata.title;

        // Sanitize metadata by removing configured phrases (case-insensitive)
        for (final phrase in RadioTujuhCahayaConfig.metadataRemovePhrases) {
          final regex = RegExp(RegExp.escape(phrase), caseSensitive: false);
          if (sanitizedArtist != null) {
            sanitizedArtist = sanitizedArtist.replaceAll(regex, '');
          }
          if (sanitizedTitle != null) {
            sanitizedTitle = sanitizedTitle.replaceAll(regex, '');
          }
        }

        // Trim and collapse spaces
        sanitizedArtist = sanitizedArtist?.replaceAll('\n', ' ').replaceAll('\t', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
        sanitizedTitle = sanitizedTitle?.replaceAll('\n', ' ').replaceAll('\t', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();

        final newArtist = (sanitizedArtist != null && sanitizedArtist.isNotEmpty)
            ? sanitizedArtist
            : RadioTujuhCahayaConfig.fallbackArtist;
        final newTitle = (sanitizedTitle != null && sanitizedTitle.isNotEmpty)
            ? sanitizedTitle
            : RadioTujuhCahayaConfig.fallbackTitle;

        _updateState(_currentState.copyWith(
          currentArtist: newArtist,
          currentTitle: newTitle,
          errorMessage: null,
        ));

        // Fetch album art for new metadata using centralized service
        // Only fetch album art if audio has actually started playing (not during pre-buffering)
        if ((_currentConfig?.showAlbumCover ?? false) &&
            (newArtist.isNotEmpty || newTitle.isNotEmpty) &&
            _currentConfig != null &&
            (!RadioTujuhCahayaConfig.delayMetadataUntilAudioStarts || _isAudioActuallyPlaying)) {
          await albumArtService.fetchAndBroadcast(newArtist, newTitle, _currentConfig!);
        }
      },
      onError: (error) {
        _updateState(_currentState.copyWith(
          errorMessage: 'Metadata error: ${error.toString()}',
        ));
      },
    );

    _remoteCommandSubscription = remoteDataSource.remoteCommandStream.listen(
      (command) {
        // Handle remote commands (play/pause from notification, etc.)
        // Note: RemoteCommand enum values may vary by radio_player package version
        // For now, we'll handle them generically
        if (command.toString().contains('play')) {
          play();
        } else if (command.toString().contains('pause')) {
          pause();
        } else if (command.toString().contains('stop')) {
          reset();
        }
      },
      onError: (error) {
        _updateState(_currentState.copyWith(
          errorMessage: 'Remote command error: ${error.toString()}',
        ));
      },
    );
  }

  /// Set up album art listener to update state when album art changes
  void _setupAlbumArtListener() {
    _albumArtSubscription = albumArtService.albumArtStream.listen(
      (albumArtState) async {
        // Update state with new album art URL
        String? albumArtUrl;
        if (albumArtState.hasUrl) {
          albumArtUrl = albumArtState.url;
        }
        
        _updateState(_currentState.copyWith(
          currentAlbumArtUrl: albumArtUrl,
        ));

        // Update notification with new album art using exponential backoff
        // Only update notifications if audio has actually started playing (not during pre-buffering)
        if (_currentConfig != null && 
            albumArtState.artist != null && 
            albumArtState.title != null &&
            (!RadioTujuhCahayaConfig.delayMetadataUntilAudioStarts || _isAudioActuallyPlaying)) {
          await _updateNotificationWithBackoff(
            artist: albumArtState.artist!,
            title: albumArtState.title!,
            artworkUrl: albumArtUrl,
          );
        }
      },
      onError: (error) {
        // Album art errors are not critical, just log them
        Log.debug('[RadioPlayerRepository] Album art error: $error');
      },
    );
  }

  /// Update the current state and emit to stream with debouncing
  void _updateState(RadioPlayerEntity newState) {
    _currentState = newState;

    // radioCoreV2: Debounce non-critical state updates
    if (_shouldDebounceState(newState)) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(
          Duration(milliseconds: RadioTujuhCahayaConfig.debounceWindowMs), () {
        _playerStateController.add(_currentState);
      });
    } else {
      // Critical states emit immediately
      _playerStateController.add(newState);
    }
  }

  /// Determine if state update should be debounced
  bool _shouldDebounceState(RadioPlayerEntity newState) {
    // Don't debounce critical states
    if (newState.errorMessage != null) return false;
    if (newState.isConnecting) return false;
    if (newState.isBuffering) return false;
    if (newState.retryAttempt > 0) return false;

    // Debounce metadata and album art updates
    return newState.currentArtist != _currentState.currentArtist ||
        newState.currentTitle != _currentState.currentTitle ||
        newState.currentAlbumArtUrl != _currentState.currentAlbumArtUrl;
  }

  /// Update notification with exponential backoff retry logic
  Future<void> _updateNotificationWithBackoff({
    required String artist,
    required String title,
    String? artworkUrl,
  }) async {
    // Create new notification state
    final newNotificationState = NotificationUpdateState(
      artist: artist,
      title: title,
      artworkUrl: artworkUrl,
    );

    // Check if this is the same content as current state
    if (_notificationState.isSameContent(newNotificationState) && 
        !_notificationState.isStale) {
      if (RadioTujuhCahayaConfig.logNotificationUpdates) {
        Log.debug('[RadioPlayerRepository] Skipping notification update - same content and not stale');
      }
      return;
    }

    // Cancel any pending notification update
    _notificationUpdateTimer?.cancel();

    // Start new notification update with exponential backoff
    _notificationState = NotificationUpdateState.updating(
      artist: artist,
      title: title,
      artworkUrl: artworkUrl,
      maxAttempts: RadioTujuhCahayaConfig.notificationMaxRetries,
    );

    final backoff = ExponentialBackoff(
      maxRetries: RadioTujuhCahayaConfig.notificationMaxRetries,
      initialDelayMs: RadioTujuhCahayaConfig.notificationInitialDelayMs,
      multiplier: RadioTujuhCahayaConfig.notificationBackoffMultiplier,
      maxDelayMs: RadioTujuhCahayaConfig.notificationMaxDelayMs,
    );

    try {
      await backoff.execute(
        () async {
          if (RadioTujuhCahayaConfig.logNotificationUpdates) {
            Log.debug('[RadioPlayerRepository] Updating notification (attempt ${_notificationState.attemptCount + 1}):');
            Log.debug('  - Artist: $artist');
            Log.debug('  - Title: $title');
            Log.debug('  - Artwork URL: $artworkUrl');
          }

          await remoteDataSource.setCustomMetadata(
            artist: artist,
            title: title,
            artworkUrl: artworkUrl,
          );

          if (RadioTujuhCahayaConfig.logNotificationUpdates) {
            Log.debug('[RadioPlayerRepository] Notification update successful');
          }
        },
        shouldRetry: (error) {
          // Retry on network errors, timeouts, but not on validation errors
          return error.toString().contains('timeout') ||
                 error.toString().contains('network') ||
                 error.toString().contains('connection');
        },
        onRetry: (attempt, error) {
          if (RadioTujuhCahayaConfig.logNotificationUpdates) {
            Log.debug('[RadioPlayerRepository] Notification update failed (attempt $attempt): $error');
            Log.debug('[RadioPlayerRepository] Retrying in ${backoff.getDelayForAttempt(attempt - 1)}ms...');
          }
          
          _notificationState = _notificationState.copyWith(
            attemptCount: attempt,
            lastError: error.toString(),
            isUpdating: true,
            hasFailed: false,
          );
        },
      );

      // Success
      _notificationState = NotificationUpdateState.success(
        artist: artist,
        title: title,
        artworkUrl: artworkUrl,
        attemptCount: _notificationState.attemptCount,
        maxAttempts: RadioTujuhCahayaConfig.notificationMaxRetries,
        lastAttemptTime: _notificationState.lastAttemptTime,
      );

      if (RadioTujuhCahayaConfig.logNotificationUpdates) {
        Log.debug('[RadioPlayerRepository] Notification update completed successfully');
      }

    } catch (error) {
      // Final failure
      _notificationState = NotificationUpdateState.failed(
        artist: artist,
        title: title,
        artworkUrl: artworkUrl,
        attemptCount: _notificationState.attemptCount,
        maxAttempts: RadioTujuhCahayaConfig.notificationMaxRetries,
        error: error.toString(),
        lastAttemptTime: _notificationState.lastAttemptTime,
      );

      if (RadioTujuhCahayaConfig.logNotificationUpdates) {
        Log.debug('[RadioPlayerRepository] Notification update failed after all retries: $error');
      }
    }
  }


  @override
  Future<Either<Failure, Unit>> initialize(RadioEntity config) async {
    if (RadioTujuhCahayaConfig.enableVerboseLogging) {
      Log.debug(
          '[RadioPlayerRepository] Initialize called - Stream URL: ${config.streamUrl}');
    }

    // radioCoreV2: Performance tracking
    _initializationStartTime = DateTime.now();

    // Check if already initialized with the same config
    if (_currentState.isInitialized &&
        _currentConfig != null &&
        _currentConfig!.streamUrl == config.streamUrl) {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerRepository] Already initialized with same config');
      }
      return const Right(unit);
    }

    // Prevent concurrent initialization
    if (_isInitializing) {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerRepository] Initialization already in progress');
      }
      return Left(ServerFailure('Initialization already in progress'));
    }

    _isInitializing = true;
    _currentConfig = config;

    try {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerRepository] Calling remoteDataSource.initialize');
      }
      await remoteDataSource.initialize(config);

      // radioCoreV2: Performance tracking
      final initTime =
          DateTime.now().difference(_initializationStartTime!).inMilliseconds;
      
      if (RadioTujuhCahayaConfig.enablePerformanceMonitoring) {
        Log.debug(
            '[RadioPlayerRepository] Initialization completed in ${initTime}ms');

        // Log performance warning if target exceeded
        if (initTime > RadioTujuhCahayaConfig.targetColdStartMs) {
          Log.debug(
              '[RadioPlayerRepository] WARNING: Cold-start time ${initTime}ms exceeds target ${RadioTujuhCahayaConfig.targetColdStartMs}ms');
        }
      }

      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug(
            '[RadioPlayerRepository] Remote data source initialized successfully');
      }
      _updateState(_currentState.copyWith(
        isInitialized: true,
        currentUrl: config.streamUrl,
        errorMessage: null,
        connectionTimeMs: initTime,
      ));
      return const Right(unit);
    } catch (e) {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerRepository] Initialize failed: ${e.toString()}');
      }
      final failure =
          ServerFailure('Failed to initialize radio player: ${e.toString()}');
      _updateState(_currentState.copyWith(
        errorMessage: failure.message,
        lastErrorTimestamp: DateTime.now(),
      ));
      return Left(failure);
    } finally {
      _isInitializing = false;
    }
  }

  @override
  Future<Either<Failure, Unit>> play() async {
    // radioCoreV2: Idempotent play with debouncing
    final now = DateTime.now();

    // Check if we have a pending play operation
    if (_pendingPlayOperation != null) {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug(
            '[RadioPlayerRepository] Play already in progress, returning existing future');
      }
      try {
        await _pendingPlayOperation!;
        return const Right(unit);
      } catch (e) {
        return Left(ServerFailure('Play operation failed: ${e.toString()}'));
      }
    }

    // Debounce rapid play requests (within 500ms)
    if (_lastPlayRequest != null &&
        now.difference(_lastPlayRequest!).inMilliseconds < 500) {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerRepository] Play request debounced (too rapid)');
      }
      return const Right(unit);
    }

    _lastPlayRequest = now;
    _playStartTime = now;

    // Immediately emit connecting to provide instant UI feedback
    _updateState(_currentState.copyWith(
      isConnecting: true,
      isBuffering: false,
      errorMessage: null,
    ));

    // Create the play operation
    _pendingPlayOperation = _performPlay();

    try {
      await _pendingPlayOperation!;
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('Play operation failed: ${e.toString()}'));
    } finally {
      _pendingPlayOperation = null;
    }
  }

  /// Internal play implementation with retry logic and pre-buffering
  Future<void> _performPlay() async {
    if (_currentConfig == null) {
      throw Exception('No radio configuration available');
    }

    // For live radio streams, always reset before playing to get current live content
    // This prevents playing stale content from when the stream was paused
    Log.debug(
        '[RadioPlayerRepository] Resetting before play to ensure live content');
    await remoteDataSource.reset();

    // Pre-buffer strategy: Initialize and wait for buffer to fill
    Log.debug(
        '[RadioPlayerRepository] Starting pre-buffering for smooth playback...');
    await _preBufferStream();

    // Check if radioCoreV2 is enabled
    if (_currentConfig!.radioCoreV2Enabled) {
      await _performPlayV2();
    } else {
      await _performPlayLegacy();
    }
  }

  /// Pre-buffer the stream to prevent AudioTrack underruns
  Future<void> _preBufferStream() async {
    try {
      // Initialize the stream first
      await remoteDataSource.initialize(_currentConfig!);

      // Get buffer time from config
      final bufferTimeMs = RadioTujuhCahayaConfig.preBufferTimeMs;

      // Update state to show buffering
      _updateState(_currentState.copyWith(
        isBuffering: true,
        isConnecting: false,
      ));

      // Wait for the stream to buffer (configurable time for smooth playback)
      Log.debug(
          '[RadioPlayerRepository] Pre-buffering stream for ${bufferTimeMs}ms...');
      await Future.delayed(Duration(milliseconds: bufferTimeMs));

      // Clear buffering state
      _updateState(_currentState.copyWith(
        isBuffering: false,
      ));

      Log.debug('[RadioPlayerRepository] Pre-buffering completed');
    } catch (e) {
      Log.debug('[RadioPlayerRepository] Pre-buffering failed: $e');
      // Clear buffering state on error
      _updateState(_currentState.copyWith(
        isBuffering: false,
      ));
      // Continue anyway - not critical
    }
  }

  /// radioCoreV2: Enhanced play with retry and backup URLs
  Future<void> _performPlayV2() async {
    Log.debug('[RadioPlayerRepository] Using radioCoreV2 play logic');

    // Prepare available URLs (primary + backups)
    _availableUrls = [_currentConfig!.streamUrl];
    _availableUrls.addAll(_currentConfig!.backupStreamUrls);
    _currentUrlIndex = 0;
    _currentRetryAttempt = 0;

    await _attemptPlayWithRetry();
  }

  /// Legacy play implementation
  Future<void> _performPlayLegacy() async {
    Log.debug('[RadioPlayerRepository] Using legacy play logic');
    
    // Update state to show connecting
    _updateState(_currentState.copyWith(
      isConnecting: true,
      isBuffering: false,
    ));
    
    try {
      // Reinitialize after reset to ensure fresh connection
      await remoteDataSource.initialize(_currentConfig!);
      await remoteDataSource.play();
      
      // Clear connecting state on success
      _updateState(_currentState.copyWith(
        isConnecting: false,
      ));
    } catch (e) {
      // Clear connecting state on error
      _updateState(_currentState.copyWith(
        isConnecting: false,
      ));
      rethrow;
    }
  }

  /// Attempt play with retry logic
  Future<void> _attemptPlayWithRetry() async {
    if (_currentUrlIndex >= _availableUrls.length) {
      throw Exception('All stream URLs exhausted');
    }

    final currentUrl = _availableUrls[_currentUrlIndex];
    Log.debug(
        '[RadioPlayerRepository] Attempting play with URL: $currentUrl (attempt ${_currentRetryAttempt + 1})');

    // Update state to show connecting
    _updateState(_currentState.copyWith(
      isConnecting: true,
      isBuffering: false,
      retryAttempt: _currentRetryAttempt,
      currentBackupUrlIndex: _currentUrlIndex,
    ));

    try {
      // Always reinitialize after reset to ensure fresh connection to live stream
      final configWithNewUrl = RadioEntity(
        enabled: _currentConfig!.enabled,
        streamUrl: currentUrl,
        autoplay: _currentConfig!.autoplay,
        showAlbumCover: _currentConfig!.showAlbumCover,
        textScrolling: _currentConfig!.textScrolling,
        metadataUrl: _currentConfig!.metadataUrl,
        logoNetworkUrl: _currentConfig!.logoNetworkUrl,
        albumArtSource: _currentConfig!.albumArtSource,
        lastUpdated: _currentConfig!.lastUpdated,
        backupStreamUrls: _currentConfig!.backupStreamUrls,
        radioCoreV2Enabled: _currentConfig!.radioCoreV2Enabled,
      );

      await remoteDataSource.initialize(configWithNewUrl);
      await remoteDataSource.play();

      // Success - reset retry state and track performance
      _currentRetryAttempt = 0;

      // radioCoreV2: Performance tracking for live stream connection time
      int? connectionTimeMs;
      if (_playStartTime != null) {
        connectionTimeMs =
            DateTime.now().difference(_playStartTime!).inMilliseconds;
        Log.debug(
            '[RadioPlayerRepository] Live stream connection completed in ${connectionTimeMs}ms');

        // Log performance warning if target exceeded
        if (connectionTimeMs > RadioTujuhCahayaConfig.targetFastResumeMs) {
          Log.debug(
              '[RadioPlayerRepository] WARNING: Connection time ${connectionTimeMs}ms exceeds target ${RadioTujuhCahayaConfig.targetFastResumeMs}ms');
        }
      }

      _updateState(_currentState.copyWith(
        isConnecting: false,
        isBuffering: false,
        retryAttempt: 0,
        currentUrl: currentUrl,
        errorMessage: null,
        lastErrorTimestamp: null,
        resumeTimeMs: connectionTimeMs,
      ));
    } catch (e) {
      Log.debug('[RadioPlayerRepository] Play attempt failed: ${e.toString()}');

      // Update error state
      _updateState(_currentState.copyWith(
        isConnecting: false,
        isBuffering: false,
        errorMessage: e.toString(),
        lastErrorTimestamp: DateTime.now(),
      ));

      // Schedule retry if we haven't exceeded max attempts
      if (_currentRetryAttempt < RadioTujuhCahayaConfig.maxRetryAttempts - 1) {
        _scheduleRetry();
      } else {
        // Try next URL if available
        if (_currentUrlIndex < _availableUrls.length - 1) {
          _currentUrlIndex++;
          _currentRetryAttempt = 0;
          _scheduleRetry();
        } else {
          throw Exception('All retry attempts and backup URLs exhausted');
        }
      }
    }
  }

  /// Schedule retry with exponential backoff
  void _scheduleRetry() {
    if (_currentRetryAttempt >=
        RadioTujuhCahayaConfig.retryBackoffDelays.length) {
      return;
    }

    final delayMs =
        RadioTujuhCahayaConfig.retryBackoffDelays[_currentRetryAttempt];
    _currentRetryAttempt++;

    Log.debug(
        '[RadioPlayerRepository] Scheduling retry in ${delayMs}ms (attempt $_currentRetryAttempt)');

    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(milliseconds: delayMs), () {
      _attemptPlayWithRetry();
    });
  }

  @override
  Future<Either<Failure, Unit>> pause() async {
    try {
      await remoteDataSource.pause();
      return const Right(unit);
    } catch (e) {
      final failure = ServerFailure('Failed to pause radio: ${e.toString()}');
      _updateState(_currentState.copyWith(
        errorMessage: failure.message,
      ));
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Unit>> reset() async {
    try {
      await remoteDataSource.reset();
      _isInitializing = false;
      _currentConfig = null;
      _updateState(const RadioPlayerEntity.initial());
      return const Right(unit);
    } catch (e) {
      final failure =
          ServerFailure('Failed to reset radio player: ${e.toString()}');
      _updateState(_currentState.copyWith(
        errorMessage: failure.message,
      ));
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, String>> getAlbumArt(
    String artist,
    String title,
    RadioEntity config,
  ) async {
    try {
      // Use the new reactive fetchAndBroadcast method
      await albumArtService.fetchAndBroadcast(artist, title, config);
      
      // Get the current album art URL from the service state
      final albumArtUrl = albumArtService.getCurrentAlbumArtUrl();
      if (albumArtUrl != null && albumArtUrl.isNotEmpty) {
        return Right(albumArtUrl);
      } else {
        return Left(ServerFailure('Album art not found'));
      }
    } catch (e) {
      return Left(ServerFailure('Failed to get album art: ${e.toString()}'));
    }
  }

  @override
  Stream<RadioPlayerEntity> watchPlayerState() {
    return _playerStateController.stream;
  }

  @override
  Future<Either<Failure, Unit>> setCustomMetadata({
    required String artist,
    required String title,
    String? artworkUrl,
  }) async {
    try {
      await remoteDataSource.setCustomMetadata(
        artist: artist,
        title: title,
        artworkUrl: artworkUrl,
      );
      return const Right(unit);
    } catch (e) {
      final failure =
          ServerFailure('Failed to set custom metadata: ${e.toString()}');
      _updateState(_currentState.copyWith(
        errorMessage: failure.message,
      ));
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStation({
    required String title,
    required String url,
    required bool parseStreamMetadata,
    required bool lookupOnlineArtwork,
    String? logoAssetPath,
    String? logoNetworkUrl,
  }) async {
    try {
      await remoteDataSource.updateStation(
        title: title,
        url: url,
        parseStreamMetadata: parseStreamMetadata,
        lookupOnlineArtwork: lookupOnlineArtwork,
        logoAssetPath: logoAssetPath,
        logoNetworkUrl: logoNetworkUrl,
      );
      return const Right(unit);
    } catch (e) {
      final failure =
          ServerFailure('Failed to update station: ${e.toString()}');
      _updateState(_currentState.copyWith(
        errorMessage: failure.message,
      ));
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Unit>> setNavigationControls({
    required bool showNextButton,
    required bool showPreviousButton,
  }) async {
    try {
      await remoteDataSource.setNavigationControls(
        showNextButton: showNextButton,
        showPreviousButton: showPreviousButton,
      );
      return const Right(unit);
    } catch (e) {
      final failure =
          ServerFailure('Failed to set navigation controls: ${e.toString()}');
      _updateState(_currentState.copyWith(
        errorMessage: failure.message,
      ));
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, Unit>> setVolume(double volume) async {
    try {
      await remoteDataSource.setVolume(volume.clamp(0.0, 1.0));
      return const Right(unit);
    } catch (e) {
      // Treat as non-fatal and return success to keep UI responsive
      return const Right(unit);
    }
  }

  /// Dispose resources with comprehensive cleanup
  void dispose() {
    if (RadioTujuhCahayaConfig.enableVerboseLogging) {
      Log.debug('[RadioPlayerRepository] Disposing resources...');
    }

    // Cancel all subscriptions
    _playbackStateSubscription?.cancel();
    _metadataSubscription?.cancel();
    _remoteCommandSubscription?.cancel();
    _albumArtSubscription?.cancel();

    // radioCoreV2: Clean up timers
    _debounceTimer?.cancel();
    _retryTimer?.cancel();
    _notificationUpdateTimer?.cancel();

    // Cancel pending operations
    _pendingPlayOperation = null;

    // Reset states
      _notificationState = NotificationUpdateState.initial();
      _currentState = const RadioPlayerEntity.initial();
      _currentConfig = null;
      _isInitializing = false;
      _isAudioActuallyPlaying = false;

    // Clear retry state
    _currentRetryAttempt = 0;
    _availableUrls.clear();
    _currentUrlIndex = 0;

    // Close stream controller
    if (!_playerStateController.isClosed) {
      _playerStateController.close();
    }

    if (RadioTujuhCahayaConfig.enableVerboseLogging) {
      Log.debug('[RadioPlayerRepository] Resources disposed successfully');
    }
  }
}
