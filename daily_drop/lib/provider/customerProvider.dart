// lib/provider/customerProvider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../model/customer_model.dart';
import '../services/customer_service.dart';

// Service Provider
final customerServiceProvider = Provider<CustomerService>((ref) {
  return CustomerService();
});

// Customers List Provider
final customersProvider = StateNotifierProvider<CustomersNotifier, AsyncValue<List<Customer>>>((ref) {
  final service = ref.watch(customerServiceProvider);
  return CustomersNotifier(service);
});

class CustomersNotifier extends StateNotifier<AsyncValue<List<Customer>>> {
  final CustomerService _service;

  CustomersNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    state = const AsyncValue.loading();
    try {
      final List<Customer> customers = await _service.getAllCustomers();
      state = AsyncValue.data(customers);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      state = const AsyncValue.loading();
      await _service.addCustomer(customer);
      await loadCustomers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _service.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _service.updateCustomer(customer);
      await loadCustomers();
    } catch (e) {
      rethrow;
    }
  }
}