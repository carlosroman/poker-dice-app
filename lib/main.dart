// Poker Dice (Yatzy) Game Application.
//
// A dice game application where players roll five dice to achieve
// various combinations for points, following Yatzy rules.
//
// ## Features
// - 5 dice with hold functionality
// - 3 rolls per turn
// - 13 scoring categories
// - Upper section bonus (35 points if >= 63)
// - Light and dark theme support
// - Accessibility features
//
// ## Scoring Categories
// ### Upper Section (Aces-Sixes)
// Score the sum of matching dice for each face value.
// Bonus of 35 points if upper total >= 63.
//
// ### Lower Section
// - **Three of a Kind**: Sum of all dice (3+ matching)
// - **Four of a Kind**: Sum of all dice (4+ matching)
// - **Full House**: 25 points (3+2 matching)
// - **Small Straight**: 30 points (1-2-3-4-5)
// - **Large Straight**: 40 points (2-3-4-5-6)
// - **Yatzy**: 50 points (5 matching)
// - **Chance**: Sum of all dice
//
// ## Architecture
// - **State Management**: BLoC pattern with flutter_bloc
// - **Theme**: Material 3 with custom color scheme
// - **Navigation**: Standard Flutter Navigator
//
// Example:
// ```dart
// void main() {
//   runApp(const MainApp());
// }
// ```
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'src/bloc/game_bloc.dart';
import 'src/ui/pages/game_page.dart';
import 'src/ui/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

/// The root widget of the Poker Dice application.
///
/// Sets up the app with:
/// - BLoC provider for game state management
/// - Material 3 theme with light/dark support
/// - Game page as the home screen
///
/// Example:
/// ```dart
/// const MainApp() // Used in main() function
/// ```
class MainApp extends StatelessWidget {
  /// Creates the main application widget.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameBloc(),
      child: MaterialApp(
        title: 'Poker Dice',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: ThemeMode.system,
        home: const GamePage(),
      ),
    );
  }
}
