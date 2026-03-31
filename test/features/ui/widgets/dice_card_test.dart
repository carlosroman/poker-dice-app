import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/features/ui/widgets/dice_card.dart';
import 'package:poker_dice/features/ui/widgets/dice_dot.dart';

void main() {
  group('DiceCard', () {
    group('renders correct dice dot', () {
      testWidgets('value 1 displays 1 pip', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 1, isHeld: false, rollId: 0)),
          ),
        );

        expect(find.byType(DiceDot), findsOneWidget);
        final diceDot = tester.widget<DiceDot>(find.byType(DiceDot).first);
        expect(diceDot.value, 1);
      });

      testWidgets('value 2 displays 2 pips', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 2, isHeld: false, rollId: 0)),
          ),
        );

        expect(find.byType(DiceDot), findsOneWidget);
        final diceDot = tester.widget<DiceDot>(find.byType(DiceDot).first);
        expect(diceDot.value, 2);
      });

      testWidgets('value 3 displays 3 pips', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 3, isHeld: false, rollId: 0)),
          ),
        );

        expect(find.byType(DiceDot), findsOneWidget);
        final diceDot = tester.widget<DiceDot>(find.byType(DiceDot).first);
        expect(diceDot.value, 3);
      });

      testWidgets('value 4 displays 4 pips', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 4, isHeld: false, rollId: 0)),
          ),
        );

        expect(find.byType(DiceDot), findsOneWidget);
        final diceDot = tester.widget<DiceDot>(find.byType(DiceDot).first);
        expect(diceDot.value, 4);
      });

      testWidgets('value 5 displays 5 pips', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 5, isHeld: false, rollId: 0)),
          ),
        );

        expect(find.byType(DiceDot), findsOneWidget);
        final diceDot = tester.widget<DiceDot>(find.byType(DiceDot).first);
        expect(diceDot.value, 5);
      });

      testWidgets('value 6 displays 6 pips', (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 6, isHeld: false, rollId: 0)),
          ),
        );

        expect(find.byType(DiceDot), findsOneWidget);
        final diceDot = tester.widget<DiceDot>(find.byType(DiceDot).first);
        expect(diceDot.value, 6);
      });
    });

    group('shows hold indicator', () {
      testWidgets('isHeld=false has no orange border', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: DiceCard(value: 1, isHeld: false, rollId: 0)),
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
            home: Scaffold(body: DiceCard(value: 1, isHeld: true, rollId: 0)),
          ),
        );

        final decoratedBox = tester.widget<DecoratedBox>(
          find.byType(DecoratedBox).first,
        );

        final decoration = decoratedBox.decoration as BoxDecoration;
        final border = decoration.border as Border;
        // Orange border with reduced opacity for subtle held effect
        expect(
          border.top.color,
          equals(const Color(0xFFFF6F00).withOpacity(0.6)),
        );
      });

      testWidgets('tap toggles hold state', (WidgetTester tester) async {
        bool holdState = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return DiceCard(
                    value: 1,
                    isHeld: holdState,
                    rollId: 0,
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
