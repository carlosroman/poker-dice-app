import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';
import '../services/storage_service.dart';

/// A dialog widget that displays high scores.
///
/// Shows the top 10 high scores with player name, score, and date.
/// Provides options to clear all scores and dismiss the dialog.
class HighScoresDialog extends ConsumerWidget {
  /// Creates a [HighScoresDialog] widget.
  const HighScoresDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context, settingsNotifier),

            // High Scores List
            Expanded(child: _buildHighScoresList(context, settingsState)),

            // Footer with Clear button
            _buildFooter(context, settingsState, settingsNotifier),
          ],
        ),
      ),
    );
  }

  /// Builds the dialog header.
  Widget _buildHeader(BuildContext context, SettingsNotifier notifier) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, size: 28),
          const SizedBox(width: 12),
          Text(
            'High Scores',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.onPrimaryContainer.withOpacity(
                0.1,
              ),
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the high scores list.
  Widget _buildHighScoresList(BuildContext context, SettingsState state) {
    final theme = Theme.of(context);

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.highScores.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No high scores yet!',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to make the cut!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.highScores.length,
      itemBuilder: (context, index) {
        final entry = state.highScores[index];
        return _buildHighScoreRow(context, index + 1, entry);
      },
    );
  }

  /// Builds a single high score row.
  Widget _buildHighScoreRow(
    BuildContext context,
    int rank,
    HighScoreEntry entry,
  ) {
    final theme = Theme.of(context);

    // Determine rank color
    Color rankColor;
    switch (rank) {
      case 1:
        rankColor = Colors.amber;
        break;
      case 2:
        rankColor = Colors.grey[400]!;
        break;
      case 3:
        rankColor = Colors.orange[400]!;
        break;
      default:
        rankColor = theme.colorScheme.onSurfaceVariant.withOpacity(0.3);
    }

    // Format date
    final dateStr = _formatDate(entry.date);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Rank
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: rankColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? Colors.white : null,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Player Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.playerName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            // Score
            Text(
              _formatScore(entry.score),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the dialog footer with clear button.
  Widget _buildFooter(
    BuildContext context,
    SettingsState state,
    SettingsNotifier notifier,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          if (state.errorMessage != null) ...[
            Expanded(
              child: Text(
                state.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: OutlinedButton.icon(
              onPressed: state.highScores.isEmpty
                  ? null
                  : () => _showClearConfirmation(context, notifier),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Clear All Scores'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a confirmation dialog before clearing scores.
  Future<void> _showClearConfirmation(
    BuildContext context,
    SettingsNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear High Scores?'),
        content: const Text(
          'Are you sure you want to delete all high scores? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await notifier.clearHighScores();
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// Formats a score with thousands separator.
  String _formatScore(int score) {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Formats a date for display.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Shows the high scores dialog.
///
/// Use this function to display the high scores dialog from anywhere in the app.
Future<void> showHighScoresDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const HighScoresDialog(),
  );
}
