/// Service for persisting game results using shared_preferences.
///
/// Provides methods to save, load, and clear game history.
/// Each game result is stored as a JSON-encoded entry in a list.
library;

import 'dart:convert';

import 'package:poker_dice/models/game_history.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Key used to store the game history list in shared_preferences.
const String _gameHistoryKey = 'game_history';

/// Key used to store the in-progress game state in shared_preferences.
const String _inProgressGameKey = 'in_progress_game';

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

  /// Returns whether there is an in-progress game saved.
  bool hasInProgressGame();

  /// Saves an in-progress [GameState] to persistent storage.
  Future<void> saveInProgressGame(GameState state);

  /// Loads the in-progress [GameState] from persistent storage.
  ///
  /// Returns `null` if no in-progress game is saved.
  Future<GameState?> loadInProgressGame();

  /// Clears the saved in-progress game from persistent storage.
  Future<void> clearInProgressGame();
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

  /// Returns the highest winner score from the game history.
  ///
  /// For single-player games this is the total score.
  /// For 2-player games this is the highest individual player score.
  /// Returns `null` if no games have been played.
  @override
  Future<int?> getHighScore() async {
    final results = await loadGameResults();
    if (results.isEmpty) return null;
    return results.map((r) => r.winnerScore).reduce((a, b) => a > b ? a : b);
  }

  /// Returns the number of games played.
  @override
  Future<int> getGamesPlayed() async {
    final results = await loadGameResults();
    return results.length;
  }

  /// Returns whether there is an in-progress game saved.
  @override
  bool hasInProgressGame() {
    return _prefs.containsKey(_inProgressGameKey);
  }

  /// Saves an in-progress [GameState] to persistent storage.
  @override
  Future<void> saveInProgressGame(GameState state) async {
    await _prefs.setString(_inProgressGameKey, jsonEncode(state.toJson()));
  }

  /// Loads the in-progress [GameState] from persistent storage.
  ///
  /// Returns `null` if no in-progress game is saved.
  @override
  Future<GameState?> loadInProgressGame() async {
    final encoded = _prefs.getString(_inProgressGameKey);
    if (encoded == null) return null;
    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      return GameState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Clears the saved in-progress game from persistent storage.
  @override
  Future<void> clearInProgressGame() async {
    await _prefs.remove(_inProgressGameKey);
  }
}
