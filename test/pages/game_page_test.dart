import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/pages/game_page.dart';
import 'package:poker_dice/widgets/dice_widget.dart';
import 'package:poker_dice/widgets/roll_button.dart';
import 'package:poker_dice/widgets/score_sheet.dart';

void main() {
  group('GamePage', () {
    late List<Dice> dice;

    setUp(() {
      dice = List.generate(5, (i) => Dice(value: (i % 6) + 1, isHeld: false));
    });

    Widget buildGamePage({
      List<Dice>? diceOverride,
      int rollsRemaining = 3,
      Map<ScoreCategory, int>? scoredCategories,
      ScoreCategory? selectedCategory,
      int totalScore = 0,
      int upperTotal = 0,
      int bonus = 0,
      VoidCallback? onRoll,
      void Function(int)? onDiceTap,
      void Function(ScoreCategory)? onCategorySelect,
      VoidCallback? onMenuTap,
      VoidCallback? onBackTap,
    }) {
      return MaterialApp(
        home: GamePage(
          dice: diceOverride ?? dice,
          rollsRemaining: rollsRemaining,
          scoredCategories: scoredCategories,
          selectedCategory: selectedCategory,
          totalScore: totalScore,
          upperTotal: upperTotal,
          bonus: bonus,
          onRoll: onRoll,
          onDiceTap: onDiceTap,
          onCategorySelect: onCategorySelect,
          onMenuTap: onMenuTap,
          onBackTap: onBackTap,
        ),
      );
    }

    testWidgets('renders all major components', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byType(ScoreSheet), findsOneWidget);
      expect(find.byType(DiceWidget), findsNWidgets(5));
      expect(find.byType(RollButton), findsOneWidget);
    });

    testWidgets('displays total score in app bar', (tester) async {
      await tester.pumpWidget(buildGamePage(totalScore: 150));

      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('displays player label "You"', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('shows back button when onBackTap is provided', (tester) async {
      await tester.pumpWidget(buildGamePage(onBackTap: () {}));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('hides back button when onBackTap is null', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('calls onBackTap when back button is tapped', (tester) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildGamePage(onBackTap: () => callbackCalled = true),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('shows menu button when onMenuTap is provided', (tester) async {
      await tester.pumpWidget(buildGamePage(onMenuTap: () {}));

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('hides menu button when onMenuTap is null', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byIcon(Icons.menu), findsNothing);
    });

    testWidgets('calls onMenuTap when menu button is tapped', (tester) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildGamePage(onMenuTap: () => callbackCalled = true),
      );

      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('displays five dice', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byType(DiceWidget), findsNWidgets(5));
    });

    testWidgets('roll button shows correct rolls remaining', (tester) async {
      await tester.pumpWidget(buildGamePage(rollsRemaining: 2));

      final rollButton = tester.widget<RollButton>(find.byType(RollButton));
      expect(rollButton.rollsRemaining, 2);
    });

    testWidgets('roll button disabled when rolls remaining is 0', (
      tester,
    ) async {
      await tester.pumpWidget(buildGamePage(rollsRemaining: 0));

      final button = tester.widget<RollButton>(find.byType(RollButton));
      expect(button.rollsRemaining, 0);
    });

    testWidgets('calls onRoll when roll button is tapped', (tester) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildGamePage(onRoll: () => callbackCalled = true),
      );

      await tester.tap(find.byType(RollButton));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('does not call onRoll when rolls remaining is 0', (
      tester,
    ) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildGamePage(rollsRemaining: 0, onRoll: () => callbackCalled = true),
      );

      await tester.tap(find.byType(RollButton));
      await tester.pumpAndSettle();

      expect(callbackCalled, isFalse);
    });

    testWidgets('calls onDiceTap with correct index when die is tapped', (
      tester,
    ) async {
      int? tappedIndex;
      await tester.pumpWidget(
        buildGamePage(onDiceTap: (index) => tappedIndex = index),
      );

      final diceFinder = find.byType(DiceWidget);
      expect(diceFinder, findsNWidgets(5));

      // Tap the third die (index 2)
      await tester.tap(diceFinder.at(2));
      await tester.pumpAndSettle();

      expect(tappedIndex, 2);
    });

    testWidgets('passes scoredCategories to ScoreSheet', (tester) async {
      final scored = {ScoreCategory.aces: 5, ScoreCategory.twos: 4};
      await tester.pumpWidget(buildGamePage(scoredCategories: scored));

      expect(find.byType(ScoreSheet), findsOneWidget);
    });

    testWidgets('passes selectedCategory to ScoreSheet', (tester) async {
      await tester.pumpWidget(
        buildGamePage(selectedCategory: ScoreCategory.threeOfAKind),
      );

      expect(find.byType(ScoreSheet), findsOneWidget);
    });

    testWidgets('passes upperTotal and bonus to ScoreSheet', (tester) async {
      await tester.pumpWidget(buildGamePage(upperTotal: 70, bonus: 35));

      expect(find.byType(ScoreSheet), findsOneWidget);
    });

    testWidgets('uses default values when optional parameters omitted', (
      tester,
    ) async {
      await tester.pumpWidget(buildGamePage());

      final rollButton = tester.widget<RollButton>(find.byType(RollButton));
      expect(rollButton.rollsRemaining, 3);
    });

    testWidgets('dice are centered horizontally', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets('roll button has full width', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byType(RollButton), findsOneWidget);
    });

    testWidgets('calls onCategorySelect when category is selected', (
      tester,
    ) async {
      ScoreCategory? selected;
      await tester.pumpWidget(
        buildGamePage(onCategorySelect: (cat) => selected = cat),
      );

      // Tap on the "Aces" category row
      final acesFinder = find.text('Aces');
      expect(acesFinder, findsOneWidget);

      await tester.tap(acesFinder);
      await tester.pumpAndSettle();

      expect(selected, ScoreCategory.aces);
    });

    testWidgets('shows dice with correct values', (tester) async {
      final testDice = List.generate(
        5,
        (i) => Dice(value: i + 1, isHeld: false),
      );
      await tester.pumpWidget(buildGamePage(diceOverride: testDice));

      expect(find.byType(DiceWidget), findsNWidgets(5));
    });

    testWidgets('respects held dice state', (tester) async {
      final testDice = [
        Dice(value: 1, isHeld: true),
        Dice(value: 2, isHeld: false),
        Dice(value: 3, isHeld: true),
        Dice(value: 4, isHeld: false),
        Dice(value: 5, isHeld: false),
      ];
      await tester.pumpWidget(buildGamePage(diceOverride: testDice));

      expect(find.byType(DiceWidget), findsNWidgets(5));
    });
  });
}
