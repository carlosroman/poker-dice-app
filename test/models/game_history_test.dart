import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/models/game_history.dart';

void main() {
  group('GameResult', () {
    test('constructor creates result with correct values', () {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      expect(result.totalScore, 250);
      expect(result.upperSectionTotal, 70);
      expect(result.bonus, 35);
      expect(result.completedAt, DateTime(2024, 1, 15));
      expect(result.playerCount, 1);
    });

    test('constructor defaults playerCount to 1', () {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      expect(result.playerCount, 1);
    });

    test('constructor accepts explicit playerCount', () {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
      );

      expect(result.playerCount, 2);
    });

    test('copyWith creates new instance with replaced fields', () {
      final original = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      final copied = original.copyWith(totalScore: 300);

      expect(copied.totalScore, 300);
      expect(copied.upperSectionTotal, 70);
      expect(copied.bonus, 35);
      expect(copied.completedAt, DateTime(2024, 1, 15));
      expect(copied, isNot(equals(original)));
    });

    test('copyWith preserves fields when not provided', () {
      final original = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      final copied = original.copyWith();

      expect(copied.totalScore, 250);
      expect(copied.upperSectionTotal, 70);
      expect(copied.bonus, 35);
      expect(copied.completedAt, DateTime(2024, 1, 15));
      expect(copied.playerCount, 1);
    });

    test('copyWith updates playerCount', () {
      final original = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 1,
      );

      final copied = original.copyWith(playerCount: 2);

      expect(copied.playerCount, 2);
      expect(copied.totalScore, 250);
    });

    test('toJson returns correct map', () {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      final json = result.toJson();

      expect(json['total_score'], 250);
      expect(json['upper_section_total'], 70);
      expect(json['bonus'], 35);
      expect(json['completed_at'], '2024-01-15T00:00:00.000');
      expect(json['player_count'], 1);
    });

    test('toJson includes playerCount for multiplayer', () {
      final result = GameResult(
        totalScore: 500,
        upperSectionTotal: 140,
        bonus: 70,
        completedAt: DateTime(2024, 3, 10),
        playerCount: 2,
      );

      final json = result.toJson();

      expect(json['player_count'], 2);
    });

    test('fromJson creates correct instance', () {
      final json = {
        'total_score': 250,
        'upper_section_total': 70,
        'bonus': 35,
        'completed_at': '2024-01-15T00:00:00.000',
      };

      final result = GameResult.fromJson(json);

      expect(result.totalScore, 250);
      expect(result.upperSectionTotal, 70);
      expect(result.bonus, 35);
      expect(result.completedAt, DateTime(2024, 1, 15));
      // Backward compatibility: defaults to 1 when player_count is missing
      expect(result.playerCount, 1);
    });

    test('fromJson deserializes playerCount', () {
      final json = {
        'total_score': 250,
        'upper_section_total': 70,
        'bonus': 35,
        'completed_at': '2024-01-15T00:00:00.000',
        'player_count': 2,
      };

      final result = GameResult.fromJson(json);

      expect(result.playerCount, 2);
    });

    test('fromJson defaults playerCount to 1 when missing', () {
      final json = {
        'total_score': 250,
        'upper_section_total': 70,
        'bonus': 35,
        'completed_at': '2024-01-15T00:00:00.000',
      };

      final result = GameResult.fromJson(json);

      expect(result.playerCount, 1);
    });

    test('toJson and fromJson are symmetric', () {
      final original = GameResult(
        totalScore: 300,
        upperSectionTotal: 80,
        bonus: 40,
        completedAt: DateTime(2024, 6, 20),
      );

      final json = original.toJson();
      final restored = GameResult.fromJson(json);

      expect(restored, equals(original));
    });

    test('equality operator compares all fields', () {
      final result1 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      final result2 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      expect(result1, equals(result2));
    });

    test('equality returns false for different values', () {
      final result1 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      final result2 = GameResult(
        totalScore: 300,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      expect(result1, isNot(equals(result2)));
    });

    test('equality returns false for different playerCount', () {
      final result1 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 1,
      );

      final result2 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
      );

      expect(result1, isNot(equals(result2)));
    });

    test('equality returns false for different type', () {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      expect(result, isNot(equals('not a result')));
    });

    test('hashCode is consistent with equality', () {
      final result1 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      final result2 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      expect(result1.hashCode, equals(result2.hashCode));
    });

    test('hashCode differs for different playerCount', () {
      final result1 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 1,
      );

      final result2 = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
      );

      expect(result1.hashCode, isNot(equals(result2.hashCode)));
    });

    test('toString returns meaningful representation', () {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      final string = result.toString();

      expect(string, contains('250'));
      expect(string, contains('70'));
      expect(string, contains('35'));
      expect(string, contains('playerCount'));
    });

    test('player1Score and player2Score default to 0', () {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
      );

      expect(result.player1Score, 0);
      expect(result.player2Score, 0);
    });

    test('player1Score and player2Score can be set explicitly', () {
      final result = GameResult(
        totalScore: 450,
        upperSectionTotal: 140,
        bonus: 0,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
        player1Score: 250,
        player2Score: 200,
      );

      expect(result.player1Score, 250);
      expect(result.player2Score, 200);
    });

    test('winnerScore returns totalScore for single-player', () {
      final result = GameResult(
        totalScore: 250,
        upperSectionTotal: 70,
        bonus: 35,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 1,
        player1Score: 250,
        player2Score: 0,
      );

      expect(result.winnerScore, 250);
    });

    test('winnerScore returns highest player score for 2-player', () {
      final result = GameResult(
        totalScore: 450,
        upperSectionTotal: 140,
        bonus: 0,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
        player1Score: 250,
        player2Score: 200,
      );

      expect(result.winnerScore, 250);
    });

    test('winnerScore returns player2Score when higher', () {
      final result = GameResult(
        totalScore: 450,
        upperSectionTotal: 140,
        bonus: 0,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
        player1Score: 200,
        player2Score: 250,
      );

      expect(result.winnerScore, 250);
    });

    test('toJson includes player scores', () {
      final result = GameResult(
        totalScore: 450,
        upperSectionTotal: 140,
        bonus: 0,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
        player1Score: 250,
        player2Score: 200,
      );

      final json = result.toJson();

      expect(json['player1_score'], 250);
      expect(json['player2_score'], 200);
    });

    test('fromJson deserializes player scores', () {
      final json = {
        'total_score': 450,
        'upper_section_total': 140,
        'bonus': 0,
        'completed_at': '2024-01-15T00:00:00.000',
        'player_count': 2,
        'player1_score': 250,
        'player2_score': 200,
      };

      final result = GameResult.fromJson(json);

      expect(result.player1Score, 250);
      expect(result.player2Score, 200);
    });

    test('fromJson defaults player scores to 0 when missing', () {
      final json = {
        'total_score': 250,
        'upper_section_total': 70,
        'bonus': 35,
        'completed_at': '2024-01-15T00:00:00.000',
        'player_count': 1,
      };

      final result = GameResult.fromJson(json);

      expect(result.player1Score, 0);
      expect(result.player2Score, 0);
    });

    test('copyWith updates player scores', () {
      final original = GameResult(
        totalScore: 450,
        upperSectionTotal: 140,
        bonus: 0,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
        player1Score: 250,
        player2Score: 200,
      );

      final copied = original.copyWith(player1Score: 300);

      expect(copied.player1Score, 300);
      expect(copied.player2Score, 200);
      expect(copied.playerCount, 2);
    });

    test('equality returns false for different player scores', () {
      final result1 = GameResult(
        totalScore: 450,
        upperSectionTotal: 140,
        bonus: 0,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
        player1Score: 250,
        player2Score: 200,
      );

      final result2 = GameResult(
        totalScore: 450,
        upperSectionTotal: 140,
        bonus: 0,
        completedAt: DateTime(2024, 1, 15),
        playerCount: 2,
        player1Score: 200,
        player2Score: 250,
      );

      expect(result1, isNot(equals(result2)));
    });

    test('toJson and fromJson are symmetric with player scores', () {
      final original = GameResult(
        totalScore: 450,
        upperSectionTotal: 140,
        bonus: 0,
        completedAt: DateTime(2024, 6, 20),
        playerCount: 2,
        player1Score: 250,
        player2Score: 200,
      );

      final json = original.toJson();
      final restored = GameResult.fromJson(json);

      expect(restored, equals(original));
    });
  });
}
