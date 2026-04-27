# Yatzy Dice Game - Implementation Plan

## Overview

A Flutter-based Yatzy dice game implementation with single-player support, Riverpod state management, and 90% test coverage target.

## Confirmed Requirements

- **Game Type**: Yatzy (dice values 1-6, standard rules)
- **Players**: Single-player (architecture extensible for future multiplayer)
- **State Management**: Riverpod (`flutter_riverpod`)
- **Icons**: Material Icons
- **Dice Hold**: Standard Yatzy (held dice stay fixed during subsequent rolls)
- **Play Button**: Selects currently highlighted category (allows choosing 0-score options)
- **Roll Counter**: Shows remaining rolls (3→2→1→0), button disabled at 0
- **Test Coverage**: 90% overall target

---

## Scoring Rules

### Upper Section (6 Categories)

| Category | Rule | Example |
|----------|------|---------|
| **Ones** | Sum of all dice showing 1 | [1,3,1,5,1] = 3 points |
| **Twos** | Sum of all dice showing 2 (×2) | [2,2,5,3,2] = 6 points |
| **Threes** | Sum of all dice showing 3 (×3) | [3,1,3,3,6] = 9 points |
| **Fours** | Sum of all dice showing 4 (×4) | [4,4,2,4,1] = 12 points |
| **Fives** | Sum of all dice showing 5 (×5) | [5,5,3,5,6] = 15 points |
| **Sixes** | Sum of all dice showing 6 (×6) | [6,1,6,6,6] = 24 points |
| **Bonus** | +35 if upper section total ≥ 63 | 63 = maximum possible (all 6s) |

**Edge Cases:**
- No dice match → 0 points (valid score)
- Exactly 63 → bonus awarded
- Multiple categories can be scored with 0 if no matching dice

### Lower Section (8 Categories)

| Category | Rule | Example | Points |
|----------|------|---------|--------|
| **Three of a Kind** | 3+ dice same value → sum ALL dice | [3,3,3,2,6] | 17 |
| **Four of a Kind** | 4+ dice same value → sum ALL dice | [4,4,4,4,1] | 17 |
| **Full House** | 3 of one + 2 of another → fixed 25 | [2,2,2,5,5] | 25 |
| **Small Straight** | 4 or 5 consecutive values → fixed 30 | [1,2,3,4,6] | 30 |
| **Large Straight** | 5 consecutive values → fixed 40 | [1,2,3,4,5] or [2,3,4,5,6] | 40 |
| **Yatzy** | All 5 dice same → fixed 50 | [6,6,6,6,6] | 50 |
| **Chance** | Sum of ALL dice | [3,4,5,2,6] | 20 |

**Edge Cases:**
- **Three/Four of a Kind**: Can also qualify for higher category
- **Full House**: Must be exactly 3+2, not 4+1 or 5-of-kind
- **Small Straight**: 4 consecutive in any order or if a Large straight can be scored
- **Large Straight**: Only two possibilities: [1,2,3,4,5] or [2,3,4,5,6]
- **Yatzy**: Can score multiple times (50 points each)

### Scoring Priority Examples

```
[5,5,5,5,5] could score as:
├── Three of a Kind: 25
├── Four of a Kind: 25
├── Yatzy: 50 ✓ (best option)
└── Chance: 25

[2,2,2,5,5] could score as:
├── Three of a Kind: 16
├── Full House: 25 ✓ (best option)
└── Chance: 16

[1,2,3,4,5] could score as:
├── Small Straight: 30
├── Large Straight: 40 ✓ (best option)
└── Chance: 15
```

---

## Project Structure

```
lib/
├── main.dart
├── theme/
│   └── app_theme.dart
├── models/
│   ├── die.dart
│   ├── dice_roll.dart
│   ├── category.dart
│   └── game_state.dart
├── services/
│   ├── scoring_service.dart
│   └── storage_service.dart
├── providers/
│   ├── game_provider.dart
│   └── settings_provider.dart
├── screens/
│   ├── game_screen.dart
│   └── game_over_screen.dart
├── widgets/
│   ├── die_widget.dart
│   ├── dice_container.dart
│   ├── score_category_row.dart
│   ├── scorecard.dart
│   ├── header_bar.dart
│   ├── control_bar.dart
│   ├── bonus_indicator.dart
│   └── high_scores_dialog.dart
└── animations/
    ├── dice_roll_animation.dart
    └── score_increment_animation.dart

test/
├── models/
│   ├── die_test.dart
│   ├── dice_roll_test.dart
│   └── game_state_test.dart
├── services/
│   └── scoring_service_test.dart
├── providers/
│   └── game_provider_test.dart
├── widgets/
│   ├── die_widget_test.dart
│   ├── dice_container_test.dart
│   ├── score_category_row_test.dart
│   ├── control_bar_test.dart
│   └── high_scores_dialog_test.dart
├── screens/
│   ├── game_screen_test.dart
│   └── game_over_screen_test.dart
└── integration/
    └── game_flow_test.dart
```

---

## Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  shared_preferences: ^2.2.2

dev_dependencies:
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.6
  mockito: ^5.4.3
```

---

## Implementation Phases

### Phase 1: Core Game Logic & Data Models (Days 1-2)

**Objectives:**
- Implement dice model and rolling logic
- Create scoring engine for all 14 categories
- Build game state manager with Riverpod

| Task | File | Tests |
|------|------|-------|
| Die model (value 1-6, held state) | `lib/models/die.dart` | `test/models/die_test.dart` |
| Dice roll (5 dice, sorting, counts) | `lib/models/dice_roll.dart` | `test/models/dice_roll_test.dart` |
| Category enum (14 categories) | `lib/models/category.dart` | - |
| Game state (scores, turns, rolls) | `lib/models/game_state.dart` | `test/models/game_state_test.dart` |
| Scoring engine (all 14 categories) | `lib/services/scoring_service.dart` | `test/services/scoring_service_test.dart` |
| Riverpod providers | `lib/providers/game_provider.dart` | `test/providers/game_provider_test.dart` |

**Tests Include:**
- Unit: Die value generation, held state toggle
- Unit: DiceRoll sorting, counting occurrences
- Unit: Each scoring category (14 tests)
- Unit: Bonus calculation (exactly at 63 threshold)
- Unit: Straights detection (4 vs 5 consecutive)
- Unit: Full House validation
- Unit: Yatzy logic
- Integration: Full turn simulation

---

### Phase 2: UI Foundation & Theming (Day 3)

**Objectives:**
- Set up Material theme with Riverpod
- Create responsive layout structure
- Implement reusable UI components

| Task | File | Tests |
|------|------|-------|
| App theme (light/dark, colors) | `lib/theme/app_theme.dart` | - |
| Single die widget with pips | `lib/widgets/die_widget.dart` | `test/widgets/die_widget_test.dart` |
| Dice row with hold gestures | `lib/widgets/dice_container.dart` | `test/widgets/dice_container_test.dart` |
| Category row component | `lib/widgets/score_category_row.dart` | `test/widgets/score_category_row_test.dart` |

**Tests Include:**
- Widget: Die renders 1-6 pips correctly
- Widget: Die shows orange glow when held
- Widget: Category row shows score (filled, 0, or available)
- Integration: Tap die toggles held state

---

### Phase 3: Main Game Screen Layout (Days 4-5)

**Objectives:**
- Implement 3-section vertical layout
- Build scorecard with Upper/Lower columns
- Add header and control bar

| Task | File | Tests |
|------|------|-------|
| Main game screen (3 sections) | `lib/screens/game_screen.dart` | `test/screens/game_screen_test.dart` |
| Header with total score | `lib/widgets/header_bar.dart` | - |
| Scorecard (Upper/Lower columns) | `lib/widgets/scorecard.dart` | - |
| Control bar (Roll + Play) | `lib/widgets/control_bar.dart` | `test/widgets/control_bar_test.dart` |
| Bonus progress indicator | `lib/widgets/bonus_indicator.dart` | - |

**Layout Structure:**
```
┌─────────────────────────────────┐
│ ← [Back]    2070    [Menu] →    │ Header
│              You                │
├─────────────────────────────────┤
│ UPPER     │     LOWER           │ Scorecard
│ 1s  [1]   │  3x  [23]           │
│ 3s  [4]   │  4x  [18]           │
│ 3s  [3]◄──│  FH  [25]           │
│ 4s  [8]   │  SS  [30]           │
│ 5s  [20]◄─│  LS  [40]           │
│ 6s  [24]  │  YAT [0]            │
│ BONUS +35 │  CH  [19]           │
│ 37/63 ○   │                     │
├─────────────────────────────────┤
│ [ROLL 2]      [PLAY]            │ Controls
└─────────────────────────────────┘
```

**Tests Include:**
- Widget: All 14 categories render in correct columns
- Integration: Category tap highlights selection
- Integration: Roll button shows counter, disables at 0

---

### Phase 4: Game Flow & State Wiring (Days 6-7)

**Objectives:**
- Connect UI to Riverpod state
- Implement complete turn management
- Handle game end condition

| Task | File | Tests |
|------|------|-------|
| Wire UI to Riverpod | Update all widgets | `test/integration/game_flow_test.dart` |
| Roll dice logic | `game_provider.dart` | - |
| Hold/unhold dice | `game_provider.dart` | - |
| Select category & score | `game_provider.dart` | - |
| Game over screen | `lib/screens/game_over_screen.dart` | `test/screens/game_over_screen_test.dart` |

**Tests Include:**
- Integration: Complete game (13 categories, game ends)
- Integration: Held dice remain fixed across rolls
- Integration: Score totals correctly (upper + bonus + lower)
- Integration: Play button selects highlighted category
- Integration: Game over shows final score, play again works

---

### Phase 5: Persistence (Day 8)

**Objectives:**
- Store high scores locally
- Add settings persistence (theme preference)

| Task | File | Tests |
|------|------|-------|
| Storage service (SharedPreferences) | `lib/services/storage_service.dart` | `test/services/storage_service_test.dart` |
| Settings provider (theme, scores) | `lib/providers/settings_provider.dart` | - |
| High scores dialog | `lib/widgets/high_scores_dialog.dart` | `test/widgets/high_scores_dialog_test.dart` |

**Tests Include:**
- Integration: High scores persist after app restart
- Integration: Theme preference persists

---

### Phase 6: Animations & Polish (Day 9)

**Objectives:**
- Add dice roll animations
- Smooth UI transitions
- Visual polish matching layout

| Task | File | Tests |
|------|------|-------|
| Dice roll animation | `lib/animations/dice_roll_animation.dart` | - |
| Score increment animation | `lib/animations/score_increment_animation.dart` | - |
| Visual polish (shadows, gradients) | All widgets | - |

**Tests Include:**
- Widget: Animations trigger on correct events
- Integration: UI remains responsive during animations

---

### Phase 7: Testing & Cross-Platform (Day 10)

**Objectives:**
- Achieve 90% test coverage
- Verify Android and Web compatibility
- Fix platform-specific issues

| Task | Tests |
|------|-------|
| Coverage audit | `flutter test --coverage` |
| Android testing | Manual + widget tests |
| Web testing | Manual + widget tests |
| Bug fixes | As needed |

**Coverage Target:**
```
lib/models/          100%
lib/services/         95%
lib/providers/        90%
lib/widgets/          85%
lib/screens/          80%
Overall target:       90%
```

---

## Comprehensive Test Plan

### Scoring Service Tests

```
test/services/scoring_service_test.dart
├── Group: Upper Section
│   ├── test_ones_scores_correctly()
│   ├── test_twos_scores_correctly()
│   ├── test_threes_scores_correctly()
│   ├── test_fours_scores_correctly()
│   ├── test_fives_scores_correctly()
│   ├── test_sixes_scores_correctly()
│   └── test_bonus_awarded_at_63()
├── Group: Lower Section
│   ├── test_three_of_a_kind_basic()
│   ├── test_three_of_a_kind_with_extra_dice()
│   ├── test_four_of_a_kind_basic()
│   ├── test_full_house_valid()
│   ├── test_full_house_not_four_plus_one()
│   ├── test_small_straight_four_consecutive()
│   ├── test_large_straight_five_consecutive()
│   ├── test_chance_sum_all_dice()
│   └── test_yatzy_five_of_a_kind()
└── Group: Edge Cases
    ├── test_category_returns_zero_when_not_qualified()
    ├── test_multiple_categories_qualify()
    └── test_yatzy_also_qualifies_for_lower_categories()
```

### Integration Test Scenarios

```
test/integration/game_flow_test.dart
├── test_complete_game_flow()
├── test_held_dice_remain_across_rolls()
├── test_roll_counter_decrements_correctly()
├── test_roll_button_disables_at_zero()
├── test_category_selection_updates_score()
├── test_bonus_awarded_when_upper_reaches_63()
├── test_game_ends_after_13_categories()
├── test_final_score_calculation()
└── test_play_again_restarts_game()
```

---

## Risk Assessment

| Risk | Mitigation |
|------|------------|
| Scoring edge cases (straights, full house) | Thorough unit tests for each category |
| State management complexity | Keep providers simple, one per feature |
| Animation performance | Use AnimatedBuilder, avoid unnecessary rebuilds |
| Cross-platform issues | Test early on both Android and Web |
| Test coverage gaps | Run coverage report after each phase |

---

## Commands Reference

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/scoring_service_test.dart

# Run tests by name
flutter test --name="test_bonus_awarded_at_63"

# Analyze code
flutter analyze

# Auto-fix issues
flutter analyze --fix

# Format code
dart format .

# Run app on Web
flutter run -d chrome

# Run app on Android
flutter run -d <android-device-id>

# Build APK
flutter build apk --release

# Build Web
flutter build web
```

---

## Progress Tracking

| Phase | Status | Tests | Coverage |
|-------|--------|-------|----------|
| Phase 1: Core Logic | Pending | - | - |
| Phase 2: UI Foundation | Pending | - | - |
| Phase 3: Main Screen | Pending | - | - |
| Phase 4: Game Flow | Pending | - | - |
| Phase 5: Persistence | Pending | - | - |
| Phase 6: Animations | Pending | - | - |
| Phase 7: Testing | Pending | - | - |
| **Overall** | **0%** | **?/?** | **0%** |

---

## Notes

- All dice values are integers 1-6
- Each category can only be scored once per game
- Players have 3 rolls per turn
- Game ends when all 13 categories are filled
- Bonus (+35) awarded if upper section ≥ 63
- Yatzy can be scored multiple times (50 points each)
