// lib/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pages/home_page.dart';
import '../pages/product_details_page.dart';
import '../pages/cart_page.dart';
import '../pages/checkout_page.dart';
import '../pages/orders_page.dart';
import '../pages/order_details_page.dart';
import '../pages/profile_page.dart';
import '../pages/admin_page.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../services/auth_service.dart';

final AuthService authService = AuthService();

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  // 🔥 AUTH REDIRECT LOGIC (FIXED)
  redirect: (context, state) {
    final user = FirebaseAuth.instance.currentUser;

    final location = state.matchedLocation;

    final isLogin = location == '/login';
    final isSignup = location == '/signup';
    final isAdminRoute = location.startsWith('/admin');

    final protectedRoutes = [
      '/profile',
      '/orders',
      '/checkout',
      '/cart',
    ];

    final isProtected = protectedRoutes.contains(location);

    final isAdmin = authService.isAdmin;

    // 🔒 ADMIN ONLY ROUTES
    if (isAdminRoute) {
      if (user == null) return '/login';
      if (!isAdmin) return '/';
    }

    // 🔒 USER PROTECTED ROUTES
    if (isProtected && user == null) {
      return '/login';
    }

    // 🔁 IF LOGGED IN → BLOCK LOGIN/SIGNUP
    if ((isLogin || isSignup) && user != null) {
      return '/';
    }

    return null;
  },

  routes: [
    // 🏠 HOME
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),

    // 📦 PRODUCT DETAILS
    GoRoute(
      path: '/product/:id',
      builder: (context, state) => ProductDetailsPage(
        productId: state.pathParameters['id']!,
      ),
    ),

    // 🛒 CART
    GoRoute(
      path: '/cart',
      builder: (context, state) => const CartPage(),
    ),

    // 💳 CHECKOUT
    GoRoute(
      path: '/checkout',
      builder: (context, state) => CheckoutPage(
        total: (state.extra as double?) ?? 0.0,
      ),
    ),

    // 📦 ORDERS
    GoRoute(
      path: '/orders',
      builder: (context, state) => const OrdersPage(),
    ),

    // 📄 ORDER DETAILS
    GoRoute(
      path: '/order/:id',
      builder: (context, state) => OrderDetailsPage(
        orderId: state.pathParameters['id']!,
      ),
    ),

    // 👤 PROFILE
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePage(),
    ),

    // 👨‍💼 ADMIN
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminPage(),
    ),

    // 🔐 LOGIN
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),

    // 🆕 SIGNUP
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
  ],

  // ❌ ERROR PAGE
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
