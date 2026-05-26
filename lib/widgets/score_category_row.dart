import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/models/category.dart';

/// Displays a single scoring category row in the scorecard.
///
/// Shows three visual states:
/// - **Available**: empty score slot, tappable to select.
/// - **Selected**: highlighted background, indicates current pick.
/// - **Scored**: displays the recorded score, not tappable.
class ScoreCategoryRow extends ConsumerWidget {
  /// The scoring category this row represents.
  final Category category;

  /// The score already recorded for this category, or null if unscored.
  final int? score;

  /// Whether this category is currently selected by the player.
  final bool isSelected;

  /// Called when the row is tapped and the category is available.
  final void Function(Category category) onTap;

  const ScoreCategoryRow({
    super.key,
    required this.category,
    this.score,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final isScored = score != null;

    return InkWell(
      onTap: isScored ? null : () => onTap(category),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                category.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onSecondaryContainer
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(
              width: 40,
              child: Text(
                score?.toString() ?? '-',
                textAlign: TextAlign.end,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isScored
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isScored ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
