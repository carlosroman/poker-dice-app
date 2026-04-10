import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poker_dice/src/bloc/game_bloc.dart';
import 'package:poker_dice/src/domain/game_state.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/animation/dice_animation.dart';
import 'package:poker_dice/src/ui/components/roll_button.dart';
import 'package:poker_dice/src/ui/components/score_sheet.dart' as ui;
import 'package:poker_dice/src/ui/theme/app_theme.dart';

/// The main game screen with GameBloc integration.
///
/// This is the stateful wrapper that manages the game lifecycle
/// and connects the UI to the GameBloc.
class GameScreen extends StatefulWidget {
  /// Callback for when the game is completed.
  final Function(int finalScore)? onGameComplete;

  /// Creates a [GameScreen].
  const GameScreen({super.key, this.onGameComplete});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameBloc _gameBloc;

  @override
  void initState() {
    super.initState();
    _gameBloc = GameBloc();
  }

  @override
  void dispose() {
    _gameBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<GameState>(
      valueListenable: _gameBloc,
      builder: (context, gameState, _) {
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
                    score: gameState.totalScore,
                    onBackTapped: () => Navigator.of(context).pop(),
                    onMenuTapped: () => _showMenu(context),
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
                        potentialScores: _buildPotentialScores(gameState),
                        currentScores: gameState.scoreSheet.scores,
                        scoredCategories: gameState.scoreSheet.scores.entries
                            .where((e) => e.value != null)
                            .map((e) => e.key)
                            .toSet(),
                        upperTotal: gameState.scoreSheet.getUpperTotal(),
                        onCategoryTapped: (category) =>
                            _gameBloc.selectCategory(category),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Dice Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: _DiceRow(
                      diceValues: gameState.diceValues,
                      rollCount: gameState.currentRound.rollCount,
                      heldIndices: gameState.currentRound.dice
                          .asMap()
                          .entries
                          .where((entry) => entry.value.held)
                          .map((entry) => entry.key)
                          .toList(),
                      onDieTapped: (index) => _gameBloc.toggleDie(index),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Button Row
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: _ButtonRow(
                      rollCount: gameState.currentRound.rollCount,
                      canRoll: gameState.canRoll,
                      hasUnscoredCategories: _gameBloc.hasUnscoredCategories,
                      onRollTapped: () => _gameBloc.rollDice(),
                      onPlayTapped: () => _handlePlayTapped(gameState),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('New Game'),
              onTap: () {
                Navigator.pop(context);
                _gameBloc.newGame();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Rules'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Map<ScoreCategory, int?> _buildPotentialScores(GameState gameState) {
    final potentialScores = <ScoreCategory, int?>{};
    for (final category in ScoreCategory.values) {
      if (!gameState.scoreSheet.isCategoryScored(category)) {
        potentialScores[category] = gameState.getPotentialScore(category);
      } else {
        potentialScores[category] = null;
      }
    }
    return potentialScores;
  }

  void _handlePlayTapped(GameState gameState) {
    // Find the currently selected category based on held dice
    // For now, we'll just select the first unscored category that matches the dice
    // This should be improved to track user selection properly
    final heldDice = gameState.currentRound.dice
        .where((die) => die.held)
        .toList();
    if (heldDice.isEmpty) {
      // No dice held, just roll again
      return;
    }

    // For simplicity, auto-select a matching category
    // In a real implementation, you'd track the user's category selection
    final unscoredCategories = gameState.getValidCategories();
    if (unscoredCategories.isNotEmpty) {
      _gameBloc.commitCategory(unscoredCategories.first);
    }
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
          IconButton(
            onPressed: onBackTapped,
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.textOnPrimary,
          ),
          const SizedBox(width: AppSpacing.sm),
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

class _DiceRow extends StatefulWidget {
  final List<int> diceValues;
  final int rollCount;
  final List<int> heldIndices;
  final Function(int) onDieTapped;

  const _DiceRow({
    required this.diceValues,
    required this.rollCount,
    required this.heldIndices,
    required this.onDieTapped,
  });

  @override
  State<_DiceRow> createState() => _DiceRowState();
}

class _DiceRowState extends State<_DiceRow> {
  int _lastRollCount = 0;

  @override
  void didUpdateWidget(_DiceRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animation when dice values change (indicating a roll)
    if (!listEquals(widget.diceValues, oldWidget.diceValues)) {
      setState(() {
        _lastRollCount++;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.diceValues.asMap().entries.map((entry) {
        final index = entry.key;
        final value = entry.value;
        final isHeld = widget.heldIndices.contains(index);
        final isBlank = value == 0 && widget.rollCount == 0;
        return AnimatedDieWidget(
          key: ValueKey('die-$index'),
          value: value,
          isHeld: isHeld,
          isBlank: isBlank,
          onTap: widget.rollCount > 0 ? () => widget.onDieTapped(index) : null,
          triggerAnimation: _lastRollCount > 0,
        );
      }).toList(),
    );
  }
}

/// Widget displaying the Roll and Play buttons.
class _ButtonRow extends StatelessWidget {
  final int rollCount;
  final bool canRoll;
  final bool hasUnscoredCategories;
  final VoidCallback? onRollTapped;
  final VoidCallback? onPlayTapped;

  const _ButtonRow({
    required this.rollCount,
    required this.canRoll,
    required this.hasUnscoredCategories,
    this.onRollTapped,
    this.onPlayTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: RollButton(
            rollCount: rollCount,
            onTap: canRoll ? onRollTapped : null,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: ElevatedButton(
            onPressed: hasUnscoredCategories ? onPlayTapped : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'PLAY',
              style: TextStyle(
                fontSize: AppTypography.large,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
