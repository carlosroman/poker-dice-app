import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/features/game/providers/game_provider.dart';
import 'package:poker_dice/features/game/providers/game_state_provider.dart';
import 'package:poker_dice/features/score/score_provider.dart';
import 'package:poker_dice/core/constants/dice_faces.dart';

@GenerateMocks([SharedPreferences])
import 'save_and_continue_test.mocks.dart';

void main() {
  group('Save and Continue Integration Tests', () {
    late MockSharedPreferences mockSharedPreferences;
    late ProviderContainer container;

    setUp(() {
      mockSharedPreferences = MockSharedPreferences();
      TestWidgetsFlutterBinding.ensureInitialized();

      // Track stored values
      final storedValues = <String, dynamic>{};

      // Default stubs for all tests
      when(mockSharedPreferences.remove(any)).thenAnswer((invocation) async {
        final key = invocation.positionalArguments[0] as String;
        storedValues.remove(key);
        return true;
      });
      when(mockSharedPreferences.setString(any, any)).thenAnswer((
        invocation,
      ) async {
        final key = invocation.positionalArguments[0] as String;
        final value = invocation.positionalArguments[1] as String;
        storedValues[key] = value;
        return true;
      });
      when(mockSharedPreferences.getString(any)).thenAnswer((invocation) {
        final key = invocation.positionalArguments[0] as String;
        return storedValues[key] as String?;
      });
      when(mockSharedPreferences.getInt(any)).thenAnswer((invocation) {
        final key = invocation.positionalArguments[0] as String;
        return storedValues[key] as int? ?? 0;
      });

      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Save state flow - save game and verify it can be loaded', () async {
      // 1. Start a new game
      container.read(gameProvider.notifier).resetGame();
      var state = container.read(gameProvider);
      expect(state.turnNumber, 1);
      expect(state.rollsRemaining, MAX_ROLLS);

      // 2. Roll dice
      container.read(gameProvider.notifier).rollDice();
      state = container.read(gameProvider);
      expect(state.rollsRemaining, MAX_ROLLS - 1);

      // 3. Select a category (create pending selection)
      container.read(gameProvider.notifier).selectPending(0);
      state = container.read(gameProvider);
      expect(state.pendingSelection, 0);

      // 4. Save the game state
      final saveNotifier = container.read(gameStateProvider.notifier);
      final saveSuccess = await saveNotifier.saveGameState(state);
      expect(saveSuccess, true);

      // 5. Verify the state was saved by reloading
      // The provider should have been updated with the saved state
      final currentState = container.read(gameStateProvider);
      expect(currentState.value, isNotNull);
      expect(currentState.value!.turnNumber, state.turnNumber);
      expect(currentState.value!.pendingSelection, state.pendingSelection);
    });

    test(
      'Clear state flow - clear saved game and verify it returns null',
      () async {
        // 1. Save a game state first
        container.read(gameProvider.notifier).resetGame();
        container.read(gameProvider.notifier).rollDice();

        final saveNotifier = container.read(gameStateProvider.notifier);
        await saveNotifier.saveGameState(container.read(gameProvider));

        // 2. Verify state exists
        var currentState = container.read(gameStateProvider);
        expect(currentState.value, isNotNull);

        // 3. Clear the saved state
        final clearSuccess = await saveNotifier.clearGameState();
        expect(clearSuccess, true);

        // 4. Verify state is now null
        currentState = container.read(gameStateProvider);
        expect(currentState.value, isNull);
      },
    );

    test('Save and continue flow - save, clear memory, then load', () async {
      // 1. Start game and make progress
      container.read(gameProvider.notifier).resetGame();
      container.read(gameProvider.notifier).rollDice();
      container.read(gameProvider.notifier).selectPending(2);

      var currentState = container.read(gameProvider);
      expect(currentState.pendingSelection, 2);

      // 2. Save the state (simulating user hitting back button with save)
      final saveNotifier = container.read(gameStateProvider.notifier);
      await saveNotifier.saveGameState(currentState);

      // 3. Verify saved state exists
      var savedState = container.read(gameStateProvider);
      expect(savedState.value, isNotNull);
      expect(savedState.value!.pendingSelection, 2);

      // 4. Simulate app restart by recreating container
      container.dispose();
      container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
      );

      // 5. Load the saved state (provider rebuilds and loads from storage)
      // Use .future to wait for the async load to complete
      final loadedState = await container.read(gameStateProvider.future);
      expect(loadedState, isNotNull);
      expect(loadedState!.pendingSelection, 2);
      savedState = container.read(gameStateProvider);

      // Get new notifier from the new container
      final newSaveNotifier = container.read(gameStateProvider.notifier);

      // 6. Load into game provider
      container
          .read(gameProvider.notifier)
          .loadFromSavedState(savedState.value!);
      var restoredState = container.read(gameProvider);
      expect(restoredState.pendingSelection, 2);

      // 7. Clear the saved state from storage (since it's now loaded)
      await newSaveNotifier.clearGameState();

      // 8. Verify saved state is cleared
      // Wait for the async update to complete
      await Future.delayed(const Duration(milliseconds: 100));
      savedState = container.read(gameStateProvider);
      expect(savedState.value, isNull);
    });

    test(
      'Invalidate gameStateProvider after save - title screen detects saved state',
      () async {
        // 1. Initial state - no saved game
        var savedState = container.read(gameStateProvider);
        expect(savedState.value, isNull);

        // 2. Create a game state and save it
        container.read(gameProvider.notifier).resetGame();
        container.read(gameProvider.notifier).rollDice();

        final gameState = container.read(gameProvider);
        final saveNotifier = container.read(gameStateProvider.notifier);
        await saveNotifier.saveGameState(gameState);

        // 3. Verify the saved state is now available (provider was updated)
        savedState = container.read(gameStateProvider);
        expect(savedState.value, isNotNull);
        expect(savedState.value!.turnNumber, gameState.turnNumber);
      },
    );

    test('Save returns true on success and false on failure', () async {
      // Setup: Normal save should succeed
      container.read(gameProvider.notifier).resetGame();
      final gameState = container.read(gameProvider);

      final saveNotifier = container.read(gameStateProvider.notifier);
      final success = await saveNotifier.saveGameState(gameState);
      expect(success, true);

      // Setup: Simulate save failure
      when(
        mockSharedPreferences.setString(any, any),
      ).thenAnswer((_) async => false);

      final failSuccess = await saveNotifier.saveGameState(gameState);
      expect(failSuccess, false);
    });

    test('Complete save and continue cycle matches user flow', () async {
      // Simulate the complete user flow:
      // 1. User starts new game
      container.read(gameProvider.notifier).resetGame();

      // 2. User rolls dice
      container.read(gameProvider.notifier).rollDice();

      // 3. User selects a category
      container.read(gameProvider.notifier).selectPending(1);

      // 4. User hits back button - game saves state
      var gameState = container.read(gameProvider);
      final saveNotifier = container.read(gameStateProvider.notifier);
      await saveNotifier.saveGameState(gameState);

      // 5. Title screen shows CONTINUE button (saved state exists)
      var savedState = container.read(gameStateProvider);
      expect(savedState.value, isNotNull);
      expect(savedState.value!.pendingSelection, 1);

      // 6. User clicks CONTINUE
      // Load state into game provider
      container
          .read(gameProvider.notifier)
          .loadFromSavedState(savedState.value!);

      // 7. Clear saved state from storage
      await saveNotifier.clearGameState();

      // 8. Verify game state is restored
      gameState = container.read(gameProvider);
      expect(gameState.pendingSelection, 1);

      // 9. Verify saved state is cleared
      savedState = container.read(gameStateProvider);
      expect(savedState.value, isNull);
    });
  });
}
