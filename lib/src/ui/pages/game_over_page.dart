import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

/// Game over page for displaying final game results.
///
/// Shows a celebration-themed layout with:
/// - Game over header with animated trophy icon
/// - Final score display with counting animation
/// - Score breakdown showing upper total, lower total, and bonus
/// - Category score summary for all 13 categories
/// - Action buttons for starting a new game and viewing high scores
///
/// Includes celebration animations:
/// - Trophy bounce and rotation animation
/// - Confetti particle effect
/// - Score counting animation
///
/// Example:
/// ```dart
/// GameOverPage(
///   scoreSheet: gameBloc.state.scoreSheet,
///   onNewGame: () => Navigator.pop(context),
///   onViewHighScores: () => Navigator.push(
///     context,
///     MaterialPageRoute(builder: (_) => HighScoresPage()),
///   ),
/// )
/// ```
class GameOverPage extends StatefulWidget {
  /// Final score sheet with all 13 categories filled.
  ///
  /// Contains all scores for upper section (Aces-Sixes),
  /// lower section (ThreeOfKind-Chance), and total score.
  final ScoreSheet scoreSheet;

  /// Callback when new game button is pressed.
  ///
  /// Typically used to navigate back to the home screen
  /// or reset the game state.
  final VoidCallback? onNewGame;

  /// Callback for viewing high scores.
  ///
  /// Used to navigate to the high scores leaderboard page.
  final VoidCallback? onViewHighScores;

  /// Creates a [GameOverPage] with the given score sheet and callbacks.
  ///
  /// The [scoreSheet] parameter must not be null and should contain
  /// all 13 category scores.
  const GameOverPage({
    super.key,
    required this.scoreSheet,
    this.onNewGame,
    this.onViewHighScores,
  });

  @override
  State<GameOverPage> createState() => _GameOverPageState();
}

class _GameOverPageState extends State<GameOverPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _trophyScaleAnimation;
  late Animation<double> _trophyRotationAnimation;
  late Animation<double> _scoreAnimation;
  final List<ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    // Single animation controller for all animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _trophyScaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _trophyRotationAnimation = Tween<double>(begin: -20.0, end: 20.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scoreAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    // Start animations
    _animationController.forward().then((_) {
      // Stop animation when complete to prevent going beyond 1.0
      _animationController.stop();
    });
    _generateConfetti();
  }

  void _generateConfetti() {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.successColor,
      AppTheme.errorColor,
      AppTheme.diceSelectedColor,
    ];

    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(
        ConfettiParticle(
          x: math.Random().nextDouble() * 600,
          y: -50,
          velocityX: (math.Random().nextDouble() - 0.5) * 4,
          velocityY: 2 + math.Random().nextDouble() * 3,
          rotation: math.Random().nextDouble() * 360,
          rotationSpeed: (math.Random().nextDouble() - 0.5) * 10,
          size: 4 + math.Random().nextDouble() * 6,
          color: colors[math.Random().nextInt(colors.length)],
          opacity: 1.0,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finalScore = widget.scoreSheet.getTotal();
    final upperTotal = widget.scoreSheet.getUpperTotal();
    final lowerTotal = widget.scoreSheet.getLowerTotal();
    final bonus = widget.scoreSheet.getBonus();

    return Scaffold(
      appBar: AppBar(title: const Text('Game Over'), elevation: 4),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildGameOverHeader(context),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildFinalScore(context, finalScore),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildScoreBreakdown(
                        context,
                        upperTotal: upperTotal,
                        lowerTotal: lowerTotal,
                        bonus: bonus,
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      _buildCategoryScoreSummary(context),
                      const SizedBox(height: AppTheme.spacingXl),
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Confetti overlay
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return CustomPaint(
                painter: ConfettiPainter(
                  particles: _confettiParticles,
                  progress: _animationController.value,
                ),
                size: MediaQuery.of(context).size,
              );
            },
          ),
        ],
      ),
    );
  }

  /// Builds the game over header with animated trophy icon.
  Widget _buildGameOverHeader(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Clamp animation values to valid range to handle elastic curve overshoot
        final scale = _trophyScaleAnimation.value.clamp(0.0, 2.0);
        final rotation = _trophyRotationAnimation.value.clamp(-45.0, 45.0);
        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation * (math.pi / 180),
            child: child,
          ),
        );
      },
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 80, color: AppTheme.secondaryColor),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Game Over!',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds the final score display with counting animation.
  Widget _buildFinalScore(BuildContext context, int finalScore) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.shadowMedium,
          ),
          child: Column(
            children: [
              Text(
                'Final Score',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 100),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  '${(finalScore * _scoreAnimation.value).floor()}',
                  key: ValueKey<int>(
                    (finalScore * _scoreAnimation.value).floor(),
                  ),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: AppTheme.secondaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 56,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the score breakdown section.
  Widget _buildScoreBreakdown(
    BuildContext context, {
    required int upperTotal,
    required int lowerTotal,
    required int bonus,
  }) {
    final hasBonus = bonus > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Breakdown',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: AppTheme.spacingLg),
            _buildScoreRow('Upper Total', upperTotal),
            _buildScoreRow('Lower Total', lowerTotal),
            if (hasBonus) _buildBonusRow(bonus),
            const Divider(height: AppTheme.spacingLg),
            _buildTotalRow(
              'Grand Total',
              upperTotal + lowerTotal + bonus,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a score row with label and value.
  Widget _buildScoreRow(String label, int score) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppTheme.bodyLarge,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: AppTheme.bodyLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bonus row with special styling.
  Widget _buildBonusRow(int bonus) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star, size: 16, color: AppTheme.secondaryColor),
              const SizedBox(width: AppTheme.spacingSm),
              const Text(
                'Bonus',
                style: TextStyle(
                  fontSize: AppTheme.bodyLarge,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            '+$bonus',
            style: const TextStyle(
              fontSize: AppTheme.bodyLarge,
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the grand total row.
  Widget _buildTotalRow(String label, int score, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: AppTheme.bodyLarge,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
            ),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontSize: AppTheme.bodyLarge,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppTheme.primaryColor : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the category score summary list.
  Widget _buildCategoryScoreSummary(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Category Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            // Upper Section
            _buildSectionHeader('Upper Section'),
            const Divider(height: AppTheme.spacingSm),
            ..._buildCategoryRows(ScoreCategoryHelper.getUpperCategories()),
            const SizedBox(height: AppTheme.spacingMd),
            // Lower Section
            _buildSectionHeader('Lower Section'),
            const Divider(height: AppTheme.spacingSm),
            ..._buildCategoryRows(ScoreCategoryHelper.getLowerCategories()),
          ],
        ),
      ),
    );
  }

  /// Builds a section header for upper/lower categories.
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: AppTheme.bodyMedium,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryColor,
      ),
    );
  }

  /// Builds a list of category score rows.
  List<Widget> _buildCategoryRows(List<ScoreCategory> categories) {
    return categories.map((category) {
      final score = widget.scoreSheet.scores[category] ?? 0;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                category.displayName,
                style: const TextStyle(
                  fontSize: AppTheme.bodyMedium,
                  color: AppTheme.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: score > 0
                    ? AppTheme.successColor
                    : AppTheme.disabledColor,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Text(
                '$score',
                style: const TextStyle(
                  fontSize: AppTheme.bodyMedium,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  /// Builds the action buttons.
  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: 'Start a new game',
          button: true,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: widget.onNewGame,
              icon: const Icon(Icons.add),
              label: const Text('New Game'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Semantics(
          label: 'View high scores leaderboard',
          button: true,
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: widget.onViewHighScores,
              icon: const Icon(Icons.leaderboard),
              label: const Text('View High Scores'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A particle for the confetti celebration animation.
///
/// Represents a single confetti piece with physics properties
/// for position, velocity, rotation, and appearance.
///
/// Example:
/// ```dart
/// final particle = ConfettiParticle(
///   x: 100.0,
///   y: 0.0,
///   velocityX: 2.0,
///   velocityY: 5.0,
///   rotation: 0.0,
///   rotationSpeed: 5.0,
///   size: 8.0,
///   color: Colors.red,
///   opacity: 1.0,
/// );
/// ```
class ConfettiParticle {
  /// Horizontal position of the particle.
  double x;

  /// Vertical position of the particle.
  double y;

  /// Horizontal velocity (pixels per frame).
  final double velocityX;

  /// Vertical velocity (pixels per frame).
  final double velocityY;

  /// Current rotation angle in degrees.
  double rotation;

  /// Rotation speed (degrees per frame).
  final double rotationSpeed;

  /// Size of the particle in pixels.
  final double size;

  /// Color of the particle.
  final Color color;

  /// Opacity of the particle (0.0 to 1.0).
  double opacity;

  /// Creates a [ConfettiParticle] with the specified properties.
  ///
  /// All parameters are required and must not be null.
  ConfettiParticle({
    required this.x,
    required this.y,
    required this.velocityX,
    required this.velocityY,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.color,
    required this.opacity,
  });
}

/// Custom painter for rendering confetti particles.
///
/// Animates confetti particles with physics-based movement,
/// rotation, and fading effects for celebration scenes.
///
/// Example:
/// ```dart
/// CustomPaint(
///   painter: ConfettiPainter(
///     particles: confettiParticles,
///     progress: animationController.value,
///   ),
///   size: MediaQuery.of(context).size,
/// )
/// ```
class ConfettiPainter extends CustomPainter {
  /// List of particles to render.
  final List<ConfettiParticle> particles;

  /// Animation progress (0.0 to 1.0).
  final double progress;

  /// Creates a [ConfettiPainter] with the given particles and progress.
  ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Clamp progress to valid range [0, 1]
    final clampedProgress = progress.clamp(0.0, 1.0);

    for (final particle in particles) {
      if (particle.opacity <= 0) continue;

      final paint = Paint()
        ..color = particle.color.withValues(
          alpha: particle.opacity.clamp(0.0, 1.0),
        )
        ..strokeWidth = particle.size
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(particle.x, particle.y);
      canvas.rotate(particle.rotation * (math.pi / 180));
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();

      // Update particle position only during active animation
      if (clampedProgress < 1.0) {
        particle.y += particle.velocityY;
        particle.x += particle.velocityX;
        particle.rotation += particle.rotationSpeed;
        particle.opacity -= 0.01;
      }
    }
  }

  @override
  bool shouldRepaint(ConfettiPainter oldDelegate) => true;
}
