import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/ui/widgets/score_sheet.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(splashFactory: NoSplash.splashFactory),
    home: Scaffold(body: child),
  );
}

void main() {
  group('ScoreSheet', () {
    // Helper to create test categories
    List<ScoreCategory> createTestCategories() {
      return const [
        ScoreCategory(name: '9s', minScore: 0, maxScore: 30),
        ScoreCategory(name: '10s', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Js', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Qs', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Ks', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'As', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Three of a Kind', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Four of a Kind', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Full House', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Straight', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Flush', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Five of a Kind', minScore: 0, maxScore: 30),
        ScoreCategory(name: 'Super Bonus', minScore: 0, maxScore: 50),
      ];
    }

    Widget createScoreSheet({
      required List<ScoreCategory> categories,
      required List<int?> potentialScores,
      Function(int)? onCategorySelected,
      bool isTurnActive = true,
    }) {
      return createTestApp(
        ScoreSheet(
          categories: categories,
          potentialScores: potentialScores,
          onCategorySelected: onCategorySelected,
          isTurnActive: isTurnActive,
        ),
      );
    }

    group('displays all categories', () {
      testWidgets('displays all 12 category names', (
        WidgetTester tester,
      ) async {
        final categories = createTestCategories();

        await tester.pumpWidget(
          createScoreSheet(
            categories: categories,
            potentialScores: List.filled(12, 0),
          ),
        );

        expect(find.text('9s'), findsOneWidget);
        expect(find.text('10s'), findsOneWidget);
        expect(find.text('Js'), findsOneWidget);
        expect(find.text('Qs'), findsOneWidget);
        expect(find.text('Ks'), findsOneWidget);
        expect(find.text('As'), findsOneWidget);
        expect(find.text('Three of a Kind'), findsOneWidget);
        expect(find.text('Four of a Kind'), findsOneWidget);
        expect(find.text('Full House'), findsOneWidget);
        expect(find.text('Straight'), findsOneWidget);
        expect(find.text('Flush'), findsOneWidget);
        expect(find.text('Five of a Kind'), findsOneWidget);
      });

      testWidgets('upper section shows 6 pair categories', (
        WidgetTester tester,
      ) async {
        final categories = createTestCategories();

        await tester.pumpWidget(
          createScoreSheet(
            categories: categories,
            potentialScores: List.filled(13, 0),
          ),
        );

        expect(find.text('Upper Section'), findsOneWidget);
        expect(find.text('9s'), findsOneWidget);
        expect(find.text('10s'), findsOneWidget);
        expect(find.text('Js'), findsOneWidget);
        expect(find.text('Qs'), findsOneWidget);
        expect(find.text('Ks'), findsOneWidget);
        expect(find.text('As'), findsOneWidget);
      });

      testWidgets('lower section shows 6 combination categories', (
        WidgetTester tester,
      ) async {
        final categories = createTestCategories();

        await tester.pumpWidget(
          createScoreSheet(
            categories: categories,
            potentialScores: List.filled(13, 0),
          ),
        );

        expect(find.text('Lower Section'), findsOneWidget);
        expect(find.text('Three of a Kind'), findsOneWidget);
        expect(find.text('Four of a Kind'), findsOneWidget);
        expect(find.text('Full House'), findsOneWidget);
        expect(find.text('Straight'), findsOneWidget);
        expect(find.text('Flush'), findsOneWidget);
        expect(find.text('Five of a Kind'), findsOneWidget);
      });
    });

    group('shows potential scores', () {
      testWidgets('displays potential scores for available categories', (
        WidgetTester tester,
      ) async {
        final categories = createTestCategories();
        final potentialScores = [15, 20, 10, 25, 30, 5, 12, 18, 22, 28, 15, 30];

        await tester.pumpWidget(
          createScoreSheet(
            categories: categories,
            potentialScores: potentialScores,
          ),
        );

        expect(find.text('15'), findsWidgets);
        expect(find.text('20'), findsOneWidget);
        expect(find.text('10'), findsOneWidget);
        expect(find.text('25'), findsOneWidget);
        expect(find.text('30'), findsWidgets);
        expect(find.text('5'), findsOneWidget);
        expect(find.text('12'), findsOneWidget);
        expect(find.text('18'), findsOneWidget);
        expect(find.text('22'), findsOneWidget);
        expect(find.text('28'), findsOneWidget);
      });

      testWidgets('scored categories show actual score in blue box', (
        WidgetTester tester,
      ) async {
        final categories = createTestCategories();
        final potentialScores = List<int?>.generate(12, (index) => null);

        await tester.pumpWidget(
          createScoreSheet(
            categories: categories,
            potentialScores: potentialScores,
          ),
        );

        expect(find.text('0'), findsNWidgets(13));
      });

      testWidgets('disabled categories are grayed out', (
        WidgetTester tester,
      ) async {
        final categories = createTestCategories();
        final potentialScores = List.filled(12, 0);

        await tester.pumpWidget(
          createScoreSheet(
            categories: categories,
            potentialScores: potentialScores,
            isTurnActive: false,
          ),
        );

        final categoryRows = find.byType(InkWell);
        expect(categoryRows, findsWidgets);

        for (int i = 0; i < 6; i++) {
          final row = tester.widget<InkWell>(categoryRows.at(i));
          expect(
            row.onTap,
            isNull,
            reason: 'Category $i should be disabled when turn is not active',
          );
        }
      });
    });

    group('category selection', () {
      testWidgets('tap on available category triggers callback', (
        WidgetTester tester,
      ) async {
        final categories = createTestCategories();
        final potentialScores = List.filled(13, 0);
        int? selectedCategoryIndex;

        await tester.pumpWidget(
          createScoreSheet(
            categories: categories,
            potentialScores: potentialScores,
            onCategorySelected: (int index) {
              selectedCategoryIndex = index;
            },
            isTurnActive: true,
          ),
        );

        await tester.tap(find.text('9s').first);
        await tester.pump();

        expect(selectedCategoryIndex, equals(0));
      });

      testWidgets('tap on scored category does not trigger callback', (
        WidgetTester tester,
      ) async {
        final categories = createTestCategories();
        final potentialScores = List<int?>.generate(12, (index) => null);
        int? selectedCategoryIndex;

        await tester.pumpWidget(
          createScoreSheet(
            categories: categories,
            potentialScores: potentialScores,
            onCategorySelected: (int index) {
              selectedCategoryIndex = index;
            },
            isTurnActive: true,
          ),
        );

        await tester.tap(find.text('9s').first);
        await tester.pump();

        expect(
          selectedCategoryIndex,
          isNull,
          reason: 'Scored categories should not be selectable',
        );
      });

      testWidgets(
        'tap on unavailable category when turn inactive does not trigger callback',
        (WidgetTester tester) async {
          final categories = createTestCategories();
          final potentialScores = List.filled(12, 0);
          int? selectedCategoryIndex;

          await tester.pumpWidget(
            createScoreSheet(
              categories: categories,
              potentialScores: potentialScores,
              onCategorySelected: (int index) {
                selectedCategoryIndex = index;
              },
              isTurnActive: false,
            ),
          );

          await tester.tap(find.text('9s').first);
          await tester.pump();

          expect(
            selectedCategoryIndex,
            isNull,
            reason: 'Categories should not be selectable when turn is inactive',
          );
        },
      );
    });
  });
}
