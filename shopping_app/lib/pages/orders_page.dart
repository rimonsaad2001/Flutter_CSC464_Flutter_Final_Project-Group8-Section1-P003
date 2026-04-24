// lib/pages/orders_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/admin_auth_provider.dart';
import '../models/order_model.dart';

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  static const _statuses = [
    'pending',
    'placed',
    'shipped',
    'delivered',
    'cancelled',
  ];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'placed':
        return Colors.blue;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(
    BuildContext context,
    String orderId,
    String newStatus,
  ) async {
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update({'status': newStatus});

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status updated to ${newStatus.toUpperCase()}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = context.watch<AdminAuthProvider>().isAdmin;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Please login first")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        title: Text(isAdmin ? 'All Orders' : 'My Orders'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getOrdersStream(isAdmin, user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No orders yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final order = OrderModel.fromMap(
                docs[index].id,
                docs[index].data() as Map<String, dynamic>,
              );

              final color = _statusColor(order.status);

              return GestureDetector(
                onTap: () {
                  context.go('/order/${order.id}');
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.id.substring(0, 6).toUpperCase()}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(color: color),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(order.customerName),
                      Text(order.customerPhone),

                      const SizedBox(height: 10),

                      Text('৳ ${order.total.toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> _getOrdersStream(bool isAdmin, String uid) {
    final collection = FirebaseFirestore.instance.collection('orders');

    if (isAdmin) {
      return collection.orderBy('createdAt', descending: true).snapshots();
    } else {
      return collection.where('userId', isEqualTo: uid).snapshots(); // safe
    }
  }
}
