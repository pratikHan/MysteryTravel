import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mystery_city_adventures/data/fixtures.dart';
import 'package:mystery_city_adventures/main.dart';
import 'package:mystery_city_adventures/navigation/router.dart';
import 'package:mystery_city_adventures/screens/adventure/adventure_path_screen.dart';
import 'package:mystery_city_adventures/state/app_state.dart';

void main() {
  testWidgets('Marking a stop done travels to the next stop',
      (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final state = AppState();
    await tester.pumpWidget(MysteryCityApp(state: state));
    await tester.pump(const Duration(seconds: 1));

    // Navigate to the Adventure tab.
    appRouter.go('/adventure');
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(AdventurePathScreen), findsOneWidget);
    expect(state.currentChapter, 0);
    expect(find.text(Fixtures.places.first.name), findsOneWidget);

    // Tap the Done button on the current stop card.
    await tester.tap(find.text('Done'));
    // One small pump starts the travel ticker, then jump through the
    // travel animation (1400ms) + scroll (900ms).
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 1000));

    expect(state.currentChapter, 1);
    expect(state.adventureComplete, isFalse);
  });

  testWidgets('Finishing the last stop completes the adventure',
      (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final state = AppState()..currentChapter = Fixtures.places.length - 1;
    await tester.pumpWidget(MysteryCityApp(state: state));
    await tester.pump(const Duration(seconds: 1));

    appRouter.go('/adventure');
    await tester.pump(const Duration(milliseconds: 600));

    // The last stop's card is far down the scene; bring it on screen.
    final scrollable = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollable, const Offset(0, -1600));
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text('Done'), warnIfMissed: false);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pump(const Duration(milliseconds: 600));

    expect(state.adventureComplete, isTrue);
    // The stamp finale screen is pushed.
    expect(find.text('You Earned a Stamp!'), findsOneWidget);
  });
}
