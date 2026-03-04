import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/ui/widgets/dice_card.dart';

void main() {
  group('DiceCard', () {
    group('renders correct face', () {
      testWidgets('value 0 displays 9', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 0, isHeld: false)),
          ),
        );

        expect(find.text('9'), findsOneWidget);
      });

      testWidgets('value 1 displays 10', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 1, isHeld: false)),
          ),
        );

        expect(find.text('10'), findsOneWidget);
      });

      testWidgets('value 2 displays J', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 2, isHeld: false)),
          ),
        );

        expect(find.text('J'), findsOneWidget);
      });

      testWidgets('value 3 displays Q', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 3, isHeld: false)),
          ),
        );

        expect(find.text('Q'), findsOneWidget);
      });

      testWidgets('value 4 displays K', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 4, isHeld: false)),
          ),
        );

        expect(find.text('K'), findsOneWidget);
      });

      testWidgets('value 5 displays A', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 5, isHeld: false)),
          ),
        );

        expect(find.text('A'), findsOneWidget);
      });
    });

    group('shows hold indicator', () {
      testWidgets('isHeld=false has no orange border', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 0, isHeld: false)),
          ),
        );

        final decoratedBox = tester.widget<DecoratedBox>(
          find.byType(DecoratedBox).first,
        );

        final decoration = decoratedBox.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.top.color, isNot(equals(const Color(0xFFFF6F00))));
      });

      testWidgets('isHeld=true has orange border', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 0, isHeld: true)),
          ),
        );

        final decoratedBox = tester.widget<DecoratedBox>(
          find.byType(DecoratedBox).first,
        );

        final decoration = decoratedBox.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.top.color, equals(const Color(0xFFFF6F00)));
      });

      testWidgets('tap toggles hold state', (WidgetTester tester) async {
        bool holdState = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DiceCard(
                    value: 0,
                    isHeld: holdState,
                    onTap: () {
                      setState(() {
                        holdState = !holdState;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        );

        expect(holdState, isFalse);

        await tester.tap(find.byType(DiceCard), warnIfMissed: false);
        await tester.pump();

        expect(holdState, isTrue);

        await tester.tap(find.byType(DiceCard), warnIfMissed: false);
        await tester.pump();

        expect(holdState, isFalse);
      });
    });
  });
}
