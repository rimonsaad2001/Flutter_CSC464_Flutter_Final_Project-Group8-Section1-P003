import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  double total(List<QueryDocumentSnapshot> docs) {
    double sum = 0;
    for (var d in docs) {
      final data = d.data() as Map<String, dynamic>;
      final price = (data['price'] ?? 0).toDouble();
      final quantity = (data['quantity'] ?? 1) as int;
      sum += price * quantity;
    }
    return sum;
  }

  Future<void> increaseQty(QueryDocumentSnapshot item) async {
    final data = item.data() as Map<String, dynamic>;
    final qty = data['quantity'] ?? 1;

    await item.reference.update({
      'quantity': qty + 1,
    });
  }

  Future<void> decreaseQty(QueryDocumentSnapshot item) async {
    final data = item.data() as Map<String, dynamic>;
    final qty = data['quantity'] ?? 1;

    if (qty > 1) {
      await item.reference.update({
        'quantity': qty - 1,
      });
    } else {
      await item.reference.delete();
    }
  }

  Future<void> removeItem(QueryDocumentSnapshot item) async {
    await item.reference.delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛒 Cart")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Your cart is empty"));
          }

          final items = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final data = item.data() as Map<String, dynamic>;
                    final price = (data['price'] ?? 0).toDouble();
                    final quantity = (data['quantity'] ?? 1) as int;
                    final itemTotal = price * quantity;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ListTile(
                        leading: Image.network(
                          data['imageUrl'] ?? '',
                          width: 55,
                          height: 55,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image_not_supported),
                        ),
                        title: Text(data['name'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Price: ৳ ${price.toStringAsFixed(0)}"),
                            Text("Subtotal: ৳ ${itemTotal.toStringAsFixed(0)}"),
                          ],
                        ),
                        trailing: SizedBox(
                          width: 140,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () => decreaseQty(item),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(
                                '$quantity',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              IconButton(
                                onPressed: () => increaseQty(item),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                              IconButton(
                                onPressed: () => removeItem(item),
                                icon: const Icon(Icons.delete, color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: const Border(top: BorderSide(color: Colors.grey)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total:",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "৳ ${total(items).toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: const Text("Checkout"),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CheckoutPage(total: total(items)),
                            ),
                          );
                        },
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
