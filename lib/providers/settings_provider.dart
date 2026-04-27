import 'package:riverpod/legacy.dart';
import '../services/storage_service.dart';

/// State class for settings provider.
///
/// Contains all settings-related state including:
/// - Theme preference (dark mode)
/// - High scores list
/// - Loading state
/// - Error messages
class SettingsState {
  /// Whether dark mode is enabled.
  final bool isDarkMode;

  /// List of high scores, sorted by score descending.
  final List<HighScoreEntry> highScores;

  /// Whether settings are currently loading.
  final bool isLoading;

  /// Any error message that occurred during loading or saving.
  final String? errorMessage;

  /// Creates a [SettingsState] with the specified parameters.
  const SettingsState({
    this.isDarkMode = false,
    this.highScores = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// Creates a copy of this state with updated fields.
  SettingsState copyWith({
    bool? isDarkMode,
    List<HighScoreEntry>? highScores,
    bool? isLoading,
    String? errorMessage,
  }) {
    return SettingsState(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      highScores: highScores ?? this.highScores,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier that manages settings state.
///
/// Handles loading, saving, and updating settings including:
/// - Theme preferences
/// - High scores
/// - Error handling
class SettingsNotifier extends StateNotifier<SettingsState> {
  /// Storage service for persisting settings.
  final StorageService _storageService;

  /// Creates a [SettingsNotifier] with the specified [storageService].
  ///
  /// If [storageService] is not provided, creates a new instance.
  SettingsNotifier({StorageService? storageService})
    : _storageService = storageService ?? StorageService(),
      super(const SettingsState());

  /// Loads settings from storage.
  ///
  /// Retrieves theme preference and high scores.
  /// Sets isLoading to true during loading and clears errors.
  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final isDarkMode = await _storageService.getThemePreference();
      final highScores = await _storageService.getHighScores();

      state = state.copyWith(
        isDarkMode: isDarkMode,
        highScores: highScores,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load settings: $e',
      );
    }
  }

  /// Toggles the dark mode theme preference.
  ///
  /// Saves the new preference to storage.
  Future<void> toggleTheme() async {
    final newIsDarkMode = !state.isDarkMode;

    try {
      await _storageService.saveThemePreference(newIsDarkMode);
      state = state.copyWith(isDarkMode: newIsDarkMode, errorMessage: null);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to save theme preference: $e',
      );
    }
  }

  /// Adds a high score entry.
  ///
  /// Saves the score to storage and reloads the high scores list.
  Future<void> addHighScore(String playerName, int score) async {
    try {
      await _storageService.saveHighScore(playerName, score);
      await loadSettings();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to save high score: $e');
    }
  }

  /// Clears all high scores.
  ///
  /// Removes all scores from storage and reloads the list.
  Future<void> clearHighScores() async {
    try {
      await _storageService.clearHighScores();
      await loadSettings();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to clear high scores: $e');
    }
  }

  /// Clears any error messages.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Checks if the given [score] would be a new high score.
  ///
  /// Returns true if the score is higher than the lowest high score
  /// or if there are fewer than 10 high scores.
  bool isHighScore(int score) {
    if (state.highScores.length < 10) {
      return true;
    }
    return score > state.highScores.last.score;
  }
}

/// Provider for settings state.
///
/// Use this provider to access settings state and actions.
///
/// Example:
/// ```dart
/// // Read settings state
/// final settings = ref.watch(settingsProvider);
///
/// // Access notifier for actions
/// final notifier = ref.read(settingsProvider.notifier);
/// await notifier.toggleTheme();
/// ```
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
