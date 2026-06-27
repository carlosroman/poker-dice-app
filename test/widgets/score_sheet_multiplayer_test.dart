/// Multiplayer tests for [ScoreSheet].
///
/// Validates multi-player score display, player totals, and
/// category selection in multiplayer mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/widgets/score_sheet.dart';

void main() {
  group('ScoreSheet - Multiplayer', () {
    late List<Dice> dice;
    late Map<ScoreCategory, int> scoredCategories;
    late List<ScoreCategory> selectedCategories;

    setUp(() {
      dice = List.generate(5, (_) => Dice(value: 1));
      scoredCategories = {};
      selectedCategories = [];
    });

    testWidgets('displays all score categories', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ScoreSheet(
              dice: dice,
              scoredCategories: scoredCategories,
              onCategorySelect: (category) {
                selectedCategories.add(category);
              },
            ),
          ),
        ),
      );

      // Assert
      for (final category in ScoreCategory.values) {
        expect(find.text(category.displayName), findsOneWidget);
      }
    });

    testWidgets('shows scores for current player', (tester) async {
      // Arrange
      scoredCategories[ScoreCategory.aces] = 3;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ScoreSheet(
              dice: dice,
              scoredCategories: scoredCategories,
              onCategorySelect: (category) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('displays all player score sheets when provided', (tester) async {
      // Arrange
      final playerScoredCategories = <int, Map<ScoreCategory, int?>>{
        0: {ScoreCategory.aces: 5},
        1: {ScoreCategory.aces: 3},
      };

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 400,
            height: 600,
            child: Material(
              child: ScoreSheet(
              dice: dice,
              scoredCategories: scoredCategories,
              onCategorySelect: (category) {},
              playerCount: 2,
              playerScoredCategories: playerScoredCategories,
            ),
          ),
        ),
      ),
    );

      // Assert: both players' scores are displayed
      expect(find.text('5'), findsWidgets);
      expect(find.text('3'), findsWidgets);
    });

    testWidgets('category selection triggers callback', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ScoreSheet(
              dice: dice,
              scoredCategories: scoredCategories,
              onCategorySelect: (category) {
                selectedCategories.add(category);
              },
            ),
          ),
        ),
      );

      // Act: tap on Aces category
      await tester.tap(find.text('Aces'));
      await tester.pumpAndSettle();

      // Assert
      expect(selectedCategories, contains(ScoreCategory.aces));
    });

    testWidgets('disabled categories are not selectable', (tester) async {
      // Arrange
      scoredCategories[ScoreCategory.aces] = 3;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ScoreSheet(
              dice: dice,
              scoredCategories: scoredCategories,
              onCategorySelect: (category) {
                selectedCategories.add(category);
              },
            ),
          ),
        ),
      );

      // Assert: already-scored category should not trigger callback when tapped
      await tester.tap(find.text('Aces'));
      await tester.pumpAndSettle();
      expect(selectedCategories, isEmpty);
    });

    testWidgets('shows potential scores based on dice', (tester) async {
      // Arrange
      dice = [
        Dice(value: 1),
        Dice(value: 1),
        Dice(value: 1),
        Dice(value: 2),
        Dice(value: 2),
      ];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            child: ScoreSheet(
              dice: dice,
              scoredCategories: scoredCategories,
              onCategorySelect: (category) {},
            ),
          ),
        ),
      );

      // Assert: potential score for aces should be 3
      expect(find.text('3'), findsWidgets);
    });
  });
}
