import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/dice_face.dart';

void main() {
  group('DiceFace', () {
    testWidgets('renders with default properties', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DiceFace(value: 1)));

      expect(find.byType(DiceFace), findsOneWidget);
    });

    testWidgets('renders with correct size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: DiceFace(value: 3, size: 64.0)),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 64.0);
      expect(sizedBox.height, 64.0);
    });

    testWidgets('uses default size of 48.0', (tester) async {
      await tester.pumpWidget(const MaterialApp(home: DiceFace(value: 1)));

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 48.0);
      expect(sizedBox.height, 48.0);
    });

    testWidgets('throws assertion for value less than 0', (tester) async {
      expect(() => DiceFace(value: -1), throwsA(isA<AssertionError>()));
      expect(() => DiceFace(value: -5), throwsA(isA<AssertionError>()));
    });

    testWidgets('throws assertion for value greater than 6', (tester) async {
      expect(() => DiceFace(value: 7), throwsA(isA<AssertionError>()));
      expect(() => DiceFace(value: 100), throwsA(isA<AssertionError>()));
    });

    testWidgets('throws assertion for non-positive size', (tester) async {
      expect(() => DiceFace(value: 1, size: 0), throwsA(isA<AssertionError>()));
      expect(
        () => DiceFace(value: 1, size: -10),
        throwsA(isA<AssertionError>()),
      );
    });

    group('all valid values render', () {
      for (final value in Iterable<int>.generate(7, (i) => i)) {
        testWidgets('value $value renders without error', (tester) async {
          await tester.pumpWidget(MaterialApp(home: DiceFace(value: value)));

          expect(find.byType(DiceFace), findsOneWidget);
        });
      }
    });

    testWidgets('accepts custom pip color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceFace(value: 4, pipColor: Colors.amber)),
      );

      expect(find.byType(DiceFace), findsOneWidget);
    });

    testWidgets('accepts custom pip radius fraction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: DiceFace(value: 2, pipRadiusFraction: 0.15)),
      );

      expect(find.byType(DiceFace), findsOneWidget);
    });

    testWidgets('supports const constructor', (tester) async {
      // Verify the widget can be declared const.
      const DiceFace dice = DiceFace(value: 1);
      expect(dice.value, 1);
      expect(dice.size, 48.0);
      expect(dice.pipColor, isNull); // derived from theme brightness
      expect(dice.pipRadiusFraction, 0.12);
    });

    testWidgets('renders within a center layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: DiceFace(value: 5, size: 80.0))),
        ),
      );

      expect(find.byType(DiceFace), findsOneWidget);
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(sizedBox.width, 80.0);
      expect(sizedBox.height, 80.0);
    });

    group('blank dice (value 0)', () {
      testWidgets('renders blank dice without error', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: DiceFace(value: 0)));

        expect(find.byType(DiceFace), findsOneWidget);
      });

      testWidgets('blank dice renders with CustomPaint', (tester) async {
        await tester.pumpWidget(const MaterialApp(home: DiceFace(value: 0)));

        expect(find.byType(CustomPaint), findsWidgets);
      });

      testWidgets('blank dice respects custom size', (tester) async {
        await tester.pumpWidget(
          const MaterialApp(home: DiceFace(value: 0, size: 80.0)),
        );

        final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox));
        expect(sizedBox.width, 80.0);
        expect(sizedBox.height, 80.0);
      });

      testWidgets('blank dice supports const constructor', (tester) async {
        const DiceFace dice = DiceFace(value: 0);
        expect(dice.value, 0);
        expect(dice.size, 48.0);
      });
    });

    testWidgets('renders multiple dice faces', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              DiceFace(value: 1),
              SizedBox(width: 8),
              DiceFace(value: 3),
              SizedBox(width: 8),
              DiceFace(value: 5),
            ],
          ),
        ),
      );

      expect(find.byType(DiceFace), findsNWidgets(3));
    });

    group('theme-aware pip color', () {
      Finder findDiceFacePainter() {
        return find.byWidgetPredicate(
          (widget) =>
              widget is CustomPaint && widget.painter is DiceFacePainter,
        );
      }

      testWidgets('uses black pips in light theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: const DiceFace(value: 3),
          ),
        );

        final painter =
            tester.widget<CustomPaint>(findDiceFacePainter()).painter
                as DiceFacePainter;
        expect(painter.pipColor, Colors.black);
      });

      testWidgets('uses white pips in dark theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: Brightness.dark),
            home: const DiceFace(value: 3),
          ),
        );

        final painter =
            tester.widget<CustomPaint>(findDiceFacePainter()).painter
                as DiceFacePainter;
        expect(painter.pipColor, Colors.white);
      });

      testWidgets('explicit pipColor overrides theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(brightness: Brightness.light),
            home: const DiceFace(value: 3, pipColor: Colors.amber),
          ),
        );

        final painter =
            tester.widget<CustomPaint>(findDiceFacePainter()).painter
                as DiceFacePainter;
        expect(painter.pipColor, Colors.amber);
      });
    });
  });
}
