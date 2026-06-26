import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/game_history.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/providers/storage_provider.dart';
import 'package:poker_dice/services/storage_service.dart';

void main() {
  late ProviderContainer container;
  late GameNotifier notifier;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        storageServiceProvider.overrideWith(
          (ref) => Future.value(const _FakeStorageService()),
        ),
      ],
    );
    notifier = container.read(gameProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  /// Rolls dice, selects, and confirms a category in one step.
  void rollAndScore(ScoreCategory category) {
    notifier.rollDice();
    notifier.selectCategoryForPreview(category);
    notifier.confirmScore();
  }

  /// Completes the game by scoring all categories.
  void completeGame() {
    for (final category in ScoreCategory.values) {
      rollAndScore(category);
    }
  }

  // -----------------------------------------------------------------------
  // Initial state
  // -----------------------------------------------------------------------

  group('initial state', () {
    test('starts with 5 blank dice (value 0) and unheld', () {
      final state = container.read(gameProvider);

      expect(state.currentDice.length, 5);
      for (final die in state.currentDice) {
        expect(die.value, 0);
        expect(die.isHeld, isFalse);
      }
    });

    test('starts with 3 rolls remaining', () {
      expect(container.read(gameProvider).rollsRemaining, 3);
    });

    test('starts with no scored categories', () {
      expect(
        container
            .read(gameProvider)
            .currentPlayerScoredCategories
            .values
            .whereType<int>(),
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
      completeGame();

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
  // selectCategory with blank dice
  // -----------------------------------------------------------------------

  group('selectCategory with blank dice', () {
    test('does not select category when all dice are blank', () {
      notifier.selectCategory(ScoreCategory.aces);
      final state = container.read(gameProvider);

      expect(state.selectedCategory, isNull);
      expect(state.currentPlayerScoredCategories[ScoreCategory.aces], isNull);
    });

    test('selects category after rolling dice', () {
      notifier.rollDice();
      notifier.selectCategory(ScoreCategory.aces);

      final state = container.read(gameProvider);
      expect(state.selectedCategory, ScoreCategory.aces);
    });
  });

  // -----------------------------------------------------------------------
  // selectCategory
  // -----------------------------------------------------------------------

  group('selectCategory', () {
    test('first call selects for preview, second call confirms score', () {
      notifier.rollDice();
      notifier.selectCategory(ScoreCategory.aces);

      // First call: only selects for preview
      var state = container.read(gameProvider);
      expect(state.selectedCategory, ScoreCategory.aces);
      expect(state.currentPlayerScoredCategories[ScoreCategory.aces], isNull);

      // Second call: confirms the score
      notifier.selectCategory(ScoreCategory.aces);
      state = container.read(gameProvider);
      expect(state.currentPlayerScoredCategories[ScoreCategory.aces], isNotNull);
      expect(state.selectedCategory, isNull);
      expect(state.rollsRemaining, 3);
    });

    test('does not overwrite an already scored category', () {
      notifier.rollDice();
      notifier.selectCategory(ScoreCategory.aces);
      notifier.selectCategory(ScoreCategory.aces);
      final firstScore = container
          .read(gameProvider)
          .currentPlayerScoredCategories[ScoreCategory.aces];

      notifier.selectCategory(ScoreCategory.aces);
      final secondScore = container
          .read(gameProvider)
          .currentPlayerScoredCategories[ScoreCategory.aces];

      expect(secondScore, equals(firstScore));
    });

    test('does nothing when game is completed', () {
      // Complete the game
      completeGame();

      notifier.selectCategory(ScoreCategory.aces);
      final stateAfter = container.read(gameProvider);

      expect(stateAfter.status, GameStatus.completed);
    });
  });

  // -----------------------------------------------------------------------
  // selectCategoryForPreview with blank dice
  // -----------------------------------------------------------------------

  group('selectCategoryForPreview with blank dice', () {
    test('does not select category when all dice are blank', () {
      notifier.selectCategoryForPreview(ScoreCategory.aces);
      final state = container.read(gameProvider);

      expect(state.selectedCategory, isNull);
    });

    test('selects category after rolling dice', () {
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);

      final state = container.read(gameProvider);
      expect(state.selectedCategory, ScoreCategory.aces);
    });
  });

  // -----------------------------------------------------------------------
  // selectCategoryForPreview
  // -----------------------------------------------------------------------

  group('selectCategoryForPreview', () {
    test('selects a category without scoring', () {
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);

      final state = container.read(gameProvider);
      expect(state.selectedCategory, ScoreCategory.aces);
      expect(state.currentPlayerScoredCategories[ScoreCategory.aces], isNull);
    });

    test('does not select an already scored category', () {
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);
      notifier.confirmScore();

      notifier.selectCategoryForPreview(ScoreCategory.aces);
      final state = container.read(gameProvider);

      expect(state.selectedCategory, isNull);
    });

    test('does nothing when game is completed', () {
      completeGame();

      notifier.selectCategoryForPreview(ScoreCategory.aces);
      final state = container.read(gameProvider);

      expect(state.status, GameStatus.completed);
      expect(state.selectedCategory, isNull);
    });

    test('switching selection updates selected category', () {
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);
      expect(container.read(gameProvider).selectedCategory, ScoreCategory.aces);

      notifier.selectCategoryForPreview(ScoreCategory.twos);
      expect(container.read(gameProvider).selectedCategory, ScoreCategory.twos);
    });
  });

  // -----------------------------------------------------------------------
  // confirmScore
  // -----------------------------------------------------------------------

  group('confirmScore', () {
    test('scores the selected category and resets the turn', () {
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);
      notifier.confirmScore();

      final state = container.read(gameProvider);
      expect(state.currentPlayerScoredCategories[ScoreCategory.aces], isNotNull);
      expect(state.selectedCategory, isNull);
      expect(state.rollsRemaining, 3);
    });

    test('does nothing when no category is selected', () {
      notifier.confirmScore();

      final state = container.read(gameProvider);
      expect(state.selectedCategory, isNull);
      expect(state.currentPlayerScoredCategories.values.whereType<int>(), isEmpty);
    });

    test('does nothing when game is completed', () {
      completeGame();

      notifier.selectCategoryForPreview(ScoreCategory.aces);
      notifier.confirmScore();
      final state = container.read(gameProvider);

      expect(state.status, GameStatus.completed);
    });
  });

  // -----------------------------------------------------------------------
  // clearSelection
  // -----------------------------------------------------------------------

  group('clearSelection', () {
    test('clears the selected category', () {
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);
      expect(container.read(gameProvider).selectedCategory, ScoreCategory.aces);

      notifier.clearSelection();
      expect(container.read(gameProvider).selectedCategory, isNull);
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
      expect(state.currentPlayerScoredCategories.values.whereType<int>(), isEmpty);
      expect(state.status, GameStatus.active);
    });

    test('resets with custom player count', () {
      notifier.resetGame(playerCount: 2);

      final state = container.read(gameProvider);
      expect(state.playerCount, 2);
      expect(state.currentPlayer, 0);
    });

    test('defaults to single player when no player count provided', () {
      notifier.resetGame();

      final state = container.read(gameProvider);
      expect(state.playerCount, 1);
      expect(state.currentPlayer, 0);
    });
  });

  // -----------------------------------------------------------------------
  // Multiplayer getters
  // -----------------------------------------------------------------------

  group('multiplayer getters', () {
    test('currentPlayer returns the current player index (0-based)', () {
      notifier.resetGame(playerCount: 2);
      expect(notifier.currentPlayer, 0);
    });

    test('playerCount returns the number of players', () {
      notifier.resetGame(playerCount: 2);
      expect(notifier.playerCount, 2);
    });

    test('lastScoredCategory is null initially', () {
      expect(notifier.lastScoredCategory, isNull);
    });

    test('lastScoredCategory updates after scoring', () {
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);
      notifier.confirmScore();

      expect(notifier.lastScoredCategory, ScoreCategory.aces);
    });
  });

  // -----------------------------------------------------------------------
  // confirmScore - player switching
  // -----------------------------------------------------------------------

  group('confirmScore - player switching', () {
    test('switches player after scoring in 2-player mode (0→1)', () {
      notifier.resetGame(playerCount: 2);
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);
      notifier.confirmScore();

      final state = container.read(gameProvider);
      expect(state.currentPlayer, 1);
    });

    test('does not switch player in single player mode', () {
      notifier.resetGame(playerCount: 1);
      notifier.rollDice();
      notifier.selectCategoryForPreview(ScoreCategory.aces);
      notifier.confirmScore();

      final state = container.read(gameProvider);
      expect(state.currentPlayer, 0);
    });

    test('game remains active after one player completes all categories in 2-player mode', () {
      notifier.resetGame(playerCount: 2);

      // Player 0 completes all 13 categories
      for (final category in ScoreCategory.values) {
        notifier.rollDice();
        notifier.selectCategoryForPreview(category);
        notifier.confirmScore();
      }

      final state = container.read(gameProvider);
      // Game is still active because player 1 hasn't scored yet
      expect(state.status, GameStatus.active);
      expect(state.currentPlayer, 1);
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
      notifier.rollDice();
      notifier.selectCategory(ScoreCategory.aces);
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

  // -----------------------------------------------------------------------
  // Auto-save on game completion
  // -----------------------------------------------------------------------

  group('auto-save', () {
    test('calls addResult when game is completed', () {
      // Track addResult calls
      List<GameResult>? resultsAdded;

      container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWith(
            (ref) => Future.value(const _FakeStorageService()),
          ),
          scoreboardProvider.overrideWith((ref) {
            return _TestScoreboardNotifier(
              ref: ref,
              onAddResult: (result) => resultsAdded = [result],
            );
          }),
        ],
      );
      notifier = container.read(gameProvider.notifier);

      // Score all 13 categories to complete the game
      for (final category in ScoreCategory.values) {
        notifier.rollDice();
        notifier.selectCategory(category);
        notifier.selectCategory(category);
      }

      expect(notifier.state.status, GameStatus.completed);
      expect(resultsAdded, isNotNull);
      expect(resultsAdded!.length, 1);
      expect(resultsAdded![0].totalScore, notifier.state.totalScore);
      expect(
        resultsAdded![0].upperSectionTotal,
        notifier.state.upperSectionTotal,
      );
      expect(resultsAdded![0].bonus, notifier.state.bonus);
    });

    test('does not call addResult when game is not completed', () {
      // Track addResult calls
      bool addResultCalled = false;

      container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWith(
            (ref) => Future.value(const _FakeStorageService()),
          ),
          scoreboardProvider.overrideWith((ref) {
            return _TestScoreboardNotifier(
              ref: ref,
              onAddResult: (result) => addResultCalled = true,
            );
          }),
        ],
      );
      notifier = container.read(gameProvider.notifier);

      // Score only one category - game is not complete
      notifier.rollDice();
      notifier.selectCategory(ScoreCategory.aces);

      expect(notifier.state.status, GameStatus.active);
      expect(addResultCalled, isFalse);
    });
  });
}

/// Test double for [ScoreboardNotifier] that tracks addResult calls.
class _TestScoreboardNotifier extends ScoreboardNotifier {
  final void Function(GameResult)? onAddResult;

  _TestScoreboardNotifier({required super.ref, this.onAddResult});

  @override
  Future<void> addResult(GameResult result) async {
    onAddResult?.call(result);
  }
}

/// Fake [StorageServiceInterface] for testing.
class _FakeStorageService implements StorageServiceInterface {
  const _FakeStorageService();

  @override
  Future<void> saveGameResult(GameResult result) async {}

  @override
  Future<List<GameResult>> loadGameResults() async => [];

  @override
  Future<int?> getHighScore() async => null;

  @override
  Future<int> getGamesPlayed() async => 0;

  @override
  Future<void> clearHistory() async {}

  @override
  bool hasInProgressGame() => false;

  @override
  Future<void> saveInProgressGame(GameState state) async {}

  @override
  Future<GameState?> loadInProgressGame() async => null;

  @override
  Future<void> clearInProgressGame() async {}
}
