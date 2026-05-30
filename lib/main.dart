import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_dice/providers/settings_provider.dart';
import 'package:poker_dice/screens/game_screen.dart';
import 'package:poker_dice/services/storage_service.dart';
import 'package:poker_dice/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MainApp()));
}

/// Async provider that loads the persisted theme mode.
final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final SettingsNotifier notifier =
      ref.read(settingsProvider.notifier);
  return await notifier.getThemeMode();
});

/// Root widget that initializes the app with persistent theme settings.
class MainApp extends ConsumerWidget {
  /// Creates the main app widget.
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeMode themeMode = ref.watch(themeModeProvider).when(
          loading: () => ThemeMode.system,
          error: (_, __) => ThemeMode.system,
          data: (mode) => mode,
        );

    return MaterialApp(
      title: 'Yatzy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const GameScreen(),
    );
  }
}
