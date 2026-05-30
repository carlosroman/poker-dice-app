import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents a single high score entry.
///
/// Stores the score value and the timestamp when it was achieved.
class HighScore {
  /// Creates a new high score entry.
  const HighScore({
    required this.score,
    required this.timestamp,
  });

  /// The numeric score value.
  final int score;

  /// When this score was achieved.
  final DateTime timestamp;

  /// Serializes this high score to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Deserializes a high score from a JSON map.
  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      score: json['score'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Serializes this high score to a JSON string.
  String toJsonString() {
    return jsonEncode(toJson());
  }

  /// Deserializes a high score from a JSON string.
  factory HighScore.fromJsonString(String jsonString) {
    final Map<String, dynamic> json =
        jsonDecode(jsonString) as Map<String, dynamic>;
    return HighScore.fromJson(json);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HighScore &&
        other.score == score &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(score, timestamp);

  @override
  String toString() {
    return 'HighScore(score: $score, timestamp: $timestamp)';
  }
}

/// Service for persisting game data using [SharedPreferences].
///
/// Handles storage and retrieval of high scores and application settings.
/// All data is stored as JSON-encoded strings in shared preferences.
class StorageService {
  /// SharedPreferences key for storing high scores.
  static const String HIGH_SCORES_KEY = 'high_scores';

  /// SharedPreferences key for storing theme mode preference.
  static const String THEME_MODE_KEY = 'theme_mode';

  /// The maximum number of high scores to retain.
  static const int MAX_HIGH_SCORES = 10;

  /// The underlying SharedPreferences instance.
  final SharedPreferences _prefs;

  /// Creates a storage service with the given [SharedPreferences] instance.
  StorageService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Creates and returns a new [StorageService] initialized with
  /// the default [SharedPreferences] instance.
  static Future<StorageService> create() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return StorageService(prefs: prefs);
  }

  /// Saves a new high score to persistent storage.
  ///
  /// The score is added to the existing list, sorted in descending order,
  /// and trimmed to [MAX_HIGH_SCORES] entries.
  ///
  /// Returns `true` if the score was saved successfully.
  Future<bool> saveHighScore(int score) async {
    try {
      final List<HighScore> scores = await getHighScores();
      scores.add(HighScore(score: score, timestamp: DateTime.now()));
      scores.sort((a, b) => b.score.compareTo(a.score));
      if (scores.length > MAX_HIGH_SCORES) {
        scores.removeRange(MAX_HIGH_SCORES, scores.length);
      }
      return await _saveHighScores(scores);
    } catch (e) {
      return false;
    }
  }

  /// Retrieves all stored high scores, sorted in descending order.
  ///
  /// Returns an empty list if no scores are stored or if an error occurs.
  Future<List<HighScore>> getHighScores() async {
    try {
      final List<String>? scoreStrings =
          _prefs.getStringList(HIGH_SCORES_KEY);
      if (scoreStrings == null || scoreStrings.isEmpty) {
        return [];
      }
      final List<HighScore> scores = [];
      for (final String scoreString in scoreStrings) {
        try {
          scores.add(HighScore.fromJsonString(scoreString));
        } catch (e) {
          // Skip invalid entries
        }
      }
      scores.sort((a, b) => b.score.compareTo(a.score));
      return scores;
    } catch (e) {
      return [];
    }
  }

  /// Persists the list of high scores to storage.
  ///
  /// Each [HighScore] is serialized to a JSON string and stored
  /// as a list of strings under [HIGH_SCORES_KEY].
  ///
  /// Returns `true` if the scores were saved successfully.
  Future<bool> _saveHighScores(List<HighScore> scores) async {
    try {
      final List<String> scoreStrings =
          scores.map((s) => s.toJsonString()).toList();
      return await _prefs.setStringList(HIGH_SCORES_KEY, scoreStrings);
    } catch (e) {
      return false;
    }
  }

  /// Clears all stored high scores.
  ///
  /// Returns `true` if the scores were cleared successfully.
  Future<bool> clearHighScores() async {
    try {
      return await _prefs.remove(HIGH_SCORES_KEY);
    } catch (e) {
      return false;
    }
  }

  /// Saves the theme mode preference to persistent storage.
  ///
  /// The [themeMode] is serialized to a string representation:
  /// - 'light' for light mode
  /// - 'dark' for dark mode
  /// - 'system' for system default
  ///
  /// Returns `true` if the theme mode was saved successfully.
  Future<bool> saveThemeMode(String themeMode) async {
    try {
      return await _prefs.setString(THEME_MODE_KEY, themeMode);
    } catch (e) {
      return false;
    }
  }

  /// Retrieves the stored theme mode preference.
  ///
  /// Returns the theme mode string if one is stored, otherwise returns
  /// `'system'` as the default value.
  ///
  /// Valid return values are: `'light'`, `'dark'`, or `'system'`.
  Future<String> getThemeMode() async {
    try {
      final String? themeMode = _prefs.getString(THEME_MODE_KEY);
      if (themeMode == null) {
        return 'system';
      }
      if (themeMode == 'light' || themeMode == 'dark' || themeMode == 'system') {
        return themeMode;
      }
      return 'system';
    } catch (e) {
      return 'system';
    }
  }

  /// Clears all stored preferences.
  ///
  /// This removes both high scores and theme mode settings.
  /// Returns `true` if all preferences were cleared successfully.
  Future<bool> clearAll() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      return false;
    }
  }
}
