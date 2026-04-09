# Poker Dice Game

A Flutter‑based implementation of **Poker Dice**, playable on Android devices and the Web.

## Overview
Poker Dice is a dice‑rolling game where players aim to score the highest total by achieving specific combinations. This app provides a single‑player experience with smooth animations, a clear score sheet, persistent high‑score tracking, and full accessibility support.

## Features
- 🎲 Roll five dice with realistic animation
- 📊 Automatic scoring for all standard Yatzy categories
- 🏆 Persistent high‑score storage (top 10 scores)
- 📱 Responsive UI for mobile, tablet, and desktop
- 🌙 Light / dark theme support
- ♿ Full accessibility support (screen readers, keyboard navigation)

## Gameplay Instructions

### How to Play
1. **Start a Game**: Tap "New Game" to begin
2. **Roll the Dice**: Tap "ROLL" to roll all dice (you have 3 rolls per turn)
3. **Hold Dice**: Tap any die to hold it (orange border indicates held dice)
4. **Re-roll**: Tap "ROLL" again to re-roll only the unheld dice
5. **Score**: After rolling, tap "PLAY" to score in your selected category
6. **Repeat**: Continue until all 13 categories are filled

### Controls
- **ROLL Button**: Rolls unheld dice. Shows roll count (0, 1, or 2).
- **PLAY Button**: Scores the selected category. Enabled after rolling.
- **Die**: Tap to toggle hold/unhold state.
- **Score Row**: Tap to select a category for scoring.

## Scoring Rules

### Upper Section

| Category | Description | Score |
|----------|-------------|-------|
| Aces | Sum of dice showing 1 | 1 point each |
| Twos | Sum of dice showing 2 | 2 points each |
| Threes | Sum of dice showing 3 | 3 points each |
| Fours | Sum of dice showing 4 | 4 points each |
| Fives | Sum of dice showing 5 | 5 points each |
| Sixes | Sum of dice showing 6 | 6 points each |
| **Bonus** | If upper total ≥ 63 | +35 points |

### Lower Section

| Category | Description | Score |
|----------|-------------|-------|
| Three of a Kind | 3+ dice with same value | Sum of ALL dice |
| Four of a Kind | 4+ dice with same value | Sum of ALL dice |
| Full House | Exactly 3 of one + 2 of another | 25 points |
| Small Straight | 4 consecutive values | 30 points |
| Large Straight | 5 consecutive values | 40 points |
| Yatzy | All 5 dice match | 50 points (+50 bonus each additional) |
| Chance | Any combination | Sum of ALL dice |

### Special Rules

**Yatzy Bonus**:
- First Yatzy: 50 points
- Each additional Yatzy: +50 bonus (2nd = 100, 3rd = 150, etc.)

**Full House Validation**:
- Must be exactly 3 of one value + 2 of another
- 4 of a kind + 1 does NOT count as Full House

## High Scores

- Top 10 scores are saved automatically
- Scores include the date achieved
- View high scores from the Game Over screen
- "View High Scores" button shows your achievements

## Accessibility

This game supports:
- Screen readers (TalkBack/VoiceOver) with semantic labels
- Keyboard navigation for all interactive elements
- High contrast mode compatibility
- Responsive text scaling

## Screenshots

### Game Screen
![Game Screen](screenshots/game_screen.png)

### High Scores
![High Scores](screenshots/high_scores.png)

### Game Over
![Game Over](screenshots/game_over.png)

*Note: Screenshots are placeholders. Replace with actual screenshots.*

## Technical Details

### Built With
- **Flutter**: Cross-platform UI framework
- **Dart**: Programming language  
- **SharedPreferences**: Local data persistence

### Project Structure

```
lib/
├── src/
│   ├── domain/          # Business logic and models
│   │   ├── models/      # Data models (Die, ScoreSheet, etc.)
│   │   ├── scoring/     # Scoring algorithms
│   │   └── game_state.dart
│   ├── data/            # Data layer
│   │   └── high_score_repository.dart
│   ├── ui/              # User interface
│   │   ├── components/  # Reusable widgets
│   │   ├── pages/       # Full pages
│   │   ├── theme/       # Theme configuration
│   │   └── utils/       # Utilities (responsive, accessibility)
│   └── bloc/            # State management
└── main.dart
```

## Getting Started

```bash
git clone https://github.com/carlosroman/poker-dice-app.git
cd poker-dice-app
flutter pub get
flutter run -d chrome   # Run in browser
# or
flutter run -d <android-device-id>  # Run on Android device/emulator
```

## Building

```bash
# Android APK
flutter build apk --release

# Web (static files in build/web)
flutter build web
```

## Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests: `flutter test`
5. Format code: `dart format .`
6. Submit a pull request

## License

MIT © 2026 Carlos Roman