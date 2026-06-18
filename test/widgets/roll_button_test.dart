import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/roll_button.dart';

void main() {
  group('RollButton', () {
    testWidgets('renders with default label Roll', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RollButton())));

      expect(find.text('Roll'), findsOneWidget);
    });

    testWidgets('renders with custom label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const RollButton(label: 'Throw')),
        ),
      );

      expect(find.text('Throw'), findsOneWidget);
    });

    testWidgets('shows default rolls remaining of 3', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RollButton())));

      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows custom rolls remaining', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const RollButton(rollsRemaining: 1))),
      );

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows 0 rolls remaining', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const RollButton(rollsRemaining: 0))),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('invokes onPressed when tapped with rolls remaining', (
      tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RollButton(
              rollsRemaining: 2,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('does not invoke onPressed when rolls = 0', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RollButton(
              rollsRemaining: 0,
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      // Button should be disabled (no tap possible)
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
      expect(pressed, isFalse);
    });

    testWidgets('does not invoke onPressed when onPressed is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const RollButton(rollsRemaining: 2))),
      );

      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    });

    testWidgets('shows dice icon', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: RollButton())));

      expect(find.byIcon(Icons.casino), findsOneWidget);
    });

    testWidgets('badge shows correct number for each roll count', (
      tester,
    ) async {
      for (int rolls in [0, 1, 2, 3]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RollButton(
                rollsRemaining: rolls,
                onPressed: rolls > 0 ? () {} : null,
              ),
            ),
          ),
        );

        expect(find.text('$rolls'), findsOneWidget);
      }
    });

    testWidgets('button is enabled when rolls > 0 and onPressed is not null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RollButton(rollsRemaining: 3, onPressed: () {})),
        ),
      );

      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
    });

    testWidgets('button is disabled when rolls = 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const RollButton(rollsRemaining: 0))),
      );

      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    });

    testWidgets('supports const constructor', (tester) async {
      const RollButton button = RollButton(rollsRemaining: 2, label: 'Roll');
      expect(button.rollsRemaining, 2);
      expect(button.label, 'Roll');
      expect(button.onPressed, isNull);
    });

    testWidgets('default values are correct', (tester) async {
      const RollButton button = RollButton();
      expect(button.rollsRemaining, 3);
      expect(button.label, 'Roll');
      expect(button.onPressed, isNull);
    });

    testWidgets('badge container has rounded corners', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RollButton(rollsRemaining: 2, onPressed: () {})),
        ),
      );

      // Find the badge container (it's a Container with the rolls number)
      final containerFinder = find.byType(Container);
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, isNotNull);
    });
  });
}
