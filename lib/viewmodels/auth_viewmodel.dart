import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool _isLoading = false;
  String? _errorMessage;
  String? _userRole;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  User? get currentUser => _auth.currentUser;
  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists
        ? UserModel.fromMap(doc.data()!, doc.id)
        : null);
  }
  Future<void> updateProfile({
    required String uid,
    required String name,
    required String bio,
    required List<String> skills,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'name': name.trim(),
      'bio': bio.trim(),
      'skills': skills,
    });
  }

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
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user == null) {
        _setError('Registration failed.');
        return false;
      }

      await user.updateDisplayName(name.trim());

      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name.trim(),
        'email': email.trim(),
        'role': role,
        'authProvider': 'password',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _userRole = role;
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_mapAuthError(e));
      return false;
    } catch (e) {
      debugPrint('Register error: $e');   // ← also fix the silent catch
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
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final user = credential.user;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        _userRole = doc.data()?['role'] as String?;
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
      await _auth.sendPasswordResetEmail(
        email: email.trim(),
      );

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
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _setError('Google sign-in cancelled.');
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        _setError('Google sign-in failed.');
        return false;
      }

      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (!doc.exists) {
        // New user — registration flow, save with role
        if (role.isEmpty) {
          _setError('Account not found. Please register first.');
          await _auth.signOut();
          await _googleSignIn.signOut();
          return false;
        }
        await docRef.set({
          'uid': user.uid,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'role': role,
          'authProvider': 'google',
          'createdAt': FieldValue.serverTimestamp(),
        });
        _userRole = role;
      } else {
        // Existing user — login flow, just read role
        _userRole = doc.data()?['role'] as String?;
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
      final user = _auth.currentUser;
      if (user == null) {
        _setError('No signed-in user.');
        return false;
      }

      await _firestore.collection('users').doc(user.uid).set({
        'role': role,
      }, SetOptions(merge: true));

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
    await _auth.signOut();
    await _googleSignIn.signOut();
    _userRole = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<String?> fetchUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    _userRole = doc.data()?['role'] as String?;
    notifyListeners();
    return _userRole;
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