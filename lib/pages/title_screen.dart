/// Title screen with New Game and Continue buttons.
///
/// Entry point of the app. The "Continue" button is disabled
/// when there is no saved in-progress game.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/providers/storage_provider.dart';

class TitleScreen extends ConsumerWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageServiceProvider);
    final hasSavedGame = storage.when(
      data: (service) => service.hasInProgressGame(),
      loading: () => false,
      error: (_, _) => false,
    );

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Title
            Text(
              'Poker Dice',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            // New Game button
            ElevatedButton(
              onPressed: () {
                ref.read(gameProvider.notifier).resetGame();
                context.go('/game');
              },
              child: const Text('New Game'),
            ),
            const SizedBox(height: 16),
            // Continue button (disabled if no saved game)
            ElevatedButton(
              onPressed: hasSavedGame ? () => context.go('/game') : null,
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
