import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:messaging_app/firebase_options.dart';
import 'package:messaging_app/pages/user_pages/home_page.dart';
//import 'package:messaging_app/services/api/firebase_api.dart';
import 'package:messaging_app/services/auth/auth_gate.dart';
import 'package:messaging_app/themes/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

final navigatorKey = GlobalKey<NavigatorState>(); //Notifs stuff so ignore

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseApi().initNotifications(); <!-- Push Notifs that i cant figure out lol-->
  await Hive.initFlutter(); // Initialize Hive
  await Hive.openBox('settings'); // Open a box for settings data

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthGate(),
        navigatorKey: navigatorKey, //Notifs stuff so ignore
        routes: {'/notification_screen': (context) => HomePage()},
        theme: Provider.of<ThemeProvider>(context).themeData);
  }
}
