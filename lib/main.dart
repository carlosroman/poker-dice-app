import 'package:flutter/material.dart';
import 'src/ui/pages/game_screen.dart';
import 'src/ui/theme/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Poker Dice Game',
      theme: AppTheme.lightTheme(),
      home: const GameScreen(),
    );
  }
}
