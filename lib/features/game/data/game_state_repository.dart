import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_state.dart';

/// Repository for persisting game state using SharedPreferences.
///
/// This class handles saving and loading the complete game state
/// to and from persistent storage using JSON serialization.
class GameStateRepository {
  /// The SharedPreferences instance used for storage.
  final SharedPreferences _sharedPreferences;

  /// The key used to store the game state.
  static const String _gameStateKey = 'game_state';

  /// Creates a [GameStateRepository] with the given [sharedPreferences].
  const GameStateRepository(SharedPreferences sharedPreferences)
    : _sharedPreferences = sharedPreferences;

  /// Saves the given [state] to persistent storage.
  ///
  /// The [state] is serialized to JSON and stored under the key 'game_state'.
  /// Returns [true] if the save was successful, [false] otherwise.
  Future<bool> saveGameState(GameState state) async {
    try {
      final jsonString = jsonEncode(state.toJson());
      return await _sharedPreferences.setString(_gameStateKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Loads the saved game state from persistent storage.
  ///
  /// Returns a [GameState] if one was previously saved, or [null] if no
  /// saved game exists or if deserialization fails.
  Future<GameState?> loadGameState() async {
    try {
      final jsonString = _sharedPreferences.getString(_gameStateKey);
      if (jsonString == null) {
        return null;
      }
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return GameState.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  /// Clears the saved game state from persistent storage.
  ///
  /// Returns [true] if the clear was successful, [false] otherwise.
  Future<bool> clearGameState() async {
    return await _sharedPreferences.remove(_gameStateKey);
  }
}
