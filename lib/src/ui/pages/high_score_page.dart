import 'package:flutter/material.dart';
import '../../data/high_score_repository.dart';
import '../theme/app_theme.dart';

/// The high score page displaying the list of top scores.
///
/// Shows a ranked list of high scores with dates, with navigation
/// back to the previous screen.
class HighScorePage extends StatefulWidget {
  /// Callback for back navigation.
  final VoidCallback? onBackTapped;

  /// Creates a [HighScorePage].
  const HighScorePage({super.key, this.onBackTapped});

  @override
  State<HighScorePage> createState() => _HighScorePageState();
}

class _HighScorePageState extends State<HighScorePage> {
  final HighScoreRepository _repository = HighScoreRepository();
  List<HighScoreEntry> _scores = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true;
    });

    final scores = await _repository.getHighScores();

    setState(() {
      _scores = scores;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundGradientStart,
              AppTheme.backgroundGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header with back button
              _Header(onBackTapped: widget.onBackTapped),

              const SizedBox(height: AppSpacing.lg),

              // Title
              const Text(
                'High Scores',
                style: TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontSize: AppTypography.display,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Score List
              Expanded(
                child: _isLoading
                    ? const _LoadingIndicator()
                    : _ScoreList(scores: _scores, onRefresh: _loadScores),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header widget with back button.
class _Header extends StatelessWidget {
  final VoidCallback? onBackTapped;

  const _Header({this.onBackTapped});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackTapped,
            icon: const Icon(Icons.arrow_back, color: AppTheme.textOnPrimary),
            tooltip: 'Back',
          ),
        ],
      ),
    );
  }
}

/// Loading indicator for high scores.
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentYellow),
      ),
    );
  }
}

/// Score list widget displaying high scores.
class _ScoreList extends StatelessWidget {
  final List<HighScoreEntry> scores;
  final Future<void> Function() onRefresh;

  const _ScoreList({required this.scores, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    if (scores.isEmpty) {
      return const _EmptyState();
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: scores.length,
        itemBuilder: (context, index) {
          return _ScoreRow(
            rank: index + 1,
            entry: scores[index],
            isTopThree: index < 3,
          );
        },
      ),
    );
  }
}

/// Empty state when no high scores exist.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: AppTheme.accentYellow.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No scores yet!',
            style: TextStyle(
              color: AppTheme.textOnPrimary,
              fontSize: AppTypography.extraLarge,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Play a game to set your first high score',
            style: TextStyle(
              color: AppTheme.textOnPrimary,
              fontSize: AppTypography.medium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// A single score row in the high scores list.
class _ScoreRow extends StatelessWidget {
  final int rank;
  final HighScoreEntry entry;
  final bool isTopThree;

  const _ScoreRow({
    required this.rank,
    required this.entry,
    required this.isTopThree,
  });

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

  IconData _getMedalIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events;
      case 3:
        return Icons.emoji_events;
      default:
        return Icons.numbers;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[300]!;
      default:
        return AppTheme.textOnPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isTopThree
            ? AppTheme.accentYellow.withValues(alpha: 0.15)
            : AppTheme.surfaceDark.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: isTopThree
            ? Border.all(color: _getRankColor(rank), width: 2)
            : null,
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isTopThree)
                  Icon(
                    _getMedalIcon(rank),
                    color: _getRankColor(rank),
                    size: 24,
                  )
                else
                  Text(
                    '#$rank',
                    style: TextStyle(
                      color: _getRankColor(rank),
                      fontSize: AppTypography.large,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Score
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.score}',
                  style: TextStyle(
                    color: AppTheme.accentYellow,
                    fontSize: AppTypography.extraLarge,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(entry.date),
                  style: const TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontSize: AppTypography.small,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
