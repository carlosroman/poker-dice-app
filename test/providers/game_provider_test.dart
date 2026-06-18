import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/providers/game_provider.dart';

void main() {
  late ProviderContainer container;
  late GameNotifier notifier;

  setUp(() {
    container = ProviderContainer();
    notifier = container.read(gameProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  // -----------------------------------------------------------------------
  // Initial state
  // -----------------------------------------------------------------------

  group('initial state', () {
    test('starts with 5 dice all showing 1 and unheld', () {
      final state = container.read(gameProvider);

      expect(state.currentDice.length, 5);
      for (final die in state.currentDice) {
        expect(die.value, 1);
        expect(die.isHeld, isFalse);
      }
    });

    test('starts with 3 rolls remaining', () {
      expect(container.read(gameProvider).rollsRemaining, 3);
    });

    test('starts with no scored categories', () {
      expect(
        container.read(gameProvider).scoredCategories.values.whereType<int>(),
        isEmpty,
      );
    });

    test('starts with active status', () {
      expect(container.read(gameProvider).status, GameStatus.active);
    });
  });

  // -----------------------------------------------------------------------
  // rollDice
  // -----------------------------------------------------------------------

  group('rollDice', () {
    test('rolls unheld dice and decrements rolls remaining', () {
      notifier.rollDice();

      final state = container.read(gameProvider);
      expect(state.rollsRemaining, 2);
      for (final die in state.currentDice) {
        expect(die.value, greaterThanOrEqualTo(1));
        expect(die.value, lessThanOrEqualTo(6));
      }
    });

    test('preserves held dice values', () {
      notifier.toggleHold(0);
      final heldValue = container.read(gameProvider).currentDice[0].value;

      notifier.rollDice();

      final state = container.read(gameProvider);
      expect(state.currentDice[0].value, heldValue);
      expect(state.currentDice[0].isHeld, isTrue);
    });

    test('does nothing when no rolls remaining', () {
      // Exhaust all rolls
      notifier.rollDice();
      notifier.rollDice();
      notifier.rollDice();
      final stateBefore = container.read(gameProvider);

      notifier.rollDice();
      final stateAfter = container.read(gameProvider);

      expect(stateAfter.rollsRemaining, equals(stateBefore.rollsRemaining));
    });

    test('does nothing when game is completed', () {
      // Score all categories to complete the game
      for (final category in ScoreCategory.values) {
        notifier.selectCategory(category);
      }

      notifier.rollDice();
      final stateAfter = container.read(gameProvider);

      expect(stateAfter.status, GameStatus.completed);
    });
  });

  // -----------------------------------------------------------------------
  // toggleHold
  // -----------------------------------------------------------------------

  group('toggleHold', () {
    test('toggles hold state on valid index', () {
      notifier.toggleHold(2);
      expect(container.read(gameProvider).currentDice[2].isHeld, isTrue);

      notifier.toggleHold(2);
      expect(container.read(gameProvider).currentDice[2].isHeld, isFalse);
    });

    test('does nothing on negative index', () {
      final stateBefore = container.read(gameProvider);
      notifier.toggleHold(-1);
      final stateAfter = container.read(gameProvider);
      expect(
        stateAfter.currentDice[2].isHeld,
        equals(stateBefore.currentDice[2].isHeld),
      );
    });

    test('does nothing on out-of-bounds index', () {
      final stateBefore = container.read(gameProvider);
      notifier.toggleHold(5);
      final stateAfter = container.read(gameProvider);
      expect(
        stateAfter.currentDice[2].isHeld,
        equals(stateBefore.currentDice[2].isHeld),
      );
    });
  });

  // -----------------------------------------------------------------------
  // selectCategory
  // -----------------------------------------------------------------------

  group('selectCategory', () {
    test('scores a category and resets the turn', () {
      notifier.selectCategory(ScoreCategory.aces);

      final state = container.read(gameProvider);
      expect(state.scoredCategories[ScoreCategory.aces], isNotNull);
      expect(state.rollsRemaining, 3);
    });

    test('does not overwrite an already scored category', () {
      notifier.selectCategory(ScoreCategory.aces);
      final firstScore = container
          .read(gameProvider)
          .scoredCategories[ScoreCategory.aces];

      notifier.selectCategory(ScoreCategory.aces);
      final secondScore = container
          .read(gameProvider)
          .scoredCategories[ScoreCategory.aces];

      expect(secondScore, equals(firstScore));
    });

    test('does nothing when game is completed', () {
      // Complete the game
      for (final category in ScoreCategory.values) {
        notifier.selectCategory(category);
      }

      notifier.selectCategory(ScoreCategory.aces);
      final stateAfter = container.read(gameProvider);

      expect(stateAfter.status, GameStatus.completed);
    });
  });

  // -----------------------------------------------------------------------
  // resetGame
  // -----------------------------------------------------------------------

  group('resetGame', () {
    test('resets to initial state', () {
      notifier.rollDice();
      notifier.selectCategory(ScoreCategory.aces);

      notifier.resetGame();

      final state = container.read(gameProvider);
      expect(state.currentDice.length, 5);
      expect(state.rollsRemaining, 3);
      expect(state.scoredCategories.values.whereType<int>(), isEmpty);
      expect(state.status, GameStatus.active);
    });
  });

  // -----------------------------------------------------------------------
  // getPreviewScore
  // -----------------------------------------------------------------------

  group('getPreviewScore', () {
    test('returns score for available category', () {
      final preview = notifier.getPreviewScore(ScoreCategory.aces);
      expect(preview, isA<int>());
    });

    test('returns null for already scored category', () {
      notifier.selectCategory(ScoreCategory.aces);
      expect(notifier.getPreviewScore(ScoreCategory.aces), isNull);
    });
  });

  // -----------------------------------------------------------------------
  // Provider integration
  // -----------------------------------------------------------------------

  group('provider integration', () {
    test('state changes are reflected in the provider', () {
      notifier.rollDice();
      expect(container.read(gameProvider).rollsRemaining, 2);

      notifier.toggleHold(0);
      expect(container.read(gameProvider).currentDice[0].isHeld, isTrue);
    });
  });
}
