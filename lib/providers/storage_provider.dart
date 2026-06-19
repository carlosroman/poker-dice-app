/// Riverpod providers for the [StorageService] and scoreboard state.
///
/// Exposes a [StorageService] instance for persistence and a
/// [ScoreboardNotifier] that loads and manages scoreboard data.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/models/game_history.dart';
import 'package:poker_dice/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider that exposes the [StorageService].
///
/// Initializes [SharedPreferences] asynchronously and creates
/// a [StorageService] instance.
final storageServiceProvider = FutureProvider<StorageServiceInterface>((
  ref,
) async {
  final prefs = await SharedPreferences.getInstance();
  return StorageService(prefs: prefs);
});

/// Holds the current scoreboard data loaded from storage.
class ScoreboardState {
  /// The list of completed game results.
  final List<GameResult> gameResults;

  /// The total number of games played.
  final int gamesPlayed;

  /// The highest score achieved across all games.
  final int? highScore;

  /// Whether data is currently being loaded.
  final bool isLoading;

  /// Creates a [ScoreboardState] with the given values.
  const ScoreboardState({
    this.gameResults = const [],
    this.gamesPlayed = 0,
    this.highScore,
    this.isLoading = false,
  });

  /// Creates a copy of this state with the given fields replaced.
  ScoreboardState copyWith({
    List<GameResult>? gameResults,
    int? gamesPlayed,
    int? highScore,
    bool? isLoading,
  }) {
    return ScoreboardState(
      gameResults: gameResults ?? this.gameResults,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      highScore: highScore ?? this.highScore,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier that loads and manages scoreboard data from [StorageService].
class ScoreboardNotifier extends StateNotifier<ScoreboardState> {
  final Ref ref;

  /// Creates a [ScoreboardNotifier] with the given [ref].
  ScoreboardNotifier({required this.ref}) : super(const ScoreboardState());

  /// Loads game results, high score, and games played from storage.
  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      final storageService = await ref.read(storageServiceProvider.future);
      final results = await storageService.loadGameResults();
      final highScore = await storageService.getHighScore();
      final gamesPlayed = await storageService.getGamesPlayed();

      state = state.copyWith(
        gameResults: results,
        gamesPlayed: gamesPlayed,
        highScore: highScore,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Clears all game history from storage and resets the state.
  Future<void> clearHistory() async {
    try {
      final storageService = await ref.read(storageServiceProvider.future);
      await storageService.clearHistory();
      state = const ScoreboardState();
    } catch (_) {
      // Ignore clear failures.
    }
  }

  /// Saves a [GameResult] to storage and reloads the scoreboard data.
  Future<void> addResult(GameResult result) async {
    try {
      final storageService = await ref.read(storageServiceProvider.future);
      await storageService.saveGameResult(result);
      await loadData();
    } catch (_) {
      // Ignore save failures.
    }
  }
}

/// Provider that exposes the [ScoreboardNotifier].
final scoreboardProvider =
    StateNotifierProvider<ScoreboardNotifier, ScoreboardState>(
      (ref) => ScoreboardNotifier(ref: ref),
    );
