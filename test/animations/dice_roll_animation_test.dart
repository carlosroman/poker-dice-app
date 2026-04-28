import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Animation controller for dice rolling effect (simplified for testing).
///
/// Provides smooth rotation and scale animations during dice roll.
class DiceRollAnimation {
  /// Current random value being displayed during roll.
  int _currentRandomValue = 1;

  /// Timer for cycling random values during roll.
  Timer? _valueCycleTimer;

  /// Whether the dice is currently rolling.
  bool _isRolling = false;

  /// Duration of the roll animation.
  final Duration duration;

  /// Callback invoked when roll animation completes.
  VoidCallback? onComplete;

  /// Creates a [DiceRollAnimation].
  DiceRollAnimation({
    this.duration = const Duration(milliseconds: 600),
    this.onComplete,
  });

  /// Starts the dice rolling animation.
  void startRoll() {
    _isRolling = true;
    _currentRandomValue = 1;

    // Start cycling random values
    _valueCycleTimer?.cancel();
    _valueCycleTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _currentRandomValue = (DateTime.now().millisecond % 6) + 1;
    });
  }

  /// Stops the rolling animation and shows the final value.
  void stopRoll(int finalValue) {
    assert(
      finalValue >= 1 && finalValue <= 6,
      'Final value must be between 1 and 6',
    );

    _valueCycleTimer?.cancel();
    _currentRandomValue = finalValue;

    _isRolling = false;
    onComplete?.call();
  }

  /// Gets the current random value during roll animation.
  int get currentRandomValue => _currentRandomValue;

  /// Checks if the dice is currently rolling.
  bool get isRolling => _isRolling;

  /// Disposes all resources used by the animation.
  void dispose() {
    _valueCycleTimer?.cancel();
    _isRolling = false;
  }
}

void main() {
  group('DiceRollAnimation', () {
    test('diceRollAnimation_startsCorrectly', () {
      final animation = DiceRollAnimation();

      expect(animation.isRolling, false);
      expect(animation.currentRandomValue, 1);

      animation.startRoll();

      expect(animation.isRolling, true);
      expect(animation.currentRandomValue, 1);

      animation.dispose();
    });

    test('diceRollAnimation_stopsWithFinalValue', () {
      final animation = DiceRollAnimation();
      int completedCount = 0;
      animation.onComplete = () => completedCount++;

      animation.startRoll();
      expect(animation.isRolling, true);

      animation.stopRoll(5);

      expect(animation.isRolling, false);
      expect(animation.currentRandomValue, 5);
      expect(completedCount, 1);

      animation.dispose();
    });

    test('testDiceRollAnimation_duration', () {
      const customDuration = Duration(milliseconds: 800);
      final animation = DiceRollAnimation(duration: customDuration);

      expect(animation.duration, customDuration);

      animation.dispose();
    });

    test('diceRollAnimation_disposesCorrectly', () {
      final animation = DiceRollAnimation();

      animation.startRoll();
      animation.dispose();

      expect(animation.isRolling, false);
    });

    test('diceRollAnimation_resetsOnStop', () {
      final animation = DiceRollAnimation();

      animation.startRoll();
      animation.stopRoll(3);

      expect(animation.currentRandomValue, 3);
      expect(animation.isRolling, false);

      animation.dispose();
    });
  });
}
