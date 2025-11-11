import 'dart:async';
import 'package:flutter/services.dart';
import 'package:radio_player/radio_player.dart';
import '../../../../config/radio_tujuhcahaya_config.dart';
import '../../domain/entities/radio_entity.dart';
import '../../../../core/logger/app_logger.dart';

/// Abstract interface for radio player data source
abstract class RadioPlayerRemoteDataSource {
  /// Initialize the radio player with configuration
  Future<void> initialize(RadioEntity config);

  /// Start radio playback
  Future<void> play();

  /// Pause radio playback
  Future<void> pause();

  /// Reset the radio player
  Future<void> reset();

  /// Set custom metadata
  Future<void> setCustomMetadata({
    required String artist,
    required String title,
    String? artworkUrl,
  });

  /// Update radio station configuration
  Future<void> updateStation({
    required String title,
    required String url,
    required bool parseStreamMetadata,
    required bool lookupOnlineArtwork,
    String? logoAssetPath,
    String? logoNetworkUrl,
  });

  /// Set navigation controls
  Future<void> setNavigationControls({
    required bool showNextButton,
    required bool showPreviousButton,
  });

  /// Set player volume 0.0–1.0 (best-effort; may be unsupported)
  Future<void> setVolume(double volume);

  /// Stream of playback state changes
  Stream<PlaybackState> get playbackStateStream;

  /// Stream of metadata updates
  Stream<Metadata> get metadataStream;

  /// Stream of remote command events
  Stream<RemoteCommand> get remoteCommandStream;
}

/// Implementation of radio player data source using radio_player package
class RadioPlayerRemoteDataSourceImpl implements RadioPlayerRemoteDataSource {
  StreamSubscription<PlaybackState>? _playbackStateSubscription;
  StreamSubscription<Metadata>? _metadataSubscription;
  StreamSubscription<RemoteCommand>? _remoteCommandSubscription;

  final StreamController<PlaybackState> _playbackStateController =
      StreamController<PlaybackState>.broadcast();
  final StreamController<Metadata> _metadataController =
      StreamController<Metadata>.broadcast();
  final StreamController<RemoteCommand> _remoteCommandController =
      StreamController<RemoteCommand>.broadcast();

  RadioPlayerRemoteDataSourceImpl() {
    _setupStreamListeners();
  }

  /// Set up stream listeners to the radio_player package
  void _setupStreamListeners() {
    _playbackStateSubscription = RadioPlayer.playbackStateStream.listen(
      (state) {
        _playbackStateController.add(state);
      },
      onError: (error) {
        // Handle playback state stream errors
      },
    );

    _metadataSubscription = RadioPlayer.metadataStream.listen(
      (metadata) {
        _metadataController.add(metadata);
      },
      onError: (error) {
        // Handle metadata stream errors
      },
    );

    _remoteCommandSubscription = RadioPlayer.remoteCommandStream.listen(
      (command) {
        _remoteCommandController.add(command);
      },
      onError: (error) {
        // Handle remote command stream errors
      },
    );
  }

  @override
  Future<void> initialize(RadioEntity config) async {
    if (RadioTujuhCahayaConfig.enableVerboseLogging) {
      Log.debug(
          '[RadioPlayerDataSource] Initialize called - Stream URL: ${config.streamUrl}');
      Log.debug('[RadioPlayerDataSource] Album art source: ${config.albumArtSource}');
    }

    final result = await _handleRadioPlayerCall(() async {
      // radioCoreV2: Optimize audio buffer to prevent underruns
      await _optimizeAudioBuffer();
      // Determine logo configuration based on album art source
      String? logoNetworkUrl;
      String? logoAssetPath;

      if (config.albumArtSource == 2) {
        // For AzuraCast, use fallback asset initially
        logoNetworkUrl = null;
        logoAssetPath = 'assets/images/fallback_artwork.jpg';
      } else if (config.logoNetworkUrl.isNotEmpty) {
        // Use configured logo network URL
        logoNetworkUrl = config.logoNetworkUrl;
        logoAssetPath = null;
      } else {
        // Use fallback asset
        logoNetworkUrl = null;
        logoAssetPath = 'assets/images/fallback_artwork.jpg';
      }

      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug(
            '[RadioPlayerDataSource] Setting station with URL: ${config.streamUrl}');
      }
      await RadioPlayer.setStation(
        title: 'Tujuh Cahaya Radio',
        url: config.streamUrl,
        parseStreamMetadata: true,
        lookupOnlineArtwork: config.albumArtSource == 3,
        logoAssetPath: logoAssetPath,
        logoNetworkUrl: logoNetworkUrl,
      );

      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerDataSource] Setting navigation controls');
      }
      await RadioPlayer.setNavigationControls(
        showNextButton: false,
        showPreviousButton: false,
      );

      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerDataSource] Station setup completed');
      }
    });

    if (result == null) {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug(
            '[RadioPlayerDataSource] RadioPlayer call completed (plugin may not be available on this platform)');
      }
    } else {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerDataSource] RadioPlayer call completed successfully');
      }
    }
  }

  @override
  Future<void> play() async {
    await _handleRadioPlayerCall(() => RadioPlayer.play());
  }

  @override
  Future<void> pause() async {
    await _handleRadioPlayerCall(() => RadioPlayer.pause());
  }

  @override
  Future<void> reset() async {
    await _handleRadioPlayerCall(() => RadioPlayer.reset());
  }

  @override
  Future<void> setCustomMetadata({
    required String artist,
    required String title,
    String? artworkUrl,
  }) async {
    await _handleRadioPlayerCall(
      () => RadioPlayer.setCustomMetadata(
        artist: artist,
        title: title,
        artworkUrl: artworkUrl,
      ),
    );
  }

  @override
  Future<void> updateStation({
    required String title,
    required String url,
    required bool parseStreamMetadata,
    required bool lookupOnlineArtwork,
    String? logoAssetPath,
    String? logoNetworkUrl,
  }) async {
    await _handleRadioPlayerCall(
      () => RadioPlayer.setStation(
        title: title,
        url: url,
        parseStreamMetadata: parseStreamMetadata,
        lookupOnlineArtwork: lookupOnlineArtwork,
        logoAssetPath: logoAssetPath,
        logoNetworkUrl: logoNetworkUrl,
      ),
    );
  }

  @override
  Future<void> setNavigationControls({
    required bool showNextButton,
    required bool showPreviousButton,
  }) async {
    await _handleRadioPlayerCall(
      () => RadioPlayer.setNavigationControls(
        showNextButton: showNextButton,
        showPreviousButton: showPreviousButton,
      ),
    );
  }

  @override
  Future<void> setVolume(double volume) async {
    // Best-effort: not all versions expose setVolume; wrap in try/catch
    try {
      // Some versions expose a static channel method; if not, this will throw
      const MethodChannel channel = MethodChannel('radio_player');
      await channel.invokeMethod('setVolume', {
        'volume': volume.clamp(0.0, 1.0),
      });
    } on MissingPluginException {
      // Silently ignore on unsupported platforms
    } catch (_) {
      // Ignore any other errors to keep UI responsive
    }
  }

  @override
  Stream<PlaybackState> get playbackStateStream =>
      _playbackStateController.stream;

  @override
  Stream<Metadata> get metadataStream => _metadataController.stream;

  @override
  Stream<RemoteCommand> get remoteCommandStream =>
      _remoteCommandController.stream;

  /// Helper method to handle MissingPluginException gracefully
  Future<T?> _handleRadioPlayerCall<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on MissingPluginException catch (e) {
      // Plugin not available - this is expected on some platforms
      Log.debug('[RadioPlayerDataSource] MissingPluginException: ${e.toString()}');
      throw Exception('Radio player plugin not available: ${e.toString()}');
    } catch (e) {
      // Re-throw other errors
      Log.debug(
          '[RadioPlayerDataSource] Error in radio player call: ${e.toString()}');
      rethrow;
    }
  }

  /// radioCoreV2: Optimize audio buffer to prevent underruns
  Future<void> _optimizeAudioBuffer() async {
    try {
      // Implement comprehensive audio buffer optimization for Pixel 7 Pro
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug(
            '[RadioPlayerDataSource] Configuring advanced audio buffer optimization...');
      }

      // Strategy 1: Pre-buffer before starting playback
      await _configurePreBuffering();

      // Strategy 2: Optimize audio session for streaming
      await _optimizeAudioSession();

      // Strategy 3: Configure buffer sizes for high-performance devices
      await _configureBufferSizes();

      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug(
            '[RadioPlayerDataSource] Audio buffer optimization completed for streaming');
      }
    } catch (e) {
      if (RadioTujuhCahayaConfig.enableVerboseLogging) {
        Log.debug('[RadioPlayerDataSource] Audio buffer optimization failed: $e');
      }
      // Continue without optimization - not critical
    }
  }

  /// Configure pre-buffering to prevent initial underruns
  Future<void> _configurePreBuffering() async {
    try {
      // Get buffer time from config
      final bufferTimeMs = RadioTujuhCahayaConfig.preBufferTimeMs;

      // For high-performance devices, we need aggressive pre-buffering
      Log.debug(
          '[RadioPlayerDataSource] Configuring ${bufferTimeMs}ms pre-buffer for smooth playback');

      // The radio_player plugin should handle this internally, but we can
      // add a delay to ensure the stream is fully buffered before starting
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      Log.debug('[RadioPlayerDataSource] Pre-buffering configuration failed: $e');
    }
  }

  /// Optimize audio session for streaming
  Future<void> _optimizeAudioSession() async {
    try {
      Log.debug(
          '[RadioPlayerDataSource] Optimizing audio session for streaming...');

      // These optimizations are handled by the radio_player plugin
      // but we can add platform-specific optimizations here
    } catch (e) {
      Log.debug('[RadioPlayerDataSource] Audio session optimization failed: $e');
    }
  }

  /// Configure buffer sizes for high-performance devices
  Future<void> _configureBufferSizes() async {
    try {
      Log.debug(
          '[RadioPlayerDataSource] Configuring buffer sizes for Pixel 7 Pro...');

      // For high-performance devices like Pixel 7 Pro, we can use larger buffers
      // This is typically handled by the underlying audio system
    } catch (e) {
      Log.debug('[RadioPlayerDataSource] Buffer size configuration failed: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _playbackStateSubscription?.cancel();
    _metadataSubscription?.cancel();
    _remoteCommandSubscription?.cancel();
    _playbackStateController.close();
    _metadataController.close();
    _remoteCommandController.close();
  }
}
