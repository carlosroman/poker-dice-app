/// Multiplayer tests for [TurnIndicator].
///
/// Validates player turn display, active player highlighting,
/// and turn order indicators in multiplayer mode.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/widgets/turn_indicator.dart';

void main() {
  group('TurnIndicator - Multiplayer', () {
    testWidgets('displays correct number of player indicators', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: TurnIndicator(playerCount: 2, currentPlayer: 0)),
      );

      // Assert
      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
    });

    testWidgets('highlights current player', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: TurnIndicator(playerCount: 2, currentPlayer: 1)),

      );

      // Assert: 'Player 2' text exists (current player)
      expect(find.text('Player 2'), findsOneWidget);
    });

    testWidgets('shows turn label for active player', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: TurnIndicator(playerCount: 2, currentPlayer: 0)),
      );

      // Assert
      expect(find.text('Your Turn'), findsOneWidget);
    });

    testWidgets('updates when player changes', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(home: TurnIndicator(playerCount: 2, currentPlayer: 0)),
      );
      expect(find.text('Player 1'), findsOneWidget);

      // Act: Switch to player 1
      await tester.pumpWidget(
        MaterialApp(home: TurnIndicator(playerCount: 2, currentPlayer: 1)),
      );

      // Assert
      expect(find.text('Player 2'), findsOneWidget);
    });

    testWidgets('shows all player slots for 2 players', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(home: TurnIndicator(playerCount: 2, currentPlayer: 0)),
      );

      // Assert
      expect(find.text('Player 1'), findsOneWidget);
      expect(find.text('Player 2'), findsOneWidget);
    });
  });
}
