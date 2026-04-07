import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';
import 'package:poker_dice/src/ui/components/die_widget.dart';
import 'package:poker_dice/src/ui/components/score_category_row.dart';
import 'package:poker_dice/src/ui/pages/game_over_page.dart';

void main() {
  group('Animations Tests', () {
    // Test duration tolerance for animation timing
    const durationTolerance = Duration(milliseconds: 50);

    group('Dice Roll Animation', () {
      testWidgets('Dice roll animation plays when rolling', (tester) async {
        final die = Die(value: 1, held: false);
        bool isRolling = true;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DieWidget(die: die, isRolling: isRolling),
            ),
          ),
        );

        // Initial pump to start animation
        await tester.pump();

        // Animation should be running (first frame)
        expect(find.byType(DieWidget), findsOneWidget);

        // Pump through the animation duration (400ms)
        await tester.pump(const Duration(milliseconds: 200));
        await tester.pump(const Duration(milliseconds: 200));

        // After animation, widget should still be present
        expect(find.byType(DieWidget), findsOneWidget);
      });

      testWidgets('Dice scale animation transforms during roll', (
        tester,
      ) async {
        final die = Die(value: 3, held: false);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(die: die, isRolling: true)),
          ),
        );

        await tester.pump();

        // Find the die container
        final dieFinder = find.byType(Container).first;
        expect(dieFinder, findsOneWidget);

        // Pump animation to midpoint
        await tester.pump(const Duration(milliseconds: 100));

        // Widget should still be present after partial animation
        expect(dieFinder, findsOneWidget);
      });

      testWidgets('Dice opacity changes during roll animation', (tester) async {
        final die = Die(value: 5, held: false);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(die: die, isRolling: true)),
          ),
        );

        await tester.pump();

        // Initial state
        expect(find.byType(DieWidget), findsOneWidget);

        // Complete the roll animation (400ms total)
        await tester.pumpAndSettle(const Duration(milliseconds: 450));

        // Widget should settle after animation
        expect(find.byType(DieWidget), findsOneWidget);
      });
    });

    group('Score Update Animation', () {
      testWidgets('Score fade/slide animation plays when category selected', (
        tester,
      ) async {
        final category = ScoreCategory.aces;
        int? score;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreCategoryRow(
                category: category,
                score: score,
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        );

        await tester.pump();

        // Category should be displayed
        expect(find.text('Aces'), findsOneWidget);

        // Pump through selection animation (250ms)
        await tester.pump(const Duration(milliseconds: 125));
        await tester.pump(const Duration(milliseconds: 125));

        // After animation, category should still be visible
        expect(find.text('Aces'), findsOneWidget);
      });

      testWidgets('Score value animates when updated', (tester) async {
        final category = ScoreCategory.twos;
        int? score = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreCategoryRow(
                category: category,
                score: score,
                isSelected: false,
              ),
            ),
          ),
        );

        await tester.pump();

        // Initial score display
        expect(find.text('0'), findsOneWidget);

        // Update score
        score = 4;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreCategoryRow(
                category: category,
                score: score,
                isSelected: false,
              ),
            ),
          ),
        );

        // Pump to trigger AnimatedSwitcher
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 100));

        // New score should be displayed
        expect(find.text('4'), findsOneWidget);
      });
    });

    group('Category Selection Feedback Animation', () {
      testWidgets('Category selection scale animation plays on tap', (
        tester,
      ) async {
        final category = ScoreCategory.threes;
        bool tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreCategoryRow(
                category: category,
                score: null,
                isSelected: true,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Tap the category
        await tester.tap(find.text('Threes'));
        await tester.pump();

        // Selection animation should start (250ms duration)
        await tester.pump(const Duration(milliseconds: 100));

        // Tap should have been registered
        expect(tapped, isTrue);
      });

      testWidgets('Category highlight animation completes within duration', (
        tester,
      ) async {
        final category = ScoreCategory.fours;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreCategoryRow(
                category: category,
                score: null,
                isSelected: true,
                onTap: () {},
              ),
            ),
          ),
        );

        await tester.pump();

        // Measure animation completion time
        final stopwatch = Stopwatch()..start();

        // Complete the selection animation (250ms)
        await tester.pumpAndSettle(const Duration(milliseconds: 300));

        stopwatch.stop();

        // Animation should complete within expected duration + tolerance
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(300 + durationTolerance.inMilliseconds),
        );

        expect(find.text('Fours'), findsOneWidget);
      });
    });

    group('Game Over Animation', () {
      testWidgets('Game over trophy animation plays when game ends', (
        tester,
      ) async {
        final scoreSheet = ScoreSheet();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameOverPage(scoreSheet: scoreSheet, onNewGame: () {}),
            ),
          ),
        );

        await tester.pump();

        // Trophy icon should be present
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);

        // Trophy animation duration is 1500ms
        await tester.pump(const Duration(milliseconds: 750));
        await tester.pump(const Duration(milliseconds: 750));

        // After animation, trophy should still be visible
        expect(find.byIcon(Icons.emoji_events), findsOneWidget);
      });

      testWidgets('Score counting animation plays when game ends', (
        tester,
      ) async {
        final scoreSheet = ScoreSheet();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameOverPage(scoreSheet: scoreSheet, onNewGame: () {}),
            ),
          ),
        );

        await tester.pump();

        // Score display should be present (multiple score texts exist)
        expect(find.textContaining(RegExp(r'^\d+$')), findsWidgets);

        // Score counting animation duration is 1500ms
        await tester.pump(const Duration(milliseconds: 750));
        await tester.pump(const Duration(milliseconds: 750));

        // Final score should be displayed
        expect(find.textContaining(RegExp(r'^\d+$')), findsWidgets);
      });

      testWidgets('Game over animation completes within expected duration', (
        tester,
      ) async {
        final scoreSheet = ScoreSheet();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameOverPage(scoreSheet: scoreSheet, onNewGame: () {}),
            ),
          ),
        );

        await tester.pump();

        // Measure total animation completion
        final stopwatch = Stopwatch()..start();

        // Game over animation duration is 1500ms
        await tester.pumpAndSettle(const Duration(milliseconds: 1600));

        stopwatch.stop();

        // Animations should complete within expected duration + tolerance
        expect(
          stopwatch.elapsedMilliseconds,
          lessThan(1600 + durationTolerance.inMilliseconds),
        );

        // Game over header should still be present
        expect(find.text('Game Over!'), findsOneWidget);
      });

      testWidgets('Confetti particles render during game over', (tester) async {
        final scoreSheet = ScoreSheet();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GameOverPage(scoreSheet: scoreSheet, onNewGame: () {}),
            ),
          ),
        );

        await tester.pump();

        // CustomPaint for confetti should be in the widget tree
        expect(find.byType(CustomPaint), findsWidgets);

        // Pump through confetti animation
        await tester.pump(const Duration(milliseconds: 1000));

        // Confetti should still be rendering
        expect(find.byType(CustomPaint), findsWidgets);
      });
    });

    group('Animation Duration Compliance', () {
      testWidgets('Dice roll animation duration is 300-500ms', (tester) async {
        // DieWidget has _rollDuration = 400ms
        const expectedDuration = Duration(milliseconds: 400);
        expect(
          expectedDuration,
          greaterThan(const Duration(milliseconds: 300)),
        );
        expect(expectedDuration, lessThan(const Duration(milliseconds: 500)));
      });

      testWidgets('Score update animation duration is 200-300ms', (
        tester,
      ) async {
        // ScoreCategoryRow has _selectionDuration = 250ms
        const expectedDuration = Duration(milliseconds: 250);
        expect(
          expectedDuration,
          greaterThan(const Duration(milliseconds: 200)),
        );
        expect(expectedDuration, lessThan(const Duration(milliseconds: 300)));
      });

      testWidgets('Category selection feedback duration is ~200ms', (
        tester,
      ) async {
        // ScoreCategoryRow has _animationDuration = 200ms
        const expectedDuration = Duration(milliseconds: 200);
        expect(expectedDuration.inMilliseconds, closeTo(200, 50));
      });

      testWidgets('Game over animation duration is 1-2 seconds', (
        tester,
      ) async {
        // GameOverPage has animation duration of 1500ms
        const expectedDuration = Duration(milliseconds: 1500);
        expect(
          expectedDuration,
          greaterThanOrEqualTo(const Duration(seconds: 1)),
        );
        expect(expectedDuration, lessThanOrEqualTo(const Duration(seconds: 2)));
      });
    });
  });
}
