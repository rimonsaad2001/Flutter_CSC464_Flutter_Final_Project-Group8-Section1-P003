import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;
  bool _isAdmin = false;

  User? get currentUser => _user;
  bool get isAdmin => _isAdmin;
  bool get isLoggedIn => _user != null;

  AdminAuthProvider() {
    _auth.authStateChanges().listen((user) {
      _user = user;
      _loadUserRole(user);
      notifyListeners();
    });
  }

  // 🔥 ROLE SYSTEM (currently default = user)
  Future<void> _loadUserRole(User? user) async {
    if (user == null) {
      _isAdmin = false;
      notifyListeners();
      return;
    }

    // ✅ SIMPLE FIRESTORE-FREE VERSION (CURRENT)
    // Everyone is user by default
    _isAdmin = false;

    notifyListeners();
  }

  // 🔐 LOGIN
  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      debugPrint("SignIn error: $e");
      rethrow;
    }
  }

  // 🆕 SIGNUP
  Future<void> signUp(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
    } catch (e) {
      debugPrint("SignUp error: $e");
      rethrow;
    }
  }

  // 🚪 SIGNOUT
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _isAdmin = false;
      notifyListeners();
    } catch (e) {
      debugPrint("SignOut error: $e");
      rethrow;
    }
  }
}
