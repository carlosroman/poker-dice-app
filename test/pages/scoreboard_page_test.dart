import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/game_history.dart';
import 'package:poker_dice/pages/scoreboard_page.dart';

void main() {
  group('ScoreboardPage', () {
    Widget buildScoreboard({
      List<GameResult>? gameResults,
      int gamesPlayed = 0,
      int? highScore,
      VoidCallback? onClearHistory,
      VoidCallback? onBackTap,
    }) {
      return MaterialApp(
        home: ScoreboardPage(
          gameResults: gameResults ?? [],
          gamesPlayed: gamesPlayed,
          highScore: highScore,
          onClearHistory: onClearHistory,
          onBackTap: onBackTap,
        ),
      );
    }

    testWidgets('renders empty state when no games', (tester) async {
      await tester.pumpWidget(buildScoreboard());

      expect(find.text('No games played yet'), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildScoreboard());

      expect(find.text('Scoreboard'), findsOneWidget);
    });

    testWidgets('shows back button when onBackTap is provided', (tester) async {
      await tester.pumpWidget(buildScoreboard(onBackTap: () {}));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('hides back button when onBackTap is null', (tester) async {
      await tester.pumpWidget(buildScoreboard());

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('calls onBackTap when back button is tapped', (tester) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildScoreboard(onBackTap: () => callbackCalled = true),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets(
      'shows clear button when games exist and onClearHistory provided',
      (tester) async {
        final results = [
          GameResult(
            totalScore: 250,
            upperSectionTotal: 70,
            bonus: 35,
            completedAt: DateTime(2024, 1, 15),
          ),
        ];
        await tester.pumpWidget(
          buildScoreboard(gameResults: results, onClearHistory: () {}),
        );

        expect(find.byIcon(Icons.delete_sweep), findsOneWidget);
      },
    );

    testWidgets('hides clear button when no games', (tester) async {
      await tester.pumpWidget(buildScoreboard(onClearHistory: () {}));

      expect(find.byIcon(Icons.delete_sweep), findsNothing);
    });

    testWidgets('hides clear button when onClearHistory is null', (
      tester,
    ) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      await tester.pumpWidget(buildScoreboard(gameResults: results));

      expect(find.byIcon(Icons.delete_sweep), findsNothing);
    });

    testWidgets('calls onClearHistory when clear button is tapped', (
      tester,
    ) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildScoreboard(
          gameResults: results,
          onClearHistory: () => callbackCalled = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_sweep));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('shows stats when games exist', (tester) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      await tester.pumpWidget(
        buildScoreboard(gameResults: results, gamesPlayed: 5, highScore: 300),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('Games Played'), findsOneWidget);
      expect(find.text('300'), findsOneWidget);
      expect(find.text('High Score'), findsOneWidget);
    });

    testWidgets('shows dash for high score when null', (tester) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      await tester.pumpWidget(
        buildScoreboard(gameResults: results, gamesPlayed: 1),
      );

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('displays game results in list', (tester) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
        GameResult(
          totalScore: 300,
          upperSectionTotal: 80,
          bonus: 40,
          completedAt: DateTime(2024, 2, 20),
        ),
      ];
      await tester.pumpWidget(buildScoreboard(gameResults: results));

      expect(find.text('Score: 300'), findsOneWidget);
      expect(find.text('Score: 250'), findsOneWidget);
    });

    testWidgets('displays game results in reverse chronological order', (
      tester,
    ) async {
      final results = [
        GameResult(
          totalScore: 200,
          upperSectionTotal: 60,
          bonus: 0,
          completedAt: DateTime(2024, 1, 1),
        ),
        GameResult(
          totalScore: 300,
          upperSectionTotal: 80,
          bonus: 40,
          completedAt: DateTime(2024, 2, 20),
        ),
      ];
      await tester.pumpWidget(buildScoreboard(gameResults: results));

      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
    });

    testWidgets('displays game details', (tester) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      await tester.pumpWidget(buildScoreboard(gameResults: results));

      expect(find.text('Upper: 70 | Bonus: 35'), findsOneWidget);
      expect(find.text('15/1/2024'), findsOneWidget);
    });
  });
}
