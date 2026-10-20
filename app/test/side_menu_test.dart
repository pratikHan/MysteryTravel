import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mystery_city_adventures/screens/home/side_menu_screen.dart';
import 'package:mystery_city_adventures/theme/themes.dart';

void main() {
  testWidgets('Side Menu lays out top to bottom without overflow',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: buildTheme(AppThemes.voyage),
      home: const SideMenuScreen(),
    ));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Add the widget'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Help center'), 300);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Calm mode'), findsOneWidget);
    expect(find.text('Restore Mystery Plus purchase'), findsOneWidget);

    // Let staggered entrance timers finish before teardown.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('Side Menu remembers its scroll position after reopening',
      (tester) async {
    GoogleFonts.config.allowRuntimeFetching = false;
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final nav = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      navigatorKey: nav,
      theme: buildTheme(AppThemes.voyage),
      home: const SizedBox(),
    ));
    Future<void> open() async {
      nav.currentState!.push(
          MaterialPageRoute<void>(builder: (_) => const SideMenuScreen()));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
    }

    double offset() => tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position
        .pixels;

    await open();
    await tester.drag(find.byType(ListView), const Offset(0, -600));
    // Let any bounce settle before reading the resting offset.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    final before = offset();
    expect(before, greaterThan(0));

    nav.currentState!.pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(SideMenuScreen), findsNothing);

    await open();
    expect(offset(), before);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 2));
  });
}
