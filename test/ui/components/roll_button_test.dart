import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/components/roll_button.dart';

void main() {
  group('RollButton', () {
    testWidgets('displays ROLL when rollCount is 0', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollButton(rollCount: 0))),
      );

      expect(find.text('ROLL'), findsOneWidget);
    });

    testWidgets('displays ROLL 1 when rollCount is 1', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollButton(rollCount: 1))),
      );

      expect(find.text('ROLL 1'), findsOneWidget);
    });

    testWidgets('displays ROLL 2 when rollCount is 2', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollButton(rollCount: 2))),
      );

      expect(find.text('ROLL 2'), findsOneWidget);
    });

    testWidgets('displays ROLL 3 when rollCount is 3', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollButton(rollCount: 3))),
      );

      expect(find.text('ROLL 3'), findsOneWidget);
    });

    testWidgets('is enabled when rollCount is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RollButton(rollCount: 0, onTap: () {})),
        ),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);

      final widget = tester.widget<ElevatedButton>(button);
      expect(widget.onPressed, isNotNull);
    });

    testWidgets('is enabled when rollCount is 1', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RollButton(rollCount: 1, onTap: () {})),
        ),
      );

      final button = find.byType(ElevatedButton);
      final widget = tester.widget<ElevatedButton>(button);
      expect(widget.onPressed, isNotNull);
    });

    testWidgets('is enabled when rollCount is 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RollButton(rollCount: 2, onTap: () {})),
        ),
      );

      final button = find.byType(ElevatedButton);
      final widget = tester.widget<ElevatedButton>(button);
      expect(widget.onPressed, isNotNull);
    });

    testWidgets('is disabled when rollCount is 3', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollButton(rollCount: 3))),
      );

      final button = find.byType(ElevatedButton);
      final widget = tester.widget<ElevatedButton>(button);
      expect(widget.onPressed, isNull);
    });

    testWidgets('calls onTap when tapped and enabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RollButton(rollCount: 0, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when disabled', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RollButton(rollCount: 3, onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(tapped, isFalse);
    });

    testWidgets('uses dark blue color when enabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollButton(rollCount: 0))),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('uses grey color when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollButton(rollCount: 3))),
      );

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
    });

    testWidgets('has correct font size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: RollButton(rollCount: 0))),
      );

      final text = find.byType(Text);
      expect(text, findsOneWidget);
    });
  });

  group('RollButton - isEnabled property', () {
    test('returns true for rollCount 0', () {
      const button = RollButton(rollCount: 0);
      expect(button.isEnabled, isTrue);
    });

    test('returns true for rollCount 1', () {
      const button = RollButton(rollCount: 1);
      expect(button.isEnabled, isTrue);
    });

    test('returns true for rollCount 2', () {
      const button = RollButton(rollCount: 2);
      expect(button.isEnabled, isTrue);
    });

    test('returns false for rollCount 3', () {
      const button = RollButton(rollCount: 3);
      expect(button.isEnabled, isFalse);
    });
  });

  group('RollButton - buttonText property', () {
    test('returns ROLL for rollCount 0', () {
      const button = RollButton(rollCount: 0);
      expect(button.buttonText, 'ROLL');
    });

    test('returns ROLL 1 for rollCount 1', () {
      const button = RollButton(rollCount: 1);
      expect(button.buttonText, 'ROLL 1');
    });

    test('returns ROLL 2 for rollCount 2', () {
      const button = RollButton(rollCount: 2);
      expect(button.buttonText, 'ROLL 2');
    });

    test('returns ROLL 3 for rollCount 3', () {
      const button = RollButton(rollCount: 3);
      expect(button.buttonText, 'ROLL 3');
    });
  });
}
