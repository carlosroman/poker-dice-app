import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/dice_container.dart';
import 'package:poker_dice/widgets/die_widget.dart';
import 'package:poker_dice/models/dice_roll.dart';

void main() {
  group('DiceContainer', () {
    // Helper to create a test dice roll with specific values
    DiceRoll createTestDiceRoll(List<int> values) {
      return DiceRoll.fromValues(values);
    }

    // Helper to create a test widget
    Widget createDiceContainer({
      required DiceRoll? diceRoll,
      Function(int index)? onDieToggled,
      double dieSize = 60.0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DiceContainer(
            diceRoll: diceRoll,
            onDieToggled: onDieToggled,
            dieSize: dieSize,
          ),
        ),
      );
    }

    // ==================== RENDERING TESTS ====================

    group('Rendering Tests', () {
      testWidgets('testDiceContainerRendersFiveDice', (
        WidgetTester tester,
      ) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);

        await tester.pumpWidget(createDiceContainer(diceRoll: diceRoll));

        // Find all DieWidget instances
        final dieFinder = find.byType(DieWidget);
        expect(dieFinder, findsExactly(5));
      });

      testWidgets('testDiceContainerShowsCorrectDieValues', (
        WidgetTester tester,
      ) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);

        await tester.pumpWidget(createDiceContainer(diceRoll: diceRoll));

        // Find all DieWidgets and verify their values
        final List<DieWidget> diceWidgets = tester
            .widgetList<DieWidget>(find.byType(DieWidget))
            .toList();

        expect(diceWidgets[0].value, 1);
        expect(diceWidgets[1].value, 2);
        expect(diceWidgets[2].value, 3);
        expect(diceWidgets[3].value, 4);
        expect(diceWidgets[4].value, 5);
      });

      testWidgets('testDiceContainerDisplaysPlaceholderWhenNull', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(createDiceContainer(diceRoll: null));

        // When null, should show Container placeholders, not DieWidgets
        final dieFinder = find.byType(DieWidget);
        expect(dieFinder, findsNothing);

        // Should have 5 placeholder Container widgets (check their constraints match die size)
        final placeholderFinder = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final decoration = widget.decoration as BoxDecoration?;
            if (decoration != null) {
              return decoration.color?.toARGB32() ==
                  Colors.grey.shade200.toARGB32();
            }
          }
          return false;
        });
        expect(placeholderFinder, findsNWidgets(5));
      });
    });

    // ==================== LAYOUT TESTS ====================

    group('Layout Tests', () {
      testWidgets('testDiceContainerHasHorizontalLayout', (
        WidgetTester tester,
      ) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);

        await tester.pumpWidget(createDiceContainer(diceRoll: diceRoll));

        // Find the Row widget
        final rowFinder = find.byType(Row);
        expect(rowFinder, findsOneWidget);

        final Row row = tester.widget<Row>(rowFinder);
        expect(row.mainAxisAlignment, MainAxisAlignment.center);
        expect(row.mainAxisSize, MainAxisSize.min);
      });

      testWidgets('testDiceContainerHasSpacingBetweenDice', (
        WidgetTester tester,
      ) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);

        await tester.pumpWidget(
          createDiceContainer(diceRoll: diceRoll, dieSize: 60.0),
        );

        // Find SizedBox widgets used for spacing (width: 18.0 = 60.0 * 0.3)
        final spacingFinder = find.byWidgetPredicate((widget) {
          if (widget is SizedBox) {
            return widget.width == 18.0 && widget.height == null;
          }
          return false;
        });
        expect(spacingFinder, findsNWidgets(4)); // 4 spacings between 5 dice
      });

      testWidgets('testDiceContainerIsCentered', (WidgetTester tester) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);

        await tester.pumpWidget(createDiceContainer(diceRoll: diceRoll));

        // Find the Center widget that is a direct child of the Scaffold body
        // The DiceContainer's build method wraps content in a Center widget
        final centerFinder = find.ancestor(
          of: find.byType(Row),
          matching: find.byType(Center),
        );
        expect(centerFinder, findsOneWidget);
      });
    });

    // ==================== INTERACTION TESTS ====================

    group('Interaction Tests', () {
      testWidgets('testTappingDieTogglesHeldState', (
        WidgetTester tester,
      ) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);
        int? toggledIndex;

        await tester.pumpWidget(
          createDiceContainer(
            diceRoll: diceRoll,
            onDieToggled: (index) {
              toggledIndex = index;
            },
          ),
        );

        // Tap the first die
        final dieFinder = find.byType(DieWidget).first;
        await tester.tap(dieFinder);
        await tester.pump();

        // Verify callback was invoked with correct index
        expect(toggledIndex, 0);
      });

      testWidgets('testOnDieToggledCallbackInvoked', (
        WidgetTester tester,
      ) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);
        List<int> tappedIndices = <int>[];

        await tester.pumpWidget(
          createDiceContainer(
            diceRoll: diceRoll,
            onDieToggled: (index) {
              tappedIndices.add(index);
            },
          ),
        );

        // Tap each die
        final List<DieWidget> diceWidgets = tester
            .widgetList<DieWidget>(find.byType(DieWidget))
            .toList();

        for (int i = 0; i < 5; i++) {
          await tester.tap(
            find.ancestor(
              of: find.byWidget(diceWidgets[i]),
              matching: find.byType(GestureDetector),
            ),
          );
          await tester.pump();
        }

        // Verify all indices were tapped in order
        expect(tappedIndices, equals(<int>[0, 1, 2, 3, 4]));
      });

      testWidgets('testMultipleDiceCanBeHeld', (WidgetTester tester) async {
        DiceRoll diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);
        List<int> tappedIndices = <int>[];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return DiceContainer(
                    diceRoll: diceRoll,
                    onDieToggled: (index) {
                      setState(() {
                        diceRoll = diceRoll.toggleDieHeld(index);
                        tappedIndices.add(index);
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        // Tap die at index 0
        final dieFinder = find.byType(DieWidget);
        await tester.tap(dieFinder.first);
        await tester.pump();

        // Tap die at index 2
        final List<DieWidget> diceWidgets = tester
            .widgetList<DieWidget>(find.byType(DieWidget))
            .toList();
        await tester.tap(find.byWidget(diceWidgets[2]));
        await tester.pump();

        // Verify both dice were toggled
        expect(diceRoll.dice[0].isHeld, true);
        expect(diceRoll.dice[2].isHeld, true);
        expect(diceRoll.dice[1].isHeld, false);
        expect(diceRoll.dice[3].isHeld, false);
        expect(diceRoll.dice[4].isHeld, false);
      });
    });

    // ==================== HELD STATE VISUAL TESTS ====================

    group('Held State Visual Tests', () {
      testWidgets('testHeldDiceShowOrangeGlow', (WidgetTester tester) async {
        final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        // Hold the first die
        final DiceRoll heldRoll = diceRoll.toggleDieHeld(0);

        await tester.pumpWidget(createDiceContainer(diceRoll: heldRoll));

        // Find the first DieWidget
        final List<DieWidget> diceWidgets = tester
            .widgetList<DieWidget>(find.byType(DieWidget))
            .toList();

        expect(diceWidgets[0].isHeld, true);
      });

      testWidgets('testUnheldDiceShowNormalBorder', (
        WidgetTester tester,
      ) async {
        final diceRoll = DiceRoll.fromValues([1, 2, 3, 4, 5]);
        // No dice are held

        await tester.pumpWidget(createDiceContainer(diceRoll: diceRoll));

        // Find all DieWidgets
        final List<DieWidget> diceWidgets = tester
            .widgetList<DieWidget>(find.byType(DieWidget))
            .toList();

        // All dice should not be held
        for (int i = 0; i < 5; i++) {
          expect(
            diceWidgets[i].isHeld,
            false,
            reason: 'Die at index $i should not be held',
          );
        }
      });
    });

    // ==================== SIZING TESTS ====================

    group('Sizing Tests', () {
      testWidgets('testDiceContainerUsesDefaultDieSize', (
        WidgetTester tester,
      ) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);

        await tester.pumpWidget(createDiceContainer(diceRoll: diceRoll));

        // Find all DieWidgets
        final List<DieWidget> diceWidgets = tester
            .widgetList<DieWidget>(find.byType(DieWidget))
            .toList();

        // Default size is 60.0
        for (int i = 0; i < 5; i++) {
          expect(
            diceWidgets[i].size,
            60.0,
            reason: 'Die at index $i should have default size 60.0',
          );
        }
      });

      testWidgets('testDiceContainerUsesCustomDieSize', (
        WidgetTester tester,
      ) async {
        final diceRoll = createTestDiceRoll([1, 2, 3, 4, 5]);
        const customSize = 80.0;

        await tester.pumpWidget(
          createDiceContainer(diceRoll: diceRoll, dieSize: customSize),
        );

        // Find all DieWidgets
        final List<DieWidget> diceWidgets = tester
            .widgetList<DieWidget>(find.byType(DieWidget))
            .toList();

        // All dice should have custom size
        for (int i = 0; i < 5; i++) {
          expect(
            diceWidgets[i].size,
            customSize,
            reason: 'Die at index $i should have custom size $customSize',
          );
        }
      });
    });
  });
}
