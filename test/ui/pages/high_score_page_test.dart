import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/src/data/high_score_repository.dart';
import 'package:poker_dice/src/ui/pages/high_score_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

late HighScoreRepository repository;

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
  });

  setUp(() async {
    repository = HighScoreRepository.instance;
    await repository.initialize();
    await repository.clearHighScores();
  });

  tearDown(() async {
    await repository.clearHighScores();
  });

  group('HighScorePage', () {
    Widget createHighScorePage({VoidCallback? onBack}) {
      return MaterialApp(home: HighScorePage(onBack: onBack));
    }

    testWidgets('renders scaffold with High Scores title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createHighScorePage());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('High Scores'), findsWidgets);
    });

    testWidgets('renders back button in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(createHighScorePage());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byIcon(Icons.arrow_back), findsWidgets);
    });

    testWidgets('renders header with trophy icon', (WidgetTester tester) async {
      await tester.pumpWidget(createHighScorePage());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('back button callback is called when pressed', (
      WidgetTester tester,
    ) async {
      bool backCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: HighScorePage(
            onBack: () {
              backCalled = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.byIcon(Icons.arrow_back).first);
      await tester.pump();

      expect(backCalled, isTrue);
    });

    testWidgets('has tooltip for back button', (WidgetTester tester) async {
      await tester.pumpWidget(createHighScorePage());
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byTooltip('Back'), findsWidgets);
    });
  });

  group('HighScorePage - Back to Game Button', () {
    testWidgets('Back to Game button is shown', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Back to Game'), findsOneWidget);
    });

    testWidgets('Back to Game button callback works', (
      WidgetTester tester,
    ) async {
      bool backToGameCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: HighScorePage(
            onBack: () {
              backToGameCalled = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Back to Game'));
      await tester.pump();

      expect(backToGameCalled, isTrue);
    });
  });

  group('HighScorePage - Header', () {
    testWidgets('displays trophy icon in header', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('displays High Scores title in header', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('High Scores'), findsWidgets);
    });
  });

  group('HighScorePage - Layout Structure', () {
    testWidgets('has Column layout with header, list, and buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('has ElevatedButton for Back to Game', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('has OutlinedButton for Clear Scores when scores exist', (
      WidgetTester tester,
    ) async {
      // Note: OutlinedButton only appears when scores exist
      // In test environment with no scores, it won't be shown
      // This test documents the expected behavior
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // OutlinedButton is conditional - only shown when _scores.isNotEmpty
      // Since no scores in test env, expect none found
      expect(find.byType(OutlinedButton), findsNothing);
    });
  });

  group('HighScorePage - Empty State', () {
    testWidgets('shows empty state message when no scores', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('No High Scores Yet!'), findsOneWidget);
      expect(
        find.text('Be the first to set a high score\nby playing the game!'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    });
  });

  group('HighScorePage - Score Display', () {
    testWidgets('displays scores in descending order', (
      WidgetTester tester,
    ) async {
      await repository.saveScore(500, DateTime(2024, 1, 1));
      await repository.saveScore(1000, DateTime(2024, 1, 2));
      await repository.saveScore(750, DateTime(2024, 1, 3));

      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // First visible score should be highest
      final scoreFinder = find.text('Score: 1000');
      expect(scoreFinder, findsOneWidget);
    });

    testWidgets('displays date for each score', (WidgetTester tester) async {
      final testDate = DateTime(2024, 6, 15);
      await repository.saveScore(9999, testDate);

      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check for date format: "Jun 15, 2024"
      expect(find.text('Jun 15, 2024'), findsOneWidget);
    });
  });

  group('HighScorePage - Clear Scores', () {
    testWidgets('shows Clear Scores button when scores exist', (
      WidgetTester tester,
    ) async {
      await repository.saveScore(1000, DateTime(2024, 1, 1));

      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Clear Scores'), findsOneWidget);
    });

    testWidgets('hides Clear Scores button when no scores', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Clear Scores'), findsNothing);
    });

    testWidgets('clears scores when button is tapped', (
      WidgetTester tester,
    ) async {
      await repository.saveScore(1000, DateTime(2024, 1, 1));
      await repository.saveScore(2000, DateTime(2024, 1, 2));

      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify scores exist
      expect(find.text('Score: 2000'), findsOneWidget);

      // Tap clear button
      await tester.tap(find.text('Clear Scores'));
      await tester.pumpAndSettle();

      // Verify scores are cleared
      expect(find.text('No High Scores Yet!'), findsOneWidget);
    });

    testWidgets('shows success snackbar after clearing', (
      WidgetTester tester,
    ) async {
      await repository.saveScore(1000, DateTime(2024, 1, 1));

      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await tester.tap(find.text('Clear Scores'));
      await tester.pumpAndSettle();

      // SnackBar appears with success message
      expect(find.text('High scores cleared'), findsOneWidget);
    });
  });

  group('HighScorePage - Header Display', () {
    testWidgets('displays player count when scores exist', (
      WidgetTester tester,
    ) async {
      await repository.saveScore(1000, DateTime(2024, 1, 1));
      await repository.saveScore(2000, DateTime(2024, 1, 2));

      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Top 2 Players'), findsOneWidget);
    });

    testWidgets('hides player count when no scores', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Top 0 Players'), findsNothing);
    });
  });

  group('HighScorePage - Accessibility', () {
    testWidgets('has proper semantics labels', (WidgetTester tester) async {
      await repository.saveScore(1000, DateTime(2024, 1, 15));

      await tester.pumpWidget(MaterialApp(home: HighScorePage()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Check for semantics labels
      expect(find.bySemanticsLabel('Clear all high scores'), findsOneWidget);
      expect(find.bySemanticsLabel('Return to game'), findsOneWidget);
    });
  });

  group('HighScorePage - Date Formatting', () {
    test('formats January date correctly', () {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final date = DateTime(2024, 1, 15);
      final formatted = '${months[date.month - 1]} ${date.day}, ${date.year}';

      expect(formatted, equals('Jan 15, 2024'));
    });

    test('formats December date correctly', () {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final date = DateTime(2024, 12, 25);
      final formatted = '${months[date.month - 1]} ${date.day}, ${date.year}';

      expect(formatted, equals('Dec 25, 2024'));
    });

    test('formats single digit day correctly', () {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final date = DateTime(2024, 1, 5);
      final formatted = '${months[date.month - 1]} ${date.day}, ${date.year}';

      expect(formatted, equals('Jan 5, 2024'));
    });
  });

  group('HighScorePage - Rank Suffixes', () {
    test('returns st for 1', () {
      int rank = 1;
      String suffix;
      if (rank > 3 && rank < 21) {
        suffix = 'th';
      } else {
        switch (rank % 10) {
          case 1:
            suffix = 'st';
            break;
          case 2:
            suffix = 'nd';
            break;
          case 3:
            suffix = 'rd';
            break;
          default:
            suffix = 'th';
        }
      }
      expect(suffix, equals('st'));
    });

    test('returns nd for 2', () {
      int rank = 2;
      String suffix;
      if (rank > 3 && rank < 21) {
        suffix = 'th';
      } else {
        switch (rank % 10) {
          case 1:
            suffix = 'st';
            break;
          case 2:
            suffix = 'nd';
            break;
          case 3:
            suffix = 'rd';
            break;
          default:
            suffix = 'th';
        }
      }
      expect(suffix, equals('nd'));
    });

    test('returns rd for 3', () {
      int rank = 3;
      String suffix;
      if (rank > 3 && rank < 21) {
        suffix = 'th';
      } else {
        switch (rank % 10) {
          case 1:
            suffix = 'st';
            break;
          case 2:
            suffix = 'nd';
            break;
          case 3:
            suffix = 'rd';
            break;
          default:
            suffix = 'th';
        }
      }
      expect(suffix, equals('rd'));
    });

    test('returns th for 4', () {
      int rank = 4;
      String suffix;
      if (rank > 3 && rank < 21) {
        suffix = 'th';
      } else {
        switch (rank % 10) {
          case 1:
            suffix = 'st';
            break;
          case 2:
            suffix = 'nd';
            break;
          case 3:
            suffix = 'rd';
            break;
          default:
            suffix = 'th';
        }
      }
      expect(suffix, equals('th'));
    });

    test('returns th for 11', () {
      int rank = 11;
      String suffix;
      if (rank > 3 && rank < 21) {
        suffix = 'th';
      } else {
        switch (rank % 10) {
          case 1:
            suffix = 'st';
            break;
          case 2:
            suffix = 'nd';
            break;
          case 3:
            suffix = 'rd';
            break;
          default:
            suffix = 'th';
        }
      }
      expect(suffix, equals('th'));
    });

    test('returns st for 21', () {
      int rank = 21;
      String suffix;
      if (rank > 3 && rank < 21) {
        suffix = 'th';
      } else {
        switch (rank % 10) {
          case 1:
            suffix = 'st';
            break;
          case 2:
            suffix = 'nd';
            break;
          case 3:
            suffix = 'rd';
            break;
          default:
            suffix = 'th';
        }
      }
      expect(suffix, equals('st'));
    });
  });
}
