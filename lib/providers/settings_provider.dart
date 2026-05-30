import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/services/storage_service.dart';

/// Provider for the [StorageService] instance.
///
/// Uses a future provider to asynchronously initialize the service
/// with [SharedPreferences].
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.create();
});

/// Notifier that manages application settings including theme mode
/// and high scores persistence.
class SettingsNotifier extends StateNotifier<AsyncValue<List<HighScore>>> {
  /// Creates a settings notifier with the given [StorageService].
  ///
  /// If [initialState] is provided, the notifier starts in that state
  /// without automatically loading high scores. Useful for testing.
  SettingsNotifier(
    this._storageService, {
    AsyncValue<List<HighScore>>? initialState,
  }) : super(
          initialState ?? const AsyncValue.loading(),
        ) {
    if (initialState == null) {
      _loadHighScores();
    }
  }

  /// The underlying storage service for persistence operations.
  final StorageService _storageService;

  /// Loads high scores from persistent storage.
  Future<void> _loadHighScores() async {
    state = const AsyncValue.loading();
    try {
      final List<HighScore> scores = await _storageService.getHighScores();
      state = AsyncValue.data(scores);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Saves a new high score to persistent storage and updates the state.
  ///
  /// The score is added to the existing list, sorted in descending order,
  /// and trimmed to the maximum number of stored scores.
  Future<void> addHighScore(int score) async {
    try {
      final bool success = await _storageService.saveHighScore(score);
      if (success) {
        await _loadHighScores();
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clears all stored high scores.
  Future<void> clearHighScores() async {
    try {
      final bool success = await _storageService.clearHighScores();
      if (success) {
        state = const AsyncValue.data([]);
      }
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Saves the theme mode preference to persistent storage.
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _storageService.saveThemeMode(_themeModeToString(themeMode));
  }

  /// Retrieves the stored theme mode preference.
  ///
  /// Returns [ThemeMode.system] if no preference is stored.
  Future<ThemeMode> getThemeMode() async {
    final String themeModeString = await _storageService.getThemeMode();
    return _stringToThemeMode(themeModeString);
  }

  /// Converts a [ThemeMode] enum value to its string representation.
  static String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Converts a string representation to a [ThemeMode] enum value.
  static ThemeMode _stringToThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}

/// Provider for the [SettingsNotifier] that manages high scores and settings.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<List<HighScore>>>(
  (ref) {
    final StorageService? storageService =
        ref.watch(storageServiceProvider).value;
    assert(
      storageService != null,
      'StorageService must be initialized before accessing settings',
    );
    return SettingsNotifier(storageService!);
  },
);
