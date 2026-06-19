import 'package:flutter/material.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    await Future.delayed(const Duration(milliseconds: 300));
    _isInitialized = true;
    notifyListeners();
  }
}