import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/die.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/services/scoring_service.dart';

void main() {
  late ProviderContainer container;
  late GameNotifier notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(gameNotifierProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  DiceRoll createRoll(List<int> values) {
    return DiceRoll(dice: values.map((v) => Die(value: v)).toList());
  }

  group('GameProvider', () {
    test('test_initial_game_state_is_correct', () {
      final state = container.read(gameStateProvider);

      expect(state.currentRollsRemaining, equals(3));
      expect(state.currentDiceRoll, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.scores.length, equals(14));
      expect(state.totalScore, equals(0));
      expect(state.isGameOver, isFalse);
    });

    test('test_roll_dice_decrements_counter', () {
      notifier.rollDice();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(2),
      );

      notifier.rollDice();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(1),
      );

      notifier.rollDice();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(0),
      );
    });

    test('test_roll_dice_creates_new_dice_roll', () {
      notifier.rollDice();
      final state = container.read(gameStateProvider);

      expect(state.currentDiceRoll, isNotNull);
      expect(state.currentDiceRoll!.dice.length, equals(5));
    });

    test('test_roll_dice_when_no_dice_exist', () {
      // Fresh state has no dice; first roll should create them
      final state = container.read(gameStateProvider);
      expect(state.currentDiceRoll, isNull);

      notifier.rollDice();

      final afterState = container.read(gameStateProvider);
      expect(afterState.currentDiceRoll, isNotNull);
      expect(afterState.currentDiceRoll!.dice.length, equals(5));
      expect(afterState.currentRollsRemaining, equals(2));
    });

    test('test_toggle_die_hold_toggles_state', () {
      final roll = createRoll([1, 2, 3, 4, 5]);
      notifier = GameNotifier(container.read(scoringServiceProvider));
      notifier.state = GameState(currentDiceRoll: roll);

      expect(notifier.state.currentDiceRoll!.dice[0].isHeld, isFalse);

      notifier.toggleDieHold(0);
      expect(notifier.state.currentDiceRoll!.dice[0].isHeld, isTrue);
      expect(notifier.state.currentDiceRoll!.dice[1].isHeld, isFalse);

      notifier.toggleDieHold(0);
      expect(notifier.state.currentDiceRoll!.dice[0].isHeld, isFalse);
    });

    test('test_select_category_updates_selection', () {
      notifier.selectCategory(Category.ones);
      expect(
        container.read(gameStateProvider).selectedCategory,
        equals(Category.ones),
      );

      notifier.selectCategory(Category.yatzy);
      expect(
        container.read(gameStateProvider).selectedCategory,
        equals(Category.yatzy),
      );
    });

    test('test_score_category_adds_score', () {
      final roll = createRoll([3, 3, 3, 1, 2]);
      notifier = GameNotifier(container.read(scoringServiceProvider));
      notifier.state = GameState(
        currentDiceRoll: roll,
        currentRollsRemaining: 2,
      );

      notifier.scoreCategory(Category.threes);

      expect(notifier.state.scores[Category.threes], equals(9));
    });

    test('test_score_category_resets_rolls', () {
      final roll = createRoll([1, 2, 3, 4, 5]);
      notifier = GameNotifier(container.read(scoringServiceProvider));
      notifier.state = GameState(
        currentDiceRoll: roll,
        currentRollsRemaining: 1,
      );

      notifier.scoreCategory(Category.chance);

      expect(notifier.state.currentRollsRemaining, equals(3));
    });

    test('test_score_all_categories_ends_game', () {
      // Start with a roll so we can score
      final roll = createRoll([1, 1, 1, 1, 1]);

      var state = GameState(currentDiceRoll: roll);
      final scoringService = ScoringService();
      for (final cat in Category.values) {
        final score = scoringService.scoreCategory(cat, roll);
        state = state.addScore(cat, score);
      }

      notifier = GameNotifier(container.read(scoringServiceProvider));
      notifier.state = state;

      expect(notifier.state.isGameOver, isTrue);
    });

    test('test_canRoll_returns_false_at_zero_rolls', () {
      notifier.rollDice();
      notifier.rollDice();
      notifier.rollDice();

      expect(notifier.canRoll(), isFalse);
    });

    test('test_canScore_returns_false_if_already_scored', () {
      final roll = createRoll([6, 6, 6, 6, 6]);
      notifier = GameNotifier(container.read(scoringServiceProvider));
      notifier.state = GameState(currentDiceRoll: roll);

      // Score sixes first
      notifier.scoreCategory(Category.sixes);
      expect(notifier.state.scores[Category.sixes], isNotNull);

      // Select the same category again
      notifier.selectCategory(Category.sixes);

      // Should not be able to score again
      expect(notifier.canScore(), isFalse);
    });

    test('test_newGame_resets_state', () {
      final roll = createRoll([1, 2, 3, 4, 5]);
      notifier = GameNotifier(container.read(scoringServiceProvider));
      notifier.state = GameState(
        currentDiceRoll: roll,
        currentRollsRemaining: 1,
      );
      notifier.state = notifier.state.addScore(Category.ones, 3);

      notifier.newGame();

      final state = notifier.state;
      expect(state.currentRollsRemaining, equals(3));
      expect(state.currentDiceRoll, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.totalScore, equals(0));
      expect(state.isGameOver, isFalse);
    });

    test('test_held_dice_remain_across_rolls', () {
      final roll = createRoll([1, 2, 3, 4, 5]);
      notifier = GameNotifier(container.read(scoringServiceProvider));
      notifier.state = GameState(
        currentDiceRoll: roll,
        currentRollsRemaining: 2,
      );

      // Hold the first die (value 1)
      notifier.toggleDieHold(0);
      final heldValue = notifier.state.currentDiceRoll!.dice[0].value;

      // Roll again
      notifier.rollDice();

      // Held die should retain its value
      expect(notifier.state.currentDiceRoll!.dice[0].value, equals(heldValue));
      expect(notifier.state.currentDiceRoll!.dice[0].isHeld, isTrue);
      expect(notifier.state.currentRollsRemaining, equals(1));
    });

    test('test_full_turn_simulation', () {
      // Simulate: roll -> hold some dice -> roll again -> select & score
      final roll = createRoll([3, 3, 1, 2, 4]);
      notifier = GameNotifier(container.read(scoringServiceProvider));
      notifier.state = GameState(
        currentDiceRoll: roll,
        currentRollsRemaining: 2,
      );

      // Hold the two 3s
      notifier.toggleDieHold(0);
      notifier.toggleDieHold(1);

      // Second roll (only unheld dice change)
      notifier.rollDice();
      expect(notifier.state.currentRollsRemaining, equals(1));
      expect(notifier.state.currentDiceRoll!.dice[0].value, equals(3));
      expect(notifier.state.currentDiceRoll!.dice[1].value, equals(3));

      // Select and score threes
      notifier.selectCategory(Category.threes);
      expect(notifier.canScore(), isTrue);

      notifier.scoreCategory(Category.threes);

      final state = notifier.state;
      expect(state.scores[Category.threes], isNotNull);
      expect(state.currentRollsRemaining, equals(3));
      expect(state.currentDiceRoll, isNull);
      expect(state.selectedCategory, isNull);
    });
  });
}
