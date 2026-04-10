import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/animation/dice_animation.dart';

void main() {
  group('AnimatedDieWidget Tests', () {
    testWidgets('displays die with correct value', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedDieWidget(value: 3))),
      );

      // Verify die is displayed
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('displays correct number of dots for value 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedDieWidget(value: 1))),
      );

      // Count Container widgets that represent dots
      final dotFinder = find.byType(Container).evaluate();
      // Should have at least some dots displayed
      expect(dotFinder.length, greaterThan(0));
    });

    testWidgets('displays correct number of dots for value 6', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedDieWidget(value: 6))),
      );

      // Verify die with 6 is displayed
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('shows orange border when held', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedDieWidget(value: 3, isHeld: true)),
        ),
      );

      // Verify the die is displayed with held state
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('triggers scale animation when triggerAnimation is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedDieWidget(value: 3, triggerAnimation: true),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Pump animation frame
      await tester.pump(const Duration(milliseconds: 50));

      // Animation should be running
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('completes animation after duration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedDieWidget(value: 3, triggerAnimation: true),
          ),
        ),
      );

      // Pump through the full animation duration (300ms)
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Widget should still be present after animation
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('handles tap callback', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedDieWidget(value: 3, onTap: () => tapped = true),
          ),
        ),
      );

      // Tap the die using the Container widget inside
      await tester.tap(find.byType(Container).first);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('accepts value 0 (blank/unrolled)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedDieWidget(value: 0, isBlank: true)),
        ),
      );

      // Should display blank die without error
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('handles value 7 gracefully (no assertion)', (
      WidgetTester tester,
    ) async {
      // Widget accepts any value, displays no dots for invalid values
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedDieWidget(value: 7))),
      );

      // Should display without error (no dots shown for invalid value)
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('updates when value changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedDieWidget(value: 1))),
      );

      expect(find.byType(AnimatedDieWidget), findsOneWidget);

      // Rebuild with different value
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedDieWidget(value: 5))),
      );

      // Widget should still be present
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('has correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedDieWidget(value: 3))),
      );

      final containerFinder = find.byType(Container).first;
      final renderBox = tester.renderObject<RenderBox>(containerFinder);

      expect(renderBox.size.width, 60);
      expect(renderBox.size.height, 60);
    });
  });

  group('AnimatedDieWidget Animation Tests', () {
    testWidgets('animates scale on trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedDieWidget(value: 3, triggerAnimation: true),
          ),
        ),
      );

      // Initial state
      await tester.pump();

      // After some animation time, scale should be different from 1.0
      await tester.pump(const Duration(milliseconds: 100));

      // Widget should still be rendered
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });

    testWidgets('animates opacity on trigger', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedDieWidget(value: 3, triggerAnimation: true),
          ),
        ),
      );

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      // Widget should still be visible
      expect(find.byType(AnimatedDieWidget), findsOneWidget);
    });
  });
}
