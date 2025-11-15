// lib/services/Product_Service.dart

import 'dart:convert';
import 'package:daily_drop/model/Product_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProductService {
  // Set base URL to match your server
  static const String baseUrl = 'https://dailydrop-3d5q.onrender.com';

  Future<Map<String, String>> _headers() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Product>> getAllProducts() async {
    final uri = Uri.parse('$baseUrl/api/products');
    final res = await http.get(uri, headers: await _headers());
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception(_readError(res));
  }

  Future<void> addProduct(Product product) async {
    final uri = Uri.parse('$baseUrl/api/products');
    final res = await http.post(
      uri,
      headers: await _headers(),
      body: jsonEncode(product.toServerJson()),
    );
    if (res.statusCode != 201) {
      throw Exception(_readError(res));
    }
  }

  Future<void> deleteProduct(String id) async {
    final uri = Uri.parse('$baseUrl/api/products/$id');
    final res = await http.delete(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception(_readError(res));
    }
  }

  Future<void> updateProduct(Product product) async {
    final uri = Uri.parse('$baseUrl/api/products/${product.id}');
    final res = await http.put(
      uri,
      headers: await _headers(),
      body: jsonEncode(product.toServerJson()),
    );
    if (res.statusCode != 200) {
      throw Exception(_readError(res));
    }
  }

  String _readError(http.Response res) {
    try {
      final m = jsonDecode(res.body);
      if (m is Map && m['message'] is String) return m['message'];
    } catch (_) {}
    return 'Request failed (${res.statusCode})';
  }
}