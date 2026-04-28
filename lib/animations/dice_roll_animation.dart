import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Animation controller for dice rolling effect.
///
/// Provides smooth rotation and scale animations during dice roll,
/// with configurable duration and easing curves.
///
/// Example usage:
/// ```dart
/// final diceRollAnimation = DiceRollAnimation(vsync: this);
/// diceRollAnimation.startRoll();
/// // After animation completes or when result is ready:
/// diceRollAnimation.stopRoll(5);
/// ```
class DiceRollAnimation {
  /// The animation controller managing the roll animation.
  final AnimationController _controller;

  /// The rotation animation during roll.
  late final Animation<double> _rotationAnimation;

  /// The scale/pulse animation during roll.
  late final Animation<double> _scaleAnimation;

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

  /// Creates a [DiceRollAnimation] with the specified duration.
  ///
  /// [vsync] is required to provide the ticker for the animation controller.
  DiceRollAnimation({
    required TickerProvider vsync,
    this.duration = const Duration(milliseconds: 600),
    this.onComplete,
  }) : _controller = AnimationController(duration: duration, vsync: vsync) {
    _initAnimations();
  }

  /// Initializes all animation curves and sequences.
  void _initAnimations() {
    // Rotation animation: spin 3-5 full rotations
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: Random().nextDouble() * 2 * pi + 4 * pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Scale animation: subtle pulse effect
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  /// Starts the dice rolling animation.
  void startRoll() {
    if (_isRolling) {
      _controller.stop();
    }
    _isRolling = true;
    _currentRandomValue = 1;

    // Start cycling random values
    _valueCycleTimer?.cancel();
    _valueCycleTimer = Timer.periodic(const Duration(milliseconds: 80), (_) {
      _currentRandomValue = Random().nextInt(6) + 1;
    });
  }

  /// Stops the rolling animation and shows the final value.
  ///
  /// [finalValue] is the die value to display after animation stops (1-6).
  void stopRoll(int finalValue) {
    assert(
      finalValue >= 1 && finalValue <= 6,
      'Final value must be between 1 and 6',
    );

    _valueCycleTimer?.cancel();
    _currentRandomValue = finalValue;

    if (_controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }

    _isRolling = false;
    onComplete?.call();
  }

  /// Gets the current random value during roll animation.
  int get currentRandomValue => _currentRandomValue;

  /// Gets the rotation animation for the dice.
  Animation<double> get rotationAnimation => _rotationAnimation;

  /// Gets the scale animation for the dice.
  Animation<double> get scaleAnimation => _scaleAnimation;

  /// Checks if the dice is currently rolling.
  bool get isRolling => _isRolling;

  /// Disposes all resources used by the animation.
  void dispose() {
    _valueCycleTimer?.cancel();
    _isRolling = false;
    _controller.dispose();
  }
}
