// lib/provider/paymentsProvider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_drop/model/delivery_model.dart';
import 'package:daily_drop/services/payments_service.dart';
import 'package:flutter_riverpod/legacy.dart';

// Service provider
final paymentsServiceProvider = Provider<PaymentsService>((ref) {
  return PaymentsService();
});

// Deliveries state (list of Delivery)
final deliveriesProvider =
    StateNotifierProvider<DeliveriesNotifier, AsyncValue<List<Delivery>>>(
  (ref) => DeliveriesNotifier(ref.watch(paymentsServiceProvider)),
);

class DeliveriesNotifier extends StateNotifier<AsyncValue<List<Delivery>>> {
  final PaymentsService _service;
  DeliveriesNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final data = await _service.getDeliveries();
      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(Delivery delivery) async {
    await _service.addDelivery(delivery);
    await load();
  }

  Future<void> removeById(String deliveryId) async {
    await _service.removeDelivery(deliveryId);
    await load();
  }
}

// Recent deliveries (for dashboard)
final recentDeliveriesProvider = FutureProvider<List<Delivery>>((ref) async {
  final service = ref.watch(paymentsServiceProvider);
  return service.getRecentDeliveries(limit: 5);
});

// Payment records state (we record payments but rarely list them all at once)
final paymentRecordsProvider = StateNotifierProvider<PaymentRecordsNotifier,
    AsyncValue<List<PaymentRecord>>>(
  (ref) => PaymentRecordsNotifier(ref.watch(paymentsServiceProvider)),
);

class PaymentRecordsNotifier
    extends StateNotifier<AsyncValue<List<PaymentRecord>>> {
  final PaymentsService _service;
  PaymentRecordsNotifier(this._service) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      // We don’t need the full list by default; keep it empty until needed.
      await _service.getDeliveries(); // keep a small async for consistency
      state = const AsyncValue.data(<PaymentRecord>[]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(PaymentRecord record) async {
    await _service.addPayment(record);
    await load();
  }
}

// Selectors/derived data

// Total pending across all customers
final totalPendingProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.computeTotalPending();
});

// Pending by customerId
final pendingByCustomerProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.computePendingByCustomer();
});

// Deliveries by customerId
final deliveriesByCustomerProvider =
    FutureProvider.family<List<Delivery>, String>((ref, customerId) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.getDeliveriesByCustomer(customerId);
});

// Payments by customerId (for future use if showing payment history)
final paymentsByCustomerProvider = FutureProvider.family<List<PaymentRecord>,
    String>((ref, customerId) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.getPaymentsByCustomer(customerId);
});