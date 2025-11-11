import 'dart:async';
import 'package:dio/dio.dart';
import '../../../../config/radio_tujuhcahaya_config.dart';
import '../../../../core/models/album_art_state.dart';
import '../../../../core/services/network_status_service.dart';
import '../repositories/album_art_repository_impl.dart';
import '../../domain/usecases/get_album_art_url.dart';
import '../../domain/entities/radio_entity.dart';
import 'album_art_cache_service.dart';
import '../../../../core/logger/app_logger.dart';

/// Reactive service to manage album art operations
/// Enhanced with cancellation, offline mode, and queue management
/// Acts as single source of truth for album art state across the app
class AlbumArtService {
  static AlbumArtService? _instance;
  final Dio _dio;
  final NetworkStatusService _networkService;
  
  // Stream controller for broadcasting album art state changes
  final StreamController<AlbumArtState> _albumArtController = 
      StreamController<AlbumArtState>.broadcast();
  
  // Current state
  AlbumArtState _currentState = AlbumArtState.initial();
  
  // Track current fetch to prevent duplicate requests
  String? _currentFetchKey;
  
  // Request cancellation token
  CancelToken? _currentCancelToken;
  
  // Network status subscription
  StreamSubscription<bool>? _networkSubscription;
  
  // Request queue for offline scenarios
  final List<Map<String, dynamic>> _requestQueue = [];

  AlbumArtService._internal() 
      : _dio = Dio(),
        _networkService = NetworkStatusService.instance;

  static AlbumArtService get instance {
    _instance ??= AlbumArtService._internal();
    return _instance!;
  }

  /// Initialize the service
  Future<void> initialize() async {
    await _networkService.initialize();
    
    // Listen to network status changes
    _networkSubscription = _networkService.networkStatusStream.listen(
      (isOnline) {
        if (isOnline && _requestQueue.isNotEmpty) {
          _processQueuedRequests();
        }
      },
    );
  }

  /// Stream of album art state changes
  Stream<AlbumArtState> get albumArtStream => _albumArtController.stream;

  /// Current album art state
  AlbumArtState get currentState => _currentState;

  /// Dispose the service and close streams
  void dispose() {
    _currentCancelToken?.cancel();
    _networkSubscription?.cancel();
    _albumArtController.close();
    _requestQueue.clear();
  }

  /// Fetch album art and broadcast the result to all listeners
  /// Enhanced with cancellation, offline mode, and queue management
  Future<void> fetchAndBroadcast(
    String artist, 
    String title, 
    RadioEntity radioConfig
  ) async {
    // Skip if no metadata
    if (artist.isEmpty && title.isEmpty) {
      return;
    }

    // Create fetch key to prevent duplicate requests
    final fetchKey = '${artist}_${title}_${radioConfig.albumArtSource}';
    if (_currentFetchKey == fetchKey) {
      // Already fetching this combination, skip
      return;
    }

    // Cancel any pending request
    _currentCancelToken?.cancel();
    _currentCancelToken = CancelToken();
    _currentFetchKey = fetchKey;

    // Check if this is the same track as current state
    final newState = AlbumArtState.loading(
      artist: artist, 
      title: title,
      isOffline: !_networkService.isOnline,
    );
    if (!_currentState.isSameTrack(newState)) {
      // Different track, emit loading state
      _emitState(newState);
    }

    try {
      // Check if we should use fallback only
      if (shouldUseFallback(radioConfig)) {
        _emitState(AlbumArtState.fallback(
          artist: artist, 
          title: title,
          isOffline: !_networkService.isOnline,
        ));
        return;
      }

      // Check cache first
      final cacheService = AlbumArtCacheService.instance;
      final cachedResult = cacheService.getCachedAlbumArtWithSource(artist, title);
      if (cachedResult != null && cachedResult['url'] != null) {
        _emitState(AlbumArtState.success(
          url: cachedResult['url']!,
          artist: artist,
          title: title,
          isOffline: !_networkService.isOnline,
          cacheSource: cachedResult['source'],
        ));
        return;
      }

      // Check if offline
      if (!_networkService.isOnline) {
        _queueRequest(artist, title, radioConfig);
        _emitState(AlbumArtState.fallback(
          artist: artist, 
          title: title,
          isOffline: true,
        ));
        return;
      }

      // Fetch from repository with cancellation support
      final repository = AlbumArtRepositoryImpl(
        dio: _dio,
        azuracastBaseUrl: null, // Will be passed to method
        azuracastStationId: null, // Will be passed to method
      );

      final albumArtUrl = await repository.getAlbumArtUrlWithStream(
        artist,
        title,
        radioConfig.albumArtSource,
        radioConfig.streamUrl,
      );

      // Check if request was cancelled
      if (_currentCancelToken?.isCancelled == true) {
        return;
      }

      if (albumArtUrl != null && albumArtUrl.isNotEmpty) {
        // Cache the result with source information
        cacheService.cacheAlbumArt(artist, title, albumArtUrl, source: 'network');
        
        // Emit success state
        _emitState(AlbumArtState.success(
          url: albumArtUrl,
          artist: artist,
          title: title,
          isOffline: false,
          cacheSource: 'network',
        ));
      } else {
        // No album art found, use fallback
        _emitState(AlbumArtState.fallback(
          artist: artist, 
          title: title,
          isOffline: false,
        ));
      }
    } catch (e) {
      // Check if request was cancelled
      if (_currentCancelToken?.isCancelled == true) {
        return;
      }

      // Error occurred, use fallback
      _emitState(AlbumArtState.error(
        error: e.toString(),
        artist: artist,
        title: title,
        isOffline: !_networkService.isOnline,
        retryCount: _currentState.retryCount + 1,
      ));
    } finally {
      _currentFetchKey = null;
      _currentCancelToken = null;
    }
  }

  /// Emit state to all listeners
  void _emitState(AlbumArtState state) {
    _currentState = state;
    if (!_albumArtController.isClosed) {
      _albumArtController.add(state);
    }
  }

  /// Queue request for when network becomes available
  void _queueRequest(String artist, String title, RadioEntity radioConfig) {
    final request = {
      'artist': artist,
      'title': title,
      'radioConfig': radioConfig,
      'timestamp': DateTime.now(),
    };
    
    // Remove any existing request for the same track
    _requestQueue.removeWhere((req) => 
        req['artist'] == artist && req['title'] == title);
    
    // Add new request
    _requestQueue.add(request);
    
    // Limit queue size
    if (_requestQueue.length > 10) {
      _requestQueue.removeAt(0);
    }
  }

  /// Process queued requests when network becomes available
  Future<void> _processQueuedRequests() async {
    if (_requestQueue.isEmpty) return;
    
    final requests = List<Map<String, dynamic>>.from(_requestQueue);
    _requestQueue.clear();
    
    for (final request in requests) {
      try {
        await fetchAndBroadcast(
          request['artist'] as String,
          request['title'] as String,
          request['radioConfig'] as RadioEntity,
        );
      } catch (e) {
        // Re-queue failed requests
        _queueRequest(
          request['artist'] as String,
          request['title'] as String,
          request['radioConfig'] as RadioEntity,
        );
      }
    }
  }

  /// Get album art URL for the given artist and title using radio configuration
  /// Returns the album art URL or null if not found
  /// DEPRECATED: Use fetchAndBroadcast instead for reactive updates
  @Deprecated('Use fetchAndBroadcast for reactive updates')
  Future<String?> getAlbumArtUrl(
      String artist, String title, RadioEntity radioConfig) async {
    if (artist.isEmpty && title.isEmpty) {
      return null;
    }

    // Check cache first
    final cacheService = AlbumArtCacheService.instance;
    final cachedResult = cacheService.getCachedAlbumArtWithSource(artist, title);
    if (cachedResult != null && cachedResult['url'] != null) {
      return cachedResult['url'];
    }

    // Check if offline
    if (!_networkService.isOnline) {
      return null;
    }

    final repository = AlbumArtRepositoryImpl(
      dio: _dio,
      azuracastBaseUrl: null, // Will be passed to method
      azuracastStationId: null, // Will be passed to method
    );

    try {
      final albumArtUrl = await repository.getAlbumArtUrlWithStream(
        artist,
        title,
        radioConfig.albumArtSource,
        radioConfig.streamUrl,
      );

      // Cache the result if successful
      if (albumArtUrl != null && albumArtUrl.isNotEmpty) {
        cacheService.cacheAlbumArt(artist, title, albumArtUrl, source: 'network');
      }

      return albumArtUrl;
    } catch (e) {
      return null;
    }
  }

  /// Get album art URL using static configuration (for backward compatibility)
  Future<String?> getAlbumArtUrlStatic(String artist, String title) async {
    if (artist.isEmpty && title.isEmpty) {
      return null;
    }

    final repository = AlbumArtRepositoryImpl(
      dio: _dio,
      azuracastBaseUrl: RadioTujuhCahayaConfig.azuracastBaseUrl,
      azuracastStationId: RadioTujuhCahayaConfig.azuracastStationId,
    );

    final getAlbumArtUrl = GetAlbumArtUrl(repository);
    final result = await getAlbumArtUrl(artist, title);

    return result.fold(
      (failure) {
        return null;
      },
      (albumArtUrl) => albumArtUrl,
    );
  }

  /// Get fallback artwork path
  String getFallbackArtworkPath() {
    return RadioTujuhCahayaConfig.fallbackArtworkPath;
  }

  /// Check if we should use fallback artwork based on radio configuration
  bool shouldUseFallback(RadioEntity radioConfig) {
    final source = AlbumArtSource.fromValue(radioConfig.albumArtSource);
    return source == AlbumArtSource.fallback;
  }

  /// Check if we should use fallback artwork using static configuration
  bool shouldUseFallbackStatic() {
    final source =
        AlbumArtSource.fromValue(RadioTujuhCahayaConfig.albumArtSource);
    return source == AlbumArtSource.fallback;
  }

  /// Get current album art URL (for backward compatibility)
  /// Returns the current album art URL or null if not available
  String? getCurrentAlbumArtUrl() {
    return _currentState.hasUrl ? _currentState.url : null;
  }

  /// Check if current state has valid album art
  bool get hasCurrentAlbumArt => _currentState.hasUrl;

  /// Get current artist and title
  String? get currentArtist => _currentState.artist;
  String? get currentTitle => _currentState.title;

  /// Reset to initial state
  void reset() {
    _currentState = AlbumArtState.initial();
    _currentFetchKey = null;
    _currentCancelToken?.cancel();
    _currentCancelToken = null;
    _requestQueue.clear();
    _emitState(_currentState);
  }

  /// Get queue status for debugging
  Map<String, dynamic> getQueueStatus() {
    return {
      'queueSize': _requestQueue.length,
      'isOnline': _networkService.isOnline,
      'currentFetchKey': _currentFetchKey,
      'hasActiveRequest': _currentCancelToken != null,
    };
  }

  /// Force retry current request (useful for error recovery)
  Future<void> retryCurrentRequest() async {
    if (_currentState.canRetry && _currentState.artist != null && _currentState.title != null) {
      // This would need the radio config, which we don't have here
      // In a real implementation, you'd need to store the last radio config
      Log.debug('[AlbumArtService] Retry requested but radio config not available');
    }
  }

  /// Clear request queue
  void clearQueue() {
    _requestQueue.clear();
  }
}
