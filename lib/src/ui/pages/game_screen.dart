import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:poker_dice/src/bloc/game_bloc.dart';
import 'package:poker_dice/src/domain/game_state.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/animation/dice_animation.dart';
import 'package:poker_dice/src/ui/animation/selection_animation.dart';
import 'package:poker_dice/src/ui/components/roll_button.dart';
import 'package:poker_dice/src/ui/components/score_row.dart';
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
                      child: _ScoreSheet(
                        gameState: gameState,
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
                      onRollTapped: () => _gameBloc.rollDice(),
                      onNewGameTapped: () => _gameBloc.newGame(),
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

/// Score sheet widget displaying all scoring categories.
class _ScoreSheet extends StatefulWidget {
  final GameState gameState;
  final Function(ScoreCategory) onCategoryTapped;

  const _ScoreSheet({required this.gameState, required this.onCategoryTapped});

  @override
  State<_ScoreSheet> createState() => _ScoreSheetState();
}

class _ScoreSheetState extends State<_ScoreSheet> {
  ScoreCategory? _lastSelectedCategory;

  @override
  void didUpdateWidget(_ScoreSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Track when a new category is selected
    final currentSelected =
        widget.gameState.currentRound.dice
            .asMap()
            .entries
            .where((entry) => entry.value.held)
            .isNotEmpty
        ? _findSelectedCategory(oldWidget.gameState)
        : null;
    if (currentSelected != _lastSelectedCategory) {
      setState(() {
        _lastSelectedCategory = currentSelected;
      });
    }
  }

  ScoreCategory? _findSelectedCategory(GameState state) {
    // Find a category that might be selected based on game state changes
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Upper Section
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ..._buildCategoryRows(
                ScoreCategory.values.where((c) => c.isUpper).toList(),
                widget.gameState,
                widget.onCategoryTapped,
              ),
              const SizedBox(height: AppSpacing.sm),
              _UpperTotalRow(
                upperTotal: widget.gameState.scoreSheet.getUpperTotal(),
                hasBonus: widget.gameState.scoreSheet.getBonus() > 0,
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),

        const Divider(height: 1, thickness: 2),

        // Lower Section
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              ..._buildCategoryRows(
                ScoreCategory.values.where((c) => c.isLower).toList(),
                widget.gameState,
                widget.onCategoryTapped,
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategoryRows(
    List<ScoreCategory> categories,
    GameState gameState,
    Function(ScoreCategory) onCategoryTapped,
  ) {
    return categories.map((category) {
      final isScored = gameState.scoreSheet.isCategoryScored(category);
      final currentScore = isScored
          ? gameState.scoreSheet.scores[category] ?? 0
          : null;
      final potentialScore = isScored
          ? null
          : gameState.getPotentialScore(category);

      return AnimatedCategorySelection(
        key: ValueKey('score_row_${category.name}'),
        isSelected: false,
        onTap: isScored ? null : () => onCategoryTapped(category),
        child: ScoreRow(
          category: category,
          potentialScore: potentialScore,
          currentScore: currentScore,
          isScored: isScored,
          yatzyBonus:
              category == ScoreCategory.yatzy &&
              gameState.scoreSheet.yatzyCount > 0,
        ),
      );
    }).toList();
  }
}

/// Widget displaying the upper section total.
class _UpperTotalRow extends StatelessWidget {
  final int upperTotal;
  final bool hasBonus;

  const _UpperTotalRow({required this.upperTotal, required this.hasBonus});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentYellow,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Bonus',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            hasBonus ? '50' : '0',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiceRow extends StatefulWidget {
  final List<int> diceValues;
  final List<int> heldIndices;
  final Function(int) onDieTapped;

  const _DiceRow({
    required this.diceValues,
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
        return AnimatedDieWidget(
          key: ValueKey('die-$index'),
          value: value,
          isHeld: isHeld,
          onTap: () => widget.onDieTapped(index),
          triggerAnimation: _lastRollCount > 0,
        );
      }).toList(),
    );
  }
}

/// Widget displaying the Roll and New Game buttons.
class _ButtonRow extends StatelessWidget {
  final int rollCount;
  final bool canRoll;
  final VoidCallback? onRollTapped;
  final VoidCallback? onNewGameTapped;

  const _ButtonRow({
    required this.rollCount,
    required this.canRoll,
    this.onRollTapped,
    this.onNewGameTapped,
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
            onPressed: onNewGameTapped,
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
              'New Game',
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
