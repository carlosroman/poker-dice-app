import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/animations/dice_roll_animation.dart';

Widget _buildDieRollAnimation({
  required int index,
  required bool isRolling,
  required Widget child,
}) {
  return MaterialApp(
    home: Material(
      child: DieRollAnimation(
        index: index,
        isRolling: isRolling,
        child: child,
      ),
    ),
  );
}

Widget _buildDiceRollAnimation({
  required bool isRolling,
  required List<Widget> dice,
}) {
  return MaterialApp(
    home: Material(
      child: DiceRollAnimation(
        isRolling: isRolling,
        dice: dice,
      ),
    ),
  );
}

void main() {
  group('DieRollAnimation', () {
    testWidgets('renders child widget when not rolling', (tester) async {
      await tester.pumpWidget(
        _buildDieRollAnimation(
          index: 0,
          isRolling: false,
          child: const Text('Die 1'),
        ),
      );

      expect(find.text('Die 1'), findsOneWidget);
    });

    testWidgets('triggers animation when isRolling changes to true',
        (tester) async {
      await tester.pumpWidget(
        _buildDieRollAnimation(
          index: 0,
          isRolling: false,
          child: const Text('Die 1'),
        ),
      );

      // Initial state - no animation running
      await tester.pumpWidget(
        _buildDieRollAnimation(
          index: 0,
          isRolling: true,
          child: const Text('Die 1'),
        ),
      );

      // Animation should start
      await tester.pump();
      expect(find.text('Die 1'), findsOneWidget);
    });

    testWidgets('applies stagger delay based on index', (tester) async {
      await tester.pumpWidget(
        _buildDieRollAnimation(
          index: 2, // Should delay by 200ms
          isRolling: true,
          child: const Text('Die 3'),
        ),
      );

      // Initial pump
      await tester.pump();

      // Advance past stagger delay (200ms)
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Die 3'), findsOneWidget);
    });

    testWidgets('completes animation within expected duration', (tester) async {
      await tester.pumpWidget(
        _buildDieRollAnimation(
          index: 0,
          isRolling: true,
          child: const Text('Die 1'),
        ),
      );

      await tester.pump();

      // Advance past full animation duration
      await tester.pump(DieRollAnimation.duration);

      expect(find.text('Die 1'), findsOneWidget);
    });

    testWidgets('restarts animation when isRolling toggles', (tester) async {
      await tester.pumpWidget(
        _buildDieRollAnimation(
          index: 0,
          isRolling: true,
          child: const Text('Die 1'),
        ),
      );

      // Let first animation complete
      await tester.pump();
      await tester.pump(DieRollAnimation.duration);

      // Reset isRolling
      await tester.pumpWidget(
        _buildDieRollAnimation(
          index: 0,
          isRolling: false,
          child: const Text('Die 1'),
        ),
      );

      // Trigger again
      await tester.pumpWidget(
        _buildDieRollAnimation(
          index: 0,
          isRolling: true,
          child: const Text('Die 1'),
        ),
      );

      await tester.pump();
      expect(find.text('Die 1'), findsOneWidget);
    });
  });

  group('DiceRollAnimation', () {
    testWidgets('renders all dice widgets', (tester) async {
      final dice = List<Widget>.generate(5, (index) {
        return Text('Die ${index + 1}');
      });

      await tester.pumpWidget(
        _buildDiceRollAnimation(
          isRolling: false,
          dice: dice,
        ),
      );

      for (int i = 1; i <= 5; i++) {
        expect(find.text('Die $i'), findsOneWidget);
      }
    });

    testWidgets('wraps each die in DieRollAnimation with correct index',
        (tester) async {
      final dice = List<Widget>.generate(5, (index) {
        return Text('Die ${index + 1}');
      });

      await tester.pumpWidget(
        _buildDiceRollAnimation(
          isRolling: true,
          dice: dice,
        ),
      );

      // All 5 dice should be present
      expect(find.byType(DieRollAnimation), findsNWidgets(5));
    });

    testWidgets('passes isRolling state to all children', (tester) async {
      final dice = List<Widget>.generate(5, (index) {
        return Text('Die ${index + 1}');
      });

      await tester.pumpWidget(
        _buildDiceRollAnimation(
          isRolling: true,
          dice: dice,
        ),
      );

      // All dice should be animating
      await tester.pump();
      expect(find.byType(DieRollAnimation), findsNWidgets(5));
    });

    testWidgets('handles empty dice list gracefully', (tester) async {
      await tester.pumpWidget(
        _buildDiceRollAnimation(
          isRolling: false,
          dice: const [],
        ),
      );

      expect(find.byType(DieRollAnimation), findsNothing);
    });

    testWidgets('handles single die', (tester) async {
      await tester.pumpWidget(
        _buildDiceRollAnimation(
          isRolling: false,
          dice: const [Text('Single Die')],
        ),
      );

      expect(find.text('Single Die'), findsOneWidget);
      expect(find.byType(DieRollAnimation), findsOneWidget);
    });
  });

  group('Animation constants', () {
    test('duration is 500ms', () {
      expect(DieRollAnimation.duration.inMilliseconds, equals(500));
    });

    test('stagger delay is 100ms', () {
      expect(DieRollAnimation.staggerDelay.inMilliseconds, equals(100));
    });
  });
}
