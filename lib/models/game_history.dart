/// Represents the result of a completed poker dice game.
///
/// Stores the final score, upper section total, bonus, number of players,
/// and the timestamp when the game was completed.
class GameResult {
  /// The total final score of the game.
  final int totalScore;

  /// The sum of upper section scores (Ones through Sixes).
  final int upperSectionTotal;

  /// Bonus awarded if upper section total is 63 or more.
  final int bonus;

  /// The date and time when the game was completed.
  final DateTime completedAt;

  /// Number of players in the completed game (1 or 2).
  final int playerCount;

  /// Individual score for player 1. Defaults to 0 for single-player games.
  final int player1Score;

  /// Individual score for player 2. Defaults to 0 for single-player games.
  final int player2Score;

  /// Creates a [GameResult] from the given scores and timestamp.
  const GameResult({
    required this.totalScore,
    required this.upperSectionTotal,
    required this.bonus,
    required this.completedAt,
    this.playerCount = 1,
    this.player1Score = 0,
    this.player2Score = 0,
  });

  /// Returns the winner's score.
  /// For single-player: returns [totalScore].
  /// For 2-player: returns the highest individual player score.
  int get winnerScore {
    if (playerCount == 1) return totalScore;
    return player1Score > player2Score ? player1Score : player2Score;
  }

  /// Creates a copy of this result with the given fields replaced.
  GameResult copyWith({
    int? totalScore,
    int? upperSectionTotal,
    int? bonus,
    DateTime? completedAt,
    int? playerCount,
    int? player1Score,
    int? player2Score,
  }) {
    return GameResult(
      totalScore: totalScore ?? this.totalScore,
      upperSectionTotal: upperSectionTotal ?? this.upperSectionTotal,
      bonus: bonus ?? this.bonus,
      completedAt: completedAt ?? this.completedAt,
      playerCount: playerCount ?? this.playerCount,
      player1Score: player1Score ?? this.player1Score,
      player2Score: player2Score ?? this.player2Score,
    );
  }

  /// Converts this result to a JSON-serializable map.
  Map<String, dynamic> toJson() {
    return {
      'total_score': totalScore,
      'upper_section_total': upperSectionTotal,
      'bonus': bonus,
      'completed_at': completedAt.toIso8601String(),
      'player_count': playerCount,
      'player1_score': player1Score,
      'player2_score': player2Score,
    };
  }

  /// Creates a [GameResult] from a JSON map.
  factory GameResult.fromJson(Map<String, dynamic> json) {
    return GameResult(
      totalScore: json['total_score'] as int,
      upperSectionTotal: json['upper_section_total'] as int,
      bonus: json['bonus'] as int,
      completedAt: DateTime.parse(json['completed_at'] as String),
      playerCount: json['player_count'] as int? ?? 1,
      player1Score: json['player1_score'] as int? ?? 0,
      player2Score: json['player2_score'] as int? ?? 0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameResult &&
        other.totalScore == totalScore &&
        other.upperSectionTotal == upperSectionTotal &&
        other.bonus == bonus &&
        other.completedAt == completedAt &&
        other.playerCount == playerCount &&
        other.player1Score == player1Score &&
        other.player2Score == player2Score;
  }

  @override
  int get hashCode => Object.hash(
    totalScore,
    upperSectionTotal,
    bonus,
    completedAt,
    playerCount,
    player1Score,
    player2Score,
  );

  @override
  String toString() {
    return 'GameResult(totalScore: $totalScore, upperSectionTotal: $upperSectionTotal, bonus: $bonus, completedAt: $completedAt, playerCount: $playerCount, player1Score: $player1Score, player2Score: $player2Score)';
  }
}
