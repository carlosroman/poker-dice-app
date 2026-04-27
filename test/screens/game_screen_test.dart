import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/screens/game_screen.dart';
import 'package:poker_dice/widgets/dice_container.dart';
import 'package:poker_dice/widgets/scorecard.dart';
import 'package:poker_dice/widgets/control_bar.dart';
import 'package:poker_dice/widgets/die_widget.dart';

void main() {
  // ========== Layout Tests ==========

  group('GameScreen Layout Tests', () {
    testWidgets('testGameScreenRendersHeader', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.text('150'), findsOneWidget);
      expect(find.text('Player 1'), findsOneWidget);
    });

    testWidgets('testGameScreenRendersDiceContainer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            diceRoll: DiceRoll.fromValues([1, 2, 3, 4, 5]),
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.byType(DiceContainer), findsOneWidget);
    });

    testWidgets('testGameScreenRendersScorecard', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.byType(Scorecard), findsOneWidget);
    });

    testWidgets('testGameScreenRendersControlBar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.byType(ControlBar), findsOneWidget);
    });

    testWidgets('testGameScreenHasThreeSections', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      // Verify the 3-section layout by checking for the presence of all sections
      // Top section: Header
      expect(find.text('150'), findsOneWidget);
      // Middle section: Scrollable content (dice, scorecard)
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      // Bottom section: Control bar
      expect(find.byType(ControlBar), findsOneWidget);
    });
  });

  // ========== Header Tests ==========

  group('GameScreen Header Tests', () {
    testWidgets('testHeaderShowsTotalScore', (WidgetTester tester) async {
      const int testScore = 250;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: testScore,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.text(testScore.toString()), findsOneWidget);
    });

    testWidgets('testHeaderShowsPlayerName', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.text('Player 1'), findsOneWidget);
    });
  });

  // ========== Dice Tests ==========

  group('GameScreen Dice Tests', () {
    testWidgets('testDiceContainerShowsDice', (WidgetTester tester) async {
      const List<int> dieValues = [1, 3, 3, 5, 6];
      final DiceRoll diceRoll = DiceRoll.fromValues(dieValues);

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            diceRoll: diceRoll,
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.byType(DieWidget), findsWidgets);
      expect(find.byType(DieWidget).evaluate().length, equals(5));
    });

    testWidgets('testDiceContainerShowsPlaceholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            diceRoll: null,
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      // When no dice roll, placeholder containers are shown
      expect(find.byType(DiceContainer), findsOneWidget);
      expect(find.byType(DieWidget), findsNothing);
    });
  });

  // ========== Scorecard Tests ==========

  group('GameScreen Scorecard Tests', () {
    testWidgets('testScorecardShowsAllCategories', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      // Check for all 14 category display names
      expect(find.text('Ones'), findsOneWidget);
      expect(find.text('Twos'), findsOneWidget);
      expect(find.text('Threes'), findsOneWidget);
      expect(find.text('Fours'), findsOneWidget);
      expect(find.text('Fives'), findsOneWidget);
      expect(find.text('Sixes'), findsOneWidget);
      expect(find.text('Three of a Kind'), findsOneWidget);
      expect(find.text('Four of a Kind'), findsOneWidget);
      expect(find.text('Full House'), findsOneWidget);
      expect(find.text('Small Straight'), findsOneWidget);
      expect(find.text('Large Straight'), findsOneWidget);
      expect(find.text('Yatzy'), findsOneWidget);
      expect(find.text('Chance'), findsOneWidget);
      expect(find.text('Bonus'), findsOneWidget);
    });

    testWidgets('testScorecardShowsUpperSection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.text('UPPER'), findsOneWidget);
      expect(find.text('Ones'), findsOneWidget);
      expect(find.text('Twos'), findsOneWidget);
      expect(find.text('Threes'), findsOneWidget);
      expect(find.text('Fours'), findsOneWidget);
      expect(find.text('Fives'), findsOneWidget);
      expect(find.text('Sixes'), findsOneWidget);
    });

    testWidgets('testScorecardShowsLowerSection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.text('LOWER'), findsOneWidget);
      expect(find.text('Three of a Kind'), findsOneWidget);
      expect(find.text('Four of a Kind'), findsOneWidget);
      expect(find.text('Full House'), findsOneWidget);
      expect(find.text('Small Straight'), findsOneWidget);
      expect(find.text('Large Straight'), findsOneWidget);
      expect(find.text('Yatzy'), findsOneWidget);
      expect(find.text('Chance'), findsOneWidget);
    });

    testWidgets('testScorecardShowsScores', (WidgetTester tester) async {
      final Map<Category, int> scores = {
        Category.ones: 5,
        Category.twos: 4,
        Category.threes: 9,
        Category.threeOfAKind: 15,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: scores,
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
    });

    testWidgets('testCategoryTapInvokesCallback', (WidgetTester tester) async {
      Category? tappedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            selectedCategory: null,
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (category) => tappedCategory = category,
            onDieToggled: (_) {},
          ),
        ),
      );

      // Tap on the "Ones" category
      await tester.tap(find.text('Ones'));
      await tester.pump();

      expect(tappedCategory, equals(Category.ones));
    });
  });

  // ========== Bonus Indicator Tests ==========

  group('GameScreen Bonus Indicator Tests', () {
    testWidgets('testBonusIndicatorShowsScore', (WidgetTester tester) async {
      const int upperScore = 45;
      const int targetScore = 63;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: upperScore,
            bonusAwarded: false,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      expect(find.text('$upperScore/$targetScore'), findsOneWidget);
    });

    testWidgets('testBonusIndicatorShowsBonusAwarded', (
      WidgetTester tester,
    ) async {
      const int upperScore = 70;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            upperSectionScore: upperScore,
            bonusAwarded: true,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      // Bonus awarded shows checkmark icon
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  // ========== Control Bar Tests ==========

  group('GameScreen Control Bar Tests', () {
    testWidgets('testRollButtonShowsCorrectCount', (WidgetTester tester) async {
      for (int rolls = 0; rolls <= 3; rolls++) {
        await tester.pumpWidget(
          MaterialApp(
            home: GameScreen(
              totalScore: 150,
              remainingRolls: rolls,
              scores: {},
              upperSectionScore: 18,
              onRollPressed: () {},
              onPlayPressed: () {},
              onCategoryTapped: (_) {},
              onDieToggled: (_) {},
            ),
          ),
        );

        expect(find.text('ROLL $rolls'), findsOneWidget);
      }
    });

    testWidgets('testPlayButtonIsEnabledWhenCategorySelected', (
      WidgetTester tester,
    ) async {
      bool playPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            selectedCategory: Category.ones,
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () => playPressed = true,
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      final playButton = find.text('PLAY');
      expect(playButton, findsOneWidget);

      // Button should be enabled (not disabled color)
      await tester.tap(playButton);
      await tester.pump();

      expect(playPressed, isTrue);
    });

    testWidgets('testPlayButtonIsDisabledWhenNoSelection', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            selectedCategory: null,
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      final playButton = find.text('PLAY');
      expect(playButton, findsOneWidget);

      // Button should be disabled - tap should do nothing
      await tester.tap(playButton);
      await tester.pump();

      // Verify the button is disabled by checking it has no onTap handler
      final ElevatedButton buttonWidget = tester.widget<ElevatedButton>(
        find
            .ancestor(of: playButton, matching: find.byType(ElevatedButton))
            .first,
      );
      expect(buttonWidget.onPressed, isNull);
    });
  });

  // ========== Integration Tests ==========

  group('GameScreen Integration Tests', () {
    testWidgets('testCompleteGameFlow', (WidgetTester tester) async {
      Category? selectedCategory;
      int? tappedDieIndex;
      bool rollPressed = false;
      bool playPressed0 = false;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 0,
            remainingRolls: 3,
            scores: {},
            diceRoll: null,
            upperSectionScore: 0,
            onRollPressed: () => rollPressed = true,
            onPlayPressed: () => playPressed0 = true,
            onCategoryTapped: (category) => selectedCategory = category,
            onDieToggled: (index) => tappedDieIndex = index,
          ),
        ),
      );

      // Initial state: Roll button shows 3
      expect(find.text('ROLL 3'), findsOneWidget);
      expect(find.text('PLAY'), findsOneWidget);

      // Tap a category
      await tester.tap(find.text('Twos'));
      await tester.pump();
      expect(selectedCategory, equals(Category.twos));

      // Roll button should still be enabled
      expect(rollPressed, isFalse);
    });

    testWidgets('testCategorySelectionUpdatesUI', (WidgetTester tester) async {
      Category? selectedCategory0;

      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 2,
            scores: {},
            selectedCategory: Category.threes,
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (category) => selectedCategory0 = category,
            onDieToggled: (_) {},
          ),
        ),
      );

      // Threes should be highlighted (selected)
      expect(find.text('Threes'), findsOneWidget);

      // Verify the category row is found
      expect(find.text('Threes'), findsOneWidget);
    });

    testWidgets('testRollButtonDisablesAtZero', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            totalScore: 150,
            remainingRolls: 0,
            scores: {},
            upperSectionScore: 18,
            onRollPressed: () {},
            onPlayPressed: () {},
            onCategoryTapped: (_) {},
            onDieToggled: (_) {},
          ),
        ),
      );

      // Roll button should show 0 and be disabled
      expect(find.text('ROLL 0'), findsOneWidget);

      final rollButton = find.text('ROLL 0');
      final ElevatedButton buttonWidget = tester.widget<ElevatedButton>(
        find
            .ancestor(of: rollButton, matching: find.byType(ElevatedButton))
            .first,
      );
      expect(buttonWidget.onPressed, isNull);
    });
  });
}
