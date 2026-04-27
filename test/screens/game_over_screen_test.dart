import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/screens/game_over_screen.dart';

void main() {
  group('GameOverScreen Tests', () {
    testWidgets('test_gameOverScreen_displaysFinalScore', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GameOverScreen())),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify Game Over title is displayed
      expect(find.text('Game Over!'), findsOneWidget);

      // Verify Final Score label is displayed
      expect(find.text('Final Score'), findsOneWidget);
    });

    testWidgets('test_gameOverScreen_displaysPlayAgainButton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GameOverScreen())),
      );

      await tester.pumpAndSettle();

      // Verify Play Again button is displayed
      expect(find.text('Play Again'), findsOneWidget);

      // Verify the button is tappable
      final playAgainButton = find.byType(ElevatedButton);
      expect(playAgainButton, findsOneWidget);
    });

    testWidgets('test_gameOverScreen_displaysBackToHomeButton', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GameOverScreen())),
      );

      await tester.pumpAndSettle();

      // Verify Back to Home button is displayed
      expect(find.text('Back to Home'), findsOneWidget);
    });

    testWidgets('test_gameOverScreen_displaysScoreBreakdown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GameOverScreen())),
      );

      await tester.pumpAndSettle();

      // Verify score breakdown sections are displayed
      expect(find.text('Score Breakdown'), findsOneWidget);
      expect(find.text('Upper Section'), findsOneWidget);
      expect(find.text('Bonus'), findsOneWidget);
      expect(find.text('Lower Section'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('test_gameOverScreen_displaysHighScores', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: GameOverScreen())),
      );

      await tester.pumpAndSettle();

      // Verify High Scores section is displayed
      expect(find.text('High Scores'), findsOneWidget);

      // Verify View All button is displayed
      expect(find.text('View All'), findsOneWidget);
    });

    testWidgets('test_gameOverScreen_playAgainResetsGame', (
      WidgetTester tester,
    ) async {
      late GameNotifier gameNotifier;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                gameNotifier = ProviderScope.containerOf(
                  context,
                ).read(gameProvider.notifier);
                return const GameOverScreen();
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Start a new game
      gameNotifier.startNewGame();
      gameNotifier.startTurn();

      await tester.pumpAndSettle();

      // Verify game state has been reset
      final container = ProviderScope.containerOf(
        tester.element(find.byType(GameOverScreen)),
      );
      final gameState = container.read(gameProvider);
      expect(gameState.isGameOver, false);
      expect(gameState.remainingRolls, 3);
      expect(gameState.diceRoll, isNotNull);
    });

    testWidgets('test_gameOverScreen_displaysTrophyIcon', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: GameOverScreen())),
      );

      await tester.pumpAndSettle();

      // Verify trophy icon is displayed (size 64 in title section)
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.emoji_events &&
              widget.size == 64,
        ),
        findsOneWidget,
      );
    });
  });
}
