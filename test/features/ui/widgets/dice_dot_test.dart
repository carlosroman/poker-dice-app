import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/ui/widgets/dice_dot.dart';

void main() {
  group('DiceDot', () {
    const diceSize = 100.0;

    testWidgets('renders dice value 1 with center pip', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 1, size: diceSize));

      // Verify Stack with 1 child (pip)
      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children.length, equals(1));
    });

    testWidgets('renders dice value 2 with 2 pips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 2, size: diceSize));

      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children.length, equals(2));
    });

    testWidgets('renders dice value 3 with 3 pips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 3, size: diceSize));

      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children.length, equals(3));
    });

    testWidgets('renders dice value 4 with 4 pips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 4, size: diceSize));

      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children.length, equals(4));
    });

    testWidgets('renders dice value 5 with 5 pips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 5, size: diceSize));

      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children.length, equals(5));
    });

    testWidgets('renders dice value 6 with 6 pips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 6, size: diceSize));

      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children.length, equals(6));
    });

    testWidgets('renders dice value 0 with no pips', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 0, size: diceSize));

      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children.length, equals(0));
    });

    testWidgets('renders dice value 7 with no pips (invalid value)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 7, size: diceSize));

      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      final stack = tester.widget<Stack>(stackFinder);
      expect(stack.children.length, equals(0));
    });

    testWidgets('uses custom pip color when provided', (
      WidgetTester tester,
    ) async {
      const customColor = Colors.red;
      await tester.pumpWidget(
        const DiceDot(value: 1, size: diceSize, pipColor: customColor),
      );

      // Find the Container that represents the pip (inside Align)
      final pipContainerFinder = find.descendant(
        of: find.byType(Align),
        matching: find.byType(Container),
      );

      expect(pipContainerFinder, findsOneWidget);

      final pipContainer = tester.widget<Container>(pipContainerFinder);
      final decoration = pipContainer.decoration as BoxDecoration;
      expect(decoration.color, equals(customColor));
    });

    testWidgets('shows background when showBackground is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const DiceDot(value: 1, size: diceSize, showBackground: true),
      );

      // Should have a Container with the background decoration
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('hides background when showBackground is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const DiceDot(value: 1, size: diceSize, showBackground: false),
      );

      // Should have SizedBox instead of background Container
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('uses custom size when provided', (WidgetTester tester) async {
      const customSize = 80.0;
      await tester.pumpWidget(const DiceDot(value: 1, size: customSize));

      // Verify the widget renders - size is used internally for pip dimensions
      final stackFinder = find.byType(Stack);
      expect(stackFinder, findsOneWidget);

      // Verify pip size is proportional to dice size
      final pipFinder = find.descendant(
        of: find.byType(Align),
        matching: find.byType(Container),
      );
      expect(pipFinder, findsOneWidget);

      final pipRenderBox = tester.renderObject<RenderBox>(pipFinder);
      expect(pipRenderBox.size.width, equals(customSize * 0.20));
      expect(pipRenderBox.size.height, equals(customSize * 0.20));
    });

    testWidgets('pips are aligned correctly for value 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 1, size: diceSize));

      final alignFinder = find.byType(Align);
      expect(alignFinder, findsOneWidget);

      final align = tester.widget<Align>(alignFinder);
      // Center pip should have Alignment(0, 0)
      expect(align.alignment, equals(Alignment.center));
    });

    testWidgets('pips are aligned correctly for value 2', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 2, size: diceSize));

      final alignFinders = find.byType(Align);
      expect(alignFinders, findsNWidgets(2));

      final aligns = alignFinders
          .evaluate()
          .map((e) => e.widget as Align)
          .toList();
      // Check that we have top-left (-0.6, -0.6) and bottom-right (0.6, 0.6)
      final hasTopLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == -0.6,
      );
      final hasBottomRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == 0.6,
      );

      expect(hasTopLeft, isTrue, reason: 'Should have top-left pip');
      expect(hasBottomRight, isTrue, reason: 'Should have bottom-right pip');
    });

    testWidgets('pips are aligned correctly for value 3', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 3, size: diceSize));

      final alignFinders = find.byType(Align);
      expect(alignFinders, findsNWidgets(3));

      final aligns = alignFinders
          .evaluate()
          .map((e) => e.widget as Align)
          .toList();

      final hasTopLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == -0.6,
      );
      final hasCenter = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.0 &&
            (a.alignment as Alignment).y == 0.0,
      );
      final hasBottomRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == 0.6,
      );

      expect(hasTopLeft, isTrue, reason: 'Should have top-left pip');
      expect(hasCenter, isTrue, reason: 'Should have center pip');
      expect(hasBottomRight, isTrue, reason: 'Should have bottom-right pip');
    });

    testWidgets('pips are aligned correctly for value 4', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 4, size: diceSize));

      final alignFinders = find.byType(Align);
      expect(alignFinders, findsNWidgets(4));

      final aligns = alignFinders
          .evaluate()
          .map((e) => e.widget as Align)
          .toList();

      final hasTopLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == -0.6,
      );
      final hasTopRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == -0.6,
      );
      final hasBottomLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == 0.6,
      );
      final hasBottomRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == 0.6,
      );

      expect(hasTopLeft, isTrue, reason: 'Should have top-left pip');
      expect(hasTopRight, isTrue, reason: 'Should have top-right pip');
      expect(hasBottomLeft, isTrue, reason: 'Should have bottom-left pip');
      expect(hasBottomRight, isTrue, reason: 'Should have bottom-right pip');
    });

    testWidgets('pips are aligned correctly for value 5', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 5, size: diceSize));

      final alignFinders = find.byType(Align);
      expect(alignFinders, findsNWidgets(5));

      final aligns = alignFinders
          .evaluate()
          .map((e) => e.widget as Align)
          .toList();

      final hasTopLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == -0.6,
      );
      final hasTopRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == -0.6,
      );
      final hasBottomLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == 0.6,
      );
      final hasBottomRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == 0.6,
      );
      final hasCenter = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.0 &&
            (a.alignment as Alignment).y == 0.0,
      );

      expect(hasTopLeft, isTrue, reason: 'Should have top-left pip');
      expect(hasTopRight, isTrue, reason: 'Should have top-right pip');
      expect(hasBottomLeft, isTrue, reason: 'Should have bottom-left pip');
      expect(hasBottomRight, isTrue, reason: 'Should have bottom-right pip');
      expect(hasCenter, isTrue, reason: 'Should have center pip');
    });

    testWidgets('pips are aligned correctly for value 6', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 6, size: diceSize));

      final alignFinders = find.byType(Align);
      expect(alignFinders, findsNWidgets(6));

      final aligns = alignFinders
          .evaluate()
          .map((e) => e.widget as Align)
          .toList();

      final hasTopLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == -0.6,
      );
      final hasTopRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == -0.6,
      );
      final hasMiddleLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == 0.0,
      );
      final hasMiddleRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == 0.0,
      );
      final hasBottomLeft = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == -0.6 &&
            (a.alignment as Alignment).y == 0.6,
      );
      final hasBottomRight = aligns.any(
        (a) =>
            (a.alignment as Alignment).x == 0.6 &&
            (a.alignment as Alignment).y == 0.6,
      );

      expect(hasTopLeft, isTrue, reason: 'Should have top-left pip');
      expect(hasTopRight, isTrue, reason: 'Should have top-right pip');
      expect(hasMiddleLeft, isTrue, reason: 'Should have middle-left pip');
      expect(hasMiddleRight, isTrue, reason: 'Should have middle-right pip');
      expect(hasBottomLeft, isTrue, reason: 'Should have bottom-left pip');
      expect(hasBottomRight, isTrue, reason: 'Should have bottom-right pip');
    });

    testWidgets('pips are circular', (WidgetTester tester) async {
      await tester.pumpWidget(const DiceDot(value: 1, size: diceSize));

      final containerFinder = find.descendant(
        of: find.byType(Align),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, equals(BoxShape.circle));
    });

    testWidgets('pips have correct size relative to dice', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const DiceDot(value: 1, size: diceSize));

      final containerFinder = find.descendant(
        of: find.byType(Align),
        matching: find.byType(Container),
      );

      expect(containerFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(containerFinder);
      expect(renderBox.size.width, equals(diceSize * 0.20));
      expect(renderBox.size.height, equals(diceSize * 0.20));
    });
  });
}
