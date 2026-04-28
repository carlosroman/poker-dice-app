import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import '../models/dice_roll.dart';
import '../providers/game_provider.dart';
import '../widgets/header_bar.dart';
import '../widgets/dice_container.dart';
import '../widgets/scorecard.dart';
import '../widgets/bonus_indicator.dart';
import '../widgets/control_bar.dart';
import 'welcome_screen.dart';

/// The main game screen for the Poker Dice game.
///
/// This screen displays the complete game interface with three sections:
/// 1. **Top Section:** Header with total score
/// 2. **Middle Section:** Dice container, scorecard, and bonus indicator (scrollable)
/// 3. **Bottom Section:** Control bar with Roll and Play buttons
///
/// This widget can consume Riverpod state OR accept explicit parameters for testing.
class GameScreen extends ConsumerWidget {
  /// The player's total score across all categories.
  ///
  /// If null, reads from gameProvider.
  final int? totalScore;

  /// Number of rolls remaining in the current turn (0-3).
  ///
  /// If null, reads from gameProvider.
  final int? remainingRolls;

  /// Map of scored categories to their scores.
  ///
  /// If null, reads from gameProvider.
  final Map<Category, int>? scores;

  /// The currently selected category for scoring.
  ///
  /// If null, reads from gameProvider.
  final Category? selectedCategory;

  /// The current dice roll to display.
  ///
  /// If null, reads from gameProvider.
  final DiceRoll? diceRoll;

  /// Whether the bonus has been awarded in the upper section.
  ///
  /// If null, reads from gameProvider.
  final bool? bonusAwarded;

  /// The current sum of upper section categories (before bonus).
  ///
  /// If null, reads from gameProvider.
  final int? upperSectionScore;

  /// Callback invoked when the Roll button is pressed.
  ///
  /// If null, calls gameProvider's rollDice.
  final VoidCallback? onRollPressed;

  /// Callback invoked when the Play button is pressed.
  ///
  /// If null, calls gameProvider's scoreCategory.
  final VoidCallback? onPlayPressed;

  /// Callback invoked when a category row is tapped.
  ///
  /// If null, calls gameProvider's selectCategory.
  final Function(Category category)? onCategoryTapped;

  /// Callback invoked when a die is toggled (held/unheld).
  ///
  /// If null, calls gameProvider's toggleDieHeld.
  final Function(int index)? onDieToggled;

  /// Creates a [GameScreen] widget.
  const GameScreen({
    super.key,
    this.totalScore,
    this.remainingRolls,
    this.scores,
    this.selectedCategory,
    this.diceRoll,
    this.bonusAwarded,
    this.upperSectionScore,
    this.onRollPressed,
    this.onPlayPressed,
    this.onCategoryTapped,
    this.onDieToggled,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use Riverpod if no explicit parameters provided
    final useRiverpod = totalScore == null && scores == null;

    final gameState = useRiverpod ? ref.watch(gameProvider) : null;
    final gameNotifier = useRiverpod ? ref.read(gameProvider.notifier) : null;

    final effectiveTotalScore = totalScore ?? gameState?.totalScore ?? 0;
    final effectiveRemainingRolls =
        remainingRolls ?? gameState?.remainingRolls ?? 0;
    final effectiveScores = scores ?? gameState?.scores ?? {};
    final effectiveSelectedCategory =
        selectedCategory ?? gameState?.selectedCategory;
    final effectiveDiceRoll = diceRoll ?? gameState?.diceRoll;
    final effectiveBonusAwarded =
        bonusAwarded ?? gameState?.bonusAwarded ?? false;
    final effectiveUpperSectionScore =
        upperSectionScore ?? gameState?.upperSectionTotal ?? 0;

    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            // Top Section: Header
            _buildHeaderSection(context, effectiveTotalScore),

            // Middle Section: Scrollable content
            Expanded(
              child: _buildMiddleSection(
                context,
                effectiveDiceRoll,
                effectiveScores,
                effectiveSelectedCategory,
                effectiveUpperSectionScore,
                effectiveBonusAwarded,
                ref,
              ),
            ),

            // Bottom Section: Control Bar
            _buildBottomSection(
              context,
              effectiveRemainingRolls,
              effectiveSelectedCategory,
              effectiveScores,
              gameNotifier,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the app bar for the screen.
  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      title: const Text('Poker Dice'),
      centerTitle: true,
      elevation: 2,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          // Save game state before navigating back
          final gameNotifier = ref.read(gameProvider.notifier);
          await gameNotifier.saveGameState();

          // Navigate to welcome screen
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WelcomeScreen()),
            );
          }
        },
      ),
    );
  }

  /// Builds the top section with the header.
  Widget _buildHeaderSection(BuildContext context, int totalScore) {
    return HeaderBar(
      totalScore: totalScore,
      playerName: 'Player 1',
      onBackPressed: () => Navigator.maybePop(context),
    );
  }

  /// Builds the middle section with dice, scorecard, and bonus indicator.
  Widget _buildMiddleSection(
    BuildContext context,
    DiceRoll? diceRoll,
    Map<Category, int> scores,
    Category? selectedCategory,
    int upperSectionScore,
    bool bonusAwarded,
    WidgetRef ref,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: <Widget>[
          // Dice Container
          _buildDiceContainer(context, diceRoll, ref),

          const SizedBox(height: 16),

          // Bonus Indicator
          _buildBonusIndicator(context, upperSectionScore, bonusAwarded),

          const SizedBox(height: 16),

          // Scorecard
          _buildScorecard(context, scores, selectedCategory, ref),
        ],
      ),
    );
  }

  /// Builds the dice container widget.
  Widget _buildDiceContainer(
    BuildContext context,
    DiceRoll? diceRoll,
    WidgetRef ref,
  ) {
    final gameNotifier = ref.read(gameProvider.notifier);
    final effectiveOnDieToggled = onDieToggled;

    return DiceContainer(
      diceRoll: diceRoll,
      onDieToggled:
          effectiveOnDieToggled ??
          ((int index) => gameNotifier.toggleDieHeld(index)),
      dieSize: MediaQuery.of(context).size.width > 600 ? 80.0 : 60.0,
    );
  }

  /// Builds the bonus indicator widget.
  Widget _buildBonusIndicator(
    BuildContext context,
    int currentScore,
    bool bonusAwarded,
  ) {
    return BonusIndicator(
      currentScore: currentScore,
      bonusAwarded: bonusAwarded,
      targetScore: 63,
      bonusPoints: 35,
    );
  }

  /// Builds the scorecard widget.
  Widget _buildScorecard(
    BuildContext context,
    Map<Category, int> scores,
    Category? selectedCategory,
    WidgetRef ref,
  ) {
    final onCategoryTapped = this.onCategoryTapped;

    return Scorecard(
      scores: scores,
      selectedCategory: selectedCategory,
      onCategoryTapped: onCategoryTapped,
    );
  }

  /// Builds the bottom section with the control bar.
  Widget _buildBottomSection(
    BuildContext context,
    int remainingRolls,
    Category? selectedCategory,
    Map<Category, int> scores,
    GameNotifier? gameNotifier,
  ) {
    final onRollPressed = this.onRollPressed;
    final onPlayPressed = this.onPlayPressed;

    return ControlBar(
      remainingRolls: null, // Use Riverpod
      onRollPressed: onRollPressed,
      onPlayPressed: onPlayPressed,
      isPlayEnabled:
          selectedCategory != null && !scores.containsKey(selectedCategory),
    );
  }
}
