import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing high score persistence.
class ScoreRepository {
  /// The key used to store the high score in SharedPreferences.
  static const String HIGH_SCORE_KEY = 'high_score';

  final SharedPreferences _sharedPreferences;

  /// Creates a [ScoreRepository] with the given [sharedPreferences] instance.
  ScoreRepository(this._sharedPreferences);

  /// Saves the high [score] to persistent storage.
  ///
  /// Throws a [StateError] if the save operation fails.
  Future<void> saveHighScore(int score) async {
    try {
      final bool written = await _sharedPreferences.setInt(
        HIGH_SCORE_KEY,
        score,
      );
      if (!written) {
        throw StateError('Failed to save high score to SharedPreferences');
      }
    } catch (e) {
      throw StateError('Failed to save high score: $e');
    }
  }

  /// Loads the high score from persistent storage.
  ///
  /// Returns 0 if no high score has been saved yet.
  Future<int> loadHighScore() async {
    try {
      return _sharedPreferences.getInt(HIGH_SCORE_KEY) ?? 0;
    } catch (e) {
      throw StateError('Failed to load high score: $e');
    }
  }

  /// Clears the saved high score from persistent storage.
  ///
  /// Throws a [StateError] if the clear operation fails.
  Future<void> clearHighScore() async {
    try {
      final bool removed = await _sharedPreferences.remove(HIGH_SCORE_KEY);
      if (!removed) {
        throw StateError('Failed to clear high score from SharedPreferences');
      }
    } catch (e) {
      throw StateError('Failed to clear high score: $e');
    }
  }
}
