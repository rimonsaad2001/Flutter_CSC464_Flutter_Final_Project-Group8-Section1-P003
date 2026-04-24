// lib/services/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 📦 Reference
  CollectionReference get _products => _firestore.collection('products');

  // 🔁 STREAM: all products
  Stream<QuerySnapshot> getProducts() {
    return _products.orderBy('createdAt', descending: true).snapshots();
  }

  // ➕ ADD PRODUCT
  Future<void> addProduct(Map<String, dynamic> data) async {
    try {
      await _products.add({
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw "Failed to add product: $e";
    }
  }

  // ✏️ UPDATE PRODUCT
  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _products.doc(id).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw "Failed to update product: $e";
    }
  }

  // 🗑 DELETE PRODUCT
  Future<void> deleteProduct(String id) async {
    try {
      await _products.doc(id).delete();
    } catch (e) {
      throw "Failed to delete product: $e";
    }
  }

  // 📦 GET SINGLE PRODUCT
  Future<DocumentSnapshot> getProductById(String id) {
    return _products.doc(id).get();
  }
}
