import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/motion.dart';
import 'navigation/router.dart';
import 'state/app_state.dart';
import 'theme/themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MysteryCityApp(state: AppState()));
}

class MysteryCityApp extends StatelessWidget {
  const MysteryCityApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: ListenableBuilder(
        listenable: Listenable.merge([state, MotionSettings.appReduceMotion]),
        builder: (context, _) => MaterialApp.router(
          title: 'Mystery City Adventures',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(state.theme),
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
