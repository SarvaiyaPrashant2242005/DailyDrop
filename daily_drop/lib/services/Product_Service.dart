// lib/services/Product_Service.dart

import 'dart:convert';
import 'dart:io';
import 'package:daily_drop/model/Product_model.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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

  Future<String?> _getToken() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString('access_token');
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

  Future<void> addProduct(Product product, {File? imageFile}) async {
    final uri = Uri.parse('$baseUrl/api/products');
    final token = await _getToken();

    if (imageFile != null) {
      // Use multipart request for image upload
      final request = http.MultipartRequest('POST', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add product fields
      request.fields['product_name'] = product.name;
      request.fields['product_price'] = product.defaultPrice.toString();
      request.fields['product_unit'] = product.unit;

      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode != 201) {
        throw Exception(_readError(res));
      }
    } else {
      // Regular JSON request without image
      final res = await http.post(
        uri,
        headers: await _headers(),
        body: jsonEncode(product.toServerJson()),
      );
      if (res.statusCode != 201) {
        throw Exception(_readError(res));
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    final uri = Uri.parse('$baseUrl/api/products/$id');
    final res = await http.delete(uri, headers: await _headers());
    if (res.statusCode != 200) {
      throw Exception(_readError(res));
    }
  }

  Future<void> updateProduct(Product product, {File? imageFile}) async {
    final uri = Uri.parse('$baseUrl/api/products/${product.id}');
    final token = await _getToken();

    if (imageFile != null) {
      // Use multipart request for image upload
      final request = http.MultipartRequest('PUT', uri);
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add product fields
      request.fields['product_name'] = product.name;
      request.fields['product_price'] = product.defaultPrice.toString();
      request.fields['product_unit'] = product.unit;

      // Add image file
      final imageStream = http.ByteStream(imageFile.openRead());
      final imageLength = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'image',
        imageStream,
        imageLength,
        filename: imageFile.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode != 200) {
        throw Exception(_readError(res));
      }
    } else {
      // Regular JSON request without image
      final res = await http.put(
        uri,
        headers: await _headers(),
        body: jsonEncode(product.toServerJson()),
      );
      if (res.statusCode != 200) {
        throw Exception(_readError(res));
      }
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