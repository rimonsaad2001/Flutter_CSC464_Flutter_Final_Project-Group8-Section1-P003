// lib/services/order_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderService {
  final CollectionReference _orders =
      FirebaseFirestore.instance.collection('orders');

  Stream<QuerySnapshot> getOrders() {
    return _orders.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> placeOrder(Map<String, dynamic> data) {
    return _orders.add(data);
  }

  Future<void> updateOrderStatus(String id, String status) {
    return _orders.doc(id).update({'status': status});
  }
}
