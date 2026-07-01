/// Multiplayer-specific tests for [GameState].
///
/// Validates player switching, independent score sheets, and end-game
/// detection across multiple players.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';

void main() {
  group('GameState - Multiplayer', () {
    // Helper: calculate total score for a player from their scored categories
    int playerTotalScore(Map<int, Map<ScoreCategory, int?>> scoredCategories,
        int player) {
      final scores = scoredCategories[player];
      if (scores == null) return 0;
      return scores.values.fold(0, (a, b) => a + (b ?? 0));
    }

    test('switches player after completing all categories', () {
      // Arrange: 2-player game, player 0 fills all categories
      GameState state = GameState.initial(playerCount: 2);
      for (final category in ScoreCategory.values) {
        state = state.recordScore(category, 10);
      }

      // Act
      state = state.switchPlayer();

      // Assert
      expect(state.currentPlayer, 1);
    });

    test('each player has independent score sheet', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);

      // Act: Player 0 scores aces
      state = state.recordScore(ScoreCategory.aces, 3);
      // Switch to player 1, score twos
      state = state.switchPlayer();
      state = state.recordScore(ScoreCategory.twos, 4);

      // Assert
      expect(state.scoredCategories[0]?[ScoreCategory.aces], 3);
      expect(state.scoredCategories[1]?[ScoreCategory.aces], isNull);
      expect(state.scoredCategories[0]?[ScoreCategory.twos], isNull);
      expect(state.scoredCategories[1]?[ScoreCategory.twos], 4);
    });

    test('player score is sum of their scored categories', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);

      // Act: Player 0 scores aces and twos
      state = state.recordScore(ScoreCategory.aces, 5);
      state = state.recordScore(ScoreCategory.twos, 10);
      // Switch to player 1, score aces
      state = state.switchPlayer();
      state = state.recordScore(ScoreCategory.aces, 3);

      // Assert
      expect(playerTotalScore(state.scoredCategories, 0), 15);
      expect(playerTotalScore(state.scoredCategories, 1), 3);
    });

    test('game ends when all players complete all categories', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);

      // Act: Both players fill all categories
      for (final category in ScoreCategory.values) {
        state = state.recordScore(category, 5);
      }
      state = state.switchPlayer();
      for (final category in ScoreCategory.values) {
        state = state.recordScore(category, 5);
      }

      // Assert
      expect(state.isGameComplete, isTrue);
    });

    test('game not complete when one player has remaining categories', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);

      // Act: Player 0 fills all, Player 1 fills only one
      for (final category in ScoreCategory.values) {
        state = state.recordScore(category, 5);
      }
      state = state.switchPlayer();
      state = state.recordScore(ScoreCategory.aces, 3);

      // Assert
      expect(state.isGameComplete, isFalse);
    });

    test('current player rolls dice independently', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);

      // Act: Player 0 rolls
      final rolledDice1 = List.generate(
        5,
        (i) => Dice(value: (i % 6) + 1),
      );
      state = state.rollDice(rolledDice1);

      state = state.switchPlayer();
      final rolledDice2 = List.generate(
        5,
        (i) => Dice(value: ((i + 3) % 6) + 1),
      );
      state = state.rollDice(rolledDice2);

      // Assert: dice are updated for current player
      expect(state.currentPlayer, 1);
      expect(state.currentDice, rolledDice2);
    });

    test('player can hold and release dice across turns', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);
      final rolledDice = List.generate(5, (i) => Dice(value: (i % 6) + 1));
      state = state.rollDice(rolledDice);

      // Act: Player 0 holds first die
      state = state.toggleHold(0);
      expect(state.currentDice[0].isHeld, isTrue);

      // Switch to player 1, roll new dice - holds are reset
      state = state.switchPlayer();
      final newDice = List.generate(5, (i) => Dice(value: 1));
      state = state.rollDice(newDice);

      // Assert: player 1 starts with no holds
      for (int i = 0; i < state.currentDice.length; i++) {
        expect(
          state.currentDice[i].isHeld,
          isFalse,
          reason: 'Die $i should not be held',
        );
      }
    });

    test('total score is sum of all player scores', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);

      // Act: Player 0 scores aces and chance
      state = state.recordScore(ScoreCategory.aces, 10);
      state = state.recordScore(ScoreCategory.chance, 20);
      // Player 1 scores twos
      state = state.switchPlayer();
      state = state.recordScore(ScoreCategory.twos, 8);

      // Assert
      final total = playerTotalScore(state.scoredCategories, 0) +
          playerTotalScore(state.scoredCategories, 1);
      expect(total, 38);
    });

    test('player count affects turn order', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);

      // Act & Assert
      expect(state.currentPlayer, 0);
      state = state.switchPlayer();
      expect(state.currentPlayer, 1);
      state = state.switchPlayer();
      expect(state.currentPlayer, 0);
    });

    test('current player score only includes their categories', () {
      // Arrange
      GameState state = GameState.initial(playerCount: 2);

      // Act: Player 0 scores
      state = state.recordScore(ScoreCategory.aces, 6);
      expect(state.currentPlayerScore, 6);

      // Switch and score for player 1
      state = state.switchPlayer();
      state = state.recordScore(ScoreCategory.twos, 4);
      expect(state.currentPlayerScore, 4);
    });
  });
}
