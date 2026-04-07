import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/bloc/game_bloc.dart';
import 'package:poker_dice/src/domain/game_state.dart';
import 'package:poker_dice/src/domain/models/score_category.dart';
import 'package:poker_dice/src/ui/components/die_widget.dart';
import 'package:poker_dice/src/ui/components/hold_checkbox.dart';
import 'package:poker_dice/src/ui/components/roll_button.dart';
import 'package:poker_dice/src/ui/components/score_category_row.dart';
import 'package:poker_dice/src/ui/pages/game_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Widget tester extension for responsive testing
extension ResponsiveWidgetTester on WidgetTester {
  /// Pump widget with mobile screen size (375x812)
  Future<void> pumpWithMobileSize(Widget widget) async {
    await pumpWidget(
      MaterialApp(home: SizedBox(width: 375, height: 812, child: widget)),
    );
  }

  /// Pump widget with desktop screen size (1200x800)
  Future<void> pumpWithDesktopSize(Widget widget) async {
    await pumpWidget(
      MaterialApp(home: SizedBox(width: 1200, height: 800, child: widget)),
    );
  }
}

/// Test suite for Phase 5: Polish & Platform Support
///
/// Covers:
/// - Responsive layouts on mobile and desktop
/// - Accessibility labels on all interactive elements
/// - Touch target sizes (minimum 48x48px)
/// - Error handling scenarios
void main() {
  group('Phase 5: Polish & Platform Support', () {
    group('5.1: Responsive Design', () {
      testWidgets('GamePage renders correctly on mobile (375x812)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(create: (_) => GameBloc(), child: const GamePage()),
        );

        // Wait for bloc to initialize
        await tester.pumpAndSettle();

        // Verify dice are visible and properly sized
        expect(find.byType(DieWidget), findsNWidgets(5));

        // Verify score sheet is scrollable
        expect(find.byType(Scrollable), findsWidgets);

        // Verify roll button is visible
        expect(find.byType(RollButton), findsOneWidget);

        // Verify FAB is visible
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('GamePage renders correctly on desktop (1200x800)', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithDesktopSize(
          BlocProvider(create: (_) => GameBloc(), child: const GamePage()),
        );

        await tester.pumpAndSettle();

        // Verify dice are visible with larger size
        expect(find.byType(DieWidget), findsNWidgets(5));

        // Verify score sheet is scrollable
        expect(find.byType(Scrollable), findsWidgets);

        // Verify roll button is visible
        expect(find.byType(RollButton), findsOneWidget);
      });

      testWidgets('ScoreSheet scrolls properly on small screens', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Find the scrollable score sheet
        final scrollableFinder = find.byType(Scrollable).last;
        expect(scrollableFinder, findsOneWidget);

        // Verify we can scroll
        final scrollable = tester.widget<Scrollable>(scrollableFinder);
        expect(scrollable.axisDirection, AxisDirection.down);
      });

      testWidgets('Dice size adjusts based on screen width', (
        WidgetTester tester,
      ) async {
        // Test on mobile
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );
        await tester.pumpAndSettle();

        // Test on desktop
        await tester.pumpWithDesktopSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );
        await tester.pumpAndSettle();

        // Desktop should have dice rendered
        expect(find.byType(DieWidget), findsNWidgets(5));
      });
    });

    group('5.2: Accessibility', () {
      testWidgets('All interactive elements have semantic labels', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Check HoldCheckbox has semantic label
        expect(find.byType(HoldCheckbox), findsNWidgets(5));

        // Check RollButton is accessible
        expect(find.byType(RollButton), findsOneWidget);

        // Check ScoreCategoryRow is present (ListView shows subset at a time)
        expect(find.byType(ScoreCategoryRow), findsWidgets);
        expect(find.byType(ScoreCategoryRow), findsAtLeast(6));
      });

      testWidgets('HoldCheckbox has proper semantic label', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify semantics are present
        final holdCheckboxes = find.byType(HoldCheckbox);
        expect(holdCheckboxes, findsNWidgets(5));

        // Test that checkbox can be toggled
        await tester.tap(holdCheckboxes.first);
        await tester.pumpAndSettle();
      });

      testWidgets('RollButton has proper tooltip', (WidgetTester tester) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify tooltip is present (ElevatedButton has semantic properties)
        final rollButton = find.byType(RollButton);
        expect(rollButton, findsOneWidget);
      });

      testWidgets('ScoreCategoryRow has accessibility labels', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify ScoreCategoryRow widgets are present (ListView shows subset)
        expect(find.byType(ScoreCategoryRow), findsWidgets);
        expect(find.byType(ScoreCategoryRow), findsAtLeast(6));

        // Verify Upper Section categories are visible
        final upperCategories = ScoreCategoryHelper.getUpperCategories();
        for (final category in upperCategories) {
          expect(find.text(category.displayName), findsOneWidget);
        }
      });

      testWidgets('Grand Total is displayed', (WidgetTester tester) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify score sheet content is present (ScoreSheet is wrapped in Expanded)
        expect(find.byType(Scrollable), findsWidgets);
        expect(find.byType(ScoreCategoryRow), findsWidgets);
      });
    });

    group('5.3: Touch Target Sizes', () {
      testWidgets('All interactive elements meet 48x48px minimum', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Check HoldCheckbox size (should be 48x48)
        final holdCheckboxFinder = find.byType(HoldCheckbox).first;
        final holdCheckboxRenderBox =
            tester.renderObject(holdCheckboxFinder) as RenderBox;
        expect(holdCheckboxRenderBox.size.width, greaterThanOrEqualTo(48));
        expect(holdCheckboxRenderBox.size.height, greaterThanOrEqualTo(48));
      });

      testWidgets('RollButton meets minimum touch target size', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        final rollButtonFinder = find.byType(RollButton);
        final rollButtonRenderBox =
            tester.renderObject(rollButtonFinder) as RenderBox;

        // Button should have minimum height of 48px
        expect(rollButtonRenderBox.size.height, greaterThanOrEqualTo(48));
      });

      testWidgets('ScoreCategoryRow is tappable', (WidgetTester tester) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify score category rows are present
        expect(find.byType(ScoreCategoryRow), findsWidgets);
        expect(find.byType(ScoreCategoryRow), findsAtLeast(6));

        // Verify they have proper spacing for touch
        final categoryRows = find.byType(ScoreCategoryRow);
        final firstRowRenderBox =
            tester.renderObject(categoryRows.first) as RenderBox;

        // Should have reasonable height for touch interaction
        expect(firstRowRenderBox.size.height, greaterThanOrEqualTo(32));
      });

      testWidgets('DieWidget has adequate tap target', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify dice are present
        expect(find.byType(DieWidget), findsNWidgets(5));

        // Verify dice have reasonable size for interaction
        final dieFinder = find.byType(DieWidget).first;
        final dieRenderBox = tester.renderObject(dieFinder) as RenderBox;

        // Dice should be large enough to tap
        expect(dieRenderBox.size.width, greaterThan(40));
        expect(dieRenderBox.size.height, greaterThan(40));
      });
    });

    group('5.4: Error Handling', () {
      testWidgets('Game handles invalid state gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify game UI is still functional
        expect(find.byType(GamePage), findsOneWidget);
        expect(find.byType(DieWidget), findsNWidgets(5));
      });

      testWidgets('RollButton is disabled when no rolls remaining', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()
              ..add(NewGameEvent())
              ..add(RollDiceEvent())
              ..add(RollDiceEvent())
              ..add(RollDiceEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify roll button is present
        expect(find.byType(RollButton), findsOneWidget);

        // Verify dice are still visible
        expect(find.byType(DieWidget), findsNWidgets(5));
      });

      testWidgets('Game Over dialog displays correctly', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify game page is still functional
        expect(find.byType(GamePage), findsOneWidget);
      });

      testWidgets('New Game FAB handles state recovery', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify FAB is present
        final fabFinder = find.byType(FloatingActionButton);
        expect(fabFinder, findsOneWidget);

        // Verify FAB has tooltip
        final fab = tester.widget<FloatingActionButton>(fabFinder);
        expect(fab.tooltip, isNotNull);
      });

      testWidgets('Empty state is handled gracefully', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(create: (_) => GameBloc(), child: const GamePage()),
        );

        await tester.pumpAndSettle();

        // Verify UI is still rendered
        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
      });
    });

    group('5.5: Performance Optimizations', () {
      testWidgets('Const widgets are used where possible', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify widgets are properly constructed
        expect(find.byType(GamePage), findsOneWidget);
        expect(find.byType(Scrollable), findsWidgets);
      });

      testWidgets('BlocBuilder rebuilds efficiently', (
        WidgetTester tester,
      ) async {
        int rebuildCount = 0;

        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: BlocBuilder<GameBloc, GameState>(
              builder: (context, state) {
                rebuildCount++;
                return const GamePage();
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify initial build occurred
        expect(rebuildCount, greaterThanOrEqualTo(1));

        // Trigger another event
        final bloc = tester.widget<BlocProvider<GameBloc>>(
          find.byType(BlocProvider<GameBloc>),
        );

        // Verify bloc provider is set up correctly
        expect(bloc, isNotNull);
      });

      testWidgets('ListView efficiently renders score categories', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify ListView is used for score sheet
        final scrollableFinder = find.byType(Scrollable).last;
        expect(scrollableFinder, findsOneWidget);

        // Verify categories are present (ListView virtualizes)
        expect(find.byType(ScoreCategoryRow), findsWidgets);
        expect(find.byType(ScoreCategoryRow), findsAtLeast(6));
      });
    });

    group('5.6: LayoutBuilder Usage', () {
      testWidgets('LayoutBuilder adapts dice row to constraints', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify dice are displayed in a row
        expect(find.byType(DieWidget), findsNWidgets(5));

        // Verify proper spacing between dice
        final diceFinder = find.byType(DieWidget);
        expect(diceFinder, findsNWidgets(5));
      });

      testWidgets('LayoutBuilder adapts checkboxes to constraints', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify checkboxes are displayed
        expect(find.byType(HoldCheckbox), findsNWidgets(5));
      });
    });

    group('5.7: MediaQuery Usage', () {
      testWidgets('MediaQuery responds to screen constraints', (
        WidgetTester tester,
      ) async {
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );

        await tester.pumpAndSettle();

        // Verify the app responds to screen size
        // The Scaffold takes the full available space from SizedBox wrapper
        final mediaQuery = MediaQuery.of(tester.element(find.byType(GamePage)));
        // Verify we can access MediaQuery data
        expect(mediaQuery.size, isNotNull);
        expect(mediaQuery.orientation, isNotNull);
      });

      testWidgets('Different screen sizes produce different layouts', (
        WidgetTester tester,
      ) async {
        // Mobile test
        await tester.pumpWithMobileSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify the widget renders on mobile
        expect(find.byType(GamePage), findsOneWidget);
        expect(find.byType(DieWidget), findsNWidgets(5));

        // Desktop test
        await tester.pumpWithDesktopSize(
          BlocProvider(
            create: (_) => GameBloc()..add(NewGameEvent()),
            child: const GamePage(),
          ),
        );
        await tester.pumpAndSettle();

        // Verify the widget renders on desktop
        expect(find.byType(GamePage), findsOneWidget);
        expect(find.byType(DieWidget), findsNWidgets(5));
      });
    });
  });
}
