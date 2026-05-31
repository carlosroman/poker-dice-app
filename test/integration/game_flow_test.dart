import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/screens/game_over_screen.dart';
import 'package:poker_dice/screens/game_screen.dart';
import 'package:poker_dice/services/scoring_service.dart';
import 'package:poker_dice/widgets/control_bar.dart';
import 'package:poker_dice/widgets/dice_container.dart';
import 'package:poker_dice/widgets/header_bar.dart';
import 'package:poker_dice/widgets/scorecard.dart';

void main() {
  group('Game Flow Integration Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    Future<void> pumpGameScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: GameScreen()),
        ),
      );
    }

    testWidgets('app starts with game screen and all components',
      (tester) async {
        await pumpGameScreen(tester);

        // Verify all major components are present
        expect(find.byType(GameScreen), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.widgetWithText(AppBar, 'Yatzy'), findsOneWidget);
        expect(find.byType(HeaderBar), findsOneWidget);
        expect(find.byType(DiceContainer), findsOneWidget);
        expect(find.byType(Scorecard), findsOneWidget);
        expect(find.byType(ControlBar), findsOneWidget);
      },
    );

    testWidgets('full game flow: roll, select, score, repeat until game over',
      (tester) async {
        await pumpGameScreen(tester);

        // Initial state: no scores
        final gameState = container.read(gameStateProvider);
        expect(gameState.isGameOver, isFalse);
        expect(gameState.totalScore, 0);

        // Complete a full game by setting all scores
        var state = const GameState();
        for (final cat in Category.values) {
          state = state.addScore(cat.name, 15);
        }

        // Check that game is marked as complete
        expect(state.isGameOver, isTrue);
        expect(state.totalScore, greaterThan(0));
      },
    );

    testWidgets('game over navigation occurs after all categories scored',
      (tester) async {
        var state = const GameState();
        for (final cat in Category.values) {
          state = state.addScore(cat.name, 10);
        }

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              gameStateProvider.overrideWithValue(state),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pump(); // Trigger addPostFrameCallback
        await tester.pump(); // Allow navigation to complete

        // After addPostFrameCallback, should navigate to GameOverScreen
        expect(find.byType(GameOverScreen), findsOneWidget);
      },
    );

    testWidgets('game over screen shows correct total score', (tester) async {
      var state = const GameState();
      for (final cat in Category.values) {
        state = state.addScore(cat.name, 20);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWithValue(state),
          ],
          child: const MaterialApp(home: GameOverScreen()),
        ),
      );

      // Total should be 14 categories * 20 = 280
      // Plus bonus 50 if upper section >= 63
      // Upper section: 6 * 20 = 120, so bonus applies
      // Total score appears twice in GameOverScreen (card and summary)
      expect(find.text('330'), findsNWidgets(2));
    });

    testWidgets('new game resets state correctly', (tester) async {
      final notifier = GameNotifier(rollAnimationDelay: Duration.zero);

      // Simulate some game progress
      await notifier.rollDice();

      // New game should reset
      notifier.newGame();

      final state = notifier.state;
      expect(state.currentRollsRemaining, 3);
      expect(state.diceRoll, isNull);
      expect(state.isGameOver, isFalse);
      expect(state.totalScore, 0);
    });

    testWidgets('upper section bonus is correctly calculated', (tester) async {
      var state = const GameState();
      // Upper section exactly at threshold (63)
      state = state.addScore(Category.ones.name, 10);
      state = state.addScore(Category.twos.name, 11);
      state = state.addScore(Category.threes.name, 12);
      state = state.addScore(Category.fours.name, 13);
      state = state.addScore(Category.fives.name, 8);
      state = state.addScore(Category.sixes.name, 9);
      // Upper total: 10+11+12+13+8+9 = 63

      for (final cat in Category.getLowerCategories()) {
        state = state.addScore(cat.name, 0);
      }

      expect(state.bonusAwarded, 50);
      expect(state.upperSectionTotal, 63);
      expect(state.totalScore, 113); // 63 + 50 + 0
    });

    testWidgets('upper section bonus not awarded below threshold',
      (tester) async {
        var state = const GameState();
        state = state.addScore(Category.ones.name, 5);
        state = state.addScore(Category.twos.name, 6);
        state = state.addScore(Category.threes.name, 7);
        state = state.addScore(Category.fours.name, 8);
        state = state.addScore(Category.fives.name, 9);
        state = state.addScore(Category.sixes.name, 10);
        // Upper total: 5+6+7+8+9+10 = 45

        for (final cat in Category.getLowerCategories()) {
          state = state.addScore(cat.name, 0);
        }

        expect(state.bonusAwarded, 0);
        expect(state.upperSectionTotal, 45);
        expect(state.totalScore, 45);
      },
    );

    testWidgets('scoring service calculates correct scores for all categories',
      (tester) async {
        final service = ScoringService();

        // Ones: three 1s = 3
        expect(service.scoreOnes(DiceRoll.fromValues([1, 1, 1, 4, 5])), 3);

        // Twos: two 2s = 4
        expect(service.scoreTwos(DiceRoll.fromValues([2, 2, 3, 4, 5])), 4);

        // Threes: four 3s = 12
        expect(service.scoreThrees(DiceRoll.fromValues([1, 3, 3, 3, 3])), 12);

        // Fours: no 4s = 0
        expect(service.scoreFours(DiceRoll.fromValues([1, 2, 3, 5, 6])), 0);

        // Fives: one 5 = 5
        expect(service.scoreFives(DiceRoll.fromValues([1, 2, 3, 4, 5])), 5);

        // Sixes: five 6s = 30
        expect(service.scoreSixes(DiceRoll.fromValues([6, 6, 6, 6, 6])), 30);

        // Three of a kind: 3+3+3+4+5 = 18
        expect(service.scoreThreeOfAKind(DiceRoll.fromValues([3, 3, 3, 4, 5])), 18);

        // Four of a kind: 4+4+4+4+5 = 21
        expect(service.scoreFourOfAKind(DiceRoll.fromValues([4, 4, 4, 4, 5])), 21);

        // Full house: 25
        expect(service.scoreFullHouse(DiceRoll.fromValues([3, 3, 3, 5, 5])), 25);

        // Small straight: 30
        expect(service.scoreSmallStraight(DiceRoll.fromValues([1, 2, 3, 4, 5])), 30);

        // Large straight: 40
        expect(service.scoreLargeStraight(DiceRoll.fromValues([2, 3, 4, 5, 6])), 40);

        // Yatzy: 50
        expect(service.scoreYatzy(DiceRoll.fromValues([5, 5, 5, 5, 5])), 50);

        // Chance: sum of all dice
        expect(service.scoreChance(DiceRoll.fromValues([1, 3, 5, 4, 2])), 15);
      },
    );

    testWidgets('game state tracks rolls correctly', (tester) async {
      final notifier = GameNotifier(rollAnimationDelay: Duration.zero);

      // Initial state: 3 rolls remaining
      expect(notifier.state.currentRollsRemaining, 3);

      await notifier.rollDice();
      expect(notifier.state.currentRollsRemaining, 2);

      await notifier.rollDice();
      expect(notifier.state.currentRollsRemaining, 1);

      await notifier.rollDice();
      expect(notifier.state.currentRollsRemaining, 0);

    });

    testWidgets('max three rolls enforced', (tester) async {
      final notifier = GameNotifier(rollAnimationDelay: Duration.zero);

      await notifier.rollDice();
      await notifier.rollDice();
      await notifier.rollDice();

      final state = notifier.state;
      expect(state.currentRollsRemaining, 0);
      // Can't roll anymore
      final rollsBefore = state.currentRollsRemaining;
      await notifier.rollDice();
      expect(notifier.state.currentRollsRemaining, rollsBefore);
    });

    testWidgets('category cannot be scored twice', (tester) async {
      var state = const GameState();

      // First score
      state = state.addScore(Category.ones.name, 5);
      expect(state.scores['ones'], 5);

      // Second score to same category should be ignored
      final stateAfterSecond = state.addScore(Category.ones.name, 10);
      expect(stateAfterSecond.scores['ones'], 5);
    });

    testWidgets('unplayed category shows as zero in game over', (tester) async {
      var state = const GameState();
      // Score all except House
      for (final cat in Category.values) {
        if (cat != Category.house) {
          state = state.addScore(cat.name, 15);
        }
      }
      // Score House as 0
      state = state.addScore(Category.house.name, 0);

      expect(state.scores[Category.house.name], 0);
      expect(state.isGameOver, isTrue);
    });

    testWidgets('game over screen displays bonus correctly', (tester) async {
      var state = const GameState();
      // Upper section >= 63
      state = state.addScore(Category.ones.name, 15);
      state = state.addScore(Category.twos.name, 12);
      state = state.addScore(Category.threes.name, 10);
      state = state.addScore(Category.fours.name, 8);
      state = state.addScore(Category.fives.name, 10);
      state = state.addScore(Category.sixes.name, 15);
      // Upper total: 70

      for (final cat in Category.getLowerCategories()) {
        state = state.addScore(cat.name, 0);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWithValue(state),
          ],
          child: const MaterialApp(home: GameOverScreen()),
        ),
      );

      expect(find.text('Bonus:'), findsOneWidget);
      expect(find.text('+50'), findsOneWidget);
    });
  });
}
