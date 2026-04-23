class ProductModel {
  final String id;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  final String description;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.description,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'description': description,
    };
  }
}
