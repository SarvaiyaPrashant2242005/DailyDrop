// lib/model/product_model.dart

class Product {
  final String id; // server id is int; stored as string in app
  final String name; // maps to server: product_name
  final double defaultPrice; // maps to server: product_price
  final String unit; // maps to server: product_unit

  Product({
    required this.id,
    required this.name,
    required this.defaultPrice,
    required this.unit,
  });

  Product copyWith({
    String? id,
    String? name,
    double? defaultPrice,
    String? unit,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      unit: unit ?? this.unit,
    );
  }

  // For local persistence/UI (legacy keys)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'defaultPrice': defaultPrice,
        'unit': unit,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    // Accept either server-style or app-style keys
    final serverId = json['id'];
    final name = (json['name'] ?? json['product_name']) as String;
    final priceAny = (json['defaultPrice'] ?? json['product_price']);
    final unit = (json['unit'] ?? json['product_unit']) as String;
    final idStr = serverId is int ? serverId.toString() : serverId as String;
    final price = priceAny is String
        ? double.tryParse(priceAny) ?? 0
        : (priceAny as num).toDouble();

    return Product(
      id: idStr,
      name: name,
      defaultPrice: price,
      unit: unit,
    );
  }

  // Map to server payload
  Map<String, dynamic> toServerJson() => {
        'product_name': name,
        'product_price': defaultPrice,
        'product_unit': unit,
      };
}