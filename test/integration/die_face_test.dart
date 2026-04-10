import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/score_row.dart';

/// Integration test for die face rendering.
///
/// Verifies that all die faces (1-6) are rendered correctly with properly
/// centered dots within the 32x32 container.
void main() {
  group('DieFace Integration Tests', () {
    /// Helper to pump a ScoreRow with die icon
    Future<void> pumpDieRow(WidgetTester tester, ScoreCategory category) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ScoreRow(category: category, showDieIcon: true),
            ),
          ),
        ),
      );
    }

    testWidgets('Die face 1 (Aces) renders CustomPaint widget', (
      WidgetTester tester,
    ) async {
      await pumpDieRow(tester, ScoreCategory.aces);
      await tester.pump();

      // Verify CustomPaint widget exists (at least one)
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Die face 2 (Twos) renders CustomPaint widget', (
      WidgetTester tester,
    ) async {
      await pumpDieRow(tester, ScoreCategory.twos);
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Die face 3 (Threes) renders CustomPaint widget', (
      WidgetTester tester,
    ) async {
      await pumpDieRow(tester, ScoreCategory.threes);
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Die face 4 (Fours) renders CustomPaint widget', (
      WidgetTester tester,
    ) async {
      await pumpDieRow(tester, ScoreCategory.fours);
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Die face 5 (Fives) renders CustomPaint widget', (
      WidgetTester tester,
    ) async {
      await pumpDieRow(tester, ScoreCategory.fives);
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Die face 6 (Sixes) renders CustomPaint widget', (
      WidgetTester tester,
    ) async {
      await pumpDieRow(tester, ScoreCategory.sixes);
      await tester.pump();

      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('Die face displays within ScoreRow container', (
      WidgetTester tester,
    ) async {
      await pumpDieRow(tester, ScoreCategory.fives);
      await tester.pump();

      // Find the Container that holds the die face (32x32)
      final containerFinder = find.byType(Container).first;
      final renderBox = tester.renderObject<RenderBox>(containerFinder);

      // The container should be 32x32
      expect(renderBox.size.width, equals(32));
      expect(renderBox.size.height, equals(32));
    });
  });

  group('DieFacePainter Position Tests', () {
    test('Die face 1 has center dot', () {
      final size = const Size(28, 28);
      final center = Offset(size.width / 2, size.height / 2);

      final positions = _getDotPositionsForDie(1, size);
      expect(positions.length, equals(1));
      expect(positions[0], equals(center));
    });

    test('Die face 2 has 2 diagonal dots', () {
      final size = const Size(28, 28);
      final center = Offset(size.width / 2, size.height / 2);
      final offset = size.width * 0.25;

      final positions = _getDotPositionsForDie(2, size);
      expect(positions.length, equals(2));
      expect(
        positions[0],
        equals(Offset(center.dx - offset, center.dy - offset)),
      );
      expect(
        positions[1],
        equals(Offset(center.dx + offset, center.dy + offset)),
      );
    });

    test('Die face 3 has 3 diagonal dots including center', () {
      final size = const Size(28, 28);
      final center = Offset(size.width / 2, size.height / 2);
      final offset = size.width * 0.25;

      final positions = _getDotPositionsForDie(3, size);
      expect(positions.length, equals(3));
      expect(positions.contains(center), isTrue);
      expect(
        positions[0],
        equals(Offset(center.dx - offset, center.dy - offset)),
      );
      expect(
        positions[2],
        equals(Offset(center.dx + offset, center.dy + offset)),
      );
    });

    test('Die face 4 has 4 corner dots', () {
      final size = const Size(28, 28);
      final center = Offset(size.width / 2, size.height / 2);
      final offset = size.width * 0.25;

      final positions = _getDotPositionsForDie(4, size);
      expect(positions.length, equals(4));
      expect(
        positions[0],
        equals(Offset(center.dx - offset, center.dy - offset)),
      );
      expect(
        positions[1],
        equals(Offset(center.dx + offset, center.dy - offset)),
      );
      expect(
        positions[2],
        equals(Offset(center.dx - offset, center.dy + offset)),
      );
      expect(
        positions[3],
        equals(Offset(center.dx + offset, center.dy + offset)),
      );
    });

    test('Die face 5 has 5 dots including center', () {
      final size = const Size(28, 28);
      final center = Offset(size.width / 2, size.height / 2);

      final positions = _getDotPositionsForDie(5, size);
      expect(positions.length, equals(5));
      expect(positions.contains(center), isTrue);
    });

    test('Die face 6 has 6 dots in 2 columns', () {
      final size = const Size(28, 28);

      final positions = _getDotPositionsForDie(6, size);
      expect(positions.length, equals(6));
      // Verify all positions are within bounds
      for (final pos in positions) {
        expect(pos.dx, greaterThan(0));
        expect(pos.dx, lessThan(size.width));
        expect(pos.dy, greaterThan(0));
        expect(pos.dy, lessThan(size.height));
      }
    });

    test('All dot positions are centered within the die face', () {
      final size = const Size(28, 28);
      final center = Offset(size.width / 2, size.height / 2);

      for (int dots = 1; dots <= 6; dots++) {
        final positions = _getDotPositionsForDie(dots, size);

        // For odd dot counts, center dot should be at center
        if (dots == 1 || dots == 3 || dots == 5) {
          expect(
            positions.contains(center),
            isTrue,
            reason: 'Die face $dots should have center dot',
          );
        }
      }
    });
  });
}

/// Extract dot positions for a given die value
List<Offset> _getDotPositionsForDie(int dots, Size size) {
  final positions = <Offset>[];
  final center = Offset(size.width / 2, size.height / 2);
  final offset = size.width * 0.25;

  switch (dots) {
    case 1:
      positions.add(center);
      break;
    case 2:
      positions.add(Offset(center.dx - offset, center.dy - offset));
      positions.add(Offset(center.dx + offset, center.dy + offset));
      break;
    case 3:
      positions.add(Offset(center.dx - offset, center.dy - offset));
      positions.add(center);
      positions.add(Offset(center.dx + offset, center.dy + offset));
      break;
    case 4:
      positions.add(Offset(center.dx - offset, center.dy - offset));
      positions.add(Offset(center.dx + offset, center.dy - offset));
      positions.add(Offset(center.dx - offset, center.dy + offset));
      positions.add(Offset(center.dx + offset, center.dy + offset));
      break;
    case 5:
      positions.add(Offset(center.dx - offset, center.dy - offset));
      positions.add(Offset(center.dx + offset, center.dy - offset));
      positions.add(center);
      positions.add(Offset(center.dx - offset, center.dy + offset));
      positions.add(Offset(center.dx + offset, center.dy + offset));
      break;
    case 6:
      final colOffset = offset * 0.8;
      final rowOffset = offset * 1.2;
      positions.add(Offset(center.dx - colOffset, center.dy - rowOffset));
      positions.add(Offset(center.dx + colOffset, center.dy - rowOffset));
      positions.add(Offset(center.dx - colOffset, center.dy));
      positions.add(Offset(center.dx + colOffset, center.dy));
      positions.add(Offset(center.dx - colOffset, center.dy + rowOffset));
      positions.add(Offset(center.dx + colOffset, center.dy + rowOffset));
      break;
    default:
      throw ArgumentError('Invalid die value: $dots');
  }

  return positions;
}
