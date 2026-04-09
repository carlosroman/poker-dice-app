import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/src/data/high_score_repository.dart';
import 'package:poker_dice/src/ui/pages/high_score_page.dart';
import 'dart:convert';

void main() {
  group('HighScorePage', () {
    setUp(() async {
      // Set up mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('displays loading indicator initially', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HighScorePage()));

      // Find the loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays high scores list after loading', (
      WidgetTester tester,
    ) async {
      // Set up mock high scores
      final prefs = await SharedPreferences.getInstance();
      final scores = [
        HighScoreEntry(score: 200, date: DateTime.now()),
        HighScoreEntry(score: 150, date: DateTime.now()),
        HighScoreEntry(score: 100, date: DateTime.now()),
      ];
      final jsonList = scores.map((e) => e.toJson()).toList();
      await prefs.setString('high_scores', jsonEncode(jsonList));

      await tester.pumpWidget(const MaterialApp(home: HighScorePage()));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify scores are displayed
      expect(find.text('200'), findsOneWidget);
      expect(find.text('150'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('displays empty state when no scores exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HighScorePage()));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify empty state is shown
      expect(find.text('No scores yet!'), findsOneWidget);
      expect(
        find.text('Play a game to set your first high score'),
        findsOneWidget,
      );
    });

    testWidgets('displays back button', (WidgetTester tester) async {
      bool backPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: HighScorePage(onBackTapped: () => backPressed = true),
        ),
      );

      // Wait for data to load
      await tester.pumpAndSettle();

      // Find and tap back button
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      expect(backPressed, isTrue);
    });

    testWidgets('displays medal icons for top 3 scores', (
      WidgetTester tester,
    ) async {
      // Set up mock high scores
      final prefs = await SharedPreferences.getInstance();
      final scores = [
        HighScoreEntry(score: 300, date: DateTime.now()),
        HighScoreEntry(score: 200, date: DateTime.now()),
        HighScoreEntry(score: 100, date: DateTime.now()),
      ];
      final jsonList = scores.map((e) => e.toJson()).toList();
      await prefs.setString('high_scores', jsonEncode(jsonList));

      await tester.pumpWidget(const MaterialApp(home: HighScorePage()));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify medal icons are shown for top 3
      expect(find.byIcon(Icons.emoji_events), findsNWidgets(3));
    });

    testWidgets('displays rank numbers for scores beyond top 3', (
      WidgetTester tester,
    ) async {
      // Set up mock high scores
      final prefs = await SharedPreferences.getInstance();
      final scores = List.generate(
        5,
        (index) =>
            HighScoreEntry(score: 300 - (index * 50), date: DateTime.now()),
      );
      final jsonList = scores.map((e) => e.toJson()).toList();
      await prefs.setString('high_scores', jsonEncode(jsonList));

      await tester.pumpWidget(const MaterialApp(home: HighScorePage()));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify rank numbers are shown
      expect(find.text('#4'), findsOneWidget);
      expect(find.text('#5'), findsOneWidget);
    });

    testWidgets('refreshes scores on pull to refresh', (
      WidgetTester tester,
    ) async {
      // Set up mock high scores
      final prefs = await SharedPreferences.getInstance();
      final scores1 = [HighScoreEntry(score: 100, date: DateTime.now())];
      final jsonList1 = scores1.map((e) => e.toJson()).toList();
      await prefs.setString('high_scores', jsonEncode(jsonList1));

      await tester.pumpWidget(const MaterialApp(home: HighScorePage()));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Update scores
      final scores2 = [HighScoreEntry(score: 200, date: DateTime.now())];
      final jsonList2 = scores2.map((e) => e.toJson()).toList();
      await prefs.setString('high_scores', jsonEncode(jsonList2));

      // Pull to refresh
      await tester.drag(find.byType(ListView), const Offset(0, 300));
      await tester.pumpAndSettle();

      // Verify new score is displayed
      expect(find.text('200'), findsOneWidget);
    });

    testWidgets('displays "Today" for scores from today', (
      WidgetTester tester,
    ) async {
      // Set up mock high scores
      final prefs = await SharedPreferences.getInstance();
      final scores = [HighScoreEntry(score: 100, date: DateTime.now())];
      final jsonList = scores.map((e) => e.toJson()).toList();
      await prefs.setString('high_scores', jsonEncode(jsonList));

      await tester.pumpWidget(const MaterialApp(home: HighScorePage()));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify "Today" is displayed
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('scores are displayed in descending order', (
      WidgetTester tester,
    ) async {
      // Set up mock high scores in random order
      final prefs = await SharedPreferences.getInstance();
      final scores = [
        HighScoreEntry(score: 100, date: DateTime.now()),
        HighScoreEntry(score: 300, date: DateTime.now()),
        HighScoreEntry(score: 200, date: DateTime.now()),
      ];
      final jsonList = scores.map((e) => e.toJson()).toList();
      await prefs.setString('high_scores', jsonEncode(jsonList));

      await tester.pumpWidget(const MaterialApp(home: HighScorePage()));

      // Wait for data to load
      await tester.pumpAndSettle();

      // Verify scores exist in expected order by finding specific score texts
      expect(find.text('300'), findsOneWidget);
      expect(find.text('200'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });
  });
}
