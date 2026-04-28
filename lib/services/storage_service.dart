import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Model representing a high score entry.
///
/// Contains player name, score, and the date the score was achieved.
class HighScoreEntry {
  /// The player's name.
  final String playerName;

  /// The score achieved.
  final int score;

  /// The date and time when the score was achieved.
  final DateTime date;

  /// Creates a [HighScoreEntry] with the specified parameters.
  const HighScoreEntry({
    required this.playerName,
    required this.score,
    required this.date,
  });

  /// Creates a [HighScoreEntry] from a map.
  ///
  /// Used for deserialization from JSON storage.
  factory HighScoreEntry.fromMap(Map<String, dynamic> map) {
    return HighScoreEntry(
      playerName: map['playerName'] as String,
      score: map['score'] as int,
      date: DateTime.parse(map['date'] as String),
    );
  }

  /// Converts this [HighScoreEntry] to a map.
  ///
  /// Used for serialization to JSON storage.
  Map<String, dynamic> toMap() {
    return {
      'playerName': playerName,
      'score': score,
      'date': date.toIso8601String(),
    };
  }

  /// Creates a copy of this entry with updated fields.
  HighScoreEntry copyWith({String? playerName, int? score, DateTime? date}) {
    return HighScoreEntry(
      playerName: playerName ?? this.playerName,
      score: score ?? this.score,
      date: date ?? this.date,
    );
  }

  @override
  String toString() {
    return 'HighScoreEntry(playerName: $playerName, score: $score, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HighScoreEntry &&
        other.playerName == playerName &&
        other.score == score &&
        other.date == date;
  }

  @override
  int get hashCode => playerName.hashCode ^ score.hashCode ^ date.hashCode;
}

/// Service for persisting game data using SharedPreferences.
///
/// This service handles:
/// - Saving and retrieving high scores
/// - Storing theme preferences
/// - Managing local storage for the game
class StorageService {
  /// Storage key for high scores list.
  static const String _highScoresKey = 'high_scores_key';

  /// Storage key for dark mode theme preference.
  static const String _themeDarkModeKey = 'theme_dark_mode';

  /// Maximum number of high scores to store.
  static const int _maxHighScores = 10;

  /// Singleton instance of [StorageService].
  static StorageService? _instance;

  /// SharedPreferences instance.
  SharedPreferences? _prefs;

  /// Private constructor for singleton pattern.
  StorageService._internal();

  /// Creates a [StorageService] instance.
  ///
  /// For testing purposes, allows passing a mock SharedPreferences instance.
  StorageService({SharedPreferences? prefs}) : _prefs = prefs {
    if (prefs == null) {
      _init();
    }
  }

  /// Initializes the storage service.
  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Gets the singleton instance of [StorageService].
  ///
  /// Initializes SharedPreferences on first call.
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._internal();
      await _instance!._init();
    }
    return _instance!;
  }

  /// Gets the current SharedPreferences instance.
  ///
  /// Throws an error if [getInstance] has not been called first.
  SharedPreferences get _preferences {
    if (_prefs == null) {
      throw StateError(
        'StorageService not initialized. Call getInstance() first.',
      );
    }
    return _prefs!;
  }

  /// Saves a new high score entry.
  ///
  /// Adds the entry to the list, keeps only top 10 scores sorted by score.
  Future<void> saveHighScore(String playerName, int score) async {
    final highScores = await getHighScores();
    final newEntry = HighScoreEntry(
      playerName: playerName,
      score: score,
      date: DateTime.now(),
    );
    highScores.add(newEntry);

    // Sort by score descending and keep top 10
    highScores.sort((a, b) => b.score.compareTo(a.score));
    if (highScores.length > _maxHighScores) {
      highScores.removeRange(_maxHighScores, highScores.length);
    }

    await _saveHighScores(highScores);
  }

  /// Saves the list of high scores to storage.
  Future<void> _saveHighScores(List<HighScoreEntry> scores) async {
    final scoreList = scores.map((entry) => entry.toMap()).toList();
    final json = jsonEncode(scoreList);
    await _preferences.setString(_highScoresKey, json);
  }

  /// Retrieves all high scores from storage.
  ///
  /// Returns an empty list if no high scores exist.
  /// Returns up to 10 high scores sorted by score (highest first).
  Future<List<HighScoreEntry>> getHighScores() async {
    final json = _preferences.getString(_highScoresKey);
    if (json == null || json.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> scoreList = jsonDecode(json);
      return scoreList
          .map((item) => HighScoreEntry.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list if parsing fails
      return [];
    }
  }

  /// Clears all high scores from storage.
  Future<void> clearHighScores() async {
    await _preferences.remove(_highScoresKey);
  }

  /// Saves the theme preference (dark mode or not).
  ///
  /// [isDarkMode] set to true for dark mode, false for light mode.
  Future<void> saveThemePreference(bool isDarkMode) async {
    await _preferences.setBool(_themeDarkModeKey, isDarkMode);
  }

  /// Retrieves the theme preference.
  ///
  /// Returns false (light mode) if no preference is set.
  Future<bool> getThemePreference() async {
    return _preferences.getBool(_themeDarkModeKey) ?? false;
  }

  /// Clears all storage data.
  ///
  /// Useful for testing or resetting the game completely.
  Future<void> clearAll() async {
    await _preferences.clear();
  }
}
