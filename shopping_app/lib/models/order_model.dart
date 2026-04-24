// lib/models/order_model.dart

import 'cart_model.dart';

class OrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final List<CartModel> items;
  final double total;
  final String status;
  final DateTime createdAt;

  const OrderModel({
    required this.id,
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
      customerName: data['customerName'] ?? '',
      customerPhone: data['customerPhone'] ?? '',
      customerAddress: data['customerAddress'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => CartModel.fromMap(
                item['productId'] ?? '',
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      total: _parseDouble(data['total']),
      status: data['status'] ?? 'pending',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  OrderModel copyWith({
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

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
