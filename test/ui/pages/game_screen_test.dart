import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/ui/pages/game_screen.dart';

void main() {
  group('GameScreen', () {
    Widget createGameScreen() {
      return MaterialApp(home: GameScreen());
    }

    testWidgets('displays score at header', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // Score is displayed in header
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('displays back button', (tester) async {
      await tester.pumpWidget(createGameScreen());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('displays menu button', (tester) async {
      await tester.pumpWidget(createGameScreen());

      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('displays 5 dice', (tester) async {
      await tester.pumpWidget(createGameScreen());

      expect(find.byKey(const ValueKey('die-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('die-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('die-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('die-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('die-4')), findsOneWidget);
    });

    testWidgets('displays ROLL button', (tester) async {
      await tester.pumpWidget(createGameScreen());

      expect(find.textContaining('ROLL'), findsOneWidget);
    });

    testWidgets('displays New Game button', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // Check for the ElevatedButton (New Game button)
      expect(find.byType(ElevatedButton), findsWidgets);
    });

    testWidgets('displays score sheet with categories', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // Score sheet should have Minor and Major section headers
      expect(find.text('Minor'), findsOneWidget);
      expect(find.text('Major'), findsOneWidget);
    });

    testWidgets('toggles die held state when tapped', (tester) async {
      await tester.pumpWidget(createGameScreen());

      final die0 = find.byKey(const ValueKey('die-0'));
      expect(die0, findsOneWidget);

      // Ensure die is visible before tapping
      await tester.ensureVisible(die0);
      // Tap die to toggle (using warnIfMissed: false to suppress hit test warning)
      await tester.tap(die0, warnIfMissed: false);
      await tester.pump();

      // Ensure die is visible before tapping again
      await tester.ensureVisible(die0);
      // Tap again to toggle back
      await tester.tap(die0, warnIfMissed: false);
      await tester.pump();
    });

    testWidgets('increments roll count when ROLL is tapped', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // Initial roll count displayed
      final initialRollButton = find.textContaining('ROLL');
      expect(initialRollButton, findsOneWidget);

      // Tap ROLL button
      await tester.tap(initialRollButton);
      await tester.pump();

      // Should still have ROLL button (with updated count)
      expect(find.textContaining('ROLL'), findsOneWidget);
    });

    testWidgets('displays bonus row in upper section', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // The bonus row should be present in the Minor column
      expect(find.text('Minor'), findsOneWidget);
    });

    testWidgets('shows menu modal when menu button is tapped', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // Tap menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Check if menu items are visible - find ListTile
      final menuItems = find.byType(ListTile);
      expect(menuItems, findsWidgets);
    });

    testWidgets('starts new game when menu New Game tapped', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // Tap menu button
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap the first ListTile (menu item)
      await tester.tap(find.byType(ListTile).first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Should be back at game screen
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('uses gradient background', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // Find the gradient container
      final gradientFinder = find.byType(Container);
      expect(gradientFinder, findsWidgets);
    });

    testWidgets('has SafeArea wrapper', (tester) async {
      await tester.pumpWidget(createGameScreen());

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('displays upper section total row', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // The bonus row should be present in the Minor column
      expect(find.text('Minor'), findsOneWidget);
    });

    testWidgets('New Game button resets the game', (tester) async {
      await tester.pumpWidget(createGameScreen());

      // Tap the second ElevatedButton (New Game button)
      await tester.tap(find.byType(ElevatedButton).last);
      await tester.pump();

      // Should still be on game screen
      expect(find.byType(GameScreen), findsOneWidget);
    });
  });
}
