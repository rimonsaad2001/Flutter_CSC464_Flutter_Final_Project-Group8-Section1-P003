import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  double total(List docs) {
    double t = 0;
    for (var d in docs) {
      t += (d['price'] * d['quantity']);
    }
    return t;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🛒 Cart")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cart').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var items = snapshot.data!.docs;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    var item = items[index];

                    return ListTile(
                      leading: Image.network(item['imageUrl']),
                      title: Text(item['name']),
                      subtitle: Text("৳ ${item['price']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => item.reference.delete(),
                      ),
                    );
                  },
                ),
              ),

              Text("Total: ৳ ${total(items)}"),

              ElevatedButton(
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
            ],
          );
        },
      ),
    );
  }
}
