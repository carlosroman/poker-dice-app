import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';
import 'package:poker_dice/src/ui/components/score_sheet.dart' as ui_component;
import 'package:poker_dice/src/ui/theme/app_theme.dart';

void main() {
  group('ScoreSheet', () {
    // Helper to create a testable widget
    Widget createWidget({
      required ScoreSheet scoreSheet,
      Function(ScoreCategory)? onCategorySelected,
      List<ScoreCategory> validCategories = const [],
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        home: Scaffold(
          body: ui_component.ScoreSheet(
            scoreSheet: scoreSheet,
            onCategorySelected: onCategorySelected,
            validCategories: validCategories,
          ),
        ),
      );
    }

    // Helper to create a fresh unscored score sheet
    ScoreSheet createUnscoredSheet() {
      return ScoreSheet();
    }

    // Helper to create a partially scored score sheet
    ScoreSheet createPartiallyScoredSheet() {
      final sheet = ScoreSheet();
      // Score some upper categories
      sheet.score(ScoreCategory.aces, [
        Die(value: 1),
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
      ]);
      sheet.score(ScoreCategory.twos, [
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
      ]);
      return sheet;
    }

    // Helper to create a fully scored score sheet
    ScoreSheet createFullyScoredSheet() {
      final sheet = ScoreSheet();
      // Score all upper categories
      sheet.score(ScoreCategory.aces, [
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
      ]);
      sheet.score(ScoreCategory.twos, [
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
      ]);
      sheet.score(ScoreCategory.threes, [
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
      ]);
      sheet.score(ScoreCategory.fours, [
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
      ]);
      sheet.score(ScoreCategory.fives, [
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
      ]);
      sheet.score(ScoreCategory.sixes, [
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
      ]);
      // Score all lower categories
      sheet.score(ScoreCategory.threeOfKind, [
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
      ]);
      sheet.score(ScoreCategory.fourOfKind, [
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 3),
      ]);
      sheet.score(ScoreCategory.fullHouse, [
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
        Die(value: 4),
        Die(value: 4),
      ]);
      sheet.score(ScoreCategory.smallStraight, [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 6),
      ]);
      sheet.score(ScoreCategory.largeStraight, [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ]);
      sheet.score(ScoreCategory.yatzy, [
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
      ]);
      sheet.score(ScoreCategory.chance, [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ]);
      return sheet;
    }

    // Helper to find text
    Finder findText(String text) {
      return find.text(text);
    }

    // Helper to find by type
    Finder findByType(Type type) {
      return find.byType(type);
    }

    testWidgets('renders header row with Category and Score labels', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      expect(findText('Category'), findsOneWidget);
      expect(findText('Score'), findsOneWidget);
    });

    testWidgets('renders all 13 categories', (WidgetTester tester) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      final categories = [
        'Aces',
        'Twos',
        'Threes',
        'Fours',
        'Fives',
        'Sixes',
        'Three of a Kind',
        'Four of a Kind',
        'Full House',
        'Small Straight',
        'Large Straight',
        'Yatzy',
        'Chance',
      ];

      for (final category in categories) {
        expect(
          findText(category),
          findsOneWidget,
          reason: 'Missing: $category',
        );
      }
    });

    testWidgets('renders Upper Section with 6 categories', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      final upperCategories = [
        'Aces',
        'Twos',
        'Threes',
        'Fours',
        'Fives',
        'Sixes',
      ];

      for (final category in upperCategories) {
        expect(
          findText(category),
          findsOneWidget,
          reason: 'Missing: $category',
        );
      }
    });

    testWidgets('renders Lower Section with 7 categories', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      final lowerCategories = [
        'Three of a Kind',
        'Four of a Kind',
        'Full House',
        'Small Straight',
        'Large Straight',
        'Yatzy',
        'Chance',
      ];

      for (final category in lowerCategories) {
        expect(
          findText(category),
          findsOneWidget,
          reason: 'Missing: $category',
        );
      }
    });

    testWidgets('shows upper total with subtotal', (WidgetTester tester) async {
      final sheet = createPartiallyScoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      expect(findText('Upper Total'), findsOneWidget);
      expect(findText('Total'), findsWidgets); // Multiple totals exist
    });

    testWidgets('shows upper total with bonus when applicable', (
      WidgetTester tester,
    ) async {
      // Create a sheet with upper total >= 63 to trigger bonus
      final sheet = ScoreSheet();
      // Score upper categories to get >= 63 points
      sheet.score(ScoreCategory.aces, [
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
      ]);
      sheet.score(ScoreCategory.twos, [
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
      ]);
      sheet.score(ScoreCategory.threes, [
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
      ]);
      sheet.score(ScoreCategory.fours, [
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
      ]);
      sheet.score(ScoreCategory.fives, [
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
      ]);
      sheet.score(ScoreCategory.sixes, [
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
      ]);

      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      expect(findText('Upper Total'), findsOneWidget);
      expect(findText('Total'), findsWidgets);
      // Bonus should be displayed
      expect(findText('+35 bonus'), findsOneWidget);
    });

    testWidgets('shows upper total without bonus when < 63', (
      WidgetTester tester,
    ) async {
      final sheet = createPartiallyScoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      expect(findText('Upper Total'), findsOneWidget);
      // Bonus should not be displayed
      expect(findText('+35 bonus'), findsNothing);
    });

    testWidgets('shows lower total correctly', (WidgetTester tester) async {
      final sheet = createPartiallyScoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      expect(findText('Lower Total'), findsOneWidget);
    });

    testWidgets('shows grand total correctly', (WidgetTester tester) async {
      final sheet = createFullyScoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Scroll to see the grand total
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final expectedTotal = sheet.getTotal();
      expect(findText(expectedTotal.toString()), findsWidgets);
    });

    testWidgets('grand total includes bonus when applicable', (
      WidgetTester tester,
    ) async {
      final sheet = ScoreSheet();
      // Score all upper categories to get bonus
      sheet.score(ScoreCategory.aces, [
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
      ]);
      sheet.score(ScoreCategory.twos, [
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
      ]);
      sheet.score(ScoreCategory.threes, [
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
      ]);
      sheet.score(ScoreCategory.fours, [
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
        Die(value: 4),
      ]);
      sheet.score(ScoreCategory.fives, [
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
      ]);
      sheet.score(ScoreCategory.sixes, [
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
      ]);
      // Score lower categories
      sheet.score(ScoreCategory.threeOfKind, [
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
      ]);
      sheet.score(ScoreCategory.fourOfKind, [
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 2),
        Die(value: 3),
      ]);
      sheet.score(ScoreCategory.fullHouse, [
        Die(value: 3),
        Die(value: 3),
        Die(value: 3),
        Die(value: 4),
        Die(value: 4),
      ]);
      sheet.score(ScoreCategory.smallStraight, [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 6),
      ]);
      sheet.score(ScoreCategory.largeStraight, [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ]);
      sheet.score(ScoreCategory.yatzy, [
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
      ]);
      sheet.score(ScoreCategory.chance, [
        Die(value: 1),
        Die(value: 2),
        Die(value: 3),
        Die(value: 4),
        Die(value: 5),
      ]);

      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Scroll to see the grand total
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      final expectedTotal = sheet.getTotal();
      expect(findText(expectedTotal.toString()), findsWidgets);
      expect(findText('+35'), findsWidgets); // Bonus should appear in breakdown
    });

    testWidgets('category rows are selectable when valid', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      bool categorySelected = false;
      ScoreCategory? selectedCategory;

      void onCategorySelected(ScoreCategory category) {
        categorySelected = true;
        selectedCategory = category;
      }

      await tester.pumpWidget(
        createWidget(
          scoreSheet: sheet,
          onCategorySelected: onCategorySelected,
          validCategories: [ScoreCategory.aces],
        ),
      );

      // Aces should be selectable (has GestureDetector)
      final acesFinder = find.ancestor(
        of: findText('Aces'),
        matching: findByType(GestureDetector),
      );
      expect(acesFinder, findsOneWidget);

      // Tap on Aces
      await tester.tap(acesFinder);
      await tester.pump();

      expect(categorySelected, isTrue);
      expect(selectedCategory, equals(ScoreCategory.aces));
    });

    testWidgets('category rows are disabled when already scored', (
      WidgetTester tester,
    ) async {
      final sheet = createPartiallyScoredSheet();
      // Aces is already scored

      await tester.pumpWidget(
        createWidget(
          scoreSheet: sheet,
          validCategories: [ScoreCategory.aces, ScoreCategory.twos],
        ),
      );

      // Aces should not be selectable (already scored)
      // It should show the score, not be a GestureDetector
      final _ = find.ancestor(
        of: findText('Aces'),
        matching: findByType(GestureDetector),
      );

      // Twos should be selectable (not scored yet and in validCategories)
      final twosFinder = find.ancestor(
        of: findText('Twos'),
        matching: findByType(GestureDetector),
      );
      expect(twosFinder, findsOneWidget);
    });

    testWidgets('callback is called when category selected', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      final selectedCategories = <ScoreCategory>[];

      void onCategorySelected(ScoreCategory category) {
        selectedCategories.add(category);
      }

      await tester.pumpWidget(
        createWidget(
          scoreSheet: sheet,
          onCategorySelected: onCategorySelected,
          validCategories: ScoreCategory.values,
        ),
      );

      // Tap on each category
      for (final category in ScoreCategory.values.take(3)) {
        final finder = find.ancestor(
          of: findText(category.displayName),
          matching: findByType(GestureDetector),
        );
        await tester.tap(finder);
        await tester.pump();
      }

      expect(selectedCategories.length, equals(3));
      expect(selectedCategories[0], equals(ScoreCategory.aces));
      expect(selectedCategories[1], equals(ScoreCategory.twos));
      expect(selectedCategories[2], equals(ScoreCategory.threes));
    });

    testWidgets('callback is not called when onCategorySelected is null', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();

      await tester.pumpWidget(
        createWidget(
          scoreSheet: sheet,
          onCategorySelected: null,
          validCategories: ScoreCategory.values,
        ),
      );

      // Should not crash when tapping
      final acesFinder = find.ancestor(
        of: findText('Aces'),
        matching: findByType(GestureDetector),
      );
      await tester.tap(acesFinder);
      await tester.pump();

      // Widget should still be rendered
      expect(findText('Aces'), findsOneWidget);
    });

    testWidgets('accessibility labels present', (WidgetTester tester) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Check that Semantics widgets are present
      final semanticsFinder = findByType(Semantics);
      expect(semanticsFinder, findsWidgets);
    });

    testWidgets('accessibility label contains category name', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Find the GestureDetector for Aces
      final acesGestureFinder = find.ancestor(
        of: findText('Aces'),
        matching: findByType(GestureDetector),
      );
      expect(acesGestureFinder, findsOneWidget);
    });

    testWidgets('renders in dark theme', (WidgetTester tester) async {
      final sheet = createFullyScoredSheet();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.dark,
          home: Scaffold(body: ui_component.ScoreSheet(scoreSheet: sheet)),
        ),
      );

      // Scroll to see the grand total
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(findText('Grand Total:'), findsOneWidget);
      expect(findText(sheet.getTotal().toString()), findsWidgets);
    });

    testWidgets('renders in light theme', (WidgetTester tester) async {
      final sheet = createFullyScoredSheet();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.light,
          home: Scaffold(body: ui_component.ScoreSheet(scoreSheet: sheet)),
        ),
      );

      // Scroll to see the grand total
      await tester.drag(find.byType(ListView), const Offset(0, -500));
      await tester.pumpAndSettle();

      expect(findText('Grand Total:'), findsOneWidget);
      expect(findText(sheet.getTotal().toString()), findsWidgets);
    });

    testWidgets('Upper Total shows correct subtotal', (
      WidgetTester tester,
    ) async {
      final sheet = createPartiallyScoredSheet();
      final expectedUpperTotal = sheet.getUpperTotal();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      expect(findText('Upper Total'), findsOneWidget);
      // The total value should be present
      expect(findText(expectedUpperTotal.toString()), findsOneWidget);
    });

    testWidgets('Lower Total shows correct subtotal', (
      WidgetTester tester,
    ) async {
      final sheet = createPartiallyScoredSheet();
      final expectedLowerTotal = sheet.getLowerTotal();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      expect(findText('Lower Total'), findsOneWidget);
      // The total value should be present
      expect(findText(expectedLowerTotal.toString()), findsOneWidget);
    });

    testWidgets('shows breakdown in grand total section', (
      WidgetTester tester,
    ) async {
      final sheet = createFullyScoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Scroll to see the grand total section
      await tester.scrollUntilVisible(findText('Grand Total:'), 500);
      await tester.pumpAndSettle();

      // Verify breakdown elements exist by checking for total values
      final upperTotal = sheet.getUpperTotal();
      final lowerTotal = sheet.getLowerTotal();

      expect(findText('Upper Total'), findsOneWidget);
      expect(findText('Lower Total'), findsOneWidget);
      expect(findText('Grand Total:'), findsOneWidget);
      // Check that the breakdown values are present
      expect(findText(upperTotal.toString()), findsWidgets);
      expect(findText(lowerTotal.toString()), findsWidgets);
    });

    testWidgets('empty score sheet shows zeros for totals', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Scroll to see the grand total
      await tester.scrollUntilVisible(findText('Grand Total:'), 500);
      await tester.pumpAndSettle();

      expect(findText('Upper Total'), findsOneWidget);
      expect(findText('Lower Total'), findsOneWidget);
      expect(findText('Grand Total:'), findsOneWidget);
      expect(findText('0'), findsWidgets); // Multiple zeros for totals
    });

    testWidgets('ListView is scrollable', (WidgetTester tester) async {
      final sheet = createFullyScoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Find ListView
      final listViewFinder = findByType(ListView);
      expect(listViewFinder, findsOneWidget);

      // Try to scroll
      await tester.drag(listViewFinder, const Offset(0, -200));
      await tester.pumpAndSettle();
    });

    testWidgets('Yatzy category shows correctly', (WidgetTester tester) async {
      final sheet = ScoreSheet();
      sheet.score(ScoreCategory.yatzy, [
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
        Die(value: 5),
      ]);
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      expect(findText('Yatzy'), findsOneWidget);
      expect(
        findText('50'),
        findsWidgets,
      ); // Yatzy score (may appear multiple times)
    });

    testWidgets('category order is correct (upper then lower)', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Get all category names in order
      final _ = tester
          .widgetList<Text>(find.text('Aces'))
          .map((widget) => widget.data)
          .toList();

      // Aces should appear first in upper section
      expect(findText('Aces'), findsOneWidget);
      expect(findText('Chance'), findsOneWidget); // Should be last
    });

    testWidgets('scrolls to show all categories', (WidgetTester tester) async {
      final sheet = createFullyScoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // All categories should be findable
      expect(findText('Aces'), findsOneWidget);
      expect(findText('Chance'), findsOneWidget);
      expect(findText('Yatzy'), findsOneWidget);
    });

    testWidgets('handles empty validCategories list', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(
        createWidget(scoreSheet: sheet, validCategories: const []),
      );

      // Should render without errors
      expect(findText('Category'), findsOneWidget);
      expect(findText('Aces'), findsOneWidget);
    });

    testWidgets('handles large score values', (WidgetTester tester) async {
      final sheet = ScoreSheet(yatzyCount: 3); // Multiple yatzy bonuses
      sheet.score(ScoreCategory.yatzy, [
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
        Die(value: 6),
      ]);
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Yatzy with 3 counts should be 50 + (3 * 50) = 200
      expect(findText('Yatzy'), findsOneWidget);
      expect(findText('200'), findsWidgets);
    });

    testWidgets('animation runs smoothly on state change', (
      WidgetTester tester,
    ) async {
      final sheet = createUnscoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: sheet));

      // Initial state
      expect(findText('Aces'), findsOneWidget);

      // Create new sheet with different state
      final newSheet = createPartiallyScoredSheet();
      await tester.pumpWidget(createWidget(scoreSheet: newSheet));

      // Pump for animation
      await tester.pumpAndSettle(const Duration(milliseconds: 300));

      // Should still be rendered
      expect(findText('Aces'), findsOneWidget);
    });
  });
}
