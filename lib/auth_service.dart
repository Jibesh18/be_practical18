import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart' as model;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password).timeout(const Duration(seconds: 15));
      await _auth.currentUser?.reload();
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        throw FirebaseAuthException(
          code: 'email-not-verified',
          message: 'Please verify your email! We sent a link to $email.',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(email: email, password: password).timeout(const Duration(seconds: 20));
      if (credential.user != null) {
        await credential.user!.updateDisplayName(name);
        await credential.user!.sendEmailVerification();
        await _db.collection('users').doc(credential.user!.uid).set({
          'id': credential.user!.uid,
          'name': name,
          'email': email,
          'avatar': '👤',
          'role': 'Member',
          'level': 1,
          'xp': 0,
          'nextLevelXp': 1000,
          'bio': 'Welcome to Be Practical!',
          'location': 'Earth',
          'headline': 'Future Specialist',
        });
        await _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> checkEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    return user.emailVerified;
  }

  Future<void> resendVerificationEmail() async {
    if (_auth.currentUser != null) await _auth.currentUser!.sendEmailVerification();
  }

  Future<model.User?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null || !user.emailVerified) return null;
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      return model.User(
        id: data['id'] ?? user.uid,
        name: data['name'] ?? 'User',
        email: data['email'] ?? user.email ?? '',
        avatar: data['avatar'] ?? '👤',
        role: data['role'] ?? 'Member',
        headline: data['headline'] ?? 'Exploring',
        bio: data['bio'] ?? '',
        location: data['location'] ?? 'Global',
        level: data['level'] ?? 1,
        xp: data['xp'] ?? 0,
        nextLevelXp: data['nextLevelXp'] ?? 1000,
        settings: model.UserSettings(),
        skills: [],
        stats: model.UserStats(applicationsSubmitted: 0, interviewsScheduled: 0, offersReceived: 0, learningStreak: 1),
      );
    } catch (e) { return null; }
  }

  Future<void> updateBio(String bio) async {
    final user = _auth.currentUser;
    if (user != null) await _db.collection('users').doc(user.uid).update({'bio': bio});
  }

  Future<String> uploadAndUpdateAvatar(String path) async {
    final user = _auth.currentUser;
    if (user == null) throw 'User not logged in';
    // In a real app, you would upload to Firebase Storage here.
    // For now, we save the path to Firestore.
    await _db.collection('users').doc(user.uid).update({'avatar': path});
    return path;
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.updateDisplayName(name);
      await _db.collection('users').doc(user.uid).update({'name': name});
    }
  }

  Future<void> logout() async => await _auth.signOut();

  String _handleError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found': return 'Account not found.';
      case 'wrong-password': return 'Incorrect password.';
      case 'email-already-in-use': return 'This email is already registered.';
      case 'email-not-verified': return e.message!;
      default: return e.message ?? 'Auth failed.';
    }
  }
}
