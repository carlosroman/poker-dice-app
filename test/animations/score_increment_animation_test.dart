import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/animations/score_increment_animation.dart';

Widget _buildAnimatedScoreWidget({
  required int score,
  int previousScore = 0,
  TextStyle? textStyle,
}) {
  return MaterialApp(
    home: Material(
      child: AnimatedScoreWidget(
        score: score,
        previousScore: previousScore,
        textStyle: textStyle,
      ),
    ),
  );
}

Widget _buildScoreIncrementAnimation({
  required int from,
  required int to,
  Duration duration = const Duration(milliseconds: 500),
  TextStyle? textStyle,
  VoidCallback? onComplete,
}) {
  return MaterialApp(
    home: Material(
      child: ScoreIncrementAnimation(
        from: from,
        to: to,
        duration: duration,
        textStyle: textStyle,
        onComplete: onComplete,
      ),
    ),
  );
}

void main() {
  group('AnimatedScoreWidget', () {
    testWidgets('renders score text', (tester) async {
      await tester.pumpWidget(_buildAnimatedScoreWidget(score: 42));

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('uses previousScore default of 0', (tester) async {
      await tester.pumpWidget(_buildAnimatedScoreWidget(score: 10));

      expect(find.text('10'), findsOneWidget);
    });

    testWidgets('triggers animation when score changes', (tester) async {
      await tester.pumpWidget(
        _buildAnimatedScoreWidget(score: 10, previousScore: 0),
      );

      // Change score
      await tester.pumpWidget(
        _buildAnimatedScoreWidget(score: 20, previousScore: 10),
      );

      // Animation should start
      await tester.pump();
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('completes animation within expected duration', (tester) async {
      await tester.pumpWidget(
        _buildAnimatedScoreWidget(score: 10, previousScore: 0),
      );

      // Change score
      await tester.pumpWidget(
        _buildAnimatedScoreWidget(score: 30, previousScore: 10),
      );

      await tester.pump();

      // Advance past full animation duration
      await tester.pump(AnimatedScoreWidget.duration);

      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('restarts animation on multiple score changes', (tester) async {
      await tester.pumpWidget(
        _buildAnimatedScoreWidget(score: 0, previousScore: 0),
      );

      // First change
      await tester.pumpWidget(
        _buildAnimatedScoreWidget(score: 10, previousScore: 0),
      );
      await tester.pump();
      await tester.pump(AnimatedScoreWidget.duration);

      // Second change
      await tester.pumpWidget(
        _buildAnimatedScoreWidget(score: 20, previousScore: 10),
      );
      await tester.pump();
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('applies custom text style', (tester) async {
      const customStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);

      await tester.pumpWidget(
        _buildAnimatedScoreWidget(score: 42, textStyle: customStyle),
      );

      final textWidget = tester.widget<Text>(find.text('42'));
      expect(textWidget.style?.fontSize, equals(24));
      expect(textWidget.style?.fontWeight, equals(FontWeight.bold));
    });
  });

  group('ScoreIncrementAnimation', () {
    testWidgets('renders final score value', (tester) async {
      await tester.pumpWidget(_buildScoreIncrementAnimation(from: 0, to: 100));

      // Initial frame shows starting value
      await tester.pump();
      expect(find.text('0'), findsOneWidget);

      // Complete animation
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('animates from to to value', (tester) async {
      await tester.pumpWidget(_buildScoreIncrementAnimation(from: 10, to: 20));

      await tester.pump();
      expect(find.text('10'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('calls onComplete when animation finishes', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        _buildScoreIncrementAnimation(
          from: 0,
          to: 50,
          onComplete: () {
            completed = true;
          },
        ),
      );

      expect(completed, isFalse);

      await tester.pumpAndSettle();
      expect(completed, isTrue);
    });

    testWidgets('uses custom duration', (tester) async {
      await tester.pumpWidget(
        _buildScoreIncrementAnimation(
          from: 0,
          to: 100,
          duration: const Duration(milliseconds: 1000),
        ),
      );

      await tester.pump();
      expect(find.text('0'), findsOneWidget);

      // Halfway through custom duration
      await tester.pump(const Duration(milliseconds: 500));
      // Value should be somewhere between 0 and 100
      expect(find.byType(Text), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('applies custom text style', (tester) async {
      const customStyle = TextStyle(fontSize: 32, color: Colors.green);

      await tester.pumpWidget(
        _buildScoreIncrementAnimation(from: 0, to: 50, textStyle: customStyle),
      );

      await tester.pump();
      final textWidget = tester.widget<Text>(find.byType(Text));
      expect(textWidget.style?.fontSize, equals(32));
      expect(textWidget.style?.color, equals(Colors.green));
    });

    testWidgets('handles same from and to values', (tester) async {
      await tester.pumpWidget(_buildScoreIncrementAnimation(from: 42, to: 42));

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('handles negative scores', (tester) async {
      await tester.pumpWidget(_buildScoreIncrementAnimation(from: 0, to: -10));

      await tester.pump();
      expect(find.text('0'), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.text('-10'), findsOneWidget);
    });
  });

  group('Animation constants', () {
    test('AnimatedScoreWidget duration is 300ms', () {
      expect(AnimatedScoreWidget.duration.inMilliseconds, equals(300));
    });
  });
}
