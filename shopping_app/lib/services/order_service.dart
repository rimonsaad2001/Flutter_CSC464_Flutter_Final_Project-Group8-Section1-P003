// lib/services/order_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final CollectionReference _orders =
      FirebaseFirestore.instance.collection('orders');

  // 📦 Get all orders (latest first)
  Stream<QuerySnapshot> getOrders() {
    return _orders.orderBy('createdAt', descending: true).snapshots();
  }

  // 🛒 Place new order
  Future<void> placeOrder(Map<String, dynamic> data) async {
    try {
      await _orders.add({
        ...data,

        // ✅ ALWAYS USE SERVER TIMESTAMP (IMPORTANT)
        'createdAt': FieldValue.serverTimestamp(),

        // ✅ default status if not provided
        'status': data['status'] ?? 'pending',
      });
    } catch (e) {
      throw Exception("Failed to place order: $e");
    }
  }

  // 🔄 Update order status
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _orders.doc(id).update({
        'status': status,
      });
    } catch (e) {
      throw Exception("Failed to update order: $e");
    }
  }

  // 🗑 Delete order (optional but useful for admin)
  Future<void> deleteOrder(String id) async {
    try {
      await _orders.doc(id).delete();
    } catch (e) {
      throw Exception("Failed to delete order: $e");
    }
  }
}
