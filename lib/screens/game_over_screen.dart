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
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer,
                Theme.of(
                  context,
                ).colorScheme.primaryContainer.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
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
      ),
    );
  }

  /// Builds the Game Over title section with animated trophy.
  Widget _buildGameOverTitle(BuildContext context) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * value),
          child: Transform.rotate(angle: (1.0 - value) * 0.5, child: child),
        );
      },
      child: Center(
        child: Column(
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              builder: (context, double iconValue, child) {
                return Icon(
                  Icons.emoji_events,
                  size: 64 + (iconValue * 8),
                  color: iconValue > 0.7
                      ? (iconValue > 0.85
                            ? Colors.amber
                            : theme.colorScheme.primary)
                      : theme.colorScheme.primary.withValues(alpha: 0.3),
                );
              },
            ),
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
      ),
    );
  }

  /// Builds the final score card with gradient and animation.
  Widget _buildFinalScoreCard(BuildContext context, GameState gameState) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.9 + (0.1 * value),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Final Score',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.star,
                    color: theme.colorScheme.secondary,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: gameState.totalScore.toDouble()),
                duration: Duration(
                  milliseconds: 1000 + (gameState.totalScore * 5),
                ),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Text(
                    '${value.toInt()}',
                    style: theme.textTheme.displayLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the score breakdown section with improved styling.
  Widget _buildScoreBreakdown(BuildContext context, GameState gameState) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: theme.colorScheme.secondary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  'Score Breakdown',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upper Section
            _buildBreakdownRow(
              context,
              'Upper Section',
              gameState.upperSectionTotal,
              icon: Icons.diamond,
            ),

            // Bonus
            _buildBreakdownRow(
              context,
              'Bonus',
              gameState.bonusAwarded ? 35 : 0,
              isBonus: true,
              icon: Icons.emoji_events,
            ),

            // Lower Section
            _buildBreakdownRow(
              context,
              'Lower Section',
              gameState.totalScore -
                  gameState.upperSectionTotal -
                  (gameState.bonusAwarded ? 35 : 0),
              icon: Icons.emoji_events,
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Total
            _buildBreakdownRow(
              context,
              'Total Score',
              gameState.totalScore,
              isTotal: true,
              icon: Icons.star,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single breakdown row with improved styling.
  Widget _buildBreakdownRow(
    BuildContext context,
    String label,
    int score, {
    bool isBonus = false,
    bool isTotal = false,
    IconData? icon,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isTotal
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : isBonus
            ? theme.colorScheme.secondaryContainer.withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 18,
                  color: isTotal
                      ? theme.colorScheme.primary
                      : isBonus
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isTotal || isBonus
                      ? FontWeight.w600
                      : FontWeight.w500,
                  color: isTotal
                      ? theme.colorScheme.primary
                      : isBonus
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          Text(
            score.toString(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: isTotal || isBonus
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: isTotal
                  ? theme.colorScheme.primary
                  : isBonus
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.onSurface,
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
