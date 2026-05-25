import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;

  bool get isLoading => _isLoading;

  Future<void> initialize(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 700));
    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }
}