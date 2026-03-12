import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../game/models/game_state.dart';
import '../../game/providers/game_provider.dart';
import '../../game/providers/game_state_provider.dart';
import '../../score/score_provider.dart';
import 'game_screen.dart';
import '../../../core/theme/app_theme.dart';

/// Title screen for the Poker Dice game.
///
/// This is the main entry point displayed when the app launches.
/// It provides options to start a new game or continue from a saved state.
class TitleScreen extends ConsumerWidget {
  /// Creates a [TitleScreen] widget.
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreAsync = ref.watch(scoreProvider);
    final savedGameStateAsync = ref.watch(gameStateProvider);

    return Scaffold(
      backgroundColor: AppTheme.darkTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildTitle(),
                const SizedBox(height: 24),
                _buildHighScore(ref, scoreAsync),
                const Spacer(),
                _buildNewGameButton(ref),
                const SizedBox(height: 16),
                _buildContinueButton(ref, savedGameStateAsync, context),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the game title display.
  Widget _buildTitle() {
    return Column(
      children: [
        Icon(Icons.casino, size: 80, color: AppTheme.primaryColor),
        const SizedBox(height: 16),
        Text(
          'Poker Dice',
          style: GoogleFonts.permanentMarker(
            fontSize: 48,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
                offset: const Offset(3, 3),
                blurRadius: 10,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds the high score display section.
  Widget _buildHighScore(WidgetRef ref, AsyncValue<int> scoreAsync) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF303030),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentColor.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'HIGH SCORE',
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          scoreAsync.when(
            data: (highScore) {
              return Text(
                '$highScore',
                style: GoogleFonts.permanentMarker(
                  fontSize: 42,
                  color: AppTheme.primaryColor,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              );
            },
            loading: () => const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
            error: (_, _) => Text(
              'N/A',
              style: GoogleFonts.permanentMarker(
                fontSize: 42,
                color: Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "New Game" button.
  Widget _buildNewGameButton(WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _startNewGame(ref),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 6,
        shadowColor: AppTheme.primaryColor.withValues(alpha: 0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_arrow, size: 28),
          const SizedBox(width: 12),
          Text(
            'NEW GAME',
            style: GoogleFonts.openSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Continue" button (only visible if there's a saved game).
  Widget _buildContinueButton(
    WidgetRef ref,
    AsyncValue<GameState?> savedGameStateAsync,
    BuildContext context,
  ) {
    return savedGameStateAsync.when(
      data: (savedState) {
        if (savedState == null || savedState.isGameOver) {
          return const SizedBox.shrink();
        }
        return ElevatedButton(
          onPressed: () => _continueGame(ref, context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: AppTheme.accentColor.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_forward, size: 28),
              const SizedBox(width: 12),
              Text(
                'CONTINUE',
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  /// Builds the footer with app version or credits.
  Widget _buildFooter() {
    return Text(
      'Poker Dice Game',
      style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey[600]),
      textAlign: TextAlign.center,
    );
  }

  /// Starts a new game and navigates to the game screen.
  Future<void> _startNewGame(WidgetRef ref) async {
    final context = ref.context;
    // Clear any saved state
    await ref.read(gameProvider.notifier).clearSavedState();
    // Reset game state
    ref.read(gameProvider.notifier).resetGame();
    // Navigate to game screen (check if widget is still mounted)
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const GameScreenWrapper()),
      );
    }
  }

  /// Continues from saved state and navigates to the game screen.
  void _continueGame(WidgetRef ref, BuildContext context) {
    final savedState = ref.read(gameStateProvider).value;
    if (savedState != null) {
      // Load the saved state into the game provider
      ref.read(gameProvider.notifier).loadFromSavedState(savedState);
      // Clear the saved state from persistence (state is now loaded into memory)
      ref.read(gameProvider.notifier).clearSavedState();
      // Navigate to game screen
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const GameScreenWrapper()),
      );
    }
  }
}

/// Wrapper widget for GameScreen to access Riverpod context.
///
/// This is needed because GameScreen needs to be used as a route destination
/// and must have access to the ProviderScope.
class GameScreenWrapper extends ConsumerWidget {
  /// Creates a [GameScreenWrapper] widget.
  const GameScreenWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuild the game screen with current state
    return const GameScreen();
  }
}
