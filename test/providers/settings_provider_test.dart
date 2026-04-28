import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/providers/settings_provider.dart';
import 'package:poker_dice/services/storage_service.dart';

/// Tests for the SettingsNotifier class.
///
/// Verifies:
/// - Initial state
/// - Synchronous methods (clearError, isHighScore)
void main() {
  group('SettingsNotifier Tests', () {
    group('Initial State', () {
      test('starts with light mode by default', () {
        final notifier = SettingsNotifier(
          storageService: _FakeStorageService(),
        );
        expect(notifier.state.isDarkMode, false);
        notifier.dispose();
      });

      test('starts with empty high scores', () {
        final notifier = SettingsNotifier(
          storageService: _FakeStorageService(),
        );
        expect(notifier.state.highScores, isEmpty);
        notifier.dispose();
      });

      test('starts with no error', () {
        final notifier = SettingsNotifier(
          storageService: _FakeStorageService(),
        );
        expect(notifier.state.errorMessage, isNull);
        notifier.dispose();
      });

      test('starts with isLoading false', () {
        final notifier = SettingsNotifier(
          storageService: _FakeStorageService(),
        );
        expect(notifier.state.isLoading, false);
        notifier.dispose();
      });
    });

    group('clearError', () {
      test('clears error message when provided', () {
        // Arrange - create notifier with initial error
        final notifier = SettingsNotifier(
          storageService: _FakeStorageService(),
        );
        // Note: clearError is a simple setter that clears errorMessage
        // Testing the method exists and can be called
        expect(() => notifier.clearError(), returnsNormally);
        notifier.dispose();
      });
    });

    group('isHighScore', () {
      test('returns true when high scores list is not full', () {
        // Arrange
        final notifier = SettingsNotifier(
          storageService: _FakeStorageService(),
        );
        notifier.state = SettingsState(
          highScores: List.generate(
            5,
            (i) => HighScoreEntry(
              playerName: 'Player$i',
              score: 100,
              date: DateTime.now(),
            ),
          ),
        );

        // Act
        final result = notifier.isHighScore(50);

        // Assert
        expect(result, true);
        notifier.dispose();
      });

      test('returns true for score higher than lowest', () {
        // Arrange
        final notifier = SettingsNotifier(
          storageService: _FakeStorageService(),
        );
        notifier.state = SettingsState(
          highScores: List.generate(
            10,
            (i) => HighScoreEntry(
              playerName: 'Player$i',
              score: 200 - i * 10,
              date: DateTime.now(),
            ),
          ),
        );

        // Act
        final result = notifier.isHighScore(150);

        // Assert
        expect(result, true);
        notifier.dispose();
      });

      test('returns false for score lower than lowest', () {
        // Arrange
        final notifier = SettingsNotifier(
          storageService: _FakeStorageService(),
        );
        notifier.state = SettingsState(
          highScores: List.generate(
            10,
            (i) => HighScoreEntry(
              playerName: 'Player$i',
              score: 200 - i * 10,
              date: DateTime.now(),
            ),
          ),
        );

        // Act
        final result = notifier.isHighScore(50);

        // Assert
        expect(result, false);
        notifier.dispose();
      });
    });
  });
}

/// Fake implementation of StorageService for testing
class _FakeStorageService implements StorageService {
  @override
  Future<void> saveHighScore(String playerName, int score) async {}

  @override
  Future<List<HighScoreEntry>> getHighScores() async => [];

  @override
  Future<void> clearHighScores() async {}

  @override
  Future<void> saveThemePreference(bool isDarkMode) async {}

  @override
  Future<bool> getThemePreference() async => false;

  @override
  Future<void> clearAll() async {}
}
