# Two-Player Game Mode - Implementation Plan

## Summary
Add two-player mode with shared dice, alternating turns, combined score sheet showing both players' scores side-by-side, and persistent game state for both modes.

---

## Requirements

### Gameplay Rules
- **Shared Dice**: Both players roll the same 5 dice
- **Turn Switching**: Player switches after each category is scored (not after every roll)
- **Score Tracking**: Separate score tracking per player (13 categories each)
- **Game Completion**: Game ends when ALL categories are scored for ALL players (26 total for 2-player)
- **Storage**: Single in-progress game slot (last mode played)
- **Yellow Dot Indicator**: Global indicator showing last scored category by any player

### UI Requirements
- Title screen: "New Single Game", "New Double Game", "Continue" buttons
- Score sheet: Two columns (Player 1 left, Player 2 right) with combined Minor/Major sections
- Turn indicator: Shows current player name
- App bar: Player label ("You" for single, "Player 1"/"Player 2" for double)

---

## Implementation Phases

### Phase 1: Core Data Model

**Files to Modify:**
1. **`lib/models/game_state.dart`**
   - Add `final int playerCount` (1 or 2)
   - Add `final int currentPlayer` (0 or 1)
   - Change `scoredCategories` from `Map<ScoreCategory, int?>` to `Map<int, Map<ScoreCategory, int?>>`
   - Add `final ScoreCategory? lastScoredCategory` for global yellow dot indicator
   - Update constructor to initialize per-player score maps
   - Add `currentPlayerScore` getter (sum of current player's scored categories)
   - Add `getLastScoredCategory()` getter
   - Update `totalScore` to sum all players' scores
   - Update `isGameComplete` to check all players' categories
   - Update `toJson()`/`fromJson()` to support multi-player state
   - Update `copyWith()` to support player switching and per-player state

2. **`lib/models/game_history.dart`**
   - Add `int playerCount` to `GameResult` class
   - Update `toJson()`/`fromJson()` to include player count
   - Update scoreboard display to show game mode

---

### Phase 2: Game Logic & State Management

**Files to Modify:**
3. **`lib/providers/game_provider.dart`**
   - Add `int get currentPlayer` getter
   - Add `int get playerCount` getter
   - Add `ScoreCategory? get lastScoredCategory` getter
   - Add `_switchPlayer()` private method
   - Modify `confirmScore()` to:
     - Record `lastScoredCategory`
     - Call `_switchPlayer()` after scoring (when 2-player mode and game not complete)
   - Modify `resetGame()` to accept optional `playerCount` parameter
   - Update `_autoSave()` to save per-player state
   - Update `_resetTurn()` to reset dice for new player turn

4. **Add route parameter support** (via `lib/main.dart` or routing config)
   - Add optional `?mode=single` or `?mode=double` query parameter to `/game` route
   - Parse mode parameter and pass to `GameNotifier`

---

### Phase 3: UI Components

**Files to Create:**
5. **`lib/widgets/turn_indicator.dart`** (NEW)
   - Shows current player name ("Player 1" or "Player 2")
   - Visual indicator (highlighted border or background)
   - Player name based on `currentPlayer` index

**Files to Modify:**
6. **`lib/widgets/score_sheet.dart`**
   - Add `int playerCount` parameter
   - Add `int currentPlayer` parameter  
   - Add `Map<int, Map<ScoreCategory, int>> playerScoredCategories` parameter
   - Add `ScoreCategory? lastScoredCategory` parameter for yellow dot indicator
   - Modify layout to show Player 1 and Player 2 columns side-by-side
   - Each player column shows:
     - Player header ("Player 1", "Player 2")
     - All 13 categories with their scores
     - Upper section total + bonus per player
     - Lower section categories per player
     - Yellow dot on last scored category (global indicator)
   - Keep Minor/Major sections within each player's column

7. **`lib/pages/game_page.dart`**
   - Update app bar title to show player label:
     - Single player: "You" (existing)
     - Two player: "Player 1" or "Player 2"
   - Add `TurnIndicator` widget above dice area
   - Update `ScoreSheet` widget call to pass new parameters
   - Update total score display to show combined or per-player totals

---

### Phase 4: Navigation & Storage

**Files to Modify:**
8. **`lib/pages/title_screen.dart`**
   - Add three buttons:
     - "New Single Game" → starts 1-player game
     - "New Double Game" → starts 2-player game
     - "Continue" → loads last saved game (any mode)
   - Disable "Continue" if no saved game exists
   - Pass `playerCount` to `GameNotifier.resetGame()`

9. **`lib/services/storage_service.dart`**
   - Update `GameState.toJson()` serialization to include:
     - `playerCount` field
     - `currentPlayer` field
     - `lastScoredCategory` field
     - Per-player `scoredCategories` map
   - Update `GameState.fromJson()` deserialization to read new fields
   - Maintain backward compatibility for single-player saves

---

### Phase 5: End-to-End Tests & Test Coverage

**Files to Create:**
10. **`test/models/game_state_multiplayer_test.dart`** (NEW)
    - Test player count initialization
    - Test current player tracking
    - Test per-player score tracking
    - Test game completion for 2-player (26 categories)
    - Test `lastScoredCategory` updates

11. **`test/providers/game_provider_multiplayer_test.dart`** (NEW)
    - Test turn switching after scoring
    - Test per-player score isolation
    - Test shared dice behavior
    - Test game completion with 2 players

12. **`test/widgets/turn_indicator_test.dart`** (NEW)
    - Test player name display
    - Test visual indicator for current player

13. **`test/widgets/score_sheet_multiplayer_test.dart`** (NEW)
    - Test two-column player layout
    - Test per-player category scores
    - Test yellow dot indicator
    - Test combined totals display

**Files to Modify:**
14. **`integration_test/app_test.dart`**
    - Add test: "two-player mode turn switching"
      - Start double game
      - Player 1 rolls, scores category
      - Verify Player 2 becomes active
      - Player 2 rolls, scores different category
      - Verify Player 1 becomes active again
    - Add test: "two-player score isolation"
      - Verify Player 1 and Player 2 have separate scores
      - Verify each player can score different categories
    - Add test: "two-player game completion"
      - Score all 26 categories
      - Verify game ends with combined total
    - Update "back navigation and continue" test to verify 2-player state persists

15. **Update existing unit tests** to work with new GameState structure
    - `test/models/game_state_test.dart`
    - `test/providers/game_provider_test.dart`

---

## Testing Strategy

### Coverage Goals
- **100%** on `game_state.dart` and `game_provider.dart` (core logic)
- **80%+** on widgets (`turn_indicator.dart`, `score_sheet.dart`)
- **End-to-end tests** for all user flows

### Test Execution
```bash
# Run all unit tests with coverage
flutter test --coverage

# Run specific multiplayer tests
flutter test test/models/game_state_multiplayer_test.dart
flutter test test/providers/game_provider_multiplayer_test.dart

# Run end-to-end tests
make test/end-to-end
# or
flutter test integration_test/app_test.dart
```

### QA Validation Checklist
- ✅ Can start single-player game
- ✅ Can start two-player game
- ✅ "Continue" loads last game (any mode)
- ✅ Two-player: turns alternate after scoring
- ✅ Two-player: dice are shared
- ✅ Two-player: scores are tracked separately per player
- ✅ Two-player: yellow dot shows last scored category globally
- ✅ Two-player: game ends after 26 categories scored
- ✅ Two-player: auto-save works mid-game
- ✅ Single-player behavior unchanged
- ✅ All existing E2E tests pass

---

## Implementation Order

Execute phases sequentially. Each phase must compile and pass existing tests before proceeding:

1. **Phase 1** → Update `GameState` model → Run existing tests to ensure backward compatibility
2. **Phase 2** → Update `GameNotifier` → Run provider tests
3. **Phase 3** → Create `TurnIndicator`, update `ScoreSheet` and `GamePage` → Run widget tests
4. **Phase 4** → Update `TitleScreen` and `StorageService` → Run integration tests
5. **Phase 5** → Add multiplayer tests → Verify 100% coverage on core logic, 80%+ on widgets

---

## Technical Decisions

### State Management
- Keep Riverpod StateNotifier pattern
- Per-player score maps ensure isolation
- Shared dice simplify turn-based gameplay

### Storage
- Single in-progress game slot (last mode played)
- Backward compatible with single-player saves
- JSON serialization includes player count

### UI Layout
- Player columns side-by-side (Player 1 left, Player 2 right)
- Each player has their own Minor/Major sections
- Yellow dot indicator is global (last person to score)

### Game Completion
- Single player: 13 categories
- Two player: 26 categories (13 per player)
- Total score shows combined for leaderboard

---

## Files Summary

### New Files (3)
- `lib/widgets/turn_indicator.dart`
- `test/models/game_state_multiplayer_test.dart`
- `test/providers/game_provider_multiplayer_test.dart`
- `test/widgets/turn_indicator_test.dart`
- `test/widgets/score_sheet_multiplayer_test.dart`

### Modified Files (8)
- `lib/models/game_state.dart`
- `lib/models/game_history.dart`
- `lib/providers/game_provider.dart`
- `lib/widgets/score_sheet.dart`
- `lib/pages/game_page.dart`
- `lib/pages/title_screen.dart`
- `lib/services/storage_service.dart`
- `integration_test/app_test.dart`

---

## Success Criteria

- ✅ Two-player mode works end-to-end
- ✅ Turn switching functions correctly
- ✅ Per-player scores are isolated
- ✅ Game completion detection works for both modes
- ✅ Storage persistence works for both modes
- ✅ All existing tests pass
- ✅ New tests achieve 100% coverage on core logic
- ✅ UI matches reference screenshots
- ✅ No regressions in single-player mode
