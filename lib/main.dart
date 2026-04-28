import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/game_screen.dart';
import 'screens/game_over_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service
  await StorageService.getInstance();

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final settingsState = ref.watch(settingsProvider);
        return MaterialApp(
          title: 'Poker Dice',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: settingsState.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const GameWrapper(),
        );
      },
    );
  }
}

/// Wrapper widget that handles game state management and navigation.
///
/// This widget:
/// - Displays WelcomeScreen initially
/// - Manages navigation to GameScreen and GameOverScreen
/// - Saves game state on navigation
class GameWrapper extends ConsumerStatefulWidget {
  const GameWrapper({super.key});

  @override
  ConsumerState<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends ConsumerState<GameWrapper> {
  @override
  void initState() {
    super.initState();
    // Load settings when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settingsNotifier = ref.read(settingsProvider.notifier);
      await settingsNotifier.loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    // Navigate to game over screen when game is over
    if (gameState.isGameOver) {
      return const GameOverScreen();
    }

    // Show game screen if game has started (has dice roll or scores)
    if (gameState.hasRolled || gameState.scores.isNotEmpty) {
      return GameScreenWrapper();
    }

    // Otherwise show welcome screen
    return const WelcomeScreen();
  }
}

/// Wrapper for the game screen that handles auto-start of turns.
class GameScreenWrapper extends ConsumerStatefulWidget {
  const GameScreenWrapper({super.key});

  @override
  ConsumerState<GameScreenWrapper> createState() => _GameScreenWrapperState();
}

class _GameScreenWrapperState extends ConsumerState<GameScreenWrapper> {
  bool _hasStartedTurn = false;

  @override
  void initState() {
    super.initState();
    // Start a new turn if dice haven't been rolled yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameState = ref.read(gameProvider);
      if (!_hasStartedTurn && !gameState.hasRolled) {
        setState(() => _hasStartedTurn = true);
        final gameNotifier = ref.read(gameProvider.notifier);
        gameNotifier.startTurn();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const GameScreen();
  }
}
