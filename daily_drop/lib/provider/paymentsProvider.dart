// lib/provider/paymentsProvider.dart

import 'package:daily_drop/provider/customerProvider.dart';
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
final recentDeliveriesProvider = Provider<AsyncValue<List<Delivery>>>((ref) {
  final deliveriesAsync = ref.watch(deliveriesProvider);
  return deliveriesAsync.whenData((deliveries) {
    return deliveries.take(5).toList();
  });
});

// Payment records state
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
      await _service.getDeliveries();
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

// Deliveries by customerId
final deliveriesByCustomerProvider =
    FutureProvider.family<List<Delivery>, String>((ref, customerId) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.getDeliveriesByCustomer(customerId);
});

// Payments by customerId
final paymentsByCustomerProvider = FutureProvider.family<List<PaymentRecord>,
    String>((ref, customerId) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.getPaymentsByCustomer(customerId);
});

// Net balance for a specific customer (FIXED VERSION)
final netBalanceByCustomerProvider = FutureProvider.family<double, String>((ref, customerId) async {
  final service = ref.watch(paymentsServiceProvider);
  
  // Get deliveries and payments directly from service
  final deliveries = await service.getDeliveriesByCustomer(customerId);
  final payments = await service.getPaymentsByCustomer(customerId);
  
  // Calculate total debits (deliveries)
  double totalDebit = 0;
  for (final d in deliveries) {
    totalDebit += d.total;
  }
  
  // Calculate total credits (payments)
  double totalCredit = 0;
  for (final p in payments) {
    totalCredit += p.amount;
  }
  
  // Net balance = Total debits - Total credits
  // Positive = customer owes money (pending)
  // Negative = customer has paid in advance (credit)
  return totalDebit - totalCredit;
});

// Total net balance across all customers (FIXED VERSION)
final totalNetBalanceProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(paymentsServiceProvider);
  final customersAsync = ref.watch(customersProvider);
  
  final customers = await customersAsync.when(
    data: (data) => Future.value(data),
    loading: () => Future.value([]),
    error: (_, __) => Future.value([]),
  );
  
  double totalNetBalance = 0;
  
  for (final customer in customers) {
    try {
      final deliveries = await service.getDeliveriesByCustomer(customer.id);
      final payments = await service.getPaymentsByCustomer(customer.id);
      
      double totalDebit = deliveries.fold(0.0, (sum, d) => sum + d.total);
      double totalCredit = payments.fold(0.0, (sum, p) => sum + p.amount);
      
      totalNetBalance += (totalDebit - totalCredit);
    } catch (e) {
      print('Error calculating balance for ${customer.name}: $e');
    }
  }
  
  return totalNetBalance;
});

// Total pending across all customers (only positive balances)
final totalPendingProvider = FutureProvider<double>((ref) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.computeTotalPending();
});

// Pending by customerId (UPDATED - now returns net balance including negatives)
final pendingByCustomerProvider =
    FutureProvider<Map<String, double>>((ref) async {
  final service = ref.watch(paymentsServiceProvider);
  return await service.computeNetBalanceByCustomer();
});