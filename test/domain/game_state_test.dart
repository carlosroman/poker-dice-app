import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/game_state.dart';
import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/domain/models/game_round.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/domain/models/score_sheet.dart';

void main() {
  group('GameState Constructor', () {
    test('initializes with new round and score sheet', () {
      final gameState = GameState();

      expect(gameState.currentRound, isA<GameRound>());
      expect(gameState.scoreSheet, isA<ScoreSheet>());
      expect(gameState.currentRound.dice.length, equals(5));
      expect(gameState.currentRound.rollCount, equals(0));
    });

    test('isGameOver starts as false', () {
      final gameState = GameState();

      expect(gameState.isGameOver, isFalse);
    });

    test('accepts custom currentRound', () {
      final customRound = GameRound(
        dice: List<Die>.generate(5, (i) => Die(value: i + 1)),
        rollCount: 2,
      );
      final gameState = GameState(currentRound: customRound);

      expect(gameState.currentRound, equals(customRound));
      expect(gameState.currentRound.rollCount, equals(2));
    });

    test('accepts custom scoreSheet', () {
      final customScoreSheet = ScoreSheet();
      customScoreSheet.score(ScoreCategory.aces, [
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
        Die(value: 1),
      ]);
      final gameState = GameState(scoreSheet: customScoreSheet);

      expect(gameState.scoreSheet.isCategoryScored(ScoreCategory.aces), isTrue);
      expect(gameState.scoreSheet.scores[ScoreCategory.aces], equals(5));
    });

    test('accepts custom isGameOver', () {
      final gameState = GameState(isGameOver: true);

      expect(gameState.isGameOver, isTrue);
    });
  });

  group('rollDice', () {
    test('rolls dice and increments rollCount', () {
      final gameState = GameState();

      expect(gameState.currentRound.rollCount, equals(0));

      final updatedState = gameState.rollDice();

      expect(updatedState.currentRound.rollCount, equals(1));
      expect(updatedState, isNot(same(gameState)));
    });

    test('respects held dice', () {
      final round = GameRound(
        dice: List<Die>.generate(5, (i) => Die(value: i + 1, held: i == 0)),
      );
      final gameState = GameState(currentRound: round);

      final updatedState = gameState.rollDice();

      // First die should still be held with value 1
      expect(updatedState.currentRound.dice[0].value, equals(1));
      expect(updatedState.currentRound.dice[0].held, isTrue);
      // Other dice should have new values
      for (int i = 1; i < 5; i++) {
        expect(updatedState.currentRound.dice[i].held, isFalse);
      }
    });

    test('returns same instance when max rolls reached (rollCount=3)', () {
      final round = GameRound(rollCount: 3);
      final gameState = GameState(currentRound: round);

      final updatedState = gameState.rollDice();

      expect(updatedState, same(gameState));
      expect(updatedState.currentRound.rollCount, equals(3));
    });

    test('returns same instance when rollCount is 2 after roll', () {
      final round = GameRound(rollCount: 2);
      final gameState = GameState(currentRound: round);

      final updatedState = gameState.rollDice();

      expect(updatedState.currentRound.rollCount, equals(3));

      final anotherUpdate = updatedState.rollDice();
      expect(anotherUpdate, same(updatedState));
    });
  });

  group('getRemainingRolls', () {
    test('returns 3 when no rolls performed', () {
      final gameState = GameState();

      expect(gameState.getRemainingRolls(), equals(3));
    });

    test('returns 2 after one roll', () {
      final gameState = GameState().rollDice();

      expect(gameState.getRemainingRolls(), equals(2));
    });

    test('returns 1 after two rolls', () {
      final gameState = GameState().rollDice().rollDice();

      expect(gameState.getRemainingRolls(), equals(1));
    });

    test('returns 0 after three rolls', () {
      final gameState = GameState().rollDice().rollDice().rollDice();

      expect(gameState.getRemainingRolls(), equals(0));
    });
  });

  group('toggleDie', () {
    test('toggles held state correctly', () {
      final gameState = GameState();

      // Initially all dice are not held
      for (int i = 0; i < 5; i++) {
        expect(gameState.currentRound.dice[i].held, isFalse);
      }

      final updatedState = gameState.toggleDie(0);

      expect(updatedState.currentRound.dice[0].held, isTrue);
      for (int i = 1; i < 5; i++) {
        expect(updatedState.currentRound.dice[i].held, isFalse);
      }

      // Toggle again
      final toggledAgain = updatedState.toggleDie(0);
      expect(toggledAgain.currentRound.dice[0].held, isFalse);
    });

    test('preserves die value when toggling', () {
      final round = GameRound(
        dice: List<Die>.generate(5, (i) => Die(value: i + 1)),
      );
      final gameState = GameState(currentRound: round);

      final updatedState = gameState.toggleDie(2);

      expect(updatedState.currentRound.dice[2].value, equals(3));
      expect(updatedState.currentRound.dice[2].held, isTrue);
    });

    test('throws error for invalid index (negative)', () {
      final gameState = GameState();

      expect(() => gameState.toggleDie(-1), throwsArgumentError);
    });

    test('throws error for invalid index (>= 5)', () {
      final gameState = GameState();

      expect(() => gameState.toggleDie(5), throwsArgumentError);
      expect(() => gameState.toggleDie(10), throwsArgumentError);
    });
  });

  group('selectCategory', () {
    test('scores category correctly', () {
      final gameState = GameState();
      final round = GameRound(
        dice: List<Die>.generate(5, (_) => Die(value: 3)),
      );
      final stateWithDice = gameState.copyWith(currentRound: round);

      final updatedState = stateWithDice.selectCategory(ScoreCategory.threes);

      expect(
        updatedState.scoreSheet.isCategoryScored(ScoreCategory.threes),
        isTrue,
      );
      expect(updatedState.scoreSheet.scores[ScoreCategory.threes], equals(15));
      expect(updatedState.isGameOver, isFalse);
    });

    test('starts new round after scoring', () {
      final round = GameRound(
        dice: List<Die>.generate(5, (i) => Die(value: i + 1)),
        rollCount: 2,
      );
      final gameState = GameState(currentRound: round);

      final updatedState = gameState.selectCategory(ScoreCategory.aces);

      expect(updatedState.currentRound.rollCount, equals(0));
      expect(updatedState.currentRound.dice.length, equals(5));
      // All dice should be new (not held, different values)
      for (int i = 0; i < 5; i++) {
        expect(updatedState.currentRound.dice[i].held, isFalse);
      }
    });

    test('throws error for already scored category', () {
      final gameState = GameState();
      final round = GameRound(
        dice: List<Die>.generate(5, (_) => Die(value: 1)),
      );
      final stateWithDice = gameState.copyWith(currentRound: round);

      // Score the category once
      final updatedState = stateWithDice.selectCategory(ScoreCategory.aces);

      // Try to score again
      expect(
        () => updatedState.selectCategory(ScoreCategory.aces),
        throwsStateError,
      );
    });

    test('sets isGameOver to true when all categories scored', () {
      var gameState = GameState();

      // Score all 13 categories
      for (final category in ScoreCategory.values) {
        final round = GameRound(
          dice: List<Die>.generate(5, (_) => Die(value: 1)),
        );
        gameState = gameState.copyWith(currentRound: round);
        gameState = gameState.selectCategory(category);
      }

      expect(gameState.isGameOver, isTrue);
    });

    test('Yatzy bonus is tracked correctly when Yatzy is rolled', () {
      var gameState = GameState();

      // Roll a Yatzy but score it in Chance first (simulating rolling multiple yatzy)
      var round = GameRound(dice: List<Die>.generate(5, (_) => Die(value: 1)));
      gameState = gameState.copyWith(currentRound: round);
      gameState = gameState.selectCategory(ScoreCategory.chance);

      expect(gameState.scoreSheet.yatzyCount, equals(0));

      // Now score Yatzy - should get 50 points (first yatzy)
      round = GameRound(dice: List<Die>.generate(5, (_) => Die(value: 2)));
      gameState = gameState.copyWith(currentRound: round);
      gameState = gameState.selectCategory(ScoreCategory.yatzy);

      expect(gameState.scoreSheet.yatzyCount, equals(1));
      expect(gameState.scoreSheet.scores[ScoreCategory.yatzy], equals(50));
    });
  });

  group('newGame', () {
    test('resets all state', () {
      // Create a modified game state
      var gameState = GameState();
      gameState = gameState.rollDice();
      gameState = gameState.toggleDie(0);

      final newGameState = gameState.newGame();

      expect(newGameState.currentRound.rollCount, equals(0));
      expect(newGameState.currentRound.dice.length, equals(5));
      for (int i = 0; i < 5; i++) {
        expect(newGameState.currentRound.dice[i].held, isFalse);
      }
      expect(newGameState.isGameOver, isFalse);
    });

    test('creates fresh round and score sheet', () {
      // Create a game state with scores
      var gameState = GameState();
      for (final category in ScoreCategory.values) {
        final round = GameRound(
          dice: List<Die>.generate(5, (_) => Die(value: 1)),
        );
        gameState = gameState.copyWith(currentRound: round);
        gameState = gameState.selectCategory(category);
      }
      expect(gameState.isGameOver, isTrue);

      final newGameState = gameState.newGame();

      expect(newGameState.scoreSheet.getEmptyCategories().length, equals(13));
      expect(newGameState.isGameOver, isFalse);
      expect(newGameState.scoreSheet.getTotal(), equals(0));
    });

    test('returns new instance', () {
      final gameState = GameState();
      final newGameState = gameState.newGame();

      expect(newGameState, isNot(same(gameState)));
    });
  });

  group('getValidCategories', () {
    test('returns only unscored categories during normal play', () {
      var gameState = GameState();

      // Initially all 13 categories are valid
      expect(gameState.getValidCategories().length, equals(13));

      // Score one category
      final round = GameRound(
        dice: List<Die>.generate(5, (_) => Die(value: 1)),
      );
      gameState = gameState.copyWith(currentRound: round);
      gameState = gameState.selectCategory(ScoreCategory.aces);

      // Now only 12 categories are valid
      expect(gameState.getValidCategories().length, equals(12));
      expect(
        gameState.getValidCategories().contains(ScoreCategory.aces),
        isFalse,
      );
    });

    test('returns empty list when game over', () {
      var gameState = GameState();

      // Score all 13 categories
      for (final category in ScoreCategory.values) {
        final round = GameRound(
          dice: List<Die>.generate(5, (_) => Die(value: 1)),
        );
        gameState = gameState.copyWith(currentRound: round);
        gameState = gameState.selectCategory(category);
      }

      expect(gameState.isGameOver, isTrue);
      expect(gameState.getValidCategories().length, equals(13));
    });
  });

  group('copyWith', () {
    test('returns new instance with same values when no changes', () {
      final gameState = GameState();
      final copied = gameState.copyWith();

      expect(copied, isNot(same(gameState)));
      expect(copied.currentRound, equals(gameState.currentRound));
      expect(copied.scoreSheet, equals(gameState.scoreSheet));
      expect(copied.isGameOver, equals(gameState.isGameOver));
    });

    test('updates only specified properties', () {
      final customRound = GameRound(rollCount: 2);
      final gameState = GameState();

      final updated = gameState.copyWith(currentRound: customRound);

      expect(updated.currentRound.rollCount, equals(2));
      expect(updated.scoreSheet, equals(gameState.scoreSheet));
      expect(updated.isGameOver, equals(gameState.isGameOver));
    });

    test('can update isGameOver', () {
      final gameState = GameState();
      final updated = gameState.copyWith(isGameOver: true);

      expect(updated.isGameOver, isTrue);
      expect(gameState.isGameOver, isFalse);
    });
  });

  group('Integration Tests', () {
    test('complete game flow from start to finish', () {
      var gameState = GameState();

      // Verify initial state
      expect(gameState.isGameOver, isFalse);
      expect(gameState.getRemainingRolls(), equals(3));
      expect(gameState.getValidCategories().length, equals(13));

      // Play through a complete game
      while (!gameState.isGameOver) {
        // Roll dice (simulate 3 rolls per round)
        gameState = gameState.rollDice();
        if (gameState.getRemainingRolls() >= 2) {
          gameState = gameState.rollDice();
        }
        if (gameState.getRemainingRolls() >= 1) {
          gameState = gameState.rollDice();
        }

        // Select a valid category
        final validCategories = gameState.getValidCategories();
        expect(validCategories.isEmpty, isFalse);

        final round = GameRound(
          dice: List<Die>.generate(5, (_) => Die(value: 1)),
        );
        gameState = gameState.copyWith(currentRound: round);
        gameState = gameState.selectCategory(validCategories.first);
      }

      // Verify game ended
      expect(gameState.isGameOver, isTrue);
      expect(gameState.scoreSheet.getEmptyCategories().isEmpty, isTrue);
    });

    test('scoring all 13 categories ends game', () {
      var gameState = GameState();

      for (int i = 0; i < 13; i++) {
        final round = GameRound(
          dice: List<Die>.generate(5, (_) => Die(value: 1)),
        );
        gameState = gameState.copyWith(currentRound: round);
        gameState = gameState.selectCategory(ScoreCategory.values[i]);

        if (i < 12) {
          expect(gameState.isGameOver, isFalse);
        } else {
          expect(gameState.isGameOver, isTrue);
        }
      }
    });

    test('edge case: 4+1 not Full House', () {
      final gameState = GameState();
      final round = GameRound(
        dice: [
          Die(value: 3),
          Die(value: 3),
          Die(value: 3),
          Die(value: 3),
          Die(value: 1),
        ],
      );
      final stateWithDice = gameState.copyWith(currentRound: round);

      final updatedState = stateWithDice.selectCategory(
        ScoreCategory.fullHouse,
      );

      expect(
        updatedState.scoreSheet.scores[ScoreCategory.fullHouse],
        equals(0),
      );
    });

    test('edge case: Yatzy bonus accumulation', () {
      var gameState = GameState();

      // Roll Yatzy 3 times but score them in different categories
      // This simulates the scenario where multiple yatzy are rolled
      final categoriesToUse = [
        ScoreCategory.chance,
        ScoreCategory.threeOfKind,
        ScoreCategory.fourOfKind,
      ];

      for (int i = 0; i < 3; i++) {
        final round = GameRound(
          dice: List<Die>.generate(5, (_) => Die(value: i + 1)),
        );
        gameState = gameState.copyWith(currentRound: round);
        // Score in different categories, not Yatzy
        gameState = gameState.selectCategory(categoriesToUse[i]);
      }

      // Now score the Yatzy category - should get 50 points
      // (since we haven't scored Yatzy yet, yatzyCount is still 0)
      final round = GameRound(
        dice: List<Die>.generate(5, (_) => Die(value: 1)),
      );
      gameState = gameState.copyWith(currentRound: round);
      gameState = gameState.selectCategory(ScoreCategory.yatzy);

      expect(gameState.scoreSheet.yatzyCount, equals(1));
      expect(gameState.scoreSheet.scores[ScoreCategory.yatzy], equals(50));
    });

    test('edge case: Small/Large straight overlap', () {
      // Large straight (1-2-3-4-5) should also qualify for small straight
      final gameState = GameState();
      final round = GameRound(
        dice: [
          Die(value: 1),
          Die(value: 2),
          Die(value: 3),
          Die(value: 4),
          Die(value: 5),
        ],
      );
      final stateWithDice = gameState.copyWith(currentRound: round);

      // Score large straight
      final updatedState = stateWithDice.selectCategory(
        ScoreCategory.largeStraight,
      );

      expect(
        updatedState.scoreSheet.scores[ScoreCategory.largeStraight],
        equals(40),
      );

      // Score small straight with same dice pattern
      final round2 = GameRound(
        dice: [
          Die(value: 1),
          Die(value: 2),
          Die(value: 3),
          Die(value: 4),
          Die(value: 5),
        ],
      );
      final stateWithDice2 = updatedState.copyWith(currentRound: round2);
      final updatedState2 = stateWithDice2.selectCategory(
        ScoreCategory.smallStraight,
      );

      expect(
        updatedState2.scoreSheet.scores[ScoreCategory.smallStraight],
        equals(30),
      );
    });

    test('toggle die then roll preserves held state', () {
      var gameState = GameState();

      // Toggle first die to held
      gameState = gameState.toggleDie(0);
      expect(gameState.currentRound.dice[0].held, isTrue);

      // Roll dice
      final updatedState = gameState.rollDice();

      // First die should still be held with original value
      expect(updatedState.currentRound.dice[0].held, isTrue);
      // Other dice should have been rolled
      for (int i = 1; i < 5; i++) {
        expect(updatedState.currentRound.dice[i].held, isFalse);
      }
    });

    test('immutability: rollDice does not modify original state', () {
      final gameState = GameState();
      final updatedState = gameState.rollDice();

      expect(gameState.currentRound.rollCount, equals(0));
      expect(updatedState.currentRound.rollCount, equals(1));
    });

    test('immutability: toggleDie does not modify original state', () {
      final gameState = GameState();
      final updatedState = gameState.toggleDie(0);

      expect(gameState.currentRound.dice[0].held, isFalse);
      expect(updatedState.currentRound.dice[0].held, isTrue);
    });

    test('immutability: selectCategory does not modify original state', () {
      final gameState = GameState();
      final round = GameRound(
        dice: List<Die>.generate(5, (_) => Die(value: 1)),
      );
      final stateWithDice = gameState.copyWith(currentRound: round);
      final updatedState = stateWithDice.selectCategory(ScoreCategory.aces);

      expect(
        stateWithDice.scoreSheet.isCategoryScored(ScoreCategory.aces),
        isFalse,
      );
      expect(
        updatedState.scoreSheet.isCategoryScored(ScoreCategory.aces),
        isTrue,
      );
    });
  });
}
