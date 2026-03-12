import 'dart:async';

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
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    _gameOverController = AnimationController(
      duration: _fadeDuration,
      vsync: this,
    );
    // Start auto-save timer to persist state periodically
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _saveGameState();
    });
  }

  @override
  void didUpdateWidget(GameScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final gameState = ref.read(gameProvider);
    if (gameState.isGameOver && !_wasGameOver) {
      _gameOverController.forward();
    }
    _wasGameOver = gameState.isGameOver;
  }

  @override
  void dispose() {
    _gameOverController.dispose();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final scoreAsync = ref.watch(scoreProvider);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: _buildAppBar(context, gameState, ref),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: _animationDuration,
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                child: _buildScorecardSection(context, gameState, ref),
              ),
              const SizedBox(height: 24),
              _buildDiceDisplaySection(context, gameState, ref),
              const SizedBox(height: 24),
              _buildControlsSection(context, gameState, ref, scoreAsync),
              const SizedBox(height: 16),
              AnimatedOpacity(
                opacity: gameState.isGameOver ? 1.0 : 0.0,
                duration: _fadeDuration,
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: _fadeDuration,
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFA726),
                      width: 2,
                    ),
                  ),
                  child: _buildGameOverContent(context, ref, scoreAsync),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the top header bar with back button, score display, and menu button.
  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
  ) {
    return AppBar(
      backgroundColor: const Color(0xFF2C3E50),
      elevation: 4,
      leading: _buildBackButton(context),
      centerTitle: true,
      title: _buildScoreDisplay(gameState),
      actions: [_buildMenuButton(context, gameState, ref)],
    );
  }

  /// Builds the back arrow button (circular, yellow/orange).
  Widget _buildBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Material(
        color: const Color(0xFFFFA726),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  /// Builds the score display - "2070 You" format (large white text).
  Widget _buildScoreDisplay(GameState gameState) {
    return Text(
      '${gameState.getTotalScore()} You',
      style: GoogleFonts.openSans(
        fontSize: 24,
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
  ) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Material(
        color: const Color(0xFFFFA726),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _showMenuDialog(context, gameState, ref),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
          child: const Icon(Icons.list, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  /// Builds the scorecard section with two-column layout.
  Widget _buildScorecardSection(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scorecard',
              style: GoogleFonts.openSans(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildMinorColumn(
                    context,
                    gameState,
                    potentialScores,
                    ref,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMajorColumn(
                    context,
                    gameState,
                    potentialScores,
                    ref,
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
  ) {
    final minorCategories = UPPER_CATEGORIES;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Minor',
          style: GoogleFonts.openSans(
            fontSize: 14,
            color: Colors.grey[300],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
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
          );
        }),
        const SizedBox(height: 8),
        _buildBonusRow(context, gameState),
      ],
    );
  }

  /// Builds the Major column with 6 scoring categories.
  Widget _buildMajorColumn(
    BuildContext context,
    GameState gameState,
    List<int> potentialScores,
    WidgetRef ref,
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
            fontSize: 14,
            color: Colors.grey[300],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isPending
                        ? const Color(0xFFFFA726)
                        : const Color(0xFFFFA726),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: _buildIconWidget(icon, isIcon: icon is IconData),
                  ),
                ),
                const SizedBox(width: 8),
                // Category name
                Expanded(
                  child: Text(
                    isMinor ? _getDieFaceValue(category) : category,
                    style: GoogleFonts.openSans(
                      fontSize: 10,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$scoredValue',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
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
                      fontSize: 11,
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
  Widget _buildBonusRow(BuildContext context, GameState gameState) {
    final upperSectionTotal = gameState.getUpperSectionTotal();
    final bonusEligible = upperSectionTotal >= BONUS_THRESHOLD;
    final bonusScore = gameState.getBonus();
    final progress = upperSectionTotal / BONUS_THRESHOLD;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                fontSize: 10,
                color: bonusEligible ? Colors.green[300] : Colors.grey[500],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 60,
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
          const SizedBox(width: 8),
          Text(
            bonusScore > 0 ? '+$bonusScore' : '0',
            style: GoogleFonts.openSans(
              fontSize: 11,
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
  ) {
    return AnimatedSwitcher(
      duration: _animationDuration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Container(
        key: ValueKey(gameState.turnNumber),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(gameState.dice.length, (index) {
              final dice = gameState.dice[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
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
  ) {
    return Column(
      children: [
        // Roll button with rolls remaining counter
        _buildRollButton(context, gameState, ref),
        const SizedBox(height: 16),
        // Play button (large, white with orange text)
        _buildPlayButton(context, gameState, ref),
        const SizedBox(height: 8),
        // Game over indicator with fade animation
        AnimatedOpacity(
          opacity: gameState.isGameOver ? 1.0 : 0.0,
          duration: _fadeDuration,
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: _fadeDuration,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFA726), width: 2),
            ),
            child: _buildGameOverContent(context, ref, scoreAsync),
          ),
        ),
      ],
    );
  }

  /// Builds the ROLL button with rolls remaining counter.
  Widget _buildRollButton(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
  ) {
    final isEnabled = gameState.rollsRemaining > 0 && gameState.isTurnActive;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                ref.read(gameProvider.notifier).rollDice();
                _saveGameState();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? const Color(0xFFFFA726)
              : Colors.grey[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: isEnabled ? 4 : 0,
        ),
        child: Text(
          'ROLL',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Builds the PLAY button to confirm pending selection and submit score.
  Widget _buildPlayButton(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
  ) {
    // Can only play if there's a pending selection and turn is active
    final hasPendingSelection = gameState.pendingSelection != null;
    final canPlay = gameState.isTurnActive && hasPendingSelection;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canPlay
            ? () {
                ref.read(gameProvider.notifier).confirmSelection();
                _saveGameState();
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canPlay ? Colors.white : Colors.grey[600],
          foregroundColor: canPlay ? const Color(0xFFFFA726) : Colors.grey[400],
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: canPlay ? 4 : 0,
        ),
        child: Text(
          'PLAY',
          style: GoogleFonts.openSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Builds the game over content.
  Widget _buildGameOverContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<int> scoreAsync,
  ) {
    return Column(
      children: [
        Text(
          'GAME OVER',
          style: GoogleFonts.openSans(
            fontSize: 20,
            color: const Color(0xFFFFA726),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        scoreAsync.when(
          data: (highScore) {
            final finalScore = ref.read(gameProvider).getTotalScore();
            final isHighScore = finalScore > highScore;
            return Column(
              children: [
                Text(
                  'Final Score: $finalScore',
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isHighScore) ...[
                  const SizedBox(height: 4),
                  Text(
                    'NEW HIGH SCORE!',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: Colors.green[300],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
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
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'PLAY AGAIN',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
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
  void _saveGameState() {
    final gameNotifier = ref.read(gameProvider.notifier);
    gameNotifier.saveState();
  }

  /// Shows menu dialog with game options.
  void _showMenuDialog(
    BuildContext context,
    GameState gameState,
    WidgetRef ref,
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
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.refresh, color: Color(0xFFFFA726)),
              title: Text(
                'Restart Game',
                style: GoogleFonts.openSans(color: Colors.white),
              ),
              onTap: () async {
                Navigator.of(context).pop();
                // Clear saved state before resetting game
                await ref.read(gameProvider.notifier).clearSavedState();
                ref.read(gameProvider.notifier).resetGame();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Color(0xFFFFA726)),
              title: Text(
                'Game Rules',
                style: GoogleFonts.openSans(color: Colors.white),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showRulesDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.openSans(color: Colors.grey[300]),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows game rules dialog.
  void _showRulesDialog(BuildContext context) {
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
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Score pairs of each face value (9, 10, J, Q, K, A).',
                style: GoogleFonts.openSans(color: Colors.grey[300]),
              ),
              const SizedBox(height: 8),
              Text(
                'Bonus: +20 if upper section total >= 30',
                style: GoogleFonts.openSans(
                  color: Colors.green[300],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lower Section:',
                style: GoogleFonts.openSans(
                  color: Colors.orange[300],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '• Three of a Kind: Sum of all dice (3+ same)',
                style: GoogleFonts.openSans(color: Colors.grey[300]),
              ),
              Text(
                '• Four of a Kind: Sum of all dice (4+ same)',
                style: GoogleFonts.openSans(color: Colors.grey[300]),
              ),
              Text(
                '• Full House: Sum of all dice (3+2)',
                style: GoogleFonts.openSans(color: Colors.grey[300]),
              ),
              Text(
                '• Small Straight: 25 points (5 consecutive)',
                style: GoogleFonts.openSans(color: Colors.grey[300]),
              ),
              Text(
                '• Large Straight: 25 points (6 consecutive)',
                style: GoogleFonts.openSans(color: Colors.grey[300]),
              ),
              Text(
                '• Yahtzee: 50 points (5 of a kind)',
                style: GoogleFonts.openSans(color: Colors.grey[300]),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.openSans(color: Colors.grey[300]),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the icon widget based on whether it's an icon data or text.
  Widget _buildIconWidget(Object icon, {required bool isIcon}) {
    if (isIcon) {
      return Icon(icon as IconData, color: Colors.white, size: 16);
    } else {
      return Text(
        icon.toString(),
        style: GoogleFonts.openSans(
          fontSize: 12,
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
