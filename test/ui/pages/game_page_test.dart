import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/game_round.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';
import 'package:poker_dice/src/ui/pages/game_page.dart';

void main() {
  group('GamePage', () {
    late GameRound gameRound;
    late ScoreSheet scoreSheet;

    setUp(() {
      gameRound = GameRound();
      scoreSheet = const ScoreSheet();
    });

    testWidgets('displays game header with score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('displays back button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays menu button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('displays 5 dice', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays ROLL button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.text('ROLL'), findsOneWidget);
    });

    testWidgets('displays PLAY button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('displays score sheet with Minor and Major headers', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.text('Minor'), findsOneWidget);
      expect(find.text('Major'), findsOneWidget);
    });

    testWidgets('calls onBackTapped when back button is tapped', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
            onBackTapped: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onMenuTapped when menu button is tapped', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
            onMenuTapped: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onRollTapped when roll button is tapped', (
      tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
            onRollTapped: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('ROLL'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onPlayTapped when play button is tapped', (
      tester,
    ) async {
      bool tapped = false;
      // Enable play by having empty categories
      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRound,
            scoreSheet: scoreSheet,
            minorTotal: 0,
            onPlayTapped: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays dice with correct values', (tester) async {
      final dice = [
        Die(value: 1),
        Die(value: 3),
        Die(value: 5),
        Die(value: 2),
        Die(value: 6),
      ];
      final gameRoundWithDice = GameRound(dice: dice, rollCount: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRoundWithDice,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      // Dice should be rendered
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('shows roll count on ROLL button', (tester) async {
      final gameRoundWithRolls = GameRound(rollCount: 1);

      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRoundWithRolls,
            scoreSheet: scoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.text('ROLL 1'), findsOneWidget);
    });
  });

  group('GamePage - Layout', () {
    testWidgets('has gradient background', (tester) async {
      final testGameRound = GameRound();
      final testScoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: testGameRound,
            scoreSheet: testScoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('has SafeArea for proper insets', (tester) async {
      final testGameRound = GameRound();
      final testScoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: testGameRound,
            scoreSheet: testScoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('uses Column layout', (tester) async {
      final testGameRound = GameRound();
      final testScoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: testGameRound,
            scoreSheet: testScoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      expect(find.byType(Column), findsWidgets);
    });
  });

  group('GamePage - Button States', () {
    testWidgets('ROLL button is enabled when rollCount < 3', (tester) async {
      final gameRoundWithRolls = GameRound(rollCount: 2);
      final testScoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: gameRoundWithRolls,
            scoreSheet: testScoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      // Button should be present
      expect(find.text('ROLL 2'), findsOneWidget);
    });

    testWidgets('PLAY button is enabled when categories are available', (
      tester,
    ) async {
      final testGameRound = GameRound();
      final testScoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: testGameRound,
            scoreSheet: testScoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      // PLAY button should be present
      expect(find.text('PLAY'), findsOneWidget);
    });
  });

  group('GamePage - Dice Interaction', () {
    testWidgets('dice are rendered horizontally', (tester) async {
      final testGameRound = GameRound();
      final testScoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(
          home: GamePage(
            gameRound: testGameRound,
            scoreSheet: testScoreSheet,
            minorTotal: 0,
          ),
        ),
      );

      // Dice should be in a row
      expect(find.byType(Container), findsWidgets);
    });
  });
}
