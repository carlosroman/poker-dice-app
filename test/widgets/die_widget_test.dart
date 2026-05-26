import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/die_widget.dart';

void main() {
  group('DieWidget', () {
    Widget buildDieWidget({bool isHeld = false, VoidCallback? onTap}) {
      return MaterialApp(
        home: Scaffold(
          body: DieWidget(value: 5, isHeld: isHeld, onTap: onTap),
        ),
      );
    }

    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(buildDieWidget());
      expect(find.byType(DieWidget), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildDieWidget(onTap: () => tapped = true));
      await tester.tap(find.byType(DieWidget));
      expect(tapped, isTrue);
    });

    testWidgets('does not call onTap when null', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildDieWidget(onTap: null));
      // Tapping should not throw
      await tester.tap(find.byType(DieWidget));
      expect(tapped, isFalse);
    });

    testWidgets('shows different visuals for held state', (tester) async {
      await tester.pumpWidget(buildDieWidget(isHeld: false));
      final notHeld = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      await tester.pumpWidget(buildDieWidget(isHeld: true));
      await tester.pumpAndSettle();
      final held = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );

      // Held state should have different decoration (border/shadow)
      expect(held.decoration, isNot(equals(notHeld.decoration)));
    });
  });

  group('DieWidget pip rendering', () {
    Widget buildDieWithValue(int value) {
      return MaterialApp(
        home: Scaffold(body: DieWidget(value: value, isHeld: false)),
      );
    }

    // Pip circles are rendered as DecoratedBox widgets with circular shape
    int countPipCircles(WidgetTester tester) {
      return tester
          .widgetList<DecoratedBox>(
            find.descendant(
              of: find.byType(GridView),
              matching: find.byWidgetPredicate(
                (w) =>
                    w is DecoratedBox &&
                    w.decoration is BoxDecoration &&
                    (w.decoration as BoxDecoration).shape == BoxShape.circle,
              ),
            ),
          )
          .length;
    }

    testWidgets('renders 1 pip for value 1', (tester) async {
      await tester.pumpWidget(buildDieWithValue(1));
      expect(countPipCircles(tester), 1);
    });

    testWidgets('renders 2 pips for value 2', (tester) async {
      await tester.pumpWidget(buildDieWithValue(2));
      expect(countPipCircles(tester), 2);
    });

    testWidgets('renders 3 pips for value 3', (tester) async {
      await tester.pumpWidget(buildDieWithValue(3));
      expect(countPipCircles(tester), 3);
    });

    testWidgets('renders 4 pips for value 4', (tester) async {
      await tester.pumpWidget(buildDieWithValue(4));
      expect(countPipCircles(tester), 4);
    });

    testWidgets('renders 5 pips for value 5', (tester) async {
      await tester.pumpWidget(buildDieWithValue(5));
      expect(countPipCircles(tester), 5);
    });

    testWidgets('renders 6 pips for value 6', (tester) async {
      await tester.pumpWidget(buildDieWithValue(6));
      expect(countPipCircles(tester), 6);
    });
  });
}
