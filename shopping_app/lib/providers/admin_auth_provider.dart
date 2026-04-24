// lib/providers/admin_auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AdminAuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get currentUser => _authService.currentUser;
  bool get isAdmin => _authService.isAdmin;
  bool get isLoggedIn => currentUser != null;

  AdminAuthProvider() {
    _authService.authStateChanges.listen((user) {
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    await _authService.signIn(email, password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}
