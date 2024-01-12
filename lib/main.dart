import 'package:firebase_auth/firebase_auth.dart';
import 'package:satellite/screens/auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:satellite/screens/chat_screen.dart';
import 'package:satellite/screens/splash_screen.dart';
import 'firebase_options.dart';

ThemeData lightTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme:
      ColorScheme.fromSeed(seedColor:const Color.fromARGB(200, 0, 102, 140)),
  brightness: Brightness.light,
);

ThemeData darkTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme:
    ColorScheme.fromSeed(seedColor:const Color.fromARGB(255, 59, 29, 96)),
  brightness: Brightness.dark,
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Satellite',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          // if firebase is still waiting or loading the token..
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const ChatScreen();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}
