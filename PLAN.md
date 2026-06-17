# Yatzy Dice Game - Implementation Plan

## Project Overview

A Flutter-based Yatzy dice game with single-player support, playable on Android and Web. This plan outlines a phased approach with mandatory testing (80%+ overall coverage, 100% on core scoring logic).

---

## Phase 1: Core Game Logic & Data Models

**Coverage Goal:** 100% on all services, especially scoring

### Files to Create

#### Models (`lib/models/`)
- **`dice.dart`**
  - `Dice` class with properties: `value` (1-6), `isHeld` (bool)
  - Equality and hashCode implementation
  - CopyWith method for immutability

- **`score_category.dart`**
  - `ScoreCategory` enum with all 13 categories:
    - Upper: `aces`, `twos`, `threes`, `fours`, `fives`, `sixes`
    - Lower: `threeOfAKind`, `fourOfAKind`, `fullHouse`, `smallStraight`, `largeStraight`, `yatzy`, `chance`
  - Extension for section determination (Upper/Lower)
  - Display name and icon mapping

- **`game_state.dart`**
  - `GameState` class tracking:
    - `List<Dice> currentDice` (5 dice)
    - `int rollsRemaining` (max 3)
    - `Map<ScoreCategory, int?> scoredCategories` (null = not scored yet)
    - `int totalScore`
    - `GameStatus` enum (active, completed)
  - Methods for state transitions (roll, hold, score)
  - Upper section total and bonus calculation

#### Services (`lib/services/`)
- **`dice_roller.dart`**
  - `RollDice()` method returning `List<Dice>` (5 random dice, values 1-6)
  - Seeded random for testing
  - Validation of output range

- **`scoring_service.dart`**
  - `calculateScore(List<Dice> dice, ScoreCategory category)` method
  - All 13 scoring algorithms:
    - **Upper Section:** Sum dice matching the value
    - **Bonus:** +35 if upper total ≥ 63
    - **Three of a Kind:** Sum all dice if 3+ match
    - **Four of a Kind:** Sum all dice if 4+ match
    - **Full House:** 25 points (3 of one + 2 of another)
    - **Small Straight:** 30 points (4 consecutive values)
    - **Large Straight:** 40 points (5 consecutive: 1-2-3-4-5 or 2-3-4-5-6)
    - **Yatzy:** 50 points (all 5 match, can score multiple times)
    - **Chance:** Sum all dice
  - Preview score calculation for UI

### Tests (`test/`)

- **`test/models/dice_test.dart`**
  - Value range validation (1-6)
  - Held state toggle
  - Equality/hashCode tests

- **`test/models/game_state_test.dart`**
  - Initial state verification
  - Roll decrement logic
  - Category scoring state changes
  - Game completion detection

- **`test/services/dice_roller_test.dart`**
  - Returns exactly 5 dice
  - All values in range 1-6
  - Seeded randomness for deterministic tests

- **`test/services/scoring_service_test.dart`**
  - **100% coverage required**
  - Test each category with multiple scenarios:
    - Valid scoring combinations
    - Invalid combinations (return 0)
    - Edge cases (exactly 63 vs 64 for bonus)
    - Multiple Yatzy scoring
    - Straight edge cases (1-2-3-4-5 vs 2-3-4-5-6)

---

## Phase 2: UI Foundation & Components

**Coverage Goal:** 80%+ on widgets and pages

### Files to Create

#### Widgets (`lib/widgets/`)
- **`dice_face.dart`**
  - CustomPaint widget drawing dice dots for values 1-6
  - No image assets - pure Flutter painting
  - Configurable size and color

- **`dice_widget.dart`**
  - Wraps DiceFace with tap gesture detector
  - Held state visual indicator: amber glow border (Material Design colors)
  - Animation-ready structure for Phase 6

- **`category_row.dart`**
  - Displays category icon/name on left
  - Score preview or final score on right
  - States: selectable, selected, scored, disabled
  - Tappable to select category for scoring

- **`score_sheet.dart`**
  - Two-column layout (Minor/Upper on left, Major/Lower on right)
  - Renders all 13 categories with CategoryRow
  - Bonus indicator showing current/63 and +35 status
  - Responsive sizing

- **`roll_button.dart`**
  - Primary action button
  - Shows remaining rolls badge (0-3)
  - Disabled state when rolls = 0
  - Material Design elevation and ripple

#### Pages (`lib/pages/`)
- **`game_page.dart`**
  - Complete game screen layout matching reference images:
    ```
    ┌─────────────────────────────────────┐
    │  ←   [Total Score]    [Menu]        │
    │         You                          │
    ├─────────────────────────────────────┤
    │     Minor          │     Major      │
    │  [1] 1   │ [3x] 23 │                │
    │  [2] 4   │ [4x] 18 │                │
    │  [3] 3   │ [🏠] 25 │                │
    │  [4] 8   │ [📃] 30 │                │
    │  [5] 20  │ [📃] 40 │                │
    │  [6] 24  │ [Yatzy] 0│               │
    │  [+35] 37/63 │ [?] 19 │             │
    ├─────────────────────────────────────┤
    │  [🎲] [🎲] [🎲] [🎲] [🎲]          │
    │  ROLL [0]      PLAY                │
    └─────────────────────────────────────┘
    ```
  - Integrates all widgets
  - Connects to game provider (Phase 3)

### Tests (`test/`)

- **`test/widgets/dice_face_test.dart`**
  - All 6 face values render correctly
  - Dot positions match standard dice layout

- **`test/widgets/dice_widget_test.dart`**
  - Held state shows glow border
  - Tap toggles held state
  - Correct dice face displays

- **`test/widgets/category_row_test.dart`**
  - Selectable state (preview shows)
  - Selected state (highlighted)
  - Scored state (final score, disabled)
  - Disabled state (faded, not tappable)

- **`test/pages/game_page_test.dart`**
  - Layout structure verification
  - All 13 categories present
  - 5 dice render
  - Roll and Play buttons present

---

## Phase 3: Game Flow & State Management

**Coverage Goal:** 100% on game logic

### Files to Create

#### Providers (`lib/providers/`)
- **`game_provider.dart`**
  - StateNotifier pattern with Riverpod
  - Manages complete game state
  - Methods:
    - `rollDice()` - Rolls unheld dice, decrements counter
    - `toggleHold(int index)` - Holds/unholds die at index
    - `selectCategory(ScoreCategory)` - Scores category, resets turn
    - `resetGame()` - Starts new game
    - `getPreviewScore(ScoreCategory)` - Returns score if category selected now
  - Auto-save on state changes

- **`theme_provider.dart`**
  - Notifier for light/dark theme toggle
  - Persisted preference
  - Material Design color schemes

#### Update
- **`lib/main.dart`**
  - Wrap app with providers
  - Configure theme
  - Enable Material 3

### Features

- **Roll Mechanics:**
  - Up to 3 rolls per turn
  - Only unheld dice roll
  - Roll counter updates in real-time

- **Hold Mechanics:**
  - Tap dice to toggle hold
  - Held dice show amber glow border
  - Can hold/unhold between rolls

- **Scoring Flow:**
  - After any roll (1-3), player selects category
  - Preview scores shown before selection
  - Category locks in, turn resets (3 rolls, no dice held)

- **Game End:**
  - Detected when all 13 categories scored
  - Show final score and total
  - Navigate to scoreboard or new game

### Tests (`test/`)

- **`test/providers/game_provider_test.dart`**
  - **100% coverage required**
  - Full game flow scenarios:
    - Roll → Hold → Roll → Score
    - Roll → Score (1 roll only)
    - Max rolls (3) → Auto-select category
  - Invalid action prevention:
    - Cannot roll when rolls = 0
    - Cannot score already scored category
    - Cannot hold after scoring
  - Game end detection
  - Preview score accuracy

---

## Phase 4: Scoring Algorithms

**Coverage Goal:** 100% (integrated with Phase 1 tests)

### Implementation Details

All algorithms implemented in `lib/services/scoring_service.dart`:

#### Upper Section (Aces-Sixes)
```dart
// Aces: Sum of all dice showing 1
// Twos: Sum of all dice showing 2
// ... etc
int calculateUpperScore(List<Dice> dice, ScoreCategory category) {
  int targetValue = category.diceValue; // 1-6
  return dice.where((d) => d.value == targetValue).fold(0, (sum, d) => sum + d.value);
}
Bonus
int calculateBonus(int upperTotal) {
  return upperTotal >= 63 ? 35 : 0;
}
Three/Four of a Kind
int calculateThreeOfAKind(List<Dice> dice) {
  Map<int, int> counts = countDiceValues(dice);
  if (counts.values.any((c) => c >= 3)) {
    return dice.fold(0, (sum, d) => sum + d.value);
  }
  return 0;
}
Full House
int calculateFullHouse(List<Dice> dice) {
  Map<int, int> counts = countDiceValues(dice);
  bool hasThree = counts.values.contains(3);
  bool hasTwo = counts.values.contains(2);
  return (hasThree && hasTwo) ? 25 : 0;
}
Straights
int calculateSmallStraight(List<Dice> dice) {
  Set<int> values = dice.map((d) => d.value).toSet();
  // Check for any 4 consecutive: 1-2-3-4, 2-3-4-5, 3-4-5-6
  return (values.containsAll([1,2,3,4]) || 
          values.containsAll([2,3,4,5]) || 
          values.containsAll([3,4,5,6])) ? 30 : 0;
}

int calculateLargeStraight(List<Dice> dice) {
  Set<int> values = dice.map((d) => d.value).toSet().toList()..sort();
  // 1-2-3-4-5 or 2-3-4-5-6
  return (values.equals([1,2,3,4,5]) || values.equals([2,3,4,5,6])) ? 40 : 0;
}
Yatzy
int calculateYatzy(List<Dice> dice) {
  Map<int, int> counts = countDiceValues(dice);
  return counts.values.contains(5) ? 50 : 0;
}
// Note: Can score multiple times if category not yet used
Chance
int calculateChance(List<Dice> dice) {
  return dice.fold(0, (sum, d) => sum + d.value);
}
Edge Cases to Test
- Bonus boundary: Exactly 63 (gets bonus) vs 62 (no bonus) vs 64 (gets bonus)
- Multiple Yatzy: Player can score Yatzy multiple times in same game
- Invalid combinations: Return 0, not exception
- Straight variants: 1-2-3-4-5 is large straight, 1-2-3-4 is small straight
- Full House with 4-of-kind: Should NOT score (needs exactly 3+2)
Phase 5: Persistence & High Scores
Coverage Goal: 80%+
Dependencies
Add to pubspec.yaml:
dependencies:
  shared_preferences: ^2.2.0
Files to Create
- lib/models/game_history.dart
class GameResult {
  final int finalScore;
  final DateTime completedAt;
  // Optional: category breakdown
}
- lib/services/storage_service.dart
- saveGameResult(GameResult result) - Add to history, keep last 10
- loadGameHistory() - Return List<GameResult>
- getLastGameResult() - For auto-resume
- clearHistory() - For testing/reset
- lib/pages/scoreboard_page.dart
- List view of last 10 games
- Sort by score (descending)
- Show date/time and final score
- "New Game" button to return to game
- Update lib/pages/game_page.dart
- Navigate to scoreboard on game over
- Menu button to view scoreboard anytime
Storage Format
{
  "last_game": {
    "score": 2070,
    "date": "2026-06-17T10:30:00Z",
    "categories": {"aces": 5, "twos": 8, ...}
  },
  "history": [
    {"score": 2070, "date": "2026-06-17T10:30:00Z"},
    {"score": 1850, "date": "2026-06-16T14:20:00Z"},
    // ... up to 10 entries
  ]
}
Tests (test/)
- test/services/storage_service_test.dart
- Save and load game result
- History maintains last 10 only
- Timestamps persist correctly
- Empty history handling
Phase 6: Polish & Animations
Coverage Goal: Not critical (visual validation)
Files to Create/Update
- lib/widgets/animated_dice.dart
- Extend DiceWidget with AnimationController
- Tumble animation on roll (rotation + scale)
- Smooth transition to final value
- lib/services/sound_service.dart
- Optional: Sound effect playback
- Roll sound, select sound, score sound
- Mute toggle in settings
- Assets from assets/sounds/ (if added)
- Update lib/providers/theme_provider.dart
- Theme colors matching reference images:
- Primary: Deep blue (#1565C0)
- Secondary: Amber (#FFC107) for buttons/highlights
- Background: Light blue gradient
- Text: White on dark, dark on light
Features
- Dice Roll Animation:
- 300-500ms tumble effect
- Each die animates independently
- Final value snaps with bounce
- Score Update Animation:
- Fade-in when category scores
- Counter increment animation for totals
- Button Feedback:
- Material ripple on press
- Scale animation on tap
Phase 7: Quality Assurance
Coverage Goal: 80%+ overall, 100% on core logic
Tasks
1. Test Coverage:
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
- Verify 80%+ overall coverage
- Verify 100% on scoring_service.dart and game_provider.dart
2. Static Analysis:
flutter analyze --fix
dart format .
- Zero warnings or errors
- Consistent formatting
3. Platform Testing:
- Android:
flutter run -d <emulator-or-device>
flutter build apk --release
- Web:
flutter run -d chrome
flutter build web
4. Manual Testing Checklist:
- All 13 categories score correctly
- Bonus triggers at 63+ points
- Dice hold/unhold works
- Roll counter decrements
- Game ends after 13 categories
- High scores persist across restarts
- Theme toggle works
- Responsive on mobile and desktop
- No crash scenarios
5. Performance:
- 60 FPS during animations
- No jank on score updates
- Memory usage stable across games
File Structure
lib/
├── main.dart
├── models/
│   ├── dice.dart
│   ├── score_category.dart
│   ├── game_state.dart
│   └── game_history.dart
├── services/
│   ├── dice_roller.dart
│   ├── scoring_service.dart
│   ├── storage_service.dart
│   └── sound_service.dart
├── providers/
│   ├── game_provider.dart
│   └── theme_provider.dart
├── widgets/
│   ├── dice_face.dart
│   ├── dice_widget.dart
│   ├── animated_dice.dart
│   ├── category_row.dart
│   ├── score_sheet.dart
│   └── roll_button.dart
└── pages/
    ├── game_page.dart
    └── scoreboard_page.dart

test/
├── models/
│   ├── dice_test.dart
│   ├── game_state_test.dart
│   └── game_history_test.dart
├── services/
│   ├── dice_roller_test.dart
│   ├── scoring_service_test.dart
│   ├── storage_service_test.dart
│   └── sound_service_test.dart
├── providers/
│   ├── game_provider_test.dart
│   └── theme_provider_test.dart
├── widgets/
│   ├── dice_face_test.dart
│   ├── dice_widget_test.dart
│   ├── category_row_test.dart
│   └── score_sheet_test.dart
└── pages/
    ├── game_page_test.dart
    └── scoreboard_page_test.dart
Implementation Order
Execute phases sequentially. Each phase must have all tests passing before proceeding:
1. Phase 1 → Models + Services → 100% coverage verified
2. Phase 2 → Widgets + Pages → 80%+ coverage verified
3. Phase 3 → Providers + Game Flow → 100% coverage verified
4. Phase 4 → (Integrated with Phase 1 tests)
5. Phase 5 → Persistence → 80%+ coverage verified
6. Phase 6 → Animations → Visual validation
7. Phase 7 → Coverage report + Platform testing
Technical Decisions
State Management
- Choice: Riverpod (StateNotifier)
- Reason: Clean separation of state and UI, easy testing, no global state pollution
Dice Rendering
- Choice: CustomPaint with dots
- Reason: No image assets needed, crisp at any resolution, easy to animate
Color Scheme
- Choice: Material Design colors
- Reason: Consistent with Flutter ecosystem, matches reference (blue/amber)
Storage
- Choice: shared_preferences
- Reason: Simple key-value, cross-platform, well-maintained
Testing Strategy
- Unit Tests: Models and services (100% on scoring)
- Widget Tests: UI components (80%+)
- Integration Tests: Full game flow (via provider tests)
Risk Mitigation
Risk
Scoring bugs
State corruption
Platform issues
Performance
Data loss
Success Criteria
- ✅ All 13 Yatzy categories score correctly
- ✅ Bonus calculation accurate at boundary (63 points)
- ✅ Game flow matches standard Yatzy rules
- ✅ 80%+ overall test coverage
- ✅ 100% test coverage on scoring_service.dart and game_provider.dart
- ✅ Zero analyzer warnings
- ✅ Smooth 60 FPS animations
- ✅ Works on Android and Web
- ✅ High scores persist across app restarts
- ✅ Responsive UI on mobile and desktop
