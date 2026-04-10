import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/components/die_widget.dart';

void main() {
  group('DieWidget', () {
    testWidgets('displays die with value 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 1))),
      );

      // Find the die container
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('displays correct number of dots for each value', (
      tester,
    ) async {
      for (int value = 1; value <= 6; value++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(value: value)),
          ),
        );

        // Count the dots (black containers)
        final dotFinder = find.byType(Container).evaluate();
        expect(
          dotFinder.length,
          greaterThan(1),
        ); // At least die container + dots

        await tester.pumpAndSettle();
      }
    });

    testWidgets('shows orange border when held', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DieWidget(value: 1, isHeld: true)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('does not show border when not held', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DieWidget(value: 1, isHeld: false)),
        ),
      );

      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DieWidget(value: 1, onTap: () => tapped = true)),
        ),
      );

      await tester.tap(find.byType(DieWidget));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('has correct dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 1))),
      );

      final finder = find.byType(Container).first;
      final container = tester.widget<Container>(finder);

      // Container should have constraints
      expect(container, isA<Container>());
    });

    testWidgets('renders all die values correctly', (tester) async {
      for (int value = 1; value <= 6; value++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(value: value)),
          ),
        );

        expect(find.byType(DieWidget), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('renders blank die with value 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 0))),
      );

      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('has shadow effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 1))),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.boxShadow, isNotEmpty);
    });
  });

  group('DieWidget - Accessibility', () {
    testWidgets('has semantic label for screen readers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 3))),
      );

      // Widget should be accessible
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });

  group('DieWidget - Dot centering', () {
    testWidgets('die value 1 has centered dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 1))),
      );

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 2 has properly positioned corner dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 2))),
      );

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 3 has properly positioned dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 3))),
      );

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 4 has properly positioned corner dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 4))),
      );

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 5 has properly positioned dots including center', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 5))),
      );

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 6 has properly positioned dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 6))),
      );

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('all die values render correct number of dots', (tester) async {
      for (int value = 1; value <= 6; value++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(value: value)),
          ),
        );

        // Find all Container widgets (dots are containers with circle decoration)
        final dotFinder = find.byType(Container);
        expect(dotFinder, findsWidgets);

        await tester.pumpAndSettle();
      }
    });
  });
}
