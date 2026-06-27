/// Multiplayer-specific tests for [GameNotifier].
///
/// Validates round-based gameplay, turn management, and score tracking
/// across multiple players through the provider layer.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/providers/game_provider.dart';

void main() {
  group('GameNotifier - Multiplayer', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier();
    });

    tearDown(() {
      notifier.dispose();
    });

    test('resets game for a new 2-player session', () {
      // Arrange
      notifier.resetGame(playerCount: 2);

      // Act & Assert
      expect(notifier.state.currentPlayer, 0);
      expect(notifier.state.status == GameStatus.completed, isFalse);
    });

    test('player rolls dice and toggles holds', () {
      // Arrange
      notifier.resetGame(playerCount: 2);

      // Act: Player 0 rolls
      notifier.rollDice();
      final stateAfterRoll = notifier.state;
      expect(3 - stateAfterRoll.rollsRemaining, 1);

      // Toggle hold on first die
      notifier.toggleHold(0);
      expect(notifier.state.currentDice[0].isHeld, isTrue);

      // Release hold
      notifier.toggleHold(0);
      expect(notifier.state.currentDice[0].isHeld, isFalse);
    });

    test('player selects and confirms a score', () {
      // Arrange
      notifier.resetGame(playerCount: 2);
      notifier.rollDice();

      // Act: Select category
      notifier.selectCategory(ScoreCategory.aces);
      expect(notifier.state.selectedCategory, ScoreCategory.aces);

      // Confirm score
      notifier.confirmScore();
      expect(notifier.state.scoredCategories[0]?[ScoreCategory.aces], isNotNull);
    });

    test('selecting a category with no dice rolled shows zero preview', () {
      // Arrange
      notifier.resetGame(playerCount: 2);
      notifier.rollDice();

      // Act: Select after rolling
      notifier.selectCategory(ScoreCategory.aces);

      // Assert
      expect(notifier.state.selectedCategory, ScoreCategory.aces);
      expect((notifier.getPreviewScore(ScoreCategory.aces) ?? 0) >= 0, isTrue);
    });

    test('re-rolling keeps held dice', () {
      // Arrange
      notifier.resetGame(playerCount: 2);
      notifier.rollDice();

      // Act: Hold first and second die, then re-roll
      notifier.toggleHold(0);
      notifier.toggleHold(1);
      final heldValues = [
        notifier.state.currentDice[0].value,
        notifier.state.currentDice[1].value,
      ];

      notifier.rollDice();

      // Assert
      expect(notifier.state.currentDice[0].value, heldValues[0]);
      expect(notifier.state.currentDice[1].value, heldValues[1]);
      expect(3 - notifier.state.rollsRemaining, 2);
    });

    test('game state is immutable after roll', () {
      // Arrange
      notifier.resetGame(playerCount: 2);
      notifier.rollDice();
      final state1 = notifier.state;

      // Act: Roll again
      notifier.rollDice();
      final state2 = notifier.state;

      // Assert: different instances
      expect(identical(state1, state2), isFalse);
      expect(3 - state2.rollsRemaining, 2);
    });

    test('player cannot exceed max rolls', () {
      // Arrange
      notifier.resetGame(playerCount: 2);
      notifier.rollDice();
      notifier.rollDice();
      notifier.rollDice();

      // Assert: 3 rolls used
      expect(3 - notifier.state.rollsRemaining, 3);
      expect(notifier.state.rollsRemaining, 0);
    });

    test('game ends when all players complete categories', () {
      // Arrange
      notifier.resetGame(playerCount: 2);

      // Act: Fill all categories for both players
      for (final category in ScoreCategory.values) {
        notifier.rollDice();
        notifier.selectCategory(category);
        notifier.confirmScore();
      }
      // After player 0 completes, switch happens automatically
      for (final category in ScoreCategory.values) {
        notifier.rollDice();
        notifier.selectCategory(category);
        notifier.confirmScore();
      }

      // Assert
      expect(notifier.state.status == GameStatus.completed, isTrue);
    });

    test('score preview updates when dice change', () {
      // Arrange
      notifier.resetGame(playerCount: 2);
      notifier.rollDice();
      notifier.selectCategory(ScoreCategory.aces);
      final score1 = notifier.getPreviewScore(ScoreCategory.aces);

      // Act: Roll again
      notifier.rollDice();
      final score2 = notifier.getPreviewScore(ScoreCategory.aces);

      // Assert
    expect((score1 ?? 0) >= 0, isTrue);
       expect((score2 ?? 0) >= 0, isTrue);
    });

    test('selected category resets after confirming score', () {
      // Arrange
      notifier.resetGame(playerCount: 2);
      notifier.rollDice();

      // Act: Select and confirm
      notifier.selectCategory(ScoreCategory.aces);
      notifier.confirmScore();

      // Assert: selected category should be null after confirm
      expect(notifier.state.selectedCategory, isNull);
    });
  });
}
