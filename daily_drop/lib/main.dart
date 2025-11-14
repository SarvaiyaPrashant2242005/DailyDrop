import 'package:daily_drop/screens/LoginScreen.dart';
import 'package:daily_drop/screens/RegisterScreen.dart';
import 'package:daily_drop/screens/SplashScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'DailyDrop',
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  ),
  home: const SplashScreen(),
  routes: {
    '/login': (_) => const LoginScreen(),
    '/register': (_) => const RegisterScreen(),
  },
);
  }
}

