import 'package:flutter_test/flutter_test.dart';
import 'package:poker_dice/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const MainApp());
    expect(find.byType(MainApp), findsOneWidget);
  });
}
