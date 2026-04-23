class CartModel {
  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String imageUrl;

  CartModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  double get total => price * quantity;

  factory CartModel.fromMap(String id, Map<String, dynamic> data) {
    return CartModel(
      productId: id,
      name: data['name'],
      price: (data['price'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}
