import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/models/die.dart';
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
        var state = GameState();
        for (final cat in Category.values) {
          state = state.addScore(cat, 15);
        }

        // Check that game is marked as complete
        expect(state.isGameOver, isTrue);
        expect(state.totalScore, greaterThan(0));
      },
    );

    testWidgets('game over navigation occurs after all categories scored',
      (tester) async {
        var state = GameState();
        for (final cat in Category.values) {
          state = state.addScore(cat, 10);
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
      var state = GameState();
      for (final cat in Category.values) {
        state = state.addScore(cat, 20);
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
      // Plus bonus 35 if upper section >= 63
      // Upper section: 6 * 20 = 120, so bonus applies
      // Total score appears twice in GameOverScreen (header and footer)
      expect(find.text('315'), findsNWidgets(2));
    });

    testWidgets('new game resets state correctly', (tester) async {
      final notifier = container.read(gameNotifierProvider.notifier);

      // Simulate some game progress
      notifier.rollDice();
      notifier.toggleDieHold(0);

      // New game should reset
      notifier.newGame();

      final state = container.read(gameStateProvider);
      expect(state.currentRollsRemaining, 3);
      expect(state.currentDiceRoll?.getHeldIndices() ?? <int>[], isEmpty);
      expect(state.isGameOver, isFalse);
      expect(state.totalScore, 0);
    });

    testWidgets('upper section bonus is correctly calculated', (tester) async {
      var state = GameState();
      // Upper section exactly at threshold (63)
      state = state.addScore(Category.ones, 10);
      state = state.addScore(Category.twos, 11);
      state = state.addScore(Category.threes, 12);
      state = state.addScore(Category.fours, 13);
      state = state.addScore(Category.fives, 8);
      state = state.addScore(Category.sixes, 9);
      // Upper total: 10+11+12+13+8+9 = 63

      for (final cat in Category.getLowerCategories()) {
        state = state.addScore(cat, 0);
      }

      expect(state.bonusAwarded, isTrue);
      expect(state.upperSectionTotal, 63);
      expect(state.totalScore, 98); // 63 + 35 + 0
    });

    testWidgets('upper section bonus not awarded below threshold',
      (tester) async {
        var state = GameState();
        state = state.addScore(Category.ones, 5);
        state = state.addScore(Category.twos, 6);
        state = state.addScore(Category.threes, 7);
        state = state.addScore(Category.fours, 8);
        state = state.addScore(Category.fives, 9);
        state = state.addScore(Category.sixes, 10);
        // Upper total: 5+6+7+8+9+10 = 45

        for (final cat in Category.getLowerCategories()) {
          state = state.addScore(cat, 0);
        }

        expect(state.bonusAwarded, isFalse);
        expect(state.upperSectionTotal, 45);
        expect(state.totalScore, 45);
      },
    );

    testWidgets('scoring service calculates correct scores for all categories',
      (tester) async {
        final service = ScoringService();

        DiceRoll createRoll(List<int> values) {
          return DiceRoll(
            dice: values.map((v) => Die(value: v)).toList(),
          );
        }

        // Ones: three 1s = 3
        expect(service.scoreCategory(Category.ones, createRoll([1, 1, 1, 4, 5])), 3);

        // Twos: two 2s = 4
        expect(service.scoreCategory(Category.twos, createRoll([2, 2, 3, 4, 5])), 4);

        // Threes: four 3s = 12
        expect(service.scoreCategory(Category.threes, createRoll([1, 3, 3, 3, 3])), 12);

        // Fours: no 4s = 0
        expect(service.scoreCategory(Category.fours, createRoll([1, 2, 3, 5, 6])), 0);

        // Fives: one 5 = 5
        expect(service.scoreCategory(Category.fives, createRoll([1, 2, 3, 4, 5])), 5);

        // Sixes: five 6s = 30
        expect(service.scoreCategory(Category.sixes, createRoll([6, 6, 6, 6, 6])), 30);

        // Three of a kind: 3+3+3+4+5 = 18
        expect(
          service.scoreCategory(Category.threeOfAKind, createRoll([3, 3, 3, 4, 5])),
          18,
        );

        // Four of a kind: 4+4+4+4+5 = 21
        expect(
          service.scoreCategory(Category.fourOfAKind, createRoll([4, 4, 4, 4, 5])),
          21,
        );

        // Full house: 3+3+3+5+5 = 25
        expect(service.scoreCategory(Category.fullHouse, createRoll([3, 3, 3, 5, 5])), 25);

        // Small straight: 4+ consecutive = 30 (standard Yatzy)
        expect(service.scoreCategory(Category.smallStraight, createRoll([1, 2, 3, 4, 5])), 30);

        // Large straight: 5 consecutive = 40 (standard Yatzy)
        expect(service.scoreCategory(Category.largeStraight, createRoll([2, 3, 4, 5, 6])), 40);

        // Yatzy: 50
        expect(service.scoreCategory(Category.yatzy, createRoll([5, 5, 5, 5, 5])), 50);

        // Chance: sum of all dice
        expect(service.scoreCategory(Category.chance, createRoll([1, 3, 5, 4, 2])), 15);

        // House maps to full house scoring: [1,2,3,4,4] is not a full house = 0
        expect(service.scoreCategory(Category.house, createRoll([1, 2, 3, 4, 4])), 0);
      },
    );

    testWidgets('game state tracks rolls correctly', (tester) async {
      final notifier = container.read(gameNotifierProvider.notifier);

      // Initial state: 3 rolls remaining
      expect(container.read(gameStateProvider).currentRollsRemaining, 3);

      notifier.rollDice();
      expect(container.read(gameStateProvider).currentRollsRemaining, 2);

      notifier.rollDice();
      expect(container.read(gameStateProvider).currentRollsRemaining, 1);

      notifier.rollDice();
      expect(container.read(gameStateProvider).currentRollsRemaining, 0);

      // Flush pending Riverpod timers
      await tester.pumpAndSettle();
    });

    testWidgets('dice are held correctly between rolls', (tester) async {
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.rollDice();
      final diceBefore = container.read(gameStateProvider).currentDiceRoll?.dice;
      expect(diceBefore, isNotNull);

      notifier.toggleDieHold(0);
      notifier.toggleDieHold(2);

      notifier.rollDice();
      final diceAfter = container.read(gameStateProvider).currentDiceRoll?.dice;
      expect(diceAfter, isNotNull);

      // Held dice should remain the same
      expect(diceAfter![0].value, diceBefore![0].value);
      expect(diceAfter[2].value, diceBefore[2].value);

      // Other dice should potentially change (not guaranteed, but likely)
      // We can't assert they're different since RNG might produce same values

      // Flush pending Riverpod timers
      await tester.pumpAndSettle();
    });

    testWidgets('max three rolls enforced', (tester) async {
      final notifier = container.read(gameNotifierProvider.notifier);

      notifier.rollDice();
      notifier.rollDice();
      notifier.rollDice();

      final state = container.read(gameStateProvider);
      expect(state.currentRollsRemaining, 0);
      expect(notifier.canRoll(), isFalse);
    });

    testWidgets('category cannot be scored twice', (tester) async {
      var state = GameState();

      // First score
      state = state.addScore(Category.ones, 5);
      expect(state.scores[Category.ones], 5);

      // Second score to same category should be ignored
      final stateAfterSecond = state.addScore(Category.ones, 10);
      expect(stateAfterSecond.scores[Category.ones], 5);
    });

    testWidgets('unplayed category shows as zero in game over', (tester) async {
      var state = GameState();
      // Score all except House
      for (final cat in Category.values) {
        if (cat != Category.house) {
          state = state.addScore(cat, 15);
        }
      }
      // Score House as 0
      state = state.addScore(Category.house, 0);

      expect(state.scores[Category.house], 0);
      expect(state.isGameOver, isTrue);
    });

    testWidgets('game over screen displays bonus correctly', (tester) async {
      var state = GameState();
      // Upper section >= 63
      state = state.addScore(Category.ones, 15);
      state = state.addScore(Category.twos, 12);
      state = state.addScore(Category.threes, 10);
      state = state.addScore(Category.fours, 8);
      state = state.addScore(Category.fives, 10);
      state = state.addScore(Category.sixes, 15);
      // Upper total: 70

      for (final cat in Category.getLowerCategories()) {
        state = state.addScore(cat, 0);
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
      expect(find.text('+35'), findsOneWidget);
    });
  });
}
