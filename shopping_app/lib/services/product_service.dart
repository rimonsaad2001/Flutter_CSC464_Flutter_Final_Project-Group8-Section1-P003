// lib/services/product_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final CollectionReference _products =
      FirebaseFirestore.instance.collection('products');

  Stream<QuerySnapshot> getProducts() {
    return _products.snapshots();
  }

  Future<void> addProduct(Map<String, dynamic> data) {
    return _products.add(data);
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) {
    return _products.doc(id).update(data);
  }

  Future<void> deleteProduct(String id) {
    return _products.doc(id).delete();
  }
}
