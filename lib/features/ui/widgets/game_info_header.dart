import 'package:flutter/material.dart';

/// A header widget displaying game information.
///
/// Shows the current turn number, current score, and high score
/// in a card-style header bar at the top of the game screen.
class GameInfoHeader extends StatelessWidget {
  /// The current total score.
  final int currentScore;

  /// The best high score.
  final int highScore;

  /// The current turn number (1-indexed).
  final int turnNumber;

  /// Whether the game has ended.
  final bool isGameOver;

  /// Creates a [GameInfoHeader] widget.
  const GameInfoHeader({
    super.key,
    required this.currentScore,
    required this.highScore,
    required this.turnNumber,
    required this.isGameOver,
  });

  static const double _headerHeight = 80.0;
  static const Color _headerBackgroundColor = Color(0xFF2C3E50);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: _headerBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _TurnDisplay(turnNumber: turnNumber),
          const VerticalDivider(
            color: Color(0x80FFFFFF),
            thickness: 1.0,
            width: 40.0,
          ),
          _ScoreDisplay(
            currentScore: currentScore,
            highScore: highScore,
            isGameOver: isGameOver,
          ),
        ],
      ),
    );
  }
}

/// Displays the current turn number.
class _TurnDisplay extends StatelessWidget {
  /// The current turn number.
  final int turnNumber;

  const _TurnDisplay({required this.turnNumber});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Turn',
          style: TextStyle(
            fontSize: 12.0,
            color: Colors.white70,
            fontWeight: FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$turnNumber',
          style: const TextStyle(
            fontSize: 24.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Displays the current score and high score.
class _ScoreDisplay extends StatelessWidget {
  /// The current total score.
  final int currentScore;

  /// The best high score.
  final int highScore;

  /// Whether the game has ended.
  final bool isGameOver;

  const _ScoreDisplay({
    required this.currentScore,
    required this.highScore,
    required this.isGameOver,
  });

  static const Color _accentColor = Color(0xFFFF6F00);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildScoreColumn(
          label: isGameOver ? 'Final Score' : 'Score',
          score: currentScore,
          isCurrent: true,
        ),
        if (highScore > 0) ...[
          const SizedBox(height: 8),
          _buildScoreColumn(
            label: 'High Score',
            score: highScore,
            isCurrent: false,
          ),
        ],
      ],
    );
  }

  Widget _buildScoreColumn({
    required String label,
    required int score,
    required bool isCurrent,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: isCurrent ? _accentColor : Colors.white24,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.0,
                  color: isCurrent ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.normal,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$score',
                style: TextStyle(
                  fontSize: isCurrent ? 32.0 : 16.0,
                  color: isCurrent ? Colors.white : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
