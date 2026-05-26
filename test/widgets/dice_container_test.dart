import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/die.dart';
import 'package:poker_dice/models/dice_roll.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/widgets/dice_container.dart';
import 'package:poker_dice/widgets/die_widget.dart';

void main() {
  group('DiceContainer', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() => container.dispose());

    Widget buildDiceContainer({DiceRoll? diceRoll, bool isInteractive = true}) {
      return UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: DiceContainer(
              diceRoll: diceRoll,
              isInteractive: isInteractive,
            ),
          ),
        ),
      );
    }

    testWidgets('renders 5 DieWidgets when dice roll provided', (tester) async {
      final dice = DiceRoll(
        dice: [
          Die(value: 1),
          Die(value: 2),
          Die(value: 3),
          Die(value: 4),
          Die(value: 5),
        ],
      );
      await tester.pumpWidget(buildDiceContainer(diceRoll: dice));
      expect(find.byType(DieWidget), findsNWidgets(5));
    });

    testWidgets('renders 5 placeholders when dice roll is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildDiceContainer());
      // Should find 5 SizedBox placeholders instead of DieWidgets
      expect(find.byType(DieWidget), findsNothing);
    });

    testWidgets('calls toggleDieHold on tap when interactive', (tester) async {
      // Pre-populate notifier state with dice
      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.rollDice();

      final dice = DiceRoll(
        dice: [
          Die(value: 1),
          Die(value: 2),
          Die(value: 3),
          Die(value: 4),
          Die(value: 5),
        ],
      );
      await tester.pumpWidget(buildDiceContainer(diceRoll: dice));

      // Tap the first die
      await tester.tap(find.byType(DieWidget).first);
      await tester.pumpAndSettle();

      // Verify the notifier state was updated
      final state = container.read(gameNotifierProvider);
      expect(state.currentDiceRoll?.dice[0].isHeld, isTrue);
    });

    testWidgets('does not call toggleDieHold when not interactive', (
      tester,
    ) async {
      // Pre-populate notifier state with dice
      final notifier = container.read(gameNotifierProvider.notifier);
      notifier.rollDice();

      final dice = DiceRoll(
        dice: [
          Die(value: 1),
          Die(value: 2),
          Die(value: 3),
          Die(value: 4),
          Die(value: 5),
        ],
      );
      await tester.pumpWidget(
        buildDiceContainer(diceRoll: dice, isInteractive: false),
      );

      // Tap the first die
      await tester.tap(find.byType(DieWidget).first);
      await tester.pumpAndSettle();

      // Verify the notifier state was NOT updated
      final state = container.read(gameNotifierProvider);
      expect(state.currentDiceRoll?.dice[0].isHeld, isFalse);
    });
  });
}
