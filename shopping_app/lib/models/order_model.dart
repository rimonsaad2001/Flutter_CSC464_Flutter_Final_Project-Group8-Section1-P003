// lib/models/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_model.dart';

class OrderModel {
  final String id;
  final String userId; // ✅ IMPORTANT
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<CartModel> items;
  final double total;
  final String status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      userId: data['userId'] ?? '', // ✅ FIXED
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',

      // ✅ SAFE ITEMS PARSING
      items: (data['items'] as List<dynamic>? ?? []).map((item) {
        final map = Map<String, dynamic>.from(item);
        return CartModel.fromMap(
          map['productId'] ?? '',
          map,
        );
      }).toList(),

      total: _parseDouble(data['total']),
      status: data['status'] ?? 'pending',

      // ✅ FIXED TIMESTAMP HANDLING
      createdAt: _parseDate(data['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId, // ✅ IMPORTANT
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'status': status,

      // ✅ STORE AS FIRESTORE TIMESTAMP
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  OrderModel copyWith({
    String? userId,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    List<CartModel>? items,
    double? total,
    String? status,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id,
      userId: userId ?? this.userId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

//
// 🔥 SAFE HELPERS
//

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

DateTime _parseDate(dynamic value) {
  if (value == null) return DateTime.now();

  if (value is Timestamp) {
    return value.toDate(); // ✅ Firestore case
  }

  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }

  return DateTime.now();
}
