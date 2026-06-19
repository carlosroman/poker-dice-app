/// Service for persisting game results using shared_preferences.
///
/// Provides methods to save, load, and clear game history.
/// Each game result is stored as a JSON-encoded entry in a list.
library;

import 'dart:convert';

import 'package:poker_dice/models/game_history.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to store the game history list in shared_preferences.
const String _gameHistoryKey = 'game_history';

/// Interface for game result persistence.
abstract class StorageServiceInterface {
  /// Saves a [GameResult] to the persistent history.
  Future<void> saveGameResult(GameResult result);

  /// Loads all saved game results from persistent storage.
  Future<List<GameResult>> loadGameResults();

  /// Clears all saved game results from persistent storage.
  Future<void> clearHistory();

  /// Returns the highest total score from the game history.
  Future<int?> getHighScore();

  /// Returns the number of games played.
  Future<int> getGamesPlayed();
}

/// Service responsible for persisting and loading game results.
///
/// Uses [SharedPreferences] to store a list of [GameResult] objects
/// as JSON-encoded strings.
class StorageService implements StorageServiceInterface {
  final SharedPreferences _prefs;

  /// Creates a [StorageService] with the given [SharedPreferences] instance.
  StorageService({required SharedPreferences prefs}) : _prefs = prefs;

  /// Saves a [GameResult] to the persistent history.
  ///
  /// Appends the result to the existing list and stores it.
  @override
  Future<void> saveGameResult(GameResult result) async {
    final history = await loadGameResults();
    history.add(result);
    final encoded = history.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_gameHistoryKey, encoded);
  }

  /// Loads all saved game results from persistent storage.
  ///
  /// Returns an empty list if no results have been saved.
  @override
  Future<List<GameResult>> loadGameResults() async {
    final encoded = _prefs.getStringList(_gameHistoryKey);
    if (encoded == null || encoded.isEmpty) {
      return [];
    }

    final results = <GameResult>[];
    for (final entry in encoded) {
      try {
        final json = jsonDecode(entry) as Map<String, dynamic>;
        results.add(GameResult.fromJson(json));
      } catch (_) {
        // Skip corrupted entries
      }
    }
    return results;
  }

  /// Clears all saved game results from persistent storage.
  @override
  Future<void> clearHistory() async {
    await _prefs.remove(_gameHistoryKey);
  }

  /// Returns the highest total score from the game history.
  ///
  /// Returns `null` if no games have been played.
  @override
  Future<int?> getHighScore() async {
    final results = await loadGameResults();
    if (results.isEmpty) return null;
    return results.map((r) => r.totalScore).reduce((a, b) => a > b ? a : b);
  }

  /// Returns the number of games played.
  @override
  Future<int> getGamesPlayed() async {
    final results = await loadGameResults();
    return results.length;
  }
}
