// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/home_page.dart';
import '../pages/product_details_page.dart';
import '../pages/cart_page.dart';
import '../pages/checkout_page.dart';
import '../pages/orders_page.dart';
import '../pages/admin_page.dart';
import '../pages/login_page.dart';
import '../services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  redirect: (BuildContext context, GoRouterState state) async {
    final user = FirebaseAuth.instance.currentUser;
    final isGoingToAdmin = state.matchedLocation.startsWith('/admin');
    final isGoingToLogin = state.matchedLocation == '/login';

    if (isGoingToAdmin) {
      // Not logged in → go to login
      if (user == null) return '/login';

      // Logged in but not admin → go home
      final authService = AuthService();
      if (!authService.isAdmin) return '/';
    }

    // Already logged in as admin, no need to see login page
    if (isGoingToLogin) {
      final authService = AuthService();
      if (authService.isAdmin) return '/admin';
    }

    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) => ProductDetailsPage(
        productId: state.pathParameters['id']!,
      ),
    ),
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),
    GoRoute(
      path: '/checkout',
      builder: (context, state) => CheckoutPage(
        total: (state.extra as double?) ?? 0.0,
      ),
    ),
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersPage(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
      title: const Text('Page not found'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '404 — Page not found',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              foregroundColor: Colors.white,
            ),
            onPressed: () => context.go('/'),
            child: const Text('Go home'),
          ),
        ],
      ),
    ),
  ),
);
