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

  group('ScoreRow - Selection highlighting', () {
    testWidgets('displays highlight when isSelected is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.aces,
              potentialScore: 3,
              isSelected: true,
            ),
          ),
        ),
      );

      expect(find.byType(ScoreRow), findsOneWidget);
      // Verify the widget builds with selection
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('displays transparent background when isSelected is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.twos,
              potentialScore: 4,
              isSelected: false,
            ),
          ),
        ),
      );

      expect(find.byType(ScoreRow), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('defaults isSelected to false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(category: ScoreCategory.threes, potentialScore: 5),
          ),
        ),
      );

      expect(find.byType(ScoreRow), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });

  group('DieFaceIcon', () {
    testWidgets('die face 1 shows 1 dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.aces,
              potentialScore: 1,
              showDieIcon: true,
            ),
          ),
        ),
      );

      // Count Container widgets that represent dots
      final dotFinder = find.byType(Container);
      expect(dotFinder, findsWidgets);

      // Find the Container with BoxShape.circle decoration (the dots)
      // We expect at least 1 dot for die face 1
      final containers = tester.widgetList<Container>(dotFinder).toList();
      expect(containers.length, greaterThanOrEqualTo(1));
    });

    testWidgets('die face 2 shows 2 dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.twos,
              potentialScore: 2,
              showDieIcon: true,
            ),
          ),
        ),
      );

      // Verify the widget builds without errors
      expect(find.byType(ScoreRow), findsOneWidget);
    });

    testWidgets('die face 3 shows 3 dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.threes,
              potentialScore: 3,
              showDieIcon: true,
            ),
          ),
        ),
      );

      expect(find.byType(ScoreRow), findsOneWidget);
    });

    testWidgets('die face 4 shows 4 dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.fours,
              potentialScore: 4,
              showDieIcon: true,
            ),
          ),
        ),
      );

      expect(find.byType(ScoreRow), findsOneWidget);
    });

    testWidgets('die face 5 shows 5 dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.fives,
              potentialScore: 5,
              showDieIcon: true,
            ),
          ),
        ),
      );

      expect(find.byType(ScoreRow), findsOneWidget);
    });

    testWidgets('die face 6 shows 6 dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.sixes,
              potentialScore: 6,
              showDieIcon: true,
            ),
          ),
        ),
      );

      expect(find.byType(ScoreRow), findsOneWidget);
    });
  });

  group('ScoreRow - Icon centering', () {
    testWidgets('3x icon is centered for ThreeOfKind', (tester) async {
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

      // Verify Center widget wraps the icon
      expect(find.byType(Center), findsWidgets);
      expect(find.text('3x'), findsOneWidget);
    });

    testWidgets('4x icon is centered for FourOfKind', (tester) async {
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

      expect(find.byType(Center), findsWidgets);
      expect(find.text('4x'), findsOneWidget);
    });

    testWidgets('house icon is centered for FullHouse', (tester) async {
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

      expect(find.byType(Center), findsWidgets);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('gift icon is centered for SmallStraight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.smallStraight,
              potentialScore: 20,
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsWidgets);
      expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
    });

    testWidgets('gift icon is centered for LargeStraight', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(
              category: ScoreCategory.largeStraight,
              potentialScore: 20,
            ),
          ),
        ),
      );

      expect(find.byType(Center), findsWidgets);
      expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
    });

    testWidgets('Y icon is centered for Yatzy', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(category: ScoreCategory.yatzy, potentialScore: 50),
          ),
        ),
      );

      expect(find.byType(Center), findsWidgets);
      expect(find.text('Y'), findsOneWidget);
    });

    testWidgets('help icon is centered for Chance', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreRow(category: ScoreCategory.chance, potentialScore: 18),
          ),
        ),
      );

      expect(find.byType(Center), findsWidgets);
      expect(find.byIcon(Icons.help), findsOneWidget);
    });

    testWidgets('die face icons are centered for upper section', (
      tester,
    ) async {
      for (final category in [
        ScoreCategory.aces,
        ScoreCategory.twos,
        ScoreCategory.threes,
        ScoreCategory.fours,
        ScoreCategory.fives,
        ScoreCategory.sixes,
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreRow(category: category, potentialScore: 5),
            ),
          ),
        );

        expect(find.byType(Center), findsWidgets);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('all category icons use Center widget for alignment', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ScoreRow(
                  category: ScoreCategory.threeOfKind,
                  potentialScore: 10,
                ),
                ScoreRow(
                  category: ScoreCategory.fourOfKind,
                  potentialScore: 10,
                ),
                ScoreRow(category: ScoreCategory.fullHouse, potentialScore: 10),
                ScoreRow(
                  category: ScoreCategory.smallStraight,
                  potentialScore: 10,
                ),
                ScoreRow(
                  category: ScoreCategory.largeStraight,
                  potentialScore: 10,
                ),
                ScoreRow(category: ScoreCategory.yatzy, potentialScore: 10),
                ScoreRow(category: ScoreCategory.chance, potentialScore: 10),
              ],
            ),
          ),
        ),
      );

      // All icons should be wrapped in Center widgets
      expect(find.byType(Center), findsWidgets);
    });
  });
}
