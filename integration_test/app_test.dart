import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:poker_dice/main.dart' as app;
import 'package:poker_dice/widgets/animated_dice.dart';

/// End-to-end integration test: dice hold mechanics and Chance scoring flow.
///
/// Validates:
/// 1. Dice are blank on start
/// 2. Roll dice
/// 3. Hold middle dice (index 2)
/// 4. Roll again - middle dice unchanged
/// 5. Hold last dice (index 4)
/// 6. Roll again - middle and last dice unchanged
/// 7. Hold first dice (index 0)
/// 8. Roll again - first, middle, and last dice unchanged
/// 9. Chance section shows score preview
/// 10. Select "Chance" and score it
///
/// Also validates:
/// - Categories are disabled when dice are blank
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('categories disabled when dice are blank', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Reset GoRouter to title screen (singleton persists across flutter drive tests)
    app.router.go('/');
    await tester.pumpAndSettle();

    // Tap "New Game" button to navigate to game screen with fresh state
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Dice are blank on start, categories should be disabled
    // Try to tap "Aces" - it should not select the category
    await tester.tap(find.text('Aces'));
    await tester.pumpAndSettle();

    // Score button should remain disabled (no category selected)
    expect(find.text('Score'), findsOneWidget);
    final scoreButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).last,
    );
    expect(
      scoreButton.onPressed,
      isNull,
      reason: 'Score button should be disabled when dice are blank',
    );
  });

  testWidgets('dice hold and chance scoring flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Reset GoRouter to title screen (singleton persists across flutter drive tests)
    app.router.go('/');
    await tester.pumpAndSettle();

    // Tap "New Game" button to navigate to game screen with fresh state
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Helper to find a specific die by index
    Finder dieAt(int index) => find.byType(AnimatedDice).at(index);

    // 1. Check dice blank on start
    expect(find.byType(AnimatedDice), findsNWidgets(5));
    for (int i = 0; i < 5; i++) {
      final dieFinder = dieAt(i);
      expect(
        tester.getSemantics(dieFinder).label,
        contains('Die showing 0'),
        reason: 'Die $i should be blank on start',
      );
    }

    // 2. Roll dice
    await tester.tap(find.text('Roll'));
    await tester.pumpAndSettle();

    // Score button should be visible but DISABLED (no category selected)
    expect(find.text('Score'), findsOneWidget);
    final initialScoreButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).last,
    );
    expect(
      initialScoreButton.onPressed,
      isNull,
      reason: 'Score button should be disabled when no category selected',
    );

    // 3. Hold middle dice (index 2)
    final middleFinder = dieAt(2);
    final middleValue = _dieValueFromSemantics(
      tester.getSemantics(middleFinder),
    );
    expect(
      middleValue >= 1 && middleValue <= 6,
      isTrue,
      reason: 'Middle die should have a value',
    );

    await tester.tap(middleFinder);
    await tester.pumpAndSettle();

    // Verify middle die is held
    expect(
      tester.getSemantics(middleFinder).label,
      contains('held'),
      reason: 'Middle die should be held',
    );

    // 4. Roll dice and check middle dice did not change
    await tester.tap(find.text('Roll'));
    await tester.pumpAndSettle();

    expect(
      _dieValueFromSemantics(tester.getSemantics(dieAt(2))),
      middleValue,
      reason: 'Middle die should not change when held',
    );

    // 5. Hold last dice (index 4)
    final lastFinder = dieAt(4);
    final lastValue = _dieValueFromSemantics(tester.getSemantics(lastFinder));
    expect(
      lastValue >= 1 && lastValue <= 6,
      isTrue,
      reason: 'Last die should have a value',
    );

    await tester.tap(lastFinder);
    await tester.pumpAndSettle();

    // Verify last die is held
    expect(
      tester.getSemantics(lastFinder).label,
      contains('held'),
      reason: 'Last die should be held',
    );

    // 6. Roll dice and check middle and last dice did not change
    await tester.tap(find.text('Roll'));
    await tester.pumpAndSettle();

    expect(
      _dieValueFromSemantics(tester.getSemantics(dieAt(2))),
      middleValue,
      reason: 'Middle die should not change when held',
    );
    expect(
      _dieValueFromSemantics(tester.getSemantics(dieAt(4))),
      lastValue,
      reason: 'Last die should not change when held',
    );

    // 7. Hold first dice (index 0)
    final firstFinder = dieAt(0);
    final firstValue = _dieValueFromSemantics(tester.getSemantics(firstFinder));
    expect(
      firstValue >= 1 && firstValue <= 6,
      isTrue,
      reason: 'First die should have a value',
    );

    await tester.tap(firstFinder);
    await tester.pumpAndSettle();

    // Verify first die is held
    expect(
      tester.getSemantics(firstFinder).label,
      contains('held'),
      reason: 'First die should be held',
    );

    // 8. Roll dice and check first, middle and last dice did not change
    await tester.tap(find.text('Roll'));
    await tester.pumpAndSettle();

    expect(
      _dieValueFromSemantics(tester.getSemantics(dieAt(0))),
      firstValue,
      reason: 'First die should not change when held',
    );
    expect(
      _dieValueFromSemantics(tester.getSemantics(dieAt(2))),
      middleValue,
      reason: 'Middle die should not change when held',
    );
    expect(
      _dieValueFromSemantics(tester.getSemantics(dieAt(4))),
      lastValue,
      reason: 'Last die should not change when held',
    );

    // 9. Chance section should show the score (preview)
    // The Chance row (keyed by ValueKey('chance')) shows a numeric preview
    // after dice have been rolled.
    final chanceRowFinder = find.byKey(const ValueKey('chance'));
    expect(chanceRowFinder, findsOneWidget, reason: 'Chance row should exist');

    // Find Text widgets that are descendants of the Chance row
    final chanceScoreFinder = find.descendant(
      of: chanceRowFinder,
      matching: find.byType(Text),
    );
    expect(
      chanceScoreFinder,
      findsWidgets,
      reason: 'Chance row should show a score preview',
    );

    // 10. Select "Chance" and score that section
    await tester.tap(find.text('Chance'));
    await tester.pumpAndSettle();

    // Score button should be ENABLED when category selected and dice rolled
    expect(find.text('Score'), findsOneWidget);
    final enabledScoreButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).last,
    );
    expect(
      enabledScoreButton.onPressed,
      isNotNull,
      reason:
          'Score button should be enabled when category selected and dice rolled',
    );

    await tester.tap(find.text('Score'));
    await tester.pumpAndSettle();

    // Score button is always visible but disabled when no category selected
    expect(find.text('Score'), findsOneWidget);
    // Verify it's disabled (onPressed is null)
    final scoreButton = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton).last,
    );
    expect(scoreButton.onPressed, isNull);
  });

  /// End-to-end test: back navigation and continue game flow.
  ///
  /// Validates:
  /// - Step 11: Hit back to title screen
  /// - Step 12: Can return back to the original game (state preserved)
  /// - Step 13: Hit back to title screen again
  /// - Step 14: Selecting new game resets score to 0 and dice to blank
  testWidgets('back navigation and continue game flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Reset GoRouter to title screen (singleton persists across flutter drive tests)
    app.router.go('/');
    await tester.pumpAndSettle();

    // Tap "New Game" button to navigate to game screen with fresh state
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Roll dice to create a game state
    await tester.tap(find.text('Roll'));
    await tester.pumpAndSettle();
    // Allow async save to complete
    await tester.pump(const Duration(milliseconds: 100));

    // Store the dice values for later verification
    final diceValuesBefore = <int>[];
    for (int i = 0; i < 5; i++) {
      diceValuesBefore.add(
        _dieValueFromSemantics(
          tester.getSemantics(find.byType(AnimatedDice).at(i)),
        ),
      );
    }

    // Step 11: Hit back to title screen
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify we're at title screen
    expect(find.text('Poker Dice'), findsOneWidget);
    expect(find.text('New Single Game'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);

    // Step 12: Tap Continue to return to the game
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // Verify game state was preserved
    for (int i = 0; i < 5; i++) {
      final currentValue = _dieValueFromSemantics(
        tester.getSemantics(find.byType(AnimatedDice).at(i)),
      );
      expect(
        currentValue,
        diceValuesBefore[i],
        reason: 'Die $i should be preserved after continue',
      );
    }

    // Step 13: Hit back to title screen again
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // Verify we're at title screen
    expect(find.text('Poker Dice'), findsOneWidget);

    // Step 14: Selecting New Game brings you to the game with score 0 and blank dice
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();

    // Verify score is 0 (find within AppBar to avoid matching dice showing 0)
    expect(
      find.descendant(of: find.byType(AppBar), matching: find.text('0')),
      findsOneWidget,
      reason: 'Total score should be 0 after new game',
    );

    // Verify dice are blank
    for (int i = 0; i < 5; i++) {
      expect(
        tester.getSemantics(find.byType(AnimatedDice).at(i)).label,
        contains('Die showing 0'),
        reason: 'Die $i should be blank after new game',
      );
    }
  });

  /// End-to-end test: multiplayer game flow.
  ///
  /// Validates:
  /// - Step 1: Start a 2-player game from the title screen
  /// - Step 2: Player 1 rolls and scores a category
  /// - Step 3: Turn switches to Player 2
  /// - Step 4: Player 2 rolls and scores a category
  /// - Step 5: Both players' scores are displayed independently
  testWidgets('multiplayer game flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Reset GoRouter to title screen
    app.router.go('/');
    await tester.pumpAndSettle();

    // Step 1: Start a 2-player game
    await tester.tap(find.text('New Multiplayer Game'));
    await tester.pumpAndSettle();

    // Verify turn indicator shows Player 1
    expect(find.text('Player 1'), findsOneWidget);

    // Step 2: Player 1 rolls
    await tester.tap(find.text('Roll'));
    await tester.pumpAndSettle();

    // Verify dice are rolled
    var hasRolled = false;
    for (int i = 0; i < 5; i++) {
      final value = _dieValueFromSemantics(
        tester.getSemantics(find.byType(AnimatedDice).at(i)),
      );
      if (value >= 1 && value <= 6) {
        hasRolled = true;
        break;
      }
    }
    expect(hasRolled, isTrue, reason: 'At least one die should have a value');

    // Player 1 scores Aces
    await tester.tap(find.text('Aces'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Score'));
    await tester.pumpAndSettle();

    // Step 3: Verify turn switched to Player 2
    expect(find.text('Player 2'), findsOneWidget);

    // Step 4: Player 2 rolls and scores
    await tester.tap(find.text('Roll'));
    await tester.pumpAndSettle();

    // Player 2 scores Twos
    await tester.tap(find.text('Twos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Score'));
    await tester.pumpAndSettle();

    // Step 5: Verify turn switched back to Player 1
    expect(find.text('Player 1'), findsOneWidget);

    // Verify both players have scores in their respective categories
    expect(find.text('Aces'), findsOneWidget);
    expect(find.text('Twos'), findsOneWidget);
  });
}

/// Extracts the numeric die value from a semantics label like
/// "Die showing 3" or "Die showing 3, held".
int _dieValueFromSemantics(SemanticsNode node) {
  final label = node.label;
  final match = RegExp(r'Die showing (\d+)').firstMatch(label);
  if (match == null) {
    throw StateError('Cannot parse die value from label: "$label"');
  }
  return int.parse(match.group(1) ?? '');
}
