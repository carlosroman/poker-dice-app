import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/widgets/animated_dice.dart';
import 'package:poker_dice/widgets/dice_face.dart';

void main() {
  group('AnimatedDice', () {
    late GlobalKey<AnimatedDiceState> key;

    setUp(() {
      key = GlobalKey<AnimatedDiceState>();
    });

    testWidgets('renders DiceFace with correct value', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 4)),
        ),
      );

      expect(find.byType(DiceFace), findsOneWidget);
      final diceFace = tester.widget<DiceFace>(find.byType(DiceFace));
      expect(diceFace.value, 4);
    });

    testWidgets('uses default size of 48.0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 3)),
        ),
      );

      final diceFace = tester.widget<DiceFace>(find.byType(DiceFace));
      expect(diceFace.size, 48.0);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 2), size: 64.0),
        ),
      );

      final diceFace = tester.widget<DiceFace>(find.byType(DiceFace));
      expect(diceFace.size, 64.0);
    });

    testWidgets('tap invokes onTap callback', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(
            key: key,
            dice: const Dice(value: 1),
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(AnimatedDice));
      expect(tapped, isTrue);
    });

    testWidgets('no onTap does not crash on tap', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 5)),
        ),
      );

      await tester.tap(find.byType(AnimatedDice));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('held die shows amber border', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(
            key: key,
            dice: const Dice(value: 3, isHeld: true),
          ),
        ),
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
          home: AnimatedDice(
            key: key,
            dice: const Dice(value: 3, isHeld: false),
          ),
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
          home: AnimatedDice(key: key, dice: const Dice(value: 2)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.lightBlue);
    });

    testWidgets('custom background color is applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(
            key: key,
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
          home: AnimatedDice(
            key: key,
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
          home: AnimatedDice(
            key: key,
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
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 5)),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AnimatedDice));
      expect(semantics.label, contains('5'));
    });

    testWidgets('semantics label includes held state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(
            key: key,
            dice: const Dice(value: 5, isHeld: true),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(AnimatedDice));
      expect(semantics.label, contains('held'));
    });

    testWidgets('animate triggers animation that completes', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(
            key: key,
            dice: const Dice(value: 3),
            onAnimationComplete: () => completed = true,
          ),
        ),
      );

      expect(completed, isFalse);
      expect(key.currentState, isNotNull);

      // Trigger animation
      key.currentState!.animate();

      // Animation should be in progress (callback not yet fired)
      await tester.pump(const Duration(milliseconds: 100));
      expect(completed, isFalse);

      // Pump to completion
      await tester.pumpAndSettle();

      // Callback should have fired
      expect(completed, isTrue);
    });

    testWidgets('onAnimationComplete null does not crash', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 3)),
        ),
      );

      key.currentState!.animate();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('animate can be restarted mid-animation', (tester) async {
      int completedCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(
            key: key,
            dice: const Dice(value: 3),
            onAnimationComplete: () => completedCount++,
          ),
        ),
      );

      // Start first animation
      key.currentState!.animate();
      await tester.pump(const Duration(milliseconds: 200));

      // Restart while still animating
      key.currentState!.animate();
      await tester.pumpAndSettle();

      // Should have completed once (the restart cancels the first)
      expect(completedCount, 1);
    });

    testWidgets('RotationTransition and ScaleTransition are present', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 3)),
        ),
      );

      expect(find.byType(RotationTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);
    });

    testWidgets('animation completes in approximately 400ms', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(
            key: key,
            dice: const Dice(value: 3),
            onAnimationComplete: () => completed = true,
          ),
        ),
      );

      key.currentState!.animate();

      // At 300ms, animation should still be running
      await tester.pump(const Duration(milliseconds: 300));
      expect(completed, isFalse);

      // Let animation complete
      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });

    testWidgets('value 0 renders blank face', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 0)),
        ),
      );

      final diceFace = tester.widget<DiceFace>(find.byType(DiceFace));
      expect(diceFace.value, 0);
    });

    testWidgets('GestureDetector is present for tap handling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(key: key, dice: const Dice(value: 3)),
        ),
      );

      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('Semantics contains tap target when onTap provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AnimatedDice(
            key: key,
            dice: const Dice(value: 3),
            onTap: () {},
          ),
        ),
      );

      // Widget should be tappable
      await tester.tap(find.byType(AnimatedDice));
      expect(tester.takeException(), isNull);
    });
  });
}
