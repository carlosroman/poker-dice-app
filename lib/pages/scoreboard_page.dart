/// Scoreboard page displaying game history and statistics.
///
/// Shows a list of completed game results, high score, and games played count.
/// Provides a clear history action and navigation back to the game.
library;

import 'package:flutter/material.dart';
import 'package:poker_dice/models/game_history.dart';

/// Displays the game history and statistics.
///
/// Receives a list of [GameResult] objects and displays them in a
/// scrollable list with summary statistics at the top.
class ScoreboardPage extends StatelessWidget {
  /// The list of completed game results to display.
  final List<GameResult> gameResults;

  /// The total number of games played.
  final int gamesPlayed;

  /// The highest score achieved.
  final int? highScore;

  /// Callback invoked when the user requests to clear history.
  final VoidCallback? onClearHistory;

  /// Callback invoked when the user navigates back.
  final VoidCallback? onBackTap;

  /// Creates a [ScoreboardPage] with the given data.
  const ScoreboardPage({
    super.key,
    required this.gameResults,
    this.gamesPlayed = 0,
    this.highScore,
    this.onClearHistory,
    this.onBackTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scoreboard'),
        leading: onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackTap,
                tooltip: 'Back',
              )
            : null,
        actions: onClearHistory != null && gameResults.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: onClearHistory,
                  tooltip: 'Clear History',
                ),
              ]
            : null,
      ),
      body: gameResults.isEmpty
          ? const Center(child: Text('No games played yet'))
          : _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      children: [
        _buildStats(context),
        const Divider(height: 1),
        Expanded(child: _buildGameList(context)),
      ],
    );
  }

  Widget _buildStats(BuildContext context) {
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
                      gamesPlayed.toString(),
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
                      highScore?.toString() ?? '-',
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

  Widget _buildGameList(BuildContext context) {
    return ListView.builder(
      itemCount: gameResults.length,
      itemBuilder: (context, index) {
        final result = gameResults[gameResults.length - 1 - index];
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
      leading: CircleAvatar(child: Text('#${result.totalScore > 0 ? '' : ''}')),
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
