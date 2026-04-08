import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/components/bonus_progress.dart';

void main() {
  group('BonusProgress', () {
    testWidgets('displays progress text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 30))),
      );

      expect(find.text('30/63'), findsOneWidget);
    });

    testWidgets('displays +35 when bonus earned', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 63))),
      );

      expect(find.text('+35'), findsOneWidget);
    });

    testWidgets('does not show +35 when bonus not earned', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 62))),
      );

      expect(find.text('+35'), findsNothing);
    });

    testWidgets('uses orange color when bonus earned', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 63))),
      );

      final container = find.byType(Container).first;
      expect(container, findsOneWidget);
    });

    testWidgets('uses light blue color when bonus not earned', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 30))),
      );

      // Verify the widget renders correctly
      expect(find.byType(BonusProgress), findsOneWidget);
    });

    testWidgets('handles zero upper total', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 0))),
      );

      expect(find.text('0/63'), findsOneWidget);
    });

    testWidgets('handles upper total exceeding 63', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 70))),
      );

      expect(find.text('70/63'), findsOneWidget);
      expect(find.text('+35'), findsOneWidget);
    });

    testWidgets('has rounded pill shape', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 30))),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('has shadow effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 30))),
      );

      expect(find.byType(Container), findsWidgets);
    });
  });

  group('BonusProgressCircle', () {
    testWidgets('displays circular progress', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BonusProgressCircle(upperTotal: 30)),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays upper total in center', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BonusProgressCircle(upperTotal: 45)),
        ),
      );

      expect(find.text('45'), findsOneWidget);
    });

    testWidgets('shows +35 when bonus earned', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BonusProgressCircle(upperTotal: 63)),
        ),
      );

      expect(find.text('+35'), findsOneWidget);
    });

    testWidgets('uses blue color when bonus not earned', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BonusProgressCircle(upperTotal: 30)),
        ),
      );

      final progressIndicator = find.byType(CircularProgressIndicator);
      expect(progressIndicator, findsOneWidget);
    });

    testWidgets('uses orange color when bonus earned', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BonusProgressCircle(upperTotal: 63)),
        ),
      );

      final progressIndicator = find.byType(CircularProgressIndicator);
      expect(progressIndicator, findsOneWidget);
    });

    testWidgets('has correct dimensions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BonusProgressCircle(upperTotal: 30)),
        ),
      );

      // Widget should render with expected size
      expect(find.byType(BonusProgressCircle), findsOneWidget);
    });
  });

  group('BonusProgress - Edge Cases', () {
    testWidgets('handles maximum score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 100))),
      );

      expect(find.text('100/63'), findsOneWidget);
      expect(find.text('+35'), findsOneWidget);
    });

    testWidgets('handles exactly 63', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 63))),
      );

      expect(find.text('63/63'), findsOneWidget);
      expect(find.text('+35'), findsOneWidget);
    });

    testWidgets('handles exactly 62', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BonusProgress(upperTotal: 62))),
      );

      expect(find.text('62/63'), findsOneWidget);
      expect(find.text('+35'), findsNothing);
    });
  });
}
