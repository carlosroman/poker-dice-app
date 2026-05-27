import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/models/category.dart';
import 'package:poker_dice/providers/game_provider.dart';
import 'package:poker_dice/widgets/bonus_indicator.dart';
import 'package:poker_dice/widgets/score_category_row.dart';

/// Displays the scorecard with Upper and Lower section columns.
///
/// Layout: Two-column grid with 6 upper categories on the left
/// and 8 lower categories on the right, plus bonus progress.
class Scorecard extends ConsumerWidget {
  const Scorecard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameStateProvider);
    final notifier = ref.watch(gameNotifierProvider.notifier);
    final theme = Theme.of(context);

    final upperCategories = Category.getUpperCategories();
    final lowerCategories = Category.getLowerCategories();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section headers
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'UPPER',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'LOWER',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Score rows - 8 rows to match lower section length
            // Upper section has 6 categories, so last 2 rows show only lower
            ...List.generate(lowerCategories.length, (index) {
              final lowerCategory = lowerCategories[index];

              return Row(
                children: [
                  Expanded(
                    child: index < upperCategories.length
                        ? ScoreCategoryRow(
                            category: upperCategories[index],
                            score: gameState.scores[upperCategories[index]],
                            isSelected:
                                gameState.selectedCategory ==
                                upperCategories[index],
                            onTap: notifier.selectCategory,
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ScoreCategoryRow(
                      category: lowerCategory,
                      score: gameState.scores[lowerCategory],
                      isSelected: gameState.selectedCategory == lowerCategory,
                      onTap: notifier.selectCategory,
                    ),
                  ),
                ],
              );
            }),
            // Upper total row
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Upper total:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${gameState.upperSectionTotal}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            // Bonus indicator (spans full width)
            const Padding(padding: EdgeInsets.only(top: 8), child: Divider()),
            const BonusIndicator(),
          ],
        ),
      ),
    );
  }
}
