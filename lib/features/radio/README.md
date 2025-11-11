# Radio Feature

## Overview

The Radio feature provides a complete radio streaming solution for the Tujuh Cahaya WordPress Flutter app. It implements Clean Architecture principles with feature-first organization and uses flutter_bloc for state management.

## Architecture

### Clean Architecture Implementation

The radio feature follows Clean Architecture with three distinct layers:

```
lib/features/radio/
├── domain/                    # Business Logic Layer
│   ├── entities/             # Core business objects
│   ├── repositories/         # Repository interfaces (abstractions)
│   └── usecases/            # Business logic use cases
├── data/                     # Data Layer
│   ├── datasources/         # Remote and local data sources
│   ├── models/              # DTOs and data models
│   ├── repositories/        # Repository implementations
│   └── services/            # Data services and utilities
└── presentation/            # Presentation Layer
    ├── bloc/                # State management (BLoC pattern)
    ├── pages/               # Screen widgets
    └── widgets/             # Feature-specific widgets
```

### Domain Layer

#### Entities
- **RadioEntity**: Core business object representing radio configuration
  - Stream URL, autoplay settings, album art preferences
  - Metadata URL, logo configuration, text scrolling options
  - Album art source configuration and last updated timestamp

#### Repositories (Interfaces)
- **RadioRepository**: Abstract interface for radio configuration operations
- **AlbumArtRepository**: Abstract interface for album art operations

#### Use Cases
- **GetRadioConfig**: Retrieves radio configuration from remote source
- **GetAlbumArtUrl**: Fetches album art URL for given artist/title

### Data Layer

#### Data Sources
- **RadioRemoteDataSource**: Fetches radio configuration from WordPress API
- **AlbumArtRemoteDataSource**: Handles album art API calls

#### Models
- **RadioModel**: Data model extending RadioEntity with JSON serialization
  - Handles API response parsing and validation
  - Includes comprehensive logging for debugging

#### Repository Implementations
- **RadioRepositoryImpl**: Implements radio configuration repository
  - Uses Either<Failure, Success> pattern for error handling
  - Handles network timeouts and server errors gracefully
- **AlbumArtRepositoryImpl**: Implements album art repository
  - Supports multiple album art sources (Auto, AzuraCast, Apple Music, Fallback)
  - Includes AzuraCast detection and configuration

#### Services
- **AlbumArtService**: Singleton service for album art operations
  - Manages caching and fallback strategies
  - Integrates with radio configuration for dynamic source selection
- **AlbumArtCacheService**: Handles album art URL caching
- **AzuraCastDetectionService**: Detects and configures AzuraCast streams

### Presentation Layer

#### State Management (BLoC)
- **RadioBloc**: Manages radio configuration state
  - Handles loading, success, and error states
  - Supports refresh functionality
- **RadioEvent**: Events for radio operations (get config, refresh)
- **RadioState**: Immutable states using Freezed (initial, loading, loaded, error)

#### Pages
- **RadioPage**: Main radio page with Material 3 design
  - Large flexible app bar with gradient background
  - Handles disabled state and error scenarios
  - Integrates with RadioPlayerWidget

#### Widgets
- **RadioPlayerWidget**: Core radio player implementation
  - Global state management for player initialization
  - Real-time metadata and playback state handling
  - Album art integration with caching
  - Error handling and graceful degradation

## Key Features

### Radio Player Widget

#### Core Functionality
- **Stream Management**: Handles radio stream initialization and playback
- **State Tracking**: Global state management for player status
- **Metadata Display**: Real-time artist and title information
- **Error Handling**: Graceful handling of MissingPluginException and network errors

#### UI Components
- **Play/Pause Controls**: Large circular button with visual feedback
- **Status Display**: Shows current playback state and error messages
- **Album Art Display**: Dynamic album art with fallback support
- **Configuration Info**: Displays current radio configuration

#### Advanced Features
- **Auto-play Support**: Configurable automatic playback
- **Text Scrolling**: Configurable text scrolling for long titles
- **Album Art Integration**: Multiple sources with caching
- **Notification Support**: Custom metadata in system notifications

### Album Art System

#### Multiple Sources
1. **Auto Mode**: Intelligent fallback chain (AzuraCast → Apple Music → Fallback)
2. **AzuraCast**: Direct integration with AzuraCast API
3. **Apple Music**: iTunes/Apple Music API integration
4. **Fallback**: Local asset fallback

#### Caching Strategy
- **Memory Caching**: In-memory cache for frequently accessed album art
- **Debouncing**: Prevents excessive API calls during metadata updates
- **Fallback Handling**: Graceful degradation when sources fail

### Configuration System

#### WordPress Integration
- **Remote Configuration**: Fetches settings from WordPress API endpoint
- **Dynamic Updates**: Supports runtime configuration changes
- **Error Handling**: Robust error handling for network issues

#### Configuration Options
- **Stream Settings**: URL, autoplay, metadata parsing
- **UI Preferences**: Album art display, text scrolling
- **Album Art Source**: Configurable source selection
- **AzuraCast Integration**: Optional AzuraCast configuration

## Development History

### Initial Implementation
- ✅ **Clean Architecture Setup**: Implemented three-layer architecture
- ✅ **Domain Layer**: Created entities, repositories, and use cases
- ✅ **Data Layer**: Implemented data sources, models, and repository implementations
- ✅ **Presentation Layer**: Created BLoC state management and UI components

### Core Features Development
- ✅ **Radio Player Widget**: Implemented core streaming functionality
- ✅ **State Management**: Added global state tracking and BLoC integration
- ✅ **Error Handling**: Implemented comprehensive error handling with Either pattern
- ✅ **WordPress Integration**: Connected to WordPress API for configuration

### Album Art System
- ✅ **Multiple Sources**: Implemented Auto, AzuraCast, Apple Music, and Fallback sources
- ✅ **Caching Service**: Added album art caching with memory management
- ✅ **AzuraCast Detection**: Implemented automatic AzuraCast stream detection
- ✅ **Dynamic Configuration**: Added runtime album art source selection

### UI/UX Enhancements
- ✅ **Material 3 Design**: Implemented modern Material 3 UI components
- ✅ **Large App Bar**: Added flexible app bar with gradient background
- ✅ **Error States**: Implemented comprehensive error handling UI
- ✅ **Loading States**: Added proper loading indicators and state management

### Advanced Features
- ✅ **Notification Integration**: Added custom metadata in system notifications
- ✅ **Text Scrolling**: Implemented configurable text scrolling for long titles
- ✅ **Auto-play Support**: Added configurable automatic playback
- ✅ **Global State Management**: Implemented cross-widget state sharing

### Performance Optimizations
- ✅ **Debouncing**: Added debouncing for album art API calls
- ✅ **Caching**: Implemented comprehensive caching strategies
- ✅ **Error Recovery**: Added graceful error recovery and fallback mechanisms
- ✅ **Memory Management**: Optimized memory usage and cleanup

### FAB Integration & User Experience
- ✅ **First-Click Success**: FAB play button now works immediately on first click
- ✅ **Smart State Management**: Automatic initialization and playback handling
- ✅ **Visual Feedback**: Loading indicators and proper state transitions
- ✅ **Debouncing**: Prevents rapid-click issues and race conditions
- ✅ **Auto-Play**: Seamless initialization with immediate playback
- ✅ **Error Recovery**: Automatic retry on initialization failures
- ✅ **State Preservation**: Maintains configuration across state transitions

## Configuration

### WordPress API Endpoint
```
GET https://{domain}/wp-json/newspro/v2/radio-config
```

### Response Format
```json
{
  "enabled": true,
  "streamUrl": "https://stream.example.com/radio",
  "autoplay": false,
  "showAlbumCover": true,
  "textScrolling": true,
  "metadataUrl": "https://stream.example.com/metadata",
  "logoNetworkUrl": "https://example.com/logo.png",
  "albumArtSource": 1,
  "lastUpdated": "2024-01-01T00:00:00Z"
}
```

### Album Art Source Values
- `1`: Auto (AzuraCast → Apple Music → Fallback)
- `2`: AzuraCast only
- `3`: Apple Music only
- `4`: Fallback only

## Dependencies

### Core Dependencies
- `flutter_bloc`: State management
- `dartz`: Functional programming (Either pattern)
- `freezed`: Immutable data classes
- `equatable`: Value equality
- `dio`: HTTP client
- `radio_player`: Radio streaming

### Development Dependencies
- `build_runner`: Code generation
- `freezed`: Code generation for immutable classes

## Testing Strategy

### Unit Tests
- Domain layer use cases and entities
- Data layer repositories and data sources
- BLoC state management logic

### Integration Tests
- End-to-end radio streaming functionality
- Album art fetching and caching
- Configuration loading and error handling

### Widget Tests
- Radio player widget interactions
- State management and UI updates
- Error state handling

## Future Enhancements

### Planned Features
- [ ] **Playlist Support**: Multiple radio stations
- [ ] **Offline Mode**: Cached content playback
- [ ] **Equalizer**: Audio enhancement controls
- [ ] **Recording**: Stream recording functionality
- [ ] **Social Features**: Share current track

### Technical Improvements
- [ ] **Performance Monitoring**: Add analytics and performance tracking
- [ ] **A/B Testing**: Configuration-based feature testing
- [ ] **Accessibility**: Enhanced accessibility support
- [ ] **Internationalization**: Multi-language support improvements

## Troubleshooting

### Common Issues

#### Radio Not Playing
1. Check network connectivity
2. Verify stream URL is accessible
3. Check WordPress API endpoint configuration
4. Review error logs for specific error messages

#### Album Art Not Loading
1. Verify album art source configuration
2. Check network connectivity for external APIs
3. Review caching service logs
4. Test with fallback mode

#### Configuration Not Loading
1. Verify WordPress API endpoint
2. Check network connectivity
3. Review API response format
4. Check error handling logs

### Debug Mode
Enable debug logging by setting `RadioTujuhCahayaConfig.enableDebugLogging = true` in the configuration file.

## Contributing

When contributing to the radio feature:

1. **Follow Clean Architecture**: Maintain separation of concerns
2. **Use BLoC Pattern**: Implement proper state management
3. **Handle Errors**: Use Either pattern for error handling
4. **Write Tests**: Add unit and integration tests
5. **Document Changes**: Update this README with new features

## License

This radio feature is part of the Tujuh Cahaya WordPress Flutter app and follows the same licensing terms.
