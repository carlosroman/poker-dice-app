# Yatzy Dice Game

A Flutter-based implementation of **Yatzy**, a classic dice game of strategy and luck. Play on Android devices or in your web browser!

## Overview

Yatzy is a dice-rolling game where players aim to score the highest total by achieving specific combinations. This single-player app features smooth roll animations, a clear score sheet, automatic scoring, and persistent high-score tracking.

**Supported Platforms:**
- 🤖 **Android** - Tested on API 21+ devices
- 🌐 **Web** - Works in modern browsers (Chrome, Edge, Firefox)

---

## How to Play

### Turn Structure

1. **Roll the Dice** - You can roll up to 3 times per turn
2. **Hold Dice** - After each roll, tap dice you want to keep (they won't reroll)
3. **Choose a Category** - Select one scoring category to fill for this turn
4. **Repeat** - Start a new turn with fresh rolls

### Game Objective

Fill all 13 scoring categories to complete the game. Your goal is to maximize your total score by strategically choosing which categories to fill each turn.

---

## Scoring Rules Reference

### Upper Section

Score the sum of dice showing the specified value:

| Category | Description | Example |
|----------|-------------|---------|
| **Aces** | Sum of all 1s | [1, 1, 3, 4, 5] = 2 points |
| **Twos** | Sum of all 2s | [2, 2, 2, 4, 6] = 6 points |
| **Threes** | Sum of all 3s | [3, 3, 1, 5, 6] = 6 points |
| **Fours** | Sum of all 4s | [4, 4, 4, 2, 3] = 12 points |
| **Fives** | Sum of all 5s | [5, 5, 1, 2, 6] = 10 points |
| **Sixes** | Sum of all 6s | [6, 6, 6, 3, 4] = 18 points |

**Bonus:** If your Upper Section total is **63 or more**, you get a **+35 bonus** (equivalent to scoring three of each die).

### Lower Section

| Category | Description | Requirements | Points |
|----------|-------------|--------------|--------|
| **Three of a Kind** | At least 3 dice showing the same value | 3+ matching dice | Sum of all dice |
| **Four of a Kind** | At least 4 dice showing the same value | 4+ matching dice | Sum of all dice |
| **Full House** | 3 dice of one value + 2 dice of another | Exact 3+2 combination | **25 points** |
| **Small Straight** | 4 consecutive values | e.g., [1,2,3,4] or [2,3,4,5] | **30 points** |
| **Large Straight** | 5 consecutive values | [1,2,3,4,5] or [2,3,4,5,6] | **40 points** |
| **Yatzy** | All 5 dice showing the same value | 5 matching dice | **50 points** |
| **Chance** | Any combination | No requirements | Sum of all dice |

### Special Rules

- **Yatzy Bonus:** If you roll multiple Yatzy combinations, you can score 50 points for each one (as long as you've already scored Yatzy at least once)
- **Full House Validation:** Must be exactly 3 of one kind + 2 of another (not 5 of a kind)
- **Straights:** Dice must be consecutive values (e.g., [1,2,3,4,5] is a Large Straight)
- **Zero Scores:** If a combination doesn't match, you score 0 for that category

---

## Screenshots

### Game Page
![Game Page](screenshots/game-page.png)
*Roll dice, hold your favorites, and choose your scoring category*

### Game Over Screen
![Game Over](screenshots/game-over.png)
*View your final score and category breakdown*

### High Scores
![High Scores](screenshots/high-scores.png)
*Track your best games and compete with yourself*

---

## Setup & Installation

### Prerequisites

- **Flutter SDK** (Dart ^3.10.8 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (for building APKs)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/poker-dice-app.git
   cd poker-dice-app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the game**
   ```bash
   # Web (recommended for development)
   flutter run -d chrome

   # Android device/emulator
   flutter run -d <device-id>
   ```

---

## Commands Reference

### Development

```bash
# Run tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run a single test by name
flutter test --name="testCounterIncrements"

# Watch mode (re-run on changes)
flutter test --watch

# Analyze code for issues
flutter analyze

# Auto-fix linting issues
flutter analyze --fix

# Format code before commits
dart format .
```

### Running the App

```bash
# Web development
flutter run -d chrome

# Android development
flutter run -d <android-device-id>
```

### Building for Release

```bash
# Build Android APK
flutter build apk --release

# Build Web (static files in build/web)
flutter build web
```

---

## Project Structure

```
poker-dice-app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── core/                     # Core utilities and services
│   ├── features/
│   │   └── game/
│   │       ├── data/             # Data layer (repositories, models)
│   │       ├── domain/           # Domain layer (entities, use cases)
│   │       └── presentation/     # UI layer (widgets, blocs)
│   └── shared/                   # Shared widgets and utilities
├── test/                         # Unit and widget tests
├── android/                      # Android-specific configuration
├── web/                          # Web-specific files
└── pubspec.yaml                  # Dependencies and metadata
```

---

## Architecture

### State Management (Bloc)

This project uses the **Bloc pattern** for predictable state management:

- **Separation of Concerns:** UI is decoupled from business logic
- **Testability:** Business logic can be tested independently
- **Predictability:** State changes are explicit and traceable

### Domain-Driven Design (DDD)

The codebase follows DDD principles:

- **Domain Layer:** Contains core game logic and rules
- **Data Layer:** Handles persistence and external data sources
- **Presentation Layer:** Manages UI and user interactions

### Layered Architecture

```
┌─────────────────┐
│  Presentation   │  ← UI Widgets, Blocs
├─────────────────┤
│    Domain       │  ← Entities, Use Cases, Rules
├─────────────────┤
│      Data       │  ← Repositories, Models, Storage
└─────────────────┘
```

---

## Testing

### Test Coverage

The project includes comprehensive tests for:

- **Unit Tests:** Game logic, scoring algorithms, dice mechanics
- **Widget Tests:** UI components, player interactions
- **Integration Tests:** Full game flow validation

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/features/game/scoring_test.dart

# Watch mode for TDD
flutter test --watch
```

### Writing Tests

Tests follow the **Arrange-Act-Assert** pattern:

```dart
test('should calculate Yatzy score correctly', () {
  // Arrange
  final dice = [6, 6, 6, 6, 6];
  final scorer = YatzyScorer();

  // Act
  final score = scorer.calculate('yatzy', dice);

  // Assert
  expect(score, equals(50));
});
```

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Commit Message Format

```
<type>(<scope>): <description>

feat(game): add poker dice logic
fix(ui): resolve widget rebuild issue
refactor(core): simplify state management
docs(readme): update setup instructions
test(game): add scoring unit tests
chore(deps): update dependencies
```

**Types:** `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`

---

## License

MIT © 2026 Carlos Roman
