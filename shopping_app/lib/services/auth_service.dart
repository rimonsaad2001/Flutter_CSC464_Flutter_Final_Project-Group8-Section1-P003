import 'package:firebase_auth/firebase_auth.dart';

const String adminEmail = 'rimonsadman@gmail.com';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔁 Auth state stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 👤 Current user
  User? get currentUser => _auth.currentUser;

  // 🔐 Admin check (SAFE + CASE INSENSITIVE)
  bool get isAdmin {
    final user = _auth.currentUser;

    if (user == null || user.email == null) return false;

    return user.email!.trim().toLowerCase() == adminEmail.trim().toLowerCase();
  }

  // 🔑 LOGIN
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _errorMessage(e);
    } catch (e) {
      throw "Unexpected error: $e";
    }
  }

  // 🆕 SIGN UP
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw _errorMessage(e);
    } catch (e) {
      throw "Unexpected error: $e";
    }
  }

  // 🚪 SIGN OUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw "Sign out failed: $e";
    }
  }

  // ❌ ERROR HANDLER
  String _errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'weak-password':
        return 'Password should be at least 6 characters';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      default:
        return e.message ?? 'Authentication error';
    }
  }
}
