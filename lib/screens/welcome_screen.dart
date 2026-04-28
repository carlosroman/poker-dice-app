import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_provider.dart';
import '../services/storage_service.dart';
import 'game_screen.dart';

/// A welcome screen displayed at the start of the game.
///
/// This screen provides options to:
/// - Start a new game
/// - Continue a previously saved game
///
/// The "Continue" button is only visible when a saved game exists.
class WelcomeScreen extends ConsumerStatefulWidget {
  /// Creates a [WelcomeScreen] widget.
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _hasSavedGame = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkForSavedGame();
  }

  /// Checks if there is a saved game in storage.
  Future<void> _checkForSavedGame() async {
    final storageService = await StorageService.getInstance();
    final savedState = await storageService.loadGameState();
    setState(() {
      _hasSavedGame = savedState != null;
      _isLoading = false;
    });
  }

  /// Starts a new game and navigates to the game screen.
  Future<void> _startNewGame() async {
    // Clear any saved game state
    final storageService = await StorageService.getInstance();
    await storageService.clearGameState();

    // Start a fresh game
    final gameNotifier = ref.read(gameProvider.notifier);
    gameNotifier.startNewGame();
    gameNotifier.startTurn();

    // Navigate to game screen
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GameScreen()),
      );
    }
  }

  /// Loads the saved game and navigates to the game screen.
  Future<void> _continueGame() async {
    final storageService = await StorageService.getInstance();
    final savedState = await storageService.loadGameState();

    if (savedState != null) {
      // Restore game state
      final gameNotifier = ref.read(gameProvider.notifier);
      gameNotifier.restoreGameState(savedState);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GameScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.secondaryContainer.withOpacity(0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  _buildLogoSection(context),

                  const SizedBox(height: 48),

                  // Welcome Message
                  _buildWelcomeMessage(context),

                  const SizedBox(height: 64),

                  // New Game Button
                  _buildNewGameButton(context),

                  const SizedBox(height: 24),

                  // Continue Button (only if saved game exists)
                  if (!_isLoading && _hasSavedGame)
                    _buildContinueButton(context),

                  const SizedBox(height: 32),

                  if (_isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the logo section with dice icons and title.
  Widget _buildLogoSection(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Dice Icons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.coffee, size: 48, color: theme.colorScheme.primary),
            const SizedBox(width: 16),
            Icon(Icons.coffee, size: 48, color: theme.colorScheme.secondary),
            const SizedBox(width: 16),
            Icon(Icons.coffee, size: 48, color: theme.colorScheme.primary),
          ],
        ),
        const SizedBox(height: 16),

        // Title
        Text(
          'POKER DICE',
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
            letterSpacing: 2.0,
          ),
        ),
      ],
    );
  }

  /// Builds the welcome message.
  Widget _buildWelcomeMessage(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      'Welcome Player!',
      style: theme.textTheme.headlineMedium?.copyWith(
        color: theme.colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Builds the New Game button.
  Widget _buildNewGameButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 280,
      child: ElevatedButton.icon(
        onPressed: _startNewGame,
        icon: const Icon(Icons.add_circle),
        label: const Text(
          'NEW GAME',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  /// Builds the Continue button.
  Widget _buildContinueButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 280,
      child: OutlinedButton.icon(
        onPressed: _continueGame,
        icon: const Icon(Icons.save),
        label: const Text(
          'CONTINUE',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
