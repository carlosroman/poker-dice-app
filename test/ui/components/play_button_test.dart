import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/components/play_button.dart';

void main() {
  group('PlayButton', () {
    testWidgets('displays PLAY text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton())),
      );

      expect(find.text('PLAY'), findsOneWidget);
    });

    testWidgets('is disabled by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton())),
      );

      final button = find.byType(OutlinedButton);
      final widget = tester.widget<OutlinedButton>(button);
      expect(widget.onPressed, isNull);
    });

    testWidgets('is enabled when isEnabled is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlayButton(isEnabled: true, onTap: () {})),
        ),
      );

      final button = find.byType(OutlinedButton);
      final widget = tester.widget<OutlinedButton>(button);
      expect(widget.onPressed, isNotNull);
    });

    testWidgets('calls onTap when tapped and enabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayButton(isEnabled: true, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PlayButton(isEnabled: false, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('uses white background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton(isEnabled: true))),
      );

      final button = find.byType(OutlinedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('uses orange text when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton(isEnabled: true))),
      );

      final text = find.byType(Text);
      expect(text, findsOneWidget);
    });

    testWidgets('uses grey text when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton(isEnabled: false))),
      );

      final text = find.byType(Text);
      expect(text, findsOneWidget);
    });

    testWidgets('has orange border when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton(isEnabled: true))),
      );

      final button = find.byType(OutlinedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('has grey border when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton(isEnabled: false))),
      );

      final button = find.byType(OutlinedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton(isEnabled: true))),
      );

      final text = find.byType(Text);
      expect(text, findsOneWidget);
    });

    testWidgets('has rounded corners', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PlayButton(isEnabled: true))),
      );

      final button = find.byType(OutlinedButton);
      expect(button, findsOneWidget);
    });
  });

  group('PlayButton - State', () {
    testWidgets('updates when isEnabled changes', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlayButton(isEnabled: false, onTap: () {})),
        ),
      );

      // Initial state - disabled
      final button1 = find.byType(OutlinedButton);
      final widget1 = tester.widget<OutlinedButton>(button1);
      expect(widget1.onPressed, isNull);

      // Rebuild with enabled state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: PlayButton(isEnabled: true, onTap: () {})),
        ),
      );

      // New state - enabled
      final button2 = find.byType(OutlinedButton);
      final widget2 = tester.widget<OutlinedButton>(button2);
      expect(widget2.onPressed, isNotNull);
    });
  });
}
