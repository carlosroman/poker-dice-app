import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model representing a high score entry in the Poker Dice game.
///
/// Each [HighScore] contains:
/// - [score]: The total score achieved in a game
/// - [date]: When the score was achieved
///
/// This class provides JSON serialization for persistent storage.
///
/// Example:
/// ```dart
/// final score = HighScore(score: 500, date: DateTime.now());
/// final json = score.toJson();
/// final restored = HighScore.fromJson(json);
/// ```
class HighScore {
  /// The total score achieved in a game.
  final int score;

  /// The date and time when the score was achieved.
  final DateTime date;

  /// Creates a [HighScore] entry.
  ///
  /// Parameters:
  /// - [score]: The total game score (must not be null).
  /// - [date]: When the score was achieved (must not be null).
  ///
  /// Example:
  /// ```dart
  /// final score = HighScore(
  ///   score: 450,
  ///   date: DateTime(2024, 1, 15, 14, 30),
  /// );
  /// ```
  HighScore({required this.score, required this.date});

  /// Converts this [HighScore] to a JSON map.
  ///
  /// Returns:
  /// A map with 'score' (int) and 'date' (ISO 8601 string) keys.
  ///
  /// Example:
  /// ```dart
  /// final json = score.toJson();
  /// // {'score': 450, 'date': '2024-01-15T14:30:00.000'}
  /// ```
  Map<String, dynamic> toJson() {
    return {'score': score, 'date': date.toIso8601String()};
  }

  /// Creates a [HighScore] from a JSON map.
  ///
  /// Parameters:
  /// - [json]: A map containing 'score' and 'date' keys.
  ///
  /// Returns:
  /// A new [HighScore] instance with the parsed values.
  ///
  /// Throws:
  /// - [FormatException]: If the date string is invalid.
  /// - [TypeError]: If the score is not an integer.
  ///
  /// Example:
  /// ```dart
  /// final json = {'score': 450, 'date': '2024-01-15T14:30:00.000'};
  /// final score = HighScore.fromJson(json);
  /// ```
  factory HighScore.fromJson(Map<String, dynamic> json) {
    return HighScore(
      score: json['score'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

/// Repository for persistent storage of high scores.
///
/// The [HighScoreRepository] manages the storage and retrieval of
/// high scores using SharedPreferences. It maintains a singleton
/// instance and keeps the top 10 scores sorted by score value.
///
/// **Features:**
/// - Singleton pattern for consistent access
/// - Asynchronous initialization
/// - Automatic sorting by score (descending)
/// - Limited to top 10 scores
/// - JSON serialization for persistence
/// - Thread-safe operations
///
/// **Storage Format:**
/// Scores are stored as a JSON array of objects with 'score' and 'date' fields.
///
/// Example:
/// ```dart
/// final repo = HighScoreRepository.instance;
/// await repo.initialize();
/// await repo.saveScore(500, DateTime.now());
/// final scores = await repo.getHighScores();
/// ```
class HighScoreRepository {
  /// Singleton instance of [HighScoreRepository].
  static HighScoreRepository? _instance;

  /// SharedPreferences instance for storage.
  /// Nullable for testing purposes.
  SharedPreferences? _prefs;

  /// Whether the repository has been initialized.
  bool _initialized = false;

  /// Private constructor for singleton pattern.
  HighScoreRepository._privateConstructor();

  /// Singleton instance of [HighScoreRepository].
  ///
  /// Returns the shared instance, creating it if necessary.
  ///
  /// Example:
  /// ```dart
  /// final repo = HighScoreRepository.instance;
  /// ```
  static HighScoreRepository get instance {
    _instance ??= HighScoreRepository._privateConstructor();
    return _instance!;
  }

  /// Whether the repository is initialized.
  ///
  /// Returns true after [initialize] has been called successfully.
  bool get isInitialized => _initialized;

  /// SharedPreferences instance.
  ///
  /// Returns the underlying SharedPreferences for advanced operations.
  /// Nullable for testing purposes.
  SharedPreferences? get prefs => _prefs;

  /// Initializes SharedPreferences.
  ///
  /// This method must be called before any score operations.
  /// Safe to call multiple times (idempotent).
  ///
  /// Returns:
  /// A [Future] that completes when initialization is done.
  ///
  /// Example:
  /// ```dart
  /// final repo = HighScoreRepository.instance;
  /// await repo.initialize();
  /// ```
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Stores a new score.
  ///
  /// Adds the score to the list, keeps only the top 10 scores,
  /// and sorts them by score in descending order.
  ///
  /// Parameters:
  /// - [score]: The score to save.
  /// - [date]: When the score was achieved.
  ///
  /// Returns:
  /// A [Future] that completes when the score is saved.
  ///
  /// Example:
  /// ```dart
  /// await repo.saveScore(450, DateTime.now());
  /// ```
  Future<void> saveScore(int score, DateTime date) async {
    if (!_initialized) await initialize();
    final highScores = getHighScoresSync();
    highScores.add(HighScore(score: score, date: date));
    highScores.sort((a, b) => b.score.compareTo(a.score));
    if (highScores.length > 10) {
      highScores.removeRange(10, highScores.length);
    }
    await _saveHighScores(highScores);
  }

  /// Retrieves the top 10 high scores.
  ///
  /// Returns:
  /// A [Future] that completes with a list of [HighScore] entries,
  /// sorted by score in descending order.
  ///
  /// Example:
  /// ```dart
  /// final scores = await repo.getHighScores();
  /// for (final score in scores) {
  ///   print('${score.score} - ${score.date}');
  /// }
  /// ```
  Future<List<HighScore>> getHighScores() async {
    if (!_initialized) await initialize();
    return getHighScoresSync();
  }

  /// Resets the high score storage.
  ///
  /// Clears all stored high scores from SharedPreferences.
  ///
  /// Returns:
  /// A [Future] that completes when storage is cleared.
  ///
  /// Example:
  /// ```dart
  /// await repo.clearHighScores();
  /// ```
  Future<void> clearHighScores() async {
    if (_prefs != null) {
      await _prefs!.remove(_highScoresKey);
    }
  }

  /// Retrieves high scores synchronously.
  ///
  /// **Note:** This is for internal use. Callers should use [getHighScores]
  /// which ensures proper initialization.
  ///
  /// Returns:
  /// A list of [HighScore] entries sorted by score descending.
  /// Returns empty list if not initialized or no scores exist.
  List<HighScore> getHighScoresSync() {
    if (_prefs == null) return [];
    final scoresJson = _prefs!.getStringList(_highScoresKey) ?? [];
    return scoresJson.map((jsonString) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HighScore.fromJson(json);
    }).toList()..sort((a, b) => b.score.compareTo(a.score));
  }

  /// Saves high scores to persistent storage.
  ///
  /// Parameters:
  /// - [highScores]: The list of high scores to save.
  ///
  /// Returns:
  /// A [Future] that completes when scores are saved.
  Future<void> _saveHighScores(List<HighScore> highScores) async {
    if (_prefs == null) return;
    final scoresJson = highScores.map((score) {
      return jsonEncode(score.toJson());
    }).toList();
    await _prefs!.setStringList(_highScoresKey, scoresJson);
  }

  /// Storage key for high scores in SharedPreferences.
  static const String _highScoresKey = 'high_scores';

  /// Resets the singleton instance (for testing purposes).
  ///
  /// This method allows tests to get a fresh repository instance.
  /// Should not be called in production code.
  ///
  /// Example:
  /// ```dart
  /// // In test setup
  /// HighScoreRepository.resetInstance();
  /// ```
  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }
}
