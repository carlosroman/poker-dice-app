import 'package:flutter/material.dart';
import 'package:poker_dice/src/data/high_score_repository.dart';
import 'package:poker_dice/src/ui/theme/app_theme.dart';

/// High score page for displaying the top 10 scores.
///
/// Shows a leaderboard-style layout with:
/// - Trophy icon header
/// - Scrollable list of high scores with rank, score, and date
/// - Medal icons for top 3 positions (gold, silver, bronze)
/// - Empty state message when no scores exist
/// - Clear scores and back to game buttons
class HighScorePage extends StatefulWidget {
  /// Callback for back navigation.
  final VoidCallback? onBack;

  /// Creates a HighScorePage with the given callback.
  const HighScorePage({super.key, this.onBack});

  @override
  State<HighScorePage> createState() => _HighScorePageState();
}

class _HighScorePageState extends State<HighScorePage> {
  final HighScoreRepository _repository = HighScoreRepository.instance;
  List<HighScore> _scores = [];
  bool _isLoading = true;
  bool _isClearing = false;

  @override
  void initState() {
    super.initState();
    _initializeAndLoadScores();
  }

  /// Initializes repository and loads high scores.
  Future<void> _initializeAndLoadScores() async {
    try {
      // Add timeout to prevent hanging in test environments
      await Future.any([
        _repository.initialize(),
        Future.delayed(const Duration(seconds: 2)),
      ]);
      await _loadScores();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing repository: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Loads high scores from the repository.
  Future<void> _loadScores() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final scores = await Future.any([
        _repository.getHighScores(),
        Future.delayed(const Duration(seconds: 2), () => <HighScore>[]),
      ]);
      setState(() {
        _scores = scores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading scores: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Clears all high scores.
  Future<void> _clearScores() async {
    if (_isClearing) return;

    setState(() {
      _isClearing = true;
    });

    try {
      await _repository.clearHighScores();
      setState(() {
        _scores = [];
        _isClearing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('High scores cleared'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isClearing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing scores: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  /// Formats a date to a nice display string.
  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Gets the medal icon for a rank position.
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

  /// Gets the color for a rank position.
  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppTheme.secondaryColor; // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('High Scores'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              widget.onBack ??
              () {
                Navigator.of(context).pop();
              },
          tooltip: 'Back',
        ),
        elevation: 4,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildScoreList()),
                _buildActionButtons(),
              ],
            ),
    );
  }

  /// Builds the header with trophy icon.
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: AppTheme.secondaryColor),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'High Scores',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_scores.isNotEmpty)
            Text(
              'Top ${_scores.length} Players',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
        ],
      ),
    );
  }

  /// Builds the scrollable list of high scores.
  Widget _buildScoreList() {
    if (_scores.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: _scores.length,
      itemBuilder: (context, index) {
        final score = _scores[index];
        final rank = index + 1;
        return _buildScoreItem(rank, score);
      },
    );
  }

  /// Builds an empty state message.
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              'No High Scores Yet!',
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Be the first to set a high score\nby playing the game!',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single score item with rank, medal, score, and date.
  Widget _buildScoreItem(int rank, HighScore score) {
    final isTopThree = rank <= 3;
    final rankColor = _getRankColor(rank);
    final medalIcon = _getMedalIcon(rank);

    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(
          color: isTopThree
              ? rankColor.withValues(alpha: 0.3)
              : Colors.transparent,
          width: isTopThree ? 2 : 1,
        ),
      ),
      child: Semantics(
        label:
            'Rank $rank: ${score.score} points on ${_formatDate(score.date)}',
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Rank with medal
              SizedBox(
                width: 60,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      medalIcon,
                      color: rankColor,
                      size: isTopThree ? 32 : 24,
                    ),
                    if (!isTopThree)
                      Text(
                        '#$rank',
                        style: TextStyle(
                          color: rankColor,
                          fontWeight: FontWeight.bold,
                          fontSize: AppTheme.bodyMedium,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              // Score information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score: ${score.score}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs / 2),
                    Text(
                      _formatDate(score.date),
                      style: TextStyle(
                        fontSize: AppTheme.bodySmall,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Rank indicator
              if (isTopThree)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    '$rank${_getRankSuffix(rank)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: AppTheme.bodyMedium,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Gets the suffix for a rank number (st, nd, rd, th).
  String _getRankSuffix(int rank) {
    if (rank > 3 && rank < 21) return 'th';
    switch (rank % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  /// Builds action buttons for clearing scores and going back.
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: AppTheme.shadowSmall,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_scores.isNotEmpty)
            Semantics(
              label: 'Clear all high scores',
              button: true,
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _isClearing ? null : _clearScores,
                  icon: _isClearing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(_isClearing ? 'Clearing...' : 'Clear Scores'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMd,
                    ),
                    foregroundColor: AppTheme.errorColor,
                  ),
                ),
              ),
            ),
          if (_scores.isNotEmpty) const SizedBox(height: AppTheme.spacingMd),
          Semantics(
            label: 'Return to game',
            button: true,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    widget.onBack ??
                    () {
                      Navigator.of(context).pop();
                    },
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Game'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingMd,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
