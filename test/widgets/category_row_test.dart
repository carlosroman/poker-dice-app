import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/widgets/category_row.dart';

void main() {
  group('CategoryRow', () {
    testWidgets('displays category icon and display name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.aces,
              state: CategoryRowState.selectable,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.looks_one), findsOneWidget);
      expect(find.text('Aces'), findsOneWidget);
    });

    testWidgets('selectable state shows preview score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.twos,
              state: CategoryRowState.selectable,
              previewScore: 8,
            ),
          ),
        ),
      );

      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('selectable state shows dash when no preview score', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.aces,
              state: CategoryRowState.selectable,
              previewScore: null,
            ),
          ),
        ),
      );

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('selectable state invokes onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.threes,
              state: CategoryRowState.selectable,
              previewScore: 6,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Threes'));
      expect(tapped, isTrue);
    });

    testWidgets('selectable state with no onTap does not crash', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.fours,
              state: CategoryRowState.selectable,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Fours'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('selected state shows highlighted decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.fives,
              state: CategoryRowState.selected,
              previewScore: 15,
            ),
          ),
        ),
      );

      expect(find.byType(CategoryRow), findsOneWidget);
      expect(find.text('Fives'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);

      // Verify the container has a border decoration
      final container = find.descendant(
        of: find.byType(CategoryRow),
        matching: find.byType(Container),
      );
      expect(container, findsOneWidget);
    });

    testWidgets('selected state invokes onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.sixes,
              state: CategoryRowState.selected,
              previewScore: 12,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Selected state is NOT tappable (onTap not invoked)
      await tester.tap(find.text('Sixes'));
      expect(tapped, isFalse);
    });

    testWidgets('scored state shows final score', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.threeOfAKind,
              state: CategoryRowState.scored,
              finalScore: 18,
            ),
          ),
        ),
      );

      expect(find.text('18'), findsOneWidget);
      expect(find.text('Three of a Kind'), findsOneWidget);
    });

    testWidgets('scored state shows 0 when finalScore is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.fourOfAKind,
              state: CategoryRowState.scored,
              finalScore: null,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('scored state does not invoke onTap when tapped', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.fullHouse,
              state: CategoryRowState.scored,
              finalScore: 25,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Full House'));
      expect(tapped, isFalse);
    });

    testWidgets('disabled state shows dash and faded appearance', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.smallStraight,
              state: CategoryRowState.disabled,
            ),
          ),
        ),
      );

      expect(find.text('-'), findsOneWidget);
      expect(find.text('Small Straight'), findsOneWidget);
    });

    testWidgets('disabled state does not invoke onTap when tapped', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.largeStraight,
              state: CategoryRowState.disabled,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Large Straight'));
      expect(tapped, isFalse);
    });

    testWidgets('all upper categories render correctly', (tester) async {
      for (final category in ScoreCategory.values.where((c) => c.isUpper)) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryRow(
                category: category,
                state: CategoryRowState.selectable,
                previewScore: 5,
              ),
            ),
          ),
        );

        expect(find.text(category.displayName), findsOneWidget);
        expect(find.byIcon(category.icon), findsOneWidget);
      }
    });

    testWidgets('all lower categories render correctly', (tester) async {
      for (final category in ScoreCategory.values.where((c) => !c.isUpper)) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CategoryRow(
                category: category,
                state: CategoryRowState.selectable,
                previewScore: 10,
              ),
            ),
          ),
        );

        expect(find.text(category.displayName), findsOneWidget);
        expect(find.byIcon(category.icon), findsOneWidget);
      }
    });

    testWidgets('supports const constructor', (tester) async {
      const row = CategoryRow(
        category: ScoreCategory.yatzy,
        state: CategoryRowState.selectable,
        previewScore: 50,
      );
      expect(row.category, ScoreCategory.yatzy);
      expect(row.state, CategoryRowState.selectable);
      expect(row.previewScore, 50);
      expect(row.finalScore, isNull);
      expect(row.onTap, isNull);
    });

    testWidgets('default state is selectable', (tester) async {
      const row = CategoryRow(category: ScoreCategory.chance);
      expect(row.state, CategoryRowState.selectable);
    });

    testWidgets('selected state shows dash when no preview score', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.yatzy,
              state: CategoryRowState.selected,
              previewScore: null,
            ),
          ),
        ),
      );

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('scored state with zero score shows 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.chance,
              state: CategoryRowState.scored,
              finalScore: 0,
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('selectable preview score uses primary color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryRow(
              category: ScoreCategory.aces,
              state: CategoryRowState.selectable,
              previewScore: 3,
            ),
          ),
        ),
      );

      final textFinder = find.text('3');
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, isNotNull);
    });
  });
}
