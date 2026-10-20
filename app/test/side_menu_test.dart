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
  });
}
