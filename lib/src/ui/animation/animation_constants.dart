import 'package:flutter/animation.dart';

/// Animation durations for the Yatzy dice game.
///
/// These constants ensure consistent animation timing throughout the app.
class AnimationDurations {
  /// Short animation duration for quick feedback (e.g., tap effects).
  /// Duration: 150ms
  static const Duration short = Duration(milliseconds: 150);

  /// Medium animation duration for standard transitions (e.g., score updates).
  /// Duration: 200ms
  static const Duration medium = Duration(milliseconds: 200);

  /// Long animation duration for smooth, noticeable effects (e.g., dice roll).
  /// Duration: 300ms
  static const Duration long = Duration(milliseconds: 300);

  /// Very long animation duration for dramatic effects.
  /// Duration: 500ms
  static const Duration veryLong = Duration(milliseconds: 500);
}

/// Animation curves for the Yatzy dice game.
///
/// These curves provide smooth, natural-looking animations.
class AnimationCurves {
  /// Standard ease-in-out curve for smooth start and end.
  static const Curve standard = Curves.easeInOut;

  /// Ease-out curve for animations that slow down at the end.
  static const Curve easeOut = Curves.easeOut;

  /// Ease-in curve for animations that start slowly.
  static const Curve easeIn = Curves.easeIn;

  /// Bounce curve for playful, bouncy effects.
  static const Curve bounce = Curves.bounceOut;

  /// Elastic curve for spring-like effects.
  static const Curve elastic = Curves.elasticOut;

  /// Decelerate curve for quick start, slow end.
  static const Curve decelerate = Curves.decelerate;
}
