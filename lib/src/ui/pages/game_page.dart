import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/game_bloc.dart';
import '../../domain/game_state.dart';
import '../components/die_widget.dart';
import '../components/hold_checkbox.dart';
import '../components/roll_button.dart';
import '../components/score_sheet.dart';
import '../theme/app_theme.dart';

/// The main game page for the Poker Dice game.
///
/// This page displays the complete game interface with:
/// - **Dice Display Area**: Shows 5 dice with hold checkboxes below
/// - **Roll Button Area**: Centered button with remaining rolls indicator
/// - **Score Sheet Area**: Scrollable list of all 13 scoring categories
///
/// **Integration:**
/// - Fully integrated with [GameBloc] for state management
/// - Uses [BlocBuilder] to rebuild on state changes
/// - Uses [BlocListener] for one-off actions (game over dialog)
///
/// **User Interactions:**
/// - Tap dice to toggle hold state
/// - Tap roll button to roll unheld dice
/// - Tap category rows to score
/// - FAB for new game or high scores
///
/// Example:
/// ```dart
/// // Navigate to game page
/// Navigator.push(
///   context,
///   MaterialPageRoute(builder: (_) => const GamePage()),
/// );
/// ```
class GamePage extends StatelessWidget {
  /// Creates a [GamePage] instance.
  ///
  /// Parameters:
  /// - [key]: Optional widget key.
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameBloc, GameState>(
      listener: (context, state) {
        // Handle game over state
        if (state.isGameOver) {
          _showGameOverDialog(context, state);
        }
      },
      child: BlocBuilder<GameBloc, GameState>(
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: _buildBody(context, state),
            floatingActionButton: _buildFab(context, state),
          );
        },
      ),
    );
  }

  /// Builds the app bar with the Poker Dice title.
  ///
  /// Returns:
  /// An [AppBar] with centered title, elevation, and shadow.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Poker Dice'),
      centerTitle: true,
      elevation: 4,
      shadowColor: Colors.black26,
    );
  }

  /// Builds the main body with Column layout.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [state]: The current game state.
  ///
  /// Returns:
  /// A [Column] containing dice area, roll button area, and score sheet.
  Widget _buildBody(BuildContext context, GameState state) {
    return Column(
      children: [
        // Dice Display Area
        _buildDiceArea(context, state),
        // Roll Button Area
        _buildRollButtonArea(context, state),
        // Score Sheet Area (scrollable)
        _buildScoreSheetArea(context, state),
      ],
    );
  }

  /// Builds the dice display area with 5 dice and hold checkboxes.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [state]: The current game state.
  ///
  /// Returns:
  /// A [Container] with styled background containing dice row and checkboxes.
  Widget _buildDiceArea(BuildContext context, GameState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.radiusLg),
        ),
        boxShadow: AppTheme.shadowMedium,
      ),
      child: Column(
        children: [
          // Dice row
          _buildDiceRow(context, state),
          const SizedBox(height: AppTheme.spacingMd),
          // Hold checkboxes row
          _buildHoldCheckboxesRow(context, state),
        ],
      ),
    );
  }

  /// Builds the row of 5 dice.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [state]: The current game state.
  ///
  /// Returns:
  /// A [Row] of [DieWidget] instances wrapped in GestureDetector.
  Widget _buildDiceRow(BuildContext context, GameState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(state.currentRound.dice.length, (index) {
            final die = state.currentRound.dice[index];
            return GestureDetector(
              onTap: () {
                context.read<GameBloc>().add(ToggleDieEvent(index));
              },
              child: DieWidget(
                key: ValueKey('die-$index'),
                die: die,
                onTap: () {
                  context.read<GameBloc>().add(ToggleDieEvent(index));
                },
              ),
            );
          }),
        );
      },
    );
  }

  /// Builds the row of hold checkboxes below the dice.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [state]: The current game state.
  ///
  /// Returns:
  /// A [Row] of [HoldCheckbox] instances with responsive spacing.
  Widget _buildHoldCheckboxesRow(BuildContext context, GameState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final checkboxSpacing = isMobile
            ? AppTheme.spacingXs
            : AppTheme.spacingSm;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(state.currentRound.dice.length, (index) {
            final die = state.currentRound.dice[index];
            return Padding(
              key: ValueKey('checkbox-$index'),
              padding: EdgeInsets.symmetric(horizontal: checkboxSpacing),
              child: HoldCheckbox(
                isHeld: die.held,
                isEnabled: !state.isGameOver && state.currentRound.canRoll(),
                onChanged: (_) {
                  context.read<GameBloc>().add(ToggleDieEvent(index));
                },
              ),
            );
          }),
        );
      },
    );
  }

  /// Builds the roll button area.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [state]: The current game state.
  ///
  /// Returns:
  /// A centered [RollButton] with appropriate enabled state.
  Widget _buildRollButtonArea(BuildContext context, GameState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacingLg,
        horizontal: AppTheme.spacingMd,
      ),
      child: Center(
        child: RollButton(
          key: const ValueKey('roll-button'),
          isEnabled: !state.isGameOver && state.currentRound.canRoll(),
          remainingRolls: state.getRemainingRolls(),
          onPressed: () {
            context.read<GameBloc>().add(RollDiceEvent());
          },
        ),
      ),
    );
  }

  /// Builds the scrollable score sheet area.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [state]: The current game state.
  ///
  /// Returns:
  /// An expanded [ScoreSheet] widget with current scores.
  Widget _buildScoreSheetArea(BuildContext context, GameState state) {
    return Expanded(
      child: Container(
        color: AppTheme.backgroundColor,
        child: ScoreSheet(
          key: const ValueKey('score-sheet'),
          scoreSheet: state.scoreSheet,
          validCategories: state.getValidCategories(),
          onCategorySelected: (category) {
            context.read<GameBloc>().add(SelectCategoryEvent(category));
          },
        ),
      ),
    );
  }

  /// Builds the floating action button for navigation.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [state]: The current game state.
  ///
  /// Returns:
  /// A [FloatingActionButton] that either starts a new game or shows high scores.
  Widget _buildFab(BuildContext context, GameState state) {
    return FloatingActionButton(
      key: const ValueKey('new-game-fab'),
      onPressed: state.isGameOver
          ? () {
              context.read<GameBloc>().add(NewGameEvent());
            }
          : () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('High Scores feature coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
      tooltip: state.isGameOver ? 'New Game' : 'View High Scores',
      child: Icon(state.isGameOver ? Icons.refresh : Icons.leaderboard),
    );
  }

  /// Shows a game over dialog with the final score.
  ///
  /// Parameters:
  /// - [context]: The build context.
  /// - [state]: The game over state containing final scores.
  ///
  /// Displays:
  /// - "Game Over!" title
  /// - Final score display
  /// - "Play Again" button
  void _showGameOverDialog(BuildContext context, GameState state) {
    final grandTotal = state.scoreSheet.getTotal();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your final score:',
                style: Theme.of(dialogContext).textTheme.titleMedium,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                '$grandTotal',
                style: Theme.of(dialogContext).textTheme.headlineLarge
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Play Again'),
            ),
          ],
        );
      },
    );
  }
}
