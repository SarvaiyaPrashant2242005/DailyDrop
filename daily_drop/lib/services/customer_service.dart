// lib/services/customer_service.dart

import '../model/customer_model.dart';

class CustomerService {
  // Start with empty list - users will add their own customers
  final List<Customer> _customers = <Customer>[];

  Future<List<Customer>> getAllCustomers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _customers.toList();
  }

  Future<void> addCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _customers.add(customer);
  }

  Future<void> deleteCustomer(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _customers.removeWhere((customer) => customer.id == id);
  }

  Future<void> updateCustomer(Customer customer) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index != -1) {
      _customers[index] = customer;
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}