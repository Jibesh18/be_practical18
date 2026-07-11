import 'package:flutter/material.dart';

import '../views/screens/employer_home_screen.dart';

import '../views/screens/intern_screen.dart';
import '../views/screens/splash_screen.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/register_screen.dart';
import '../views/widgets/auth_gate.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String authGate = '/authGate';
  static const String employerHome = '/employerHome';
  static const String internHome = '/internHome';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    authGate: (context) => const AuthGate(),
    employerHome: (context) => const EmployerHomeScreen(),
    internHome: (context) => const InternHomeTab(),
  };

  static Route<dynamic> smoothRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionDuration: const Duration(milliseconds: 1100),
      reverseTransitionDuration: const Duration(milliseconds: 700),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.18, 1.0, curve: Curves.easeInOutCubic),
        );
        final slide = Tween<Offset>(
          begin: const Offset(0, 0.02),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        final scale = Tween<double>(begin: 0.992, end: 1.0)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: slide,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
    );
  }
}