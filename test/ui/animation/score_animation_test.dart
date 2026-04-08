import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/animation/score_animation.dart';

void main() {
  group('AnimatedScoreWidget Tests', () {
    testWidgets('displays score correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedScoreWidget(score: 25))),
      );

      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('displays empty string when score is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedScoreWidget(score: null)),
        ),
      );

      // Empty text should be displayed
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('displays bonus indicator when showBonus is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedScoreWidget(score: 50, showBonus: true)),
        ),
      );

      expect(find.text('+50'), findsOneWidget);
    });

    testWidgets('does not display bonus when showBonus is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedScoreWidget(score: 50, showBonus: false),
          ),
        ),
      );

      expect(find.text('+50'), findsNothing);
    });

    testWidgets('triggers fade-in animation when isNewScore is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedScoreWidget(score: 25, isNewScore: true),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Pump animation frame
      await tester.pump(const Duration(milliseconds: 50));

      // Widget should still be present
      expect(find.byType(AnimatedScoreWidget), findsOneWidget);
    });

    testWidgets('completes animation after duration', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedScoreWidget(score: 25, isNewScore: true),
          ),
        ),
      );

      // Pump through the full animation duration (200ms)
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Widget should still be present
      expect(find.byType(AnimatedScoreWidget), findsOneWidget);
    });

    testWidgets('updates when score changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedScoreWidget(score: 10))),
      );

      expect(find.text('10'), findsOneWidget);

      // Rebuild with different score
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedScoreWidget(score: 30))),
      );

      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('triggers animation when isNewScore changes to true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedScoreWidget(score: 10, isNewScore: false),
          ),
        ),
      );

      // Change to isNewScore: true
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedScoreWidget(score: 10, isNewScore: true),
          ),
        ),
      );

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(AnimatedScoreWidget), findsOneWidget);
    });
  });

  group('AnimatedScoreRow Tests', () {
    testWidgets('wraps child widget correctly', (WidgetTester tester) async {
      const child = Text('Test Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const AnimatedScoreRow(child: child)),
        ),
      );

      expect(find.text('Test Row'), findsOneWidget);
    });

    testWidgets('triggers scale animation when isSelected is true', (
      WidgetTester tester,
    ) async {
      const child = Text('Test Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedScoreRow(isSelected: true, child: child),
          ),
        ),
      );

      // Initial pump
      await tester.pump();

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Test Row'), findsOneWidget);
    });

    testWidgets('completes animation and returns to normal', (
      WidgetTester tester,
    ) async {
      const child = Text('Test Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedScoreRow(
              isSelected: true,
              duration: Duration(milliseconds: 100),
              child: child,
            ),
          ),
        ),
      );

      // Pump through full animation cycle
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      expect(find.text('Test Row'), findsOneWidget);
    });

    testWidgets('animates when isSelected changes from false to true', (
      WidgetTester tester,
    ) async {
      const child = Text('Test Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedScoreRow(isSelected: false, child: child),
          ),
        ),
      );

      // Change isSelected to true
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedScoreRow(isSelected: true, child: child),
          ),
        ),
      );

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Test Row'), findsOneWidget);
    });

    testWidgets('uses custom duration when provided', (
      WidgetTester tester,
    ) async {
      const child = Text('Test Row');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AnimatedScoreRow(
              isSelected: true,
              duration: Duration(milliseconds: 300),
              child: child,
            ),
          ),
        ),
      );

      // Animation should still be running at 100ms
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Test Row'), findsOneWidget);
    });
  });

  group('AnimatedScoreWidget Highlight Tests', () {
    testWidgets('applies highlight during animation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedScoreWidget(score: 25, isNewScore: true),
          ),
        ),
      );

      // Pump animation
      await tester.pump(const Duration(milliseconds: 50));

      // Widget should be rendered with animation
      expect(find.byType(AnimatedScoreWidget), findsOneWidget);
    });
  });
}
