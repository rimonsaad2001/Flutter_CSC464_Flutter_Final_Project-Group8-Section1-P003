// lib/pages/product_details_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_provider.dart';
import '../models/product_model.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productId;

  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  bool _loading = false;

  Future<void> _addToCart(ProductModel product) async {
    setState(() => _loading = true);

    await context.read<CartProvider>().addToCart(product.id, {
      'productId': product.id,
      'name': product.name,
      'price': product.price,
      'image': product.image,
      'quantity': 1,
    });

    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${product.name} added to cart")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('products')
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.data!.exists) {
            return const Center(child: Text("Product not found"));
          }

          final product = ProductModel.fromMap(
            snapshot.data!.id,
            snapshot.data!.data() as Map<String, dynamic>,
          );

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: Colors.deepPurple,
                leading: IconButton(
                  icon: const Icon(Icons.home),
                  onPressed: () => context.go('/'),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(product.name),
                  background: _buildImage(product.image),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name,
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("৳ ${product.price}"),
                      const SizedBox(height: 10),
                      Text(product.description),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _loading ? null : () => _addToCart(product),
                          child: Text(_loading ? "Adding..." : "Add to Cart"),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildImage(String image) {
    if (image.isEmpty) {
      return Image.network('https://picsum.photos/400', fit: BoxFit.cover);
    }

    if (image.startsWith('http')) {
      return Image.network(image, fit: BoxFit.cover);
    }

    try {
      return Image.memory(base64Decode(image), fit: BoxFit.cover);
    } catch (_) {
      return Image.network('https://picsum.photos/400');
    }
  }
}
