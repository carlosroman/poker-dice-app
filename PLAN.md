# Yatzy Dice Game - Implementation Plan

## Overview

This document outlines the implementation plan for a **Yatzy dice game** built with Flutter. The game is single-player (extensible to 2-4 players later) and targets Android and Web platforms.

**UI Design:** Based on `Yatzy_layout.png` - compact two-column layout with blue gradient background, yellow/orange accents.

---

## Scoring Rules (Final)

### Upper Section
| Category | Description | Score |
|----------|-------------|-------|
| Aces | Sum of all dice showing 1 | 1 point each |
| Twos | Sum of all dice showing 2 | 2 points each |
| Threes | Sum of all dice showing 3 | 3 points each |
| Fours | Sum of all dice showing 4 | 4 points each |
| Fives | Sum of all dice showing 5 | 5 points each |
| Sixes | Sum of all dice showing 6 | 6 points each |
| **Bonus** | If upper section total ≥ 63 | +35 points |

### Lower Section
| Category | Description | Score |
|----------|-------------|-------|
| Three of a Kind | 3+ dice with same value | Sum of ALL dice |
| Four of a Kind | 4+ dice with same value | Sum of ALL dice |
| Full House | Exactly 3 of one + 2 of another | 25 points |
| Small Straight | 4 consecutive values (1-2-3-4, 2-3-4-5, 3-4-5-6) | 30 points |
| Large Straight | 5 consecutive values (1-2-3-4-5, 2-3-4-5-6) | 40 points |
| Yatzy | All 5 dice match | 50 points |
| Chance | Any combination | Sum of ALL dice |

### Special Rules

**Yatzy Bonus:**
- First Yatzy: 50 points
- Each additional Yatzy: +50 bonus (e.g., 2nd Yatzy = 100 total, 3rd Yatzy = 150 total)
- Bonus applies if user selects Yatzy category and already has a Yatzy scored
- Display "+50" indicator when bonus applies

**Full House Validation:**
- Must be exactly 3 of one value + 2 of another
- 4 of a kind + 1 does NOT count as Full House

**Small Straight:**
- Valid combinations: [1,2,3,4], [2,3,4,5], [3,4,5,6]
- 5 consecutive (large straight) can be scored as small straight OR large straight (user chooses)

**Category Selection:**
- User clicks any row to select category, then clicks PLAY button to score
- User can score 0 in any category if they choose
- If Yatzy rolled but Yatzy already scored, user gets +50 bonus in any category they select
- Each row shows: [icon] | [potential score] | [current score in light blue box]

**Category Icons:**

*Upper Section (Upper Column):*
- Aces: Die face with 1 dot
- Twos: Die face with 2 dots
- Threes: Die face with 3 dots
- Fours: Die face with 4 dots
- Fives: Die face with 5 dots
- Sixes: Die face with 6 dots

*Lower Section (Lower Column):*
- ThreeOfKind: "3x" icon
- FourOfKind: "4x" icon
- FullHouse: House icon
- SmallStraight: Cards with "small" label
- LargeStraight: Cards with "large" label
- Yatzy: "Yatzy" text
- Chance: "?" icon

**Game End:**
- Game ends when all 13 categories are filled
- Show Game Over screen with total score
- User can start new game

---

## Implementation Phases

### Phase 1: Core Game Logic & Data Models

**Goal:** Implement foundational game mechanics without UI

#### Step 1.1: Die Class
- File: `lib/src/domain/models/die.dart`
- Properties:
  - `value`: int (1-6)
  - `held`: bool (default false)
- Methods:
  - `roll()`: Random value 1-6
  - `toggleHold()`: Toggle held state
  - `copyWith()`: For immutability
- Tests: `test/domain/models/die_test.dart`
- Commit work once done and passes QA.

#### Step 1.2: ScoreCategory Enum
- File: `lib/src/domain/models/score_category.dart`
- Values: Aces, Twos, Threes, Fours, Fives, Sixes, ThreeOfKind, FourOfKind, FullHouse, SmallStraight, LargeStraight, Yatzy, Chance
- Properties:
  - `displayName`: String for UI
  - `section`: Upper or Lower
- Tests: `test/domain/models/score_category_test.dart`
- Commit work once done and passes QA.

#### Step 1.3: ScoreSheet Class
- File: `lib/src/domain/models/score_sheet.dart`
- Properties:
  - `scores`: Map<ScoreCategory, int?> (null = not scored)
  - `yatzyCount`: int (tracks total Yatzy rolled)
- Methods:
  - `score(category, dice)`: Calculate and store score
  - `getTotal()`: Sum all scores + bonus
  - `getUpperTotal()`: Sum upper section
  - `getLowerTotal()`: Sum lower section
  - `getBonus()`: 35 if upper ≥ 63, else 0
  - `isCategoryScored(category)`: Check if filled
  - `getEmptyCategories()`: List of unscored categories
  - `copyWith()`: For immutability
- Tests: `test/domain/models/score_sheet_test.dart`
- Commit work once done and passes QA.

#### Step 1.4: GameRound Class
- File: `lib/src/domain/models/game_round.dart`
- Properties:
  - `dice`: List<Die> (5 dice)
  - `rollCount`: int (0-3, starts at 0)
- Methods:
  - `rollDice(keptIndices)`: Roll unheld dice
  - `toggleDie(index)`: Toggle held state
  - `canRoll()`: rollCount < 3
  - `copyWith()`: For immutability
- Tests: `test/domain/models/game_round_test.dart`
- Commit work once done and passes QA.

#### Step 1.5: Scorer Class
- File: `lib/src/domain/scoring/scorer.dart`
- Static methods for each category:
  - `scoreAces(dice)`, `scoreTwos(dice)`, etc.
  - `scoreThreeOfKind(dice)`: Sum all if 3+ match
  - `scoreFourOfKind(dice)`: Sum all if 4+ match
  - `scoreFullHouse(dice)`: 25 if exactly 3+2
  - `scoreSmallStraight(dice)`: 30 if 4 consecutive
  - `scoreLargeStraight(dice)`: 40 if 5 consecutive
  - `scoreYatzy(dice, bonus)`: 50 + (bonus * 50) if all match
  - `scoreChance(dice)`: Sum all
- Helper methods:
  - `_countOccurrences(dice)`: Map<value, count>
  - `_isConsecutive(sortedDice)`: Check if consecutive
- Tests: `test/domain/scoring/scorer_test.dart` (extensive edge cases)
- Commit work once done and passes QA.

#### Step 1.6: GameState Class
- File: `lib/src/domain/game_state.dart`
- Properties:
  - `currentRound`: GameRound
  - `scoreSheet`: ScoreSheet
  - `isGameOver`: bool
- Methods:
  - `rollDice()`: Roll unheld dice, increment rollCount
  - `toggleDie(index)`: Toggle held state
  - `selectCategory(category)`: Score category, start new round
  - `newGame()`: Reset state
  - `getValidCategories()`: Categories user can score in
- Tests: `test/domain/game_state_test.dart` (integration tests)
- Commit work once done and passes QA.

**Phase 1 Tests:**
- Unit tests for all classes
- Integration test: Complete game flow from start to finish
- Edge cases: 4+1 not Full House, Yatzy bonus, small/large straight overlap

---

### Phase 2: UI Foundation & Theme

**Goal:** Build UI matching `Yatzy_layout.png` design

#### Step 2.1: Theme Configuration
- File: `lib/src/ui/theme/app_theme.dart`
- Color scheme: Blue gradient (#1E88E5 to #1565C0), yellow/orange accents (#FFB74D, #FF9800)
- White bold text for scores, light blue score boxes (#4FC3F7)
- Typography, spacing for compact mobile layout
- Tests: `test/ui/theme/app_theme_test.dart`
- Commit work once done and passes QA.

#### Step 2.2: DieWidget Component
- File: `lib/src/ui/components/die_widget.dart`
- White rounded square die face with black dots (1-6)
- Orange border (#FF9800) when held (no separate checkbox)
- Subtle shadow effect
- Tests: `test/ui/components/die_widget_test.dart`
- Commit work once done and passes QA.

#### Step 2.3: ScoreRow Component
- File: `lib/src/ui/components/score_row.dart`
- Layout: [Die/Category Icon] | [Potential Score] | [Current Score Box]
- Icon: Yellow square with die face (1-6) or symbol (3x, 4x, house, cards, Yatzy, ?)
- Potential Score: White text showing calculated score for current dice
- Current Score: Light blue box with white text (empty if not scored)
- Clickable to select category for scoring
- Yatzy bonus indicator (+50) when applicable
- Tests: `test/ui/components/score_row_test.dart`
- Commit work once done and passes QA.

#### Step 2.4: BonusProgress Component
- File: `lib/src/ui/components/bonus_progress.dart`
- Displays "X/63" progress toward bonus (e.g., "37/63")
- Shows "+35" bonus indicator when upper total ≥ 63
- Compact circular or pill-shaped design
- Tests: `test/ui/components/bonus_progress_test.dart`
- Commit work once done and passes QA.

#### Step 2.5: RollButton Component
- File: `lib/src/ui/components/roll_button.dart`
- Dark blue button showing "ROLL" and roll count: "ROLL 0", "ROLL 1", "ROLL 2"
- Disabled and dimmed when rollCount = 3 (max rolls reached)
- Tests: `test/ui/components/roll_button_test.dart`
- Commit work once done and passes QA.

#### Step 2.6: PlayButton Component
- File: `lib/src/ui/components/play_button.dart`
- White button with orange "PLAY" text
- Enabled when user has rolled and has empty categories
- Disabled when game over or no valid selections
- Tests: `test/ui/components/play_button_test.dart`
- Commit work once done and passes QA.

#### Step 2.7: ScoreSheet Widget
- File: `lib/src/ui/components/score_sheet.dart`
- Two-column layout with headers "Upper" (left) and "Lower" (right)
- **Upper Column (Upper Section):** Rows for Aces-Sixes with die icons
- **Lower Column (Lower Section):** Rows for ThreeKind, FourKind, FullHouse, Straights, Yatzy, Chance with icons
- BonusProgress row at bottom of Upper column
- Tests: `test/ui/components/score_sheet_test.dart`
- Commit work once done and passes QA.

#### Step 2.8: GamePage Layout
- File: `lib/src/ui/pages/game_page.dart`
- **Header:** Score (top center), back button (left), menu button (right)
- **Score Sheet (middle):** Two columns - Upper and Lower section
- **Dice Row:** 5 dice horizontally aligned, tap to toggle hold (orange border)
- **Button Row:** ROLL button (left, dark) + PLAY button (right, white/orange)
- Tests: `test/ui/pages/game_page_test.dart`
- Commit work once done and passes QA.

#### Step 2.9: GameOverPage Layout
- File: `lib/src/ui/pages/game_over_page.dart`
- Large final score display (centered)
- Category breakdown (all 13 categories with scores)
- "New Game" button
- Tests: `test/ui/pages/game_over_page_test.dart`
- Commit work once done and passes QA.

**Phase 2 Tests:**
- Widget tests for all components
- Integration test: UI renders all components correctly

---

### Phase 3: Game Flow & User Interactions

**Goal:** Connect UI to game logic for complete gameplay

#### Step 3.1: GameBloc State Management
- File: `lib/src/bloc/game_bloc.dart`
- Manages GameLogic and UI state
- Handles roll, hold, category selection
- Emits state changes for UI updates
- Tests: `test/bloc/game_bloc_test.dart`
- Commit work once done and passes QA.

#### Step 3.2: Complete GamePage Implementation
- Wire up GameBloc to UI
- Handle all user interactions
- Tests: Widget tests for interactions
- Commit work once done and passes QA.

#### Step 3.3: Animations
- Dice roll animation (3D effect or scale/fade)
- Score update animation
- Category selection feedback
- Tests: Integration tests with animations
- Commit work once done and passes QA.

**Phase 3 Tests:**
- Widget tests for game flow (roll, hold, select)
- Integration test: Complete game from start to end
- Integration test: Verify score sheet updates correctly

---

### Phase 4: High Score Tracking & Persistence

**Goal:** Implement persistent high score storage

#### Step 4.1: Add Dependency
- Add `shared_preferences: ^2.2.0` to pubspec.yaml

#### Step 4.2: HighScoreRepository
- File: `lib/src/data/high_score_repository.dart`
- Properties:
  - `saveScore(score, date)`: Store score
  - `getHighScores()`: List of top 10 scores
  - `clearHighScores()`: Reset storage
- Tests: `test/data/high_score_repository_test.dart` (mock storage)
- Commit work once done and passes QA.

#### Step 4.3: HighScorePage UI
- File: `lib/src/ui/pages/high_score_page.dart`
- Display high score list
- Navigation from GameOverPage
- Tests: `test/ui/pages/high_score_page_test.dart`
- Commit work once done and passes QA.

**Phase 4 Tests:**
- Unit tests for repository
- Integration test: Save/load scores across app restarts

---

### Phase 5: Polish & Platform Support

**Goal:** Final polish and ensure Android/Web compatibility

#### Step 5.1: Responsive Design
- Mobile-first layout
- Desktop/browser optimizations
- Tests: Widget tests for different screen sizes
- Commit work once done and passes QA.

#### Step 5.2: Accessibility
- Semantic labels for screen readers
- Keyboard navigation support
- Tests: Accessibility tests
- Commit work once done and passes QA.

#### Step 5.3: Performance Optimizations
- Const constructors
- Efficient rebuilds (Selector, Consumer)
- Tests: Performance benchmark tests
- Commit work once done and passes QA.

#### Step 5.4: Error Handling
- Invalid inputs
- State recovery
- Tests: Error scenario tests
- Commit work once done and passes QA.

**Phase 5 Tests:**
- Widget tests for responsive layouts
- Integration test: Full game on different screen sizes

---

### Phase 6: Documentation & Test Coverage

**Goal:** Complete documentation and comprehensive test coverage

#### Step 6.1: Inline Documentation
- Add dartdoc comments to all public APIs
- Document scoring algorithms
- Commit work once done and passes QA.

#### Step 6.2: Update README
- Gameplay instructions
- Scoring rules reference
- Screenshots
- Commit work once done and passes QA.

#### Step 6.3: Test Coverage
- Achieve >80% coverage
- Run: `flutter test --coverage`
- Check: `genhtml coverage/lcov.info -o coverage/html`
- Commit work once done and passes QA.

**Phase 6 Tests:**
- Coverage verification

---

## Project Structure

```
lib/
└── src/
    ├── domain/
    │   ├── models/
    │   │   ├── die.dart
    │   │   ├── score_category.dart
    │   │   ├── score_sheet.dart
    │   │   └── game_round.dart
    │   ├── scoring/
    │   │   └── scorer.dart
    │   └── game_state.dart
    ├── data/
    │   └── high_score_repository.dart
    ├── bloc/
    │   └── game_bloc.dart
    └── ui/
        ├── theme/
        │   └── app_theme.dart
        ├── components/
        │   ├── die_widget.dart
        │   ├── score_row.dart
        │   ├── bonus_progress.dart
        │   ├── roll_button.dart
        │   ├── play_button.dart
        │   └── score_sheet.dart
        └── pages/
            ├── game_page.dart
            ├── game_over_page.dart
            └── high_score_page.dart

test/
├── domain/
│   ├── models/
│   │   ├── die_test.dart
│   │   ├── score_category_test.dart
│   │   ├── score_sheet_test.dart
│   │   └── game_round_test.dart
│   ├── scoring/
│   │   └── scorer_test.dart
│   └── game_state_test.dart
├── data/
│   └── high_score_repository_test.dart
├── bloc/
│   └── game_bloc_test.dart
└── ui/
    ├── components/
    │   ├── die_widget_test.dart
    │   ├── score_row_test.dart
    │   ├── bonus_progress_test.dart
    │   ├── roll_button_test.dart
    │   ├── play_button_test.dart
    │   └── score_sheet_test.dart
    └── pages/
        ├── game_page_test.dart
        ├── game_over_page_test.dart
        └── high_score_page_test.dart
```

---

## Testing Strategy

| Phase | Unit Tests | Widget Tests | Integration Tests |
|-------|-----------|--------------|-------------------|
| 1 | ✅ All domain logic | - | ✅ Game flow |
| 2 | - | ✅ All components | ✅ UI rendering |
| 3 | ✅ Bloc logic | ✅ User interactions | ✅ Complete gameplay |
| 4 | ✅ Repository | - | ✅ Persistence |
| 5 | - | ✅ Responsive layouts | ✅ Cross-platform |
| 6 | ✅ Coverage check | - | - |

---

## Future Poker Dice Mode Considerations

To support Poker Dice later, design with:
1. **Strategy pattern** for scoring logic (swap Yatzy scorer for Poker scorer)
2. **Dice configuration** (standard 1-6 vs. card symbols 9,10,J,Q,K,A)
3. **Game mode enum** (Yatzy vs. Poker Dice)
4. **Factory pattern** for creating game instances

---

## Commands Reference

```bash
# Run tests
flutter test

# Run specific test
flutter test test/domain/models/die_test.dart

# Run tests with coverage
flutter test --coverage

# Analyze code
flutter analyze

# Format code
dart format .

# Run app
flutter run -d chrome

# Build APK
flutter build apk --release

# Build Web
flutter build web
```

---

## Commit Convention

```
<type>(scope): <description>

feat(domain): add Die class with roll and hold
fix(scoring): resolve full house validation edge case
refactor(ui): simplify ScoreSheet widget structure
docs(readme): update scoring rules reference
test(domain): add Yatzy bonus integration tests
```

Types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`

---

## Implementation Checklist

### Phase 1: Core Game Logic & Data Models
- [ ] Step 1.1: Die class + tests
- [ ] Step 1.2: ScoreCategory enum
- [ ] Step 1.3: ScoreSheet class + tests
- [ ] Step 1.4: GameRound class + tests
- [ ] Step 1.5: Scorer class + tests
- [ ] Step 1.6: GameState class + tests

### Phase 2: UI Foundation & Theme
- [ ] Step 2.1: Theme configuration (blue gradient, orange/yellow accents)
- [ ] Step 2.2: DieWidget (white die, orange border when held)
- [ ] Step 2.3: ScoreRow (icon | potential | current score)
- [ ] Step 2.4: BonusProgress (X/63 progress indicator)
- [ ] Step 2.5: RollButton (shows roll count)
- [ ] Step 2.6: PlayButton (white/orange)
- [ ] Step 2.7: ScoreSheet (two-column: Upper/Lower)
- [ ] Step 2.8: GamePage layout (header, score sheet, dice, buttons)
- [ ] Step 2.9: GameOverPage layout

### Phase 3: Game Flow & User Interactions
- [ ] Step 3.1: GameBloc + tests
- [ ] Step 3.2: Complete GamePage implementation
- [ ] Step 3.3: Animations + tests

### Phase 4: High Score Tracking
- [ ] Step 4.1: Add shared_preferences dependency
- [ ] Step 4.2: HighScoreRepository + tests
- [ ] Step 4.3: HighScorePage + tests

### Phase 5: Polish & Platform Support
- [ ] Step 5.1: Responsive design
- [ ] Step 5.2: Accessibility
- [ ] Step 5.3: Performance optimizations
- [ ] Step 5.4: Error handling

### Phase 6: Documentation & Test Coverage
- [ ] Step 6.1: Inline documentation
- [ ] Step 6.2: Update README
- [ ] Step 6.3: Test coverage >80%

---

## Notes

- **Implementation approach:** Incremental (build and test each component as we go)
- **Player count:** Single player now, extend to 2-4 players later
- **Dice faces:** Standard 1-6 dots (card symbols for Poker Dice later)
- **Animations:** Scale/fade dice roll effect (3D if time permits)
- **State management:** Bloc pattern
- **UI Layout:** Two-column design (Upper, Lower section)
- **Category selection:** Direct row click + PLAY button (no menu)
- **Bonus display:** Show "X/63" progress toward bonus
