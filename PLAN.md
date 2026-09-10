# PLAN.md

Implementation plan for the **Yatzy Poker Dice** Flutter app (v0.1.0).

## Objective

Build a complete, polished **single-player** Yatzy dice game (5 dice, 13 categories) with full scoring rules, hold-dice mechanics, animations, and persistent high scores. Flutter 3.44.2 / Dart 3.12.2, Android + Web, feature-first layered architecture, Riverpod for state management.

**Scope decisions (locked):**
- **Single-player only** for v1. Multi-player is out of scope.
- **State management:** Riverpod (`flutter_riverpod`). Only dependencies added: `flutter_riverpod`, `shared_preferences`.
- **No external game packages** — dice, scoring, and state are hand-written. No state-management/sound libs beyond the two above.

## Scoring Rules (source of truth)

### Upper Section (sum of matching dice)
| Category | Score |
|---|---|
| Ones–Sixes | Sum of dice with that face |
| **Bonus** | **+35** if upper total ≥ **63** |

### Lower Section
| Category | Score |
|---|---|
| Three of a Kind | Sum of all dice if 3+ match |
| Four of a Kind | Sum of all dice if 4+ match |
| Full House | 25 (3 of one + 2 of another) |
| Small Straight | 30 (4 consecutive values, e.g. 1-2-3-4) |
| Large Straight | 40 (5 consecutive, 1-2-3-4-5 or 2-3-4-5-6) |
| Yatzy | 50 (all 5 match; **repeatable** once scored) |
| Chance | Sum of all dice |

### Game Flow
- Roll 5 dice, up to **3 rolls** per turn.
- **Hold** any dice between rolls.
- Select **one** category per turn; each category usable **once** (Yatzy repeatable).
- Game ends when all 13 categories are filled.

## Target File Structure

```
lib/
  main.dart                      # runApp + ProviderScope
  core/
    theme/                      # light/dark ThemeData
    router/                     # routes: home, game, results
  features/
    game/
      domain/
        die.dart                # Die model, DiceValue
        category.dart           # Category enum + metadata
        score_calculator.dart  # pure scoring functions
        game_logic.dart        # roll, hold, rollsUsed, game-over, total
      presentation/
        game_providers.dart   # Riverpod providers (GameController etc.)
        widgets/
          dice.dart           # dice face widget w/ roll animation
          die_tray.dart       # 5 dice + hold interaction
          scorecard.dart      # category grid, locked states
          roll_button.dart
        pages/
          game_page.dart
          home_page.dart
          results_page.dart
      data/
        high_score_repository.dart  # shared_preferences persistence
  shared/
    widgets/                  # shared buttons, backgrounds
test/
  domain/
    score_calculator_test.dart
    game_logic_test.dart
  presentation/
    game_widget_test.dart
  e2e/
    full_game_test.dart        # full game play-through
```

## Phases

### Phase 1 — Foundation & Dependencies
- Add `flutter_riverpod`, `shared_preferences` to `pubspec.yaml`.
- Set up `core/theme` (light/dark), `core/router`, and wired `main.dart` shell.
- **Completion:** `flutter analyze` passes; app runs in `-d chrome`.

### Phase 2 — Domain: Scoring Engine (pure, dependency-free)
- Implement `die.dart`, `category.dart`, `score_calculator.dart` (README rules, table-driven).
- **Testing:** Comprehensive unit tests — every category, valid/invalid combos, edge cases (straights 1-2-3-4-5, small straight overlap, Yatzy repeatability, full house 25, bonus threshold 63).
- **Completion:** `test/domain/score_calculator_test.dart` green.

### Phase 3 — Domain: Game State Machine
- Implement `game_logic.dart`: roll, hold, `rollsUsed` (max 3), score-category locking, 13-category game-over, total/upper/bonus calc, `newGame()`.
- **Testing:** Turn flow tests: hold persists, max-3-roll enforcement, rescore prevention, game over after 13.
- **Completion:** `test/domain/game_logic_test.dart` green.

### Phase 4 — Data: High-Score Persistence
- `high_score_repository.dart` via `shared_preferences`; store best total + full scorecard breakdown.
- **Testing:** Repository unit tests with in-memory mock store.
- **Completion:** Persistence tests green; score survives app restart.

### Phase 5 — State: Riverpod Controllers
- `game_providers.dart`: `GameController`, `HighScoreController`; UI never touches domain/data directly.
- **Completion:** Riverpod wiring covered in widget tests; no direct domain access in widgets.

### Phase 6 — UI Screens & Widgets
- `dice.dart` (pips + roll animation), `die_tray.dart` (hold/hover states), `scorecard.dart` (scrollable grid, locked categories), `home_page.dart`, `game_page.dart`, `results_page.dart` (final score + play again).
- Responsive layout: phone and desktop sizes; light/dark theme.
- **Completion:** All screens render; `flutter analyze` clean.

### Phase 7 — Integration, Polish & E2E
- Full flow: Home → Roll/Hold/Score → Results → High score → Play Again.
- Animations, sounds (`assets/sounds/`), responsive polish.
- `flutter test` full suite, `flutter build web`, `flutter build apk`.
- **Testing:** End-to-end widget test playing a full 13-category game → game over → high score saved → new game.
- **Completion:** e2e test passes; both builds succeed; `README.md` updated with run instructions.

## Build & Verify Commands

```bash
flutter analyze
flutter test
flutter build web
flutter build apk
```

## Completion Criteria
- All scoring categories match README exactly.
- Max 3 rolls, holds, one category per turn, repeatable Yatzy, +35 bonus ≥63.
- Persistent high score, single player, responsive Android + Web, light/dark theme.
- `flutter analyze` clean, all tests green, both builds succeed.
