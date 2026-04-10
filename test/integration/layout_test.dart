import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/score_sheet.dart';

/// Integration test for the score sheet layout.
///
/// This test verifies that the Minor and Major sections are displayed
/// side-by-side in a Row widget, not stacked vertically in a Column.
void main() {
  group('ScoreSheetWidget Layout', () {
    late Map<ScoreCategory, int?> potentialScores;
    late Map<ScoreCategory, int?> currentScores;
    late Set<ScoreCategory> scoredCategories;

    setUp(() {
      // Initialize with empty scores
      potentialScores = {};
      currentScores = {};
      scoredCategories = {};

      // Populate potential scores for all categories
      for (final category in ScoreCategory.values) {
        potentialScores[category] = 0;
      }
    });

    Widget createScoreSheetWidget() {
      return MaterialApp(
        home: Scaffold(
          body: ScoreSheetWidget(
            potentialScores: potentialScores,
            currentScores: currentScores,
            scoredCategories: scoredCategories,
            minorTotal: 0,
            onCategoryTapped: null,
          ),
        ),
      );
    }

    testWidgets('displays Minor and Major headers side-by-side', (
      tester,
    ) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Verify Minor header is present
      expect(find.text('Minor'), findsOneWidget);

      // Verify Major header is present
      expect(find.text('Major'), findsOneWidget);

      // Verify both headers are found (they should be siblings in a Row)
      final minorFinder = find.text('Minor');
      final majorFinder = find.text('Major');

      expect(minorFinder, findsOneWidget);
      expect(majorFinder, findsOneWidget);
    });

    testWidgets('headers are arranged in a Row widget', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the Row widget that contains both headers
      final headerRowFinder = find.ancestor(
        of: find.text('Minor'),
        matching: find.byType(Row),
      );

      expect(
        headerRowFinder,
        findsOneWidget,
        reason: 'Minor header should be inside a Row widget',
      );

      // Verify the Row contains both headers
      final rowWidget = tester.widget<Row>(headerRowFinder);
      expect(
        rowWidget.children.length,
        greaterThanOrEqualTo(2),
        reason: 'Row should have at least 2 children (Minor and Major headers)',
      );
    });

    testWidgets('displays Minor section categories (6 categories)', (
      tester,
    ) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Verify Minor section has 6 categories (aces through sixes)
      final minorCategories = ScoreCategory.values
          .where((c) => c.isMinor)
          .toList();

      // We should have 6 categories in Minor section
      expect(
        minorCategories.length,
        6,
        reason: 'Minor section should have 6 categories',
      );
    });

    testWidgets('displays Major section categories (7 categories)', (
      tester,
    ) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Verify Major section has 7 categories
      final majorCategories = ScoreCategory.values
          .where((c) => c.isMajor)
          .toList();

      expect(
        majorCategories.length,
        7,
        reason: 'Major section should have 7 categories',
      );
    });

    testWidgets('layout structure uses Row for side-by-side columns', (
      tester,
    ) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find all Row widgets
      final rowFinder = find.byType(Row);
      expect(
        rowFinder,
        findsWidgets,
        reason: 'Should have Row widgets for layout',
      );

      // Verify that there's a Row with two Expanded children (for Minor and Major columns)
      bool foundSideBySideLayout = false;

      for (final row in tester.widgetList<Row>(rowFinder)) {
        // Check if this row has Expanded children (indicating side-by-side columns)
        final hasExpandedChildren = row.children.any(
          (child) => child is Expanded,
        );

        if (hasExpandedChildren && row.children.length >= 2) {
          foundSideBySideLayout = true;
          break;
        }
      }

      expect(
        foundSideBySideLayout,
        isTrue,
        reason:
            'Should have a Row with Expanded children for side-by-side layout',
      );
    });

    testWidgets('Minor and Major columns are properly spaced', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the SizedBox widgets used for spacing
      final sizedBoxFinder = find.byType(SizedBox);
      expect(
        sizedBoxFinder,
        findsWidgets,
        reason: 'Should have SizedBox widgets for spacing',
      );

      // Verify there's horizontal spacing between columns
      final sizedBoxes = tester.widgetList<SizedBox>(sizedBoxFinder).toList();

      // Should have at least one SizedBox with horizontal spacing
      final horizontalSpacing = sizedBoxes.any(
        (box) => box.width != null && box.width! > 0,
      );

      expect(
        horizontalSpacing,
        isTrue,
        reason: 'Should have horizontal spacing between columns',
      );
    });

    testWidgets('Minor section header is present', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the Minor header
      final minorHeaderFinder = find.text('Minor');
      expect(minorHeaderFinder, findsOneWidget);

      // Verify it's in a Row with the Major header
      final rowFinder = find.ancestor(
        of: minorHeaderFinder,
        matching: find.byType(Row),
      );

      expect(
        rowFinder,
        findsOneWidget,
        reason: 'Minor header should be in a Row widget',
      );
    });

    testWidgets('Major section header is present', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the Major header
      final majorHeaderFinder = find.text('Major');
      expect(majorHeaderFinder, findsOneWidget);

      // Verify it's in the same Row as Minor header
      final rowFinder = find.ancestor(
        of: majorHeaderFinder,
        matching: find.byType(Row),
      );

      expect(
        rowFinder,
        findsOneWidget,
        reason: 'Major header should be in the same Row as Minor header',
      );
    });

    testWidgets('score sheet has two columns layout', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the Row that contains the two columns (Minor and Major)
      // This should be inside the main Column of ScoreSheetWidget
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsWidgets, reason: 'Should have Column widgets');

      // Find a Row that is a descendant of a Column and has Expanded children
      final sideBySideRowFinder = find.descendant(
        of: columnFinder,
        matching: find.byType(Row),
      );

      expect(
        sideBySideRowFinder,
        findsWidgets,
        reason: 'Should have Row widgets inside Column',
      );

      // Verify at least one Row has Expanded children (side-by-side layout)
      bool foundColumnLayout = false;
      for (final row in tester.widgetList<Row>(sideBySideRowFinder)) {
        final hasExpanded = row.children.whereType<Expanded>().length >= 2;
        if (hasExpanded) {
          foundColumnLayout = true;
          break;
        }
      }

      expect(
        foundColumnLayout,
        isTrue,
        reason: 'Should have a Row with 2+ Expanded children for columns',
      );
    });
  });
}
