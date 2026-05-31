import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/models/category.dart';
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

    final upperCategories = Category.getUpperCategories();
    final lowerCategories = Category.getLowerCategories();

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Game Complete!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Upper Section
                    Text(
                      'UPPER SECTION',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...upperCategories.map(
                      (cat) => _buildCategoryRow(
                        context,
                        cat.displayName,
                        gameState.scores[cat.name],
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Upper Total:',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          gameState.upperSectionTotal.toString(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    if (gameState.bonusAwarded > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Bonus:'),
                          Text(
                            '+${gameState.bonusAwarded}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 16),
                    // Lower Section
                    Text(
                      'LOWER SECTION',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ...lowerCategories.map(
                      (cat) => _buildCategoryRow(
                        context,
                        cat.displayName,
                        gameState.scores[cat.name],
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          gameState.totalScore.toString(),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
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
            const SizedBox(height: 24),
            Text(
              'Final Score',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              gameState.totalScore.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () => notifier.newGame(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('PLAY AGAIN'),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => _showHighScores(context),
                  icon: const Icon(Icons.leaderboard),
                  label: const Text('VIEW STATISTICS'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    String categoryName,
    int? score,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(categoryName),
          Text(score?.toString() ?? '-'),
        ],
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
