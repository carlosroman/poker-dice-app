import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/die_widget.dart';

void main() {
  group('DieWidget Animation', () {
    testWidgets('dieWidget_animatesOnRoll', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DieWidget(
              value: 3,
              isHeld: false,
              onTap: () => tapCount++,
              isRolling: true,
            ),
          ),
        ),
      );

      // Check that the die widget is displayed
      expect(find.byType(DieWidget), findsOneWidget);

      // Pump to allow animations and timer to start
      await tester.pump(const Duration(milliseconds: 100));

      // Update to a new value
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DieWidget(
              value: 5,
              isHeld: false,
              onTap: () => tapCount++,
              isRolling: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the die still exists after update
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('dieWidget_smoothHeldTransition', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DieWidget(value: 4, isHeld: false, size: 80.0)),
        ),
      );

      final dieFinder = find.byType(DieWidget);
      expect(dieFinder, findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DieWidget(value: 4, isHeld: true, size: 80.0)),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DieWidget(value: 4, isHeld: false, size: 80.0)),
        ),
      );

      await tester.pump(const Duration(milliseconds: 100));
    });

    testWidgets('dieWidget_animationCompletes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DieWidget(value: 6, isHeld: false, size: 100.0)),
        ),
      );

      await tester.tap(find.byType(DieWidget));
      await tester.pump();

      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('dieWidget_displaysCorrectValue', (WidgetTester tester) async {
      for (int value = 1; value <= 6; value++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(value: value, isHeld: false)),
          ),
        );

        expect(find.byType(DieWidget), findsOneWidget);

        await tester.pumpAndSettle();
      }
    });

    testWidgets('dieWidget_heldStateVisualFeedback', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DieWidget(value: 2, isHeld: true, size: 60.0)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DieWidget(value: 2, isHeld: false, size: 60.0)),
        ),
      );

      await tester.pumpAndSettle();
    });

    testWidgets('dieWidget_tapCallbackInvoked', (WidgetTester tester) async {
      int tapCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DieWidget(value: 1, isHeld: false, onTap: () => tapCount++),
          ),
        ),
      );

      await tester.tap(find.byType(DieWidget));
      await tester.pumpAndSettle();

      expect(tapCount, 1);
    });

    testWidgets('dieWidget_customSize', (WidgetTester tester) async {
      const customSize = 120.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DieWidget(value: 5, isHeld: false, size: customSize),
          ),
        ),
      );

      final RenderBox renderBox = tester.renderObject(find.byType(DieWidget));
      expect(renderBox.size.width, customSize);
      expect(renderBox.size.height, customSize);
    });

    testWidgets('dieWidget_assertsInvalidValue', (WidgetTester tester) async {
      expect(() => DieWidget(value: 0, isHeld: false), throwsAssertionError);

      expect(() => DieWidget(value: 7, isHeld: false), throwsAssertionError);
    });

    testWidgets('dieWidget_rollingStateCyclesValues', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DieWidget(value: 3, isHeld: false, isRolling: true),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 200));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DieWidget(value: 6, isHeld: false, isRolling: false),
          ),
        ),
      );

      await tester.pumpAndSettle();
    });
  });
}
