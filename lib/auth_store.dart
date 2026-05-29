import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthStore extends ChangeNotifier {
  AuthStore._();
  static final instance = AuthStore._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _initialized = false;

  User? get user => _user;
  bool get isSignedIn => _user != null;
  String get currentName => _user?.displayName ?? _user?.email ?? '';
  String get currentEmail => _user?.email ?? '';
  bool get isInitialized => _initialized;

  /// Initialize auth state listener. Call once from main.dart.
  void init() {
    if (_initialized) return;
    _initialized = true;
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Returns an error string, or null on success.
  Future<String?> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Creates a new account and signs in.
  Future<String?> signUp(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      // Set display name
      await credential.user?.updateDisplayName(name.trim());
      await credential.user?.reload();
      return null;
    } on FirebaseAuthException catch (e) {
      return _mapAuthError(e);
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }
}