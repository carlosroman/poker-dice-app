# Yatzy Dice Game

A Flutter‑based implementation of **Yatzy** (not to be confused with Yahtzee), playable on Android devices and the Web.

## Overview
Yatzy is a dice‑rolling game where players aim to score the highest total by achieving specific combinations (e.g. Two Pair, Full House, Straight, etc.). This app provides a single‑player experience with smooth roll animations, a clear score sheet, and persistent high‑score tracking.

## Features
- 🎲 Roll five dice with realistic animation
- 📊 Automatic scoring for all standard Yatzy categories
- 🏆 Persistent high‑score storage
- 📱 Responsive UI for both mobile (Android) and desktop browsers
- 🌙 Light / dark theme support
- 🎨 Choice of dice set ('1,2,3,4,5,6' or '9,10,J,Q,K,A')

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
MIT © 2026 Your Name