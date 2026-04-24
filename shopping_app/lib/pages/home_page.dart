// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/admin_auth_provider.dart';
import '../models/product_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productProvider = context.read<ProductProvider>();
    final auth = context.watch<AdminAuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),

      // 🔥 APP BAR (WITH PROFILE BUTTON)
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        title: const Text(
          'My Shop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // 👤 PROFILE BUTTON (NEW)
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => context.go('/profile'),
          ),

          // 🧾 ORDERS
          IconButton(
            icon: const Icon(Icons.receipt_long),
            tooltip: 'My Orders',
            onPressed: () => context.go('/orders'),
          ),

          // 🛒 CART
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Cart',
            onPressed: () => context.go('/cart'),
          ),

          // 👨‍💼 ADMIN / LOGIN
          if (auth.isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () => context.go('/admin'),
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Admin Login',
              onPressed: () => context.go('/login'),
            ),
        ],
      ),

      body: Column(
        children: [
          // 🔍 SEARCH
          Container(
            color: Colors.deepPurple,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search products...',
                hintStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🎯 BANNER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.deepPurple.shade400,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Hot deals today!',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                if (auth.isAdmin)
                  TextButton.icon(
                    onPressed: () async {
                      await context.read<AdminAuthProvider>().signOut();
                    },
                    icon:
                        const Icon(Icons.logout, color: Colors.white, size: 16),
                    label: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),

          // 🛍 PRODUCTS
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: productProvider.products,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allDocs = snapshot.data?.docs ?? [];

                final docs = _searchQuery.isEmpty
                    ? allDocs
                    : allDocs.where((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final name =
                            (data['name'] ?? '').toString().toLowerCase();
                        final category =
                            (data['category'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery) ||
                            category.contains(_searchQuery);
                      }).toList();

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final product = ProductModel.fromMap(
                      docs[index].id,
                      docs[index].data() as Map<String, dynamic>,
                    );

                    return GestureDetector(
                      onTap: () => context.go('/product/${product.id}'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(18),
                              ),
                              child: Image.network(
                                product.imageUrl.isNotEmpty
                                    ? product.imageUrl
                                    : 'https://picsum.photos/300',
                                height: 130,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                product.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '৳ ${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
