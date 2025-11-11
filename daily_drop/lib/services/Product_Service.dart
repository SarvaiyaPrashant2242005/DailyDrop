// lib/services/product_service.dart

import 'package:daily_drop/model/Product_model.dart';


class ProductService {
  // Simulated local storage - in real app, use SQLite or SharedPreferences
  final List<Product> _products = <Product>[
    Product(
      id: '1',
      name: 'Water Bottle',
      defaultPrice: 20,
      unit: 'bottle',
    ),
    Product(
      id: '2',
      name: 'Milk (500ml)',
      defaultPrice: 30,
      unit: '500ml',
    ),
    Product(
      id: '3',
      name: 'Milk (1L)',
      defaultPrice: 55,
      unit: '1L',
    ),
  ];

  Future<List<Product>> getAllProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    // Return a strongly typed list
    return _products.toList();
  }

  Future<void> addProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _products.add(product);
  }

  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _products.removeWhere((product) => product.id == id);
  }

  Future<void> updateProduct(Product product) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
    }
  }
}