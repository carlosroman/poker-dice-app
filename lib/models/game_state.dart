import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/score_category.dart';

/// Represents the possible statuses of a game.
enum GameStatus {
  /// Game is in progress.
  active,

  /// Game has been completed.
  completed,
}

/// Immutable snapshot of the current game state.
class GameState {
  /// The five dice currently on the table.
  final List<Dice> currentDice;

  /// Number of rolls remaining in the current turn (0–3).
  final int rollsRemaining;

  /// Per-player score maps: player index → category scores.
  final Map<int, Map<ScoreCategory, int?>> scoredCategories;

  /// Current game status.
  final GameStatus status;

  /// Category the player has selected before rolling (pending confirmation).
  final ScoreCategory? selectedCategory;

  /// Number of players (1 or 2).
  final int playerCount;

  /// Current player index (0 or 1).
  final int currentPlayer;

  /// Last scored category across all players (for yellow dot indicator).
  final ScoreCategory? lastScoredCategory;

  GameState({
    List<Dice>? currentDice,
    this.rollsRemaining = 3,
    Map<int, Map<ScoreCategory, int?>>? scoredCategories,
    /// Accepts old single-player format for backward compatibility.
    Map<ScoreCategory, int?>? singlePlayerScoredCategories,
    this.status = GameStatus.active,
    this.selectedCategory,
    this.playerCount = 1,
    this.currentPlayer = 0,
    this.lastScoredCategory,
  })  : assert(playerCount >= 1 && playerCount <= 2,
            'playerCount must be 1 or 2, got $playerCount.'),
        assert(currentPlayer >= 0 && currentPlayer < playerCount,
            'currentPlayer ($currentPlayer) must be in range [0, $playerCount).'),
        currentDice = currentDice ?? List.generate(5, (_) => Dice(value: 0)),
        scoredCategories = _resolveScoredCategories(
          scoredCategories,
          singlePlayerScoredCategories,
          playerCount,
        ) {
    if (this.currentDice.length != 5) {
      throw ArgumentError(
        'Exactly 5 dice are required, got ${this.currentDice.length}.',
      );
    }
  }

  static Map<int, Map<ScoreCategory, int?>> _resolveScoredCategories(
    Map<int, Map<ScoreCategory, int?>>? multi,
    Map<ScoreCategory, int?>? single,
    int playerCount,
  ) {
    if (multi != null) return multi;
    if (single != null) {
      return {0: Map<ScoreCategory, int?>.from(single)};
    }
    return {
      for (int i = 0; i < playerCount; i++)
        i: {
          for (final category in ScoreCategory.values) category: null,
        },
    };
  }

  /// Creates a fresh initial game state.
  factory GameState.initial({int playerCount = 1}) {
    return GameState(playerCount: playerCount);
  }

  /// Returns the current player's scored categories.
  Map<ScoreCategory, int?> get currentPlayerScoredCategories {
    return scoredCategories[currentPlayer] ??
        {for (final category in ScoreCategory.values) category: null};
  }

  /// Returns all categories that have been scored by the current player.
  Map<ScoreCategory, int> get scored {
    return Map<ScoreCategory, int>.fromEntries(
      currentPlayerScoredCategories.entries
          .where((entry) => entry.value != null)
          .map((entry) => MapEntry(entry.key, entry.value as int)),
    );
  }

  /// Returns all categories that have NOT been scored by the current player.
  List<ScoreCategory> get unscoredCategories {
    return ScoreCategory.values
        .where((category) => currentPlayerScoredCategories[category] == null)
        .toList();
  }

  /// Returns all categories that have NOT been scored by ANY player.
  List<ScoreCategory> get unscoredByAllCategories {
    final scoredByAny = <ScoreCategory>{};
    for (final playerMap in scoredCategories.values) {
      for (final entry in playerMap.entries) {
        if (entry.value != null) {
          scoredByAny.add(entry.key);
        }
      }
    }
    return ScoreCategory.values
        .where((category) => !scoredByAny.contains(category))
        .toList();
  }

  /// Total score across ALL players plus bonus.
  int get totalScore {
    int total = 0;
    for (final playerMap in scoredCategories.values) {
      for (final entry in playerMap.entries) {
        if (entry.value != null) {
          total += entry.value as int;
        }
      }
    }
    return total + bonus;
  }

  /// Total score for the current player only.
  int get currentPlayerScore {
    int total = 0;
    for (final entry in currentPlayerScoredCategories.entries) {
      if (entry.value != null) {
        total += entry.value as int;
      }
    }
    return total;
  }

  /// Sum of upper section scores for the current player.
  int get upperSectionTotal {
    int total = 0;
    for (final category in ScoreCategory.values) {
      if (category.isUpper) {
        final score = currentPlayerScoredCategories[category];
        if (score != null) {
          total += score;
        }
      }
    }
    return total;
  }

  /// Bonus for upper section (35 points if upper section total >= 63).
  int get bonus => upperSectionTotal >= 63 ? 35 : 0;

  /// Toggles the hold state of the die at the given index.
  GameState toggleHold(int index) {
    final updatedDice = List<Dice>.from(currentDice);
    final die = updatedDice[index];
    updatedDice[index] = die.copyWith(isHeld: !die.isHeld);
    return copyWith(currentDice: updatedDice);
  }

  /// Sum of all dice values.
  int get diceTotal {
    int total = 0;
    for (final die in currentDice) {
      total += die.value;
    }
    return total;
  }

  /// Whether the game is complete (ALL players have filled all categories).
  bool get isGameComplete {
    for (final playerMap in scoredCategories.values) {
      for (final category in ScoreCategory.values) {
        if (playerMap[category] == null) return false;
      }
    }
    return true;
  }

  /// Switches to the next player.
  GameState switchPlayer() {
    if (playerCount <= 1) return this;
    final nextPlayer = (currentPlayer + 1) % playerCount;
    return copyWith(currentPlayer: nextPlayer);
  }

  /// Returns the score for the given category based on current dice.
  int? scoreCategory(ScoreCategory category) {
    return category.calculateScore(currentDice);
  }

  /// Records a score for the given category for the current player.
  GameState recordScore(ScoreCategory category, int score) {
    final playerCategories = scoredCategories[currentPlayer];
    if (playerCategories == null || playerCategories[category] != null) {
      throw StateError('${category.displayName} has already been scored.');
    }

    final updatedPlayer = Map<ScoreCategory, int?>.from(playerCategories);
    updatedPlayer[category] = score;

    final updated = Map<int, Map<ScoreCategory, int?>>.from(scoredCategories);
    updated[currentPlayer] = updatedPlayer;

    // Check if ALL players have completed
    bool allComplete = updated.values.every((playerCats) =>
        ScoreCategory.values.every((cat) => playerCats[cat] != null));

    final newStatus = allComplete ? GameStatus.completed : status;

    return copyWith(
      scoredCategories: updated,
      status: newStatus,
      lastScoredCategory: category,
    );
  }

  /// Rolls the dice and returns a new state with updated dice and decremented rolls.
  GameState rollDice(List<Dice> newDice) {
    return copyWith(
      currentDice: newDice,
      rollsRemaining: rollsRemaining - 1,
      selectedCategory: null,
    );
  }

  /// Selects a category to score before rolling.
  GameState selectCategory(ScoreCategory category) {
    return copyWith(selectedCategory: category);
  }

  /// Resets the game state for a new game with the same player count.
  GameState reset() {
    return GameState.initial(playerCount: playerCount);
  }

  /// Creates a copy of this state with optional fields replaced.
  GameState copyWith({
    List<Dice>? currentDice,
    int? rollsRemaining,
    Map<int, Map<ScoreCategory, int?>>? scoredCategories,
    GameStatus? status,
    ScoreCategory? selectedCategory,
    bool clearSelectedCategory = false,
    int? playerCount,
    int? currentPlayer,
    ScoreCategory? lastScoredCategory,
  }) {
    return GameState(
      currentDice: currentDice ?? this.currentDice,
      rollsRemaining: rollsRemaining ?? this.rollsRemaining,
      scoredCategories: scoredCategories ?? this.scoredCategories,
      status: status ?? this.status,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      playerCount: playerCount ?? this.playerCount,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      lastScoredCategory: lastScoredCategory ?? this.lastScoredCategory,
    );
  }

  /// Serializes the state to JSON.
  Map<String, dynamic> toJson() {
    return {
      'player_count': playerCount,
      'current_player': currentPlayer,
      'last_scored_category_index': lastScoredCategory?.index,
      'current_dice': currentDice.map((d) => d.toJson()).toList(),
      'rolls_remaining': rollsRemaining,
      'scored_categories': scoredCategories.entries
          .map(
            (e) => {
              'player_index': e.key,
              'categories': e.value.entries
                  .map(
                    (c) => {
                      'category_index': c.key.index,
                      'score': c.value,
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'status_index': status.index,
      'selected_category_index': selectedCategory?.index,
    };
  }

  /// Deserializes state from JSON, supporting both old and new formats.
  factory GameState.fromJson(Map<String, dynamic> json) {
    final diceList = (json['current_dice'] as List<dynamic>)
        .map((d) => Dice.fromJson(d as Map<String, dynamic>))
        .toList();

    // Parse per-player scored categories, supporting old single-player format
    final scoredData = json['scored_categories'] as List<dynamic>?;
    Map<int, Map<ScoreCategory, int?>>? parsedScoredCategories;

    if (scoredData != null && scoredData.isNotEmpty) {
      final firstEntry = scoredData.first as Map<String, dynamic>;

      if (firstEntry.containsKey('player_index')) {
        // New format: per-player
        parsedScoredCategories = <int, Map<ScoreCategory, int?>>{
          for (final entry in scoredData.cast<Map<String, dynamic>>())
            entry['player_index'] as int: <ScoreCategory, int?>{
              for (final cat in (entry['categories'] as List<dynamic>)
                  .cast<Map<String, dynamic>>())
                ScoreCategory.values[cat['category_index'] as int]:
                    cat['score'] as int?,
            },
        };
      } else {
        // Old format: single player list
        final singlePlayer = <ScoreCategory, int?>{
          for (final entry in scoredData.cast<Map<String, dynamic>>())
            ScoreCategory.values[entry['category_index'] as int]:
                entry['score'] as int?,
        };
        parsedScoredCategories = {0: singlePlayer};
      }
    }

    return GameState(
      currentDice: diceList,
      rollsRemaining: json['rolls_remaining'] as int? ?? 3,
      scoredCategories: parsedScoredCategories,
      playerCount: json['player_count'] as int? ?? 1,
      currentPlayer: json['current_player'] as int? ?? 0,
      lastScoredCategory: json['last_scored_category_index'] != null
          ? ScoreCategory.values[json['last_scored_category_index'] as int]
          : null,
      status: GameStatus.values[json['status_index'] as int? ?? 0],
      selectedCategory: json['selected_category_index'] != null
          ? ScoreCategory.values[json['selected_category_index'] as int]
          : null,
    );
  }

  @override
  String toString() {
    return 'GameState('
        'dice: $currentDice, '
        'rolls: $rollsRemaining, '
        'player: ${currentPlayer + 1}/$playerCount, '
        'score: $currentPlayerScore, '
        'status: $status'
        ')';
  }
}
