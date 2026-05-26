import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/die.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/services/scoring_service.dart';

void main() {
  late ScoringService service;

  setUp(() {
    service = ScoringService();
  });

  DiceRoll roll(List<int> values) {
    return DiceRoll(dice: values.map((v) => Die(value: v)).toList());
  }

  group('Upper Section', () {
    test('test_ones_scores_correctly', () {
      expect(service.scoreOnes(roll([1, 3, 1, 5, 1])), equals(3));
      expect(service.scoreOnes(roll([2, 4, 6, 2, 4])), equals(0));
      expect(service.scoreOnes(roll([1, 1, 1, 1, 1])), equals(5));
    });

    test('test_twos_scores_correctly', () {
      expect(service.scoreTwos(roll([2, 2, 5, 3, 2])), equals(6));
      expect(service.scoreTwos(roll([1, 3, 5, 1, 3])), equals(0));
      expect(service.scoreTwos(roll([2, 2, 2, 2, 2])), equals(10));
    });

    test('test_threes_scores_correctly', () {
      expect(service.scoreThrees(roll([3, 1, 3, 3, 6])), equals(9));
      expect(service.scoreThrees(roll([1, 2, 4, 5, 6])), equals(0));
    });

    test('test_fours_scores_correctly', () {
      expect(service.scoreFours(roll([4, 4, 2, 4, 1])), equals(12));
      expect(service.scoreFours(roll([1, 2, 3, 5, 6])), equals(0));
    });

    test('test_fives_scores_correctly', () {
      expect(service.scoreFives(roll([5, 5, 3, 5, 6])), equals(15));
      expect(service.scoreFives(roll([1, 2, 3, 4, 6])), equals(0));
    });

    test('test_sixes_scores_correctly', () {
      expect(service.scoreSixes(roll([6, 1, 6, 6, 6])), equals(24));
      expect(service.scoreSixes(roll([1, 2, 3, 4, 5])), equals(0));
    });

    test('test_bonus_awarded_at_63', () {
      expect(service.calculateBonus(63), equals(35));
      expect(service.calculateBonus(100), equals(35));
    });

    test('test_bonus_not_awarded_below_63', () {
      expect(service.calculateBonus(62), equals(0));
      expect(service.calculateBonus(0), equals(0));
    });
  });

  group('Lower Section', () {
    test('test_three_of_a_kind_basic', () {
      expect(service.scoreThreeOfAKind(roll([3, 3, 3, 2, 6])), equals(17));
    });

    test('test_three_of_a_kind_with_extra_dice', () {
      // 4 of a kind also qualifies for 3 of a kind
      expect(service.scoreThreeOfAKind(roll([5, 5, 5, 5, 2])), equals(22));
      // 5 of a kind also qualifies
      expect(service.scoreThreeOfAKind(roll([4, 4, 4, 4, 4])), equals(20));
    });

    test('test_three_of_a_kind_returns_zero_when_not_qualified', () {
      expect(service.scoreThreeOfAKind(roll([1, 2, 3, 4, 5])), equals(0));
      expect(service.scoreThreeOfAKind(roll([1, 1, 2, 2, 3])), equals(0));
    });

    test('test_four_of_a_kind_basic', () {
      expect(service.scoreFourOfAKind(roll([4, 4, 4, 4, 1])), equals(17));
    });

    test('test_four_of_a_kind_returns_zero_when_not_qualified', () {
      expect(service.scoreFourOfAKind(roll([3, 3, 3, 2, 1])), equals(0));
      expect(service.scoreFourOfAKind(roll([1, 2, 3, 4, 5])), equals(0));
    });

    test('test_full_house_valid', () {
      expect(service.scoreFullHouse(roll([2, 2, 2, 5, 5])), equals(25));
      expect(service.scoreFullHouse(roll([6, 6, 1, 1, 1])), equals(25));
    });

    test('test_full_house_not_four_plus_one', () {
      expect(service.scoreFullHouse(roll([2, 2, 2, 2, 5])), equals(0));
    });

    test('test_full_house_not_five_of_a_kind', () {
      expect(service.scoreFullHouse(roll([3, 3, 3, 3, 3])), equals(0));
    });

    test('test_small_straight_four_consecutive', () {
      expect(service.scoreSmallStraight(roll([1, 2, 3, 4, 6])), equals(30));
      expect(service.scoreSmallStraight(roll([2, 3, 4, 5, 1])), equals(30));
    });

    test('test_small_straight_five_consecutive', () {
      expect(service.scoreSmallStraight(roll([1, 2, 3, 4, 5])), equals(30));
      expect(service.scoreSmallStraight(roll([2, 3, 4, 5, 6])), equals(30));
    });

    test('test_small_straight_not_consecutive', () {
      expect(service.scoreSmallStraight(roll([1, 3, 5, 2, 6])), equals(0));
      expect(service.scoreSmallStraight(roll([1, 1, 3, 5, 6])), equals(0));
    });

    test('test_large_straight_1_to_5', () {
      expect(service.scoreLargeStraight(roll([1, 2, 3, 4, 5])), equals(40));
    });

    test('test_large_straight_2_to_6', () {
      expect(service.scoreLargeStraight(roll([2, 3, 4, 5, 6])), equals(40));
    });

    test('test_large_straight_not_consecutive', () {
      expect(service.scoreLargeStraight(roll([1, 2, 3, 4, 6])), equals(0));
      expect(service.scoreLargeStraight(roll([1, 1, 2, 3, 4])), equals(0));
      expect(service.scoreLargeStraight(roll([1, 3, 5, 2, 6])), equals(0));
    });

    test('test_yatzy_five_of_a_kind', () {
      expect(service.scoreYatzy(roll([6, 6, 6, 6, 6])), equals(50));
      expect(service.scoreYatzy(roll([1, 1, 1, 1, 1])), equals(50));
      expect(service.scoreYatzy(roll([3, 3, 3, 3, 3])), equals(50));
    });

    test('test_yatzy_returns_zero_when_not_qualified', () {
      expect(service.scoreYatzy(roll([6, 6, 6, 6, 1])), equals(0));
      expect(service.scoreYatzy(roll([1, 2, 3, 4, 5])), equals(0));
    });

    test('test_chance_sum_all_dice', () {
      expect(service.scoreChance(roll([3, 4, 5, 2, 6])), equals(20));
      expect(service.scoreChance(roll([1, 1, 1, 1, 1])), equals(5));
      expect(service.scoreChance(roll([6, 6, 6, 6, 6])), equals(30));
    });
  });

  group('Edge Cases', () {
    test('test_category_returns_zero_when_not_qualified', () {
      final noMatch = roll([1, 1, 2, 2, 3]);
      expect(
        service.scoreCategory(Category.ones, roll([2, 3, 4, 5, 6])),
        equals(0),
      );
      expect(
        service.scoreCategory(Category.twos, roll([1, 3, 4, 5, 6])),
        equals(0),
      );
      expect(service.scoreCategory(Category.threeOfAKind, noMatch), equals(0));
      expect(service.scoreCategory(Category.fullHouse, noMatch), equals(0));
      expect(service.scoreCategory(Category.largeStraight, noMatch), equals(0));
      expect(service.scoreCategory(Category.yatzy, noMatch), equals(0));
    });

    test('test_multiple_categories_qualify', () {
      // [2,2,2,5,5] qualifies for threeOfAKind and fullHouse
      final fhRoll = roll([2, 2, 2, 5, 5]);
      expect(service.scoreCategory(Category.threeOfAKind, fhRoll), equals(16));
      expect(service.scoreCategory(Category.fullHouse, fhRoll), equals(25));
      expect(service.scoreCategory(Category.chance, fhRoll), equals(16));
    });

    test('test_yatzy_also_qualifies_for_lower_categories', () {
      final yatzyRoll = roll([5, 5, 5, 5, 5]);
      expect(service.scoreCategory(Category.yatzy, yatzyRoll), equals(50));
      expect(
        service.scoreCategory(Category.fourOfAKind, yatzyRoll),
        equals(25),
      );
      expect(
        service.scoreCategory(Category.threeOfAKind, yatzyRoll),
        equals(25),
      );
      expect(service.scoreCategory(Category.chance, yatzyRoll), equals(25));
    });

    test('test_large_straight_also_qualifies_for_small_straight', () {
      final largeStraight = roll([1, 2, 3, 4, 5]);
      expect(
        service.scoreCategory(Category.largeStraight, largeStraight),
        equals(40),
      );
      expect(
        service.scoreCategory(Category.smallStraight, largeStraight),
        equals(30),
      );
    });

    test('test_score_category_dispatches_correctly', () {
      final rollValues = roll([3, 3, 3, 1, 2]);
      expect(
        service.scoreCategory(Category.threes, rollValues),
        equals(service.scoreThrees(rollValues)),
      );
      expect(
        service.scoreCategory(Category.fives, rollValues),
        equals(service.scoreFives(rollValues)),
      );
      expect(
        service.scoreCategory(Category.sixes, rollValues),
        equals(service.scoreSixes(rollValues)),
      );
    });

    test('test_upper_section_all_dice_same_value', () {
      final allSixes = roll([6, 6, 6, 6, 6]);
      expect(service.scoreOnes(allSixes), equals(0));
      expect(service.scoreTwos(allSixes), equals(0));
      expect(service.scoreThrees(allSixes), equals(0));
      expect(service.scoreFours(allSixes), equals(0));
      expect(service.scoreFives(allSixes), equals(0));
      expect(service.scoreSixes(allSixes), equals(30));
    });

    test('test_small_straight_with_duplicates', () {
      // [1,1,2,3,4] has 4 consecutive (1,2,3,4) despite duplicate
      expect(service.scoreSmallStraight(roll([1, 1, 2, 3, 4])), equals(30));
      // [1,2,3,4,4] has 4 consecutive (1,2,3,4) despite duplicate
      expect(service.scoreSmallStraight(roll([1, 2, 3, 4, 4])), equals(30));
    });
  });
}
