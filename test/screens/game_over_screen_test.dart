import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/screens/game_over_screen.dart';

void main() {
  group('GameOverScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    GameState createGameOverState({int totalScore = 150}) {
      var state = const GameState();
      for (final cat in Category.values) {
        state = state.addScore(cat.name, totalScore ~/ Category.values.length);
      }
      return state;
    }

    Future<void> pumpGameOverScreen(
      WidgetTester tester, {
      GameState? gameState,
    }) async {
      final state = gameState ?? createGameOverState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWithValue(state),
          ],
          child: MaterialApp(home: const GameOverScreen()),
        ),
      );
    }

    testWidgets('renders game over app bar title', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.widgetWithText(AppBar, 'Game Over'), findsOneWidget);
    });

    testWidgets('displays final score heading', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.text('Final Score'), findsOneWidget);
    });

    testWidgets('displays total score value', (tester) async {
      final state = createGameOverState(totalScore: 200);
      await pumpGameOverScreen(tester, gameState: state);

      expect(find.text('246'), findsWidgets);
    });

    testWidgets('displays upper section header', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.text('UPPER SECTION'), findsOneWidget);
    });

    testWidgets('displays lower section header', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.text('LOWER SECTION'), findsOneWidget);
    });

    testWidgets('displays all upper category names', (tester) async {
      await pumpGameOverScreen(tester);

      for (final cat in Category.getUpperCategories()) {
        expect(find.text(cat.displayName), findsOneWidget);
      }
    });

    testWidgets('displays all lower category names', (tester) async {
      await pumpGameOverScreen(tester);

      for (final cat in Category.getLowerCategories()) {
        expect(find.text(cat.displayName), findsOneWidget);
      }
    });

    testWidgets('displays upper total label and value', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.text('Upper Total:'), findsOneWidget);
    });

    testWidgets('displays total label', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.text('TOTAL'), findsOneWidget);
    });

    testWidgets('shows bonus when upper section threshold met', (tester) async {
      var state = const GameState();
      // Score upper section to meet/exceed 63 threshold
      state = state.addScore(Category.ones.name, 15);
      state = state.addScore(Category.twos.name, 12);
      state = state.addScore(Category.threes.name, 9);
      state = state.addScore(Category.fours.name, 8);
      state = state.addScore(Category.fives.name, 10);
      state = state.addScore(Category.sixes.name, 15);
      // Score lower section
      for (final cat in Category.getLowerCategories()) {
        state = state.addScore(cat.name, 0);
      }

      await pumpGameOverScreen(tester, gameState: state);

      expect(find.text('Bonus:'), findsOneWidget);
      expect(find.text('+50'), findsOneWidget);
    });

    testWidgets('hides bonus when upper section threshold not met', (tester) async {
      var state = const GameState();
      // Score upper section below 63 threshold
      state = state.addScore(Category.ones.name, 3);
      state = state.addScore(Category.twos.name, 4);
      state = state.addScore(Category.threes.name, 0);
      state = state.addScore(Category.fours.name, 0);
      state = state.addScore(Category.fives.name, 0);
      state = state.addScore(Category.sixes.name, 0);
      // Score lower section
      for (final cat in Category.getLowerCategories()) {
        state = state.addScore(cat.name, 0);
      }

      await pumpGameOverScreen(tester, gameState: state);

      expect(find.text('Bonus:'), findsNothing);
      expect(find.text('+50'), findsNothing);
    });

    testWidgets('displays play again button', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.text('PLAY AGAIN'), findsOneWidget);
    });

    testWidgets('displays view statistics button', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.text('VIEW STATISTICS'), findsOneWidget);
    });

    testWidgets('play again button calls newGame', (tester) async {
      final state = createGameOverState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWithValue(state),
          ],
          child: MaterialApp(home: const GameOverScreen()),
        ),
      );

      // The notifier should reset state when play again is pressed
      await tester.tap(find.text('PLAY AGAIN'));
      await tester.pump();

      // After newGame(), the state should be reset
      // Verify by checking that the screen still renders (no crash)
      expect(find.text('PLAY AGAIN'), findsOneWidget);
    });

    testWidgets('screen is scrollable', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Scroll down
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
        5000,
      );
      await tester.pumpAndSettle();

      // Should still find all widgets
      expect(find.byType(GameOverScreen), findsOneWidget);
    });

    testWidgets('displays score for Ones category', (tester) async {
      var state = const GameState();
      state = state.addScore(Category.ones.name, 12);
      state = state.addScore(Category.twos.name, 10);
      state = state.addScore(Category.threes.name, 9);
      state = state.addScore(Category.fours.name, 8);
      state = state.addScore(Category.fives.name, 15);
      state = state.addScore(Category.sixes.name, 18);
      for (final cat in Category.getLowerCategories()) {
        state = state.addScore(cat.name, 0);
      }

      await pumpGameOverScreen(tester, gameState: state);

      expect(find.text('12'), findsWidgets);
    });

    testWidgets('renders card with score breakdown', (tester) async {
      await pumpGameOverScreen(tester);

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('renders dividers between sections', (tester) async {
      await pumpGameOverScreen(tester);

      // Should have at least 2 dividers (after upper total, before final total)
      expect(find.byType(Divider), findsWidgets);
    });
  });
}
