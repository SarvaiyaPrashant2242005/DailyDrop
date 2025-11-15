// lib/services/payments_service.dart

import 'dart:convert';
import 'package:daily_drop/model/delivery_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PaymentsService {
  static const String baseUrl = 'https://dailydrop-3d5q.onrender.com';

  Future<Map<String, String>> _headers() async {
    final sp = await SharedPreferences.getInstance();
    final token = sp.getString('access_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ----- Deliveries -----

  // Create delivery rows on server for each item in the UI delivery
  Future<void> addDelivery(Delivery delivery) async {
    final weekday = _weekdayString(delivery.date.weekday);
    for (final item in delivery.items) {
      final body = {
        'customer_id': int.parse(delivery.customerId),
        'product_id': int.parse(item.productId),
        'product_quantity': item.quantity,
        'delivery_day': weekday,
      };
      final res = await http.post(
        Uri.parse('$baseUrl/api/deliveries'),
        headers: await _headers(),
        body: jsonEncode(body),
      );
      if (res.statusCode != 201) {
        throw Exception(_err(res));
      }
    }
  }

  // Delete all delivery rows belonging to a grouped UI delivery (same customerId and timestamp minute)
  Future<void> removeDelivery(String deliveryGroupId) async {
    // We encode delivery.id as '<customerId>|<iso>' when building from server.
    final parts = deliveryGroupId.split('|');
    if (parts.length != 2) return;
    final customerId = parts[0];
    final iso = parts[1];
    final groupTime = DateTime.tryParse(iso);

    // Fetch rows then delete those that belong to the same minute window
    final rows = await _fetchDeliveryRows();
    final toDelete = rows.where((r) {
      final cid = _asString(r['customer_id']);
      final createdAt = DateTime.parse(r['createdAt']);
      return cid == customerId && _sameMinute(createdAt, groupTime!);
    }).toList();

    for (final r in toDelete) {
      final id = r['id'];
      final res = await http.delete(
        Uri.parse('$baseUrl/api/deliveries/$id'),
        headers: await _headers(),
      );
      if (res.statusCode != 200) {
        throw Exception(_err(res));
      }
    }
  }

  // Get all deliveries grouped per customer and created time window
  Future<List<Delivery>> getDeliveries() async {
    final rows = await _fetchDeliveryRows();

    // Group by (customer_id, minute(createdAt))
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final r in rows) {
      final cid = _asString(r['customer_id']);
      final createdAt = DateTime.parse(r['createdAt']);
      final key = '$cid|${_minuteIso(createdAt)}';
      groups.putIfAbsent(key, () => []).add(r);
    }

    final List<Delivery> list = [];
    for (final entry in groups.entries) {
      final rows = entry.value;
      final first = rows.first;
      final customer = first['customer'] as Map<String, dynamic>?;
      final productItems = rows.map((r) {
        final product = r['product'] as Map<String, dynamic>?;
        return DeliveryItem(
          productId: _asString(r['product_id']),
          productName: product?['product_name']?.toString() ?? 'Product',
          quantity: (r['product_quantity'] as num).toInt(),
          price: _toDouble(product?['product_price']),
        );
      }).toList();
      final createdAt = DateTime.parse(first['createdAt']);
      final customerName = customer?['customer_name']?.toString() ?? 'Customer';
      final customerAddress = customer?['customer_address']?.toString() ?? '';
      list.add(Delivery(
        id: entry.key, // composite id used for undo group
        customerId: _asString(first['customer_id']),
        customerName: customerName,
        customerAddress: customerAddress,
        date: createdAt,
        items: productItems,
      ));
    }

    // Sort recent first
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  Future<List<Delivery>> getDeliveriesByCustomer(String customerId) async {
    final all = await getDeliveries();
    return all.where((d) => d.customerId == customerId).toList();
  }

  Future<Delivery?> getLatestDeliveryForCustomerToday(String customerId) async {
    final now = DateTime.now();
    final todays = (await getDeliveries()).where((d) =>
        d.customerId == customerId &&
        d.date.year == now.year && d.date.month == now.month && d.date.day == now.day);
    if (todays.isEmpty) return null;
    return todays.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
  }

  Future<List<Delivery>> getRecentDeliveries({int limit = 5}) async {
    final all = await getDeliveries();
    return all.take(limit).toList();
  }

  // ----- Payments -----

  Future<void> addPayment(PaymentRecord record) async {
    final body = {
      'customer_id': int.parse(record.customerId),
      'total_amount': record.amount,
      'paid_amount': record.amount,
    };
    final res = await http.post(
      Uri.parse('$baseUrl/api/payments'),
      headers: await _headers(),
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) {
      throw Exception(_err(res));
    }
  }

  Future<List<PaymentRecord>> getPaymentsByCustomer(String customerId) async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/payments/by-customer/$customerId'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception(_err(res));
    final list = jsonDecode(res.body) as List;
    return list.map((m) {
      final mm = m as Map<String, dynamic>;
      // Interpret paid_amount as payment amount
      final amount = _toDouble(mm['paid_amount']);
      final createdAt = DateTime.parse(mm['createdAt']);
      return PaymentRecord(
        id: _asString(mm['id']),
        customerId: _asString(mm['customer_id']),
        date: createdAt,
        amount: amount,
      );
    }).toList();
  }

  Future<Map<String, double>> computePendingByCustomer() async {
    final deliveries = await getDeliveries();
    final Map<String, double> pending = {};
    for (final d in deliveries) {
      pending[d.customerId] = (pending[d.customerId] ?? 0) + d.total;
    }

    // For each customer, subtract paid amounts
    final Set<String> customerIds = deliveries.map((d) => d.customerId).toSet();
    for (final cid in customerIds) {
      final pays = await getPaymentsByCustomer(cid);
      for (final p in pays) {
        pending[cid] = (pending[cid] ?? 0) - p.amount;
      }
    }

    pending.updateAll((key, value) => value < 0 ? 0 : value);
    return pending;
  }

  Future<double> computeTotalPending() async {
    final byCustomer = await computePendingByCustomer();
    double total = 0.0;
    for (final v in byCustomer.values) {
      total += v;
    }
    return total;
  }

  // ----- Helpers -----

  Future<List<Map<String, dynamic>>> _fetchDeliveryRows() async {
    final res = await http.get(
      Uri.parse('$baseUrl/api/deliveries'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) throw Exception(_err(res));
    final list = jsonDecode(res.body) as List;
    return list.cast<Map<String, dynamic>>();
  }

  String _weekdayString(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'monday';
    }
  }

  bool _sameMinute(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day && a.hour == b.hour && a.minute == b.minute;

  String _minuteIso(DateTime dt) => DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute).toIso8601String();

  String _err(http.Response r) {
    try {
      final m = jsonDecode(r.body);
      if (m is Map && m['message'] is String) return m['message'];
    } catch (_) {}
    return 'Request failed (${r.statusCode})';
  }

  double _toDouble(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }

  String _asString(dynamic v) {
    if (v is int) return v.toString();
    return v as String;
  }
}
