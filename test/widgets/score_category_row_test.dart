import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/animations/score_increment_animation.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/widgets/score_category_row.dart';

void main() {
  group('ScoreCategoryRow', () {
    Widget buildCategoryRow({
      Category category = Category.ones,
      int? score,
      int? potentialScore,
      bool isSelected = false,
      required void Function(Category) onTap,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ScoreCategoryRow(
              category: category,
              score: score,
              potentialScore: potentialScore,
              isSelected: isSelected,
              onTap: onTap,
            ),
          ),
        ),
      );
    }

    testWidgets('renders category display name', (tester) async {
      await tester.pumpWidget(buildCategoryRow(onTap: (_) {}));
      expect(find.text(Category.ones.displayName), findsOneWidget);
    });

    testWidgets('shows dash for unscored category with no potential score', (tester) async {
      await tester.pumpWidget(buildCategoryRow(onTap: (_) {}));
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('shows potential score when provided and not scored', (tester) async {
      await tester.pumpWidget(
        buildCategoryRow(potentialScore: 12, onTap: (_) {}),
      );
      expect(find.text('12'), findsOneWidget);
      expect(find.text('-'), findsNothing);
    });

    testWidgets('potential score is displayed in italic style', (tester) async {
      await tester.pumpWidget(
        buildCategoryRow(potentialScore: 12, onTap: (_) {}),
      );
      final textWidget = tester.widget<Text>(find.text('12'));
      expect(textWidget.style?.fontStyle, FontStyle.italic);
    });

    testWidgets('shows AnimatedScoreWidget for scored category, not potential', (tester) async {
      await tester.pumpWidget(
        buildCategoryRow(score: 15, potentialScore: 12, onTap: (_) {}),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedScoreWidget), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      // Potential score should not appear when category is scored
      expect(find.text('12'), findsNothing);
    });

    testWidgets('shows AnimatedScoreWidget for scored category', (tester) async {
      await tester.pumpWidget(buildCategoryRow(score: 15, onTap: (_) {}));
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedScoreWidget), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped and not scored', (tester) async {
      Category? tappedCategory;
      await tester.pumpWidget(
        buildCategoryRow(onTap: (c) => tappedCategory = c),
      );
      await tester.tap(find.byType(ScoreCategoryRow));
      expect(tappedCategory, Category.ones);
    });

    testWidgets('calls onTap when tapped with potential score but not scored', (tester) async {
      Category? tappedCategory;
      await tester.pumpWidget(
        buildCategoryRow(potentialScore: 12, onTap: (c) => tappedCategory = c),
      );
      await tester.tap(find.byType(ScoreCategoryRow));
      expect(tappedCategory, Category.ones);
    });

    testWidgets('does not call onTap when already scored', (tester) async {
      Category? tappedCategory;
      await tester.pumpWidget(
        buildCategoryRow(score: 10, onTap: (c) => tappedCategory = c),
      );
      await tester.tap(find.byType(ScoreCategoryRow));
      expect(tappedCategory, isNull);
    });

    testWidgets('applies selected styling when selected', (tester) async {
      await tester.pumpWidget(
        buildCategoryRow(isSelected: true, onTap: (_) {}),
      );
      // When selected, text should have bold weight
      final textWidget = tester.widget<Text>(
        find.text(Category.ones.displayName),
      );
      expect(textWidget.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('uses normal weight when not selected', (tester) async {
      await tester.pumpWidget(
        buildCategoryRow(isSelected: false, onTap: (_) {}),
      );
      final textWidget = tester.widget<Text>(
        find.text(Category.ones.displayName),
      );
      expect(textWidget.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('potential score 0 shows as 0 not dash', (tester) async {
      await tester.pumpWidget(
        buildCategoryRow(potentialScore: 0, onTap: (_) {}),
      );
      expect(find.text('0'), findsOneWidget);
      expect(find.text('-'), findsNothing);
    });
  });
}
