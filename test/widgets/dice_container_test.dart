import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/animations/dice_roll_animation.dart';
import 'package:poker_dice/widgets/dice_container.dart';
import 'package:poker_dice/widgets/die_widget.dart';
import 'package:poker_dice/providers/game_provider.dart';

void main() {
  group('DiceContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    Widget buildDiceContainer({
      List<int>? diceRoll,
      bool? isRolling,
    }) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: DiceContainer(
              diceRoll: diceRoll,
              isRolling: isRolling,
            ),
          ),
        ),
      );
    }

    testWidgets('renders 5 DieWidgets when dice roll provided', (tester) async {
      await tester.pumpWidget(
        buildDiceContainer(diceRoll: [1, 2, 3, 4, 5]),
      );
      expect(find.byType(DieWidget), findsNWidgets(5));
    });

    testWidgets('renders 5 placeholders when dice roll is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildDiceContainer());
      // Should find 5 SizedBox placeholders instead of DieWidgets
      expect(find.byType(DieWidget), findsNothing);
      expect(find.text('?'), findsNWidgets(5));
    });

    testWidgets('wraps each die in DieRollAnimation', (tester) async {
      await tester.pumpWidget(
        buildDiceContainer(diceRoll: [1, 2, 3, 4, 5]),
      );
      expect(find.byType(DieRollAnimation), findsNWidgets(5));
    });

    testWidgets('shows rolling animation state', (tester) async {
      await tester.pumpWidget(
        buildDiceContainer(diceRoll: [1, 2, 3, 4, 5], isRolling: true),
      );
      // All DieRollAnimations should be present with isRolling true
      final animations = find.byType(DieRollAnimation);
      expect(animations, findsNWidgets(5));
    });

    testWidgets('shows non-rolling state when not rolling', (tester) async {
      await tester.pumpWidget(
        buildDiceContainer(diceRoll: [1, 2, 3, 4, 5], isRolling: false),
      );
      final animations = find.byType(DieRollAnimation);
      expect(animations, findsNWidgets(5));
    });
  });

  group('held dice interactions', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier(rollAnimationDelay: Duration.zero);
    });

    testWidgets('tapping die toggles held state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameNotifierProvider.overrideWith((_) => notifier),
          ],
          child: MaterialApp(home: DiceContainer()),
        ),
      );
      await tester.pumpAndSettle();

      // Roll dice through notifier
      notifier.rollDice();
      await tester.pump();

      // Find all die widgets
      final dies = find.byType(DieWidget);
      expect(dies, findsNWidgets(5));

      // First die should not be held
      expect(notifier.state.effectiveHeldDice[0], isFalse);

      // Tap first die
      await tester.tap(find.byType(DieWidget).first);
      await tester.pump();

      // First die should now be held
      expect(notifier.state.effectiveHeldDice[0], isTrue);
    });

    testWidgets('tapping held die un-holds it', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameNotifierProvider.overrideWith((_) => notifier),
          ],
          child: MaterialApp(home: DiceContainer()),
        ),
      );
      await tester.pumpAndSettle();

      notifier.rollDice();
      await tester.pump();

      // Tap first die to hold
      await tester.tap(find.byType(DieWidget).first);
      await tester.pump();
      expect(notifier.state.effectiveHeldDice[0], isTrue);

      // Tap again to un-hold
      await tester.tap(find.byType(DieWidget).first);
      await tester.pump();
      expect(notifier.state.effectiveHeldDice[0], isFalse);
    });

    testWidgets('cannot hold dice when no dice rolled', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameNotifierProvider.overrideWith((_) => notifier),
          ],
          child: MaterialApp(home: DiceContainer()),
        ),
      );
      await tester.pumpAndSettle();

      // Should show 5 placeholders, no DieWidgets
      expect(find.byType(DieWidget), findsNothing);
      expect(find.text('?'), findsNWidgets(5));
    });

    testWidgets('held state preserved after re-roll', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameNotifierProvider.overrideWith((_) => notifier),
          ],
          child: MaterialApp(home: DiceContainer()),
        ),
      );
      await tester.pumpAndSettle();

      notifier.rollDice();
      await tester.pump();

      // Hold first die
      await tester.tap(find.byType(DieWidget).first);
      await tester.pump();
      expect(notifier.state.effectiveHeldDice[0], isTrue);

      // Re-roll
      notifier.rollDice();
      await tester.pump();

      // First die should still be held
      expect(notifier.state.effectiveHeldDice[0], isTrue);
    });

    testWidgets('held state cleared after reset turn', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameNotifierProvider.overrideWith((_) => notifier),
          ],
          child: MaterialApp(home: DiceContainer()),
        ),
      );
      await tester.pumpAndSettle();

      notifier.rollDice();
      await tester.pump();

      // Hold first die
      await tester.tap(find.byType(DieWidget).first);
      await tester.pump();
      expect(notifier.state.effectiveHeldDice[0], isTrue);

      // Reset turn
      notifier.resetTurn();
      await tester.pump();

      // Held state should be cleared
      expect(notifier.state.effectiveHeldDice, everyElement(isFalse));
    });

    testWidgets('multiple dice can be held independently', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameNotifierProvider.overrideWith((_) => notifier),
          ],
          child: MaterialApp(home: DiceContainer()),
        ),
      );
      await tester.pumpAndSettle();

      notifier.rollDice();
      await tester.pump();

      // Hold first and third dice
      await tester.tap(find.byType(DieWidget).at(0));
      await tester.pump();
      await tester.tap(find.byType(DieWidget).at(2));
      await tester.pump();

      expect(notifier.state.effectiveHeldDice[0], isTrue);
      expect(notifier.state.effectiveHeldDice[1], isFalse);
      expect(notifier.state.effectiveHeldDice[2], isTrue);
      expect(notifier.state.effectiveHeldDice[3], isFalse);
      expect(notifier.state.effectiveHeldDice[4], isFalse);
    });
  });
}
