// lib/pages/profile_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  bool editing = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      nameController.text = data['name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      addressController.text = data['address'] ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (user == null) return;

    setState(() => loading = true);

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'address': addressController.text.trim(),
    });

    setState(() {
      loading = false;
      editing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile updated")),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .delete();

      await user!.delete();

      if (!mounted) return;
      context.go('/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    // 🔥 GO HOME AFTER LOGOUT
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    final orderStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user!.uid)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,

        // 🏠 HOME BUTTON
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => context.go('/'),
        ),

        actions: [
          // 🚪 LOGOUT BUTTON (GO HOME)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 👤 PROFILE CARD
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.person, size: 70, color: Colors.deepPurple),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nameController,
                    enabled: editing,
                    decoration: const InputDecoration(labelText: "Name"),
                  ),
                  TextField(
                    controller: phoneController,
                    enabled: editing,
                    decoration: const InputDecoration(labelText: "Phone"),
                  ),
                  TextField(
                    controller: addressController,
                    enabled: editing,
                    decoration: const InputDecoration(labelText: "Address"),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user!.email ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: loading
                              ? null
                              : () {
                                  if (editing) {
                                    _updateProfile();
                                  } else {
                                    setState(() => editing = true);
                                  }
                                },
                          child: Text(editing ? "Save" : "Edit"),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _deleteAccount,
                          child: const Text("Delete"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "My Orders",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            // 📦 ORDERS LIST
            StreamBuilder<QuerySnapshot>(
              stream: orderStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Text("No orders yet");
                }

                final orders = snapshot.data!.docs;

                return Column(
                  children: orders.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      child: ListTile(
                        title: Text("Order #${doc.id.substring(0, 6)}"),
                        subtitle: Text("Status: ${data['status']}"),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => context.go('/orders'),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
