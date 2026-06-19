import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/widgets/dice_face.dart';
import 'package:poker_dice/widgets/dice_widget.dart';

void main() {
  group('DiceWidget', () {
    testWidgets('renders DiceFace with correct value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceWidget(dice: const Dice(value: 4))),
      );

      expect(find.byType(DiceFace), findsOneWidget);
      final diceFace = tester.widget<DiceFace>(find.byType(DiceFace));
      expect(diceFace.value, 4);
    });

    testWidgets('uses default size of 48.0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceWidget(dice: const Dice(value: 3))),
      );

      final diceFace = tester.widget<DiceFace>(find.byType(DiceFace));
      expect(diceFace.size, 48.0);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceWidget(dice: const Dice(value: 2), size: 64.0)),
      );

      final diceFace = tester.widget<DiceFace>(find.byType(DiceFace));
      expect(diceFace.size, 64.0);
    });

    testWidgets('tap invokes onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: DiceWidget(
            dice: const Dice(value: 1),
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(DiceWidget));
      expect(tapped, isTrue);
    });

    testWidgets('no onTap does not crash on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceWidget(dice: const Dice(value: 5))),
      );

      await tester.tap(find.byType(DiceWidget));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('held die shows amber border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceWidget(dice: const Dice(value: 3, isHeld: true))),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNotNull);
      expect(decoration.border!.top.color, Colors.amber);
      expect(decoration.border!.top.width, 3.0);
    });

    testWidgets('unheld die has no border but has background', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiceWidget(dice: const Dice(value: 3, isHeld: false)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isNull);
      expect(decoration.color, isNotNull);
    });

    testWidgets('uses theme surface color as default background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              surface: Colors.lightBlue,
            ),
          ),
          home: DiceWidget(dice: const Dice(value: 2)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.lightBlue);
    });

    testWidgets('custom background color is applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiceWidget(
            dice: const Dice(value: 4),
            backgroundColor: Colors.green,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green);
    });

    testWidgets('custom held color is applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiceWidget(
            dice: const Dice(value: 2, isHeld: true),
            heldColor: Colors.red,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border!.top.color, Colors.red);
    });

    testWidgets('custom held border width is applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiceWidget(
            dice: const Dice(value: 2, isHeld: true),
            heldBorderWidth: 5.0,
          ),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border!.top.width, 5.0);
    });

    testWidgets('semantics label includes value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceWidget(dice: const Dice(value: 5))),
      );

      final semantics = tester.getSemantics(find.byType(DiceWidget));
      expect(semantics.label, contains('5'));
    });

    testWidgets('semantics label includes held state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceWidget(dice: const Dice(value: 5, isHeld: true))),
      );

      final semantics = tester.getSemantics(find.byType(DiceWidget));
      expect(semantics.label, contains('held'));
    });

    testWidgets('supports const constructor', (tester) async {
      const DiceWidget dice = DiceWidget(dice: Dice(value: 1));
      expect(dice.dice.value, 1);
      expect(dice.size, 48.0);
      expect(dice.heldColor, Colors.amber);
      expect(dice.heldBorderWidth, 3.0);
      expect(dice.backgroundColor, isNull);
    });
  });
}
