class OrderModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final double total;
  final String status;

  OrderModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.total,
    required this.status,
  });

  factory OrderModel.fromMap(String id, Map<String, dynamic> data) {
    return OrderModel(
      id: id,
      name: data['name'],
      phone: data['phone'],
      address: data['address'],
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'total': total,
      'status': status,
    };
  }
}
