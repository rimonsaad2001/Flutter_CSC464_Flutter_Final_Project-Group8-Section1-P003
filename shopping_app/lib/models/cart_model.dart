// lib/models/cart_model.dart

class CartModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  const CartModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  // 💰 total price
  double get total => price * quantity;

  // ================= FROM MAP =================
  factory CartModel.fromMap(String id, Map<String, dynamic> data) {
    return CartModel(
      productId: id,
      name: data['name'] ?? '',
      price: _parseDouble(data['price']),
      quantity: (data['quantity'] ?? 1) as int,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // ================= TO MAP =================
  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  // ================= COPY WITH =================
  CartModel copyWith({
    String? productId,
    String? name,
    double? price,
    int? quantity,
    String? imageUrl,
  }) {
    return CartModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

// ================= SAFE PARSER =================
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
