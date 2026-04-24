// lib/models/product_model.dart

class ProductModel {
  final String id;
  final String name;
  final double price;
  final String description;
  final String image;
  final String category;

  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.image,
    required this.category,
  });

  factory ProductModel.fromMap(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      price: _parseDouble(data['price']),
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      category: data['category'] ?? 'Others',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'image': image,
      'category': category,
    };
  }
}

double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}
