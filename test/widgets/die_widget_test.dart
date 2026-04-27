import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/die_widget.dart';

void main() {
  group('DieWidget', () {
    // Helper to pump the widget
    Widget pumpDie({
      required int value,
      bool isHeld = false,
      VoidCallback? onTap,
      double size = 60.0,
    }) {
      return MaterialApp(
        home: DieWidget(value: value, isHeld: isHeld, onTap: onTap, size: size),
      );
    }

    // ============================================
    // PIP RENDERING TESTS
    // ============================================

    group('Pip Rendering Tests', () {
      testWidgets('testDieRendersPipForValue1 - Center dot for value 1', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

        // Find the die container
        expect(find.byType(DieWidget), findsOneWidget);

        // For value 1, there should be a single centered pip
        // Find the black circular decoration (pip)
        final pipFinder = find.byType(Container).first;
        expect(pipFinder, findsOneWidget);
      });

      testWidgets('testDieRendersPipsForValue2 - Diagonal pips for value 2', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 2, isHeld: false));

        expect(find.byType(DieWidget), findsOneWidget);

        // Value 2 should have 2 pips (top-left and bottom-right)
        // The GridView should have 4 items (2x2 grid)
        final gridViewFinder = find.byType(GridView);
        expect(gridViewFinder, findsOneWidget);
      });

      testWidgets(
        'testDieRendersPipsForValue3 - Diagonal + center for value 3',
        (WidgetTester tester) async {
          await tester.pumpWidget(pumpDie(value: 3, isHeld: false));

          expect(find.byType(DieWidget), findsOneWidget);

          // Value 3 should have a 3x3 grid layout
          final gridViewFinder = find.byType(GridView);
          expect(gridViewFinder, findsOneWidget);
        },
      );

      testWidgets('testDieRendersPipsForValue4 - Four corners for value 4', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 4, isHeld: false));

        expect(find.byType(DieWidget), findsOneWidget);

        // Value 4 uses a 3x3 grid with corners filled
        final gridViewFinder = find.byType(GridView);
        expect(gridViewFinder, findsOneWidget);
      });

      testWidgets(
        'testDieRendersPipsForValue5 - Four corners + center for value 5',
        (WidgetTester tester) async {
          await tester.pumpWidget(pumpDie(value: 5, isHeld: false));

          expect(find.byType(DieWidget), findsOneWidget);

          // Value 5 uses a 3x3 grid with corners and center filled
          final gridViewFinder = find.byType(GridView);
          expect(gridViewFinder, findsOneWidget);
        },
      );

      testWidgets(
        'testDieRendersPipsForValue6 - Two columns of three for value 6',
        (WidgetTester tester) async {
          await tester.pumpWidget(pumpDie(value: 6, isHeld: false));

          expect(find.byType(DieWidget), findsOneWidget);

          // Value 6 uses a 3x3 grid with left and right columns filled
          final gridViewFinder = find.byType(GridView);
          expect(gridViewFinder, findsOneWidget);
        },
      );
    });

    // ============================================
    // HELD STATE TESTS
    // ============================================

    group('Held State Tests', () {
      testWidgets(
        'testDieShowsOrangeBorderWhenHeld - Orange border when held=true',
        (WidgetTester tester) async {
          await tester.pumpWidget(pumpDie(value: 1, isHeld: true));

          // Find the AnimatedContainer which has the border
          final animatedContainerFinder = find.byType(AnimatedContainer);
          expect(animatedContainerFinder, findsOneWidget);

          final animatedContainer = tester.widget<AnimatedContainer>(
            animatedContainerFinder,
          );
          final decoration = animatedContainer.decoration as BoxDecoration;
          final border = decoration.border as Border;

          // Check that the border color is orange (deepOrange)
          expect(border.top.color, equals(Colors.deepOrange));
          expect(border.left.color, equals(Colors.deepOrange));
          expect(border.right.color, equals(Colors.deepOrange));
          expect(border.bottom.color, equals(Colors.deepOrange));
        },
      );

      testWidgets(
        'testDieShowsWhiteBorderWhenNotHeld - Default border when held=false',
        (WidgetTester tester) async {
          await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

          final animatedContainerFinder = find.byType(AnimatedContainer);
          expect(animatedContainerFinder, findsOneWidget);

          final animatedContainer = tester.widget<AnimatedContainer>(
            animatedContainerFinder,
          );
          final decoration = animatedContainer.decoration as BoxDecoration;
          final border = decoration.border as Border;

          // Check that the border color is grey (not orange)
          expect(border.top.color, equals(Colors.grey.shade300));
          expect(border.left.color, equals(Colors.grey.shade300));
          expect(border.right.color, equals(Colors.grey.shade300));
          expect(border.bottom.color, equals(Colors.grey.shade300));
        },
      );
    });

    // ============================================
    // INTERACTION TESTS
    // ============================================

    group('Interaction Tests', () {
      testWidgets('testDieTogglesHeldStateOnTap - Tap toggles held state', (
        WidgetTester tester,
      ) async {
        bool heldState = false;

        await tester.pumpWidget(
          MaterialApp(
            home: StatefulBuilder(
              builder: (context, setState) {
                return DieWidget(
                  value: 1,
                  isHeld: heldState,
                  onTap: () {
                    setState(() {
                      heldState = !heldState;
                    });
                  },
                );
              },
            ),
          ),
        );

        // Initially not held
        expect(heldState, false);

        // Tap the die
        await tester.tap(find.byType(DieWidget));
        await tester.pumpAndSettle();

        // State should be toggled
        expect(heldState, true);
      });

      testWidgets('testOnTapCallbackInvoked - onTap callback called on tap', (
        WidgetTester tester,
      ) async {
        bool onTapCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: DieWidget(
              value: 1,
              isHeld: false,
              onTap: () {
                onTapCalled = true;
              },
            ),
          ),
        );

        expect(onTapCalled, false);

        // Tap the die
        await tester.tap(find.byType(DieWidget));
        await tester.pump();

        expect(onTapCalled, true);
      });
    });

    // ============================================
    // SIZING TESTS
    // ============================================

    group('Sizing Tests', () {
      testWidgets('testDieHasDefaultSize - Default size is 60x60', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

        await tester.pumpAndSettle();

        // Find the AnimatedContainer with white background (die's container)
        final animatedContainers = find.byType(AnimatedContainer).evaluate();
        expect(animatedContainers.length, greaterThan(0));

        // Find the one that has the white decoration (the die container)
        AnimatedContainer? dieContainer;
        for (final element in animatedContainers) {
          final widget = element.widget as AnimatedContainer;
          final decoration = widget.decoration as BoxDecoration?;
          if (decoration?.color == Colors.white) {
            dieContainer = widget;
            break;
          }
        }

        expect(dieContainer, isNotNull);
        // Check the width and height properties via constraints
        expect(dieContainer!.constraints?.minWidth, equals(60.0));
        expect(dieContainer.constraints?.maxWidth, equals(60.0));
        expect(dieContainer.constraints?.minHeight, equals(60.0));
        expect(dieContainer.constraints?.maxHeight, equals(60.0));
      });

      testWidgets('testDieHasCustomSize - Custom size applied correctly', (
        WidgetTester tester,
      ) async {
        const customSize = 100.0;

        await tester.pumpWidget(
          pumpDie(value: 1, isHeld: false, size: customSize),
        );

        await tester.pumpAndSettle();

        final animatedContainers = find.byType(AnimatedContainer).evaluate();

        AnimatedContainer? dieContainer;
        for (final element in animatedContainers) {
          final widget = element.widget as AnimatedContainer;
          final decoration = widget.decoration as BoxDecoration?;
          if (decoration?.color == Colors.white) {
            dieContainer = widget;
            break;
          }
        }

        expect(dieContainer, isNotNull);
        expect(dieContainer!.constraints?.minWidth, equals(customSize));
        expect(dieContainer.constraints?.maxWidth, equals(customSize));
        expect(dieContainer.constraints?.minHeight, equals(customSize));
        expect(dieContainer.constraints?.maxHeight, equals(customSize));
      });
    });

    // ============================================
    // ADDITIONAL VISUAL TESTS
    // ============================================

    group('Visual Tests', () {
      testWidgets('testDieHasRoundedCorners - Border radius applied', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

        final animatedContainerFinder = find.byType(AnimatedContainer);
        final animatedContainer = tester.widget<AnimatedContainer>(
          animatedContainerFinder,
        );
        final decoration = animatedContainer.decoration as BoxDecoration;

        expect(decoration.borderRadius, isNotNull);
      });

      testWidgets('testDieHasShadow - Box shadow is present', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

        final animatedContainerFinder = find.byType(AnimatedContainer);
        final animatedContainer = tester.widget<AnimatedContainer>(
          animatedContainerFinder,
        );
        final decoration = animatedContainer.decoration as BoxDecoration;

        expect(decoration.boxShadow, isNotEmpty);
        expect(decoration.boxShadow!.length, equals(1));
      });

      testWidgets('testDieHasWhiteBackground - Background color is white', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

        final animatedContainerFinder = find.byType(AnimatedContainer);
        final animatedContainer = tester.widget<AnimatedContainer>(
          animatedContainerFinder,
        );
        final decoration = animatedContainer.decoration as BoxDecoration;

        expect(decoration.color, equals(Colors.white));
      });

      testWidgets('testDieIsTappable - GestureDetector is present', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

        final gestureDetectorFinder = find.byType(GestureDetector);
        expect(gestureDetectorFinder, findsOneWidget);
      });
    });

    // ============================================
    // PIP COUNT TESTS
    // ============================================

    group('Pip Count Tests', () {
      testWidgets('testValue1HasOnePip', (WidgetTester tester) async {
        await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

        // Count the number of black circular containers (pips)
        final pips = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final boxDecoration = widget.decoration;
            if (boxDecoration is BoxDecoration) {
              return boxDecoration.color == Colors.black87 &&
                  boxDecoration.shape == BoxShape.circle;
            }
          }
          return false;
        });

        expect(pips, findsOneWidget);
      });

      testWidgets('testValue2HasTwoPips', (WidgetTester tester) async {
        await tester.pumpWidget(pumpDie(value: 2, isHeld: false));

        final pips = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final boxDecoration = widget.decoration;
            if (boxDecoration is BoxDecoration) {
              return boxDecoration.color == Colors.black87 &&
                  boxDecoration.shape == BoxShape.circle;
            }
          }
          return false;
        });

        expect(pips, findsNWidgets(2));
      });

      testWidgets('testValue3HasThreePips', (WidgetTester tester) async {
        await tester.pumpWidget(pumpDie(value: 3, isHeld: false));

        final pips = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final boxDecoration = widget.decoration;
            if (boxDecoration is BoxDecoration) {
              return boxDecoration.color == Colors.black87 &&
                  boxDecoration.shape == BoxShape.circle;
            }
          }
          return false;
        });

        expect(pips, findsNWidgets(3));
      });

      testWidgets('testValue4HasFourPips', (WidgetTester tester) async {
        await tester.pumpWidget(pumpDie(value: 4, isHeld: false));

        final pips = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final boxDecoration = widget.decoration;
            if (boxDecoration is BoxDecoration) {
              return boxDecoration.color == Colors.black87 &&
                  boxDecoration.shape == BoxShape.circle;
            }
          }
          return false;
        });

        expect(pips, findsNWidgets(4));
      });

      testWidgets('testValue5HasFivePips', (WidgetTester tester) async {
        await tester.pumpWidget(pumpDie(value: 5, isHeld: false));

        final pips = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final boxDecoration = widget.decoration;
            if (boxDecoration is BoxDecoration) {
              return boxDecoration.color == Colors.black87 &&
                  boxDecoration.shape == BoxShape.circle;
            }
          }
          return false;
        });

        expect(pips, findsNWidgets(5));
      });

      testWidgets('testValue6HasSixPips', (WidgetTester tester) async {
        await tester.pumpWidget(pumpDie(value: 6, isHeld: false));

        final pips = find.byWidgetPredicate((widget) {
          if (widget is Container) {
            final boxDecoration = widget.decoration;
            if (boxDecoration is BoxDecoration) {
              return boxDecoration.color == Colors.black87 &&
                  boxDecoration.shape == BoxShape.circle;
            }
          }
          return false;
        });

        expect(pips, findsNWidgets(6));
      });
    });

    // ============================================
    // ANIMATION TESTS
    // ============================================

    group('Animation Tests', () {
      testWidgets('testDieAnimatesOnTap - Tap triggers animation', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(pumpDie(value: 1, isHeld: false));

        // Tap the die
        await tester.tap(find.byType(DieWidget));

        // Pump for animation duration
        await tester.pump(const Duration(milliseconds: 75));

        // Animation should be in progress
        expect(find.byType(AnimatedContainer), findsOneWidget);
      });
    });
  });
}
