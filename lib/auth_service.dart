import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart' as model;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream to listen to real-time authentication changes (Login/Logout)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// LOGIN: Validates credentials and ensures the email is verified via Gmail link
  Future<void> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 15));

      // Reload user to fetch the latest 'emailVerified' status from Firebase servers
      await credential.user?.reload();
      final user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        // Force sign out if they haven't clicked the link in their Gmail
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email! We sent a link to $email. Check your Spam folder.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw 'Connection interrupted. Please check your internet.';
    }
  }

  /// SIGNUP: Creates Firebase account, sends Gmail verification link, and sets up Firestore profile
  Future<void> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ).timeout(const Duration(seconds: 20));

      if (credential.user != null) {
        // 1. Set the name in Firebase Auth profile
        await credential.user!.updateDisplayName(name);

        // 2. Send the real verification link to their Gmail
        await credential.user!.sendEmailVerification();

        // 3. Initialize the 3D Dashboard data in Firestore
        await _db.collection('users').doc(credential.user!.uid).set({
          'id': credential.user!.uid,
          'name': name,
          'email': email,
          'avatar': '👤', // Default avatar (can be updated via Camera)
          'role': 'Member',
          'level': 1,
          'xp': 0,
          'nextLevelXp': 1000,
          'bio': 'Welcome to Be Practical! Tell us about your goals.',
          'location': 'Earth',
          'headline': 'Future Specialist',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Sign out after signup so they must log in AFTER verifying their email
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  /// PASSWORD RESET: Sends a real reset link to the provided Gmail
  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  /// CHECK EMAIL VERIFICATION: Checks if the user has clicked the link
  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return user.emailVerified;
  }

  /// RESEND VERIFICATION: Sends the link again
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }
  }

  /// FETCH USER DATA: Retrieves the premium 3D profile data from Firestore
  Future<model.User?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) return null;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;

      // DEEP FIX: Added null-safety fallbacks for all fields to prevent dashboard crashes
      return model.User(
        id: data['id'] ?? user.uid,
        name: data['name'] ?? 'Guest User',
        email: data['email'] ?? user.email ?? '',
        avatar: data['avatar'] ?? '👤',
        role: data['role'] ?? 'Member',
        headline: data['headline'] ?? 'Exploring',
        bio: data['bio'] ?? '',
        location: data['location'] ?? 'Global', // Prevents "Location Exception"
        level: data['level'] ?? 1,
        xp: data['xp'] ?? 0,
        nextLevelXp: data['nextLevelXp'] ?? 1000,
        settings: model.UserSettings(),
        skills: [],
        stats: model.UserStats(
          applicationsSubmitted: 0,
          interviewsScheduled: 0,
          offersReceived: 0,
          learningStreak: 1,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// PERMANENT SAVING: Updates the Bio in the Firestore Database
  Future<void> updateBio(String bio) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({'bio': bio});
    }
  }

  /// PERMANENT SAVING: Updates the Avatar path/emoji in the Firestore Database
  Future<void> updateAvatar(String avatarPath) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _db.collection('users').doc(user.uid).update({'avatar': avatarPath});
    }
  }

  /// PERMANENT SAVING: Updates the Display Name in both Auth and Firestore
  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await _db.collection('users').doc(user.uid).update({'name': name});
    }
  }

  /// LOGOUT: Ends the current Firebase session
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// ERROR HANDLING: Maps Firebase technical codes to readable messages
  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Account does not exist. Please Sign Up first.';
      case 'wrong-password':
        return 'The password you entered is incorrect.';
      case 'email-already-in-use':
        return 'This email is already registered. Try logging in.';
      case 'invalid-email':
        return 'Please enter a valid email format.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-not-verified':
        return e.message ?? 'Please verify your email via Gmail link.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
