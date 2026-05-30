import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/providers/settings_provider.dart';
import 'package:poker_dice/services/storage_service.dart';

/// A dialog that displays the list of stored high scores.
///
/// Shows scores in descending order with their achievement dates.
/// Displays loading and empty states appropriately.
class HighScoresDialog extends ConsumerWidget {
  /// Creates a high scores dialog.
  const HighScoresDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<HighScore>> scoresAsync =
        ref.watch(settingsProvider);

    return Dialog(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            SizedBox(
              height: 300,
              child: scoresAsync.when(
                data: (scores) => _buildScoresList(context, scores),
                loading: () => const _LoadingState(),
                error: (_, __) => const _ErrorState(),
              ),
            ),
            const Divider(height: 1),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  /// Builds the dialog header with title and icon.
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber),
          const SizedBox(width: 12),
          Text(
            'High Scores',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }

  /// Builds the scrollable list of high scores.
  Widget _buildScoresList(BuildContext context, List<HighScore> scores) {
    if (scores.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: scores.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final HighScore score = scores[index];
        return _HighScoreRow(
          rank: index + 1,
          score: score,
        );
      },
    );
  }

  /// Builds the dialog action buttons.
  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Displays a single high score entry in the list.
class _HighScoreRow extends StatelessWidget {
  /// Creates a high score row.
  const _HighScoreRow({
    required this.rank,
    required this.score,
  });

  /// The position in the rankings (1-based).
  final int rank;

  /// The high score data to display.
  final HighScore score;

  @override
  Widget build(BuildContext context) {
    final String dateStr =
        '${score.timestamp.year}-${score.timestamp.month.toString().padLeft(2, '0')}-${score.timestamp.day.toString().padLeft(2, '0')}';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getRankColor(context),
        child: Text(
          '$rank',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        score.score.toString(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(dateStr),
      trailing: Icon(
        _getRankIcon(),
        color: _getRankColor(context),
      ),
    );
  }

  /// Returns the appropriate icon based on rank.
  IconData _getRankIcon() {
    switch (rank) {
      case 1:
        return Icons.workspace_premium;
      case 2:
        return Icons.workspace_premium;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.star_border;
    }
  }

  /// Returns the appropriate color based on rank.
  Color _getRankColor(BuildContext context) {
    switch (rank) {
      case 1:
        return Colors.amber.shade700;
      case 2:
        return Colors.grey.shade400;
      case 3:
        return Colors.brown.shade300;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }
}

/// Displays a loading indicator while scores are being fetched.
class _LoadingState extends StatelessWidget {
  /// Creates a loading state widget.
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// Displays an error message when scores cannot be loaded.
class _ErrorState extends StatelessWidget {
  /// Creates an error state widget.
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Unable to load high scores',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

/// Displays a message when no high scores have been recorded yet.
class _EmptyState extends StatelessWidget {
  /// Creates an empty state widget.
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No high scores yet',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Complete a game to set a score',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
