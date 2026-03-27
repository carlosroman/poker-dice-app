import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/ui/widgets/game_controls.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(body: child),
  );
}

void main() {
  group('GameControls', () {
    group('Roll button disabled when no rolls remaining', () {
      testWidgets('rollsRemaining=0 shows disabled button', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 0,
              isTurnActive: true,
              isGameOver: false,
            ),
          ),
        );

        final rollButton = find.byType(ElevatedButton);
        expect(rollButton, findsOneWidget);

        final button = tester.widget<ElevatedButton>(rollButton);
        expect(button.onPressed, isNull, reason: 'Button should be disabled');
      });

      testWidgets('rollsRemaining>0 shows enabled button', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 3,
              isTurnActive: true,
              isGameOver: false,
              onRoll: () {},
            ),
          ),
        );

        final rollButton = find.byType(ElevatedButton);
        expect(rollButton, findsOneWidget);

        final button = tester.widget<ElevatedButton>(rollButton);
        expect(button.onPressed, isNotNull, reason: 'Button should be enabled');
      });

      testWidgets('isTurnActive=false shows disabled button', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 3,
              isTurnActive: false,
              isGameOver: false,
            ),
          ),
        );

        final rollButton = find.byType(ElevatedButton);
        expect(rollButton, findsOneWidget);

        final button = tester.widget<ElevatedButton>(rollButton);
        expect(button.onPressed, isNull, reason: 'Button should be disabled');
      });
    });

    group('Roll button displays rolls remaining', () {
      testWidgets('rollsRemaining=3 shows ROLL with badge', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 3,
              isTurnActive: true,
              isGameOver: false,
            ),
          ),
        );

        expect(find.text('ROLL'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      });

      testWidgets('rollsRemaining=2 shows ROLL with badge', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 2,
              isTurnActive: true,
              isGameOver: false,
            ),
          ),
        );

        expect(find.text('ROLL'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);
      });

      testWidgets('rollsRemaining=1 shows ROLL with badge', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 1,
              isTurnActive: true,
              isGameOver: false,
            ),
          ),
        );

        expect(find.text('ROLL'), findsOneWidget);
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('rollsRemaining=0 shows disabled ROLL with badge', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 0,
              isTurnActive: true,
              isGameOver: false,
            ),
          ),
        );

        expect(find.text('ROLL'), findsOneWidget);
        expect(find.text('0'), findsOneWidget);
      });
    });

    group('New game button', () {
      testWidgets('isGameOver=false shows disabled new game button', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 3,
              isTurnActive: true,
              isGameOver: false,
            ),
          ),
        );

        final newGameButton = find.byType(OutlinedButton);
        expect(newGameButton, findsOneWidget);

        final button = tester.widget<OutlinedButton>(newGameButton);
        expect(
          button.onPressed,
          isNull,
          reason: 'New game button should be disabled when game is not over',
        );
      });

      testWidgets('isGameOver=true shows enabled new game button', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 3,
              isTurnActive: true,
              isGameOver: true,
              onNewGame: () {},
            ),
          ),
        );

        final newGameButton = find.byType(OutlinedButton);
        expect(newGameButton, findsOneWidget);

        final button = tester.widget<OutlinedButton>(newGameButton);
        expect(
          button.onPressed,
          isNotNull,
          reason: 'New game button should be enabled when game is over',
        );
      });

      testWidgets('tap on new game triggers callback', (
        WidgetTester tester,
      ) async {
        bool newGameTriggered = false;

        await tester.pumpWidget(
          createTestApp(
            GameControls(
              rollsRemaining: 3,
              isTurnActive: true,
              isGameOver: true,
              onNewGame: () {
                newGameTriggered = true;
              },
            ),
          ),
        );

        expect(newGameTriggered, isFalse);

        await tester.tap(find.byType(OutlinedButton));
        await tester.pump();

        expect(newGameTriggered, isTrue);
      });
    });
  });
}
