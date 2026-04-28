import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/animations/score_increment_animation.dart';

/// Simple TickerProvider for testing
class _TestTickerProvider implements TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return _TestTicker();
  }
}

class _TestTicker implements Ticker {
  @override
  bool get isActive => false;
  @override
  bool get isTicking => false;
  @override
  bool get scheduled => false;
  @override
  bool get shouldScheduleTick => false;
  @override
  bool muted = false;
  @override
  bool forceFrames = false;
  @override
  String? debugLabel;

  @override
  void dispose() {}

  @override
  TickerFuture start() {
    return TickerFuture.complete();
  }

  @override
  void stop({bool canceled = false}) {}

  @override
  void absorbTicker(Ticker originalTicker) {}

  @override
  DiagnosticsNode describeForError(String name) =>
      DiagnosticsNode.message('TestTicker');

  @override
  void scheduleTick({bool rescheduling = false}) {}

  @override
  void unscheduleTick() {}

  @override
  String toString({bool debugIncludeStack = false}) => 'TestTicker';
}

void main() {
  group('ScoreIncrementAnimation', () {
    test('scoreIncrementAnimation_animatesCorrectly', () {
      final animation = ScoreIncrementAnimation(vsync: _TestTickerProvider());

      expect(animation.currentScore, 0);
      expect(animation.targetScore, 0);

      animation.animateTo(42);

      expect(animation.targetScore, 42);

      animation.setCurrentScore(42);
      expect(animation.currentScore, 42);

      animation.dispose();
    });

    test('scoreIncrementAnimation_duration', () {
      const customScaleDuration = Duration(milliseconds: 500);

      final animation = ScoreIncrementAnimation(
        vsync: _TestTickerProvider(),
        scaleDuration: customScaleDuration,
      );

      expect(animation.scaleDuration, customScaleDuration);

      animation.dispose();
    });

    test('scoreIncrementAnimation_customFlashColor', () {
      const customColor = Color(0xFFFF5733);
      final animation = ScoreIncrementAnimation(
        vsync: _TestTickerProvider(),
        flashColor: customColor,
      );

      expect(animation, isNotNull);

      animation.dispose();
    });

    test('scoreIncrementAnimation_disposesCorrectly', () {
      final animation = ScoreIncrementAnimation(vsync: _TestTickerProvider());

      animation.animateTo(100);
      animation.dispose();

      expect(animation, isNotNull);
    });

    test('scoreIncrementAnimation_multipleAnimations', () {
      final animation = ScoreIncrementAnimation(vsync: _TestTickerProvider());

      animation.animateTo(10);
      animation.setCurrentScore(10);

      animation.animateTo(20);
      animation.setCurrentScore(20);

      expect(animation.targetScore, 20);

      animation.dispose();
    });
  });

  group('AnimatedScoreCounter', () {
    testWidgets('animatedScoreCounter_displaysScoreCorrectly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedScoreCounter(score: 42))),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('animatedScoreCounter_animatesOnScoreChange', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedScoreCounter(score: 10))),
      );

      expect(find.text('10'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedScoreCounter(score: 20))),
      );

      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('animatedScoreCounter_withCustomStyle', (
      WidgetTester tester,
    ) async {
      const customStyle = TextStyle(fontSize: 24, color: Colors.red);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedScoreCounter(score: 100, style: customStyle),
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('animatedScoreCounter_withoutScaleAnimation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedScoreCounter(score: 50, animateScale: false),
          ),
        ),
      );

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('animatedScoreCounter_withoutColorAnimation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedScoreCounter(score: 75, animateColor: false),
          ),
        ),
      );

      expect(find.text('75'), findsOneWidget);
    });

    testWidgets('animatedScoreCounter_withCustomFlashColor', (
      WidgetTester tester,
    ) async {
      const customColor = Color(0xFF2196F3);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedScoreCounter(score: 30, flashColor: customColor),
          ),
        ),
      );

      expect(find.text('30'), findsOneWidget);
    });

    testWidgets('animatedScoreCounter_zeroScore', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: AnimatedScoreCounter(score: 0))),
      );

      expect(find.text('0'), findsOneWidget);
    });
  });
}
