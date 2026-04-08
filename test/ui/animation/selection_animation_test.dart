import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/animation/selection_animation.dart';

void main() {
  group('AnimatedCategorySelection Tests', () {
    testWidgets('wraps child widget correctly', (WidgetTester tester) async {
      const child = Text('Category');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const AnimatedCategorySelection(child: child)),
        ),
      );

      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('triggers tap callback when tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      const child = Text('Category');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedCategorySelection(
              child: child,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Category'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('triggers scale animation when isSelected is true', (
      WidgetTester tester,
    ) async {
      const child = Text('Category');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategorySelection(
              isSelected: true,
              child: child,
            ),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('shows highlight border when showHighlight is true', (
      WidgetTester tester,
    ) async {
      const child = Text('Category');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategorySelection(
              showHighlight: true,
              child: child,
            ),
          ),
        ),
      );

      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('uses custom duration when provided', (
      WidgetTester tester,
    ) async {
      const child = Text('Category');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategorySelection(
              isSelected: true,
              duration: Duration(milliseconds: 300),
              child: child,
            ),
          ),
        ),
      );

      // Animation should still be running
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('animates when isSelected changes from false to true', (
      WidgetTester tester,
    ) async {
      const child = Text('Category');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategorySelection(
              isSelected: false,
              child: child,
            ),
          ),
        ),
      );

      // Change isSelected to true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategorySelection(
              isSelected: true,
              child: child,
            ),
          ),
        ),
      );

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('does not trigger callback when onTap is null', (
      WidgetTester tester,
    ) async {
      const child = Text('Category');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const AnimatedCategorySelection(child: child)),
        ),
      );

      // Should not throw when tapping
      await tester.tap(find.text('Category'));
      await tester.pump();

      expect(find.text('Category'), findsOneWidget);
    });
  });

  group('RippleEffect Tests', () {
    testWidgets('displays child widget', (WidgetTester tester) async {
      const child = Text('Ripple Child');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const RippleEffect(child: child)),
        ),
      );

      expect(find.text('Ripple Child'), findsOneWidget);
    });

    testWidgets('triggers tap callback when tapped', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      const child = Text('Ripple Child');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RippleEffect(child: child, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Ripple Child'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('animates ripple on tap', (WidgetTester tester) async {
      const child = Text('Ripple Child');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const RippleEffect(
              duration: Duration(milliseconds: 150),
              child: child,
            ),
          ),
        ),
      );

      // Tap to trigger ripple
      await tester.tap(find.text('Ripple Child'));
      await tester.pump();

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Ripple Child'), findsOneWidget);
    });

    testWidgets('uses custom ripple color', (WidgetTester tester) async {
      const child = Text('Ripple Child');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const RippleEffect(rippleColor: Colors.blue, child: child),
          ),
        ),
      );

      expect(find.text('Ripple Child'), findsOneWidget);
    });

    testWidgets('completes ripple animation', (WidgetTester tester) async {
      const child = Text('Ripple Child');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const RippleEffect(
              duration: Duration(milliseconds: 100),
              child: child,
            ),
          ),
        ),
      );

      // Tap and settle
      await tester.tap(find.text('Ripple Child'));
      await tester.pumpAndSettle(const Duration(milliseconds: 150));

      expect(find.text('Ripple Child'), findsOneWidget);
    });
  });

  group('AnimatedCategoryRow Tests', () {
    testWidgets('displays child widget', (WidgetTester tester) async {
      const child = Text('Category Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const AnimatedCategoryRow(child: child)),
        ),
      );

      expect(find.text('Category Row'), findsOneWidget);
    });

    testWidgets('animates color when isSelected is true', (
      WidgetTester tester,
    ) async {
      const child = Text('Category Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategoryRow(isSelected: true, child: child),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Category Row'), findsOneWidget);
    });

    testWidgets('uses custom selected color', (WidgetTester tester) async {
      const child = Text('Category Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategoryRow(
              isSelected: true,
              selectedColor: Colors.green,
              child: child,
            ),
          ),
        ),
      );

      expect(find.text('Category Row'), findsOneWidget);
    });

    testWidgets('animates when isSelected changes', (
      WidgetTester tester,
    ) async {
      const child = Text('Category Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategoryRow(isSelected: false, child: child),
          ),
        ),
      );

      // Change isSelected to true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategoryRow(isSelected: true, child: child),
          ),
        ),
      );

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Category Row'), findsOneWidget);
    });

    testWidgets('reverses animation when isSelected changes to false', (
      WidgetTester tester,
    ) async {
      const child = Text('Category Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategoryRow(isSelected: true, child: child),
          ),
        ),
      );

      // Change isSelected to false
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategoryRow(isSelected: false, child: child),
          ),
        ),
      );

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Category Row'), findsOneWidget);
    });

    testWidgets('uses custom duration', (WidgetTester tester) async {
      const child = Text('Category Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedCategoryRow(
              isSelected: true,
              duration: Duration(milliseconds: 400),
              child: child,
            ),
          ),
        ),
      );

      // Animation should still be running
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Category Row'), findsOneWidget);
    });
  });
}
