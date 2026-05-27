import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/widgets/header_bar.dart';

void main() {
  group('HeaderBar', () {
    testWidgets('renders total score', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const HeaderBar())),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders You label', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const HeaderBar())),
        ),
      );

      expect(find.text('You'), findsOneWidget);
    });

    testWidgets('renders back button', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const HeaderBar())),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('renders menu button', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const HeaderBar())),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('displays updated total score', (tester) async {
      final state = GameState();
      final stateWithScores = state.copyWith(
        scores: {Category.ones: 3, Category.twos: 4},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(stateWithScores)],
          child: MaterialApp(home: Scaffold(body: const HeaderBar())),
        ),
      );

      expect(find.text('7'), findsOneWidget);
    });
  });
}
