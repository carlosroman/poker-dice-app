import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/services/dice_service.dart';

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

  group('GameProvider', () {
    test('initial game state is correct', () {
      final state = container.read(gameStateProvider);

      expect(state.currentRollsRemaining, equals(3));
      expect(state.diceRoll, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.scores, isEmpty);
      expect(state.totalScore, equals(0));
      expect(state.isGameOver, isFalse);
    });

    test('rollDice decrements counter and sets dice', () async {
      await notifier.rollDice();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(2),
      );
      expect(
        container.read(gameStateProvider).diceRoll,
        isNotNull,
      );
      expect(
        container.read(gameStateProvider).diceRoll!.length,
        equals(5),
      );

      await notifier.rollDice();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(1),
      );

      await notifier.rollDice();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(0),
      );
    });

    test('rollDice sets isRolling to false after animation', () async {
      await notifier.rollDice();
      expect(
        container.read(gameStateProvider).isRolling,
        isFalse,
      );
    });

    test('rollDice creates dice with values 1-6', () async {
      await notifier.rollDice();
      final dice = container.read(gameStateProvider).diceRoll!;

      expect(dice.length, equals(5));
      for (final value in dice) {
        expect(value, inInclusiveRange(1, 6));
      }
    });

    test('selectCategory updates selection', () {
      notifier.selectCategory('ones');
      expect(
        container.read(gameStateProvider).selectedCategory,
        equals('ones'),
      );

      notifier.selectCategory('yatzy');
      expect(
        container.read(gameStateProvider).selectedCategory,
        equals('yatzy'),
      );
    });

    test('selectCategory null clears selection', () {
      notifier.selectCategory('ones');
      expect(
        container.read(gameStateProvider).selectedCategory,
        equals('ones'),
      );

      notifier.selectCategory(null);
      expect(
        container.read(gameStateProvider).selectedCategory,
        isNull,
      );
    });

    test('scoreCategory adds score to state', () {
      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      expect(container.read(gameStateProvider).scores['ones'], isNotNull);
    });

    test('scoreCategory resets rolls', () async {
      await notifier.rollDice();
      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(3),
      );
    });

    test('scoreCategory clears dice and selection', () async {
      await notifier.rollDice();
      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      final state = container.read(gameStateProvider);
      expect(state.diceRoll, isNull);
      expect(state.selectedCategory, isNull);
    });

    test('newGame resets state', () async {
      await notifier.rollDice();
      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      notifier.newGame();

      final state = container.read(gameStateProvider);
      expect(state.currentRollsRemaining, equals(3));
      expect(state.diceRoll, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.totalScore, equals(0));
      expect(state.isGameOver, isFalse);
    });

    test('isGameOver is true when all categories scored', () {
      var state = const GameState();
      for (final cat in Category.values) {
        state = state.addScore(cat.name, 10);
      }

      final notifierWithScores = GameNotifier(initialState: state);
      expect(notifierWithScores.state.isGameOver, isTrue);
    });

    test('resetTurn clears turn state', () async {
      await notifier.rollDice();
      notifier.selectCategory('ones');

      notifier.resetTurn();

      final state = container.read(gameStateProvider);
      expect(state.currentRollsRemaining, equals(3));
      expect(state.diceRoll, isNull);
      expect(state.selectedCategory, isNull);
      expect(state.isRolling, isFalse);
    });

    test('decrementRolls reduces remaining rolls', () {
      notifier.decrementRolls();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(2),
      );

      notifier.decrementRolls();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(1),
      );
    });

    test('full turn simulation', () async {
      // Roll dice
      await notifier.rollDice();
      expect(
        container.read(gameStateProvider).currentRollsRemaining,
        equals(2),
      );
      expect(
        container.read(gameStateProvider).diceRoll,
        isNotNull,
      );

      // Select and score a category
      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      final state = container.read(gameStateProvider);
      expect(state.scores['ones'], isNotNull);
      expect(state.currentRollsRemaining, equals(3));
      expect(state.diceRoll, isNull);
      expect(state.selectedCategory, isNull);
    });

    test('GameNotifier accepts custom DiceService', () {
      final customService = DiceService();
      final customNotifier = GameNotifier(diceService: customService);

      expect(customNotifier, isNotNull);
    });

    test('GameNotifier accepts initial state', () {
      const initialState = GameState(currentRollsRemaining: 2);
      final customNotifier = GameNotifier(initialState: initialState);

      expect(customNotifier.state.currentRollsRemaining, equals(2));
    });
  });
}
