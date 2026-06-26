import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';

void main() {
  group('GameState', () {
    group('initial state', () {
      test('creates with default values', () {
        final state = GameState();

        expect(state.currentDice.length, 5);
        for (final die in state.currentDice) {
          expect(die.value, 0);
        }
        expect(state.rollsRemaining, 3);
        expect(state.status, GameStatus.active);
        expect(state.selectedCategory, isNull);
        expect(state.playerCount, 1);
        expect(state.currentPlayer, 0);
        expect(state.lastScoredCategory, isNull);
      });

      test('creates with custom dice', () {
        final dice = [
          Dice(value: 1),
          Dice(value: 2),
          Dice(value: 3),
          Dice(value: 4),
          Dice(value: 5),
        ];
        final state = GameState(currentDice: dice);

        expect(state.currentDice, dice);
      });

      test('throws on invalid dice count', () {
        final dice = [Dice(value: 1), Dice(value: 2), Dice(value: 3)];

        expect(() => GameState(currentDice: dice), throwsArgumentError);
      });

      test('throws on invalid player count', () {
        expect(() => GameState(playerCount: 0), throwsA(isA<AssertionError>()));
        expect(() => GameState(playerCount: 3), throwsA(isA<AssertionError>()));
      });

      test('throws on invalid current player index', () {
        expect(
          () => GameState(playerCount: 2, currentPlayer: 2),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('initial factory', () {
      test('creates initial state with default player count', () {
        final state = GameState.initial();

        expect(state.playerCount, 1);
        expect(state.currentPlayer, 0);
        expect(state.rollsRemaining, 3);
        expect(state.status, GameStatus.active);
      });

      test('creates initial state with specified player count', () {
        final state = GameState.initial(playerCount: 2);

        expect(state.playerCount, 2);
        expect(state.currentPlayer, 0);
        expect(state.scoredCategories.length, 2);
        expect(state.scoredCategories[0], isNotNull);
        expect(state.scoredCategories[1], isNotNull);
      });
    });

    group('scored categories', () {
      test('tracks scored categories per player', () {
        final scored = {ScoreCategory.aces: 3, ScoreCategory.twos: 2};
        final state = GameState(singlePlayerScoredCategories: scored);

        expect(state.currentPlayerScoredCategories[ScoreCategory.aces], 3);
        expect(state.currentPlayerScoredCategories[ScoreCategory.twos], 2);
        expect(state.currentPlayerScoredCategories[ScoreCategory.threes], null);
      });

      test('returns scored map with non-null values', () {
        final scored = {ScoreCategory.aces: 3, ScoreCategory.twos: null};
        final state = GameState(singlePlayerScoredCategories: scored);

        final scoredMap = state.scored;
        expect(scoredMap.length, 1);
        expect(scoredMap[ScoreCategory.aces], 3);
      });

      test('returns unscored categories', () {
        final scored = {ScoreCategory.aces: 3};
        final state = GameState(singlePlayerScoredCategories: scored);

        final unscored = state.unscoredCategories;
        expect(unscored, isNot(contains(ScoreCategory.aces)));
        expect(unscored, contains(ScoreCategory.twos));
      });

      test('totalScore sums all scored categories', () {
        final scored = {
          ScoreCategory.aces: 6,
          ScoreCategory.twos: 4,
          ScoreCategory.threes: 3,
        };
        final state = GameState(singlePlayerScoredCategories: scored);

        expect(state.totalScore, 13);
      });

      test('totalScore sums across all players', () {
        final scoredCategories = {
          0: {ScoreCategory.aces: 6, ScoreCategory.twos: 4},
          1: {ScoreCategory.aces: 3, ScoreCategory.twos: null},
        };
        final state = GameState(
          scoredCategories: scoredCategories,
          playerCount: 2,
        );

        expect(state.totalScore, 13); // 6 + 4 + 3
      });

      test('currentPlayerScore sums only current player scores', () {
        final scoredCategories = {
          0: {ScoreCategory.aces: 6, ScoreCategory.twos: 4},
          1: {ScoreCategory.aces: 3, ScoreCategory.twos: null},
        };
        final state = GameState(
          scoredCategories: scoredCategories,
          playerCount: 2,
          currentPlayer: 1,
        );

        expect(state.currentPlayerScore, 3);
      });
    });

    group('record score', () {
      test('records a score for the current player', () {
        final state = GameState();
        final newState = state.recordScore(ScoreCategory.aces, 6);

        expect(newState.currentPlayerScoredCategories[ScoreCategory.aces], 6);
        expect(newState.lastScoredCategory, ScoreCategory.aces);
      });

      test('throws when category already scored', () {
        final state = GameState(
          singlePlayerScoredCategories: {ScoreCategory.aces: 6},
        );

        expect(
          () => state.recordScore(ScoreCategory.aces, 3),
          throwsA(isA<StateError>()),
        );
      });

      test('completes game when all categories filled', () {
        final scored = {
          for (final category in ScoreCategory.values)
            if (category != ScoreCategory.aces) category: 0,
        };
        final state = GameState(singlePlayerScoredCategories: scored);
        final newState = state.recordScore(ScoreCategory.aces, 6);

        expect(newState.status, GameStatus.completed);
      });

      test('does not complete when other player has unscored categories', () {
        final player0 = {
          for (final category in ScoreCategory.values)
            if (category != ScoreCategory.sixes) category: 0,
        };
        final player1 = {
          for (final category in ScoreCategory.values)
            if (category != ScoreCategory.aces) category: 0,
        };
        final state = GameState(
          scoredCategories: {0: player0, 1: player1},
          playerCount: 2,
          currentPlayer: 1,
        );
        final newState = state.recordScore(ScoreCategory.aces, 6);

        expect(newState.status, GameStatus.active);
      });
    });

    group('switch player', () {
      test('switches to next player', () {
        final state = GameState.initial(playerCount: 2);
        final newState = state.switchPlayer();

        expect(newState.currentPlayer, 1);
      });

      test('switches back to first player', () {
        final state = GameState.initial(playerCount: 2);
        final newState = state.switchPlayer().switchPlayer();

        expect(newState.currentPlayer, 0);
      });

      test('returns same state for single player', () {
        final state = GameState.initial(playerCount: 1);
        final newState = state.switchPlayer();

        expect(newState, state);
      });
    });

    group('roll dice', () {
      test('updates dice and decrements rolls', () {
        final state = GameState();
        final newDice = [
          Dice(value: 1),
          Dice(value: 2),
          Dice(value: 3),
          Dice(value: 4),
          Dice(value: 5),
        ];
        final newState = state.rollDice(newDice);

        expect(newState.currentDice, newDice);
        expect(newState.rollsRemaining, 2);
        expect(newState.selectedCategory, isNull);
      });
    });

    group('select category', () {
      test('sets selected category', () {
        final state = GameState();
        final newState = state.selectCategory(ScoreCategory.aces);

        expect(newState.selectedCategory, ScoreCategory.aces);
      });
    });

    group('score category', () {
      test('calculates score for a category', () {
        final dice = [
          Dice(value: 1),
          Dice(value: 1),
          Dice(value: 1),
          Dice(value: 2),
          Dice(value: 3),
        ];
        final state = GameState(currentDice: dice);

        final score = state.scoreCategory(ScoreCategory.aces);
        expect(score, 3); // 1 + 1 + 1
      });
    });

    group('copyWith', () {
      test('creates a copy with updated fields', () {
        final state = GameState();
        final newState = state.copyWith(
          rollsRemaining: 2,
          selectedCategory: ScoreCategory.aces,
        );

        expect(newState.rollsRemaining, 2);
        expect(newState.selectedCategory, ScoreCategory.aces);
        expect(newState.currentDice, state.currentDice);
      });

      test('clears selected category when requested', () {
        final state = GameState(selectedCategory: ScoreCategory.aces);
        final newState = state.copyWith(clearSelectedCategory: true);

        expect(newState.selectedCategory, isNull);
      });
    });

    group('reset', () {
      test('creates a fresh state', () {
        final dice = [
          Dice(value: 3),
          Dice(value: 4),
          Dice(value: 5),
          Dice(value: 1),
          Dice(value: 2),
        ];
        final scored = {ScoreCategory.aces: 6};
        final state = GameState(
          currentDice: dice,
          rollsRemaining: 1,
          singlePlayerScoredCategories: scored,
        );
        final newState = state.reset();

        expect(newState.rollsRemaining, 3);
        expect(
          newState.currentPlayerScoredCategories[ScoreCategory.aces],
          null,
        );
        for (final die in newState.currentDice) {
          expect(die.value, 0);
        }
      });
    });

    group('game completion', () {
      test('isGameComplete is false initially', () {
        final state = GameState();
        expect(state.isGameComplete, false);
      });

      test('isGameComplete is true when all categories filled', () {
        final scored = {
          for (final category in ScoreCategory.values) category: 0,
        };
        final state = GameState(singlePlayerScoredCategories: scored);
        expect(state.isGameComplete, true);
      });

      test('isGameComplete checks all players', () {
        final player0 = {
          for (final category in ScoreCategory.values) category: 0,
        };
        final player1 = {
          for (final category in ScoreCategory.values)
            if (category != ScoreCategory.aces) category: 0,
        };
        final state = GameState(
          scoredCategories: {0: player0, 1: player1},
          playerCount: 2,
        );
        expect(state.isGameComplete, false);
      });
    });

    group('JSON serialization', () {
      test('round-trips correctly', () {
        final dice = [
          Dice(value: 1),
          Dice(value: 2),
          Dice(value: 3),
          Dice(value: 4),
          Dice(value: 5),
        ];
        final scored = {ScoreCategory.aces: 6};
        final state = GameState(
          currentDice: dice,
          rollsRemaining: 2,
          singlePlayerScoredCategories: scored,
          selectedCategory: ScoreCategory.twos,
          lastScoredCategory: ScoreCategory.aces,
        );

        final json = state.toJson();
        final restored = GameState.fromJson(json);

        expect(restored.currentDice.length, 5);
        expect(restored.rollsRemaining, 2);
        expect(restored.currentPlayerScoredCategories[ScoreCategory.aces], 6);
        expect(restored.selectedCategory, ScoreCategory.twos);
        expect(restored.lastScoredCategory, ScoreCategory.aces);
        expect(restored.status, GameStatus.active);
      });

      test('loads old single-player JSON format', () {
        final oldJson = {
          'current_dice': [
            {'value': 1},
            {'value': 2},
            {'value': 3},
            {'value': 4},
            {'value': 5},
          ],
          'rolls_remaining': 2,
          'scored_categories': [
            {'category_index': 0, 'score': 6},
            {'category_index': 1, 'score': null},
          ],
          'status_index': 0,
          'selected_category_index': null,
        };

        final state = GameState.fromJson(oldJson);

        expect(state.playerCount, 1);
        expect(state.currentPlayer, 0);
        expect(state.rollsRemaining, 2);
        expect(state.currentPlayerScoredCategories[ScoreCategory.aces], 6);
        expect(state.currentPlayerScoredCategories[ScoreCategory.twos], null);
      });

      test('loads new per-player JSON format', () {
        final newJson = {
          'current_dice': [
            {'value': 1},
            {'value': 2},
            {'value': 3},
            {'value': 4},
            {'value': 5},
          ],
          'rolls_remaining': 2,
          'player_count': 2,
          'current_player': 1,
          'last_scored_category_index': 0,
          'scored_categories': [
            {
              'player_index': 0,
              'categories': [
                {'category_index': 0, 'score': 6},
                {'category_index': 1, 'score': 4},
              ],
            },
            {
              'player_index': 1,
              'categories': [
                {'category_index': 0, 'score': 3},
                {'category_index': 1, 'score': null},
              ],
            },
          ],
          'status_index': 0,
          'selected_category_index': null,
        };

        final state = GameState.fromJson(newJson);

        expect(state.playerCount, 2);
        expect(state.currentPlayer, 1);
        expect(state.lastScoredCategory, ScoreCategory.aces);
        expect(state.scoredCategories[0]?[ScoreCategory.aces], 6);
        expect(state.scoredCategories[1]?[ScoreCategory.aces], 3);
      });
    });

    group('dice total', () {
      test('sums all dice values', () {
        final dice = [
          Dice(value: 1),
          Dice(value: 2),
          Dice(value: 3),
          Dice(value: 4),
          Dice(value: 5),
        ];
        final state = GameState(currentDice: dice);

        expect(state.diceTotal, 15);
      });

      test('returns zero for blank dice', () {
        final state = GameState();
        expect(state.diceTotal, 0);
      });
    });

    group('toString', () {
      test('returns a readable string', () {
        final state = GameState();
        final string = state.toString();

        expect(string, contains('GameState'));
        expect(string, contains('rolls: 3'));
      });
    });
  });
}
