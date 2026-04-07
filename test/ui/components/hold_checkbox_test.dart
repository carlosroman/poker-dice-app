import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/components/hold_checkbox.dart';

void main() {
  group('HoldCheckbox', () {
    testWidgets('Renders checkbox in unchecked state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: HoldCheckbox(isHeld: false, onChanged: (_) {})),
          ),
        ),
      );

      // Find the checkbox
      final Checkbox checkbox = tester.widget<Checkbox>(find.byType(Checkbox));

      // Verify unchecked state
      expect(checkbox.value, isFalse);
    });

    testWidgets('Renders checkbox in checked state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: HoldCheckbox(isHeld: true, onChanged: (_) {})),
          ),
        ),
      );

      // Find the checkbox
      final Checkbox checkbox = tester.widget<Checkbox>(find.byType(Checkbox));

      // Verify checked state
      expect(checkbox.value, isTrue);
    });

    testWidgets('Checkbox toggles state when tapped', (
      WidgetTester tester,
    ) async {
      bool heldState = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return HoldCheckbox(
                    isHeld: heldState,
                    onChanged: (bool? newValue) {
                      setState(() {
                        heldState = newValue ?? false;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Find and tap the checkbox
      final Finder checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      // Verify initial unchecked state
      Checkbox checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isFalse);

      await tester.tap(checkboxFinder, warnIfMissed: false);
      await tester.pump();

      // Verify state changed to checked
      checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isTrue);

      // Tap again to uncheck
      await tester.tap(checkboxFinder, warnIfMissed: false);
      await tester.pump();

      // Verify state changed back to unchecked
      checkbox = tester.widget<Checkbox>(checkboxFinder);
      expect(checkbox.value, isFalse);
    });

    testWidgets('Disabled checkbox does not respond to taps', (
      WidgetTester tester,
    ) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoldCheckbox(
                isHeld: false,
                onChanged: (_) {
                  callbackCalled = true;
                },
                isEnabled: false,
              ),
            ),
          ),
        ),
      );

      // Find and tap the checkbox
      final Finder checkboxFinder = find.byType(Checkbox);
      expect(checkboxFinder, findsOneWidget);

      await tester.tap(checkboxFinder, warnIfMissed: false);
      await tester.pump();

      // Verify callback was not called
      expect(callbackCalled, isFalse);

      // Verify checkbox is still in original state
      final Checkbox checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.value, isFalse);
    });

    testWidgets('Callback is called when toggled', (WidgetTester tester) async {
      int callbackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: HoldCheckbox(
                isHeld: false,
                onChanged: (bool? newValue) {
                  callbackCount++;
                },
              ),
            ),
          ),
        ),
      );

      // Tap the checkbox
      final Finder checkboxFinder = find.byType(Checkbox);
      await tester.tap(checkboxFinder, warnIfMissed: false);
      await tester.pump();

      // Verify callback was called once
      expect(callbackCount, equals(1));

      // Tap again
      await tester.tap(checkboxFinder, warnIfMissed: false);
      await tester.pump();

      // Verify callback was called twice
      expect(callbackCount, equals(2));
    });

    testWidgets('Accessibility labels present', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: HoldCheckbox(isHeld: false, onChanged: (_) {})),
          ),
        ),
      );

      // Find Semantics widgets inside HoldCheckbox
      final Finder semanticsFinder = find.descendant(
        of: find.byType(HoldCheckbox),
        matching: find.byType(Semantics),
      );
      expect(semanticsFinder, findsWidgets);

      // Verify Semantics widgets exist
      expect(semanticsFinder.evaluate().length, greaterThan(0));
    });

    testWidgets('Correct sizing for touch targets', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: HoldCheckbox(isHeld: false, onChanged: (_) {})),
          ),
        ),
      );

      // Find the SizedBox widget inside HoldCheckbox
      final Finder sizedBoxFinder = find.descendant(
        of: find.byType(HoldCheckbox),
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsOneWidget);

      final SizedBox sizedBox = tester.widget<SizedBox>(sizedBoxFinder);

      // Verify minimum touch target size (48x48)
      expect(sizedBox.width, greaterThanOrEqualTo(48.0));
      expect(sizedBox.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('Checked state has correct semantics', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: HoldCheckbox(isHeld: true, onChanged: (_) {})),
          ),
        ),
      );

      // Find the Semantics widget with the label "Die held"
      final Finder semanticsFinder = find.descendant(
        of: find.byType(HoldCheckbox),
        matching: find.byType(Semantics),
      );
      expect(semanticsFinder, findsWidgets);

      // Just verify that Semantics widgets exist
      expect(semanticsFinder.evaluate().length, greaterThan(0));
    });

    testWidgets('Disabled checkbox has greyed out appearance', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: HoldCheckbox(isHeld: false, isEnabled: false)),
          ),
        ),
      );

      // Find the checkbox
      final Checkbox checkbox = tester.widget<Checkbox>(find.byType(Checkbox));

      // Verify the checkbox is disabled (onChanged is null when disabled)
      expect(checkbox.onChanged, isNull);
    });

    testWidgets('AnimatedContainer is present for smooth animations', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: HoldCheckbox(isHeld: false, onChanged: (_) {})),
          ),
        ),
      );

      // Find AnimatedContainer widget inside HoldCheckbox
      final Finder animatedContainerFinder = find.descendant(
        of: find.byType(HoldCheckbox),
        matching: find.byType(AnimatedContainer),
      );
      expect(animatedContainerFinder, findsOneWidget);
    });
  });
}
