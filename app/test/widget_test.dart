import 'package:flutter_test/flutter_test.dart';
import 'package:mystery_city_adventures/main.dart';
import 'package:mystery_city_adventures/state/app_state.dart';

void main() {
  testWidgets('App boots to the splash screen', (tester) async {
    await tester.pumpWidget(MysteryCityApp(state: AppState()));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Get Started'), findsOneWidget);
  });
}
