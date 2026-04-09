import 'package:flutter/material.dart';

/// Responsive layout utilities for the Poker Dice game.
///
/// Provides helpers for creating responsive layouts that adapt to
/// different screen sizes (mobile, tablet, desktop).
class ResponsiveLayout {
  ResponsiveLayout._();

  /// Breakpoint values for different screen sizes.
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  /// Returns true if the current screen width is mobile-sized.
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width <= mobileMaxWidth;
  }

  /// Returns true if the current screen width is tablet-sized.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > mobileMaxWidth && width <= tabletMaxWidth;
  }

  /// Returns true if the current screen width is desktop-sized.
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width > tabletMaxWidth;
  }

  /// Returns the appropriate padding based on screen size.
  static EdgeInsets getPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(12);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsets.all(32);
    }
  }

  /// Returns the appropriate max width for content based on screen size.
  static double getMaxWidth(BuildContext context) {
    if (isMobile(context)) {
      return double.infinity;
    } else if (isTablet(context)) {
      return 600;
    } else {
      return 800;
    }
  }

  /// Returns the appropriate dice size based on screen size.
  static double getDiceSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width <= 400) {
      return 50;
    } else if (width <= 600) {
      return 60;
    } else if (width <= 1024) {
      return 80;
    } else {
      return 100;
    }
  }

  /// Returns the appropriate font size for scores based on screen size.
  static double getScoreFontSize(BuildContext context) {
    if (isMobile(context)) {
      return 16;
    } else if (isTablet(context)) {
      return 18;
    } else {
      return 20;
    }
  }
}

/// A responsive wrapper widget that adapts its layout based on screen size.
///
/// Provides a consistent way to create responsive layouts throughout the app.
class ResponsiveWrapper extends StatelessWidget {
  /// The child widget to wrap.
  final Widget child;

  /// Maximum width for the content.
  final double? maxWidth;

  /// Creates a [ResponsiveWrapper].
  const ResponsiveWrapper({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    final effectiveMaxWidth = maxWidth ?? ResponsiveLayout.getMaxWidth(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= effectiveMaxWidth) {
          return child;
        }

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
            child: child,
          ),
        );
      },
    );
  }
}

/// A responsive container that adjusts its padding based on screen size.
class ResponsiveContainer extends StatelessWidget {
  /// The child widget to contain.
  final Widget child;

  /// Creates a [ResponsiveContainer].
  const ResponsiveContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(padding: ResponsiveLayout.getPadding(context), child: child);
  }
}
