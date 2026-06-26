/// Represents the result of a completed poker dice game.
///
/// Stores the final score, upper section total, bonus, number of players,
/// and the timestamp when the game was completed.
class GameResult {
  /// The total final score of the game.
  final int totalScore;

  /// The sum of upper section scores (Aces through Sixes).
  final int upperSectionTotal;

  /// Bonus awarded if upper section total is 63 or more.
  final int bonus;

  /// The date and time when the game was completed.
  final DateTime completedAt;

  /// Number of players in the completed game (1 or 2).
  final int playerCount;

  /// Creates a [GameResult] from the given scores and timestamp.
  const GameResult({
    required this.totalScore,
    required this.upperSectionTotal,
    required this.bonus,
    required this.completedAt,
    this.playerCount = 1,
  });

  /// Creates a copy of this result with the given fields replaced.
  GameResult copyWith({
    int? totalScore,
    int? upperSectionTotal,
    int? bonus,
    DateTime? completedAt,
    int? playerCount,
  }) {
    return GameResult(
      totalScore: totalScore ?? this.totalScore,
      upperSectionTotal: upperSectionTotal ?? this.upperSectionTotal,
      bonus: bonus ?? this.bonus,
      completedAt: completedAt ?? this.completedAt,
      playerCount: playerCount ?? this.playerCount,
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
        other.playerCount == playerCount;
  }

  @override
  int get hashCode =>
      Object.hash(totalScore, upperSectionTotal, bonus, completedAt, playerCount);

  @override
  String toString() {
    return 'GameResult(totalScore: $totalScore, upperSectionTotal: $upperSectionTotal, bonus: $bonus, completedAt: $completedAt, playerCount: $playerCount)';
  }
}
