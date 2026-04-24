// lib/services/cart_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔐 User-specific cart reference (VERY IMPORTANT FIX)
  CollectionReference get _cart {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User not logged in");
    }

    return _db.collection('users').doc(user.uid).collection('cart');
  }

  // 📦 Get cart items (real-time stream)
  Stream<QuerySnapshot> getCartItems() {
    return _cart.snapshots();
  }

  // ➕ Add item to cart
  Future<void> addToCart(String productId, Map<String, dynamic> data) async {
    try {
      await _cart.doc(productId).set({
        ...data,
        'productId': productId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to add to cart: $e");
    }
  }

  // 🔄 Update cart item (quantity, etc.)
  Future<void> updateCartItem(String id, Map<String, dynamic> data) async {
    try {
      await _cart.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("Failed to update cart item: $e");
    }
  }

  // ❌ Remove single item
  Future<void> removeFromCart(String id) async {
    try {
      await _cart.doc(id).delete();
    } catch (e) {
      throw Exception("Failed to remove item: $e");
    }
  }

  // 🧹 Clear full cart (ONLY current user)
  Future<void> clearCart() async {
    try {
      final snapshot = await _cart.get();

      final batch = _db.batch();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception("Failed to clear cart: $e");
    }
  }
}
