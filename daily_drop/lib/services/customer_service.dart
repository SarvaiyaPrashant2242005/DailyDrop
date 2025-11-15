// lib/services/customer_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/customer_model.dart';

class CustomerService {
  static const String baseUrl = 'https://dailydrop-3d5q.onrender.com'; // align with Product_Service

  Future<Map<String, String>> _headers() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<Customer>> getAllCustomers() async {
    final res = await http.get(Uri.parse('$baseUrl/api/customers'), headers: await _headers());
    if (res.statusCode != 200) throw Exception(_err(res));
    final list = jsonDecode(res.body) as List;

    // For each customer, fetch their product assignments
    final customers = <Customer>[];
    for (final item in list) {
      final cMap = item as Map<String, dynamic>;
      final id = (cMap['id'] is int) ? cMap['id'].toString() : cMap['id'] as String;
      final products = await getCustomerProducts(id);
      customers.add(
        Customer(
          id: id,
          name: cMap['customer_name'] as String,
          address: cMap['customer_address'] as String,
          phone: cMap['phone_no'] as String,
          products: products,
          pendingAmount: 0,
        ),
      );
    }
    return customers;
  }

  Future<List<CustomerProduct>> getCustomerProducts(String customerId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/customer-products/by-customer/$customerId'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception(_err(res));
    final list = jsonDecode(res.body) as List;
    return list.map((m) => _cpFromServer(m as Map<String, dynamic>)).toList();
  }

  Future<void> addCustomer(Customer c) async {
    final body = {
      'customer_name': c.name,
      'customer_address': c.address,
      'phone_no': c.phone,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/api/customers'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) throw Exception(_err(res));

    // Create product assignments
    final created = jsonDecode(res.body) as Map<String, dynamic>;
    final customerId = (created['id'] as int).toString();

    for (final p in c.products) {
      await addCustomerProduct(customerId, p);
    }
  }

  Future<void> addCustomerProduct(String customerId, CustomerProduct p) async {
    final body = {
      'customer_id': int.parse(customerId),
      'product_id': int.parse(p.productId),
      'quantity': p.quantity,
      'price': p.price,
      'unit': p.unit,
      'frequency': _freqToServer(p.frequency),
      'alternate_day_start': p.alternateDayStart != null ? _altToServer(p.alternateDayStart!) : null,
      'weekly_day': p.weeklyDay != null ? _weekToServer(p.weeklyDay!) : null,
      'monthly_date': p.monthlyDate,
      'custom_week_days': p.customWeekDays?.map(_weekToServer).toList(),
    };
    final res = await http.post(
      Uri.parse('$baseUrl/api/customer-products'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) throw Exception(_err(res));
  }

  Future<void> updateCustomer(Customer c) async {
    final body = {
      'customer_name': c.name,
      'customer_address': c.address,
      'phone_no': c.phone,
    };
    final res = await http.put(
      Uri.parse('$baseUrl/api/customers/${c.id}'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) throw Exception(_err(res));
    // Note: Updating assignments: call additional endpoints as needed
  }

  Future<void> deleteCustomer(String id) async {
    final res = await http.delete(
      Uri.parse('$baseUrl/api/customers/$id'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception(_err(res));
  }

  String _err(http.Response r) {
    try {
      final m = jsonDecode(r.body);
      if (m is Map && m['message'] is String) return m['message'];
    } catch (_) {}
    return 'Request failed (${r.statusCode})';
  }

  // Mapping helpers
  CustomerProduct _cpFromServer(Map<String, dynamic> m) {
    // If include product present
    final prod = m['product'] as Map<String, dynamic>?;
    final pid = m['product_id'] is int ? (m['product_id'] as int).toString() : m['product_id'].toString();
    final unit = (m['unit'] as String?) ?? (prod?['product_unit'] as String? ?? '');
    final priceRaw = m['price'] ?? prod?['product_price'] ?? 0;

    return CustomerProduct(
      productId: pid,
      productName: (prod?['product_name'] as String?) ?? '',
      quantity: m['quantity'] as int,
      price: priceRaw is String ? double.tryParse(priceRaw) ?? 0 : (priceRaw as num).toDouble(),
      unit: unit,
      frequency: _freqFromServer(m['frequency'] as String),
      alternateDayStart: _altFromServer(m['alternate_day_start']),
      weeklyDay: _weekFromServer(m['weekly_day']),
      monthlyDate: (m['monthly_date'] as num?)?.toInt(),
      customWeekDays: (m['custom_week_days'] as List?)?.map((e) => _weekFromServer(e as String)!).whereType<WeekDay>().toList(),
    );
  }

  String _freqToServer(DeliveryFrequency f) {
    switch (f) {
      case DeliveryFrequency.everyday: return 'everyday';
      case DeliveryFrequency.oneDayOnOneDayOff: return 'alternate';
      case DeliveryFrequency.weekly: return 'weekly';
      case DeliveryFrequency.monthly: return 'monthly';
      case DeliveryFrequency.custom: return 'custom';
    }
  }

  DeliveryFrequency _freqFromServer(String s) {
    switch (s) {
      case 'everyday': return DeliveryFrequency.everyday;
      case 'alternate': return DeliveryFrequency.oneDayOnOneDayOff;
      case 'weekly': return DeliveryFrequency.weekly;
      case 'monthly': return DeliveryFrequency.monthly;
      case 'custom': return DeliveryFrequency.custom;
      default: return DeliveryFrequency.everyday;
    }
  }

  String _altToServer(AlternateDayStart a) => a == AlternateDayStart.today ? 'today' : 'tomorrow';
  AlternateDayStart? _altFromServer(dynamic s) {
    if (s == 'today') return AlternateDayStart.today;
    if (s == 'tomorrow') return AlternateDayStart.tomorrow;
    return null;
    }

  String _weekToServer(WeekDay w) => w.name; // monday..sunday
  WeekDay? _weekFromServer(dynamic s) {
    if (s == null) return null;
    final v = s.toString().toLowerCase();
    return WeekDay.values.firstWhere((e) => e.name == v, orElse: () => WeekDay.monday);
  }
}