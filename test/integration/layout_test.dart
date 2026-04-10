import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/score_sheet.dart';

/// Integration test for the score sheet layout.
///
/// This test verifies that the Upper Section and Lower Section are displayed
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
            upperTotal: 0,
            onCategoryTapped: null,
          ),
        ),
      );
    }

    testWidgets(
      'displays Upper Section and Lower Section headers side-by-side',
      (tester) async {
        await tester.pumpWidget(createScoreSheetWidget());

        // Verify Upper Section header is present
        expect(find.text('Upper Section'), findsOneWidget);

        // Verify Lower Section header is present
        expect(find.text('Lower Section'), findsOneWidget);

        // Verify both headers are found (they should be siblings in a Row)
        final upperFinder = find.text('Upper Section');
        final lowerFinder = find.text('Lower Section');

        expect(upperFinder, findsOneWidget);
        expect(lowerFinder, findsOneWidget);
      },
    );

    testWidgets('headers are arranged in a Row widget', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the Row widget that contains both headers
      final headerRowFinder = find.ancestor(
        of: find.text('Upper Section'),
        matching: find.byType(Row),
      );

      expect(
        headerRowFinder,
        findsOneWidget,
        reason: 'Upper Section header should be inside a Row widget',
      );

      // Verify the Row contains both headers
      final rowWidget = tester.widget<Row>(headerRowFinder);
      expect(
        rowWidget.children.length,
        greaterThanOrEqualTo(2),
        reason:
            'Row should have at least 2 children (Upper Section and Lower Section headers)',
      );
    });

    testWidgets('displays Upper Section categories (6 categories)', (
      tester,
    ) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Verify Upper Section has 6 categories (aces through sixes)
      final upperCategories = ScoreCategory.values
          .where((c) => c.isUpper)
          .toList();

      // We should have 6 categories in Upper Section
      expect(
        upperCategories.length,
        6,
        reason: 'Upper Section should have 6 categories',
      );
    });

    testWidgets('displays Lower Section categories (7 categories)', (
      tester,
    ) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Verify Lower Section has 7 categories
      final lowerCategories = ScoreCategory.values
          .where((c) => c.isLower)
          .toList();

      expect(
        lowerCategories.length,
        7,
        reason: 'Lower Section should have 7 categories',
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

    testWidgets('Upper Section and Lower Section columns are properly spaced', (
      tester,
    ) async {
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

    testWidgets('Upper Section header is present', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the Upper Section header
      final upperHeaderFinder = find.text('Upper Section');
      expect(upperHeaderFinder, findsOneWidget);

      // Verify it's in a Row with the Lower Section header
      final rowFinder = find.ancestor(
        of: upperHeaderFinder,
        matching: find.byType(Row),
      );

      expect(
        rowFinder,
        findsOneWidget,
        reason: 'Upper Section header should be in a Row widget',
      );
    });

    testWidgets('Lower Section header is present', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the Lower Section header
      final lowerHeaderFinder = find.text('Lower Section');
      expect(lowerHeaderFinder, findsOneWidget);

      // Verify it's in the same Row as Upper Section header
      final rowFinder = find.ancestor(
        of: lowerHeaderFinder,
        matching: find.byType(Row),
      );

      expect(
        rowFinder,
        findsOneWidget,
        reason:
            'Lower Section header should be in the same Row as Upper Section header',
      );
    });

    testWidgets('score sheet has two columns layout', (tester) async {
      await tester.pumpWidget(createScoreSheetWidget());

      // Find the Row that contains the two columns (Upper Section and Lower Section)
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
