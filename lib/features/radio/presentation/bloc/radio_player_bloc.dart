import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/audio/audio_focus_manager.dart';
import '../../../../config/radio_tujuhcahaya_config.dart';
import '../../domain/entities/radio_entity.dart';
import '../../domain/entities/radio_player_entity.dart';
import '../../domain/repositories/radio_player_repository.dart';
import '../../domain/usecases/initialize_radio_player.dart';
import '../../domain/usecases/play_radio.dart';
import '../../domain/usecases/pause_radio.dart';
import '../../domain/usecases/reset_radio_player.dart';
import '../bloc/radio_bloc.dart';
import '../bloc/radio_state.dart';
import 'radio_player_event.dart';
import '../../../../core/logger/app_logger.dart';
import 'radio_player_state.dart';

/// BLoC for managing radio player state and operations
/// This is the single source of truth for radio player state across the app
class RadioPlayerBloc extends Bloc<RadioPlayerEvent, RadioPlayerState> {
  final InitializeRadioPlayer initializeRadioPlayer;
  final PlayRadio playRadio;
  final PauseRadio pauseRadio;
  final ResetRadioPlayer resetRadioPlayer;
  final RadioPlayerRepository repository;
  final RadioBloc radioConfigBloc;

  StreamSubscription<RadioPlayerEntity>? _playerStateSubscription;
  StreamSubscription<RadioState>? _radioConfigSubscription;
  StreamSubscription<bool>? _audioFocusSubscription;
  StreamSubscription<AudioFocusEventData>? _audioFocusEventSubscription;

  // Store current radio config for initialization
  RadioEntity? _currentConfig;

  // Guard against duplicate initialization
  bool _initSent = false;

  // Pending autoplay flag
  bool _autoPlayPending = false;

  // Guard against rapid state changes
  bool? _lastKnownPlayingState;

  // Guard against rapid toggling (separate from play/pause debouncing)
  DateTime? _lastToggleTime;

  // Separate guards for direct play/pause calls
  DateTime? _lastPlayTime;
  DateTime? _lastPauseTime;

  // Audio focus state management
  bool _wasPlayingBeforeFocusLoss = false;
  bool _canAutoResume = false;

  RadioPlayerBloc({
    required this.initializeRadioPlayer,
    required this.playRadio,
    required this.pauseRadio,
    required this.resetRadioPlayer,
    required this.repository,
    required this.radioConfigBloc,
  }) : super(const RadioPlayerState.initial()) {
    // 1) Register event handlers FIRST
    on<RadioPlayerEvent>(_onRadioPlayerEvent);

    // 2) Then set up listeners that might call add()
    _setupStreamListeners();
    _setupRadioConfigListener();
    // Re-enable audio focus listeners with conservative approach
    _setupAudioFocusListener();
    _setupAudioFocusEventListener();
  }

  /// Set up stream listener to repository state changes
  void _setupStreamListeners() {
    _playerStateSubscription = repository.watchPlayerState().listen(
      (playerEntity) {
        // radioCoreV2: Enhanced state mapping
        if (playerEntity.errorMessage != null) {
          add(RadioPlayerEvent.errorOccurred(playerEntity.errorMessage!));
        } else if (playerEntity.isConnecting) {
          add(const RadioPlayerEvent.stateChanged('connecting'));
        } else if (playerEntity.isBuffering) {
          add(const RadioPlayerEvent.stateChanged('buffering'));
        } else if (playerEntity.isRetrying) {
          add(RadioPlayerEvent.retrying(
            playerEntity.retryAttempt,
            playerEntity.errorMessage ?? 'Retrying connection',
          ));
        } else if (playerEntity.isInitialized) {
          // Only emit playback state changes if the state actually changed
          if (_lastKnownPlayingState != playerEntity.isPlaying) {
            _lastKnownPlayingState = playerEntity.isPlaying;
            add(RadioPlayerEvent.playbackStateChanged(playerEntity.isPlaying));
          }

          if (playerEntity.hasMetadata) {
            add(RadioPlayerEvent.metadataUpdated(
              playerEntity.currentArtist,
              playerEntity.currentTitle,
            ));
          }
          if (playerEntity.hasAlbumArt) {
            add(RadioPlayerEvent.albumArtFetched(
                playerEntity.currentAlbumArtUrl!));
          }
        }
      },
      onError: (error) {
        add(RadioPlayerEvent.errorOccurred(
            'Stream error: ${error.toString()}'));
      },
    );
  }

  /// Set up listener to radio config changes
  void _setupRadioConfigListener() {
    Log.debug('[RadioPlayerBloc] Setting up radio config listener');
    _radioConfigSubscription?.cancel(); // Cancel previous subscription if any
    _radioConfigSubscription = radioConfigBloc.stream.listen(
      (radioState) {
        Log.debug('[RadioPlayerBloc] Radio config state changed: $radioState');
        radioState.maybeWhen(
          loaded: (radioConfig) {
            Log.debug(
                '[RadioPlayerBloc] Radio config loaded: ${radioConfig.streamUrl}');
            _currentConfig = radioConfig;

            // radioCoreV2: Auto-initialize with autoplay if enabled (guard against duplicates)
            if (radioConfig.enabled && radioConfig.autoplay && !_initSent) {
              Log.debug(
                  '[RadioPlayerBloc] Auto-initializing with autoplay enabled');
              _initSent = true;
              add(RadioPlayerEvent.initialize(radioConfig, autoPlay: true));
            } else if (radioConfig.enabled && !_initSent) {
              Log.debug('[RadioPlayerBloc] Auto-initializing without autoplay');
              _initSent = true;
              add(RadioPlayerEvent.initialize(radioConfig, autoPlay: false));
            }
          },
          orElse: () {
            Log.debug('[RadioPlayerBloc] Radio config not loaded yet: $radioState');
          },
        );
      },
    );

    // Also check current state immediately
    final currentRadioState = radioConfigBloc.state;
    Log.debug('[RadioPlayerBloc] Current radio config state: $currentRadioState');
    currentRadioState.maybeWhen(
      loaded: (radioConfig) {
        Log.debug(
            '[RadioPlayerBloc] Radio config already loaded: ${radioConfig.streamUrl}');
        _currentConfig = radioConfig;

        // radioCoreV2: Auto-initialize with autoplay if enabled (guard against duplicates)
        if (radioConfig.enabled && radioConfig.autoplay && !_initSent) {
          Log.debug(
              '[RadioPlayerBloc] Auto-initializing with autoplay enabled (immediate)');
          _initSent = true;
          add(RadioPlayerEvent.initialize(radioConfig, autoPlay: true));
        } else if (radioConfig.enabled && !_initSent) {
          Log.debug(
              '[RadioPlayerBloc] Auto-initializing without autoplay (immediate)');
          _initSent = true;
          add(RadioPlayerEvent.initialize(radioConfig, autoPlay: false));
        }
      },
      orElse: () {
        Log.debug('[RadioPlayerBloc] Radio config not loaded in current state');
      },
    );
  }

  /// Set up audio focus listener (legacy) - Conservative approach
  void _setupAudioFocusListener() {
    try {
      _audioFocusSubscription = AudioFocusManager.instance.focusStream.listen(
        (hasFocus) {
          if (!hasFocus) {
            // Lost audio focus - only pause if we're actually playing
            final currentState = state;
            currentState.maybeWhen(
              ready: (isPlaying, currentUrl, currentArtist, currentTitle,
                  currentAlbumArtUrl, isDucking, canAutoResume) {
                if (isPlaying) {
                  Log.debug('[RadioPlayerBloc] Lost audio focus, pausing playback');
                  add(const RadioPlayerEvent.pause());
                }
              },
              orElse: () {
                // Don't pause if not in ready state
              },
            );
          }
        },
      );
    } catch (e) {
      Log.debug('[RadioPlayerBloc] Audio focus listener setup failed: $e');
      // Continue without audio focus monitoring
    }
  }

  /// Set up enhanced audio focus event listener
  void _setupAudioFocusEventListener() {
    try {
      _audioFocusEventSubscription =
          AudioFocusManager.instance.focusEventStream.listen(
        (focusEvent) {
          _handleAudioFocusEvent(focusEvent);
        },
      );
    } catch (e) {
      Log.debug('[RadioPlayerBloc] Audio focus event listener setup failed: $e');
      // Continue without audio focus monitoring
    }
  }

  /// Handle audio focus events with smart behavior - Conservative approach
  void _handleAudioFocusEvent(AudioFocusEventData focusEvent) {
    Log.debug(
        '[RadioPlayerBloc] Audio focus event: ${focusEvent.event}, hasFocus: ${focusEvent.hasFocus}, shouldDuck: ${focusEvent.shouldDuck}');

    // Only handle focus events if we're in a ready state
    final currentState = state;
    currentState.maybeWhen(
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        switch (focusEvent.event) {
          case AudioFocusEvent.gain:
            _handleFocusGain();
            break;
          case AudioFocusEvent.loss:
            _handleFocusLoss();
            break;
          case AudioFocusEvent.lossTransient:
            _handleFocusLossTransient();
            break;
          case AudioFocusEvent.lossTransientCanDuck:
            _handleFocusLossTransientCanDuck();
            break;
        }
      },
      orElse: () {
        // Don't handle focus events if not in ready state
        Log.debug(
            '[RadioPlayerBloc] Ignoring audio focus event - not in ready state');
      },
    );
  }

  /// Handle focus gain - resume if we were playing before
  void _handleFocusGain() {
    if (_canAutoResume && _wasPlayingBeforeFocusLoss) {
      Log.debug('[RadioPlayerBloc] Auto-resuming playback after focus gain');
      add(const RadioPlayerEvent.play());
    }
    _canAutoResume = false;
    _wasPlayingBeforeFocusLoss = false;
  }

  /// Handle permanent focus loss - pause and don't auto-resume
  void _handleFocusLoss() {
    final currentState = state;
    currentState.maybeWhen(
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        if (isPlaying) {
          _wasPlayingBeforeFocusLoss = true;
          _canAutoResume = false; // Permanent loss, don't auto-resume
          Log.debug('[RadioPlayerBloc] Permanent focus loss, pausing playback');
          add(const RadioPlayerEvent.pause());
        }
      },
      orElse: () {},
    );
  }

  /// Handle transient focus loss - pause but be ready to resume
  void _handleFocusLossTransient() {
    final currentState = state;
    currentState.maybeWhen(
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        if (isPlaying) {
          _wasPlayingBeforeFocusLoss = true;
          _canAutoResume = true; // Transient loss, can auto-resume
          Log.debug(
              '[RadioPlayerBloc] Transient focus loss, pausing playback (will auto-resume)');
          add(const RadioPlayerEvent.pause());
        }
      },
      orElse: () {},
    );
  }

  /// Handle transient focus loss with ducking - reduce volume but keep playing
  void _handleFocusLossTransientCanDuck() {
    final currentState = state;
    currentState.maybeWhen(
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        if (isPlaying) {
          Log.debug(
              '[RadioPlayerBloc] Transient focus loss with ducking, reducing volume');
          // Update state to show ducking without pausing
          add(RadioPlayerEvent.playbackStateChanged(
              true)); // Keep playing but with ducking
        }
      },
      orElse: () {},
    );
  }

  /// Handle all radio player events
  Future<void> _onRadioPlayerEvent(
    RadioPlayerEvent event,
    Emitter<RadioPlayerState> emit,
  ) async {
    event.when(
      initialize: (config, autoPlay) =>
          _onInitialize(config, emit, autoPlay: autoPlay),
      play: () => _onPlay(emit),
      pause: () => _onPause(emit),
      togglePlayPause: () async => _onTogglePlayPause(emit),
      reset: () => _onReset(emit),
      playbackStateChanged: (isPlaying) =>
          _onPlaybackStateChanged(isPlaying, emit),
      metadataUpdated: (artist, title) =>
          _onMetadataUpdated(artist, title, emit),
      albumArtFetched: (albumArtUrl) => _onAlbumArtFetched(albumArtUrl, emit),
      errorOccurred: (message) => _onErrorOccurred(message, emit),
      stateChanged: (state) => _onStateChanged(state, emit),
      retrying: (attempt, reason) => _onRetrying(attempt, reason, emit),
      setCustomMetadata: (artist, title, artworkUrl) =>
          _onSetCustomMetadata(artist, title, artworkUrl, emit),
      updateStation: (title, url, parseStreamMetadata, lookupOnlineArtwork,
              logoAssetPath, logoNetworkUrl) =>
          _onUpdateStation(title, url, parseStreamMetadata, lookupOnlineArtwork,
              logoAssetPath, logoNetworkUrl, emit),
    );
  }

  /// Handle initialize event
  Future<void> _onInitialize(RadioEntity config, Emitter<RadioPlayerState> emit,
      {bool autoPlay = false}) async {
    Log.debug(
        '[RadioPlayerBloc] Initialize called - Stream URL: ${config.streamUrl}, AutoPlay: $autoPlay');
    emit(const RadioPlayerState.initializing());

    // Store config for later use
    _currentConfig = config;

    Log.debug('[RadioPlayerBloc] Calling initializeRadioPlayer use case');
    final result = await initializeRadioPlayer(config);
    result.fold(
      (failure) {
        Log.debug('[RadioPlayerBloc] Initialize failed: ${failure.message}');
        emit(
            RadioPlayerState.error(failure: failure, message: failure.message));
      },
      (_) async {
        Log.debug('[RadioPlayerBloc] Initialize succeeded');
        // Success - state will be updated via stream listener
        // If autoPlay is true, set flag and wait for ready state
        if (autoPlay) {
          Log.debug('[RadioPlayerBloc] AutoPlay enabled - waiting for ready state');
          _autoPlayPending = true;
        }
      },
    );
  }

  /// Handle play event
  Future<void> _onPlay(Emitter<RadioPlayerState> emit) async {
    // Prevent rapid play calls (separate from toggle debouncing)
    final now = DateTime.now();
    if (_lastPlayTime != null &&
        now.difference(_lastPlayTime!).inMilliseconds < 300) {
      Log.debug('[RadioPlayerBloc] Play request debounced (too rapid)');
      return;
    }
    _lastPlayTime = now;

    // Optimize audio session and request audio focus for smooth playback
    try {
      // First optimize the audio session for streaming
      await AudioFocusManager.instance.optimizeAudioSession();

      // Then request audio focus after a configurable delay to let the plugin initialize first
      final audioSessionDelay =
          RadioTujuhCahayaConfig.audioSessionOptimizationDelayMs;
      await Future.delayed(Duration(milliseconds: audioSessionDelay));
      final hasFocus = await AudioFocusManager.instance.requestAudioFocus();
      if (!hasFocus) {
        Log.debug('[RadioPlayerBloc] Audio focus denied, but continuing playback');
      } else {
        Log.debug('[RadioPlayerBloc] Audio focus granted successfully');
      }
    } catch (e) {
      Log.debug('[RadioPlayerBloc] Audio focus not available: $e');
      // Continue without audio focus - not critical
    }

    Log.debug('[RadioPlayerBloc] Starting playback');
    // Configurable delay to ensure audio focus is properly established
    final audioFocusDelay = RadioTujuhCahayaConfig.audioFocusDelayMs;
    await Future.delayed(Duration(milliseconds: audioFocusDelay));
    final result = await playRadio();
    result.fold(
      (failure) => emit(
          RadioPlayerState.error(failure: failure, message: failure.message)),
      (_) {
        // Success - state will be updated via stream listener
      },
    );
  }

  /// Handle pause event
  Future<void> _onPause(Emitter<RadioPlayerState> emit) async {
    // Prevent rapid pause calls (separate from toggle debouncing)
    final now = DateTime.now();
    if (_lastPauseTime != null &&
        now.difference(_lastPauseTime!).inMilliseconds < 300) {
      Log.debug('[RadioPlayerBloc] Pause request debounced (too rapid)');
      return;
    }
    _lastPauseTime = now;

    // Try to release audio focus (optional)
    try {
      await AudioFocusManager.instance.releaseAudioFocus();
    } catch (e) {
      Log.debug('[RadioPlayerBloc] Audio focus release failed: $e');
      // Continue - not critical
    }

    Log.debug('[RadioPlayerBloc] Pausing playback');
    final result = await pauseRadio();
    result.fold(
      (failure) => emit(
          RadioPlayerState.error(failure: failure, message: failure.message)),
      (_) {
        // Success - state will be updated via stream listener
      },
    );
  }

  /// Handle toggle play/pause event
  Future<void> _onTogglePlayPause(Emitter<RadioPlayerState> emit) async {
    // Prevent rapid toggling (debounce within 500ms)
    final now = DateTime.now();
    if (_lastToggleTime != null &&
        now.difference(_lastToggleTime!).inMilliseconds < 500) {
      Log.debug('[RadioPlayerBloc] Toggle request debounced (too rapid)');
      return;
    }
    _lastToggleTime = now;

    final currentState = state;
    // Debug logging can be removed for production

    currentState.maybeWhen(
      initial: () {
        Log.debug('[RadioPlayerBloc] In initial state');
        // Initialize and play if we have config
        if (_currentConfig != null) {
          Log.debug(
              '[RadioPlayerBloc] Initializing with config: ${_currentConfig!.streamUrl}');
          add(RadioPlayerEvent.initialize(_currentConfig!, autoPlay: true));
        } else {
          Log.debug(
              '[RadioPlayerBloc] ERROR: No config available for initialization');
        }
      },
      initializing: () {
        Log.debug('[RadioPlayerBloc] Already initializing, ignoring request');
        // Do nothing - wait for initialization to complete
      },
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        Log.debug('[RadioPlayerBloc] In ready state - isPlaying: $isPlaying');
        if (isPlaying) {
          Log.debug('[RadioPlayerBloc] Pausing playback');
          // Directly call pause without going through event system to avoid debounce conflicts
          _onPause(emit);
        } else {
          Log.debug('[RadioPlayerBloc] Starting playback');
          // Directly call play without going through event system to avoid debounce conflicts
          _onPlay(emit);
        }
      },
      error: (failure, message) {
        Log.debug('[RadioPlayerBloc] In error state: $message');
        // Retry initialization on error
        if (_currentConfig != null) {
          Log.debug('[RadioPlayerBloc] Retrying initialization after error');
          add(RadioPlayerEvent.initialize(_currentConfig!, autoPlay: true));
        } else {
          Log.debug('[RadioPlayerBloc] ERROR: No config available for retry');
        }
      },
      orElse: () {
        Log.debug('[RadioPlayerBloc] In unknown state: $currentState');
        // Do nothing for other states
      },
    );
  }

  /// Handle reset event
  Future<void> _onReset(Emitter<RadioPlayerState> emit) async {
    final result = await resetRadioPlayer();
    result.fold(
      (failure) => emit(
          RadioPlayerState.error(failure: failure, message: failure.message)),
      (_) => emit(const RadioPlayerState.initial()),
    );
  }

  /// Handle playback state changed event
  void _onPlaybackStateChanged(bool isPlaying, Emitter<RadioPlayerState> emit) {
    final currentState = state;
    currentState.maybeWhen(
      ready: (currentIsPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        emit(RadioPlayerState.ready(
          isPlaying: isPlaying,
          currentUrl: currentUrl,
          currentArtist: currentArtist,
          currentTitle: currentTitle,
          currentAlbumArtUrl: currentAlbumArtUrl,
          isDucking: isDucking,
          canAutoResume: canAutoResume,
        ));
      },
      orElse: () {
        // First playback state change after initialization
        emit(RadioPlayerState.ready(
          isPlaying: isPlaying,
          currentUrl: _currentConfig?.streamUrl, // Use stored config URL
          isDucking: false,
          canAutoResume: false,
        ));
        
        // Trigger autoplay if pending (matches manual play button logic)
        if (_autoPlayPending && !isPlaying) {
          Log.debug('[RadioPlayerBloc] Player ready - triggering pending autoplay');
          _autoPlayPending = false;
          add(const RadioPlayerEvent.togglePlayPause());
        }
      },
    );
  }

  /// Handle metadata updated event
  void _onMetadataUpdated(
      String? artist, String? title, Emitter<RadioPlayerState> emit) {
    final currentState = state;
    currentState.maybeWhen(
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        // Only emit if metadata actually changed
        if (currentArtist != artist || currentTitle != title) {
          emit(RadioPlayerState.ready(
            isPlaying: isPlaying,
            currentUrl: currentUrl,
            currentArtist: artist,
            currentTitle: title,
            currentAlbumArtUrl: currentAlbumArtUrl,
            isDucking: isDucking,
            canAutoResume: canAutoResume,
          ));
        }
      },
      orElse: () {},
    );
  }

  /// Handle album art fetched event
  void _onAlbumArtFetched(String albumArtUrl, Emitter<RadioPlayerState> emit) {
    final currentState = state;
    currentState.maybeWhen(
      ready: (isPlaying, currentUrl, currentArtist, currentTitle,
          currentAlbumArtUrl, isDucking, canAutoResume) {
        // Only emit if album art URL actually changed
        if (currentAlbumArtUrl != albumArtUrl) {
          emit(RadioPlayerState.ready(
            isPlaying: isPlaying,
            currentUrl: currentUrl,
            currentArtist: currentArtist,
            currentTitle: currentTitle,
            currentAlbumArtUrl: albumArtUrl,
            isDucking: isDucking,
            canAutoResume: canAutoResume,
          ));
        }
      },
      orElse: () {},
    );
  }

  /// Handle error occurred event
  void _onErrorOccurred(String message, Emitter<RadioPlayerState> emit) {
    // radioCoreV2: Enhanced error handling with failure types
    final failure = ServerFailure(message);
    emit(RadioPlayerState.error(failure: failure, message: message));
  }

  /// radioCoreV2: Handle state changed event
  void _onStateChanged(String state, Emitter<RadioPlayerState> emit) {
    switch (state) {
      case 'connecting':
        emit(const RadioPlayerState.connecting());
        break;
      case 'buffering':
        emit(const RadioPlayerState.buffering());
        break;
      default:
        Log.debug('[RadioPlayerBloc] Unknown state: $state');
    }
  }

  /// radioCoreV2: Handle retrying event
  void _onRetrying(int attempt, String reason, Emitter<RadioPlayerState> emit) {
    emit(RadioPlayerState.retrying(attempt: attempt, reason: reason));
  }

  /// Handle set custom metadata event
  Future<void> _onSetCustomMetadata(String artist, String title,
      String? artworkUrl, Emitter<RadioPlayerState> emit) async {
    final result = await repository.setCustomMetadata(
      artist: artist,
      title: title,
      artworkUrl: artworkUrl,
    );
    result.fold(
      (failure) => emit(
          RadioPlayerState.error(failure: failure, message: failure.message)),
      (_) {
        // Success - no state change needed
      },
    );
  }

  /// Handle update station event
  Future<void> _onUpdateStation(
      String title,
      String url,
      bool parseStreamMetadata,
      bool lookupOnlineArtwork,
      String? logoAssetPath,
      String? logoNetworkUrl,
      Emitter<RadioPlayerState> emit) async {
    final result = await repository.updateStation(
      title: title,
      url: url,
      parseStreamMetadata: parseStreamMetadata,
      lookupOnlineArtwork: lookupOnlineArtwork,
      logoAssetPath: logoAssetPath,
      logoNetworkUrl: logoNetworkUrl,
    );
    result.fold(
      (failure) => emit(
          RadioPlayerState.error(failure: failure, message: failure.message)),
      (_) {
        // Success - no state change needed
      },
    );
  }

  @override
  Future<void> close() {
    _playerStateSubscription?.cancel();
    _radioConfigSubscription?.cancel();
    _audioFocusSubscription?.cancel();
    _audioFocusEventSubscription?.cancel();
    AudioFocusManager.instance.dispose();
    return super.close();
  }
}
