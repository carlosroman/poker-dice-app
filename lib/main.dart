import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/game_provider.dart';
import 'screens/game_screen.dart';
import 'screens/game_over_screen.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.system,
      home: const GameScreenWrapper(),
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
    // Start a new game when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
