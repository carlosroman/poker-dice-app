import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/animations/dice_roll_animation.dart';

Widget _buildDieRollAnimation({
  required int index,
  required bool isRolling,
  bool isHeld = false,
  required Widget child,
  Key? key,
}) {
  return MaterialApp(
    home: Material(
      child: DieRollAnimation(
        key: key,
        index: index,
        isRolling: isRolling,
        isHeld: isHeld,
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

/// Helper to check if a DieRollAnimation's immediate child is an AnimatedBuilder.
/// When isHeld=true, the build method returns widget.child directly (no AnimatedBuilder).
/// When isHeld=false, it returns AnimatedBuilder(...).
bool _hasAnimationWrapper(WidgetTester tester, Key key) {
  final element = tester.element(find.byKey(key));
  final renderObject = element.renderObject;
  // When held, the child is rendered directly.
  // When not held, an AnimatedBuilder wraps it which creates Transform.scale.
  // We check by looking for Transform-related render objects in the subtree.
  return find.descendant(
    of: find.byKey(key),
    matching: find.byType(Transform),
  ).evaluate().isNotEmpty;
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

    group('held dice', () {
      final heldDieKey = const ValueKey<int>(100);
      final rollingDieKey = const ValueKey<int>(101);

      testWidgets('held die does not animate when isRolling is true',
          (tester) async {
        await tester.pumpWidget(
          _buildDieRollAnimation(
            key: heldDieKey,
            index: 0,
            isRolling: true,
            isHeld: true,
            child: const Text('Held Die'),
          ),
        );

        expect(find.text('Held Die'), findsOneWidget);

        // Held die should have no Transform descendants (no animation)
        final hasTransform = find.descendant(
          of: find.byKey(heldDieKey),
          matching: find.byType(Transform),
        ).evaluate().isNotEmpty;
        expect(hasTransform, isFalse,
            reason: 'Held die should not have animation transforms');
      });

      testWidgets('held die renders child without AnimatedBuilder',
          (tester) async {
        await tester.pumpWidget(
          _buildDieRollAnimation(
            key: heldDieKey,
            index: 0,
            isRolling: true,
            isHeld: true,
            child: const Text('Held Die'),
          ),
        );

        expect(find.text('Held Die'), findsOneWidget);
        // Held dice skip AnimatedBuilder - check no Transform in subtree
        final hasTransform = find.descendant(
          of: find.byKey(heldDieKey),
          matching: find.byType(Transform),
        ).evaluate().isNotEmpty;
        expect(hasTransform, isFalse);
      });

      testWidgets('non-held die animates normally when rolling', (tester) async {
        await tester.pumpWidget(
          _buildDieRollAnimation(
            key: rollingDieKey,
            index: 0,
            isRolling: true,
            isHeld: false,
            child: const Text('Rolling Die'),
          ),
        );

        await tester.pump();

        expect(find.text('Rolling Die'), findsOneWidget);
        // Non-held dice should have animation transforms (Transform.scale, etc)
        final hasTransform = find.descendant(
          of: find.byKey(rollingDieKey),
          matching: find.byType(Transform),
        ).evaluate().isNotEmpty;
        expect(hasTransform, isTrue,
            reason: 'Non-held die should have animation transforms');
      });

      testWidgets('held die remains static when isRolling toggles',
          (tester) async {
        await tester.pumpWidget(
          _buildDieRollAnimation(
            key: heldDieKey,
            index: 0,
            isRolling: false,
            isHeld: true,
            child: const Text('Held Die'),
          ),
        );

        // Toggle to rolling
        await tester.pumpWidget(
          _buildDieRollAnimation(
            key: heldDieKey,
            index: 0,
            isRolling: true,
            isHeld: true,
            child: const Text('Held Die'),
          ),
        );

        await tester.pump();

        expect(find.text('Held Die'), findsOneWidget);
        // Still no animation transforms for held die
        final hasTransform = find.descendant(
          of: find.byKey(heldDieKey),
          matching: find.byType(Transform),
        ).evaluate().isNotEmpty;
        expect(hasTransform, isFalse);
      });

      testWidgets('isHeld defaults to false', (tester) async {
        await tester.pumpWidget(
          _buildDieRollAnimation(
            key: rollingDieKey,
            index: 0,
            isRolling: true,
            child: const Text('Default Die'),
          ),
        );

        await tester.pump();

        // Without explicit isHeld, should animate (Transform present)
        final hasTransform = find.descendant(
          of: find.byKey(rollingDieKey),
          matching: find.byType(Transform),
        ).evaluate().isNotEmpty;
        expect(hasTransform, isTrue,
            reason: 'Default isHeld=false should animate');
      });
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
