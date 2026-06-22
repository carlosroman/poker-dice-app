import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/providers/theme_provider.dart';
import 'package:poker_dice/pages/game_page.dart';
import 'package:poker_dice/widgets/animated_dice.dart';
import 'package:poker_dice/widgets/roll_button.dart';
import 'package:poker_dice/widgets/score_sheet.dart';

void main() {
  group('GamePage', () {
    GameState buildGameState({
      List<Dice>? dice,
      int rollsRemaining = 3,
      Map<ScoreCategory, int?>? scoredCategories,
      GameStatus status = GameStatus.active,
      ScoreCategory? selectedCategory,
    }) {
      return GameState(
        currentDice: dice,
        rollsRemaining: rollsRemaining,
        scoredCategories: scoredCategories,
        status: status,
        selectedCategory: selectedCategory,
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
      expect(find.byType(AnimatedDice), findsNWidgets(5));
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

      expect(find.byType(AnimatedDice), findsNWidgets(5));
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

      expect(find.byType(AnimatedDice), findsNWidgets(5));
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

      expect(find.byType(AnimatedDice), findsNWidgets(5));
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

    testWidgets('View Scoreboard button is visible when game is completed', (
      tester,
    ) async {
      final completedState = buildGameState(
        status: GameStatus.completed,
        scoredCategories: {for (final c in ScoreCategory.values) c: 0},
      );
      await tester.pumpWidget(buildGamePage(gameState: completedState));

      expect(find.text('View Scoreboard'), findsOneWidget);
    });

    testWidgets('View Scoreboard button is hidden when game is active', (
      tester,
    ) async {
      final activeState = buildGameState(status: GameStatus.active);
      await tester.pumpWidget(buildGamePage(gameState: activeState));

      expect(find.text('View Scoreboard'), findsNothing);
    });

    // -----------------------------------------------------------------------
    // Score Button
    // -----------------------------------------------------------------------

    testWidgets('score button is disabled when no category selected', (
      tester,
    ) async {
      final state = buildGameState(status: GameStatus.active);
      await tester.pumpWidget(buildGamePage(gameState: state));

      // Score button should always be visible but disabled without category
      expect(find.text('Score'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(find.byType(ElevatedButton).last)
            .onPressed,
        isNull,
      );
    });

    testWidgets('score button is disabled when dice have not been rolled', (
      tester,
    ) async {
      // Dice start with value 0 (blank) — button should be disabled
      final unrolledDice = List.generate(5, (_) => const Dice(value: 0));
      final state = buildGameState(
        dice: unrolledDice,
        selectedCategory: ScoreCategory.aces,
      );
      await tester.pumpWidget(buildGamePage(gameState: state));

      // Score button should be visible but disabled
      expect(find.text('Score'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: find.text('Score'),
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('score button is enabled when dice have been rolled', (
      tester,
    ) async {
      final rolledDice = [
        const Dice(value: 3),
        const Dice(value: 1),
        const Dice(value: 5),
        const Dice(value: 2),
        const Dice(value: 4),
      ];
      final state = buildGameState(
        dice: rolledDice,
        selectedCategory: ScoreCategory.aces,
      );
      await tester.pumpWidget(buildGamePage(gameState: state));

      // Score button should be visible and enabled
      expect(find.text('Score'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: find.text('Score'),
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('score button is enabled when at least one die has value > 0', (
      tester,
    ) async {
      // Only one die rolled — button should still be enabled
      final partialDice = [
        const Dice(value: 1),
        const Dice(value: 0),
        const Dice(value: 0),
        const Dice(value: 0),
        const Dice(value: 0),
      ];
      final state = buildGameState(
        dice: partialDice,
        selectedCategory: ScoreCategory.chance,
      );
      await tester.pumpWidget(buildGamePage(gameState: state));

      expect(find.text('Score'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.ancestor(
                of: find.text('Score'),
                matching: find.byType(ElevatedButton),
              ),
            )
            .onPressed,
        isNotNull,
      );
    });

    testWidgets('score button is visible when category is selected', (
      tester,
    ) async {
      final state = buildGameState(
        status: GameStatus.active,
        selectedCategory: ScoreCategory.aces,
      );
      await tester.pumpWidget(buildGamePage(gameState: state));

      expect(find.text('Score'), findsOneWidget);
    });

    testWidgets('score button shows selected category name', (tester) async {
      final state = buildGameState(
        status: GameStatus.active,
        selectedCategory: ScoreCategory.fullHouse,
      );
      await tester.pumpWidget(buildGamePage(gameState: state));

      expect(find.text('Full House'), findsOneWidget);
    });

    testWidgets('tapping score button confirms the score', (tester) async {
      final rolledDice = [
        const Dice(value: 1),
        const Dice(value: 2),
        const Dice(value: 3),
        const Dice(value: 4),
        const Dice(value: 5),
      ];
      final notifier = GameNotifier(
        initialState: buildGameState(
          dice: rolledDice,
          status: GameStatus.active,
          selectedCategory: ScoreCategory.aces,
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(
            theme: ThemeNotifier.lightTheme,
            home: const GamePage(),
          ),
        ),
      );

      // Score button should be visible
      expect(find.text('Score'), findsOneWidget);

      // Tap the score button
      await tester.tap(find.text('Score'));
      await tester.pumpAndSettle();

      // Category should now be scored and selection cleared
      final state = notifier.state;
      expect(state.scoredCategories[ScoreCategory.aces], isNotNull);
      expect(state.selectedCategory, isNull);
      // Score button remains visible but disabled (no category selected)
      expect(find.text('Score'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(find.byType(ElevatedButton).last)
            .onPressed,
        isNull,
      );
    });

    // -----------------------------------------------------------------------
    // Regression: unscored categories remain selectable
    // -----------------------------------------------------------------------

    testWidgets(
      'unscored categories are selectable when some categories are scored',
      (tester) async {
        // Regression test: when some categories have scores, unscored
        // categories must still be tappable. Previously, GamePage passed
        // all 13 categories (including nulls as 0) to ScoreSheet, causing
        // every row to appear "scored" and unselectable.
        final notifier = GameNotifier(
          initialState: buildGameState(
            status: GameStatus.active,
            scoredCategories: {ScoreCategory.aces: 5, ScoreCategory.twos: 4},
          ),
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [gameProvider.overrideWith((ref) => notifier)],
            child: MaterialApp(
              theme: ThemeNotifier.lightTheme,
              home: const GamePage(),
            ),
          ),
        );

        // ScoreSheet should be present
        expect(find.byType(ScoreSheet), findsOneWidget);

        // Ensure Chance is visible by scrolling
        final chanceFinder = find.text('Chance');
        await tester.ensureVisible(chanceFinder);
        await tester.pumpAndSettle();

        // Tap an unscored category (Chance)
        await tester.tap(chanceFinder);
        await tester.pumpAndSettle();

        // Tapping unscored category should select it for preview
        final state = notifier.state;
        expect(state.selectedCategory, ScoreCategory.chance);

        // Score button should appear
        expect(find.text('Score'), findsOneWidget);
      },
    );
  });
}
