import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:poker_dice/src/ui/utils/responsive_layout.dart';

void main() {
  group('ResponsiveLayout', () {
    test('mobileMaxWidth constant is 600', () {
      expect(ResponsiveLayout.mobileMaxWidth, equals(600));
    });

    test('tabletMaxWidth constant is 1024', () {
      expect(ResponsiveLayout.tabletMaxWidth, equals(1024));
    });

    test('mobileMaxWidth is less than tabletMaxWidth', () {
      expect(
        ResponsiveLayout.mobileMaxWidth,
        lessThan(ResponsiveLayout.tabletMaxWidth),
      );
    });

    group('isMobile', () {
      testWidgets('returns true for screens <= 600px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(500, 800)),
              child: Builder(
                builder: (context) {
                  final isMobile = ResponsiveLayout.isMobile(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isMobile.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('true'), findsOneWidget);
      });

      testWidgets('returns true for screen exactly 600px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(600, 800)),
              child: Builder(
                builder: (context) {
                  final isMobile = ResponsiveLayout.isMobile(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isMobile.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('true'), findsOneWidget);
      });

      testWidgets('returns false for screens > 600px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(700, 800)),
              child: Builder(
                builder: (context) {
                  final isMobile = ResponsiveLayout.isMobile(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isMobile.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('returns false for tablet-sized screens', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1000)),
              child: Builder(
                builder: (context) {
                  final isMobile = ResponsiveLayout.isMobile(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isMobile.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('returns false for desktop-sized screens', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Builder(
                builder: (context) {
                  final isMobile = ResponsiveLayout.isMobile(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isMobile.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });
    });

    group('isTablet', () {
      testWidgets('returns false for screens <= 600px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(500, 800)),
              child: Builder(
                builder: (context) {
                  final isTablet = ResponsiveLayout.isTablet(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isTablet.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('returns true for screens > 600px and <= 1024px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1000)),
              child: Builder(
                builder: (context) {
                  final isTablet = ResponsiveLayout.isTablet(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isTablet.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('true'), findsOneWidget);
      });

      testWidgets('returns true for screen exactly 1024px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1024, 800)),
              child: Builder(
                builder: (context) {
                  final isTablet = ResponsiveLayout.isTablet(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isTablet.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('true'), findsOneWidget);
      });

      testWidgets('returns false for screens > 1024px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Builder(
                builder: (context) {
                  final isTablet = ResponsiveLayout.isTablet(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isTablet.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });
    });

    group('isDesktop', () {
      testWidgets('returns false for screens <= 600px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(500, 800)),
              child: Builder(
                builder: (context) {
                  final isDesktop = ResponsiveLayout.isDesktop(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isDesktop.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('returns false for screens <= 1024px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1000)),
              child: Builder(
                builder: (context) {
                  final isDesktop = ResponsiveLayout.isDesktop(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isDesktop.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('returns false for screen exactly 1024px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1024, 800)),
              child: Builder(
                builder: (context) {
                  final isDesktop = ResponsiveLayout.isDesktop(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isDesktop.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('false'), findsOneWidget);
      });

      testWidgets('returns true for screens > 1024px', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Builder(
                builder: (context) {
                  final isDesktop = ResponsiveLayout.isDesktop(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isDesktop.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('true'), findsOneWidget);
      });

      testWidgets('returns true for large desktop screens', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1920, 1080)),
              child: Builder(
                builder: (context) {
                  final isDesktop = ResponsiveLayout.isDesktop(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(isDesktop.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('true'), findsOneWidget);
      });
    });

    group('getPadding', () {
      testWidgets('returns 12px padding for mobile', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 800)),
              child: ResponsiveContainer(child: const Text('Test')),
            ),
          ),
        );

        final paddingFinder = find.byType(Padding);
        expect(paddingFinder, findsOneWidget);

        final padding = tester.widget<Padding>(paddingFinder).padding;
        expect(padding, equals(const EdgeInsets.all(12)));
      });

      testWidgets('returns 24px padding for tablet', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1000)),
              child: ResponsiveContainer(child: const Text('Test')),
            ),
          ),
        );

        final paddingFinder = find.byType(Padding);
        expect(paddingFinder, findsOneWidget);

        final padding = tester.widget<Padding>(paddingFinder).padding;
        expect(padding, equals(const EdgeInsets.all(24)));
      });

      testWidgets('returns 32px padding for desktop', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: ResponsiveContainer(child: const Text('Test')),
            ),
          ),
        );

        final paddingFinder = find.byType(Padding);
        expect(paddingFinder, findsOneWidget);

        final padding = tester.widget<Padding>(paddingFinder).padding;
        expect(padding, equals(const EdgeInsets.all(32)));
      });
    });

    group('getMaxWidth', () {
      testWidgets('returns infinity for mobile', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 800)),
              child: Builder(
                builder: (context) {
                  final maxWidth = ResponsiveLayout.getMaxWidth(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(
                      maxWidth.isInfinite ? 'inf' : maxWidth.toString(),
                    ),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('inf'), findsOneWidget);
      });

      testWidgets('returns 600 for tablet', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1000)),
              child: Builder(
                builder: (context) {
                  final maxWidth = ResponsiveLayout.getMaxWidth(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(maxWidth.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('600.0'), findsOneWidget);
      });

      testWidgets('returns 800 for desktop', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Builder(
                builder: (context) {
                  final maxWidth = ResponsiveLayout.getMaxWidth(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(maxWidth.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('800.0'), findsOneWidget);
      });
    });

    group('getDiceSize', () {
      testWidgets('returns 50 for very small screens', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(300, 600)),
              child: Builder(
                builder: (context) {
                  final diceSize = ResponsiveLayout.getDiceSize(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(diceSize.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('50.0'), findsOneWidget);
      });

      testWidgets('returns 60 for small screens', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(500, 800)),
              child: Builder(
                builder: (context) {
                  final diceSize = ResponsiveLayout.getDiceSize(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(diceSize.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('60.0'), findsOneWidget);
      });

      testWidgets('returns 80 for tablet screens', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1000)),
              child: Builder(
                builder: (context) {
                  final diceSize = ResponsiveLayout.getDiceSize(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(diceSize.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('80.0'), findsOneWidget);
      });

      testWidgets('returns 100 for desktop screens', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Builder(
                builder: (context) {
                  final diceSize = ResponsiveLayout.getDiceSize(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(diceSize.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('100.0'), findsOneWidget);
      });
    });

    group('getScoreFontSize', () {
      testWidgets('returns 16 for mobile', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(400, 800)),
              child: Builder(
                builder: (context) {
                  final fontSize = ResponsiveLayout.getScoreFontSize(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(fontSize.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('16.0'), findsOneWidget);
      });

      testWidgets('returns 18 for tablet', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(800, 1000)),
              child: Builder(
                builder: (context) {
                  final fontSize = ResponsiveLayout.getScoreFontSize(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(fontSize.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('18.0'), findsOneWidget);
      });

      testWidgets('returns 20 for desktop', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(size: Size(1200, 800)),
              child: Builder(
                builder: (context) {
                  final fontSize = ResponsiveLayout.getScoreFontSize(context);
                  return SizedBox(
                    width: 100,
                    height: 100,
                    child: Text(fontSize.toString()),
                  );
                },
              ),
            ),
          ),
        );

        expect(find.text('20.0'), findsOneWidget);
      });
    });
  });

  group('ResponsiveWrapper', () {
    testWidgets('displays child directly when within max width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveWrapper(maxWidth: 1000, child: const Text('Test')),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('centers child when exceeding max width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return ResponsiveWrapper(
                  maxWidth: 100,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    child: const Text('Test'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('applies constraints when exceeding max width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveWrapper(
              maxWidth: 200,
              child: Container(
                width: 500,
                height: 100,
                color: Colors.red,
                child: const Text('Test'),
              ),
            ),
          ),
        ),
      );

      // The container should be constrained to maxWidth
      expect(find.byType(Container), findsOneWidget);
    });
  });

  group('ResponsiveContainer', () {
    testWidgets('applies padding to child', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: const ResponsiveContainer(child: Text('Test'))),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.byType(Padding), findsOneWidget);
    });

    testWidgets('renders child correctly', (WidgetTester tester) async {
      const testText = 'Hello Responsive';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const ResponsiveContainer(child: Text(testText)),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });
  });
}
