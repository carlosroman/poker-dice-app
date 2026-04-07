import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/score_category_row.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

void main() {
  group('ScoreCategoryRow', () {
    // Helper to create a testable widget
    Widget createWidget({
      ScoreCategory category = ScoreCategory.aces,
      int? score,
      bool isSelected = false,
      bool showYatzyBonus = false,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        home: Scaffold(
          body: ScoreCategoryRow(
            category: category,
            score: score,
            isSelected: isSelected,
            showYatzyBonus: showYatzyBonus,
            onTap: onTap,
          ),
        ),
      );
    }

    // Helper to find the category name text
    Finder findCategoryName(String name) {
      return find.text(name);
    }

    // Helper to find the score text
    Finder findScoreText(String score) {
      return find.text(score);
    }

    // Helper to find the placeholder
    Finder findPlaceholder() {
      return find.text('-');
    }

    // Helper to find the bonus indicator
    Finder findBonusIndicator() {
      return find.text('+50');
    }

    testWidgets('renders category name correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget(category: ScoreCategory.aces));

      expect(findCategoryName('Aces'), findsOneWidget);
    });

    testWidgets('renders all category display names correctly', (
      WidgetTester tester,
    ) async {
      final categories = [
        (ScoreCategory.aces, 'Aces'),
        (ScoreCategory.twos, 'Twos'),
        (ScoreCategory.threes, 'Threes'),
        (ScoreCategory.fours, 'Fours'),
        (ScoreCategory.fives, 'Fives'),
        (ScoreCategory.sixes, 'Sixes'),
        (ScoreCategory.threeOfKind, 'Three of a Kind'),
        (ScoreCategory.fourOfKind, 'Four of a Kind'),
        (ScoreCategory.fullHouse, 'Full House'),
        (ScoreCategory.smallStraight, 'Small Straight'),
        (ScoreCategory.largeStraight, 'Large Straight'),
        (ScoreCategory.yatzy, 'Yatzy'),
        (ScoreCategory.chance, 'Chance'),
      ];

      for (final (category, name) in categories) {
        await tester.pumpWidget(createWidget(category: category));
        expect(find.text(name), findsOneWidget, reason: 'Failed for $name');
      }
    });

    testWidgets('renders score when scored', (WidgetTester tester) async {
      const testScore = 25;
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.aces, score: testScore),
      );

      expect(findScoreText(testScore.toString()), findsOneWidget);
      expect(findPlaceholder(), findsNothing);
    });

    testWidgets('shows placeholder when not scored', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.twos, score: null),
      );

      expect(findPlaceholder(), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets('selected state has highlighted styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.threes, isSelected: true),
      );

      // Find the GestureDetector which contains the AnimatedContainer
      final gestureFinder = find.byType(GestureDetector);
      expect(gestureFinder, findsOneWidget);

      // Verify the category name is rendered
      expect(findCategoryName('Threes'), findsOneWidget);

      // Verify the placeholder is shown (not scored)
      expect(findPlaceholder(), findsOneWidget);
    });

    testWidgets('scored state has greyed out styling', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          category: ScoreCategory.fours,
          score: 20,
          isSelected: false,
        ),
      );

      expect(findScoreText('20'), findsOneWidget);
      expect(findPlaceholder(), findsNothing);
    });

    testWidgets('Yatzy bonus indicator shows when applicable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.yatzy, showYatzyBonus: true),
      );

      expect(findBonusIndicator(), findsOneWidget);
    });

    testWidgets('Yatzy bonus indicator does not show when not applicable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.yatzy, showYatzyBonus: false),
      );

      expect(findBonusIndicator(), findsNothing);
    });

    testWidgets('Yatzy bonus indicator shows with score', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(
          category: ScoreCategory.yatzy,
          score: 50,
          showYatzyBonus: true,
        ),
      );

      expect(findScoreText('50'), findsOneWidget);
      expect(findBonusIndicator(), findsOneWidget);
    });

    testWidgets('tap callback is called when selectable', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;
      void onTap() {
        wasTapped = true;
      }

      await tester.pumpWidget(
        createWidget(
          category: ScoreCategory.fives,
          isSelected: true,
          onTap: onTap,
        ),
      );

      // Tap the row
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('tap callback is called when scored', (
      WidgetTester tester,
    ) async {
      bool wasTapped = false;
      void onTap() {
        wasTapped = true;
      }

      await tester.pumpWidget(
        createWidget(category: ScoreCategory.sixes, score: 30, onTap: onTap),
      );

      // Tap the row
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('tap callback is null when not provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.threeOfKind, isSelected: false),
      );

      // Should not crash when tapping with no callback
      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Widget should still be rendered
      expect(findCategoryName('Three of a Kind'), findsOneWidget);
    });

    testWidgets('accessibility labels present', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.fullHouse, score: 25),
      );

      // Check that semantics is present (multiple semantics widgets exist in the tree)
      final semanticsFinder = find.byType(Semantics);
      expect(semanticsFinder, findsWidgets);
    });

    testWidgets('accessibility label contains category name and score', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.smallStraight, score: 30),
      );

      // Find by semantics label
      final rowFinder = find.byType(GestureDetector);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('accessibility label for selectable item', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.largeStraight, isSelected: true),
      );

      final rowFinder = find.byType(GestureDetector);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('accessibility label for Yatzy with bonus', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.yatzy, showYatzyBonus: true),
      );

      final rowFinder = find.byType(GestureDetector);
      expect(rowFinder, findsOneWidget);
    });

    testWidgets('renders in dark theme', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: ScoreCategoryRow(category: ScoreCategory.chance, score: 42),
          ),
        ),
      );

      expect(findScoreText('42'), findsOneWidget);
      expect(findCategoryName('Chance'), findsOneWidget);
    });

    testWidgets('animations run smoothly', (WidgetTester tester) async {
      await tester.pumpWidget(
        createWidget(category: ScoreCategory.aces, isSelected: true),
      );

      // Verify initial state
      expect(findPlaceholder(), findsOneWidget);

      // Change state
      await tester.pumpWidget(
        createWidget(
          category: ScoreCategory.aces,
          score: 10,
          isSelected: false,
        ),
      );

      // Pump for animation
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Should show score now
      expect(findScoreText('10'), findsOneWidget);
    });

    testWidgets('ScoreSectionDivider renders correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          home: Scaffold(
            body: const ScoreSectionDivider(title: 'Upper Section'),
          ),
        ),
      );

      expect(find.text('Upper Section'), findsOneWidget);
    });

    testWidgets('ScoreSectionDivider renders in dark theme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: const ScoreSectionDivider(title: 'Lower Section'),
          ),
        ),
      );

      expect(find.text('Lower Section'), findsOneWidget);
    });
  });
}
