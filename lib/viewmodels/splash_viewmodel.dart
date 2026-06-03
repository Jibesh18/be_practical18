import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../views/screens/login_screen.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Future<void> initialize(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 450));
    _isLoading = false;
    notifyListeners();

    if (!context.mounted) return;

    Navigator.of(context).pushReplacement(
      AppRoutes.smoothRoute(const LoginScreen()),
    );
  }
}