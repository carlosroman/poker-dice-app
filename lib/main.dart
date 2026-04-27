import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/game_screen.dart';
import 'screens/game_over_screen.dart';
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
          home: const GameScreenWrapper(),
        );
      },
    );
  }
}

/// Wrapper widget that handles game state initialization and game over navigation.
class GameScreenWrapper extends ConsumerStatefulWidget {
  const GameScreenWrapper({super.key});

  @override
  ConsumerState<GameScreenWrapper> createState() => _GameScreenWrapperState();
}

class _GameScreenWrapperState extends ConsumerState<GameScreenWrapper> {
  @override
  void initState() {
    super.initState();
    // Load settings and start a new game when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load settings from storage
      final settingsNotifier = ref.read(settingsProvider.notifier);
      await settingsNotifier.loadSettings();

      // Start a new game
      final gameNotifier = ref.read(gameProvider.notifier);
      gameNotifier.startNewGame();
      gameNotifier.startTurn();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);

    // Navigate to game over screen when game is over
    if (gameState.isGameOver) {
      return const GameOverScreen();
    }

    return GameScreen();
  }
}
