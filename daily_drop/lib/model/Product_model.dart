// lib/model/product_model.dart

class Product {
  final String id;
  final String name;
  final double defaultPrice;
  final String unit;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'defaultPrice': defaultPrice,
      'unit': unit,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      defaultPrice: (json['defaultPrice'] as num).toDouble(),
      unit: json['unit'] as String,
    );
  }
}