import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/services/dice_service.dart';
import 'package:poker_dice/services/scoring_service.dart';

// -- Fake DiceService for deterministic testing --
class FakeDiceService implements DiceService {
  final List<List<int>> _responses;
  int _callIndex = 0;

  FakeDiceService(this._responses);

  @override
  List<int> rollDice(int count) {
    final response = _responses[_callIndex++];
    return response.take(count).toList();
  }
}

// -- Fake ScoringService for deterministic testing --
class FakeScoringService implements ScoringService {
  final Map<String, int> _responses;
  FakeScoringService(this._responses);

  @override
  int scoreCategory(Category category, DiceRoll roll) {
    return _responses[category.name] ?? 0;
  }

  @override
  int scoreOnes(DiceRoll roll) => 0;

  @override
  int scoreTwos(DiceRoll roll) => 0;

  @override
  int scoreThrees(DiceRoll roll) => 0;

  @override
  int scoreFours(DiceRoll roll) => 0;

  @override
  int scoreFives(DiceRoll roll) => 0;

  @override
  int scoreSixes(DiceRoll roll) => 0;

  @override
  int scoreThreeOfAKind(DiceRoll roll) => 0;

  @override
  int scoreFourOfAKind(DiceRoll roll) => 0;

  @override
  int scoreFullHouse(DiceRoll roll) => 0;

  @override
  int scoreSmallStraight(DiceRoll roll) => 0;

  @override
  int scoreLargeStraight(DiceRoll roll) => 0;

  @override
  int scoreYatzy(DiceRoll roll) => 0;

  @override
  int scoreChance(DiceRoll roll) => 0;

  @override
  int calculateBonus(int upperSectionTotal) => 0;
}

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
    test('initial game state is correct', () async {
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

    test('selectCategory updates selection', () async {
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

    test('selectCategory null clears selection', () async {
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

    test('scoreCategory adds score to state', () async {
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

    test('isGameOver is true when all categories scored', () async {
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

    test('decrementRolls reduces remaining rolls', () async {
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

    test('GameNotifier accepts custom DiceService', () async {
      final customService = DiceService();
      final customNotifier = GameNotifier(diceService: customService);

      expect(customNotifier, isNotNull);
    });

    test('GameNotifier accepts initial state', () async {
      const initialState = GameState(currentRollsRemaining: 2);
      final customNotifier = GameNotifier(initialState: initialState);

      expect(customNotifier.state.currentRollsRemaining, equals(2));
    });
  });

  group('GameProvider held dice', () {
    test('rollDice preserves held dice values on second roll', () async {
      // First roll returns [1, 3, 5, 2, 6], second roll returns [4, 4, 1]
      final fakeService = FakeDiceService([
        [1, 3, 5, 2, 6],
        [4, 4, 1],
      ]);
      final notifier = GameNotifier(
        diceService: fakeService,
        rollAnimationDelay: Duration.zero,
      );

      // First roll: all 5 dice
      await notifier.rollDice();
      expect(notifier.state.diceRoll, equals([1, 3, 5, 2, 6]));

      // Hold dice at index 0 and 4
      notifier.toggleHeldDice(0);
      notifier.toggleHeldDice(4);
      expect(notifier.state.effectiveHeldDice, equals([true, false, false, false, true]));

      // Second roll: only 3 non-held dice are rolled
      await notifier.rollDice();
      final result = notifier.state.diceRoll!;

      // Held dice (index 0 and 4) should preserve original values
      expect(result[0], equals(1), reason: 'die at index 0 should be held (value 1)');
      expect(result[4], equals(6), reason: 'die at index 4 should be held (value 6)');
      // Non-held dice should have new values
      expect(result[1], equals(4));
      expect(result[2], equals(4));
      expect(result[3], equals(1));
    });

    test('rollDice rolls all 5 dice when none are held', () async {
      final fakeService = FakeDiceService([
        [1, 2, 3, 4, 5],
        [6, 5, 4, 3, 2],
      ]);
      final notifier = GameNotifier(
        diceService: fakeService,
        rollAnimationDelay: Duration.zero,
      );

      await notifier.rollDice();
      expect(notifier.state.diceRoll, equals([1, 2, 3, 4, 5]));

      // No dice held
      await notifier.rollDice();
      expect(notifier.state.diceRoll, equals([6, 5, 4, 3, 2]));
    });

    test('rollDice preserves all dice when all are held', () async {
      // First roll returns [1, 2, 3, 4, 5], second roll returns [9, 9, 9] (won't be used)
      final fakeService = FakeDiceService([
        [1, 2, 3, 4, 5],
        [9, 9, 9],
      ]);
      final notifier = GameNotifier(
        diceService: fakeService,
        rollAnimationDelay: Duration.zero,
      );

      await notifier.rollDice();
      expect(notifier.state.diceRoll, equals([1, 2, 3, 4, 5]));

      // Hold all dice
      for (var i = 0; i < 5; i++) {
        notifier.toggleHeldDice(i);
      }
      expect(notifier.state.effectiveHeldDice, equals([true, true, true, true, true]));

      // Second roll: no non-held dice, all values preserved
      await notifier.rollDice();
      expect(notifier.state.diceRoll, equals([1, 2, 3, 4, 5]));
    });

    test('rollDice preserves single held die', () async {
      final fakeService = FakeDiceService([
        [3, 3, 3, 3, 3],
        [1, 2, 4, 5, 6],
      ]);
      final notifier = GameNotifier(
        diceService: fakeService,
        rollAnimationDelay: Duration.zero,
      );

      await notifier.rollDice();
      expect(notifier.state.diceRoll, equals([3, 3, 3, 3, 3]));

      // Hold only die at index 2
      notifier.toggleHeldDice(2);

      await notifier.rollDice();
      final result = notifier.state.diceRoll!;

      expect(result[2], equals(3), reason: 'die at index 2 should be held (value 3)');
      expect(result[0], equals(1));
      expect(result[1], equals(2));
      expect(result[3], equals(4));
      expect(result[4], equals(5));
    });

    test('rollDice rolls all 5 on first roll regardless of held state', () async {
      final fakeService = FakeDiceService([
        [2, 4, 6, 1, 3],
      ]);
      final notifier = GameNotifier(
        diceService: fakeService,
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(
          heldDice: [true, true, false, false, false],
        ),
      );

      // First roll with no previous dice should roll all 5
      await notifier.rollDice();
      expect(notifier.state.diceRoll, equals([2, 4, 6, 1, 3]));
    });
  });

  group('GameNotifier scoring integration', () {
    test('scoreCategory calculates correct score with fake service', () async {
      final fakeService = FakeScoringService({'ones': 2});
      final notifier = GameNotifier(
        diceService: FakeDiceService([[1, 1, 2, 3, 4]]),
        scoringService: fakeService,
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      expect(notifier.state.scores['ones'], equals(2));
    });

    test('scoreCategory calculates correct score for yatzy with fake', () async {
      final fakeService = FakeScoringService({'yatzy': 50});
      final notifier = GameNotifier(
        diceService: FakeDiceService([[5, 5, 5, 5, 5]]),
        scoringService: fakeService,
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('yatzy');
      notifier.scoreCategory('yatzy');

      expect(notifier.state.scores['yatzy'], equals(50));
    });

    test('scoreCategory returns 0 when no dice rolled', () {
      final notifier = GameNotifier(
        scoringService: FakeScoringService({'ones': 10}),
        rollAnimationDelay: Duration.zero,
      );

      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      expect(notifier.state.scores['ones'], equals(0));
    });

    test('scoreCategory with real ScoringService - ones', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[1, 1, 2, 3, 4]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      expect(notifier.state.scores['ones'], equals(2));
    });

    test('scoreCategory with real ScoringService - sixes', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[6, 6, 6, 3, 4]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('sixes');
      notifier.scoreCategory('sixes');

      expect(notifier.state.scores['sixes'], equals(18));
    });

    test('scoreCategory with real ScoringService - yatzy', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[3, 3, 3, 3, 3]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('yatzy');
      notifier.scoreCategory('yatzy');

      expect(notifier.state.scores['yatzy'], equals(50));
    });

    test('scoreCategory with real ScoringService - full house', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[2, 2, 5, 5, 5]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('fullHouse');
      notifier.scoreCategory('fullHouse');

      expect(notifier.state.scores['fullHouse'], equals(25));
    });

    test('scoreCategory with real ScoringService - small straight', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[1, 2, 3, 4, 5]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('smallStraight');
      notifier.scoreCategory('smallStraight');

      expect(notifier.state.scores['smallStraight'], equals(30));
    });

    test('scoreCategory with real ScoringService - large straight', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[2, 3, 4, 5, 6]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('largeStraight');
      notifier.scoreCategory('largeStraight');

      expect(notifier.state.scores['largeStraight'], equals(40));
    });

    test('scoreCategory with real ScoringService - three of a kind', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[4, 4, 4, 2, 3]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('threeOfAKind');
      notifier.scoreCategory('threeOfAKind');

      expect(notifier.state.scores['threeOfAKind'], equals(17));
    });

    test('scoreCategory with real ScoringService - four of a kind', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[2, 2, 2, 2, 5]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('fourOfAKind');
      notifier.scoreCategory('fourOfAKind');

      expect(notifier.state.scores['fourOfAKind'], equals(13));
    });

    test('scoreCategory with real ScoringService - chance', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[3, 4, 5, 6, 2]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('chance');
      notifier.scoreCategory('chance');

      expect(notifier.state.scores['chance'], equals(20));
    });

    test('scoreCategory with real ScoringService - house', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[3, 3, 1, 1, 3]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('house');
      notifier.scoreCategory('house');

      expect(notifier.state.scores['house'], equals(25));
    });

    test('scoreCategory returns 0 for non-matching patterns', () async {
      // No three of a kind in [1, 2, 3, 4, 5]
      final notifier = GameNotifier(
        diceService: FakeDiceService([[1, 2, 3, 4, 5]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('threeOfAKind');
      notifier.scoreCategory('threeOfAKind');

      expect(notifier.state.scores['threeOfAKind'], equals(0));
    });

    test('scoreCategory updates total score correctly', () async {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[1, 1, 2, 3, 4]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      await notifier.rollDice();
      notifier.selectCategory('ones');
      notifier.scoreCategory('ones');

      expect(notifier.state.totalScore, equals(2));
    });

    test('scoreCategory does nothing when no category selected', () {
      final notifier = GameNotifier(
        diceService: FakeDiceService([[1, 1, 2, 3, 4]]),
        scoringService: ScoringService(),
        rollAnimationDelay: Duration.zero,
        initialState: const GameState(currentRollsRemaining: 2),
      );

      // Don't select a category
      notifier.scoreCategory('ones');

      expect(notifier.state.scores, isEmpty);
    });

    test('GameNotifier accepts custom ScoringService', () {
      final customService = ScoringService();
      final customNotifier = GameNotifier(scoringService: customService);

      expect(customNotifier, isNotNull);
    });
  });
}
