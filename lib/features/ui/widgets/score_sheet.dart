import 'package:flutter/material.dart';

/// Represents a scoring category in poker dice.
class ScoreCategory {
  final String name;
  final int minScore;
  final int maxScore;

  const ScoreCategory({
    required this.name,
    required this.minScore,
    required this.maxScore,
  });
}

/// A widget that displays the poker dice score sheet with all 13 categories.
class ScoreSheet extends StatelessWidget {
  /// All 13 scoring categories for poker dice.
  final List<ScoreCategory> categories;

  /// Potential scores for each category (null if already scored).
  final List<int?> potentialScores;

  /// Callback when a category is selected.
  final Function(int)? onCategorySelected;

  /// Whether the current turn is active (enables/disables interaction).
  final bool isTurnActive;

  const ScoreSheet({
    super.key,
    required this.categories,
    required this.potentialScores,
    this.onCategorySelected,
    this.isTurnActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final upperCategories = categories.take(6).toList();
    final lowerCategories = categories.skip(6).take(6).toList();
    final upperScores = potentialScores.take(6).toList();
    final lowerScores = potentialScores.skip(6).take(6).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Sheet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildSection(
                    context,
                    upperCategories,
                    upperScores,
                    'Upper Section',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSection(
                    context,
                    lowerCategories,
                    lowerScores,
                    'Lower Section',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildBonusIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    List<ScoreCategory> sectionCategories,
    List<int?> sectionScores,
    String title,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[300],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...sectionCategories.asMap().entries.map((entry) {
          final index = entry.key;
          final category = entry.value;
          final potentialScore = sectionScores[index];
          return _buildCategoryRow(context, category, potentialScore, index);
        }),
      ],
    );
  }

  Widget _buildCategoryRow(
    BuildContext context,
    ScoreCategory category,
    int? potentialScore,
    int index,
  ) {
    final isScored = potentialScore == null;
    final canInteract = isTurnActive && !isScored && onCategorySelected != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canInteract ? () => onCategorySelected!(index) : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: canInteract ? Colors.grey[800] : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isScored ? Colors.blue : Colors.grey[600]!,
                width: isScored ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    category.name,
                    style: TextStyle(
                      color: canInteract
                          ? Colors.grey[200]
                          : isScored
                          ? Colors.blue[300]
                          : Colors.grey[500],
                      fontWeight: isScored
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                if (isScored)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '0',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    potentialScore.toString(),
                    style: TextStyle(
                      color: canInteract ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBonusIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[600]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Bonus',
            style: TextStyle(
              color: Colors.grey[300],
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '0',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
