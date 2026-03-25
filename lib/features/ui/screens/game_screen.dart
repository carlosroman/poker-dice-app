import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/dice_faces.dart';
import '../../game/models/game_state.dart';
import '../../game/providers/game_provider.dart';
import '../../score/score_provider.dart';
import '../widgets/dice_card.dart';

const _animationDuration = Duration(milliseconds: 300);
const _fadeDuration = Duration(milliseconds: 250);

/// Helper class for responsive sizing based on screen dimensions
class _ResponsiveSizes {
  final double screenWidth;
  final double screenHeight;
  final double scale;
  final bool isWeb;

  _ResponsiveSizes(this.screenWidth, this.screenHeight, {this.isWeb = false})
    : scale = isWeb ? 1.0 : (screenWidth / 375);

  // For web, use fixed sizes; for mobile, use scaled sizes
  double get fontSizeSmall => isWeb ? 10 : 10 * scale;
  double get fontSizeMedium => isWeb ? 14 : 14 * scale;
  double get fontSizeLarge => isWeb ? 18 : 18 * scale;
  double get fontSizeXLarge => isWeb ? 24 : 24 * scale;
  double get spacingSmall => isWeb ? 8 : 6 * scale;
  double get spacingMedium => isWeb ? 16 : 12 * scale;
  double get spacingLarge => isWeb ? 24 : 20 * scale;
  double get padding => isWeb ? 16 : 12 * scale;
  double get buttonPaddingVertical => isWeb ? 16 : 14 * scale;
  double get iconSize => isWeb ? 16 : 16 * scale;
}

/// Main game screen for the Poker Dice game.
///
/// Displays the complete game interface including:
/// - Header bar with back button, score, and menu
/// - Scorecard with two-column layout (minor/major categories)
/// - Dice display section with 5 card-style dice
/// - Controls section with roll and play buttons
///
/// Connected to Riverpod providers for game state and score management.
class GameScreen extends ConsumerStatefulWidget {
  /// Creates a [GameScreen] widget.
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _gameOverController;
  bool _wasGameOver = false;
  bool _modalShown = false;

  @override
  void initState() {
    super.initState();
    _gameOverController = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );
    _wasGameOver = false;
    _modalShown = false;
  }

  void _resetGameOverFlags() {
    _wasGameOver = false;
    _modalShown = false;
    _gameOverController.reset();
  }

  @override
  void dispose() {
    _gameOverController.dispose();
    super.dispose();
  }

  /// Shows the game over modal dialog
  void _showGameOverModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Consumer(
        builder: (dialogContext, ref, _) {
          final scoreAsync = ref.watch(scoreProvider);
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFA726), width: 3),
              ),
              child: _buildGameOverContent(context, ref, scoreAsync),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final scoreAsync = ref.watch(scoreProvider);
    final screenSize = MediaQuery.of(context).size;
    final sizes = _ResponsiveSizes(
      screenSize.width,
      screenSize.height,
      isWeb: kIsWeb,
    );

    // Check for game over transition in build method
    if (gameState.isGameOver && !_wasGameOver && !_modalShown) {
      _wasGameOver = true;
      _modalShown = true;
      _gameOverController.forward();
      // Show modal after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showGameOverModal(context);
        }
      });
    }

    // Reset flags when game is reset (isGameOver goes from true to false)
    if (!gameState.isGameOver && _wasGameOver) {
      _resetGameOverFlags();
    }

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _buildAppBar(context, gameState, ref, sizes),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: EdgeInsets.all(sizes.padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: sizes.spacingSmall + 2),
                    AnimatedSwitcher(
                      duration: _animationDuration,
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _buildScorecardSection(
                        context,
                        gameState,
                        ref,
                        sizes,
                      ),
                    ),
                    SizedBox(height: sizes.spacingMedium),
                    _buildDiceDisplaySection(context, gameState, ref, sizes),
                    SizedBox(height: sizes.spacingMedium),
                    _buildControlsSection(
                      context,
                      gameState,
                      ref,
                      scoreAsync,
                      sizes,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the top header bar with back button, score display, and menu button.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFF2C3E50),
      elevation: 4,
      leading: _buildBackButton(context, sizes),
      centerTitle: true,
      title: _buildScoreDisplay(gameState, sizes),
      actions: [_buildMenuButton(context, gameState, ref, sizes)],
    );
  }

  /// Builds the back arrow button (circular, yellow/orange).
  Widget _buildBackButton(BuildContext context, _ResponsiveSizes sizes) {
    return Padding(
      padding: EdgeInsets.only(left: sizes.spacingSmall + 2),
      child: Material(
        color: const Color(0xFFFFA726),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _handleBackNavigation(context),
          borderRadius: BorderRadius.circular(24 * sizes.scale),
          child: Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 24 * sizes.scale,
          ),
        ),
      ),
    );
  }

  /// Handles back navigation with confirmation dialog.
  ///
  /// Always saves the game state before navigating back.
  /// Shows a dialog with three options:
  /// - Cancel: Stay in the game
  /// - Save & Continue Later: Save state and return to title screen
  /// - Restart Game: Clear saved state and start fresh
  Future<void> _handleBackNavigation(BuildContext context) async {
    // Always save current state first
    await _saveGameState();

    final navigator = Navigator.of(context);

    // Show confirmation dialog with options
    final choice = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Leave Game?',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Your game will be saved. What would you like to do?',
          style: GoogleFonts.openSans(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(0),
            child: Text(
              'Cancel',
              style: GoogleFonts.openSans(color: Colors.grey[400]),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(1),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFA726),
            ),
            child: const Text('Save & Continue Later'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(2),
            style: TextButton.styleFrom(foregroundColor: Colors.red[300]),
            child: const Text('Restart Game'),
          ),
        ],
      ),
    );

    // Handle the user's choice
    if (choice == 1 && mounted) {
      // Save & Continue - navigate back to title screen
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (choice == 2 && mounted) {
      // Restart - clear state and navigate to title
      await ref.read(gameProvider.notifier).clearSavedState();
      ref.read(gameProvider.notifier).resetGame();
      navigator.pop();
    }
    // choice == 0 means cancel, do nothing (stay in game)
  }

  /// Builds the score display - "2070 You" format (large white text).
  Widget _buildScoreDisplay(GameState gameState, _ResponsiveSizes sizes) {
    return Text(
      '${gameState.getTotalScore()} You',
      style: GoogleFonts.openSans(
        fontSize: sizes.fontSizeXLarge,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Builds the menu button (circular, yellow/orange with list icon).
  Widget _buildMenuButton(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    return Padding(
      padding: EdgeInsets.only(right: sizes.spacingSmall + 2),
      child: Material(
        color: const Color(0xFFFFA726),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _showMenuDialog(context, gameState, ref, sizes),
          borderRadius: BorderRadius.circular(24 * sizes.scale),
          child: Icon(Icons.list, color: Colors.white, size: 24 * sizes.scale),
        ),
      ),
    );
  }

  /// Builds the scorecard section with two-column layout.
  Widget _buildScorecardSection(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    final diceHaveValues = gameState.dice.every((d) => d.value != null);
    final diceValues = diceHaveValues
        ? gameState.dice.map((d) => d.value!).toList()
        : List.filled(5, 0);
    final potentialScores = diceHaveValues
        ? ref.read(gameProvider.notifier).getPotentialScores(diceValues)
        : List.filled(NUM_CATEGORIES, 0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(sizes.padding + 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scorecard',
              style: GoogleFonts.openSans(
                fontSize: sizes.fontSizeLarge,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: sizes.spacingMedium),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildMinorColumn(
                    context,
                    gameState,
                    potentialScores,
                    ref,
                    sizes,
                  ),
                ),
                SizedBox(width: sizes.spacingMedium),
                Expanded(
                  child: _buildMajorColumn(
                    context,
                    gameState,
                    potentialScores,
                    ref,
                    sizes,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the Minor column with 6 rows for die face values.
  Widget _buildMinorColumn(
    BuildContext context,
    GameState gameState,
    List<int> potentialScores,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    final minorCategories = UPPER_CATEGORIES;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minor',
          style: GoogleFonts.openSans(
            fontSize: sizes.fontSizeMedium,
            color: Colors.grey[300],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: sizes.spacingSmall + 2),
        ...minorCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final isScored = gameState.isCategoryScored(index);
          final scoredValue = gameState.scoreCategories[index].score ?? 0;
          final potentialScore = isScored ? null : potentialScores[index];

          return _buildScoreRow(
            context,
            icon: _getDiceFaceIcon(index),
            category: category,
            isScored: isScored,
            scoredValue: scoredValue,
            potentialScore: potentialScore,
            isMinor: true,
            isPending: gameState.pendingSelection == index,
            onTap: () => _onCategorySelected(ref, index),
            enabled: !isScored && gameState.isTurnActive,
            sizes: sizes,
          );
        }),
        SizedBox(height: sizes.spacingSmall + 2),
        _buildBonusRow(context, gameState, sizes),
      ],
    );
  }

  /// Builds the Major column with 6 scoring categories.
  Widget _buildMajorColumn(
    BuildContext context,
    GameState gameState,
    List<int> potentialScores,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    final majorCategories = LOWER_CATEGORIES;
    final majorIcons = [
      '3x',
      '4x',
      Icons.home,
      Icons.credit_card,
      Icons.credit_card,
      'Y',
      'C',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Major',
          style: GoogleFonts.openSans(
            fontSize: sizes.fontSizeMedium,
            color: Colors.grey[300],
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: sizes.spacingSmall + 2),
        ...majorCategories.asMap().entries.map((entry) {
          final index = entry.key + 6;
          final category = entry.value;
          final isScored = gameState.isCategoryScored(index);
          final scoredValue = gameState.scoreCategories[index].score ?? 0;
          final potentialScore = isScored ? null : potentialScores[index];

          return _buildScoreRow(
            context,
            icon: majorIcons[index - 6],
            category: category,
            isScored: isScored,
            scoredValue: scoredValue,
            potentialScore: potentialScore,
            isMinor: false,
            isPending: gameState.pendingSelection == index,
            onTap: () => _onCategorySelected(ref, index),
            enabled: !isScored && gameState.isTurnActive,
            sizes: sizes,
          );
        }),
      ],
    );
  }

  /// Builds a single score row with icon, score box, and potential score.
  Widget _buildScoreRow(
    BuildContext context, {
    required Object icon,
    required String category,
    required bool isScored,
    required int scoredValue,
    required int? potentialScore,
    required bool isMinor,
    required bool isPending,
    required VoidCallback? onTap,
    required bool enabled,
    required _ResponsiveSizes sizes,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sizes.spacingSmall - 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: sizes.iconSize / 2,
              vertical: sizes.spacingSmall - 4,
            ),
            decoration: BoxDecoration(
              color: isPending
                  ? const Color(0xFFFFA726).withValues(alpha: 0.2)
                  : enabled
                  ? Colors.grey[800]
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isScored
                    ? Colors.blue
                    : isPending
                    ? const Color(0xFFFFA726)
                    : Colors.grey[600]!,
                width: isScored || isPending ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // Yellow die face icon box
                Container(
                  width: 32 * sizes.scale,
                  height: 32 * sizes.scale,
                  decoration: BoxDecoration(
                    color: isPending
                        ? const Color(0xFFFFA726)
                        : const Color(0xFFFFA726),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: _buildIconWidget(
                      icon,
                      isIcon: icon is IconData,
                      sizes: sizes,
                    ),
                  ),
                ),
                SizedBox(width: sizes.spacingSmall + 2),
                // Category name
                Expanded(
                  child: Text(
                    isMinor ? _getDieFaceValue(category) : category,
                    style: GoogleFonts.openSans(
                      fontSize: sizes.fontSizeSmall,
                      color: isPending
                          ? const Color(0xFFFFA726)
                          : enabled
                          ? Colors.grey[200]
                          : isScored
                          ? Colors.blue[300]
                          : Colors.grey[500],
                      fontWeight: isScored || isPending
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                // Score box (blue) if scored
                if (isScored)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: sizes.iconSize / 2 + 2,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$scoredValue',
                      style: GoogleFonts.openSans(
                        fontSize: sizes.fontSizeSmall + 1,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                // Potential score (white text) if not scored
                else
                  Text(
                    potentialScore?.toString() ?? '0',
                    style: GoogleFonts.openSans(
                      fontSize: sizes.fontSizeSmall + 1,
                      color: isPending
                          ? const Color(0xFFFFA726)
                          : enabled
                          ? Colors.white
                          : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the bonus row with progress indicator.
  Widget _buildBonusRow(
    BuildContext context,
    GameState gameState,
    _ResponsiveSizes sizes,
  ) {
    final upperSectionTotal = gameState.getUpperSectionTotal();
    final bonusEligible = upperSectionTotal >= BONUS_THRESHOLD;
    final bonusScore = gameState.getBonus();
    final progress = upperSectionTotal / BONUS_THRESHOLD;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: sizes.iconSize / 2,
        vertical: sizes.spacingSmall - 4,
      ),
      decoration: BoxDecoration(
        color: bonusEligible ? Colors.green[900] : Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: bonusEligible ? Colors.green : Colors.grey[600]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'BONUS +20',
              style: GoogleFonts.openSans(
                fontSize: sizes.fontSizeSmall,
                color: bonusEligible ? Colors.green[300] : Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: sizes.spacingSmall + 2),
          SizedBox(
            width: 60 * sizes.scale,
            child: Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: bonusEligible ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: sizes.spacingSmall + 2),
          Text(
            bonusScore > 0 ? '+$bonusScore' : '0',
            style: GoogleFonts.openSans(
              fontSize: sizes.fontSizeSmall + 1,
              color: bonusEligible ? Colors.green[300] : Colors.grey[500],
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the dice display section with 5 card-style dice.
  Widget _buildDiceDisplaySection(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    return AnimatedSwitcher(
      duration: _animationDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Container(
        key: ValueKey(gameState.turnNumber),
        padding: EdgeInsets.symmetric(vertical: sizes.spacingMedium + 4),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(gameState.dice.length, (index) {
              final dice = gameState.dice[index];
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: sizes.spacingSmall - 2,
                ),
                child: DiceCard(
                  value: dice.value,
                  isHeld: dice.isHeld,
                  onTap: () {
                    ref.read(gameProvider.notifier).toggleHold(index);
                    _saveGameState();
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  /// Builds the controls section with roll and play buttons.
  Widget _buildControlsSection(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
    AsyncValue<int> scoreAsync,
    _ResponsiveSizes sizes,
  ) {
    return Column(
      children: [
        // Roll and Play buttons side by side
        Row(
          children: [
            // Roll button with rolls remaining counter
            Expanded(child: _buildRollButton(context, gameState, ref, sizes)),
            SizedBox(width: sizes.spacingMedium + 4),
            // Play button (large, white with orange text)
            Expanded(child: _buildPlayButton(context, gameState, ref, sizes)),
          ],
        ),
        SizedBox(height: sizes.spacingSmall + 2),
      ],
    );
  }

  /// Builds the ROLL button with rolls remaining counter.
  Widget _buildRollButton(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    final isEnabled = gameState.rollsRemaining > 0 && gameState.isTurnActive;

    return ElevatedButton(
      onPressed: isEnabled
          ? () {
              ref.read(gameProvider.notifier).rollDice();
              _saveGameState();
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isEnabled ? const Color(0xFFFFA726) : Colors.grey[600],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: sizes.buttonPaddingVertical),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: isEnabled ? 4 : 0,
      ),
      child: Text(
        'ROLL (${gameState.rollsRemaining})',
        style: GoogleFonts.openSans(
          fontSize: sizes.fontSizeLarge + 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds the PLAY button to confirm pending selection and submit score.
  Widget _buildPlayButton(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    // Can only play if there's a pending selection and turn is active
    final hasPendingSelection = gameState.pendingSelection != null;
    final canPlay = gameState.isTurnActive && hasPendingSelection;

    return ElevatedButton(
      onPressed: canPlay
          ? () {
              ref.read(gameProvider.notifier).confirmSelection();
              _saveGameState();
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canPlay ? Colors.white : Colors.grey[600],
        foregroundColor: canPlay ? const Color(0xFFFFA726) : Colors.grey[400],
        padding: EdgeInsets.symmetric(vertical: sizes.buttonPaddingVertical),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: canPlay ? 4 : 0,
      ),
      child: Text(
        'PLAY',
        style: GoogleFonts.openSans(
          fontSize: sizes.fontSizeLarge + 2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Builds the game over content for the modal dialog.
  Widget _buildGameOverContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> scoreAsync,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'GAME OVER',
          style: GoogleFonts.openSans(
            fontSize: 28,
            color: const Color(0xFFFFA726),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        scoreAsync.when(
          data: (highScore) {
            final finalScore = ref.read(gameProvider).getTotalScore();
            final isHighScore = finalScore > highScore;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Final Score: $finalScore',
                  style: GoogleFonts.openSans(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isHighScore) ...[
                  const SizedBox(height: 8),
                  Text(
                    'NEW HIGH SCORE!',
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      color: Colors.green[300],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    // Close dialog first
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    // Reset flags
                    _resetGameOverFlags();
                    // Clear saved state before starting new game
                    await ref.read(gameProvider.notifier).clearSavedState();
                    ref.read(gameProvider.notifier).resetGame();
                    if (isHighScore) {
                      ref
                          .read(scoreProvider.notifier)
                          .saveHighScore(finalScore);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA726),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'PLAY AGAIN',
                    style: GoogleFonts.openSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (_, error) => const Text('Error loading high score'),
        ),
      ],
    );
  }

  /// Handles category selection - marks it as pending.
  void _onCategorySelected(WidgetRef ref, int index) {
    ref.read(gameProvider.notifier).selectPending(index);
    _saveGameState();
  }

  /// Saves the current game state to persistent storage.
  Future<void> _saveGameState() async {
    final gameNotifier = ref.read(gameProvider.notifier);
    await gameNotifier.saveState();
  }

  /// Shows menu dialog with game options.
  void _showMenuDialog(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
    _ResponsiveSizes sizes,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Menu',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: sizes.fontSizeLarge,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.refresh,
                color: const Color(0xFFFFA726),
                size: sizes.iconSize,
              ),
              title: Text(
                'Restart Game',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: sizes.fontSizeMedium,
                ),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                // Clear saved state before resetting game
                await ref.read(gameProvider.notifier).clearSavedState();
                ref.read(gameProvider.notifier).resetGame();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: const Color(0xFFFFA726),
                size: sizes.iconSize,
              ),
              title: Text(
                'Game Rules',
                style: GoogleFonts.openSans(
                  color: Colors.white,
                  fontSize: sizes.fontSizeMedium,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showRulesDialog(context, sizes);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.openSans(
                color: Colors.grey[300],
                fontSize: sizes.fontSizeMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows game rules dialog.
  void _showRulesDialog(BuildContext context, _ResponsiveSizes sizes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Game Rules',
          style: GoogleFonts.openSans(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: sizes.fontSizeLarge,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Upper Section:',
                style: GoogleFonts.openSans(
                  color: Colors.orange[300],
                  fontWeight: FontWeight.bold,
                  fontSize: sizes.fontSizeMedium,
                ),
              ),
              SizedBox(height: sizes.spacingSmall - 2),
              Text(
                'Score pairs of each face value (9, 10, J, Q, K, A).',
                style: GoogleFonts.openSans(
                  color: Colors.grey[300],
                  fontSize: sizes.fontSizeSmall + 2,
                ),
              ),
              SizedBox(height: sizes.spacingMedium - 4),
              Text(
                'Bonus: +20 if upper section total >= 30',
                style: GoogleFonts.openSans(
                  color: Colors.green[300],
                  fontWeight: FontWeight.w600,
                  fontSize: sizes.fontSizeSmall + 2,
                ),
              ),
              SizedBox(height: sizes.spacingLarge - 4),
              Text(
                'Lower Section:',
                style: GoogleFonts.openSans(
                  color: Colors.orange[300],
                  fontWeight: FontWeight.bold,
                  fontSize: sizes.fontSizeMedium,
                ),
              ),
              SizedBox(height: sizes.spacingSmall - 2),
              Text(
                '• Three of a Kind: Sum of all dice (3+ same)',
                style: GoogleFonts.openSans(
                  color: Colors.grey[300],
                  fontSize: sizes.fontSizeSmall + 2,
                ),
              ),
              Text(
                '• Four of a Kind: Sum of all dice (4+ same)',
                style: GoogleFonts.openSans(
                  color: Colors.grey[300],
                  fontSize: sizes.fontSizeSmall + 2,
                ),
              ),
              Text(
                '• Full House: Sum of all dice (3+2)',
                style: GoogleFonts.openSans(
                  color: Colors.grey[300],
                  fontSize: sizes.fontSizeSmall + 2,
                ),
              ),
              Text(
                '• Small Straight: 25 points (5 consecutive)',
                style: GoogleFonts.openSans(
                  color: Colors.grey[300],
                  fontSize: sizes.fontSizeSmall + 2,
                ),
              ),
              Text(
                '• Large Straight: 25 points (6 consecutive)',
                style: GoogleFonts.openSans(
                  color: Colors.grey[300],
                  fontSize: sizes.fontSizeSmall + 2,
                ),
              ),
              Text(
                '• Yahtzee: 50 points (5 of a kind)',
                style: GoogleFonts.openSans(
                  color: Colors.grey[300],
                  fontSize: sizes.fontSizeSmall + 2,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.openSans(
                color: Colors.grey[300],
                fontSize: sizes.fontSizeMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the icon widget based on whether it's an icon data or text.
  Widget _buildIconWidget(
    Object icon, {
    required bool isIcon,
    required _ResponsiveSizes sizes,
  }) {
    if (isIcon) {
      return Icon(icon as IconData, color: Colors.white, size: sizes.iconSize);
    } else {
      return Text(
        icon.toString(),
        style: GoogleFonts.openSans(
          fontSize: sizes.iconSize,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }
  }

  /// Extracts the die face value from category name.
  String _getDieFaceValue(String categoryName) {
    if (categoryName.contains('9')) return '9';
    if (categoryName.contains('10')) return '10';
    if (categoryName.contains('Jacks')) return 'J';
    if (categoryName.contains('Queens')) return 'Q';
    if (categoryName.contains('Kings')) return 'K';
    if (categoryName.contains('Aces')) return 'A';
    return categoryName;
  }

  /// Returns the icon for a dice face value.
  Object _getDiceFaceIcon(int index) {
    switch (index) {
      case 0:
        return '9';
      case 1:
        return '10';
      case 2:
        return 'J';
      case 3:
        return 'Q';
      case 4:
        return 'K';
      case 5:
        return 'A';
      default:
        return '?';
    }
  }
}
