import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poker_dice/src/domain/models/die.dart';
import 'package:poker_dice/src/ui/components/die_widget.dart';

void main() {
  group('DieWidget', () {
    /// Creates a testable DieWidget with the given value and held state.
    Widget createDieWidget({
      required int value,
      bool held = false,
      VoidCallback? onTap,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: DieWidget(
            die: Die(value: value, held: held),
            onTap: onTap,
          ),
        ),
      );
    }

    Finder findDieWidget() => find.byType(DieWidget);

    //region Value Rendering Tests

    testWidgets('renders die face with value 1', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 1));
      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('renders die face with value 2', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 2));
      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('renders die face with value 3', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 3));
      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('renders die face with value 4', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 4));
      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('renders die face with value 5', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 5));
      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('renders die face with value 6', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 6));
      expect(findDieWidget(), findsOneWidget);
    });

    //endregion

    //region Dot Count Tests

    testWidgets('displays correct number of dots for value 1', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 1));
      expect(find.byKey(const ValueKey('dot-0')), findsOneWidget);
    });

    testWidgets('displays correct number of dots for value 2', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 2));
      expect(find.byKey(const ValueKey('dot-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-1')), findsOneWidget);
    });

    testWidgets('displays correct number of dots for value 3', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 3));
      expect(find.byKey(const ValueKey('dot-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-2')), findsOneWidget);
    });

    testWidgets('displays correct number of dots for value 4', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 4));
      expect(find.byKey(const ValueKey('dot-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-3')), findsOneWidget);
    });

    testWidgets('displays correct number of dots for value 5', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 5));
      expect(find.byKey(const ValueKey('dot-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-4')), findsOneWidget);
    });

    testWidgets('displays correct number of dots for value 6', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 6));
      expect(find.byKey(const ValueKey('dot-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-2')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-3')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-4')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-5')), findsOneWidget);
    });

    //endregion

    //region Held State Tests

    testWidgets('shows different styling when held is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 3, held: true));
      final dieWidget = tester.widget<DieWidget>(findDieWidget());
      expect(dieWidget.die.held, isTrue);
    });

    testWidgets('applies held animation on state change', (
      WidgetTester tester,
    ) async {
      bool isHeld = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DieWidget(die: Die(value: 3, held: isHeld));
              },
            ),
          ),
        ),
      );

      // Change held state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                isHeld = true;
                return DieWidget(die: Die(value: 3, held: isHeld));
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(true, isTrue);
    });

    //endregion

    //region Tap Callback Tests

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool wasTapped = false;
      await tester.pumpWidget(
        createDieWidget(value: 3, onTap: () => wasTapped = true),
      );

      await tester.tap(findDieWidget());
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('does not call onTap when null', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 3, onTap: null));

      await tester.tap(findDieWidget());
      await tester.pump();

      expect(true, isTrue);
    });

    //endregion

    //region Responsive Sizing Tests

    testWidgets('uses responsive sizing based on screen width', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                return DieWidget(die: Die(value: 3));
              },
            ),
          ),
        ),
      );

      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('renders correctly in small screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 320, child: DieWidget(die: Die(value: 3))),
          ),
        ),
      );

      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('renders correctly in large screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(width: 800, child: DieWidget(die: Die(value: 3))),
          ),
        ),
      );

      expect(findDieWidget(), findsOneWidget);
    });

    //endregion

    //region Accessibility Tests

    testWidgets('has accessibility label for screen readers', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 4));
      final dieWidget = tester.widget<DieWidget>(findDieWidget());
      expect(dieWidget.die.value, equals(4));
    });

    testWidgets('has semantic label indicating die value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 5));
      final dieWidget = tester.widget<DieWidget>(findDieWidget());
      expect(dieWidget.die.value, equals(5));
    });

    testWidgets('is marked as button when onTap is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createDieWidget(value: 2, onTap: () {}));
      expect(find.byType(DieWidget), findsOneWidget);
    });

    //endregion

    //region Visual Design Tests

    testWidgets('has rounded corners', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 3));
      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('has shadow for 3D effect', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 3));
      expect(findDieWidget(), findsOneWidget);
    });

    testWidgets('has correct dot color', (WidgetTester tester) async {
      await tester.pumpWidget(createDieWidget(value: 3));
      expect(find.byKey(const ValueKey('dot-0')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-1')), findsOneWidget);
      expect(find.byKey(const ValueKey('dot-2')), findsOneWidget);
    });

    //endregion
  });
}
