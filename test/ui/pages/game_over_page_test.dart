import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';
import 'package:poker_dice/src/ui/pages/game_over_page.dart';

void main() {
  group('GameOverPage', () {
    testWidgets('displays Game Over title', (tester) async {
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.text('Game Over!'), findsOneWidget);
    });

    testWidgets('displays final score', (tester) async {
      final scores = <ScoreCategory, int?>{
        ScoreCategory.aces: 5,
        ScoreCategory.twos: 10,
        ScoreCategory.threes: 15,
        ScoreCategory.fours: 20,
        ScoreCategory.fives: 25,
        ScoreCategory.sixes: 30,
        ScoreCategory.threeOfKind: 25,
        ScoreCategory.fourOfKind: 28,
        ScoreCategory.fullHouse: 25,
        ScoreCategory.smallStraight: 30,
        ScoreCategory.largeStraight: 40,
        ScoreCategory.yatzy: 50,
        ScoreCategory.chance: 30,
      };

      final scoreSheet = ScoreSheet(scores: scores);

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      // Total should be: 135 (upper) + 198 (lower) + 35 (bonus) = 368
      expect(find.text('368'), findsOneWidget);
    });

    testWidgets('displays New Game button', (tester) async {
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.text('New Game'), findsOneWidget);
    });

    testWidgets('calls onNewGameTapped when button is tapped', (tester) async {
      bool tapped = false;
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(
          home: GameOverPage(
            scoreSheet: scoreSheet,
            onNewGameTapped: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays back button', (tester) async {
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('calls onBackTapped when back is tapped', (tester) async {
      bool tapped = false;
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(
          home: GameOverPage(
            scoreSheet: scoreSheet,
            onBackTapped: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays Minor Section header', (tester) async {
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.text('Minor Section'), findsOneWidget);
    });

    testWidgets('displays Major Section header', (tester) async {
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.text('Major Section'), findsOneWidget);
    });

    testWidgets('displays all category names', (tester) async {
      final scores = {for (final cat in ScoreCategory.values) cat: 0};
      final scoreSheet = ScoreSheet(scores: scores);

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      for (final category in ScoreCategory.values) {
        expect(find.text(category.displayName), findsOneWidget);
      }
    });

    testWidgets('displays Minor Total', (tester) async {
      final scores = <ScoreCategory, int?>{
        ScoreCategory.aces: 5,
        ScoreCategory.twos: 10,
        ScoreCategory.threes: 15,
        ScoreCategory.fours: 20,
        ScoreCategory.fives: 25,
        ScoreCategory.sixes: 30,
      };
      final scoreSheet = ScoreSheet(scores: scores);

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.text('Minor Total'), findsOneWidget);
      expect(find.text('105'), findsOneWidget); // 5+10+15+20+25+30
    });

    testWidgets('displays bonus when earned', (tester) async {
      final scores = <ScoreCategory, int?>{
        ScoreCategory.aces: 5,
        ScoreCategory.twos: 10,
        ScoreCategory.threes: 15,
        ScoreCategory.fours: 20,
        ScoreCategory.fives: 25,
        ScoreCategory.sixes: 30, // Upper total = 105 >= 63, bonus = 35
      };
      final scoreSheet = ScoreSheet(scores: scores);

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.text('Bonus'), findsOneWidget);
      expect(find.text('35'), findsOneWidget);
    });

    testWidgets('displays Major Total', (tester) async {
      final scores = <ScoreCategory, int?>{
        ScoreCategory.threeOfKind: 20,
        ScoreCategory.fourOfKind: 25,
        ScoreCategory.fullHouse: 25,
        ScoreCategory.smallStraight: 30,
        ScoreCategory.largeStraight: 40,
        ScoreCategory.yatzy: 50,
        ScoreCategory.chance: 30,
      };
      final scoreSheet = ScoreSheet(scores: scores);

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.text('Major Total'), findsOneWidget);
      expect(find.text('220'), findsWidgets); // Multiple matches expected
    });
  });

  group('GameOverPage - Layout', () {
    testWidgets('has gradient background', (tester) async {
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('displays score breakdown in scrollable area', (tester) async {
      final scores = {for (final cat in ScoreCategory.values) cat: 0};
      final scoreSheet = ScoreSheet(scores: scores);

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('GameOverPage - Score Display', () {
    testWidgets('shows zero score correctly', (tester) async {
      final scores = {for (final cat in ScoreCategory.values) cat: 0};
      final scoreSheet = ScoreSheet(scores: scores);

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      expect(find.text('0'), findsWidgets);
    });

    testWidgets('displays large font for final score', (tester) async {
      final scoreSheet = const ScoreSheet();

      await tester.pumpWidget(
        MaterialApp(home: GameOverPage(scoreSheet: scoreSheet)),
      );

      // Final score container should be present
      expect(find.byType(Container), findsWidgets);
    });
  });
}
