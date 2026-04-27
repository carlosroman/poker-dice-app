import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/high_scores_dialog.dart';

/// A screen displayed when the game is over.
///
/// Shows the final score breakdown, high scores (if available),
/// and provides options to play again or return to home.
class GameOverScreen extends ConsumerWidget {
  /// Creates a [GameOverScreen] widget.
  const GameOverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Over'),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Game Over Title
              _buildGameOverTitle(context),

              const SizedBox(height: 32),

              // Final Score Card
              _buildFinalScoreCard(context, gameState),

              const SizedBox(height: 24),

              // Score Breakdown
              _buildScoreBreakdown(context, gameState),

              const SizedBox(height: 32),

              // High Scores Section
              _buildHighScoresSection(context, ref),

              const SizedBox(height: 32),

              // Action Buttons
              _buildActionButtons(context, gameNotifier),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the Game Over title section.
  Widget _buildGameOverTitle(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'Game Over!',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the final score card.
  Widget _buildFinalScoreCard(BuildContext context, GameState gameState) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Final Score',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              gameState.totalScore.toString(),
              style: theme.textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the score breakdown section.
  Widget _buildScoreBreakdown(BuildContext context, GameState gameState) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Breakdown',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),

            // Upper Section
            _buildBreakdownRow(
              context,
              'Upper Section',
              gameState.upperSectionTotal,
            ),

            // Bonus
            _buildBreakdownRow(
              context,
              'Bonus',
              gameState.bonusAwarded ? 35 : 0,
              isBonus: true,
            ),

            // Lower Section
            _buildBreakdownRow(
              context,
              'Lower Section',
              gameState.totalScore -
                  gameState.upperSectionTotal -
                  (gameState.bonusAwarded ? 35 : 0),
            ),

            const Divider(height: 24),

            // Total
            _buildBreakdownRow(
              context,
              'Total',
              gameState.totalScore,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single breakdown row.
  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    int score, {
    bool isBonus = false,
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal || isBonus
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isBonus
                  ? theme.colorScheme.secondary
                  : isTotal
                  ? theme.colorScheme.primary
                  : null,
            ),
          ),
          Text(
            score.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal || isBonus
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: isBonus
                  ? theme.colorScheme.secondary
                  : isTotal
                  ? theme.colorScheme.primary
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the high scores section.
  Widget _buildHighScoresSection(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settingsState = ref.watch(settingsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'High Scores',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => showHighScoresDialog(context),
                  icon: const Icon(Icons.emoji_events, size: 18),
                  label: const Text('View All'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (settingsState.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (settingsState.highScores.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'No high scores yet!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: settingsState.highScores
                      .take(3)
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                        final index = entry.key;
                        final score = entry.value;
                        return Column(
                          children: [
                            _buildHighScoreRow(
                              context,
                              index + 1,
                              score.playerName,
                              score.score,
                            ),
                            if (index <
                                settingsState.highScores
                                        .take(3)
                                        .toList()
                                        .length -
                                    1)
                              const SizedBox(height: 8),
                          ],
                        );
                      })
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds a single high score row.
  Widget _buildHighScoreRow(
    BuildContext context,
    int rank,
    String playerName,
    int score,
  ) {
    final theme = Theme.of(context);

    return Row(
      children: [
        // Rank
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: rank == 1
                ? Colors.amber
                : rank == 2
                ? Colors.grey
                : rank == 3
                ? Colors.orange
                : theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: rank <= 3 ? Colors.white : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Player Name
        Expanded(child: Text(playerName, style: theme.textTheme.bodyMedium)),

        // Score
        Text(
          score.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Builds the action buttons.
  Widget _buildActionButtons(BuildContext context, GameNotifier gameNotifier) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Play Again Button
        ElevatedButton.icon(
          onPressed: () {
            gameNotifier.startNewGame();
            gameNotifier.startTurn();
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Play Again'),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Back to Home Button
        OutlinedButton.icon(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.home),
          label: const Text('Back to Home'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
