import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/providers/theme_provider.dart';
import 'package:poker_dice/widgets/animated_dice.dart';
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
class GamePage extends StatefulWidget {
  /// Called when the player taps the back button.
  final VoidCallback? onBackTap;

  /// Creates a [GamePage] with optional navigation callbacks.
  const GamePage({super.key, this.onBackTap});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<GlobalKey<AnimatedDiceState>> _dieKeys = List.generate(
    5,
    (_) => GlobalKey<AnimatedDiceState>(),
  );

  /// Rolls dice and triggers tumble animation only on non-held dice.
  void _onRoll(GameNotifier notifier, List<Dice> dice) {
    notifier.rollDice();
    for (var i = 0; i < dice.length; i++) {
      if (!dice[i].isHeld) {
        _dieKeys[i].currentState?.animate();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _GamePageContent(
      onBackTap: widget.onBackTap,
      dieKeys: _dieKeys,
      onRoll: _onRoll,
    );
  }
}

/// Internal widget that accesses Riverpod providers and builds the UI.
class _GamePageContent extends ConsumerWidget {
  final VoidCallback? onBackTap;
  final List<GlobalKey<AnimatedDiceState>> dieKeys;
  final void Function(GameNotifier, List<Dice>) onRoll;

  const _GamePageContent({
    required this.onBackTap,
    required this.dieKeys,
    required this.onRoll,
  });

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
                    scoredCategories: Map<ScoreCategory, int>.fromEntries(
                      gameState.scoredCategories.entries
                          .where((e) => e.value != null)
                          .map((e) => MapEntry(e.key, e.value as int)),
                    ),
                    selectedCategory: gameState.selectedCategory,
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
                // Score confirmation button
                if (gameState.selectedCategory != null)
                  _buildScoreButton(context, notifier, gameState.currentDice),
                if (gameState.selectedCategory != null)
                  const SizedBox(height: 8),
                // Roll button
                _buildRollButton(context, gameState.rollsRemaining, gameState.currentDice, notifier),
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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$totalScore',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          'You',
          style: theme.textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  /// Builds the horizontal row of five dice on a darker background.
  Widget _buildDiceArea(
    BuildContext context,
    List<Dice> dice,
    GameNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          dice.length,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: AnimatedDice(
              key: dieKeys[index],
              dice: dice[index],
              size: 112.0,
              onTap: () => notifier.toggleHold(index),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the confirmation button to score the selected category.
  /// Disabled until at least one die has been rolled (value > 0).
  Widget _buildScoreButton(
    BuildContext context,
    GameNotifier notifier,
    List<Dice> dice,
  ) {
    final bool diceRolled = dice.any((die) => die.value > 0);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: diceRolled ? notifier.confirmScore : null,
        icon: const Icon(Icons.check),
        label: const Text('Score'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Builds the roll button with remaining rolls badge.
  Widget _buildRollButton(
    BuildContext context,
    int rollsRemaining,
    List<Dice> dice,
    GameNotifier notifier,
  ) {
    return SizedBox(
      width: double.infinity,
      child: RollButton(
        rollsRemaining: rollsRemaining,
        onPressed: () => onRoll(notifier, dice),
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
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/scoreboard'),
                    icon: const Icon(Icons.leaderboard),
                    label: const Text('View Scoreboard'),
                    style: OutlinedButton.styleFrom(
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
