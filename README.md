# Yatzy Dice Game

A Flutter‑based implementation of **Yatzy**, playable on Android devices and the Web.

## Overview
Yatzy is a dice‑rolling game where players aim to score the highest total by achieving specific combinations (e.g. Two Pair, Full House, Straight, etc.). This app provides a single‑player experience with smooth roll animations, a clear score sheet, and persistent high‑score tracking.

## Features
- 🎲 Roll five dice with realistic animation
- 📊 Automatic scoring for all standard Yatzy categories
- 🏆 Persistent high‑score storage
- 📱 Responsive UI for both mobile (Android) and desktop browsers
- 🌙 Light / dark theme support

## Scoring Rules

### Upper Section
- **Aces**: Sum of all dice showing 1 (1 point each)
- **Twos**: Sum of all dice showing 2 (2 points each)
- **Threes**: Sum of all dice showing 3 (3 points each)
- **Fours**: Sum of all dice showing 4 (4 points each)
- **Fives**: Sum of all dice showing 5 (5 points each)
- **Sixes**: Sum of all dice showing 6 (6 points each)
- **Bonus**: +35 if upper section total >= 63

### Lower Section
- **Three of a Kind**: Sum of all dice (if 3+ match)
- **Four of a Kind**: Sum of all dice (if 4+ match)
- **Full House**: 25 points (3 of one + 2 of another)
- **Small Straight**: 30 points (4 consecutive values)
- **Large Straight**: 40 points (5 consecutive values)
- **Yatzy**: 50 points (all 5 dice match, can be scored multiple times if scored at least once)
- **Chance**: Sum of all dice values

### Game Flow
- Roll 5 dice up to 3 times per turn
- Hold any dice between rolls
- Select one scoring category per turn
- Game ends when all 13 categories are filled

## Platforms
- **Android** – Tested on API 21+ devices
- **Web** – Works in modern browsers (Chrome, Edge, Firefox)

## Getting Started
```bash
git clone https://github.com/your-username/poker-dice-app.git
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

## License
MIT © 2026 Carlos Roman