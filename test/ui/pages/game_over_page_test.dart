import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';
import 'package:poker_dice/src/ui/pages/game_over_page.dart';

void main() {
  group('GameOverPage', () {
    late ScoreSheet testScoreSheet;

    setUp(() {
      // Create a test score sheet with all categories scored
      testScoreSheet = ScoreSheet();

      // Score upper section
      testScoreSheet.scores[ScoreCategory.aces] = 5;
      testScoreSheet.scores[ScoreCategory.twos] = 10;
      testScoreSheet.scores[ScoreCategory.threes] = 15;
      testScoreSheet.scores[ScoreCategory.fours] = 20;
      testScoreSheet.scores[ScoreCategory.fives] = 25;
      testScoreSheet.scores[ScoreCategory.sixes] = 30;

      // Score lower section
      testScoreSheet.scores[ScoreCategory.threeOfKind] = 25;
      testScoreSheet.scores[ScoreCategory.fourOfKind] = 30;
      testScoreSheet.scores[ScoreCategory.fullHouse] = 25;
      testScoreSheet.scores[ScoreCategory.smallStraight] = 30;
      testScoreSheet.scores[ScoreCategory.largeStraight] = 40;
      testScoreSheet.scores[ScoreCategory.yatzy] = 50;
      testScoreSheet.scores[ScoreCategory.chance] = 20;
    });

    Widget createGameOverPage({
      ScoreSheet? scoreSheet,
      VoidCallback? onNewGame,
      VoidCallback? onViewHighScores,
    }) {
      return MaterialApp(
        home: GameOverPage(
          scoreSheet: scoreSheet ?? testScoreSheet,
          onNewGame: onNewGame,
          onViewHighScores: onViewHighScores,
        ),
      );
    }

    testWidgets('renders scaffold with Game Over title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createGameOverPage());

      expect(find.text('Game Over'), findsOneWidget);
    });

    testWidgets('renders game over header with trophy icon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createGameOverPage());

      expect(find.text('Game Over!'), findsOneWidget);
      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('renders final score display', (WidgetTester tester) async {
      await tester.pumpWidget(createGameOverPage());
      await tester.pump(); // Allow animations to complete

      // Total should be: 105 (upper) + 220 (lower) + 35 (bonus) = 360
      expect(find.text('Final Score'), findsOneWidget);
      expect(find.textContaining('360'), findsWidgets);
    });

    testWidgets('renders score breakdown (upper, lower, bonus)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createGameOverPage());
      await tester.pump(); // Allow animations to complete

      expect(find.text('Score Breakdown'), findsOneWidget);
      expect(find.text('Upper Total'), findsOneWidget);
      expect(find.text('Lower Total'), findsOneWidget);
      expect(find.text('Bonus'), findsOneWidget);
      expect(find.textContaining('105'), findsWidgets); // Upper total
      expect(find.textContaining('220'), findsWidgets); // Lower total
      expect(find.textContaining('+35'), findsOneWidget); // Bonus
    });

    testWidgets('renders category score summary', (WidgetTester tester) async {
      await tester.pumpWidget(createGameOverPage());

      expect(find.text('Category Results'), findsOneWidget);
      expect(find.text('Upper Section'), findsOneWidget);
      expect(find.text('Lower Section'), findsOneWidget);

      // Check for category names
      expect(find.text('Aces'), findsOneWidget);
      expect(find.text('Twos'), findsOneWidget);
      expect(find.text('Threes'), findsOneWidget);
      expect(find.text('Fours'), findsOneWidget);
      expect(find.text('Fives'), findsOneWidget);
      expect(find.text('Sixes'), findsOneWidget);
      expect(find.text('Three of a Kind'), findsOneWidget);
      expect(find.text('Four of a Kind'), findsOneWidget);
      expect(find.text('Full House'), findsOneWidget);
      expect(find.text('Small Straight'), findsOneWidget);
      expect(find.text('Large Straight'), findsOneWidget);
      expect(find.text('Yatzy'), findsOneWidget);
      expect(find.text('Chance'), findsOneWidget);
    });

    testWidgets('renders New Game button', (WidgetTester tester) async {
      await tester.pumpWidget(createGameOverPage());

      expect(find.text('New Game'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders View High Scores button', (WidgetTester tester) async {
      await tester.pumpWidget(createGameOverPage());

      expect(find.text('View High Scores'), findsOneWidget);
      expect(find.byIcon(Icons.leaderboard), findsOneWidget);
    });

    testWidgets('New Game callback is called when pressed', (
      WidgetTester tester,
    ) async {
      bool newGameCalled = false;

      await tester.pumpWidget(
        createGameOverPage(
          onNewGame: () {
            newGameCalled = true;
          },
        ),
      );
      await tester.pump();

      // Scroll to make button visible
      await tester.scrollUntilVisible(find.text('New Game'), -200);
      await tester.pump();

      await tester.tap(find.text('New Game'));
      await tester.pump();

      expect(newGameCalled, isTrue);
    });

    testWidgets('View High Scores callback is called when pressed', (
      WidgetTester tester,
    ) async {
      bool highScoresCalled = false;

      await tester.pumpWidget(
        createGameOverPage(
          onViewHighScores: () {
            highScoresCalled = true;
          },
        ),
      );
      await tester.pump();

      // Scroll to make button visible
      await tester.scrollUntilVisible(find.text('View High Scores'), -200);
      await tester.pump();

      await tester.tap(find.text('View High Scores'));
      await tester.pump();

      expect(highScoresCalled, isTrue);
    });

    testWidgets('has accessibility labels for buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createGameOverPage());

      // Check for semantics labels
      final newGameSemantics = find.bySemanticsLabel('Start a new game');
      final highScoresSemantics = find.bySemanticsLabel(
        'View high scores leaderboard',
      );

      expect(newGameSemantics, findsOneWidget);
      expect(highScoresSemantics, findsOneWidget);
    });

    testWidgets('displays bonus only when upper total >= 63', (
      WidgetTester tester,
    ) async {
      // Create score sheet without bonus (upper total < 63)
      final noBonusSheet = ScoreSheet();
      noBonusSheet.scores[ScoreCategory.aces] = 5;
      noBonusSheet.scores[ScoreCategory.twos] = 10;
      noBonusSheet.scores[ScoreCategory.threes] = 15;
      noBonusSheet.scores[ScoreCategory.fours] = 20;
      noBonusSheet.scores[ScoreCategory.fives] = 0;
      noBonusSheet.scores[ScoreCategory.sixes] = 0;
      // Upper total = 50, no bonus

      noBonusSheet.scores[ScoreCategory.threeOfKind] = 25;
      noBonusSheet.scores[ScoreCategory.fourOfKind] = 30;
      noBonusSheet.scores[ScoreCategory.fullHouse] = 25;
      noBonusSheet.scores[ScoreCategory.smallStraight] = 30;
      noBonusSheet.scores[ScoreCategory.largeStraight] = 40;
      noBonusSheet.scores[ScoreCategory.yatzy] = 50;
      noBonusSheet.scores[ScoreCategory.chance] = 20;

      await tester.pumpWidget(createGameOverPage(scoreSheet: noBonusSheet));

      expect(find.text('Bonus'), findsNothing);
      expect(find.text('+35'), findsNothing);
    });

    testWidgets('displays zero scores for lower section categories', (
      WidgetTester tester,
    ) async {
      // Create score sheet with some zero scores
      final zeroScoreSheet = ScoreSheet();

      // Upper section with bonus
      zeroScoreSheet.scores[ScoreCategory.aces] = 5;
      zeroScoreSheet.scores[ScoreCategory.twos] = 10;
      zeroScoreSheet.scores[ScoreCategory.threes] = 15;
      zeroScoreSheet.scores[ScoreCategory.fours] = 20;
      zeroScoreSheet.scores[ScoreCategory.fives] = 25;
      zeroScoreSheet.scores[ScoreCategory.sixes] = 30;

      // Lower section with zeros
      zeroScoreSheet.scores[ScoreCategory.threeOfKind] = 0;
      zeroScoreSheet.scores[ScoreCategory.fourOfKind] = 0;
      zeroScoreSheet.scores[ScoreCategory.fullHouse] = 0;
      zeroScoreSheet.scores[ScoreCategory.smallStraight] = 0;
      zeroScoreSheet.scores[ScoreCategory.largeStraight] = 0;
      zeroScoreSheet.scores[ScoreCategory.yatzy] = 0;
      zeroScoreSheet.scores[ScoreCategory.chance] = 0;

      await tester.pumpWidget(createGameOverPage(scoreSheet: zeroScoreSheet));

      // Should display zeros for categories
      expect(find.text('0'), findsWidgets);
    });
  });
}
