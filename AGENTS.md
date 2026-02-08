# AGENTS.md

Defines automation rules for this Flutter poker dice game.

## Project Overview

- **Type:** Flutter app (Android-first, Web-supported)
- **SDK:** Dart ^3.10.8
- **Linting:** flutter_lints ^6.0.0
- **Platforms:** Android, Web

## Commands

```bash
# Run all tests
flutter test

# Specific test file
flutter test test/widget_test.dart

# Single test method
flutter test --name="testCounterIncrements"

# Watch mode
flutter test --watch

# Analyze code
flutter analyze

# Auto-fix issues
flutter analyze --fix

# Run app locally
flutter run -d chrome

# Build APK
flutter build apk

# Build Web
flutter build web
```

## Style Guidelines

**Formatting:** Run `dart format .` before commits

**Imports:** dart → package → relative → third_party, grouped with blank lines

**Naming:**
- Classes: PascalCase (`GamePage`)
- Functions: camelCase (`calculateScore`)
- Variables: camelCase (`playerName`)
- Constants: UPPER_SNAKE_CASE (`MAX_PLAYERS`)
- Private: underscore prefix (`_privateMethod`)
- Booleans: is/has/can (`isVisible`)

**Types:** Use explicit types (`int`, `String`), not `var` or `dynamic`

**Error Handling:** Use try-catch, throw descriptive errors, never swallow exceptions

**Widgets:** Use const aggressively, separate logic from UI, avoid unnecessary rebuilds

**Organization:** Layered (UI → State → Domain → Data), feature folders for data/domain/presentation

## Testing

- Write tests for all new features
- Keep tests isolated and deterministic
- Mock external dependencies
- Place tests in `test/` mirroring `lib/` structure

## Architecture

- Feature-first with layered architecture
- State management: Riverpod (preferred)
- Maintain separation between UI, business logic, and data layers

## Dependencies

- Check `pubspec.yaml` before adding packages
- Prefer actively maintained packages
- Justify new dependencies in PR/description

## Commit Format

```
<type>(scope): <description>

feat(game): add poker dice logic
fix(ui): resolve widget rebuild issue
refactor(core): simplify state management
docs(readme): update setup instructions
```

Types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`

## Platform Notes

**Android:** Don't modify `applicationId`, `minSdkVersion`, `targetSdkVersion` without instruction. Keep Gradle changes minimal.

**Web:** Use `flutter run -d chrome` for development, clean web directory before rebuilding.
