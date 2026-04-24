import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductDetailsPage extends StatelessWidget {
  final dynamic product;

  const ProductDetailsPage({super.key, required this.product});

  void addToCart() {
    FirebaseFirestore.instance.collection('cart').add({
      'name': product['name'],
      'price': product['price'],
      'imageUrl': product['imageUrl'],
      'quantity': 1,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: Column(
        children: [
          Image.network(product['imageUrl'], height: 250),
          Text(product['name'], style: const TextStyle(fontSize: 22)),
          Text("৳ ${product['price']}"),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(product['description'] ?? ""),
          ),
          ElevatedButton(
            onPressed: addToCart,
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}
