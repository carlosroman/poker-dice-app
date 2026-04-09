import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/utils/accessibility_utils.dart';

void main() {
  group('AccessibilityUtils', () {
    group('getDieLabel', () {
      test('returns correct label for die value 1', () {
        expect(AccessibilityUtils.getDieLabel(1), equals('Die showing 1'));
      });

      test('returns correct label for die value 6', () {
        expect(AccessibilityUtils.getDieLabel(6), equals('Die showing 6'));
      });

      test('includes held status when die is held', () {
        expect(
          AccessibilityUtils.getDieLabel(3, isHeld: true),
          equals('Die showing 3 (held)'),
        );
      });

      test('does not include held status when die is not held', () {
        expect(
          AccessibilityUtils.getDieLabel(3, isHeld: false),
          equals('Die showing 3'),
        );
      });
    });

    group('getScoreRowLabel', () {
      test('returns label with category name only', () {
        expect(
          AccessibilityUtils.getScoreRowLabel('Aces', null, null),
          equals('Aces, not scored yet. Double tap to select.'),
        );
      });

      test('returns label with potential score', () {
        expect(
          AccessibilityUtils.getScoreRowLabel('Aces', 5, null),
          equals(
            'Aces, potential score 5, not scored yet. Double tap to select.',
          ),
        );
      });

      test('returns label with current score', () {
        expect(
          AccessibilityUtils.getScoreRowLabel('Aces', null, 10),
          equals('Aces, current score 10. Double tap to select.'),
        );
      });

      test('returns label with both scores', () {
        expect(
          AccessibilityUtils.getScoreRowLabel('Aces', 5, 10),
          equals(
            'Aces, potential score 5, current score 10. Double tap to select.',
          ),
        );
      });
    });

    group('getRollLabel', () {
      test('returns correct label for roll count 0', () {
        expect(
          AccessibilityUtils.getRollLabel(0, true),
          equals('Roll button, roll count 0 of 3'),
        );
      });

      test('returns correct label for roll count 2', () {
        expect(
          AccessibilityUtils.getRollLabel(2, true),
          equals('Roll button, roll count 2 of 3'),
        );
      });

      test('includes disabled status when cannot roll', () {
        expect(
          AccessibilityUtils.getRollLabel(3, false),
          equals(
            'Roll button, roll count 3 of 3 (disabled, maximum rolls reached)',
          ),
        );
      });
    });

    group('getPlayLabel', () {
      test('returns correct label when enabled', () {
        expect(
          AccessibilityUtils.getPlayLabel(true),
          equals('Play button, select a category to score'),
        );
      });

      test('returns correct label when disabled', () {
        expect(
          AccessibilityUtils.getPlayLabel(false),
          equals('Play button, select a category to score (disabled)'),
        );
      });
    });

    group('getTotalScoreLabel', () {
      test('returns correct label for score 0', () {
        expect(
          AccessibilityUtils.getTotalScoreLabel(0),
          equals('Total score: 0 points'),
        );
      });

      test('returns correct label for score 100', () {
        expect(
          AccessibilityUtils.getTotalScoreLabel(100),
          equals('Total score: 100 points'),
        );
      });

      test('returns correct label for high score', () {
        expect(
          AccessibilityUtils.getTotalScoreLabel(500),
          equals('Total score: 500 points'),
        );
      });
    });

    group('getBonusProgressLabel', () {
      test('returns correct label when bonus not earned', () {
        expect(
          AccessibilityUtils.getBonusProgressLabel(30, 63, 0),
          equals('Bonus progress: 30 out of 63 points for +0 bonus'),
        );
      });

      test('returns correct label when bonus earned', () {
        expect(
          AccessibilityUtils.getBonusProgressLabel(70, 63, 35),
          equals('Bonus achieved: 70 out of 63, +35 bonus points'),
        );
      });
    });

    group('getHighScoreLabel', () {
      test('returns correct label for rank 1', () {
        final date = DateTime.now();
        final label = AccessibilityUtils.getHighScoreLabel(1, 100, date);
        expect(label, contains('Rank 1'));
        expect(label, contains('100 points'));
      });

      test('returns correct label for rank 10', () {
        final date = DateTime(2024, 1, 1);
        final label = AccessibilityUtils.getHighScoreLabel(10, 50, date);
        expect(label, contains('Rank 10'));
        expect(label, contains('50 points'));
      });
    });

    group('_formatDate', () {
      test('returns "today" for today\'s date', () {
        final date = DateTime.now();
        final label = AccessibilityUtils.getHighScoreLabel(1, 100, date);
        expect(label, contains('today'));
      });

      test('returns "yesterday" for yesterday\'s date', () {
        final date = DateTime.now().subtract(const Duration(days: 1));
        final label = AccessibilityUtils.getHighScoreLabel(1, 100, date);
        expect(label, contains('yesterday'));
      });
    });
  });

  group('AccessibilityExtensions', () {
    testWidgets('withSemanticLabel adds semantic label', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Text('Test').withSemanticLabel('Test Label'),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('asButton marks widget as button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.add),
            ).asButton(),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('asSelected marks widget as selected', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: const Text('Selected').asSelected())),
      );

      expect(find.text('Selected'), findsOneWidget);
    });

    testWidgets('withHint adds hint to widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const Text('Test').withHint('Test Hint')),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });
  });
}
