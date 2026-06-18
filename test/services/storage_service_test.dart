import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/game_history.dart';
import 'package:poker_dice/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('StorageService', () {
    late FakeSharedPreferences fakePrefs;
    late StorageService storageService;

    setUp(() {
      fakePrefs = FakeSharedPreferences();
      storageService = StorageService(prefs: fakePrefs);
    });

    test('loadGameResults returns empty list when no data', () async {
      final results = await storageService.loadGameResults();
      expect(results, isEmpty);
    });

    test('loadGameResults returns results from storage', () async {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );
      fakePrefs.data['game_history'] = [jsonEncode(result.toJson())];

      final results = await storageService.loadGameResults();

      expect(results, hasLength(1));
      expect(results[0], equals(result));
    });

    test('saveGameResult adds to existing results', () async {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      await storageService.saveGameResult(result);

      expect(fakePrefs.data['game_history'], isNotNull);
      expect(fakePrefs.data['game_history']!, hasLength(1));
    });

    test('saveGameResult appends to existing history', () async {
      final result1 = GameResult(
        totalScore: 200,
        upperSectionTotal: 60,
        bonus: 0,
        completedAt: DateTime(2024, 1, 1),
      );
      final result2 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      fakePrefs.data['game_history'] = [jsonEncode(result1.toJson())];
      await storageService.saveGameResult(result2);

      expect(fakePrefs.data['game_history']!, hasLength(2));
    });

    test('clearHistory removes all results', () async {
      fakePrefs.data['game_history'] = ['some_data'];

      await storageService.clearHistory();

      expect(fakePrefs.data['game_history'], isNull);
    });

    test('getHighScore returns null when no games', () async {
      final highScore = await storageService.getHighScore();
      expect(highScore, isNull);
    });

    test('getHighScore returns highest score', () async {
      final result1 = GameResult(
        totalScore: 200,
        upperSectionTotal: 60,
        bonus: 0,
        completedAt: DateTime(2024, 1, 1),
      );
      final result2 = GameResult(
        totalScore: 300,
        upperSectionTotal: 80,
        bonus: 40,
        completedAt: DateTime(2024, 1, 15),
      );
      final result3 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 2, 1),
      );

      fakePrefs.data['game_history'] = [
        jsonEncode(result1.toJson()),
        jsonEncode(result2.toJson()),
        jsonEncode(result3.toJson()),
      ];

      final highScore = await storageService.getHighScore();

      expect(highScore, 300);
    });

    test('getGamesPlayed returns correct count', () async {
      final result1 = GameResult(
        totalScore: 200,
        upperSectionTotal: 60,
        bonus: 0,
        completedAt: DateTime(2024, 1, 1),
      );
      final result2 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      fakePrefs.data['game_history'] = [
        jsonEncode(result1.toJson()),
        jsonEncode(result2.toJson()),
      ];

      final count = await storageService.getGamesPlayed();

      expect(count, 2);
    });

    test('loadGameResults skips corrupted entries', () async {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      fakePrefs.data['game_history'] = [
        'corrupted_data',
        jsonEncode(result.toJson()),
      ];

      final results = await storageService.loadGameResults();

      expect(results, hasLength(1));
      expect(results[0], equals(result));
    });
  });
}

/// Fake implementation of SharedPreferences for testing.
class FakeSharedPreferences implements SharedPreferences {
  final Map<String, dynamic> data = {};

  @override
  bool containsKey(String key) => data.containsKey(key);

  @override
  bool? getBool(String key) => data[key] as bool?;

  @override
  double? getDouble(String key) => data[key] as double?;

  @override
  int? getInt(String key) => data[key] as int?;

  @override
  String? getString(String key) => data[key] as String?;

  @override
  List<String>? getStringList(String key) => data[key] as List<String>?;

  Set<String>? getStringSet(String key) => data[key] as Set<String>?;

  @override
  Future<bool> clear() {
    data.clear();
    return Future.value(true);
  }

  @override
  Future<bool> remove(String key) {
    data.remove(key);
    return Future.value(true);
  }

  @override
  Future<bool> setBool(String key, bool value) {
    data[key] = value;
    return Future.value(true);
  }

  @override
  Future<bool> setDouble(String key, double value) {
    data[key] = value;
    return Future.value(true);
  }

  @override
  Future<bool> setInt(String key, int value) {
    data[key] = value;
    return Future.value(true);
  }

  @override
  Future<bool> setString(String key, String value) {
    data[key] = value;
    return Future.value(true);
  }

  @override
  Future<bool> setStringList(String key, List<String> value) {
    data[key] = value;
    return Future.value(true);
  }

  Future<bool> setStringSet(String key, Set<String> value) {
    data[key] = value;
    return Future.value(true);
  }

  @override
  Set<String> getKeys() => data.keys.toSet();

  @override
  Future<bool> reload() => Future.value(true);

  @override
  Future<bool> commit() => Future.value(true);

  @override
  dynamic get(String key) => data[key];
}
