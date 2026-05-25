import 'package:be_practical18/views/screens/splash_screen.dart';
import 'package:flutter/material.dart';


class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    // home: (context) => const HomeScreen(), // uncomment when ready
  };
}