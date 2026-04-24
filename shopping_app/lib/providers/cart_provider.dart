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
      debugPrint('addToCart error: $e');
      rethrow;
    }
  }

  Future<void> updateCartItem(String id, Map<String, dynamic> data) async {
    try {
      await _cartService.updateCartItem(id, data);
    } catch (e) {
      debugPrint('updateCartItem error: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(String id) async {
    try {
      await _cartService.removeFromCart(id);
    } catch (e) {
      debugPrint('removeFromCart error: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      await _cartService.clearCart();
    } catch (e) {
      debugPrint('clearCart error: $e');
      rethrow;
    }
  }
}
