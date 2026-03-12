import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../score/score_provider.dart';
import '../data/game_state_repository.dart';
import '../models/game_state.dart';

/// Provider for [GameStateRepository].
///
/// Creates and manages the game state repository instance
/// with SharedPreferences dependency for persistence.
final gameStateRepositoryProvider = Provider<GameStateRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return GameStateRepository(sharedPreferences);
});

/// Provider for [GameStatePersistenceNotifier].
///
/// Creates and manages the async notifier for persisted game state.
final gameStateProvider =
    AsyncNotifierProvider<GameStatePersistenceNotifier, GameState?>(
      () => GameStatePersistenceNotifier(),
    );

/// Async notifier for managing persisted game state.
///
/// Handles loading, saving, and clearing of the game state
/// using the [GameStateRepository]. Extends [AsyncNotifier]
/// for proper async state management following Riverpod conventions.
class GameStatePersistenceNotifier extends AsyncNotifier<GameState?> {
  /// Builds the initial state by loading the persisted game state.
  ///
  /// Returns the loaded [GameState] if one exists, or [null] if no
  /// saved game is found.
  @override
  Future<GameState?> build() async {
    return await ref.read(gameStateRepositoryProvider).loadGameState();
  }

  /// Saves the current [gameState] to persistent storage.
  ///
  /// Returns [true] if the save was successful, [false] otherwise.
  Future<bool> saveGameState(GameState gameState) async {
    state = const AsyncValue.loading();

    try {
      final success = await ref
          .read(gameStateRepositoryProvider)
          .saveGameState(gameState);
      if (success) {
        state = AsyncValue.data(gameState);
      }
      return success;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }

  /// Clears the saved game state from persistent storage.
  ///
  /// Updates the state to [null] after clearing.
  /// Returns [true] if the clear was successful, [false] otherwise.
  Future<bool> clearGameState() async {
    state = const AsyncValue.loading();

    try {
      final success = await ref
          .read(gameStateRepositoryProvider)
          .clearGameState();
      if (success) {
        state = AsyncValue.data(null);
      }
      return success;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return false;
    }
  }
}
