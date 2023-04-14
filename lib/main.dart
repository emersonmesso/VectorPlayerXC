import 'package:apptv/pages/Home.dart';
import 'package:apptv/pages/SettingsPage.dart';
import 'package:apptv/pages/channels/ChannelsPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'pages/SplashScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeRight,
    DeviceOrientation.landscapeLeft,
  ]);

  if (defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android) {
    final appDocumentDirectory = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDirectory.path);
  } else if (defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.windows) {
    // Some desktop specific code there
  } else {
    await Hive.initFlutter();
  }
  runApp(
    Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
      },
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Vector Play',
        theme: ThemeData(
          primarySwatch: Colors.red,
          backgroundColor: HexColor("#201d2e"),
          accentColor: HexColor("#262432"),
        ),
        initialRoute: '/',
        routes: {
          // When navigating to the "/" route, build the FirstScreen widget.
          '/': (context) => const SplashScreen(),
          '/home' : (context) => const HomePage(),
          '/settings' : (context) => const SettingsPage(),
          '/category/channels' : (context) => const ChannelsPage(),
          // When navigating to the "/second" route, build the SecondScreen widget.
          //'/second': (context) => const SecondScreen(),
        },
      ),
    ),
  );
}
