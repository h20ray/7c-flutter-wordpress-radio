/// Album art source options
enum AlbumArtSource {
  auto(1, 'Auto'),
  azuracast(2, 'AzuraCast'),
  appleMusic(3, 'Apple Music'),
  fallback(4, 'Fallback');

  const AlbumArtSource(this.value, this.displayName);

  final int value;
  final String displayName;

  static AlbumArtSource fromValue(int value) {
    return AlbumArtSource.values.firstWhere(
      (source) => source.value == value,
      orElse: () => AlbumArtSource.auto,
    );
  }
}

class RadioTujuhCahayaConfig {
  // ===========================================================================
  // 1. PRIMARY STATION CONFIGURATION (Most likely to be changed)
  // ===========================================================================

  /// Radio Station Name
  /// NOTE: The station name is now managed in the localization files.
  /// Please edit `assets/translations/id-ID.json` (and other languages)
  /// Key: "radio_station_name"

  /// Logo configuration
  static const String logoAssetPath = 'assets/images/radio_logo.png';
  static const String? logoNetworkUrl = null; // Will be implemented via server configuration
  
  /// Default Artwork (Displayed when no album art is available)
  static const String artworkUrl = 'assets/images/fallback_artwork.jpg';
  static const String fallbackArtworkPath = 'assets/images/fallback_artwork.jpg';

  /// Fallback Metadata (Displayed when stream metadata is missing)
  static const String fallbackArtist = 'Now On Air';
  static const String fallbackTitle = 'Live Radio Stream';

  /// Request/Feedback WebView configuration
  static const String requestWebViewTitle = 'Request Lagu'; // Set to desired title
  static const String requestWebViewUrl = 'https://www.upradio.id/request/'; // Set to target URL

  // ===========================================================================
  // 2. STREAM & PLAYBACK SETTINGS
  // ===========================================================================

  /// Radio player settings
  static const bool parseStreamMetadata = true;
  static const bool lookupOnlineArtwork = false;
  
  /// Backup stream URLs for failover
  /// Primary stream is configured via server, these are fallbacks
  static const List<String> backupStreamUrls = [
    // Add backup stream URLs here
    // Example: 'https://backup1.example.com/stream',
    // Example: 'https://backup2.example.com/stream',
  ];

  /// Album art configuration
  /// 1 = Auto (AzuraCast → Apple Music → Fallback)
  /// 2 = AzuraCast only
  /// 3 = Apple Music only
  /// 4 = Fallback only
  static const int albumArtSource = 1;

  /// AzuraCast configuration
  static const String? azuracastBaseUrl = null; // Set via server configuration
  static const String? azuracastStationId = null; // Set via server configuration

  /// Apple Music/iTunes configuration
  static const bool enableAppleMusicFallback = true;

  /// Metadata sanitization
  /// Any occurrence (case-insensitive) of these phrases in artist/title
  /// will be removed before display or lookup
  static const List<String> metadataRemovePhrases = [
    'now on air:',
    'now playing:',
    'now playng:',
    'on air:',
    'Sorry, service not available. Try again later.'
  ];

  // ===========================================================================
  // 3. UI & NAVIGATION SETTINGS
  // ===========================================================================

  /// Navigation controls settings
  static const bool showNextButton = false;
  static const bool showPreviousButton = false;

  /// Metadata update behavior
  static const bool delayMetadataUntilAudioStarts = true; // Wait for audio to start before updating metadata

  // ===========================================================================
  // 4. ADVANCED / TECHNICAL SETTINGS (Rarely changed)
  // ===========================================================================

  /// radioCoreV2 Feature Flag
  /// This will be overridden by server configuration at runtime
  static const bool radioCoreV2Enabled = true;

  /// Retry configuration
  static const int maxRetryAttempts = 4;
  static const List<int> retryBackoffDelays = [
    1000,
    2000,
    4000,
    8000
  ]; // milliseconds
  static const int debounceWindowMs = 200;

  /// Performance targets
  static const int targetColdStartMs = 3000; // 3 seconds
  static const int targetFastResumeMs = 500; // 500 milliseconds

  /// Audio buffer configuration to prevent underruns
  static const int audioBufferSize = 8192; // 8KB buffer
  static const int maxBufferUnderruns = 3; // Switch URL after 3 underruns

  /// Pre-buffering configuration for smooth playback
  static const int preBufferTimeMs = 500; // 2.5 seconds pre-buffer
  static const int audioSessionOptimizationDelayMs = 200; // 200ms delay for audio session
  static const int audioFocusDelayMs = 100; // 100ms delay for audio focus

  /// Notification update configuration
  static const int notificationMaxRetries = 2;
  static const int notificationInitialDelayMs = 500;
  static const double notificationBackoffMultiplier = 2.0;
  static const int notificationMaxDelayMs = 2000;

  /// Album art cache configuration
  static const int albumArtCacheTTLHours = 1; // 1 hour TTL
  static const int albumArtRequestTimeoutMs = 10000; // 10 seconds
  static const int albumArtMaxConcurrentRequests = 3;

  /// Debug settings
  static const bool enableDebugLogging = false;
  static const bool enableVerboseLogging = false; // Enable for testing
  static const bool enablePerformanceMonitoring = false; // Enable for testing
  static const bool logNotificationUpdates = true; // Enable for testing
  static const bool enableShoutboxDebugLogging = false; // Disable shoutbox debug logs to reduce spam
}
