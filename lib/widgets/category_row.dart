import 'package:flutter/material.dart';
import 'package:poker_dice/models/score_category.dart';

/// Visual state of a [CategoryRow].
enum CategoryRowState {
  /// Row shows a preview score and is tappable.
  selectable,

  /// Row is currently highlighted (user has tapped it).
  selected,

  /// Row has a committed score; not tappable.
  scored,

  /// Row is faded out and not tappable.
  disabled,
}

/// A single row in the score sheet for one [ScoreCategory].
///
/// Displays the category icon and name on the left, and either a preview
/// score or a final committed score on the right. Appearance changes based
/// on [state].
class CategoryRow extends StatelessWidget {
  /// The scoring category this row represents.
  final ScoreCategory category;

  /// The current visual [CategoryRowState].
  final CategoryRowState state;

  /// Preview score shown when [state] is [CategoryRowState.selectable].
  ///
  /// This is the score the player would get if they committed this category
  /// with the current dice roll.
  final int? previewScore;

  /// Final committed score shown when [state] is [CategoryRowState.scored].
  final int? finalScore;

  /// Called when the row is tapped and [state] is selectable.
  final VoidCallback? onTap;

  /// Whether this category was the most recently scored.
  ///
  /// When true, a yellow dot indicator is shown next to the category name.
  final bool isLastScored;

  /// Creates a [CategoryRow].
  const CategoryRow({
    super.key,
    required this.category,
    this.state = CategoryRowState.selectable,
    this.previewScore,
    this.finalScore,
    this.onTap,
    this.isLastScored = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = state == CategoryRowState.selectable;

    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: _buildDecoration(theme),
        child: Row(
          children: [
            Icon(category.icon, color: _iconColor(theme)),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      category.displayName,
                      style: _textStyle(theme),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isLastScored) const SizedBox(width: 6),
                  if (isLastScored)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildScore(theme),
          ],
        ),
      ),
    );
  }

  BoxDecoration? _buildDecoration(ThemeData theme) {
    switch (state) {
      case CategoryRowState.selected:
        return BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
        );
      case CategoryRowState.scored:
        return BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.3,
          ),
          borderRadius: BorderRadius.circular(8),
        );
      case CategoryRowState.disabled:
        return null;
      case CategoryRowState.selectable:
        return BoxDecoration(borderRadius: BorderRadius.circular(8));
    }
  }

  Color _iconColor(ThemeData theme) {
    switch (state) {
      case CategoryRowState.selected:
        return theme.colorScheme.primary;
      case CategoryRowState.scored:
        return theme.colorScheme.onSurface;
      case CategoryRowState.disabled:
        return theme.colorScheme.onSurface.withValues(alpha: 0.38);
      case CategoryRowState.selectable:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  TextStyle _textStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.bodyMedium;
    switch (state) {
      case CategoryRowState.selected:
        return baseStyle?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ) ??
            const TextStyle();
      case CategoryRowState.scored:
        return baseStyle?.copyWith(color: theme.colorScheme.onSurface) ??
            const TextStyle();
      case CategoryRowState.disabled:
        return baseStyle?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
            ) ??
            const TextStyle();
      case CategoryRowState.selectable:
        return baseStyle ?? const TextStyle();
    }
  }

  Widget _buildScore(ThemeData theme) {
    switch (state) {
      case CategoryRowState.selectable:
        final score = previewScore;
        if (score == null) {
          return Text(
            '-',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          );
        }
        return Text(
          score.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        );
      case CategoryRowState.selected:
        final score = previewScore;
        if (score == null) {
          return Text(
            '-',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          );
        }
        return Text(
          score.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        );
      case CategoryRowState.scored:
        final score = finalScore ?? 0;
        return Text(
          score.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        );
      case CategoryRowState.disabled:
        return Text(
          '-',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
          ),
        );
    }
  }
}
