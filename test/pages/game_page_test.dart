import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/providers/theme_provider.dart';
import 'package:poker_dice/pages/game_page.dart';
import 'package:poker_dice/widgets/dice_widget.dart';
import 'package:poker_dice/widgets/roll_button.dart';
import 'package:poker_dice/widgets/score_sheet.dart';

void main() {
  group('GamePage', () {
    GameState buildGameState({
      List<Dice>? dice,
      int rollsRemaining = 3,
      Map<ScoreCategory, int?>? scoredCategories,
      GameStatus status = GameStatus.active,
    }) {
      return GameState(
        currentDice: dice,
        rollsRemaining: rollsRemaining,
        scoredCategories: scoredCategories,
        status: status,
      );
    }

    Widget buildGamePage({GameState? gameState, VoidCallback? onBackTap}) {
      return ProviderScope(
        overrides: [
          gameProvider.overrideWith(
            (ref) => GameNotifier(initialState: gameState ?? GameState()),
          ),
        ],
        child: MaterialApp(
          theme: ThemeNotifier.lightTheme,
          darkTheme: ThemeNotifier.darkTheme,
          home: GamePage(onBackTap: onBackTap),
        ),
      );
    }

    testWidgets('renders all major components', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byType(ScoreSheet), findsOneWidget);
      expect(find.byType(DiceWidget), findsNWidgets(5));
      expect(find.byType(RollButton), findsOneWidget);
    });

    testWidgets('displays total score in app bar', (tester) async {
      final state = buildGameState(scoredCategories: {ScoreCategory.aces: 150});
      await tester.pumpWidget(buildGamePage(gameState: state));

      expect(find.text('150'), findsOneWidget);
    });

    testWidgets('displays player label "You"', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('shows back button when onBackTap is provided', (tester) async {
      await tester.pumpWidget(buildGamePage(onBackTap: () {}));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('hides back button when onBackTap is null', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byIcon(Icons.arrow_back), findsNothing);
    });

    testWidgets('calls onBackTap when back button is tapped', (tester) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildGamePage(onBackTap: () => callbackCalled = true),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('menu button is always visible', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('displays five dice', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byType(DiceWidget), findsNWidgets(5));
    });

    testWidgets('roll button shows correct rolls remaining', (tester) async {
      final state = buildGameState(rollsRemaining: 2);
      await tester.pumpWidget(buildGamePage(gameState: state));

      final rollButton = tester.widget<RollButton>(find.byType(RollButton));
      expect(rollButton.rollsRemaining, 2);
    });

    testWidgets('roll button disabled when rolls remaining is 0', (
      tester,
    ) async {
      final state = buildGameState(rollsRemaining: 0);
      await tester.pumpWidget(buildGamePage(gameState: state));

      final button = tester.widget<RollButton>(find.byType(RollButton));
      expect(button.rollsRemaining, 0);
    });

    testWidgets('passes scoredCategories to ScoreSheet', (tester) async {
      final state = buildGameState(
        scoredCategories: {ScoreCategory.aces: 5, ScoreCategory.twos: 4},
      );
      await tester.pumpWidget(buildGamePage(gameState: state));

      expect(find.byType(ScoreSheet), findsOneWidget);
    });

    testWidgets('passes upperTotal and bonus to ScoreSheet', (tester) async {
      final state = buildGameState(scoredCategories: {ScoreCategory.aces: 70});
      await tester.pumpWidget(buildGamePage(gameState: state));

      expect(find.byType(ScoreSheet), findsOneWidget);
    });

    testWidgets('uses default values when state is initial', (tester) async {
      await tester.pumpWidget(buildGamePage());

      final rollButton = tester.widget<RollButton>(find.byType(RollButton));
      expect(rollButton.rollsRemaining, 3);
    });

    testWidgets('dice are centered horizontally', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets('roll button has full width', (tester) async {
      await tester.pumpWidget(buildGamePage());

      expect(find.byType(RollButton), findsOneWidget);
    });

    testWidgets('shows dice with correct values', (tester) async {
      final testDice = List.generate(
        5,
        (i) => Dice(value: i + 1, isHeld: false),
      );
      final state = buildGameState(dice: testDice);
      await tester.pumpWidget(buildGamePage(gameState: state));

      expect(find.byType(DiceWidget), findsNWidgets(5));
    });

    testWidgets('respects held dice state', (tester) async {
      final testDice = [
        Dice(value: 1, isHeld: true),
        Dice(value: 2, isHeld: false),
        Dice(value: 3, isHeld: true),
        Dice(value: 4, isHeld: false),
        Dice(value: 5, isHeld: false),
      ];
      final state = buildGameState(dice: testDice);
      await tester.pumpWidget(buildGamePage(gameState: state));

      expect(find.byType(DiceWidget), findsNWidgets(5));
    });

    testWidgets('shows theme toggle button in app bar', (tester) async {
      await tester.pumpWidget(buildGamePage());

      // Theme toggle uses dark_mode icon in light theme
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('shows dark mode icon in light theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameProvider.overrideWith((ref) => GameNotifier())],
          child: MaterialApp(
            theme: ThemeNotifier.lightTheme,
            home: const GamePage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('shows light mode icon in dark theme', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameProvider.overrideWith((ref) => GameNotifier())],
          child: MaterialApp(
            theme: ThemeNotifier.darkTheme,
            home: const GamePage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.light_mode), findsOneWidget);
    });

    testWidgets('tapping theme toggle calls toggleTheme', (tester) async {
      final themeNotifier = ThemeNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameProvider.overrideWith((ref) => GameNotifier()),
            themeProvider.overrideWith((ref) => themeNotifier),
          ],
          child: MaterialApp(
            theme: ThemeNotifier.lightTheme,
            darkTheme: ThemeNotifier.darkTheme,
            themeMode: themeNotifier.state,
            home: const GamePage(),
          ),
        ),
      );

      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pumpAndSettle();

      // Theme should have toggled to dark
      expect(themeNotifier.state, ThemeMode.dark);
    });

    testWidgets('shows completion overlay when game is completed', (
      tester,
    ) async {
      final completedState = buildGameState(
        status: GameStatus.completed,
        scoredCategories: {for (final c in ScoreCategory.values) c: 0},
      );
      await tester.pumpWidget(buildGamePage(gameState: completedState));

      expect(find.text('Game Complete!'), findsOneWidget);
      expect(find.text('Final Score'), findsOneWidget);
      expect(find.text('New Game'), findsOneWidget);
    });

    testWidgets('completion overlay shows total score', (tester) async {
      final total = 250;
      final completedState = buildGameState(
        status: GameStatus.completed,
        scoredCategories: {
          for (final c in ScoreCategory.values) c: total ~/ 13,
        },
      );
      await tester.pumpWidget(buildGamePage(gameState: completedState));

      expect(find.text('Game Complete!'), findsOneWidget);
    });

    testWidgets('New Game button resets the game', (tester) async {
      final completedState = buildGameState(
        status: GameStatus.completed,
        scoredCategories: {for (final c in ScoreCategory.values) c: 0},
      );

      final notifier = GameNotifier(initialState: completedState);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(
            theme: ThemeNotifier.lightTheme,
            home: const GamePage(),
          ),
        ),
      );

      expect(find.text('Game Complete!'), findsOneWidget);

      // Tap the New Game button
      await tester.tap(find.text('New Game'));
      await tester.pumpAndSettle();

      // Game should be reset - overlay should be gone
      expect(find.text('Game Complete!'), findsNothing);
      expect(notifier.state.status, GameStatus.active);
    });

    testWidgets('no completion overlay when game is active', (tester) async {
      final activeState = buildGameState(status: GameStatus.active);
      await tester.pumpWidget(buildGamePage(gameState: activeState));

      expect(find.text('Game Complete!'), findsNothing);
    });
  });
}
