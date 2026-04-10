import 'package:flutter/material.dart';
import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/game_round.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart' as domain;
import 'package:poker_dice/src/ui/components/die_widget.dart';
import 'package:poker_dice/src/ui/components/play_button.dart';
import 'package:poker_dice/src/ui/components/roll_button.dart';
import 'package:poker_dice/src/ui/components/score_sheet.dart' as ui;
import 'package:poker_dice/src/ui/theme/app_theme.dart';

// The main game page displaying the Yatzy game interface.
///
/// Shows the score sheet, dice, and control buttons.
class GamePage extends StatelessWidget {
  /// The current game round with dice and roll count.
  final GameRound gameRound;

  /// The current score sheet.
  final domain.ScoreSheet scoreSheet;

  /// The current minor section total.
  final int minorTotal;

  /// Callback when a category is tapped for scoring.
  final Function(ScoreCategory)? onCategoryTapped;

  /// Callback when the roll button is tapped.
  final VoidCallback? onRollTapped;

  /// Callback when the play button is tapped.
  final VoidCallback? onPlayTapped;

  /// Callback for back navigation.
  final VoidCallback? onBackTapped;

  /// Callback for menu action.
  final VoidCallback? onMenuTapped;

  /// Creates a [GamePage].
  const GamePage({
    super.key,
    required this.gameRound,
    required this.scoreSheet,
    required this.minorTotal,
    this.onCategoryTapped,
    this.onRollTapped,
    this.onPlayTapped,
    this.onBackTapped,
    this.onMenuTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundGradientStart,
              AppTheme.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _GameHeader(
                score: scoreSheet.getTotal(),
                onBackTapped: onBackTapped,
                onMenuTapped: onMenuTapped,
              ),
              const SizedBox(height: AppSpacing.md),

              // Score Sheet
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: ui.ScoreSheetWidget(
                    potentialScores: _getPotentialScores(),
                    currentScores: scoreSheet.scores,
                    scoredCategories: scoreSheet.scores.keys
                        .where((k) => scoreSheet.scores[k] != null)
                        .toSet(),
                    minorTotal: minorTotal,
                    onCategoryTapped: onCategoryTapped,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Dice Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _DiceRow(
                  dice: gameRound.dice,
                  rollCount: gameRound.rollCount,
                  onDieTapped: (index) => gameRound.toggleDie(index),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Button Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: _ButtonRow(
                  rollCount: gameRound.rollCount,
                  canRoll: gameRound.canRoll(),
                  canPlay: scoreSheet.getEmptyCategories().isNotEmpty,
                  onRollTapped: onRollTapped,
                  onPlayTapped: onPlayTapped,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Map<ScoreCategory, int?> _getPotentialScores() {
    // This would be calculated based on current dice
    // For now, return empty map - actual implementation would use Scorer
    return {};
  }
}

/// Header widget showing score and navigation buttons.
class _GameHeader extends StatelessWidget {
  final int score;
  final VoidCallback? onBackTapped;
  final VoidCallback? onMenuTapped;

  const _GameHeader({
    required this.score,
    this.onBackTapped,
    this.onMenuTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: onBackTapped,
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.textOnPrimary,
          ),
          const SizedBox(width: AppSpacing.sm),

          // Score
          Expanded(
            child: Text(
              '$score',
              style: const TextStyle(
                color: AppTheme.textOnPrimary,
                fontSize: AppTypography.display,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Menu button
          IconButton(
            onPressed: onMenuTapped,
            icon: const Icon(Icons.more_vert),
            color: AppTheme.textOnPrimary,
          ),
        ],
      ),
    );
  }
}

/// Widget displaying the 5 dice in a row.
class _DiceRow extends StatelessWidget {
  final List<Die> dice;
  final int rollCount;
  final Function(int) onDieTapped;

  const _DiceRow({
    required this.dice,
    required this.rollCount,
    required this.onDieTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: dice.asMap().entries.map((entry) {
        final index = entry.key;
        final die = entry.value;
        final isBlank = die.value == 0 && rollCount == 0;
        return DieWidget(
          key: ValueKey('die-$index'),
          value: die.value,
          isHeld: die.held,
          isBlank: isBlank,
          onTap: rollCount > 0 ? () => onDieTapped(index) : null,
        );
      }).toList(),
    );
  }
}

/// Widget displaying the Roll and Play buttons.
class _ButtonRow extends StatelessWidget {
  final int rollCount;
  final bool canRoll;
  final bool canPlay;
  final VoidCallback? onRollTapped;
  final VoidCallback? onPlayTapped;

  const _ButtonRow({
    required this.rollCount,
    required this.canRoll,
    required this.canPlay,
    this.onRollTapped,
    this.onPlayTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Roll button
        Expanded(
          child: RollButton(
            rollCount: rollCount,
            onTap: canRoll ? onRollTapped : null,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Play button
        Expanded(
          child: PlayButton(
            isEnabled: canPlay,
            onTap: canPlay ? onPlayTapped : null,
          ),
        ),
      ],
    );
  }
}
