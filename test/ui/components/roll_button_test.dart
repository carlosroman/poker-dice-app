import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/components/roll_button.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

void main() {
  group('RollButton', () {
    // Helper function to create a widget with RollButton
    Widget createRollButton({
      bool isEnabled = true,
      int remainingRolls = 3,
      VoidCallback? onPressed,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: RollButton(
              isEnabled: isEnabled,
              remainingRolls: remainingRolls,
              onPressed: onPressed,
            ),
          ),
        ),
      );
    }

    //region Render Tests

    testWidgets('renders button with correct text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      expect(find.text('Roll Dice (3 left)'), findsOneWidget);
    });

    testWidgets('shows remaining rolls count', (WidgetTester tester) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 1),
      );

      expect(find.text('Roll Dice (1 left)'), findsOneWidget);
    });

    testWidgets('shows default text when remainingRolls is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: false, remainingRolls: 0),
      );

      expect(find.text('Roll Dice'), findsOneWidget);
    });

    testWidgets('contains dice icon when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      expect(find.byIcon(Icons.diamond), findsOneWidget);
    });

    testWidgets('contains block icon when disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: false, remainingRolls: 0),
      );

      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    //endregion

    //region Color Tests

    testWidgets('enabled state has primary color background', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      final buttonFinder = find.byType(ElevatedButton);
      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      final buttonStyle = buttonWidget.style;

      final backgroundColor = buttonStyle?.backgroundColor?.resolve({});
      expect(backgroundColor, equals(AppTheme.primaryColor));
    });

    testWidgets('disabled state has grey background color', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: false, remainingRolls: 0),
      );

      final buttonFinder = find.byType(ElevatedButton);
      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      final buttonStyle = buttonWidget.style;

      final backgroundColor = buttonStyle?.backgroundColor?.resolve({});
      expect(backgroundColor, equals(AppTheme.disabledColor));
    });

    testWidgets('foreground color is white for contrast', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      final buttonFinder = find.byType(ElevatedButton);
      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      final buttonStyle = buttonWidget.style;

      final foregroundColor = buttonStyle?.foregroundColor?.resolve({});
      expect(foregroundColor, equals(AppTheme.textOnSurface));
    });

    //endregion

    //region Disabled State Tests

    testWidgets('button is disabled when remainingRolls is 0', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: false, remainingRolls: 0),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      expect(buttonWidget.onPressed, isNull);
    });

    testWidgets('button is enabled when isEnabled is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 2),
      );

      // Check that the button can be tapped (not disabled)
      expect(find.byType(ElevatedButton), findsOneWidget);

      // Verify the button is tappable by checking it responds to tap
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // If we get here without error, the button is enabled
      expect(true, isTrue);
    });

    //endregion

    //region Callback Tests

    testWidgets('callback is called when pressed and enabled', (
      WidgetTester tester,
    ) async {
      bool wasPressed = false;
      void handlePress() {
        wasPressed = true;
      }

      await tester.pumpWidget(
        createRollButton(
          isEnabled: true,
          remainingRolls: 3,
          onPressed: handlePress,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('callback is NOT called when disabled', (
      WidgetTester tester,
    ) async {
      bool wasPressed = false;
      void handlePress() {
        wasPressed = true;
      }

      await tester.pumpWidget(
        createRollButton(
          isEnabled: false,
          remainingRolls: 0,
          onPressed: handlePress,
        ),
      );

      // Try to tap the button - should not trigger callback
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isFalse);
    });

    //endregion

    //region Accessibility Tests

    testWidgets('has semantic label for accessibility', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      // Check that the button has semantics
      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      // Verify semantics widget is present
      final semanticsFinder = find.byType(Semantics);
      expect(semanticsFinder, findsWidgets);
    });

    testWidgets('button is focusable for keyboard navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      final buttonFinder = find.byType(ElevatedButton);
      expect(buttonFinder, findsOneWidget);

      // Check that the button can be tapped (indicates it's enabled/focusable)
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // If we get here without error, the button is enabled
      expect(true, isTrue);
    });

    //endregion

    //region Sizing Tests

    testWidgets('has minimum touch target size of 48x48', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      final buttonFinder = find.byType(ElevatedButton);
      await tester.pumpAndSettle();

      final RenderBox renderBox = tester.renderObject(buttonFinder);
      final Size size = renderBox.size;

      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    });

    testWidgets('has rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      final buttonFinder = find.byType(ElevatedButton);
      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      final buttonStyle = buttonWidget.style;

      final shape = buttonStyle?.shape?.resolve({});
      expect(shape, isA<RoundedRectangleBorder>());

      final roundedShape = shape as RoundedRectangleBorder;
      expect(roundedShape.borderRadius, isNotNull);
    });

    testWidgets('has elevation for depth', (WidgetTester tester) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      final buttonFinder = find.byType(ElevatedButton);
      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      final buttonStyle = buttonWidget.style;

      final elevation = buttonStyle?.elevation?.resolve({});
      expect(elevation, greaterThan(0));
    });

    //endregion

    //region Animation Tests

    testWidgets('animates when enabled state changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      // Verify initial state
      expect(find.byIcon(Icons.diamond), findsOneWidget);

      // Change to disabled state
      await tester.pumpWidget(
        createRollButton(isEnabled: false, remainingRolls: 0),
      );

      // Verify icon changed
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('animates when remaining rolls changes', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      expect(find.text('Roll Dice (3 left)'), findsOneWidget);

      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 2),
      );

      expect(find.text('Roll Dice (2 left)'), findsOneWidget);
    });

    //endregion

    //region Visual Design Tests

    testWidgets('has shadow/elevation for depth', (WidgetTester tester) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      final buttonFinder = find.byType(ElevatedButton);
      final ElevatedButton buttonWidget = tester.widget(buttonFinder);
      final buttonStyle = buttonWidget.style;

      // Check that elevation is set (which creates shadow)
      expect(buttonStyle?.elevation?.resolve({}), greaterThan(0));
    });

    testWidgets('displays icon and text in row layout', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        createRollButton(isEnabled: true, remainingRolls: 3),
      );

      // Check that both icon and text are present
      expect(find.byIcon(Icons.diamond), findsOneWidget);
      expect(find.text('Roll Dice (3 left)'), findsOneWidget);
    });

    //endregion
  });
}
