import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/bloc/game_bloc.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';

void main() {
  group('GameBloc', () {
    late GameBloc gameBloc;

    setUp(() {
      gameBloc = GameBloc();
    });

    tearDown(() {
      gameBloc.dispose();
    });

    group('Initialization', () {
      test('starts with a new game state', () {
        expect(gameBloc.value.isGameOver, isFalse);
        expect(gameBloc.value.currentRound.rollCount, 0);
        expect(gameBloc.value.scoreSheet.isComplete, isFalse);
      });

      test('starts with 5 dice', () {
        expect(gameBloc.value.diceValues.length, 5);
      });
    });

    group('rollDice', () {
      test('increments roll count', () {
        final initialState = gameBloc.value;
        gameBloc.rollDice();
        expect(gameBloc.value.currentRound.rollCount, 1);
        expect(
          gameBloc.value.currentRound.rollCount,
          greaterThan(initialState.currentRound.rollCount),
        );
      });

      test('does nothing if game is over', () {
        // Simulate game over state
        gameBloc = GameBloc(
          initialState: gameBloc.value.copyWith(isGameOver: true),
        );
        final rollCount = gameBloc.value.currentRound.rollCount;
        gameBloc.rollDice();
        expect(gameBloc.value.currentRound.rollCount, rollCount);
      });

      test('does nothing if max rolls reached', () {
        // Roll 3 times to reach max
        gameBloc.rollDice();
        gameBloc.rollDice();
        gameBloc.rollDice();

        final rollCount = gameBloc.value.currentRound.rollCount;
        gameBloc.rollDice();
        expect(gameBloc.value.currentRound.rollCount, rollCount);
      });
    });

    group('toggleDie', () {
      test('toggles die held state after roll', () {
        gameBloc.rollDice();
        final die0 = gameBloc.value.currentRound.dice[0];
        expect(die0.held, isFalse);

        gameBloc.toggleDie(0);
        expect(gameBloc.value.currentRound.dice[0].held, isTrue);

        gameBloc.toggleDie(0);
        expect(gameBloc.value.currentRound.dice[0].held, isFalse);
      });

      test('does nothing if game is over', () {
        gameBloc = GameBloc(
          initialState: gameBloc.value.copyWith(isGameOver: true),
        );
        final die0 = gameBloc.value.currentRound.dice[0];
        gameBloc.toggleDie(0);
        expect(gameBloc.value.currentRound.dice[0].held, die0.held);
      });

      test('does nothing before first roll', () {
        final initialState = gameBloc.value;
        gameBloc.toggleDie(0);
        expect(gameBloc.value, initialState);
      });
    });

    group('selectCategory', () {
      test('scores a category and updates score sheet', () {
        // First roll dice
        gameBloc.rollDice();

        final initialScore =
            gameBloc.value.scoreSheet.scores[ScoreCategory.aces];
        gameBloc.selectCategory(ScoreCategory.aces);

        expect(gameBloc.value.scoreSheet.scores[ScoreCategory.aces], isNotNull);
        expect(
          gameBloc.value.scoreSheet.scores[ScoreCategory.aces],
          isNot(equals(initialScore)),
        );
      });

      test('starts a new round after scoring', () {
        gameBloc.rollDice();

        gameBloc.selectCategory(ScoreCategory.aces);

        expect(gameBloc.value.currentRound.rollCount, 0);
      });

      test('sets game over when all categories are scored', () {
        // Score all categories
        for (final category in ScoreCategory.values) {
          gameBloc.rollDice();
          gameBloc.selectCategory(category);
        }

        expect(gameBloc.value.isGameOver, isTrue);
      });

      test('does nothing if game is over', () {
        gameBloc = GameBloc(
          initialState: gameBloc.value.copyWith(isGameOver: true),
        );
        final scoreSheet = gameBloc.value.scoreSheet;
        gameBloc.selectCategory(ScoreCategory.aces);
        expect(gameBloc.value.scoreSheet, scoreSheet);
      });
    });

    group('newGame', () {
      test('resets game state', () {
        // Modify state
        gameBloc.rollDice();
        gameBloc.rollDice();
        final rollCountBeforeSelect = gameBloc.value.currentRound.rollCount;
        gameBloc.selectCategory(ScoreCategory.aces);

        expect(rollCountBeforeSelect, greaterThan(0));

        gameBloc.newGame();

        expect(gameBloc.value.isGameOver, isFalse);
        expect(gameBloc.value.currentRound.rollCount, 0);
        expect(gameBloc.value.scoreSheet.isComplete, isFalse);
      });
    });

    group('getPotentialScore', () {
      test('returns potential score for unscored category', () {
        gameBloc.rollDice();
        final potential = gameBloc.getPotentialScore(ScoreCategory.aces);
        expect(potential, isA<int>());
        expect(potential, greaterThanOrEqualTo(0));
      });

      test('returns 0 for already scored category', () {
        gameBloc.rollDice();
        gameBloc.selectCategory(ScoreCategory.aces);

        final potential = gameBloc.getPotentialScore(ScoreCategory.aces);
        expect(potential, 0);
      });

      test('returns 0 if game is over', () {
        gameBloc = GameBloc(
          initialState: gameBloc.value.copyWith(isGameOver: true),
        );
        final potential = gameBloc.getPotentialScore(ScoreCategory.aces);
        expect(potential, 0);
      });
    });

    group('ValueNotifier behavior', () {
      test('notifies listeners on state change', () {
        var notifyCount = 0;
        gameBloc.addListener(() => notifyCount++);

        gameBloc.rollDice();
        expect(notifyCount, 1);

        gameBloc.toggleDie(0);
        expect(notifyCount, 2);

        gameBloc.newGame();
        expect(notifyCount, 3);
      });
    });
  });
}
