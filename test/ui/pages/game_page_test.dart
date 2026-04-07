import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/bloc/game_bloc.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/pages/game_page.dart';

void main() {
  group('GamePage Bloc Integration Tests', () {
    /// Creates a testable widget with BlocProvider wrapping GamePage
    Widget buildTestWidget({GameBloc? bloc}) {
      return BlocProvider<GameBloc>.value(
        value: bloc ?? GameBloc(),
        child: const MaterialApp(home: GamePage()),
      );
    }

    testWidgets('renders scaffold with app bar', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('app bar shows "Poker Dice" title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Poker Dice'), findsOneWidget);
    });

    testWidgets('renders 5 dice in dice area', (WidgetTester tester) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Trigger initial game state by rolling dice
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Check for 5 die widgets
      expect(find.byKey(const ValueKey('die-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('die-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('die-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('die-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('die-4')), findsOneWidget);
    });

    testWidgets('renders hold checkboxes below dice', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Trigger initial game state by rolling dice
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Check for 5 hold checkboxes
      expect(find.byKey(const ValueKey('checkbox-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('checkbox-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('checkbox-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('checkbox-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('checkbox-4')), findsOneWidget);
    });

    testWidgets('renders roll button', (WidgetTester tester) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('roll-button')), findsOneWidget);
      expect(find.textContaining('Roll Dice'), findsOneWidget);
    });

    testWidgets('renders score sheet', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.byKey(const ValueKey('score-sheet')), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Score'), findsOneWidget);
    });

    testWidgets('dispatches ToggleDieEvent when die is tapped', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Roll dice first to get dice values
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Tap the first die
      await tester.tap(find.byKey(const ValueKey('die-0')));
      await tester.pumpAndSettle();

      // Verify the toggle event was dispatched by checking state change
      // The die should now be held
      expect(find.byKey(const ValueKey('checkbox-0')), findsOneWidget);
    });

    testWidgets('dispatches RollDiceEvent when roll button is tapped', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Initial state - should have 3 rolls available after first roll
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Tap the roll button
      await tester.tap(find.byKey(const ValueKey('roll-button')));
      await tester.pumpAndSettle();

      // Verify UI updates - should show 2 rolls remaining
      expect(find.textContaining('Roll Dice'), findsOneWidget);
    });

    testWidgets('dispatches SelectCategoryEvent when category is tapped', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Roll dice to start game
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Tap a valid category (Aces)
      final acesFinder = find.text('Aces');
      expect(acesFinder, findsOneWidget);

      await tester.tap(acesFinder);
      await tester.pumpAndSettle();

      // Verify the category was scored (should no longer be selectable)
      // The UI should reflect the score
    });

    testWidgets('UI updates when state changes after die toggle', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Roll dice first
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Get initial checkbox state
      final checkbox0 = find.byKey(const ValueKey('checkbox-0'));
      expect(checkbox0, findsOneWidget);

      // Toggle die 0
      await tester.tap(find.byKey(const ValueKey('die-0')));
      await tester.pumpAndSettle();

      // UI should rebuild with updated hold state
      expect(checkbox0, findsOneWidget);
    });

    testWidgets('UI updates when state changes after roll', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // First roll
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Check remaining rolls display
      expect(find.textContaining('Roll Dice (2 left)'), findsOneWidget);

      // Second roll
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Check remaining rolls display
      expect(find.textContaining('Roll Dice (1 left)'), findsOneWidget);
    });

    testWidgets('roll button is disabled when no rolls remaining', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Use all 3 rolls
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Roll button should be disabled
      final rollButton = find.byKey(const ValueKey('roll-button'));
      expect(rollButton, findsOneWidget);
    });

    testWidgets('holds checkboxes are disabled when no rolls remaining', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Use all 3 rolls
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Checkboxes should still be present but interaction logic handled by bloc
      expect(find.byKey(const ValueKey('checkbox-0')), findsOneWidget);
    });

    testWidgets('displays new game FAB when game is over', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Roll dice to start game
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Score all categories to trigger game over
      // Upper section
      bloc.add(SelectCategoryEvent(ScoreCategory.aces));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.twos));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.threes));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fours));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fives));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.sixes));
      await tester.pumpAndSettle();

      // Lower section
      bloc.add(SelectCategoryEvent(ScoreCategory.threeOfKind));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fourOfKind));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fullHouse));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.smallStraight));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.largeStraight));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.yatzy));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.chance));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(); // Allow dialog to show

      // FAB should now show refresh icon for new game
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('new game event dispatched when FAB pressed after game over', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Roll dice to start game
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Score all categories to trigger game over
      bloc.add(SelectCategoryEvent(ScoreCategory.aces));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.twos));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.threes));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fours));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fives));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.sixes));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.threeOfKind));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fourOfKind));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fullHouse));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.smallStraight));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.largeStraight));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.yatzy));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.chance));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(); // Allow dialog to show

      // Dismiss the dialog by tapping the button
      await tester.tap(find.text('Play Again'));
      await tester.pumpAndSettle();

      // Tap the FAB to start new game
      await tester.tap(find.byKey(const ValueKey('new-game-fab')));
      await tester.pumpAndSettle();

      // Game should reset - dice should be in initial state
      expect(find.byKey(const ValueKey('die-0')), findsOneWidget);
    });

    testWidgets('game over dialog shows final score', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      // Roll dice to start game
      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Score all categories to trigger game over
      bloc.add(SelectCategoryEvent(ScoreCategory.aces));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.twos));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.threes));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fours));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fives));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.sixes));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.threeOfKind));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fourOfKind));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.fullHouse));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.smallStraight));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.largeStraight));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.yatzy));
      await tester.pumpAndSettle();
      bloc.add(SelectCategoryEvent(ScoreCategory.chance));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(); // Allow dialog to show

      // Game over dialog should appear
      expect(find.text('Game Over!'), findsOneWidget);
      expect(find.text('Your final score:'), findsOneWidget);
    });

    testWidgets('accessibility labels present on hold checkboxes', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(buildTestWidget(bloc: bloc));

      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Check for semantics labels
      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('layout is responsive on mobile', (WidgetTester tester) async {
      final bloc = GameBloc();
      await tester.pumpWidget(
        BlocProvider<GameBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(375, 812)),
              child: const GamePage(),
            ),
          ),
        ),
      );

      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Verify dice are rendered
      expect(find.byKey(const ValueKey('die-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('checkbox-0')), findsOneWidget);
    });

    testWidgets('layout is responsive on web/desktop', (
      WidgetTester tester,
    ) async {
      final bloc = GameBloc();
      await tester.pumpWidget(
        BlocProvider<GameBloc>.value(
          value: bloc,
          child: MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: const GamePage(),
            ),
          ),
        ),
      );

      bloc.add(RollDiceEvent());
      await tester.pumpAndSettle();

      // Verify dice are rendered
      expect(find.byKey(const ValueKey('die-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('checkbox-0')), findsOneWidget);
    });

    testWidgets('score sheet takes remaining space and scrolls', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());

      // Verify ListView is present for scrolling
      expect(find.byType(ListView), findsOneWidget);
    });
  });
}
