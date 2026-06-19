/// Scoreboard page displaying game history and statistics.
///
/// Shows a list of completed game results, high score, and games played count.
/// Provides a clear history action and navigation back to the game.
///
/// State is managed by [scoreboardProvider] via Riverpod. When data is passed
/// directly through the constructor, it takes precedence over the provider.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_dice/models/game_history.dart';
import 'package:poker_dice/providers/storage_provider.dart';

/// Displays the game history and statistics.
///
/// Receives a list of [GameResult] objects and displays them in a
/// scrollable list with summary statistics at the top.
class ScoreboardPage extends ConsumerWidget {
  /// The list of completed game results to display.
  ///
  /// If provided, takes precedence over the provider state.
  final List<GameResult>? gameResults;

  /// The total number of games played.
  final int? gamesPlayed;

  /// The highest score achieved.
  final int? highScore;

  /// Callback invoked when the user requests to clear history.
  final VoidCallback? onClearHistory;

  /// Callback invoked when the user navigates back.
  final VoidCallback? onBackTap;

  /// Creates a [ScoreboardPage] with optional data.
  ///
  /// When no data is provided, the page loads from [scoreboardProvider].
  const ScoreboardPage({
    super.key,
    this.gameResults,
    this.gamesPlayed,
    this.highScore,
    this.onClearHistory,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerState = ref.watch(scoreboardProvider);

    // Load data from storage if not already loaded (deferred to avoid
    // modifying provider state during build)
    if (providerState.gameResults.isEmpty && gameResults == null) {
      Future.microtask(
        () => ref.read(scoreboardProvider.notifier).loadData(),
      );
    }

    // Use constructor data if provided, otherwise use provider state
    final results = gameResults ?? providerState.gameResults;
    final played = gamesPlayed ?? providerState.gamesPlayed;
    final score = highScore ?? providerState.highScore;
    final isLoading = providerState.isLoading && gameResults == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBackTap ?? () => context.pop(),
          tooltip: 'Back',
        ),
        actions: (onClearHistory != null || results.isNotEmpty)
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: results.isNotEmpty
                      ? () {
                          onClearHistory?.call();
                          if (onClearHistory == null) {
                            ref
                                .read(scoreboardProvider.notifier)
                                .clearHistory();
                          }
                        }
                      : null,
                  tooltip: 'Clear History',
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? const Center(child: Text('No games played yet'))
              : _buildContent(context, results, played, score),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<GameResult> results,
    int played,
    int? score,
  ) {
    return Column(
      children: [
        _buildStats(context, played, score),
        const Divider(height: 1),
        Expanded(child: _buildGameList(context, results)),
      ],
    );
  }

  Widget _buildStats(BuildContext context, int played, int? score) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      played.toString(),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text('Games Played'),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      score?.toString() ?? '-',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const Text('High Score'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameList(BuildContext context, List<GameResult> results) {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[results.length - 1 - index];
        return _GameResultTile(result: result);
      },
    );
  }
}

/// Displays a single game result in a list tile.
class _GameResultTile extends StatelessWidget {
  final GameResult result;

  const _GameResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text('${result.totalScore}'),
      ),
      title: Text('Score: ${result.totalScore}'),
      subtitle: Text(
        'Upper: ${result.upperSectionTotal} | Bonus: ${result.bonus}',
      ),
      trailing: Text(
        '${result.completedAt.day}/${result.completedAt.month}/${result.completedAt.year}',
      ),
    );
  }
}
