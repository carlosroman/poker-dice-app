import 'package:flutter/material.dart';

/// Game controls widget displaying roll and new game buttons.
class GameControls extends StatelessWidget {
  /// Number of rolls remaining in the current turn.
  final int rollsRemaining;

  /// Whether the current turn is active.
  final bool isTurnActive;

  /// Whether the game has ended.
  final bool isGameOver;

  /// Callback triggered when roll button is pressed.
  final VoidCallback? onRoll;

  /// Callback triggered when new game button is pressed.
  final VoidCallback? onNewGame;

  const GameControls({
    super.key,
    required this.rollsRemaining,
    required this.isTurnActive,
    required this.isGameOver,
    this.onRoll,
    this.onNewGame,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _RollButton(
          rollsRemaining: rollsRemaining,
          isTurnActive: isTurnActive,
          onRoll: onRoll,
        ),
        const SizedBox(height: 16),
        _NewGameButton(isGameOver: isGameOver, onNewGame: onNewGame),
      ],
    );
  }
}

/// Roll button widget showing rolls remaining counter.
class _RollButton extends StatelessWidget {
  final int rollsRemaining;
  final bool isTurnActive;
  final VoidCallback? onRoll;

  const _RollButton({
    required this.rollsRemaining,
    required this.isTurnActive,
    required this.onRoll,
  });

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = rollsRemaining > 0 && isTurnActive;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? onRoll : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? const Color(0xFFFFA726)
              : const Color(0xFF9E9E9E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          elevation: isEnabled ? 4 : 0,
        ),
        child: Text(
          'ROLL ($rollsRemaining)',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// New game button widget.
class _NewGameButton extends StatelessWidget {
  final bool isGameOver;
  final VoidCallback? onNewGame;

  const _NewGameButton({required this.isGameOver, required this.onNewGame});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isGameOver ? onNewGame : null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFFFA726), width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
        child: Text(
          'NEW GAME',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isGameOver
                ? const Color(0xFFFFA726)
                : const Color(0xFF9E9E9E),
          ),
        ),
      ),
    );
  }
}
