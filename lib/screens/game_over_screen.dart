import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/providers/settings_provider.dart';
import 'package:poker_dice/widgets/high_scores_dialog.dart';

/// Screen displayed when a game is completed.
///
/// Shows the final score and provides options to play again
/// or view high scores. Automatically saves the final score
/// to persistent storage.
class GameOverScreen extends ConsumerStatefulWidget {
  /// Creates a game over screen.
  const GameOverScreen({super.key});

  @override
  ConsumerState<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends ConsumerState<GameOverScreen> {
  /// Whether the score has been saved to persistent storage.
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  /// Saves the final score to persistent storage.
  Future<void> _saveScore() async {
    final int totalScore = ref.read(gameStateProvider).totalScore;
    try {
      await ref.read(settingsProvider.notifier).addHighScore(totalScore);
      if (mounted) {
        setState(() {
          _isSaved = true;
        });
      }
    } catch (e) {
      // Silently fail - score persistence is not critical
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.watch(gameNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: () => _showHighScores(context),
            tooltip: 'View High Scores',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Game Complete!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        'Final Score',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        gameState.totalScore.toString(),
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                      if (_isSaved) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Score saved!',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => notifier.newGame(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Play Again'),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => _showHighScores(context),
                    icon: const Icon(Icons.leaderboard),
                    label: const Text('High Scores'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows the high scores dialog.
  static void _showHighScores(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const HighScoresDialog(),
    );
  }
}
