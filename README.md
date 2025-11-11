# 7C Flutter WordPress Radio

A Flutter application for streaming radio with WordPress integration, Firebase analytics/auth, OneSignal push notifications, ads, offline caching, and multi-language support.

This repository is prepared for development on macOS, Linux, and Windows, and can build/distribute to Android and iOS out of the box. Desktop (macOS, Windows, Linux) builds are supported by Flutter; see Desktop Setup below to enable and generate platform folders.

## Features

- WordPress-powered content (posts, categories, comments)
- Radio streaming with album art and multiple sources
- Firebase (Core, Analytics, Auth)
- OneSignal push notifications
- Google Mobile Ads and Facebook Audience Network via `easy_ads_flutter`
- Deep links and in-app web view
- Offline caching with Hive and sqflite
- Light/Dark themes and localization (English, Indonesian)

## Requirements

- Flutter SDK 3.19+ (Dart 3)
- Xcode (for iOS/macOS), Android Studio/SDK (for Android), appropriate toolchains for Windows/Linux if targeting desktop
- Firebase project (GoogleService-Info.plist for iOS, google-services.json for Android)
- OneSignal app setup (with iOS Notification Service Extension already included in this repo)

## Getting Started

1) Clone and install dependencies

```bash
flutter pub get
```

2) Configure platforms

- Android: Place `android/app/google-services.json`
- iOS: Place `ios/Runner/GoogleService-Info.plist`
- OneSignal:
  - iOS: Set your OneSignal App ID in `Runner` target capabilities and ensure the `OneSignalNotificationServiceExtension` bundle ID and entitlements match your project
  - Android: Configure OneSignal in native and/or Flutter as needed per `onesignal_flutter` package docs

3) App configuration

- Review and update configuration in:
  - `lib/config/wp_config.dart` (WordPress)
  - `lib/config/radio_tujuhcahaya_config.dart` (radio and album art)
  - `lib/config/ad_config.dart` (ads)
  - `lib/config/app_images_config.dart` (branding)
- Assets are declared in `pubspec.yaml` under `assets/`
- Localizations are in `assets/translations/`

4) Run the app

```bash
flutter run
```

## Desktop Setup (macOS, Windows, Linux)

Flutter supports desktop; to enable and generate platform folders:

```bash
# Enable desktop targets
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop

# Generate missing platform folders
flutter create . --platforms=android,ios,macos,windows,linux
```

Notes:
- Some plugins have limited desktop support. Review the `pubspec.yaml` dependencies and each plugin’s platform matrix.
- If a plugin is not supported on a desktop target, guard usage at runtime or use alternative implementations.

## Build and Release

Android:
```bash
# Split APKs by ABI (adds obfuscation and debug info split path)
flutter build apk --split-per-abi --obfuscate --split-debug-info=./private/data/

# AppBundle for Play Store
flutter build appbundle --obfuscate --split-debug-info=./private/data/
```

iOS:
```bash
# Use Xcode for signing and distribution after this
flutter build ipa --obfuscate --split-debug-info=./private/data/ --build-name=<version> --build-number=<number>
```

macOS:
```bash
flutter build macos --release
```

Windows:
```bash
flutter build windows --release
```

Linux:
```bash
flutter build linux --release
```

## Album Art Configuration

Album art supports Auto, AzuraCast-only, Apple Music-only, and Fallback-only modes. See `ALBUM_ART_CONFIGURATION.md` for a complete guide, including client-side and server-side details and example usage.

## Project Structure (high level)

- `lib/core`: shared components, constants, controllers, DI, errors, localization, logger, models, repositories, routes, services, themes, utils, widgets
- `lib/features/radio`: radio domain/data/presentation
- `lib/views`: UI screens for auth, base, explore, home, onboarding, saved, settings, etc.
- `assets`: images, svgs, animations, translations, fonts

## Common Issues

- CocoaPods issues on iOS/macOS: run `pod repo update` and `pod install` in `ios`/`macos` folders
- M1/M2 macOS toolchain: ensure proper homebrew and Ruby setup for CocoaPods
- Android build failures: ensure correct `compileSdkVersion` and installed SDK components in Android Studio

## Development Notes

- Lints configured in `analysis_options.yaml`
- Coverage output goes to `coverage/`
- Private build artifacts and symbol/debug info are ignored via `.gitignore` (`private/` is ignored)

## License

See `LICENSE`.

## Helpful Commands

Android package name:

```bash
flutter pub run change_app_package_name:main com.yourapp.id
```

Splash screen and launcher icons:

```bash
flutter pub run flutter_native_splash:create
flutter pub run flutter_launcher_icons:main
```

Build APKs:

```bash
# Split per ABI with obfuscation and split debug info
flutter build apk --split-per-abi --obfuscate --split-debug-info=./private/data/

# Single target platform example
flutter build apk --target-platform android-arm64
```

Build App Bundle:

```bash
flutter build appbundle --obfuscate --split-debug-info=./private/data/
```

Build iOS IPA:

```bash
flutter build ipa --obfuscate --split-debug-info=./private/data/ --build-name=<version> --build-number=<number>
```

Test Android App Links:

```bash
adb shell 'am start -W -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://newspro.uixxy.com/elon-musk-bought-twitter/"'
```

