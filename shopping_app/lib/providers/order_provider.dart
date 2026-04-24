import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  Stream<QuerySnapshot> get orders => _orderService.getOrders();

  Future<void> placeOrder(Map<String, dynamic> data) async {
    try {
      await _orderService.placeOrder({
        ...data,
        'createdAt': FieldValue.serverTimestamp(), // ✅ FIXED
        'status': 'pending',
      });
    } catch (e) {
      debugPrint('OrderProvider.placeOrder error: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _orderService.updateOrderStatus(id, status);
    } catch (e) {
      debugPrint('OrderProvider.updateOrderStatus error: $e');
      rethrow;
    }
  }
}
