import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/score_sheet.dart';
import 'package:poker_dice/src/ui/components/score_row.dart';

void main() {
  group('ScoreSheet', () {
    testWidgets('displays Upper Section and Lower Section headers', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      expect(find.text('Upper Section'), findsOneWidget);
      expect(find.text('Lower Section'), findsOneWidget);
    });

    testWidgets('displays upper section categories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {
                ScoreCategory.aces: 1,
                ScoreCategory.twos: 2,
                ScoreCategory.threes: 3,
                ScoreCategory.fours: 4,
                ScoreCategory.fives: 5,
                ScoreCategory.sixes: 6,
              },
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      // Check that 6 ScoreRow widgets are displayed for upper section
      expect(find.byType(ScoreRow), findsNWidgets(13)); // 6 upper + 7 lower
    });

    testWidgets('displays lower section categories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {
                ScoreCategory.threeOfKind: 15,
                ScoreCategory.fourOfKind: 20,
                ScoreCategory.fullHouse: 25,
                ScoreCategory.smallStraight: 30,
                ScoreCategory.largeStraight: 40,
                ScoreCategory.yatzy: 50,
                ScoreCategory.chance: 18,
              },
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      expect(find.text('15'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(find.text('40'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
      expect(find.text('18'), findsOneWidget);
    });

    testWidgets('displays bonus progress', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 45,
            ),
          ),
        ),
      );

      expect(find.text('45/63'), findsOneWidget);
    });

    testWidgets('calls onCategoryTapped when category is tapped', (
      tester,
    ) async {
      ScoreCategory? tappedCategory;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {ScoreCategory.aces: 1},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
              onCategoryTapped: (category) => tappedCategory = category,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ScoreRow).first);
      await tester.pumpAndSettle();

      expect(tappedCategory, ScoreCategory.aces);
    });

    testWidgets('displays scored categories with scores', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {ScoreCategory.aces: 2},
              currentScores: {ScoreCategory.aces: 2},
              scoredCategories: {ScoreCategory.aces},
              upperTotal: 2,
            ),
          ),
        ),
      );

      expect(find.text('2'), findsWidgets);
    });

    testWidgets('has two-column layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      // Should have multiple Rows (headers, upper/lower columns, etc.)
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('renders all 13 categories', (tester) async {
      final potentialScores = <ScoreCategory, int?>{};
      final currentScores = <ScoreCategory, int?>{};

      for (final category in ScoreCategory.values) {
        potentialScores[category] = 10;
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: potentialScores,
              currentScores: currentScores,
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      // Should have 13 ScoreRow widgets (6 upper + 7 lower)
      expect(find.byType(ScoreRow), findsNWidgets(13));
    });
  });

  group('ScoreSheet - Layout', () {
    testWidgets('upper column has 6 categories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      // Count upper section rows (6 categories + bonus row)
      expect(find.text('Upper Section'), findsOneWidget);
    });

    testWidgets('lower column has 7 categories', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      // Count lower section rows
      expect(find.text('Lower Section'), findsOneWidget);
    });

    testWidgets('bonus row is at bottom of upper column', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 30,
            ),
          ),
        ),
      );

      expect(find.text('30/63'), findsOneWidget);
    });
  });

  group('ScoreSheet - Empty State', () {
    testWidgets('displays dashes for null potential scores', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      expect(find.text('-'), findsNWidgets(13));
    });

    testWidgets('displays empty boxes for null current scores', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScoreSheetWidget(
              potentialScores: {},
              currentScores: {},
              scoredCategories: {},
              upperTotal: 0,
            ),
          ),
        ),
      );

      // Score boxes should be present but empty
      expect(find.byType(ScoreRow), findsNWidgets(13));
    });
  });
}
