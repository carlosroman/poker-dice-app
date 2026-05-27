import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/screens/game_screen.dart';
import 'package:poker_dice/widgets/control_bar.dart';
import 'package:poker_dice/widgets/dice_container.dart';
import 'package:poker_dice/widgets/header_bar.dart';
import 'package:poker_dice/widgets/scorecard.dart';

void main() {
  group('GameScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: const GameScreen()),
        ),
      );

      // Find the AppBar title specifically
      expect(find.widgetWithText(AppBar, 'Yatzy'), findsOneWidget);
    });

    testWidgets('renders header bar', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: const GameScreen()),
        ),
      );

      expect(find.byType(HeaderBar), findsOneWidget);
    });

    testWidgets('renders dice container', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: const GameScreen()),
        ),
      );

      expect(find.byType(DiceContainer), findsOneWidget);
    });

    testWidgets('renders scorecard', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: const GameScreen()),
        ),
      );

      expect(find.byType(Scorecard), findsOneWidget);
    });

    testWidgets('renders control bar', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: const GameScreen()),
        ),
      );

      expect(find.byType(ControlBar), findsOneWidget);
    });

    testWidgets('renders refresh button', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: const GameScreen()),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('has correct layout structure', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: const GameScreen()),
        ),
      );

      // Should have a Column with header, expanded scrollable content, and control bar
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('scorecard is scrollable', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: const GameScreen()),
        ),
      );

      // Scroll down
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
        5000,
      );
      await tester.pumpAndSettle();

      // Should still find all widgets
      expect(find.byType(Scorecard), findsOneWidget);
    });
  });
}
