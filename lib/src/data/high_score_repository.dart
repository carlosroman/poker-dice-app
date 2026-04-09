import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;

/// Represents a high score entry with score and timestamp.
///
/// Used for storing and retrieving high scores from persistent storage.
class HighScoreEntry {
  /// The player's score.
  final int score;

  /// The timestamp when the score was achieved.
  final DateTime date;

  /// Creates a [HighScoreEntry].
  const HighScoreEntry({required this.score, required this.date});

  /// Creates a [HighScoreEntry] from JSON.
  ///
  /// [json] is a map with 'score' and 'date' keys.
  factory HighScoreEntry.fromJson(Map<String, dynamic> json) {
    return HighScoreEntry(
      score: json['score'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }

  /// Converts this entry to JSON.
  Map<String, dynamic> toJson() {
    return {'score': score, 'date': date.toIso8601String()};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! HighScoreEntry) return false;
    return score == other.score && date == other.date;
  }

  @override
  int get hashCode => Object.hash(score, date);

  @override
  String toString() => 'HighScoreEntry(score: $score, date: $date)';
}

/// Repository for managing high scores persistence.
///
/// Uses SharedPreferences to store and retrieve high scores.
/// Stores top 10 scores sorted by score (descending).
class HighScoreRepository {
  /// Key for storing high scores in SharedPreferences.
  static const String _highScoresKey = 'high_scores';

  /// Maximum number of high scores to store.
  static const int maxScores = 10;

  /// Saves a score to the high scores list.
  ///
  /// [score] is the score to save.
  /// Returns true if the score was added to the high scores list.
  Future<bool> saveScore(int score) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scores = await getHighScores();

      // Add new score
      final newEntry = HighScoreEntry(score: score, date: DateTime.now());
      scores.add(newEntry);

      // Sort by score descending
      scores.sort((a, b) => b.score.compareTo(a.score));

      // Keep only top 10
      if (scores.length > maxScores) {
        scores.removeRange(maxScores, scores.length);
      }

      // Save to storage
      final jsonList = scores.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      return await prefs.setString(_highScoresKey, jsonString);
    } catch (e) {
      // Log error but don't crash
      developer.log('Error saving score: $e', name: 'HighScoreRepository');
      return false;
    }
  }

  /// Retrieves the list of high scores.
  ///
  /// Returns a list of [HighScoreEntry] sorted by score (descending).
  /// Returns empty list if no scores exist.
  Future<List<HighScoreEntry>> getHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_highScoresKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .map((item) => HighScoreEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      developer.log(
        'Error getting high scores: $e',
        name: 'HighScoreRepository',
      );
      // Return empty list on error
      return [];
    }
  }

  /// Clears all high scores.
  ///
  /// Returns true if successful.
  Future<bool> clearHighScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_highScoresKey);
    } catch (e) {
      developer.log(
        'Error clearing high scores: $e',
        name: 'HighScoreRepository',
      );
      return false;
    }
  }

  /// Checks if a score qualifies for the high scores list.
  ///
  /// [score] is the score to check.
  /// Returns true if the score would be added to the high scores.
  Future<bool> scoreQualifies(int score) async {
    final scores = await getHighScores();

    // If less than 10 scores, any score qualifies
    if (scores.length < maxScores) {
      return true;
    }

    // Check if score is higher than the lowest
    final lowestScore = scores.last.score;
    return score > lowestScore;
  }
}
