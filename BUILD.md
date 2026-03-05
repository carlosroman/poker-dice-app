# Build Documentation

## Build Commands

### Development
```bash
# Run app locally on Chrome
flutter run -d chrome

# Run app locally on Android device
flutter run -d <device-id>
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run specific test by name
flutter test --name="testCounterIncrements"

# Watch mode for continuous testing
flutter test --watch
```

### Analysis
```bash
# Analyze code for issues
flutter analyze

# Auto-fix analysis issues
flutter analyze --fix

# Format code
dart format .
```

### Production Builds
```bash
# Build APK for Android
flutter build apk

# Build web application
flutter build web
```

## Build Artifact Locations

| Build Type | Location | Size |
|------------|----------|------|
| Web Build | `build/web/` | ~30MB |
| Android APK (Release) | `build/app/outputs/flutter-apk/app-release.apk` | ~44MB |
| Flutter Assets | `build/flutter_assets/` | - |
| Native Libraries | `build/native_assets/` | - |
| Unit Test Assets | `build/unit_test_assets/` | - |

## Build Sizes

- **Web**: ~30MB (uncompressed)
- **Android APK**: ~44MB (release build)

*Note: Build sizes may vary based on dependencies and Flutter SDK version.*

## Notes for Future Builds

### Prerequisites
- Flutter SDK: ^3.10.8
- Dart SDK: ^3.10.8
- Android SDK (for Android builds)
- Chrome browser (for web testing)

### Dependencies
Key dependencies that affect build size:
- `flutter_riverpod: ^2.4.0` - State management
- `shared_preferences: ^2.2.0` - Local persistence
- `google_fonts: ^6.0.0` - Custom fonts

### Build Clean-Up
To clean build artifacts:
```bash
flutter clean
flutter pub get
```

### Platform Support
- **Android**: First-class support (APK builds)
- **Web**: Fully supported (build web)
- **iOS**: Not currently configured

### CI/CD Considerations
- Run `flutter analyze` before builds to ensure no linting errors
- Run `flutter test` to verify all tests pass
- Use `dart format .` before committing to maintain code style

### Environment Variables
No custom environment variables required for builds.