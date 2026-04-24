// lib/pages/cart_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../models/cart_model.dart';
import '../widgets/cart_item_widget.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  double _calculateTotal(List<QueryDocumentSnapshot> docs) {
    return docs.fold(0.0, (sum, d) {
      final data = d.data() as Map<String, dynamic>;
      final price = (data['price'] ?? 0).toDouble();
      final qty = (data['quantity'] ?? 1) as int;
      return sum + price * qty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff6f7fb),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text('My Cart'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: cartProvider.cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final items = snapshot.data?.docs ?? [];

          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 90,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final doc = items[index];
                    final cart = CartModel.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    );

                    return CartItemWidget(
                      item: cart,
                      onIncrease: () => cartProvider.updateCartItem(
                        doc.id,
                        {'quantity': cart.quantity + 1},
                      ),
                      onDecrease: () {
                        if (cart.quantity > 1) {
                          cartProvider.updateCartItem(
                            doc.id,
                            {'quantity': cart.quantity - 1},
                          );
                        } else {
                          cartProvider.removeFromCart(doc.id);
                        }
                      },
                      onRemove: () => cartProvider.removeFromCart(doc.id),
                    );
                  },
                ),
              ),

              // Checkout bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '৳ ${_calculateTotal(items).toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => context.go(
                          '/checkout',
                          extra: _calculateTotal(items),
                        ),
                        child: const Text(
                          'Proceed to checkout',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
