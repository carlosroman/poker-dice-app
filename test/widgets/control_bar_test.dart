import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/widgets/control_bar.dart';

void main() {
  group('ControlBar', () {
    testWidgets('renders roll button', (tester) async {
      final notifier = GameNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      expect(find.textContaining('ROLL'), findsOneWidget);
    });

    testWidgets('renders play button', (tester) async {
      final notifier = GameNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('shows remaining rolls', (tester) async {
      final notifier = GameNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      expect(find.text('ROLL 3'), findsOneWidget);
    });

    testWidgets('roll button is enabled when can roll', (tester) async {
      final notifier = GameNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      final rollButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'ROLL 3'),
      );
      expect(rollButton.onPressed, isNotNull);
    });

    testWidgets('roll button is disabled when no rolls left', (tester) async {
      final state = const GameState(
        diceRoll: [1, 2, 3, 4, 5],
        currentRollsRemaining: 0,
      );
      final notifier = GameNotifier(initialState: state);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      final rollButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'ROLL 0'),
      );
      expect(rollButton.onPressed, isNull);
    });

    testWidgets('play button is enabled when can score', (tester) async {
      final state = const GameState(
        diceRoll: [1, 2, 3, 4, 5],
        selectedCategory: 'ones',
      );
      final notifier = GameNotifier(initialState: state);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      final playButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'PLAY'),
      );
      expect(playButton.onPressed, isNotNull);
    });

    testWidgets('play button is disabled when no selection', (tester) async {
      final notifier = GameNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      final playButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'PLAY'),
      );
      expect(playButton.onPressed, isNull);
    });

    testWidgets('tapping roll calls rollDice', (tester) async {
      final notifier = GameNotifier();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'ROLL 3'));
      await tester.pumpAndSettle();

      expect(notifier.state.currentRollsRemaining, 2);
    });

    testWidgets('tapping play scores selected category', (tester) async {
      final state = const GameState(
        diceRoll: [1, 2, 3, 4, 5],
        selectedCategory: 'ones',
      );
      final notifier = GameNotifier(initialState: state);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameNotifierProvider.overrideWith((ref) => notifier)],
          child: MaterialApp(home: Scaffold(body: const ControlBar())),
        ),
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'PLAY'));
      await tester.pumpAndSettle();

      expect(notifier.state.scores['ones'], isNotNull);
    });
  });
}
