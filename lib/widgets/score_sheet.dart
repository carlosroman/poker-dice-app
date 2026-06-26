import 'package:flutter/material.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/services/scoring_service.dart';
import 'package:poker_dice/widgets/category_row.dart';

/// Score sheet for the poker dice game.
///
/// Supports single-player and 2-player modes. In 2-player mode, shows
/// both players' scores side by side with a turn indicator.
///
/// Left column: Upper section (Minor) — number categories + Bonus row.
/// Right column: Lower section (Major) — combination categories.
class ScoreSheet extends StatelessWidget {
  /// The current dice values used to calculate preview scores.
  final List<Dice> dice;

  /// Categories that have already been scored (immutable map).
  final Map<ScoreCategory, int> scoredCategories;

  /// The category currently selected by the player (pending confirmation).
  final ScoreCategory? selectedCategory;

  /// Callback invoked when the player taps a selectable category.
  final void Function(ScoreCategory category) onCategorySelect;

  /// Total of the upper section (number categories).
  final int upperTotal;

  /// Bonus value: 35 if [upperTotal] >= 63, otherwise 0.
  final int bonus;

  /// Number of players (1 or 2). Defaults to 1.
  final int playerCount;

  /// Current player index (0-based). Used in 2-player mode.
  final int currentPlayer;

  /// Per-player scores for 2-player mode.
  /// Key is player index (0 or 1), value is category → score map.
  final Map<int, Map<ScoreCategory, int?>>? playerScoredCategories;

  /// The category most recently scored (across both players).
  final ScoreCategory? lastScoredCategory;

  const ScoreSheet({
    super.key,
    required this.dice,
    required this.scoredCategories,
    this.selectedCategory,
    required this.onCategorySelect,
    this.upperTotal = 0,
    this.bonus = 0,
    this.playerCount = 1,
    this.currentPlayer = 0,
    this.playerScoredCategories,
    this.lastScoredCategory,
  });

  /// Returns the row state for a given [category].
  CategoryRowState _rowState(ScoreCategory category) {
    if (scoredCategories.containsKey(category)) {
      return CategoryRowState.scored;
    }
    if (selectedCategory == category) {
      return CategoryRowState.selected;
    }
    return CategoryRowState.selectable;
  }

  /// Returns the preview score for a [category] based on current dice.
  int? _previewScore(ScoreCategory category) {
    return ScoringService().calculateScore(dice, category);
  }

  @override
  Widget build(BuildContext context) {
    if (playerCount > 1) {
      return _buildMultiplayer(context);
    }
    return _buildSinglePlayer(context);
  }

  Widget _buildSinglePlayer(BuildContext context) {
    final upperCategories = ScoreCategory.values
        .where((c) => c.isUpper)
        .toList();
    final lowerCategories = ScoreCategory.values
        .where((c) => !c.isUpper)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 300;

        if (useTwoColumns) {
          return Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: _buildSection(context, 'Minor', upperCategories),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildSection(context, 'Major', lowerCategories),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildSection(context, 'Minor', upperCategories),
              const SizedBox(height: 8),
              _buildSection(context, 'Major', lowerCategories),
            ],
          ),
        );
      },
    );
  }

  /// Builds the 2-player layout with side-by-side player panels.
  Widget _buildMultiplayer(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final p0Scores =
        playerScoredCategories?[0] ??
        scoredCategories.cast<ScoreCategory, int?>();
    final p1Scores =
        playerScoredCategories?[1] ?? const <ScoreCategory, int?>{};

    final upperCategories = ScoreCategory.values
        .where((c) => c.isUpper)
        .toList();
    final lowerCategories = ScoreCategory.values
        .where((c) => !c.isUpper)
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 400;

        if (useTwoColumns) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildPlayerPanel(
                  context,
                  0,
                  p0Scores,
                  upperCategories,
                  lowerCategories,
                  colors,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPlayerPanel(
                  context,
                  1,
                  p1Scores,
                  upperCategories,
                  lowerCategories,
                  colors,
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildPlayerPanel(
                context,
                0,
                p0Scores,
                upperCategories,
                lowerCategories,
                colors,
              ),
              const SizedBox(height: 8),
              _buildPlayerPanel(
                context,
                1,
                p1Scores,
                upperCategories,
                lowerCategories,
                colors,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds a single player's panel with header and score sections.
  Widget _buildPlayerPanel(
    BuildContext context,
    int playerIndex,
    Map<ScoreCategory, int?> scores,
    List<ScoreCategory> upperCategories,
    List<ScoreCategory> lowerCategories,
    ColorScheme colors,
  ) {
    final theme = Theme.of(context);
    final isCurrent = currentPlayer == playerIndex;

    // Calculate upper total for this player
    final playerUpperTotal = upperCategories.fold(
      0,
      (sum, cat) => sum + (scores[cat] ?? 0),
    );
    final playerBonus = playerUpperTotal >= 63 ? 35 : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Player header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isCurrent
                ? colors.primaryContainer.withValues(alpha: 0.5)
                : colors.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Player ${playerIndex + 1}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isCurrent ? colors.primary : null,
                    ),
                  ),
                  if (isCurrent) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                _playerTotal(scores).toString(),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // Score sections
        ClipRRect(
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(12),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildReadOnlySection(
                  context,
                  'Minor',
                  upperCategories,
                  scores,
                  playerUpperTotal,
                  playerBonus,
                  isCurrent,
                ),
                const Divider(height: 1),
                _buildReadOnlySection(
                  context,
                  'Major',
                  lowerCategories,
                  scores,
                  playerUpperTotal,
                  playerBonus,
                  isCurrent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a section of category rows for a player.
  /// For the current player, rows are interactive. For the other player, read-only.
  Widget _buildReadOnlySection(
    BuildContext context,
    String title,
    List<ScoreCategory> categories,
    Map<ScoreCategory, int?> scores,
    int upperTotal,
    int bonus,
    bool isInteractive,
  ) {
    final isUpper = categories.isNotEmpty && categories.first.isUpper;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(context, title),
        ...categories.map((category) {
          final score = scores[category];
          final isScored = score != null;

          if (isInteractive) {
            return CategoryRow(
              key: ValueKey('${categories.first.name}_$title'),
              category: category,
              state: _rowState(category),
              previewScore: _previewScore(category),
              finalScore: scoredCategories[category],
              onTap: _rowState(category) == CategoryRowState.selectable
                  ? () => onCategorySelect(category)
                  : null,
              isLastScored: category == lastScoredCategory,
            );
          }

          // Read-only display for other player
          return CategoryRow(
            key: ValueKey('${categories.first.name}_$title'),
            category: category,
            state: isScored
                ? CategoryRowState.scored
                : CategoryRowState.disabled,
            finalScore: score ?? 0,
            isLastScored: category == lastScoredCategory,
          );
        }),
        if (isUpper) ...[const SizedBox(height: 4), _buildBonusRow(context)],
      ],
    );
  }

  /// Calculates total score from a player's scores map.
  int _playerTotal(Map<ScoreCategory, int?> scores) {
    return scores.values.fold(0, (sum, score) => sum + (score ?? 0));
  }

  /// Builds a single column section with header, category rows, and optional bonus.
  Widget _buildSection(
    BuildContext context,
    String title,
    List<ScoreCategory> categories,
  ) {
    final isUpper = categories.isNotEmpty && categories.first.isUpper;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(context, title),
        ...categories.map(
          (category) => CategoryRow(
            key: ValueKey(category.name),
            category: category,
            state: _rowState(category),
            previewScore: _previewScore(category),
            finalScore: scoredCategories[category],
            onTap: _rowState(category) == CategoryRowState.selectable
                ? () => onCategorySelect(category)
                : null,
          ),
        ),
        if (isUpper) ...[const SizedBox(height: 4), _buildBonusRow(context)],
      ],
    );
  }

  /// Builds the section header with title and separator.
  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
          Expanded(
            child: Divider(
              color: theme.colorScheme.outlineVariant,
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the bonus row showing progress toward 63 and the +35 indicator.
  Widget _buildBonusRow(BuildContext context) {
    final theme = Theme.of(context);
    final hasBonus = upperTotal >= 63;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: hasBonus
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : null,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: hasBonus
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
          const SizedBox(width: 3),
          Text(
            'Bonus',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '$upperTotal/63',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            hasBonus ? '+35' : '+0',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: hasBonus
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}
