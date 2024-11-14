import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:Whispr/firebase_options.dart';
import 'package:Whispr/pages/user_pages/home_page.dart';
//import 'package:Whispr/services/api/firebase_api.dart';
import 'package:Whispr/services/auth/auth_gate.dart';
import 'package:Whispr/themes/theme_provider.dart';
import 'package:provider/provider.dart';

final navigatorKey = GlobalKey<NavigatorState>(); //Notifs stuff so ignore

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseApi().initNotifications(); <!-- Push Notifs that i cant figure out lol-->

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
