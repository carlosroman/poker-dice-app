# Yatzy Poker Dice Game - Implementation Plan

A comprehensive multi-phase plan for implementing a Flutter-based Yatzy (poker dice) game.

---

## Project Overview

**Game Type**: Yatzy/Poker Dice (single-player)  
**Platforms**: Android, Web  
**State Management**: Riverpod  
**Dice Style**: Card-style (9, 10, J, Q, K, A)  
**Scoring Categories**: 13 total (6 upper, 6 lower, 1 bonus)

**Game Rules**:
- Roll 5 dice up to 3 times per turn
- Select dice to hold between rolls
- Choose one scoring category per turn (can score 0)
- Game ends when all 13 categories are filled
- Upper section bonus: +35 if total >= 63

---

## Phase 1: Project Foundation

### Tasks
1. **Directory Structure Setup**
   - Create `lib/core/constants/` - Game constants
   - Create `lib/core/utils/` - Utility functions
   - Create `lib/features/game/models/` - Data models
   - Create `lib/features/game/logic/` - Scoring engine
   - Create `lib/features/game/providers/` - State management
   - Create `lib/features/score/` - Persistence layer
   - Create `lib/features/ui/widgets/` - Reusable components
   - Create `lib/features/ui/screens/` - Full screens

2. **Dependencies Configuration**
   - Add `flutter_riverpod` for state management
   - Add `shared_preferences` for persistence
   - Add `google_fonts` for card-style typography
   - Run `flutter pub get`

3. **Constants Setup**
   - Define card-style dice faces: `[9, 10, 'J', 'Q', 'K', 'A']`
   - Configure game constants (max rolls: 3, bonus threshold: 30)

### Testing Requirements
- **Integration Test**: `test/integration/app_launch_test.dart` - Verify app launches without errors

---

## Phase 2: Core Game Logic

### Tasks
1. **Dice Model** (`lib/features/game/models/dice.dart`)
   - Value (0-5 index mapping to card faces)
   - Hold state (boolean)
   - Roll functionality (random value generation)

2. **Game State Model** (`lib/features/game/models/game_state.dart`)
   - Dice collection (5 dice)
   - Rolls remaining counter
   - Turn state (active/inactive)
   - Score sheet tracking (13 categories with scored/unscored status)

3. **Scoring Engine** (`lib/features/game/logic/scoring.dart`)
   - **Upper Section**:
     - "Pair of 9s" - Sum of all 9s
     - "Pair of 10s" - Sum of all 10s
     - "Pair of Jacks" - Sum of all Jacks
     - "Pair of Queens" - Sum of all Queens
     - "Pair of Kings" - Sum of all Kings
     - "Pair of Aces" - Sum of all Aces
   - **Lower Section**:
     - "Two Pair" - Two different pairs (sum of 4 dice)
     - "Three of a Kind" - At least 3 same (sum of all)
     - "Four of a Kind" - At least 4 same (sum of all)
     - "Straight" - 9-10-J-Q-K-A (25 points)
     - "Full House" - Three + Pair (sum of all)
     - "Yatzy" - All 5 same (50 points)
   - **Bonus**: +20 if upper section total ≥ 30
   - **Game Over**: When all 13 categories filled

4. **Game Provider** (`lib/features/game/providers/game_provider.dart`)
   - Riverpod notifier managing game state
   - Methods: `rollDice()`, `toggleHold()`, `selectScore()`, `resetGame()`
   - Handle turn transitions and game over detection

### Testing Requirements
- **Unit Test**: `test/features/game/models/dice_test.dart`
  - Dice value mapping (all 6 faces)
  - Dice hold/unhold toggle
  - Dice roll randomness (statistical validation)
- **Unit Test**: `test/features/game/logic/scoring_test.dart`
  - All 6 upper section combinations
  - All 6 lower section combinations
  - Bonus calculation logic
  - Edge cases (empty hand, invalid combinations)
- **Unit Test**: `test/features/game/providers/game_provider_test.dart`
  - Game state transitions
  - Roll mechanics
  - Score selection
- **Integration Test**: `test/integration/game_flow_test.dart`
  - Full turn flow (3 rolls, select score, advance)
  - Game over detection

---

## Phase 3: Persistence Layer

### Tasks
1. **Score Repository** (`lib/features/score/score_repository.dart`)
   - Save high score to shared preferences
   - Load high score from shared preferences
   - Clear/reset high score functionality

2. **Provider Setup** (`lib/features/score/score_provider.dart`)
   - Riverpod provider for repository
   - Handle async loading errors

### Testing Requirements
- **Unit Test**: `test/features/score/score_repository_test.dart`
  - Save high score
  - Load high score
  - Clear scores
- **Integration Test**: `test/integration/persistence_test.dart`
  - Full persistence cycle (save → restart → load)

---

## Phase 4: UI Components

### Tasks
1. **Dice Card Widget** (`lib/features/ui/widgets/dice_card.dart`)
   - Display card-style face value
   - Visual hold indicator (border/icon)
   - Simple scale/fade roll animation

2. **Score Sheet Widget** (`lib/features/ui/widgets/score_sheet.dart`)
   - Display all 13 scoring categories
   - Show potential scores (calculated preview)
   - Visual states: available/scored/disabled

3. **Game Controls Widget** (`lib/features/ui/widgets/game_controls.dart`)
   - Roll button with state management
   - Rolls remaining counter
   - New game button

4. **Game Info Header** (`lib/features/ui/widgets/game_info_header.dart`)
   - Current turn display
   - High score display
   - Current total score

### Testing Requirements
- **Widget Test**: `test/features/ui/widgets/dice_card_test.dart`
  - Renders correct face
  - Shows hold indicator when held
- **Widget Test**: `test/features/ui/widgets/score_sheet_test.dart`
  - Displays all categories
  - Shows potential scores
- **Widget Test**: `test/features/ui/widgets/game_controls_test.dart`
  - Roll button disabled when no rolls remaining
- **Integration Test**: `test/integration/ui_integration_test.dart`
  - Dice selection updates potential scores

---

## Phase 5: Main Game Screen

### Tasks
1. **Layout Implementation** (`lib/features/ui/screens/game_screen.dart`)
   - **Top Header Bar**:
     - Left: Back arrow button (circular, yellow/orange)
     - Center: Score display - "2070 You" format (large white text)
     - Right: Menu button (circular, yellow/orange with list icon)
   - **Scorecard Section** (Two-Column Layout):
     - **Minor Column** (left):
       - 6 rows for die face values (1 through 6)
       - Each row: yellow die face icon | current score (blue box) | potential score (white text)
       - Bonus row at bottom: "BONUS +35" label with progress indicator (e.g., "37/63")
     - **Major Column** (right):
       - 7 scoring categories with icons:
         1. "3x" - Three of a kind
         2. "4x" - Four of a kind
         3. House icon - Full house
         4. "small" card icon - Small straight
         5. "large" card icon - Large straight
         6. "Yatzy" - Five of a kind
         7. "?" - Chance
       - Each category: icon (yellow box) | current score (blue box) | potential score (white text)
   - **Dice Display Section**:
     - 5 card-style dice in horizontal row
     - White dice with black pips
     - Orange border indicates selected/held dice
     - Scrollable if screen width is limited
   - **Controls Section**:
     - "ROLL" button with rolls remaining counter (disabled when 0 rolls)
     - "PLAY" button (large, white with orange text) to submit score
   - Responsive design for mobile and web

2. **Theme Configuration**
   - Light/dark theme support
   - Card-style color scheme

3. **Game Flow Integration**
   - Connect all widgets to Riverpod providers
   - Handle score selection → auto-advance to next turn
   - Game over detection and final score display

### Testing Requirements
- **Widget Test**: `test/features/ui/screens/game_screen_test.dart`
  - Renders all sections
  - Theme switching works
- **Integration Test**: `test/integration/full_game_test.dart`
  - Complete game cycle (start → play → game over)
  - Score selection advances turn
  - Game over shows correct final score

---

## Phase 6: Testing & Polish

### Tasks
1. **Test Coverage Review**
   - Ensure all logic has unit tests
   - Ensure all UI components have widget tests
   - Add missing integration tests

2. **Animation Polish**
   - Refine dice roll animation timing
   - Add score selection animation
   - Smooth transitions between turns

3. **Responsive Testing**
   - Test on mobile (Android API 21+)
   - Test on web (Chrome, Edge, Firefox)
   - Adjust layouts for different screen sizes

4. **Performance Optimization**
   - Profile app performance
   - Optimize animations
   - Reduce widget rebuilds using `const`

### Testing Requirements
- **All Previous Tests**: Ensure all pass
- **Integration Test**: Mobile platform testing
- **Integration Test**: Web platform testing
- **Performance Test**: Animation frame rate validation
- **Lint Check**: `flutter analyze` - No errors
- **Format Check**: `dart format .` - Consistent formatting

---

## Phase 7: Build & Deployment

### Tasks
1. **Build Configuration**
   - Configure Android APK build
   - Configure Web build

2. **Pre-release Checks**
   - Run `flutter analyze`
   - Run `dart format .`
   - Run `flutter test`

3. **Build Artifacts**
   - Generate release APK (`flutter build apk --release`)
   - Generate web build (`flutter build web`)

### Testing Requirements
- **Integration Test**: APK installs and runs on device
- **Integration Test**: Web build loads in browser
- **Smoke Test**: Full game playable on both platforms

---

## Test File Structure

```
test/
├── integration/
│   ├── app_launch_test.dart
│   ├── game_flow_test.dart
│   ├── persistence_test.dart
│   ├── ui_integration_test.dart
│   └── full_game_test.dart
├── features/
│   ├── game/
│   │   ├── models/
│   │   │   └── dice_test.dart
│   │   ├── logic/
│   │   │   └── scoring_test.dart
│   │   └── providers/
│   │       └── game_provider_test.dart
│   ├── score/
│   │   └── score_repository_test.dart
│   └── ui/
│       ├── widgets/
│       │   ├── dice_card_test.dart
│       │   ├── score_sheet_test.dart
│       │   └── game_controls_test.dart
│       └── screens/
│           └── game_screen_test.dart
└── widget_test.dart
```

---

## Test Coverage Matrix

| Component | Unit Tests | Widget Tests | Integration Tests |
|-----------|------------|--------------|-------------------|
| Dice Model | ✓ | - | - |
| Scoring Engine | ✓ | - | - |
| Game Provider | ✓ | - | - |
| Score Repository | ✓ | - | ✓ |
| Dice Card Widget | - | ✓ | - |
| Score Sheet Widget | - | ✓ | ✓ |
| Game Controls | - | ✓ | - |
| Game Info Header | - | ✓ | - |
| Game Screen | - | ✓ | ✓ |
| Full Game Flow | - | - | ✓ |
| Platform Builds | - | - | ✓ |

---

## Implementation Order

1. **Phase 1**: Project setup, dependencies, constants
2. **Phase 2**: Core game logic + unit tests
3. **Phase 3**: Persistence layer + tests
4. **Phase 4**: UI components + widget tests
5. **Phase 5**: Main screen + integration tests
6. **Phase 6**: Polish, performance, all tests
7. **Phase 7**: Build and deployment

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0
  shared_preferences: ^2.2.0
  google_fonts: ^6.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mockito: ^5.4.0  # For testing
```

---

## Project Structure

```
lib/
├── core/
│   ├── constants/
│   │   └── dice_faces.dart
│   └── utils/
│       └── random_utils.dart
├── features/
│   ├── game/
│   │   ├── models/
│   │   │   ├── dice.dart
│   │   │   └── game_state.dart
│   │   ├── logic/
│   │   │   └── scoring.dart
│   │   └── providers/
│   │       └── game_provider.dart
│   ├── score/
│   │   ├── score_repository.dart
│   │   └── score_provider.dart
│   └── ui/
│       ├── widgets/
│       │   ├── dice_card.dart
│       │   ├── score_sheet.dart
│       │   ├── game_controls.dart
│       │   └── game_info_header.dart
│       └── screens/
│           └── game_screen.dart
└── main.dart
```

---

## Notes

- **Game Over**: When all 13 categories are filled (can score 0 in any)
- **Category Names**: Use "Pair of 9s", "Pair of 10s", etc.
- **Scope**: Core gameplay first (no settings screen initially)
- **Test Organization**: Tests mirror `lib/` structure
- **Animations**: Simple 2D scale/fade (no 3D)
- **Fonts**: Use `google_fonts` for card-style typography

---

## Status

- [ ] Phase 1: Project Foundation
- [ ] Phase 2: Core Game Logic
- [ ] Phase 3: Persistence Layer
- [ ] Phase 4: UI Components
- [ ] Phase 5: Main Game Screen
- [ ] Phase 6: Testing & Polish
- [ ] Phase 7: Build & Deployment