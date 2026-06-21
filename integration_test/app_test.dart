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
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dice hold and chance scoring flow', (tester) async {
    app.main();
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

    // Score button should appear when a category is selected
    expect(find.text('Score'), findsOneWidget);

    await tester.tap(find.text('Score'));
    await tester.pumpAndSettle();

    // Score button disappears after scoring
    expect(find.text('Score'), findsNothing);
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
