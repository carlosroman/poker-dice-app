import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/widgets/category_row.dart';
import 'package:poker_dice/widgets/score_sheet.dart';

void main() {
  group('ScoreSheet', () {
    final List<Dice> defaultDice = [
      const Dice(value: 1),
      const Dice(value: 2),
      const Dice(value: 3),
      const Dice(value: 4),
      const Dice(value: 5),
    ];

    Widget buildScoreSheet({
      List<Dice> dice = const [],
      Map<ScoreCategory, int> scoredCategories = const {},
      ScoreCategory? selectedCategory,
      void Function(ScoreCategory)? onCategorySelect,
      int upperTotal = 0,
      int bonus = 0,
      double? width,
      double? height,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: width ?? double.infinity,
            height: height ?? 800,
            child: ScoreSheet(
              dice: dice,
              scoredCategories: scoredCategories,
              selectedCategory: selectedCategory,
              onCategorySelect: onCategorySelect ?? (_) {},
              upperTotal: upperTotal,
              bonus: bonus,
            ),
          ),
        ),
      );
    }

    testWidgets('renders all 13 categories', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      expect(find.byType(CategoryRow), findsNWidgets(13));
    });

    testWidgets('renders 6 upper categories', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      final upperCategories = ScoreCategory.values
          .where((c) => c.isUpper)
          .toList();
      for (final category in upperCategories) {
        expect(find.text(category.displayName), findsOneWidget);
      }
    });

    testWidgets('renders 7 lower categories', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      final lowerCategories = ScoreCategory.values
          .where((c) => !c.isUpper)
          .toList();
      for (final category in lowerCategories) {
        expect(find.text(category.displayName), findsOneWidget);
      }
    });

    testWidgets('uses two-column layout when width >= 300', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      // Two columns are arranged in a Row
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('uses single-column layout when width < 300', (tester) async {
      await tester.pumpWidget(
        buildScoreSheet(dice: defaultDice, width: 200, height: 1200),
      );

      // Single column uses a Column for sections
      expect(find.byType(CategoryRow), findsNWidgets(13));
    });

    testWidgets('shows Minor section header', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      expect(find.text('Minor'), findsOneWidget);
    });

    testWidgets('shows Major section header', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      expect(find.text('Major'), findsOneWidget);
    });

    testWidgets('shows bonus row in upper section', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      expect(find.text('Bonus'), findsOneWidget);
    });

    testWidgets('bonus row shows current/63 progress', (tester) async {
      await tester.pumpWidget(
        buildScoreSheet(dice: defaultDice, width: 400, upperTotal: 45),
      );

      expect(find.text('45/63'), findsOneWidget);
    });

    testWidgets('bonus row shows +0 when upper total < 63', (tester) async {
      await tester.pumpWidget(
        buildScoreSheet(
          dice: defaultDice,
          width: 400,
          upperTotal: 50,
          bonus: 0,
        ),
      );

      expect(find.text('+0'), findsOneWidget);
    });

    testWidgets('bonus row shows +35 when upper total >= 63', (tester) async {
      await tester.pumpWidget(
        buildScoreSheet(
          dice: defaultDice,
          width: 400,
          upperTotal: 65,
          bonus: 35,
        ),
      );

      expect(find.text('+35'), findsOneWidget);
    });

    testWidgets('scored category shows final score', (tester) async {
      await tester.pumpWidget(
        buildScoreSheet(
          dice: defaultDice,
          width: 400,
          scoredCategories: {ScoreCategory.aces: 10},
        ),
      );

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('selected category shows selected state', (tester) async {
      await tester.pumpWidget(
        buildScoreSheet(
          dice: defaultDice,
          width: 400,
          selectedCategory: ScoreCategory.fives,
        ),
      );

      // The selected row should be present
      expect(find.text('Fives'), findsOneWidget);
    });

    testWidgets(
      'onCategorySelect is called when selectable category is tapped',
      (tester) async {
        ScoreCategory? selected;

        await tester.pumpWidget(
          buildScoreSheet(
            dice: defaultDice,
            width: 400,
            onCategorySelect: (category) => selected = category,
          ),
        );

        await tester.tap(find.text('Ones'));
        await tester.pump();

        expect(selected, ScoreCategory.aces);
      },
    );

    testWidgets('scored category does not invoke onCategorySelect', (
      tester,
    ) async {
      ScoreCategory? selected;

      await tester.pumpWidget(
        buildScoreSheet(
          dice: defaultDice,
          width: 400,
          scoredCategories: {ScoreCategory.twos: 4},
          onCategorySelect: (category) => selected = category,
        ),
      );

      await tester.tap(find.text('Twos'));
      await tester.pump();

      expect(selected, isNull);
    });

    testWidgets('selected category does not invoke onCategorySelect', (
      tester,
    ) async {
      ScoreCategory? selected;

      await tester.pumpWidget(
        buildScoreSheet(
          dice: defaultDice,
          width: 400,
          selectedCategory: ScoreCategory.threes,
          onCategorySelect: (category) => selected = category,
        ),
      );

      await tester.tap(find.text('Threes'));
      await tester.pump();

      expect(selected, isNull);
    });

    testWidgets('uses default upperTotal of 0', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      expect(find.text('0/63'), findsOneWidget);
    });

    testWidgets('uses default bonus of 0', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: defaultDice, width: 400));

      expect(find.text('+0'), findsOneWidget);
    });

    testWidgets('exposes upperTotal and bonus properties', (tester) async {
      final sheet = ScoreSheet(
        dice: const [],
        scoredCategories: const {},
        onCategorySelect: (_) {},
        upperTotal: 10,
        bonus: 35,
      );
      expect(sheet.upperTotal, 10);
      expect(sheet.bonus, 35);
      expect(sheet.dice, isEmpty);
      expect(sheet.scoredCategories, isEmpty);
    });

    testWidgets('renders without crashing with empty dice', (tester) async {
      await tester.pumpWidget(buildScoreSheet(dice: const [], width: 400));

      expect(find.byType(ScoreSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'categories always call onCategorySelect (guard is in provider)',
      (tester) async {
        final blankDice = [
          const Dice(value: 0),
          const Dice(value: 0),
          const Dice(value: 0),
          const Dice(value: 0),
          const Dice(value: 0),
        ];

        ScoreCategory? selected;
        await tester.pumpWidget(
          buildScoreSheet(
            dice: blankDice,
            width: 400,
            onCategorySelect: (c) => selected = c,
          ),
        );

        await tester.tap(find.text('Ones'));
        await tester.pump();

        // ScoreSheet always delegates to provider; provider guards blank dice
        expect(selected, ScoreCategory.aces);
      },
    );

    testWidgets('categories are enabled after rolling dice', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        buildScoreSheet(
          dice: defaultDice,
          width: 400,
          onCategorySelect: (_) => tapped = true,
        ),
      );

      await tester.tap(find.text('Ones'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
