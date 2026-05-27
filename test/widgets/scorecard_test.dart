import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/models/game_state.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/services/scoring_service.dart';
import 'package:poker_dice/widgets/scorecard.dart';
import 'package:poker_dice/widgets/score_category_row.dart';

void main() {
  group('Scorecard', () {
    testWidgets('renders all 14 category rows', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const Scorecard())),
        ),
      );

      expect(find.byType(ScoreCategoryRow), findsNWidgets(14));
    });

    testWidgets('renders upper section categories', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const Scorecard())),
        ),
      );

      for (final category in Category.getUpperCategories()) {
        expect(find.text(category.displayName), findsOneWidget);
      }
    });

    testWidgets('renders lower section categories', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const Scorecard())),
        ),
      );

      for (final category in Category.getLowerCategories()) {
        expect(find.text(category.displayName), findsOneWidget);
      }
    });

    testWidgets('renders bonus indicator', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const Scorecard())),
        ),
      );

      expect(find.textContaining('BONUS'), findsOneWidget);
    });

    testWidgets('renders upper total', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const Scorecard())),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders two columns side by side', (tester) async {
      final state = GameState();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(state)],
          child: MaterialApp(home: Scaffold(body: const Scorecard())),
        ),
      );

      // Find the Row widgets that contain the columns
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('selects category on tap', (tester) async {
      final state = GameState();
      final notifier = GameNotifier(ScoringService());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            gameStateProvider.overrideWithValue(state),
            gameNotifierProvider.overrideWith((ref) => notifier),
          ],
          child: MaterialApp(home: Scaffold(body: const Scorecard())),
        ),
      );

      // Tap on Ones category
      await tester.tap(find.text('Ones'));
      await tester.pumpAndSettle();

      expect(notifier.state.selectedCategory, Category.ones);
    });

    testWidgets('shows score when scored', (tester) async {
      final state = GameState();
      final stateWithScore = state.copyWith(scores: {Category.ones: 3});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [gameStateProvider.overrideWithValue(stateWithScore)],
          child: MaterialApp(home: Scaffold(body: const Scorecard())),
        ),
      );

      expect(find.text('3'), findsAtLeast(1));
    });
  });
}
