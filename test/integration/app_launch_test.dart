import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:poker_dice/main.dart';
import 'package:poker_dice/features/score/score_provider.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([SharedPreferences])
import 'app_launch_test.mocks.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    final mockSharedPreferences = MockSharedPreferences();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
        ],
        child: const PokerDiceApp(),
      ),
    );
    expect(find.byType(PokerDiceApp), findsOneWidget);
  });
}
