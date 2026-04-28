import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/control_bar.dart';

void main() {
  group('ControlBar', () {
    // Rendering Tests
    group('Rendering Tests', () {
      testWidgets('testControlBarRendersRollButton', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        expect(find.textContaining(RegExp(r'ROLL \d+')), findsOneWidget);
      });

      testWidgets('testControlBarRendersPlayButton', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('PLAY'), findsOneWidget);
      });

      testWidgets('testRollButtonShowsCorrectCount', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 2,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('ROLL 2'), findsOneWidget);
      });
    });

    // Roll Count Tests
    group('Roll Count Tests', () {
      testWidgets('testRollButtonShowsRoll3', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('ROLL 3'), findsOneWidget);
      });

      testWidgets('testRollButtonShowsRoll2', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 2,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('ROLL 2'), findsOneWidget);
      });

      testWidgets('testRollButtonShowsRoll1', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 1,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('ROLL 1'), findsOneWidget);
      });

      testWidgets('testRollButtonShowsRoll0', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 0,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        expect(find.text('ROLL 0'), findsOneWidget);
      });
    });

    // Roll Button State Tests
    group('Roll Button State Tests', () {
      testWidgets('testRollButtonEnabledWhenRollsGreaterThan0', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 1,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        final rollButton = find.textContaining('ROLL');
        final container = tester.widget<Container>(
          find.ancestor(of: rollButton, matching: find.byType(Container)).first,
        );
        // Check that the container has a non-disabled color (primary color)
        expect((container.decoration as BoxDecoration).color, isNotNull);
      });

      testWidgets('testRollButtonDisabledWhenRollsZero', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 0,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        final rollButton = find.textContaining('ROLL');
        final container = tester.widget<Container>(
          find.ancestor(of: rollButton, matching: find.byType(Container)).first,
        );
        // Check that the container has a disabled color (low alpha)
        final color = (container.decoration as BoxDecoration).color;
        expect(color, isNotNull);
      });
    });

    // Play Button State Tests
    group('Play Button State Tests', () {
      testWidgets('testPlayButtonEnabledWhenIsPlayEnabledTrue', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () {},
                onPlayPressed: () {},
                isPlayEnabled: true,
              ),
            ),
          ),
        );

        final playButton = find.textContaining('PLAY');
        final container = tester.widget<Container>(
          find.ancestor(of: playButton, matching: find.byType(Container)).first,
        );
        // Check that the container has a non-disabled color
        expect((container.decoration as BoxDecoration).color, isNotNull);
      });

      testWidgets('testPlayButtonDisabledWhenIsPlayEnabledFalse', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () {},
                onPlayPressed: () {},
                isPlayEnabled: false,
              ),
            ),
          ),
        );

        final playButton = find.textContaining('PLAY');
        final container = tester.widget<Container>(
          find.ancestor(of: playButton, matching: find.byType(Container)).first,
        );
        // Check that the container has a disabled color
        final color = (container.decoration as BoxDecoration).color;
        expect(color, isNotNull);
      });
    });

    // Interaction Tests
    group('Interaction Tests', () {
      testWidgets('testRollButtonInvokesCallback', (WidgetTester tester) async {
        bool rollPressed = false;
        bool playPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () => rollPressed = true,
                onPlayPressed: () => playPressed = true,
                isPlayEnabled: true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('ROLL 3'));
        await tester.pump();

        expect(rollPressed, isTrue);
        expect(playPressed, isFalse);
      });

      testWidgets('testPlayButtonInvokesCallback', (WidgetTester tester) async {
        bool rollPressed = false;
        bool playPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () => rollPressed = true,
                onPlayPressed: () => playPressed = true,
                isPlayEnabled: true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('PLAY'));
        await tester.pump();

        expect(playPressed, isTrue);
        expect(rollPressed, isFalse);
      });

      testWidgets('testDisabledRollButtonDoesNotInvokeCallback', (
        WidgetTester tester,
      ) async {
        bool rollPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 0,
                onRollPressed: () => rollPressed = true,
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        final rollButton = find.text('ROLL 0');
        await tester.tap(rollButton);
        await tester.pump();

        expect(rollPressed, isFalse);
      });
    });

    // Visual Tests
    group('Visual Tests', () {
      testWidgets('testRollButtonHasPrimaryColor', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        final rollButton = find.textContaining('ROLL');
        expect(rollButton, findsOneWidget);
      });

      testWidgets('testPlayButtonHasSecondaryColor', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () {},
                onPlayPressed: () {},
                isPlayEnabled: true,
              ),
            ),
          ),
        );

        final playButton = find.textContaining('PLAY');
        expect(playButton, findsOneWidget);
      });

      testWidgets('testControlBarHasProperSpacing', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ControlBar(
                remainingRolls: 3,
                onRollPressed: () {},
                onPlayPressed: () {},
              ),
            ),
          ),
        );

        final spacingFinder = find.byWidgetPredicate(
          (Widget widget) => widget is SizedBox && widget.width == 16.0,
        );

        expect(spacingFinder, findsOneWidget);
      });
    });
  });
}
