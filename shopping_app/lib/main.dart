import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

/// =======================
/// APP ROOT
/// =======================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mini Ecommerce',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const ProductListPage(),
    );
  }
}

/// =======================
/// CART MODEL (LOCAL)
/// =======================
class CartItem {
  final String id;
  final String name;
  final int price;
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.qty = 1,
  });
}

/// =======================
/// GLOBAL CART
/// =======================
class CartStore {
  static List<CartItem> items = [];

  static void add(String id, String name, int price) {
    final index = items.indexWhere((e) => e.id == id);
    if (index >= 0) {
      items[index].qty++;
    } else {
      items.add(CartItem(id: id, name: name, price: price));
    }
  }

  static int total() {
    return items.fold(0, (sum, item) => sum + item.price * item.qty);
  }

  static void clear() {
    items.clear();
  }
}

/// =======================
/// PRODUCT LIST (HOME)
/// =======================
class ProductListPage extends StatelessWidget {
  const ProductListPage({super.key});

  void addSampleProduct() {
    FirebaseFirestore.instance.collection('products').add({
      'name': 'T-Shirt',
      'price': 500,
      'image': 'https://via.placeholder.com/300',
      'description': 'Comfortable cotton T-shirt',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🛒 Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersPage()),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addSampleProduct,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('products').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var docs = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var p = docs[index];

              return Card(
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(p['image'], fit: BoxFit.cover),
                    ),
                    Text(p['name']),
                    Text("৳ ${p['price']}"),
                    ElevatedButton(
                      onPressed: () {
                        CartStore.add(p.id, p['name'], p['price']);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Added to cart")),
                        );
                      },
                      child: const Text("Add"),
                    ),
                    TextButton(
                      child: const Text("Details"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailPage(product: p),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// =======================
/// PRODUCT DETAILS PAGE
/// =======================
class ProductDetailPage extends StatelessWidget {
  final dynamic product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['name'])),
      body: Column(
        children: [
          Image.network(product['image']),
          Text(product['name'], style: const TextStyle(fontSize: 20)),
          Text("৳ ${product['price']}"),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(product['description'] ?? ""),
          ),
          ElevatedButton(
            onPressed: () {
              CartStore.add(product.id, product['name'], product['price']);
              Navigator.pop(context);
            },
            child: const Text("Add to Cart"),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// CART PAGE
/// =======================
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cart")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: CartStore.items.length,
              itemBuilder: (context, index) {
                var item = CartStore.items[index];

                return ListTile(
                  title: Text(item.name),
                  subtitle: Text("Qty: ${item.qty}"),
                  trailing: Text("৳ ${item.price * item.qty}"),
                );
              },
            ),
          ),
          Text("Total: ৳ ${CartStore.total()}"),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutPage()),
              );
            },
            child: const Text("Checkout"),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// CHECKOUT PAGE
/// =======================
class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  void placeOrder(BuildContext context) async {
    await FirebaseFirestore.instance.collection('orders').add({
      'items': CartStore.items
          .map((e) => {'name': e.name, 'qty': e.qty, 'price': e.price})
          .toList(),
      'total': CartStore.total(),
      'status': 'pending',
      'time': Timestamp.now(),
    });

    CartStore.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const ProductListPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          const Text("Enter Details (demo)"),
          ElevatedButton(
            onPressed: () => placeOrder(context),
            child: const Text("Place Order"),
          ),
        ],
      ),
    );
  }
}

/// =======================
/// ORDER HISTORY
/// =======================
class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Orders")),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var o = orders[index];

              return ListTile(
                title: Text("Order ৳${o['total']}"),
                subtitle: Text(o['status']),
              );
            },
          );
        },
      ),
    );
  }
}
