// lib/services/payments_service.dart

import 'dart:async';

import 'package:daily_drop/model/delivery_model.dart';

class PaymentsService {
  final List<Delivery> _deliveries = <Delivery>[];
  final List<PaymentRecord> _payments = <PaymentRecord>[];

  Future<void> addDelivery(Delivery delivery) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _deliveries.add(delivery);
  }

  Future<void> addPayment(PaymentRecord record) async {
    await Future.delayed(const Duration(milliseconds: 120));
    _payments.add(record);
  }

  Future<List<Delivery>> getDeliveries() async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _deliveries.toList();
  }

  Future<List<Delivery>> getDeliveriesByCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _deliveries.where((d) => d.customerId == customerId).toList();
  }

  Future<List<PaymentRecord>> getPaymentsByCustomer(String customerId) async {
    await Future.delayed(const Duration(milliseconds: 120));
    return _payments.where((p) => p.customerId == customerId).toList();
  }

  Future<Map<String, double>> computePendingByCustomer() async {
    await Future.delayed(const Duration(milliseconds: 80));
    final Map<String, double> pending = {};
    for (final d in _deliveries) {
      pending[d.customerId] = (pending[d.customerId] ?? 0) + d.total;
    }
    for (final p in _payments) {
      pending[p.customerId] = (pending[p.customerId] ?? 0) - p.amount;
    }
    pending.updateAll((key, value) => value < 0 ? 0 : value);
    return pending;
  }
  // Remove a delivery by id
Future<void> removeDelivery(String deliveryId) async {
  await Future.delayed(const Duration(milliseconds: 100));
  _deliveries.removeWhere((d) => d.id == deliveryId);
}

// Latest delivery today for a customer (if any)
Future<Delivery?> getLatestDeliveryForCustomerToday(String customerId) async {
  await Future.delayed(const Duration(milliseconds: 60));
  final now = DateTime.now();
  final todays = _deliveries.where((d) =>
      d.customerId == customerId &&
      d.date.year == now.year &&
      d.date.month == now.month &&
      d.date.day == now.day);
  if (todays.isEmpty) return null;
  // latest by time
  return todays.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
}

// Recent deliveries (most recent first)
Future<List<Delivery>> getRecentDeliveries({int limit = 5}) async {
  await Future.delayed(const Duration(milliseconds: 60));
  final copy = _deliveries.toList()
    ..sort((a, b) => b.date.compareTo(a.date));
  return copy.take(limit).toList();
}
Future<double> computeTotalPending() async {
  final byCustomer = await computePendingByCustomer();
  double total = 0.0;
  for (final v in byCustomer.values) {
    total += v;
  }
  return total;
}
}

