import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/screens/game_over_screen.dart';
import 'package:poker_dice/widgets/control_bar.dart';
import 'package:poker_dice/widgets/dice_container.dart';
import 'package:poker_dice/widgets/header_bar.dart';
import 'package:poker_dice/widgets/scorecard.dart';

/// Main game screen with 3-section vertical layout.
///
/// Layout:
/// - Header (top): Total score, player info, navigation
/// - Scorecard (middle): Scrollable scorecard with dice display
/// - Control bar (bottom): Roll and Play buttons
class GameScreen extends ConsumerWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.watch(gameNotifierProvider.notifier);

    // Navigate to game over screen when game ends
    if (gameState.isGameOver) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const GameOverScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yatzy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.newGame(),
            tooltip: 'New Game',
          ),
        ],
      ),
      body: const Column(
        children: [
          HeaderBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    DiceContainer(),
                    SizedBox(height: 16),
                    Scorecard(),
                  ],
                ),
              ),
            ),
          ),
          ControlBar(),
        ],
      ),
    );
  }
}
