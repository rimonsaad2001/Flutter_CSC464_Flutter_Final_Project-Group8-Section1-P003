// lib/providers/cart_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();

  Stream<QuerySnapshot> get cartItems => _cartService.getCartItems();

  Future<void> addToCart(String productId, Map<String, dynamic> data) async {
    try {
      await _cartService.addToCart(productId, data);
    } catch (e) {
      debugPrint('CartProvider.addToCart error: $e');
      rethrow;
    }
  }

  Future<void> updateCartItem(String id, Map<String, dynamic> data) async {
    try {
      await _cartService.updateCartItem(id, data);
    } catch (e) {
      debugPrint('CartProvider.updateCartItem error: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String id) async {
    try {
      await _cartService.removeFromCart(id);
    } catch (e) {
      debugPrint('CartProvider.removeFromCart error: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
    } catch (e) {
      debugPrint('CartProvider.clearCart error: $e');
      rethrow;
    }
  }
}
