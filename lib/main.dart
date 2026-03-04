import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/theme/app_theme.dart';
import 'features/score/score_provider.dart';
import 'features/ui/screens/game_screen.dart';

/// Main entry point for the Poker Dice application.
///
/// Initializes the app with Riverpod providers and SharedPreferences support.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize SharedPreferences for high score persistence.
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    /// ProviderScope wraps the app to manage Riverpod providers.
    ///
    /// Overrides scoreRepositoryProvider with the initialized SharedPreferences
    /// instance for dependency injection.
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const PokerDiceApp(),
    ),
  );
}

/// PokerDiceApp is the root widget of the application.
///
/// Configures MaterialApp with dark theme and sets GameScreen as the home.
class PokerDiceApp extends StatelessWidget {
  /// Creates a [PokerDiceApp] widget.
  const PokerDiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Dice',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const GameScreen(),
    );
  }
}
