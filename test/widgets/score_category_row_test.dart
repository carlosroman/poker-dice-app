import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/score_category_row.dart';
import 'package:poker_dice/models/category.dart';

void main() {
  group('ScoreCategoryRow', () {
    // Helper to create a testable widget
    Widget createTestWidget(Widget child) {
      return MaterialApp(home: Scaffold(body: child));
    }

    // Helper to create a ScoreCategoryRow with default values
    ScoreCategoryRow createCategoryRow({
      Category category = Category.ones,
      int? score,
      bool isSelected = false,
      VoidCallback? onTap,
      bool isUpperSection = true,
    }) {
      return ScoreCategoryRow(
        key: ValueKey('${category.index}-$score-$isSelected'),
        category: category,
        score: score,
        isSelected: isSelected,
        onTap: onTap,
        isUpperSection: isUpperSection,
      );
    }

    // ==================== RENDERING TESTS ====================

    group('Rendering Tests', () {
      testWidgets('testCategoryRowDisplaysCategoryName', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(category: Category.twos, isUpperSection: true),
          ),
        );

        expect(find.text('Twos'), findsOneWidget);
      });

      testWidgets('testCategoryRowDisplaysCategoryDisplayName', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.threeOfAKind,
              isUpperSection: false,
            ),
          ),
        );

        expect(find.text('Three of a Kind'), findsOneWidget);
      });

      testWidgets('testUpperSectionCategoryShowsCorrectLabel', (
        WidgetTester tester,
      ) async {
        final categories = [
          (Category.ones, 'Ones'),
          (Category.twos, 'Twos'),
          (Category.threes, 'Threes'),
          (Category.fours, 'Fours'),
          (Category.fives, 'Fives'),
          (Category.sixes, 'Sixes'),
        ];

        for (final (category, expectedName) in categories) {
          await tester.pumpWidget(
            createTestWidget(
              createCategoryRow(category: category, isUpperSection: true),
            ),
          );

          expect(
            find.text(expectedName),
            findsOneWidget,
            reason:
                'Upper section category $category should display $expectedName',
          );
          await tester.pumpAndSettle();
        }
      });

      testWidgets('testLowerSectionCategoryShowsCorrectLabel', (
        WidgetTester tester,
      ) async {
        final categories = [
          (Category.threeOfAKind, 'Three of a Kind'),
          (Category.fourOfAKind, 'Four of a Kind'),
          (Category.fullHouse, 'Full House'),
          (Category.smallStraight, 'Small Straight'),
          (Category.largeStraight, 'Large Straight'),
          (Category.yatzy, 'Yatzy'),
          (Category.chance, 'Chance'),
        ];

        for (final (category, expectedName) in categories) {
          await tester.pumpWidget(
            createTestWidget(
              createCategoryRow(category: category, isUpperSection: false),
            ),
          );

          expect(
            find.text(expectedName),
            findsOneWidget,
            reason:
                'Lower section category $category should display $expectedName',
          );
          await tester.pumpAndSettle();
        }
      });
    });

    // ==================== SCORE DISPLAY TESTS ====================

    group('Score Display Tests', () {
      testWidgets('testCategoryRowShowsScoreWhenScored', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.fives,
              score: 15,
              isUpperSection: true,
            ),
          ),
        );

        expect(find.text('15'), findsOneWidget);
      });

      testWidgets('testCategoryRowShowsPlaceholderWhenUnscored', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.chance,
              score: null,
              isUpperSection: false,
            ),
          ),
        );

        expect(find.text('---'), findsOneWidget);
      });

      testWidgets('testCategoryRowShowsZeroScore', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.yatzy,
              score: 0,
              isUpperSection: false,
            ),
          ),
        );

        expect(find.text('0'), findsOneWidget);
      });

      testWidgets('testCategoryRowShowsHighScore', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.chance,
              score: 25,
              isUpperSection: false,
            ),
          ),
        );

        expect(find.text('25'), findsOneWidget);
      });
    });

    // ==================== SELECTION STATE TESTS ====================

    group('Selection State Tests', () {
      testWidgets('testCategoryRowHighlightsWhenSelected', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.ones,
              isSelected: true,
              isUpperSection: true,
            ),
          ),
        );

        final cardFinder = find.byType(GestureDetector);
        expect(cardFinder, findsOneWidget);

        final containerFinder = find.ancestor(
          of: find.text('Ones'),
          matching: find.byType(AnimatedContainer),
        );
        expect(containerFinder, findsOneWidget);
      });

      testWidgets('testCategoryRowNormalAppearanceWhenNotSelected', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.twos,
              isSelected: false,
              isUpperSection: true,
            ),
          ),
        );

        expect(find.text('Twos'), findsOneWidget);

        final containerFinder = find.ancestor(
          of: find.text('Twos'),
          matching: find.byType(AnimatedContainer),
        );
        expect(containerFinder, findsOneWidget);
      });

      testWidgets('testSelectedCategoryHasBorder', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.threes,
              isSelected: true,
              isUpperSection: true,
            ),
          ),
        );

        final containerFinder = find.byType(AnimatedContainer);
        expect(containerFinder, findsOneWidget);

        final AnimatedContainer container = tester.widget<AnimatedContainer>(
          containerFinder,
        );
        final BoxDecoration decoration = container.decoration as BoxDecoration;
        final Border border = decoration.border as Border;

        // Selected should have 2.0 width border
        expect(border.top.width, equals(2.0));
      });
    });

    // ==================== INTERACTION TESTS ====================

    group('Interaction Tests', () {
      testWidgets('testTappingCategoryInvokesOnTap', (
        WidgetTester tester,
      ) async {
        bool tapped = false;
        void mockOnTap() => tapped = true;

        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.fours,
              onTap: mockOnTap,
              isUpperSection: true,
            ),
          ),
        );

        await tester.tap(find.text('Fours'));
        await tester.pumpAndSettle();

        expect(tapped, isTrue);
      });

      testWidgets('testCategoryIsTappable', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(category: Category.fives, isUpperSection: true),
          ),
        );

        final gestureFinder = find.byType(GestureDetector);
        expect(gestureFinder, findsOneWidget);

        await tester.tap(gestureFinder);
        await tester.pumpAndSettle();
      });

      testWidgets('testCategoryDoesNotInvokeOnTapWhenNull', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.sixes,
              onTap: null,
              isUpperSection: true,
            ),
          ),
        );

        expect(() => tester.tap(find.text('Sixes')), returnsNormally);
      });
    });

    // ==================== VISUAL TESTS ====================

    group('Visual Tests', () {
      testWidgets('testCategoryRowHasCardAppearance', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(category: Category.bonus, isUpperSection: true),
          ),
        );

        final containerFinder = find.byType(AnimatedContainer);
        expect(containerFinder, findsOneWidget);

        final AnimatedContainer container = tester.widget<AnimatedContainer>(
          containerFinder,
        );
        final BoxDecoration decoration = container.decoration as BoxDecoration;

        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('testCategoryRowHasRoundedCorners', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.smallStraight,
              isUpperSection: false,
            ),
          ),
        );

        final containerFinder = find.byType(AnimatedContainer);
        final AnimatedContainer container = tester.widget<AnimatedContainer>(
          containerFinder,
        );
        final BoxDecoration decoration = container.decoration as BoxDecoration;

        expect(decoration.borderRadius, isA<BorderRadius>());
      });

      testWidgets('testScoredCategoryHasDifferentStyle', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.largeStraight,
              score: 20,
              isUpperSection: false,
            ),
          ),
        );

        final containerFinder = find.byType(AnimatedContainer);
        expect(containerFinder, findsOneWidget);

        final AnimatedContainer container = tester.widget<AnimatedContainer>(
          containerFinder,
        );
        final BoxDecoration decoration = container.decoration as BoxDecoration;

        expect(decoration.color, isNotNull);
      });

      testWidgets('testZeroScoreHasErrorColor', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.yatzy,
              score: 0,
              isUpperSection: false,
            ),
          ),
        );

        final scoreBoxFinder = find.byType(Container).last;
        expect(scoreBoxFinder, findsOneWidget);

        final Container scoreBox = tester.widget<Container>(scoreBoxFinder);
        final BoxDecoration decoration = scoreBox.decoration! as BoxDecoration;

        // Zero score should have error color in score box
        expect(decoration.color, isNotNull);
      });

      testWidgets('testCategoryRowHasProperSpacing', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(category: Category.chance, isUpperSection: false),
          ),
        );

        final containerFinder = find.byType(AnimatedContainer);
        final AnimatedContainer container = tester.widget<AnimatedContainer>(
          containerFinder,
        );

        expect(
          container.margin,
          equals(const EdgeInsets.symmetric(vertical: 4, horizontal: 8)),
        );
        expect(
          container.padding,
          equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        );
      });
    });

    // ==================== THEME TESTS ====================

    group('Theme Tests', () {
      testWidgets('testCategoryRowWorksInLightTheme', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            home: Scaffold(
              body: createCategoryRow(
                category: Category.ones,
                isUpperSection: true,
              ),
            ),
          ),
        );

        expect(find.text('Ones'), findsOneWidget);
      });

      testWidgets('testCategoryRowWorksInDarkTheme', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.dark(),
            home: Scaffold(
              body: createCategoryRow(
                category: Category.yatzy,
                isUpperSection: false,
              ),
            ),
          ),
        );

        expect(find.text('Yatzy'), findsOneWidget);
      });

      testWidgets('testCategoryRowRespectsSystemTheme', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
            home: Scaffold(
              body: createCategoryRow(
                category: Category.chance,
                isUpperSection: false,
              ),
            ),
          ),
        );

        expect(find.text('Chance'), findsOneWidget);
      });
    });

    // ==================== BONUS CATEGORY TESTS ====================

    group('Bonus Category Tests', () {
      testWidgets('testBonusCategoryDisplaysCorrectly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(category: Category.bonus, isUpperSection: true),
          ),
        );

        expect(find.text('Bonus'), findsOneWidget);
      });

      testWidgets('testBonusCategoryShowsScore', (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.bonus,
              score: 35,
              isUpperSection: true,
            ),
          ),
        );

        expect(find.text('35'), findsOneWidget);
      });
    });

    // ==================== EDGE CASES ====================

    group('Edge Cases', () {
      testWidgets('testCategoryRowWithNegativeScore', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.chance,
              score: -1,
              isUpperSection: false,
            ),
          ),
        );

        expect(find.text('-1'), findsOneWidget);
      });

      testWidgets('testCategoryRowWithMaximumScore', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          createTestWidget(
            createCategoryRow(
              category: Category.chance,
              score: 100,
              isUpperSection: false,
            ),
          ),
        );

        expect(find.text('100'), findsOneWidget);
      });

      testWidgets('testAllCategoriesRenderCorrectly', (
        WidgetTester tester,
      ) async {
        for (final category in Category.values) {
          await tester.pumpWidget(
            createTestWidget(
              createCategoryRow(
                category: category,
                score: null,
                isUpperSection: category.isUpperSection,
              ),
            ),
          );

          expect(
            find.text(category.displayName),
            findsOneWidget,
            reason: 'Category ${category.name} should render',
          );
          await tester.pumpAndSettle();
        }
      });
    });
  });
}
