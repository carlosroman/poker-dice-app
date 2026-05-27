import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/widgets/bonus_indicator.dart';

void main() {
  group('BonusIndicator', () {
    testWidgets('renders BONUS label', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const BonusIndicator())),
        ),
      );

      expect(find.textContaining('BONUS'), findsOneWidget);
    });

    testWidgets('renders progress text', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const BonusIndicator())),
        ),
      );

      expect(find.text('0/63'), findsOneWidget);
    });

    testWidgets('renders outlined circle when bonus not awarded', (
      tester,
    ) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const BonusIndicator())),
        ),
      );

      expect(find.byIcon(Icons.circle_outlined), findsOneWidget);
    });

    testWidgets('renders filled circle when bonus awarded', (tester) async {
      final state = GameState();
      final stateWithBonus = state.copyWith(
        scores: {
          Category.ones: 10,
          Category.twos: 10,
          Category.threes: 10,
          Category.fours: 10,
          Category.fives: 10,
          Category.sixes: 13,
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(stateWithBonus)],
          child: MaterialApp(home: Scaffold(body: const BonusIndicator())),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows correct upper total', (tester) async {
      final state = GameState();
      final stateWithScores = state.copyWith(
        scores: {Category.ones: 3, Category.twos: 4, Category.threes: 6},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(stateWithScores)],
          child: MaterialApp(home: Scaffold(body: const BonusIndicator())),
        ),
      );

      expect(find.text('13/63'), findsOneWidget);
    });
  });
}
