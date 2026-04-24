import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  Stream<QuerySnapshot> get products => _productService.getProducts();

  Future<void> addProduct(Map<String, dynamic> data) async {
    try {
      await _productService.addProduct({
        ...data,
        'createdAt': FieldValue.serverTimestamp(), // ✅ FIXED
      });
    } catch (e) {
      debugPrint('ProductProvider.addProduct error: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> data) async {
    try {
      await _productService.updateProduct(id, data);
    } catch (e) {
      debugPrint('ProductProvider.updateProduct error: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
    } catch (e) {
      debugPrint('ProductProvider.deleteProduct error: $e');
      rethrow;
    }
  }
}
