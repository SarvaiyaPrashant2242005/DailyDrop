// lib/provider/productProvider.dart

import 'package:daily_drop/model/Product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../services/Product_Service.dart';

// Service Provider
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Products List Provider
final productsProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final service = ref.watch(productServiceProvider);
  return ProductsNotifier(service);
});

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductService _service;

  ProductsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadProducts();
  }

Future<void> loadProducts() async {
  state = const AsyncValue.loading();
  try {
    final products = await _service.getAllProducts();
    state = AsyncValue.data(products.cast<Product>());
  } catch (e, stack) {
    state = AsyncValue.error(e, stack);
  }
}

  Future<void> addProduct(Product product) async {
    try {
      await _service.addProduct(product);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _service.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      await _service.updateProduct(product);
      await loadProducts();
    } catch (e) {
      rethrow;
    }
  }
}