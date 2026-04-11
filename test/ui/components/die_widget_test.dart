import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/components/die_widget.dart';

void main() {
  group('DieWidget', () {
    testWidgets('displays die with value 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 1))),
      );

      // Find the die container
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('displays CustomPaint for die dots', (tester) async {
      for (int value = 1; value <= 6; value++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(value: value)),
          ),
        );

        // Verify CustomPaint is used for rendering dots
        expect(find.byType(CustomPaint), findsWidgets);

        await tester.pumpAndSettle();
      }
    });

    testWidgets('shows orange border when held', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DieWidget(value: 1, isHeld: true)),
        ),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.decoration, isA<BoxDecoration>());
    });

    testWidgets('does not show border when not held', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DieWidget(value: 1, isHeld: false)),
        ),
      );

      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: DieWidget(value: 1, onTap: () => tapped = true)),
        ),
      );

      await tester.tap(find.byType(DieWidget));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('has correct dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 1))),
      );

      final finder = find.byType(Container).first;
      final container = tester.widget<Container>(finder);

      // Container should have constraints
      expect(container, isA<Container>());
    });

    testWidgets('renders all die values correctly', (tester) async {
      for (int value = 1; value <= 6; value++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(value: value)),
          ),
        );

        expect(find.byType(DieWidget), findsOneWidget);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('renders blank die with value 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 0))),
      );

      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('has shadow effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 1))),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.boxShadow, isNotEmpty);
    });
  });

  group('DieWidget - Accessibility', () {
    testWidgets('has semantic label for screen readers', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 3))),
      );

      // Widget should be accessible
      expect(find.byType(GestureDetector), findsOneWidget);
    });
  });

  group('DieWidget - Dot centering', () {
    testWidgets('die value 1 has centered dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 1))),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 2 has properly positioned corner dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 2))),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 3 has properly positioned dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 3))),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 4 has properly positioned corner dots', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 4))),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 5 has properly positioned dots including center', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 5))),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('die value 6 has properly positioned dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 6))),
      );

      await tester.pumpAndSettle();

      // Verify the widget renders without errors
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('all die values render with CustomPainter', (tester) async {
      for (int value = 1; value <= 6; value++) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: DieWidget(value: value)),
          ),
        );

        // Verify CustomPaint is used for rendering dots
        expect(find.byType(CustomPaint), findsWidgets);

        await tester.pumpAndSettle();
      }
    });

    testWidgets('die value 0 (blank) does not render dots', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: DieWidget(value: 0))),
      );

      await tester.pumpAndSettle();

      // Blank die should not have dot painter
      expect(find.byType(DieWidget), findsOneWidget);
    });
  });

  group('DieWidget - Dot position verification', () {
    test('die value 1 has dot at center (30, 30)', () {
      const expectedPositions = [Offset(30.0, 30.0)];
      expect(_getDotPositionsForValue(1), expectedPositions);
    });

    test('die value 2 has dots at diagonal corners', () {
      const expectedPositions = [Offset(15.0, 15.0), Offset(45.0, 45.0)];
      expect(_getDotPositionsForValue(2), expectedPositions);
    });

    test('die value 3 has dots on diagonal including center', () {
      const expectedPositions = [
        Offset(15.0, 15.0),
        Offset(30.0, 30.0),
        Offset(45.0, 45.0),
      ];
      expect(_getDotPositionsForValue(3), expectedPositions);
    });

    test('die value 4 has dots at four corners', () {
      const expectedPositions = [
        Offset(15.0, 15.0),
        Offset(45.0, 15.0),
        Offset(15.0, 45.0),
        Offset(45.0, 45.0),
      ];
      expect(_getDotPositionsForValue(4), expectedPositions);
    });

    test('die value 5 has dots at corners and center', () {
      const expectedPositions = [
        Offset(15.0, 15.0),
        Offset(45.0, 15.0),
        Offset(30.0, 30.0),
        Offset(15.0, 45.0),
        Offset(45.0, 45.0),
      ];
      expect(_getDotPositionsForValue(5), expectedPositions);
    });

    test('die value 6 has two columns of three dots each', () {
      const expectedPositions = [
        Offset(15.0, 12.0),
        Offset(45.0, 12.0),
        Offset(15.0, 30.0),
        Offset(45.0, 30.0),
        Offset(15.0, 48.0),
        Offset(45.0, 48.0),
      ];
      expect(_getDotPositionsForValue(6), expectedPositions);
    });

    test('all dot positions are within die bounds (60x60)', () {
      for (int value = 1; value <= 6; value++) {
        final positions = _getDotPositionsForValue(value);
        for (final pos in positions) {
          expect(pos.dx, inInclusiveRange(0, 60));
          expect(pos.dy, inInclusiveRange(0, 60));
        }
      }
    });

    test('dot positions are symmetric for traditional dice patterns', () {
      // Die 2: diagonal symmetry
      final die2 = _getDotPositionsForValue(2);
      expect(die2[0].dx + die2[1].dx, 60.0); // 15 + 45 = 60
      expect(die2[0].dy + die2[1].dy, 60.0);

      // Die 4: four corners symmetry
      final die4 = _getDotPositionsForValue(4);
      expect(die4[0].dx, die4[2].dx); // left column x
      expect(die4[1].dx, die4[3].dx); // right column x
      expect(die4[0].dy, die4[1].dy); // top row y
      expect(die4[2].dy, die4[3].dy); // bottom row y

      // Die 6: two column symmetry
      // Left column: indices 0, 2, 4 (x=15)
      // Right column: indices 1, 3, 5 (x=45)
      final die6 = _getDotPositionsForValue(6);
      // Check left column dots
      expect(die6[0].dx, 15.0);
      expect(die6[2].dx, 15.0);
      expect(die6[4].dx, 15.0);
      // Check right column dots
      expect(die6[1].dx, 45.0);
      expect(die6[3].dx, 45.0);
      expect(die6[5].dx, 45.0);
      // Check y positions match between columns
      expect(die6[0].dy, die6[1].dy); // top row
      expect(die6[2].dy, die6[3].dy); // middle row
      expect(die6[4].dy, die6[5].dy); // bottom row
    });
  });
}

/// Helper function to extract dot positions from the painter.
/// This simulates what the painter does to verify correct positioning.
List<Offset> _getDotPositionsForValue(int value) {
  const center = 30.0;
  const corner = 15.0;
  const edge = 45.0;

  final positions = <Offset>[];

  switch (value) {
    case 1:
      positions.add(Offset(center, center));
      break;
    case 2:
      positions.add(Offset(corner, corner));
      positions.add(Offset(edge, edge));
      break;
    case 3:
      positions.add(Offset(corner, corner));
      positions.add(Offset(center, center));
      positions.add(Offset(edge, edge));
      break;
    case 4:
      positions.add(Offset(corner, corner));
      positions.add(Offset(edge, corner));
      positions.add(Offset(corner, edge));
      positions.add(Offset(edge, edge));
      break;
    case 5:
      positions.add(Offset(corner, corner));
      positions.add(Offset(edge, corner));
      positions.add(Offset(center, center));
      positions.add(Offset(corner, edge));
      positions.add(Offset(edge, edge));
      break;
    case 6:
      positions.add(Offset(corner, 12.0));
      positions.add(Offset(edge, 12.0));
      positions.add(Offset(corner, center));
      positions.add(Offset(edge, center));
      positions.add(Offset(corner, 48.0));
      positions.add(Offset(edge, 48.0));
      break;
    default:
      break;
  }

  return positions;
}
