# Album Art Configuration Guide

This document explains how to configure and use the new album art system in the Tujuh Cahaya Radio Flutter app.

## Overview

The album art system supports 4 different sources for fetching album artwork:

1. **Auto (1)** - Smart fallback sequence: AzuraCast → Apple Music → Fallback
2. **AzuraCast (2)** - Direct from AzuraCast API only
3. **Apple Music (3)** - iTunes/Apple Music API only  
4. **Fallback (4)** - Asset-based default image only

## Configuration

### Client-Side Configuration

In `lib/config/radio_tujuhcahaya_config.dart`, you can set the default album art source:

```dart
/// Album art configuration
/// 1 = Auto (AzuraCast → Apple Music → Fallback)
/// 2 = AzuraCast only
/// 3 = Apple Music only  
/// 4 = Fallback only
static const int albumArtSource = 1;
```

### Server-Side Configuration

The WordPress admin panel now includes new fields for album art configuration:

#### Album Art Source
- **Field**: `radio_album_art_source`
- **Type**: Number (1-4)
- **Description**: Choose how album art is fetched
- **Default**: 1 (Auto)

#### AzuraCast Configuration
- **Client-Side Detection**: AzuraCast base URL and station short name are automatically detected on the Flutter client side
- **No Server-Side HTTP Requests**: Detection happens asynchronously in Flutter to avoid blocking the WordPress API response
- **Station ID Format**: AzuraCast uses station short names (e.g., `tujuhcahaya_radio`) in the API endpoint `/api/nowplaying/{station_short_name}/art`
- **Detection Method**: The system extracts the station short name from the `/listen/{station_short_name}/` path pattern
- **Art Endpoint**: Uses the direct art endpoint with cache-busting timestamps for optimal performance
- **Performance**: Fast WordPress API response without HTTP delays

## How It Works

### Auto Mode (Source = 1)
1. First tries to fetch album art from AzuraCast API (auto-detected from stream URL)
2. If AzuraCast fails or is not detected, tries Apple Music/iTunes API
3. If both fail, uses the fallback asset image

### AzuraCast Mode (Source = 2)
- Only fetches album art from AzuraCast API
- Automatically detects AzuraCast configuration from stream URL
- Uses the `/api/nowplaying/{station_short_name}/art` endpoint with cache-busting timestamps
- Directly returns the art URL without parsing JSON responses

### Apple Music Mode (Source = 3)
- Only fetches album art from iTunes Search API
- Searches using artist and title information
- Returns high-resolution (600x600) artwork URLs
- No additional configuration required

### Fallback Mode (Source = 4)
- Always uses the fallback asset image
- No network requests are made
- Uses `assets/images/fallback_artwork.jpg`

## Implementation Details

### Clean Architecture Structure

```
lib/features/radio/
├── data/
│   ├── datasources/
│   │   └── album_art_remote_datasource.dart
│   ├── repositories/
│   │   └── album_art_repository_impl.dart
│   └── services/
│       └── album_art_service.dart
├── domain/
│   ├── entities/
│   │   └── radio_entity.dart (updated)
│   ├── repositories/
│   │   └── album_art_repository.dart
│   └── usecases/
│       └── get_album_art_url.dart
└── presentation/
    └── widgets/
        └── radio_player_widget.dart (updated)
```

### Key Components

1. **AlbumArtService** - Main service for managing album art operations
2. **AlbumArtRepository** - Repository pattern for data access
3. **AzuraCastAlbumArtDataSource** - Handles AzuraCast API integration
4. **AppleMusicAlbumArtDataSource** - Handles iTunes API integration
5. **RadioEntity** - Updated to include album art configuration fields

### Integration with Radio Player

The radio player widget automatically:
1. Fetches album art when new metadata is received
2. Updates the notification with the fetched artwork
3. Falls back gracefully when album art cannot be fetched
4. Uses the configured album art source from the radio entity

## Usage Examples

### Setting Album Art Source via Configuration

```dart
// In radio_tujuhcahaya_config.dart
static const int albumArtSource = 2; // AzuraCast only
```

### Using Album Art Service Directly

```dart
final albumArtService = AlbumArtService.instance;

// Get album art using radio configuration
final albumArtUrl = await albumArtService.getAlbumArtUrl(
  'Artist Name',
  'Song Title',
  radioConfig,
);

// Check if fallback should be used
final shouldUseFallback = albumArtService.shouldUseFallback(radioConfig);

// Get fallback artwork path
final fallbackPath = albumArtService.getFallbackArtworkPath();
```

## Error Handling

The system includes comprehensive error handling:
- Network timeouts (10 seconds)
- API failures are logged but don't crash the app
- Graceful fallback to next source in Auto mode
- Debug logging when `enableDebugLogging` is true

## Debugging

Enable debug logging in `radio_tujuhcahaya_config.dart`:

```dart
static const bool enableDebugLogging = true;
```

This will log:
- Album art source selection
- API requests and responses
- Error messages
- Fallback decisions

## Performance Considerations

- Network requests are cached by the HTTP client
- Timeouts prevent hanging requests
- Album art is only fetched when metadata changes
- Fallback mode requires no network requests

## Future Enhancements

Potential improvements for future versions:
- Local caching of album art
- Multiple fallback sources
- Custom album art providers
- Batch album art fetching
- Album art quality selection
