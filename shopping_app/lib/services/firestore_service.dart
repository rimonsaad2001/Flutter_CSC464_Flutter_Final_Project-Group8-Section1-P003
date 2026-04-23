import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // 📦 PRODUCTS
  // =========================

  CollectionReference get products => _db.collection('products');

  Stream<QuerySnapshot> getProducts() {
    return products.snapshots();
  }

  Future<void> addProduct(Map<String, dynamic> data) {
    return products.add(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return products.doc(id).update(data);
  }

  Future<void> deleteProduct(String id) {
    return products.doc(id).delete();
  }

  // =========================
  // 🛒 CART
  // =========================

  CollectionReference get cart => _db.collection('cart');

  Stream<QuerySnapshot> getCartItems() {
    return cart.snapshots();
  }

  Future<void> addToCart(String productId, Map<String, dynamic> data) {
    return cart.doc(productId).set(data);
  }

  Future<void> updateCartItem(String id, Map<String, dynamic> data) {
    return cart.doc(id).update(data);
  }

  Future<void> removeFromCart(String id) {
    return cart.doc(id).delete();
  }

  Future<void> clearCart() async {
    final snapshot = await cart.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // =========================
  // 📦 ORDERS
  // =========================

  CollectionReference get orders => _db.collection('orders');

  Stream<QuerySnapshot> getOrders() {
    return orders.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> placeOrder(Map<String, dynamic> data) {
    return orders.add(data);
  }

  Future<void> updateOrderStatus(String id, String status) {
    return orders.doc(id).update({'status': status});
  }
}
