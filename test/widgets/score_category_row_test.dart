import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/widgets/score_category_row.dart';

void main() {
  group('ScoreCategoryRow', () {
    Widget buildCategoryRow({
      Category category = Category.ones,
      int? score,
      bool isSelected = false,
      required void Function(Category) onTap,
    }) {
      return ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ScoreCategoryRow(
              category: category,
              score: score,
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

    testWidgets('shows dash for unscored category', (tester) async {
      await tester.pumpWidget(buildCategoryRow(onTap: (_) {}));
      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('shows score for scored category', (tester) async {
      await tester.pumpWidget(buildCategoryRow(score: 15, onTap: (_) {}));
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
  });
}
