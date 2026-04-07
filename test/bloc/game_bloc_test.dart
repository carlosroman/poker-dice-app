import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/bloc/game_bloc.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';

/// Helper function to wait for bloc state changes.
Future<void> waitForStateChange() async {
  await Future.delayed(const Duration(milliseconds: 50));
}

void main() {
  group('GameBloc', () {
    late GameBloc gameBloc;

    setUp(() {
      gameBloc = GameBloc();
    });

    tearDown(() {
      gameBloc.close();
    });

    test('initial state is GameInitial', () {
      expect(gameBloc.state, isA<GameInitial>());
      expect(gameBloc.state.isGameOver, isFalse);
    });

    group('NewGameEvent', () {
      test('transitions to GamePlaying state', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        expect(gameBloc.state.isGameOver, isFalse);
        expect(gameBloc.state.currentRound.rollCount, equals(0));
        expect(gameBloc.state.currentRound.dice.length, equals(5));
      });

      test('resets score sheet', () async {
        // First start a game and score something
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        // Score a category
        gameBloc.add(SelectCategoryEvent(ScoreCategory.aces));
        await waitForStateChange();

        expect(
          gameBloc.state.scoreSheet.isCategoryScored(ScoreCategory.aces),
          isTrue,
        );

        // Start new game
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        // Verify score sheet is reset
        expect(
          gameBloc.state.scoreSheet.getEmptyCategories().length,
          equals(13),
        );
      });
    });

    group('RollDiceEvent', () {
      test('rolls dice and updates state', () async {
        // Start a new game
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        // Roll the dice
        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        expect(gameBloc.state.currentRound.rollCount, equals(1));
        expect(
          gameBloc.state.currentRound.dice.every(
            (die) => die.value >= 1 && die.value <= 6,
          ),
          isTrue,
        );
      });

      test('increments roll count on each roll', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        expect(gameBloc.state.currentRound.rollCount, equals(3));
      });

      test('does not roll when max rolls reached', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        // Use all 3 rolls
        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        final rollCountBefore = gameBloc.state.currentRound.rollCount;

        // Try to roll again
        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        expect(gameBloc.state.currentRound.rollCount, equals(rollCountBefore));
        expect(gameBloc.state.currentRound.canRoll(), isFalse);
      });

      test('cannot roll in GameInitial state', () async {
        // Ensure we're in initial state
        expect(gameBloc.state.currentRound.rollCount, equals(0));

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        // State should not have changed (still rollCount 0)
        expect(gameBloc.state.currentRound.rollCount, equals(0));
      });
    });

    group('ToggleDieEvent', () {
      test('toggles die hold state', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        // All dice should start as not held
        expect(
          gameBloc.state.currentRound.dice.every((die) => !die.held),
          isTrue,
        );

        // Toggle first die
        gameBloc.add(ToggleDieEvent(0));
        await waitForStateChange();

        expect(gameBloc.state.currentRound.dice[0].held, isTrue);

        // Toggle again to unhold
        gameBloc.add(ToggleDieEvent(0));
        await waitForStateChange();

        expect(gameBloc.state.currentRound.dice[0].held, isFalse);
      });

      test('toggles multiple dice independently', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        gameBloc.add(ToggleDieEvent(0));
        await waitForStateChange();

        gameBloc.add(ToggleDieEvent(2));
        await waitForStateChange();

        gameBloc.add(ToggleDieEvent(4));
        await waitForStateChange();

        expect(gameBloc.state.currentRound.dice[0].held, isTrue);
        expect(gameBloc.state.currentRound.dice[1].held, isFalse);
        expect(gameBloc.state.currentRound.dice[2].held, isTrue);
        expect(gameBloc.state.currentRound.dice[3].held, isFalse);
        expect(gameBloc.state.currentRound.dice[4].held, isTrue);
      });

      test('handles invalid index gracefully', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        final initialState = gameBloc.state;

        // These should not throw exceptions
        gameBloc.add(ToggleDieEvent(-1));
        await waitForStateChange();

        gameBloc.add(ToggleDieEvent(5));
        await waitForStateChange();

        // State should remain unchanged
        expect(gameBloc.state, equals(initialState));
        expect(
          gameBloc.state.currentRound.dice.every((die) => !die.held),
          isTrue,
        );
      });
    });

    group('SelectCategoryEvent', () {
      test('scores category and starts new round', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        // Roll dice to have some values to score
        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        // Score aces
        gameBloc.add(SelectCategoryEvent(ScoreCategory.aces));
        await waitForStateChange();

        expect(
          gameBloc.state.scoreSheet.isCategoryScored(ScoreCategory.aces),
          isTrue,
        );
        expect(
          gameBloc.state.currentRound.rollCount,
          equals(0),
        ); // New round started
      });

      test('throws error for already scored category', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        // Score a category
        gameBloc.add(SelectCategoryEvent(ScoreCategory.aces));
        await waitForStateChange();

        expect(
          gameBloc.state.scoreSheet.isCategoryScored(ScoreCategory.aces),
          isTrue,
        );

        // Try to score again - should throw StateError
        // The bloc throws the error in the event handler
        expect(
          () => gameBloc.selectCategorySync(ScoreCategory.aces),
          throwsA(isA<StateError>()),
        );
      });

      test('scores different categories correctly', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        // Score multiple categories
        gameBloc.add(SelectCategoryEvent(ScoreCategory.aces));
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(SelectCategoryEvent(ScoreCategory.twos));
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(SelectCategoryEvent(ScoreCategory.threes));
        await waitForStateChange();

        expect(
          gameBloc.state.scoreSheet.isCategoryScored(ScoreCategory.aces),
          isTrue,
        );
        expect(
          gameBloc.state.scoreSheet.isCategoryScored(ScoreCategory.twos),
          isTrue,
        );
        expect(
          gameBloc.state.scoreSheet.isCategoryScored(ScoreCategory.threes),
          isTrue,
        );
        expect(
          gameBloc.state.scoreSheet.getEmptyCategories().length,
          equals(10),
        );
      });
    });

    group('Game Over', () {
      test('transitions to GameOver when all categories scored', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        // Score all 13 categories
        for (final category in ScoreCategory.values) {
          gameBloc.add(RollDiceEvent());
          await waitForStateChange();

          gameBloc.add(SelectCategoryEvent(category));
          await waitForStateChange();

          // Break if game is over
          if (gameBloc.state.isGameOver) break;
        }

        expect(gameBloc.state.isGameOver, isTrue);
      });

      test('provides all categories after game over', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        // Score all categories to complete the game
        for (final category in ScoreCategory.values) {
          gameBloc.add(RollDiceEvent());
          await waitForStateChange();

          gameBloc.add(SelectCategoryEvent(category));
          await waitForStateChange();

          if (gameBloc.state.isGameOver) break;
        }

        // After game over, all categories should be available
        final validCategories = gameBloc.state.getValidCategories();
        expect(validCategories.length, equals(13));
      });
    });

    group('Valid Categories', () {
      test('provides correct valid categories during play', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        // Initially all categories are valid
        var validCategories = gameBloc.state.getValidCategories();
        expect(validCategories.length, equals(13));

        // Score one category
        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(SelectCategoryEvent(ScoreCategory.aces));
        await waitForStateChange();

        // Now only 12 categories are valid
        validCategories = gameBloc.state.getValidCategories();
        expect(validCategories.length, equals(12));
        expect(validCategories.contains(ScoreCategory.aces), isFalse);
      });

      test('excludes already scored categories', () async {
        gameBloc.add(NewGameEvent());
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(SelectCategoryEvent(ScoreCategory.aces));
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(SelectCategoryEvent(ScoreCategory.twos));
        await waitForStateChange();

        gameBloc.add(RollDiceEvent());
        await waitForStateChange();

        gameBloc.add(SelectCategoryEvent(ScoreCategory.threes));
        await waitForStateChange();

        final validCategories = gameBloc.state.getValidCategories();

        expect(validCategories.contains(ScoreCategory.aces), isFalse);
        expect(validCategories.contains(ScoreCategory.twos), isFalse);
        expect(validCategories.contains(ScoreCategory.threes), isFalse);
        expect(validCategories.contains(ScoreCategory.fours), isTrue);
      });
    });
  });
}
