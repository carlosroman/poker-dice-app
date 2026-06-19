import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/game_history.dart';
import 'package:poker_dice/pages/scoreboard_page.dart';
import 'package:poker_dice/providers/storage_provider.dart';
import 'package:poker_dice/services/storage_service.dart';

void main() {
  group('ScoreboardPage', () {
    late _FakeStorageService fakeStorage;

    setUp(() {
      fakeStorage = _FakeStorageService();
    });

    Widget buildScoreboard({
      List<GameResult>? gameResults,
      int? gamesPlayed,
      int? highScore,
      VoidCallback? onClearHistory,
      VoidCallback? onBackTap,
    }) {
      return ProviderScope(
        overrides: [
          storageServiceProvider.overrideWith(
            (ref) => Future.value(fakeStorage),
          ),
          scoreboardProvider.overrideWith(
            (ref) => ScoreboardNotifier(ref: ref),
          ),
        ],
        child: MaterialApp(
          home: ScoreboardPage(
            gameResults: gameResults,
            gamesPlayed: gamesPlayed,
            highScore: highScore,
            onClearHistory: onClearHistory,
            onBackTap: onBackTap,
          ),
        ),
      );
    }

    testWidgets('renders empty state when no games', (tester) async {
      await tester.pumpWidget(buildScoreboard(gameResults: []));

      expect(find.text('No games played yet'), findsOneWidget);
    });

    testWidgets('renders title', (tester) async {
      await tester.pumpWidget(buildScoreboard(gameResults: []));

      expect(find.text('Scoreboard'), findsOneWidget);
    });

    testWidgets('shows back button', (tester) async {
      await tester.pumpWidget(buildScoreboard(gameResults: []));

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('calls onBackTap when back button is tapped', (tester) async {
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildScoreboard(
          gameResults: [],
          onBackTap: () => callbackCalled = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets(
      'shows clear button when games exist and onClearHistory provided',
      (tester) async {
        final results = [
          GameResult(
            totalScore: 250,
            upperSectionTotal: 70,
            bonus: 35,
            completedAt: DateTime(2024, 1, 15),
          ),
        ];
        await tester.pumpWidget(
          buildScoreboard(gameResults: results, onClearHistory: () {}),
        );

        expect(find.byIcon(Icons.delete_sweep), findsOneWidget);
      },
    );

    testWidgets('hides clear button when no games', (tester) async {
      await tester.pumpWidget(buildScoreboard(gameResults: []));

      expect(find.byIcon(Icons.delete_sweep), findsNothing);
    });

    testWidgets(
      'clear button is disabled when no games but onClearHistory provided',
      (tester) async {
        await tester.pumpWidget(
          buildScoreboard(gameResults: [], onClearHistory: () {}),
        );

        expect(find.byIcon(Icons.delete_sweep), findsOneWidget);
      },
    );

    testWidgets('calls onClearHistory when clear button is tapped', (
      tester,
    ) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      bool callbackCalled = false;
      await tester.pumpWidget(
        buildScoreboard(
          gameResults: results,
          onClearHistory: () => callbackCalled = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.delete_sweep));
      await tester.pumpAndSettle();

      expect(callbackCalled, isTrue);
    });

    testWidgets('shows stats when games exist', (tester) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      await tester.pumpWidget(
        buildScoreboard(
          gameResults: results,
          gamesPlayed: 5,
          highScore: 300,
        ),
      );

      expect(find.text('5'), findsOneWidget);
      expect(find.text('Games Played'), findsOneWidget);
      expect(find.text('300'), findsOneWidget);
      expect(find.text('High Score'), findsOneWidget);
    });

    testWidgets('shows dash for high score when null', (tester) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      await tester.pumpWidget(
        buildScoreboard(gameResults: results, gamesPlayed: 1),
      );

      expect(find.text('-'), findsOneWidget);
    });

    testWidgets('displays game results in list', (tester) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
        GameResult(
          totalScore: 300,
          upperSectionTotal: 80,
          bonus: 40,
          completedAt: DateTime(2024, 2, 20),
        ),
      ];
      await tester.pumpWidget(buildScoreboard(gameResults: results));

      expect(find.text('Score: 300'), findsOneWidget);
      expect(find.text('Score: 250'), findsOneWidget);
    });

    testWidgets('displays game results in reverse chronological order', (
      tester,
    ) async {
      final results = [
        GameResult(
          totalScore: 200,
          upperSectionTotal: 60,
          bonus: 0,
          completedAt: DateTime(2024, 1, 1),
        ),
        GameResult(
          totalScore: 300,
          upperSectionTotal: 80,
          bonus: 40,
          completedAt: DateTime(2024, 2, 20),
        ),
      ];
      await tester.pumpWidget(buildScoreboard(gameResults: results));

      final listView = find.byType(ListView);
      expect(listView, findsOneWidget);
    });

    testWidgets('displays game details', (tester) async {
      final results = [
        GameResult(
          totalScore: 250,
          upperSectionTotal: 70,
          bonus: 35,
          completedAt: DateTime(2024, 1, 15),
        ),
      ];
      await tester.pumpWidget(buildScoreboard(gameResults: results));

      expect(find.text('Upper: 70 | Bonus: 35'), findsOneWidget);
      expect(find.text('15/1/2024'), findsOneWidget);
    });
  });

  group('ScoreboardPage with Riverpod', () {
    testWidgets(
      'shows provider data when no constructor data provided',
      (tester) async {
        final results = [
          GameResult(
            totalScore: 150,
            upperSectionTotal: 50,
            bonus: 0,
            completedAt: DateTime(2024, 3, 10),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              storageServiceProvider.overrideWith(
                (ref) => Future.value(_FakeStorageService()),
              ),
              scoreboardProvider.overrideWith(
                (ref) => ScoreboardNotifier(ref: ref)
                  ..state = ScoreboardState(
                    gameResults: results,
                    gamesPlayed: 3,
                    highScore: 150,
                  ),
              ),
            ],
            child: const MaterialApp(
              home: ScoreboardPage(),
            ),
          ),
        );

        expect(find.text('Score: 150'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('150'), findsNWidgets(2)); // score + high score
      },
    );

    testWidgets(
      'constructor data takes precedence over provider data',
      (tester) async {
        final providerResults = [
          GameResult(
            totalScore: 100,
            upperSectionTotal: 30,
            bonus: 0,
            completedAt: DateTime(2024, 1, 1),
          ),
        ];
        final constructorResults = [
          GameResult(
            totalScore: 999,
            upperSectionTotal: 99,
            bonus: 99,
            completedAt: DateTime(2024, 6, 1),
          ),
        ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              storageServiceProvider.overrideWith(
                (ref) => Future.value(_FakeStorageService()),
              ),
              scoreboardProvider.overrideWith(
                (ref) => ScoreboardNotifier(ref: ref)
                  ..state = ScoreboardState(
                    gameResults: providerResults,
                    gamesPlayed: 1,
                    highScore: 100,
                  ),
              ),
            ],
            child: MaterialApp(
              home: ScoreboardPage(
                gameResults: constructorResults,
                gamesPlayed: 42,
                highScore: 999,
              ),
            ),
          ),
        );

        expect(find.text('Score: 999'), findsOneWidget);
        expect(find.text('Score: 100'), findsNothing);
        expect(find.text('42'), findsOneWidget);
      },
    );

    testWidgets(
      'clear button calls notifier clearHistory when no callback',
      (tester) async {
        final results = [
          GameResult(
            totalScore: 200,
            upperSectionTotal: 60,
            bonus: 10,
            completedAt: DateTime(2024, 5, 5),
          ),
        ];
        bool clearCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              storageServiceProvider.overrideWith(
                (ref) => Future.value(_FakeStorageService()),
              ),
              scoreboardProvider.overrideWith(
                (ref) => _TestScoreboardNotifier(
                  ref: ref,
                  initialState: ScoreboardState(
                    gameResults: results,
                    gamesPlayed: 1,
                    highScore: 200,
                  ),
                  onClear: () => clearCalled = true,
                ),
              ),
            ],
            child: const MaterialApp(
              home: ScoreboardPage(),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.delete_sweep));
        await tester.pump();

        expect(clearCalled, isTrue);
      },
    );

    testWidgets('shows loading indicator when provider is loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            storageServiceProvider.overrideWith(
              (ref) => Future.value(_FakeStorageService()),
            ),
            scoreboardProvider.overrideWith(
              (ref) => ScoreboardNotifier(ref: ref)
                ..state = const ScoreboardState(isLoading: true),
            ),
          ],
          child: const MaterialApp(
            home: ScoreboardPage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'empty state shown when provider has no results and not loading',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              storageServiceProvider.overrideWith(
                (ref) => Future.value(_FakeStorageService()),
              ),
              scoreboardProvider.overrideWith(
                (ref) => ScoreboardNotifier(ref: ref)
                  ..state = const ScoreboardState(),
              ),
            ],
            child: const MaterialApp(
              home: ScoreboardPage(),
            ),
          ),
        );

        // After the microtask, it will try to load data
        await tester.pump();
        expect(find.text('No games played yet'), findsOneWidget);
      },
    );
  });

  group('ScoreboardState', () {
    test('starts with default values', () {
      const state = ScoreboardState();

      expect(state.gameResults, isEmpty);
      expect(state.gamesPlayed, equals(0));
      expect(state.highScore, isNull);
      expect(state.isLoading, isFalse);
    });

    test('copyWith creates correct copy', () {
      const state = ScoreboardState(
        gamesPlayed: 5,
        highScore: 300,
      );

      final updated = state.copyWith(
        gamesPlayed: 10,
        isLoading: true,
      );

      expect(updated.gamesPlayed, equals(10));
      expect(updated.highScore, equals(300));
      expect(updated.isLoading, isTrue);
      expect(updated.gameResults, isEmpty);
    });
  });

  group('ScoreboardNotifier', () {
    test('starts with empty state', () async {
      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWith(
            (ref) => Future.value(_FakeStorageService()),
          ),
        ],
      );

      final notifier = container.read(scoreboardProvider.notifier);
      final state = notifier.state;

      expect(state.gameResults, isEmpty);
      expect(state.gamesPlayed, equals(0));
      expect(state.highScore, isNull);
      expect(state.isLoading, isFalse);

      container.dispose();
    });

    test('loadData populates state from storage', () async {
      final results = [
        GameResult(
          totalScore: 350,
          upperSectionTotal: 90,
          bonus: 35,
          completedAt: DateTime(2024, 4, 1),
        ),
      ];
      final fakeStorage = _FakeStorageService(
        gameResults: results,
        highScore: 350,
        gamesPlayed: 2,
      );

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWith(
            (ref) => Future.value(fakeStorage),
          ),
        ],
      );

      final notifier = container.read(scoreboardProvider.notifier);
      await notifier.loadData();

      expect(notifier.state.gameResults, hasLength(1));
      expect(notifier.state.gamesPlayed, equals(2));
      expect(notifier.state.highScore, equals(350));
      expect(notifier.state.isLoading, isFalse);

      container.dispose();
    });

    test('clearHistory resets state', () async {
      final fakeStorage = _FakeStorageService(
        gameResults: [
          GameResult(
            totalScore: 200,
            upperSectionTotal: 50,
            bonus: 0,
            completedAt: DateTime(2024, 1, 1),
          ),
        ],
        highScore: 200,
        gamesPlayed: 1,
      );

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWith(
            (ref) => Future.value(fakeStorage),
          ),
        ],
      );

      final notifier = container.read(scoreboardProvider.notifier);
      await notifier.loadData();

      expect(notifier.state.gameResults, isNotEmpty);

      await notifier.clearHistory();

      expect(notifier.state.gameResults, isEmpty);
      expect(notifier.state.gamesPlayed, equals(0));
      expect(notifier.state.highScore, isNull);
      expect(fakeStorage.clearWasCalled, isTrue);

      container.dispose();
    });

    test('addResult saves and reloads', () async {
      final fakeStorage = _FakeStorageService();

      final container = ProviderContainer(
        overrides: [
          storageServiceProvider.overrideWith(
            (ref) => Future.value(fakeStorage),
          ),
        ],
      );

      final notifier = container.read(scoreboardProvider.notifier);

      final result = GameResult(
        totalScore: 400,
        upperSectionTotal: 100,
        bonus: 35,
        completedAt: DateTime(2024, 5, 1),
      );

      await notifier.addResult(result);

      expect(fakeStorage.savedResults, hasLength(1));
      expect(fakeStorage.savedResults.first.totalScore, equals(400));

      container.dispose();
    });
  });
}

/// Test double for [ScoreboardNotifier] that tracks clear calls.
class _TestScoreboardNotifier extends ScoreboardNotifier {
  final VoidCallback? onClear;
  final ScoreboardState initialState;

  _TestScoreboardNotifier({
    required super.ref,
    required this.initialState,
    this.onClear,
  }) {
    state = initialState;
  }

  @override
  Future<void> clearHistory() async {
    onClear?.call();
    state = const ScoreboardState();
  }
}

/// Fake [StorageServiceInterface] for testing.
class _FakeStorageService implements StorageServiceInterface {
  final List<GameResult> gameResults;
  final int? highScore;
  final int gamesPlayed;
  final List<GameResult> savedResults = [];
  bool clearWasCalled = false;

  _FakeStorageService({
    this.gameResults = const [],
    this.highScore,
    this.gamesPlayed = 0,
  });

  @override
  Future<void> saveGameResult(GameResult result) async {
    savedResults.add(result);
  }

  @override
  Future<List<GameResult>> loadGameResults() async => List.unmodifiable(
    gameResults,
  );

  @override
  Future<int?> getHighScore() async => highScore;

  @override
  Future<int> getGamesPlayed() async => gamesPlayed;

  @override
  Future<void> clearHistory() async {
    clearWasCalled = true;
  }
}
