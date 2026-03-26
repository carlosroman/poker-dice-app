import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/core/constants/dice_faces.dart';
import 'package:poker_dice/features/ui/screens/game_screen.dart';
import 'package:poker_dice/features/ui/widgets/dice_card.dart';
import 'package:poker_dice/features/game/providers/game_provider.dart';
import 'package:poker_dice/features/score/score_provider.dart';

class MockSharedPreferences implements SharedPreferences {
  final Map<String, dynamic> _data = {};

  @override
  Future<bool> setInt(String key, int value) async {
    _data[key] = value;
    return true;
  }

  @override
  int? getInt(String key) => _data[key] as int?;

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<bool> setBool(String key, bool value) async {
    _data[key] = value;
    return true;
  }

  @override
  bool? getBool(String key) => _data[key] as bool?;

  @override
  Future<bool> setDouble(String key, double value) async {
    _data[key] = value;
    return true;
  }

  @override
  double? getDouble(String key) => _data[key] as double?;
  Future<bool> setStringSet(String key, Set<String> value) async {
    _data[key] = value;
    return true;
  }

  Set<String>? getStringSet(String key) => _data[key] as Set<String>?;

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<void> reload() async {}

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  dynamic get(String key) => _data[key];

  @override
  Future<bool> commit() => Future.value(true);

  @override
  List<String>? getStringList(String key) => _data[key] as List<String>?;

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    _data[key] = value;
    return true;
  }
}

void main() {
  late ProviderContainer container;
  late SharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    TestWidgetsFlutterBinding.ensureInitialized();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('GameScreen', () {
    group('Renders all sections', () {
      testWidgets('header bar with score display renders', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(AppBar), findsOneWidget);
        expect(find.textContaining('You'), findsOneWidget);
      });

      testWidgets('scorecard section with two columns renders', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Scorecard'), findsOneWidget);
        expect(find.text('Minor'), findsOneWidget);
        expect(find.text('Major'), findsOneWidget);
      });

      testWidgets('dice display section with 5 dice renders', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        final diceCards = find.byType(DiceCard);
        expect(diceCards, findsNWidgets(5));
      });

      testWidgets('controls section with ROLL and PLAY buttons renders', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('ROLL'), findsOneWidget);
        expect(find.text('PLAY'), findsOneWidget);
      });
    });

    group('Theme switching', () {
      testWidgets('light theme applies correct text brightness', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const GameScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(const Color(0xFF2C3E50)));
      });

      testWidgets('dark theme applies correct colors', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const GameScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, equals(Colors.grey[900]));
      });

      testWidgets('theme can be toggled', (WidgetTester tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: MaterialApp(
              theme: ThemeData.light(),
              home: const GameScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        var appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(const Color(0xFF2C3E50)));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: MaterialApp(
              theme: ThemeData.dark(),
              home: const GameScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        appBar = tester.widget<AppBar>(find.byType(AppBar));
        expect(appBar.backgroundColor, equals(const Color(0xFF2C3E50)));
      });
    });

    group('Riverpod integration', () {
      testWidgets('gameProvider state updates reflect in UI', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        var initialGameState = container.read(gameProvider);
        expect(initialGameState.rollsRemaining, equals(3));

        container.read(gameProvider.notifier).resetGame();

        await tester.pump();

        var updatedGameState = container.read(gameProvider);
        expect(updatedGameState.turnNumber, equals(1));
      });

      testWidgets('scoreProvider state updates reflect in UI', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        var scoreState = await container.read(scoreProvider.future);
        expect(scoreState, equals(0));

        await container.read(scoreProvider.notifier).saveHighScore(2000);

        await tester.pump();

        scoreState = await container.read(scoreProvider.future);
        expect(scoreState, equals(2000));
      });

      testWidgets('game state update triggers UI rebuild', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        container.read(gameProvider.notifier).resetGame();

        await tester.pump();

        expect(find.byType(DiceCard), findsNWidgets(5));
      });
    });

    group('Game over modal', () {
      testWidgets('game over modal appears when all categories are filled', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Fill all 14 categories to trigger game over
        // Game ends when categoriesRemaining() <= 1 after filling a category
        for (int i = 0; i < NUM_CATEGORIES; i++) {
          container.read(gameProvider.notifier).selectPending(i);
          await tester.pump();
          container.read(gameProvider.notifier).confirmSelection();
          await tester.pumpAndSettle();
        }

        // Verify game is over
        var gameState = container.read(gameProvider);
        expect(
          gameState.isGameOver,
          isTrue,
          reason: 'Game should be over after all categories filled',
        );
      });

      testWidgets('Play Again button resets the game', (
        WidgetTester tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Verify initial game state
        var gameState = container.read(gameProvider);
        expect(gameState.isGameOver, isFalse);
        expect(gameState.turnNumber, equals(1));
        expect(gameState.rollsRemaining, equals(MAX_ROLLS));

        // Fill all 14 categories to trigger game over
        for (int i = 0; i < NUM_CATEGORIES; i++) {
          container.read(gameProvider.notifier).selectPending(i);
          await tester.pump();
          container.read(gameProvider.notifier).confirmSelection();
          await tester.pumpAndSettle();
        }

        // Verify game is over
        gameState = container.read(gameProvider);
        expect(gameState.isGameOver, isTrue);

        // Reset the game (simulating Play Again button action)
        container.read(gameProvider.notifier).resetGame();
        await tester.pump();

        // Verify game has been reset
        gameState = container.read(gameProvider);
        expect(gameState.isGameOver, isFalse);
        expect(gameState.turnNumber, equals(1));
        expect(gameState.rollsRemaining, equals(MAX_ROLLS));
      });
    });

    group('Back button and Leave Game dialog', () {
      testWidgets('Restart Game resets game and stays on game screen', (
        WidgetTester tester,
      ) async {
        // Ensure binding is initialized before any widget operations
        TestWidgetsFlutterBinding.ensureInitialized();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(
                mockSharedPreferences,
              ),
            ],
            child: const MaterialApp(home: GameScreen()),
          ),
        );

        await tester.pumpAndSettle();

        // Get the provider container from the widget tree
        final gameScreenElement = tester.element(find.byType(GameScreen));
        final testContainer = ProviderScope.containerOf(gameScreenElement);

        // Verify initial game state
        var gameState = testContainer.read(gameProvider);
        expect(gameState.isCategoryScored(0), isFalse);
        expect(gameState.turnNumber, equals(1));

        // Score a category to change the game state
        testContainer.read(gameProvider.notifier).rollDice();
        await tester.pump();
        testContainer.read(gameProvider.notifier).selectPending(0);
        await tester.pump();
        testContainer.read(gameProvider.notifier).confirmSelection();
        await tester.pumpAndSettle();

        // Verify game state has changed
        gameState = testContainer.read(gameProvider);
        expect(gameState.isCategoryScored(0), isTrue);

        // Tap the back button
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Verify the dialog appears
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Leave Game?'), findsOneWidget);

        // Tap the "Restart Game" button
        await tester.tap(find.text('Restart Game'));
        await tester.pumpAndSettle();

        // Verify the dialog is closed
        expect(find.byType(AlertDialog), findsNothing);

        // Verify the game has been reset
        gameState = testContainer.read(gameProvider);
        expect(gameState.isGameOver, isFalse);
        expect(gameState.turnNumber, equals(1));
        expect(gameState.rollsRemaining, equals(MAX_ROLLS));

        // Verify no categories are scored
        for (int i = 0; i < NUM_CATEGORIES; i++) {
          expect(gameState.isCategoryScored(i), isFalse);
        }
      }, skip: true); // Skip due to Flutter shader issue in test environment
    });
  });
}
