import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../repository/auth_repository.dart';
import '../services/user_services.dart';

/// ViewModel for authentication + the current user's profile.
///
/// IMPORTANT: This class no longer talks to FirebaseAuth/Firestore directly.
/// All data access goes through AuthRepository (auth) and UserService
/// (profile document), so there is exactly one place that knows how auth
/// and user documents are stored.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final UserService _userService;

  AuthViewModel({
    AuthRepository? authRepository,
    UserService? userService,
  })  : _authRepo = authRepository ?? AuthRepository(),
        _userService = userService ?? UserService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  User? get currentUser => _authRepo.currentUser;

  /// Exposed so widgets like AuthGate can watch auth state through the
  /// ViewModel instead of instantiating AuthRepository themselves.
  Stream<User?> get authStateChanges => _authRepo.authStateChanges;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final credential = await _authRepo.registerWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        _setError('Registration failed.');
        return false;
      }

      await user.updateDisplayName(name.trim());

      await _authRepo.saveUser(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        authProvider: 'password',
      );

      _userRole = role;
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
      return false;
    } catch (e) {
      debugPrint('Register error: $e');
      _setError('Something went wrong.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final credential = await _authRepo.loginWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        _userRole = await _authRepo.fetchRole(user.uid);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
      return false;
    } catch (_) {
      _setError('Something went wrong.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _setError(null);

    try {
      await _authRepo.sendPasswordReset(email);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
      return false;
    } catch (_) {
      _setError('Unable to send reset email.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signInWithGoogle({required String role}) async {
    _setLoading(true);
    _setError(null);

    try {
      final userCredential = await _authRepo.signInWithGoogle();
      final user = userCredential?.user;
      if (user == null) {
        _setError('Google sign-in cancelled.');
        return false;
      }

      final existingRole = await _authRepo.fetchRole(user.uid);

      if (existingRole == null) {
        // New user — registration flow, save with role.
        if (role.isEmpty) {
          _setError('Account not found. Please register first.');
          await _authRepo.logout();
          return false;
        }
        await _authRepo.saveUser(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          role: role,
          authProvider: 'google',
        );
        _userRole = role;
      } else {
        _userRole = existingRole;
      }

      return true;
    } catch (e) {
      debugPrint('Google sign-in error: $e');
      _setError('Google sign-in failed.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> setRoleForCurrentUser(String role) async {
    _setLoading(true);
    _setError(null);

    try {
      final user = _authRepo.currentUser;
      if (user == null) {
        _setError('No signed-in user.');
        return false;
      }

      await _authRepo.saveUser(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        role: role,
        authProvider: 'password',
      );

      _userRole = role;
      return true;
    } catch (_) {
      _setError('Could not save role.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    _userRole = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> fetchUserRole() async {
    final user = _authRepo.currentUser;
    if (user == null) return null;

    _userRole = await _authRepo.fetchRole(user.uid);
    notifyListeners();
    return _userRole;
  }

  /// Used by AuthGate right after register/login, when the Firestore
  /// user doc may not have propagated yet.
  Future<String?> fetchUserRoleWithRetry() async {
    final user = _authRepo.currentUser;
    if (user == null) return null;

    _userRole = await _authRepo.fetchRoleWithRetry(user.uid);
    notifyListeners();
    return _userRole;
  }

  // ── Profile (delegates to UserService) ─────────────────────────────────

  /// Live stream of the current user's profile document, for ProfileTab
  /// and anywhere else that needs to watch profile changes.
  Stream<UserModel?> watchUserProfile(String uid) =>
      _userService.watchUser(uid);
  Future<UserModel?> getUserProfile(String uid) => _userService.getUser(uid);

  Future<void> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required List<String> skills,
    String? education,
    String? experience,
    String? linkedinUrl,
    String? githubUrl,
    String? cvUrl,
  }) {
    return _userService.updateProfile(
      uid: uid,
      name: name,
      bio: bio,
      skills: skills,
      education: education,
      experience: experience,
      linkedinUrl: linkedinUrl,
      githubUrl: githubUrl,
      cvUrl: cvUrl,
    );
  }



  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email.';

      case 'email-already-in-use':
        return 'An account with this email already exists.';

      case 'weak-password':
        return 'Password must be at least 6 characters.';

      case 'user-not-found':
        return 'Account not found. Please register first.';

      case 'wrong-password':
        return 'Invalid email or password.';

      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password.';

      case 'user-disabled':
        return 'This account is disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Try again later.';

      case 'network-request-failed':
        return 'Please check your internet connection.';

      default:
        return e.message ?? 'Something went wrong.';
    }
  }
}