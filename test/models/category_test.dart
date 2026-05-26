import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';

void main() {
  group('Category', () {
    test('test_values_returns_all_14_categories', () {
      expect(Category.values.length, equals(14));
    });

    test('test_upper_section_has_6_categories', () {
      final upper = Category.getUpperCategories();
      expect(upper.length, equals(6));
      expect(upper, contains(Category.ones));
      expect(upper, contains(Category.twos));
      expect(upper, contains(Category.threes));
      expect(upper, contains(Category.fours));
      expect(upper, contains(Category.fives));
      expect(upper, contains(Category.sixes));
    });

    test('test_lower_section_has_8_categories', () {
      final lower = Category.getLowerCategories();
      expect(lower.length, equals(8));
      expect(lower, contains(Category.threeOfAKind));
      expect(lower, contains(Category.fourOfAKind));
      expect(lower, contains(Category.fullHouse));
      expect(lower, contains(Category.smallStraight));
      expect(lower, contains(Category.largeStraight));
      expect(lower, contains(Category.yatzy));
      expect(lower, contains(Category.house));
      expect(lower, contains(Category.chance));
    });

    test('test_isUpperSection_returns_true_for_upper', () {
      for (final cat in Category.getUpperCategories()) {
        expect(cat.isUpperSection, isTrue);
      }
    });

    test('test_isUpperSection_returns_false_for_lower', () {
      for (final cat in Category.getLowerCategories()) {
        expect(cat.isUpperSection, isFalse);
      }
    });

    test('test_displayName_returns_non_empty_string', () {
      for (final cat in Category.values) {
        expect(cat.displayName, isNotEmpty);
      }
    });

    test('test_displayNames_are_correct', () {
      expect(Category.ones.displayName, equals('Ones'));
      expect(Category.twos.displayName, equals('Twos'));
      expect(Category.threes.displayName, equals('Threes'));
      expect(Category.fours.displayName, equals('Fours'));
      expect(Category.fives.displayName, equals('Fives'));
      expect(Category.sixes.displayName, equals('Sixes'));
      expect(Category.threeOfAKind.displayName, equals('Three of a Kind'));
      expect(Category.fourOfAKind.displayName, equals('Four of a Kind'));
      expect(Category.fullHouse.displayName, equals('Full House'));
      expect(Category.smallStraight.displayName, equals('Small Straight'));
      expect(Category.largeStraight.displayName, equals('Large Straight'));
      expect(Category.yatzy.displayName, equals('Yatzy'));
      expect(Category.house.displayName, equals('House'));
      expect(Category.chance.displayName, equals('Chance'));
    });

    test('test_upper_and_lower_are_disjoint', () {
      final upper = Category.getUpperCategories().toSet();
      final lower = Category.getLowerCategories().toSet();
      expect(upper.intersection(lower), isEmpty);
    });

    test('test_upper_and_lower_cover_all_values', () {
      final combined = Category.getUpperCategories()
        ..addAll(Category.getLowerCategories());
      expect(combined.toSet(), unorderedEquals(Category.values.toSet()));
    });
  });
}
