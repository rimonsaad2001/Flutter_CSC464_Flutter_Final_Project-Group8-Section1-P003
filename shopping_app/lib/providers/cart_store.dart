// lib/providers/cart_store.dart

import 'package:flutter/material.dart';

import '../models/cart_model.dart';

class CartStore extends ChangeNotifier {
  final Map<String, CartModel> _items = {};

  List<CartModel> get items => _items.values.toList();

  int get itemCount => _items.length;

  double get total => _items.values.fold(
        0.0,
        (sum, item) => sum + (item.price * item.quantity),
      );

  void addItem({
    required String productId,
    required String name,
    required double price,
    required String imageUrl,
  }) {
    if (_items.containsKey(productId)) {
      _items[productId] = _items[productId]!.copyWith(
        quantity: _items[productId]!.quantity + 1,
      );
    } else {
      _items[productId] = CartModel(
        productId: productId,
        name: name,
        price: price,
        quantity: 1,
        imageUrl: imageUrl,
      );
    }
    notifyListeners();
  }

  void decreaseItem(String productId) {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      _items[productId] = _items[productId]!.copyWith(
        quantity: _items[productId]!.quantity - 1,
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  List<Map<String, dynamic>> toOrderItems() {
    return _items.values
        .map((item) => {
              'productId': item.productId,
              'name': item.name,
              'quantity': item.quantity,
              'price': item.price,
              'imageUrl': item.imageUrl,
            })
        .toList();
  }
}
