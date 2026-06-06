import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import '../repo/auth_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final bool isVerifying;
  final String? generatedCode;
  final String? tempName;
  final bool isInitialized;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.isVerifying = false,
    this.generatedCode,
    this.tempName,
    this.isInitialized = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    String? successMessage,
    bool? isVerifying,
    String? generatedCode,
    String? tempName,
    bool? isInitialized,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage ?? this.successMessage,
      isVerifying: isVerifying ?? this.isVerifying,
      generatedCode: generatedCode ?? this.generatedCode,
      tempName: tempName ?? this.tempName,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      final fbUser = fb.FirebaseAuth.instance.currentUser;

      if (fbUser != null && !fbUser.emailVerified) {
        state = state.copyWith(isInitialized: true, isVerifying: true);
        return;
      }

      final user = await _authService.getUserData().timeout(
        const Duration(seconds: 15),
        onTimeout: () => null,
      );

      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final savedBio = prefs.getString('user_bio');
        final savedAvatar = prefs.getString('user_avatar');
        state = state.copyWith(
          user: user.copyWith(
            bio: savedBio ?? user.bio,
            avatar: savedAvatar ?? user.avatar,
          ),
          isInitialized: true,
        );
      } else {
        state = state.copyWith(isInitialized: true);
      }
    } catch (e) {
      state = state.copyWith(isInitialized: true);
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _authService.signUp(email, password, name).timeout(const Duration(seconds: 30));
      state = state.copyWith(
        isLoading: false,
        isVerifying: true,
        tempName: name,
        successMessage: 'Account created! Please check your Gmail to verify.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _authService.login(email, password).timeout(const Duration(seconds: 20));
      final user = await _authService.getUserData();
      state = state.copyWith(user: user, isLoading: false, isVerifying: false);
      return true;
    } catch (e) {
      final cleaned = _cleanError(e.toString());
      if (cleaned.contains('verify your email')) {
        state = state.copyWith(isLoading: false, isVerifying: true, successMessage: cleaned);
        return true;
      }
      state = state.copyWith(isLoading: false, error: cleaned);
      return false;
    }
  }

  Future<void> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _authService.forgotPassword(email);
      state = state.copyWith(isLoading: false, successMessage: 'Reset link sent to Gmail!');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _cleanError(e.toString()));
    }
  }

  Future<bool> checkVerificationStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final isVerified = await _authService.checkEmailVerified();
      if (isVerified) {
        final user = await _authService.getUserData();
        final updatedUser = user?.copyWith(name: state.tempName) ?? state.user?.copyWith(name: state.tempName);
        state = state.copyWith(isVerifying: false, user: updatedUser, isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: "Email not verified yet.");
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _cleanError(e.toString()));
      return false;
    }
  }

  Future<void> resendVerification() async {
    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      await _authService.resendVerificationEmail();
      state = state.copyWith(isLoading: false, successMessage: "Verification email resent.");
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _cleanError(e.toString()));
    }
  }

  void updateName(String name) async {
    if (state.user != null) {
      await _authService.updateDisplayName(name);
      state = state.copyWith(user: state.user!.copyWith(name: name));
    }
  }

  void updateBio(String bio) async {
    if (state.user == null) return;
    await _authService.updateBio(bio);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_bio', bio);
    state = state.copyWith(user: state.user!.copyWith(bio: bio));
  }

  Future<void> updateAvatar(String path) async {
    if (state.user == null) return;
    try {
      // Set loading state for avatar if needed, but here we just wait
      final downloadUrl = await _authService.uploadAndUpdateAvatar(path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_avatar', downloadUrl);
      state = state.copyWith(user: state.user!.copyWith(avatar: downloadUrl));
    } catch (e) {
      debugPrint("Avatar upload failed: $e");
    }
  }

  void addXp(int amount) {
    if (state.user == null) return;
    int newXp = state.user!.xp + amount;
    int newLevel = state.user!.level;
    int nextLevelXp = state.user!.nextLevelXp;
    if (newXp >= nextLevelXp) {
      newLevel++;
      newXp -= nextLevelXp;
      nextLevelXp = (nextLevelXp * 1.5).toInt();
    }
    state = state.copyWith(user: state.user!.copyWith(xp: newXp, level: newLevel, nextLevelXp: nextLevelXp));
  }

  void toggleSetting(String key, bool val) {
    if (state.user == null) return;
    final settings = state.user!.settings;
    UserSettings newSet;
    switch(key) {
      case 'publicProfile': newSet = settings.copyWith(publicProfile: val); break;
      case 'showEmail': newSet = settings.copyWith(showEmail: val); break;
      case 'notifications': newSet = settings.copyWith(notificationsEnabled: val); break;
      case '2fa': newSet = settings.copyWith(twoFactorEnabled: val); break;
      default: newSet = settings;
    }
    state = state.copyWith(user: state.user!.copyWith(settings: newSet));
  }

  void logout() async {
    await _authService.logout();
    state = AuthState(isInitialized: true);
  }

  String _cleanError(String error) {
    return error.replaceAll('Exception: ', '').replaceAll('FirebaseAuthException: ', '');
  }
}

final authServiceProvider = Provider((ref) => AuthService());
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});
