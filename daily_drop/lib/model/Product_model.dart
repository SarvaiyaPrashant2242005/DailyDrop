// lib/model/product_model.dart

class Product {
  final String id; // server id is int; stored as string in app
  final String name; // maps to server: product_name
  final double defaultPrice; // maps to server: product_price
  final String unit; // maps to server: product_unit
  final String? imageUrl; // maps to server: image_url

  Product({
    required this.id,
    required this.name,
    required this.defaultPrice,
    required this.unit,
    this.imageUrl,
  });

  Product copyWith({
    String? id,
    String? name,
    double? defaultPrice,
    String? unit,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultPrice: defaultPrice ?? this.defaultPrice,
      unit: unit ?? this.unit,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  // For local persistence/UI (legacy keys)
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'defaultPrice': defaultPrice,
        'unit': unit,
        'imageUrl': imageUrl,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    // Accept either server-style or app-style keys
    final serverId = json['id'];
    final name = (json['name'] ?? json['product_name'] ?? '') as String;
    final priceAny = (json['defaultPrice'] ?? json['product_price'] ?? 0);
    final unit = (json['unit'] ?? json['product_unit'] ?? '') as String;
    final rawImageUrl = (json['imageUrl'] ?? json['image_url']) as String?;
    final idStr = serverId is int ? serverId.toString() : (serverId?.toString() ?? '0');
    final price = priceAny is String
        ? double.tryParse(priceAny) ?? 0.0
        : (priceAny as num?)?.toDouble() ?? 0.0;

    // Convert relative image URL to absolute URL
    String? imageUrl;
    if (rawImageUrl != null && rawImageUrl.isNotEmpty) {
      if (rawImageUrl.startsWith('http')) {
        // Already a full URL
        imageUrl = rawImageUrl;
      } else {
        // Relative path - prepend base URL
        const baseUrl = 'https://dailydrop-3d5q.onrender.com';
        imageUrl = '$baseUrl$rawImageUrl';
      }
    }

    return Product(
      id: idStr,
      name: name,
      defaultPrice: price,
      unit: unit,
      imageUrl: imageUrl,
    );
  }

  // Map to server payload
  Map<String, dynamic> toServerJson() => {
        'product_name': name,
        'product_price': defaultPrice,
        'product_unit': unit,
      };
}