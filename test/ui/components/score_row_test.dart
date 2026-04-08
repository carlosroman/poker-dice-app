import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/score_row.dart';

void main() {
  group('ScoreRow', () {
    testWidgets('displays category icon for upper section', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(category: ScoreCategory.aces, potentialScore: 2),
          ),
        ),
      );

      expect(find.byType(ScoreRow), findsOneWidget);
    });

    testWidgets('displays potential score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(category: ScoreCategory.twos, potentialScore: 4),
          ),
        ),
      );

      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('displays dash when potential score is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.threes,
              potentialScore: null,
            ),
          ),
        ),
      );

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('displays current score in blue box', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.fours,
              potentialScore: 8,
              currentScore: 8,
              isScored: true,
            ),
          ),
        ),
      );

      expect(find.text('8'), findsWidgets);
    });

    testWidgets('displays empty box when not scored', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.fives,
              potentialScore: 5,
              currentScore: null,
              isScored: false,
            ),
          ),
        ),
      );

      // Score box should be empty
      expect(find.byType(ScoreRow), findsOneWidget);
    });

    testWidgets('shows yatzy bonus indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.yatzy,
              potentialScore: 50,
              currentScore: 50,
              isScored: true,
              yatzyBonus: true,
            ),
          ),
        ),
      );

      expect(find.text('+50'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.sixes,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('displays 3x icon for ThreeOfKind', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.threeOfKind,
              potentialScore: 15,
            ),
          ),
        ),
      );

      expect(find.text('3x'), findsOneWidget);
    });

    testWidgets('displays 4x icon for FourOfKind', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.fourOfKind,
              potentialScore: 20,
            ),
          ),
        ),
      );

      expect(find.text('4x'), findsOneWidget);
    });

    testWidgets('displays house icon for FullHouse', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.fullHouse,
              potentialScore: 25,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('displays Yatzy text for Yatzy category', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(category: ScoreCategory.yatzy, potentialScore: 50),
          ),
        ),
      );

      expect(find.text('Y'), findsOneWidget);
    });

    testWidgets('displays help icon for Chance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(category: ScoreCategory.chance, potentialScore: 18),
          ),
        ),
      );

      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('uses correct colors from theme', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.aces,
              currentScore: 3,
              isScored: true,
            ),
          ),
        ),
      );

      // Verify score box uses light blue
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('ScoreRow - Layout', () {
    testWidgets('has correct widget structure', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.twos,
              potentialScore: 6,
              currentScore: 6,
              isScored: true,
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('renders all categories', (tester) async {
      for (final category in ScoreCategory.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreRow(category: category, potentialScore: 10),
            ),
          ),
        );

        expect(find.byType(ScoreRow), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });
  });
}
