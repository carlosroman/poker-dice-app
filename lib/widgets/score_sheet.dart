import 'package:flutter/material.dart';
import 'package:poker_dice/models/dice.dart';
import 'package:poker_dice/models/score_category.dart';
import 'package:poker_dice/services/scoring_service.dart';
import 'package:poker_dice/widgets/category_row.dart';

/// Two-column score sheet for the poker dice game.
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

  const ScoreSheet({
    super.key,
    required this.dice,
    required this.scoredCategories,
    this.selectedCategory,
    required this.onCategorySelect,
    this.upperTotal = 0,
    this.bonus = 0,
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
              Expanded(child: _buildSection(context, 'Minor', upperCategories)),
              const SizedBox(width: 8),
              Expanded(child: _buildSection(context, 'Major', lowerCategories)),
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

  /// Builds a single column section with header, category rows, and optional bonus.
  Widget _buildSection(
    BuildContext context,
    String title,
    List<ScoreCategory> categories,
  ) {
    final isUpper = categories.isNotEmpty && categories.first.isUpper;

    return Column(
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
            style: theme.textTheme.labelSmall?.copyWith(
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
