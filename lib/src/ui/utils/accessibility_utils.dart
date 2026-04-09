import 'package:flutter/material.dart';

/// Accessibility utilities for the Poker Dice game.
///
/// Provides helpers for creating accessible UI components with
/// proper semantic labels and keyboard navigation support.
class AccessibilityUtils {
  AccessibilityUtils._();

  /// Returns a semantic label for a die value.
  static String getDieLabel(int value, {bool isHeld = false}) {
    final holdStatus = isHeld ? ' (held)' : '';
    return 'Die showing $value$holdStatus';
  }

  /// Returns a semantic label for a score category row.
  static String getScoreRowLabel(
    String categoryName,
    int? potentialScore,
    int? currentScore,
  ) {
    final buffer = StringBuffer(categoryName);

    if (potentialScore != null) {
      buffer.write(', potential score $potentialScore');
    }

    if (currentScore != null) {
      buffer.write(', current score $currentScore');
    } else {
      buffer.write(', not scored yet');
    }

    buffer.write('. Double tap to select.');

    return buffer.toString();
  }

  /// Returns a semantic label for the roll button.
  static String getRollLabel(int rollCount, bool canRoll) {
    final status = canRoll ? '' : ' (disabled, maximum rolls reached)';
    return 'Roll button, roll count $rollCount of 3$status';
  }

  /// Returns a semantic label for the play button.
  static String getPlayLabel(bool isEnabled) {
    final status = isEnabled ? '' : ' (disabled)';
    return 'Play button, select a category to score$status';
  }

  /// Returns a semantic label for the total score.
  static String getTotalScoreLabel(int score) {
    return 'Total score: $score points';
  }

  /// Returns a semantic label for the bonus progress.
  static String getBonusProgressLabel(int current, int target, int bonus) {
    if (bonus > 0) {
      return 'Bonus achieved: $current out of $target, +$bonus bonus points';
    }
    return 'Bonus progress: $current out of $target points for +$bonus bonus';
  }

  /// Returns a semantic label for a high score entry.
  static String getHighScoreLabel(int rank, int score, DateTime date) {
    return 'Rank $rank: $score points, achieved on ${_formatDate(date)}';
  }

  /// Formats a date for accessibility labels.
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Creates an accessible button with proper labels.
  static Widget accessibleButton({
    required Widget child,
    required VoidCallback? onPressed,
    required String label,
    bool isEnabled = true,
  }) {
    return Semantics(
      label: label,
      button: true,
      enabled: isEnabled,
      child: IconButton(
        onPressed: onPressed,
        icon: child is Icon ? child : Icon(Icons.check),
        tooltip: label,
      ),
    );
  }

  /// Creates an accessible text widget with proper labels.
  static Widget accessibleText({
    required String text,
    required String label,
    TextStyle? style,
  }) {
    return Semantics(
      label: label,
      child: Text(text, style: style),
    );
  }

  /// Creates an accessible container with proper labels.
  static Widget accessibleContainer({
    required Widget child,
    required String label,
  }) {
    return Semantics(label: label, child: child);
  }
}

/// Extension methods for adding accessibility features to widgets.
extension AccessibilityExtensions on Widget {
  /// Adds a semantic label to the widget.
  Widget withSemanticLabel(String label) {
    return Semantics(label: label, child: this);
  }

  /// Marks the widget as a button for screen readers.
  Widget asButton({bool enabled = true}) {
    return Semantics(button: true, enabled: enabled, child: this);
  }

  /// Marks the widget as selected.
  Widget asSelected() {
    return Semantics(selected: true, child: this);
  }

  /// Adds a hint for screen readers.
  Widget withHint(String hint) {
    return Semantics(hint: hint, child: this);
  }
}
