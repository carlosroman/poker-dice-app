import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'score_repository.dart';

/// Provider for [ScoreRepository] with [SharedPreferences] dependency.
///
/// Creates and manages the score repository instance for high score persistence.
final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return ScoreRepository(sharedPreferences);
});

/// Provider for [SharedPreferences] instance.
///
/// Provides the SharedPreferences instance for dependency injection.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferencesProvider must be overridden in your app initialization',
  );
});

/// Provider for [ScoreNotifier].
///
/// Creates and manages the score state notifier for high score management.
final scoreProvider = AsyncNotifierProvider<ScoreNotifier, int>(
  () => ScoreNotifier(),
);

/// High score notifier for managing score persistence and state.
///
/// Handles loading, saving, and clearing of high scores with async operations.
/// Extends [AsyncNotifier] for proper async state management following Riverpod conventions.
class ScoreNotifier extends AsyncNotifier<int> {
  /// Builds the initial state by loading the high score from the repository.
  ///
  /// Returns the loaded high score, or 0 if no score exists.
  @override
  Future<int> build() async {
    return await ref.read(scoreRepositoryProvider).loadHighScore();
  }

  /// Saves the given [score] as the new high score.
  ///
  /// Updates the state to reflect the saved score.
  /// Throws an exception if the save operation fails.
  Future<void> saveHighScore(int score) async {
    state = const AsyncValue.loading();

    try {
      await ref.read(scoreRepositoryProvider).saveHighScore(score);
      state = AsyncValue.data(score);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  /// Clears the saved high score from persistent storage.
  ///
  /// Updates the state to 0 after clearing.
  /// Throws an exception if the clear operation fails.
  Future<void> clearHighScore() async {
    state = const AsyncValue.loading();

    try {
      await ref.read(scoreRepositoryProvider).clearHighScore();
      state = AsyncValue.data(0);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
