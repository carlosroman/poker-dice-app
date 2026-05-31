import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/animations/dice_roll_animation.dart';
import 'package:poker_dice/widgets/dice_container.dart';
import 'package:poker_dice/widgets/die_widget.dart';

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
}
