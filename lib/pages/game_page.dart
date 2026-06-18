import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/providers/theme_provider.dart';
import 'package:poker_dice/widgets/dice_widget.dart';
import 'package:poker_dice/widgets/roll_button.dart';
import 'package:poker_dice/widgets/score_sheet.dart';

/// Complete game screen for the poker dice (Yatzy) game.
///
/// Layout:
/// - AppBar: back button, total score, theme toggle, menu button
/// - Score sheet with two-column layout (Minor/Upper, Major/Lower)
/// - Five dice displayed horizontally
/// - Roll button with remaining rolls badge
/// - Game completion overlay with total score and new game button
///
/// State is managed by [gameProvider] via Riverpod.
class GamePage extends ConsumerWidget {
  /// Called when the player taps the back button.
  final VoidCallback? onBackTap;

  /// Creates a [GamePage] with optional navigation callbacks.
  const GamePage({super.key, this.onBackTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final notifier = ref.read(gameProvider.notifier);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: onBackTap != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackTap,
                tooltip: 'Back',
              )
            : null,
        title: _buildAppBarTitle(context, gameState.totalScore),
        actions: [
          IconButton(
            icon: Icon(
              (Theme.of(context).brightness == Brightness.dark)
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: themeNotifier.toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => context.push('/scoreboard'),
            tooltip: 'Scoreboard',
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Score sheet
                Expanded(
                  flex: 3,
                  child: ScoreSheet(
                    dice: gameState.currentDice,
                    scoredCategories: gameState.scoredCategories.map(
                      (k, v) => MapEntry(k, v ?? 0),
                    ),
                    onCategorySelect: (ScoreCategory category) =>
                        notifier.selectCategory(category),
                    upperTotal: gameState.upperSectionTotal,
                    bonus: gameState.bonus,
                  ),
                ),
                const SizedBox(height: 16),
                // Dice area
                _buildDiceArea(context, gameState.currentDice, notifier),
                const SizedBox(height: 16),
                // Roll button
                _buildRollButton(context, gameState.rollsRemaining, notifier),
              ],
            ),
          ),
          // Game completion overlay
          if (gameState.status == GameStatus.completed)
            _buildCompletionOverlay(context, gameState, notifier),
        ],
      ),
    );
  }

  /// Builds the app bar title showing total score and player label.
  Widget _buildAppBarTitle(BuildContext context, int totalScore) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$totalScore',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'You',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  /// Builds the horizontal row of five dice.
  Widget _buildDiceArea(
    BuildContext context,
    List<Dice> dice,
    GameNotifier notifier,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        dice.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: DiceWidget(
            dice: dice[index],
            size: 56.0,
            onTap: () => notifier.toggleHold(index),
          ),
        ),
      ),
    );
  }

  /// Builds the roll button with remaining rolls badge.
  Widget _buildRollButton(
    BuildContext context,
    int rollsRemaining,
    GameNotifier notifier,
  ) {
    return SizedBox(
      width: double.infinity,
      child: RollButton(
        rollsRemaining: rollsRemaining,
        onPressed: notifier.rollDice,
      ),
    );
  }

  /// Builds the game completion overlay with total score and new game action.
  Widget _buildCompletionOverlay(
    BuildContext context,
    GameState gameState,
    GameNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface.withValues(alpha: 0.85),
      child: Center(
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 64,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Game Complete!',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Final Score',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '${gameState.totalScore}',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: notifier.resetGame,
                    icon: const Icon(Icons.refresh),
                    label: const Text('New Game'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
