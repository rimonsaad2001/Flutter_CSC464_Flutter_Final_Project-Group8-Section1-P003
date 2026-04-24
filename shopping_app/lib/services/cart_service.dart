// lib/services/cart_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final CollectionReference _cart =
      FirebaseFirestore.instance.collection('cart');

  Stream<QuerySnapshot> getCartItems() {
    return _cart.snapshots();
  }

  Future<void> addToCart(String productId, Map<String, dynamic> data) {
    return _cart.doc(productId).set(data);
  }

  Future<void> updateCartItem(String id, Map<String, dynamic> data) {
    return _cart.doc(id).update(data);
  }

  Future<void> removeFromCart(String id) {
    return _cart.doc(id).delete();
  }

  Future<void> clearCart() async {
    final snapshot = await _cart.get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
