import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_dice/pages/game_page.dart';
import 'package:poker_dice/pages/scoreboard_page.dart';
import 'package:poker_dice/providers/theme_provider.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

/// GoRouter configuration for the app.
final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const GamePage()),
    GoRoute(
      path: '/scoreboard',
      builder: (context, state) => const ScoreboardPage(gameResults: []),
    ),
  ],
);

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Poker Dice',
      theme: ThemeNotifier.lightTheme,
      darkTheme: ThemeNotifier.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
