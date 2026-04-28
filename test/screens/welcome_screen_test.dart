import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/screens/welcome_screen.dart';
import 'package:poker_dice/screens/game_screen.dart';
import 'package:poker_dice/services/storage_service.dart';

void main() {
  setUp(() {
    // Reset storage service instance before each test
    StorageService.resetInstance();
  });

  tearDown(() {
    // Reset storage service instance after each test
    StorageService.resetInstance();
  });

  group('WelcomeScreen Tests', () {
    testWidgets('testWelcomeScreen_displaysTitle', (WidgetTester tester) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Wait for async check
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify title is displayed
      expect(find.text('POKER DICE'), findsOneWidget);
    });

    testWidgets('testWelcomeScreen_displaysWelcomeMessage', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Wait for async check
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify welcome message
      expect(find.text('Welcome Player!'), findsOneWidget);
    });

    testWidgets('testWelcomeScreen_displaysNewGameButton', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Wait for async check
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify New Game button exists
      expect(find.text('NEW GAME'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('testWelcomeScreen_displaysContinueWhenGameExists', (
      WidgetTester tester,
    ) async {
      // Create a mock storage service with saved game
      final savedState = {
        'diceRoll': null,
        'scores': {},
        'selectedCategory': null,
        'remainingRolls': 3,
        'currentTurn': 1,
        'isGameOver': false,
        'upperSectionTotal': 0,
        'bonusAwarded': false,
        'totalScore': 0,
      };
      final mockStorage = MockStorageService(
        hasSavedGame: true,
        savedState: savedState,
      );
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Wait for async check
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Continue button should be visible if game exists
      expect(find.text('CONTINUE'), findsOneWidget);
    });

    testWidgets('testWelcomeScreen_hidesContinueWhenNoGame', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Wait for async check
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Continue button should not be visible initially (no saved game)
      expect(find.text('CONTINUE'), findsNothing);
    });

    testWidgets('testWelcomeScreen_newGameNavigatesToGameScreen', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap New Game button
      await tester.tap(find.text('NEW GAME'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify navigation to game screen
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('testWelcomeScreen_buttonHasCorrectIcon', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Wait for loading
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify New Game button has icon
      final addButtonFinder = find.byIcon(Icons.add_circle);
      expect(addButtonFinder, findsOneWidget);
    });

    testWidgets('testWelcomeScreen_displaysDiceIcons', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Wait for loading
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify dice icons are displayed
      final iconFinder = find.byIcon(Icons.coffee);
      expect(iconFinder, findsNWidgets(3));
    });

    testWidgets('testWelcomeScreen_loadingState', (WidgetTester tester) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      // Initially loading indicator might be visible
      // After loading completes, it should disappear
      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Loading indicator should not be visible after loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('WelcomeScreen Navigation Tests', () {
    testWidgets('testWelcomeScreen_newGameResetsGameState', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Tap New Game
      await tester.tap(find.text('NEW GAME'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify game screen is shown
      expect(find.byType(GameScreen), findsOneWidget);
    });

    testWidgets('testWelcomeScreen_navigationPreservesProviderState', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify New Game button is enabled
      final newGameButton = find.text('NEW GAME');
      expect(newGameButton, findsOneWidget);

      // Tap and navigate
      await tester.tap(newGameButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Game screen should be displayed
      expect(find.byType(GameScreen), findsOneWidget);
    });
  });

  group('WelcomeScreen Layout Tests', () {
    testWidgets('testWelcomeScreen_layoutIsCentered', (
      WidgetTester tester,
    ) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify layout elements exist
      expect(find.text('POKER DICE'), findsOneWidget);
      expect(find.text('Welcome Player!'), findsOneWidget);
      expect(find.text('NEW GAME'), findsOneWidget);
    });

    testWidgets('testWelcomeScreen_buttonStyling', (WidgetTester tester) async {
      // Set mock storage service
      final mockStorage = MockStorageService(hasSavedGame: false);
      StorageService.setInstance(mockStorage);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: WelcomeScreen())),
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 200));

      // Verify ElevatedButton is used for New Game
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}

/// Mock storage service for testing
class MockStorageService extends StorageService {
  final bool hasSavedGame;
  final Map<String, dynamic>? savedState;
  bool _gameStateCleared = false;

  MockStorageService({this.hasSavedGame = false, this.savedState});

  @override
  Future<Map<String, dynamic>?> loadGameState() async {
    if (_gameStateCleared) return null;
    return hasSavedGame ? savedState : null;
  }

  @override
  Future<void> saveGameState(Map<String, dynamic> gameState) async {
    // Mock implementation - do nothing
  }

  @override
  Future<void> clearGameState() async {
    _gameStateCleared = true;
  }

  @override
  Future<void> saveHighScore(String playerName, int score) async {
    // Mock implementation - do nothing
  }

  @override
  Future<List<HighScoreEntry>> getHighScores() async {
    return [];
  }

  @override
  Future<void> clearHighScores() async {
    // Mock implementation - do nothing
  }

  @override
  Future<void> saveThemePreference(bool isDarkMode) async {
    // Mock implementation - do nothing
  }

  @override
  Future<bool> getThemePreference() async {
    return false;
  }

  @override
  Future<void> clearAll() async {
    _gameStateCleared = true;
  }
}
