import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CheckoutPage extends StatefulWidget {
  final double total;

  const CheckoutPage({super.key, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();

  void placeOrder() async {
    await FirebaseFirestore.instance.collection('orders').add({
      'name': name.text,
      'phone': phone.text,
      'address': address.text,
      'total': widget.total,
      'status': 'pending',
      'time': DateTime.now(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order Placed Successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: phone,
            decoration: const InputDecoration(labelText: "Phone"),
          ),
          TextField(
            controller: address,
            decoration: const InputDecoration(labelText: "Address"),
          ),

          Text("Total: ৳ ${widget.total}"),

          ElevatedButton(
            onPressed: placeOrder,
            child: const Text("Place Order"),
          ),
        ],
      ),
    );
  }
}
