// lib/controller/customer_controller.dart

import 'package:daily_drop/widgets/customer_form_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/customer_model.dart';
import '../provider/customerProvider.dart';


class CustomerController {
  final WidgetRef ref;

  CustomerController(this.ref);

  Future<void> addCustomer({
    required String name,
    required String address,
    required String phone,
    required List<CustomerProduct> products,
    required BuildContext context,
  }) async {
    try {
      final customer = Customer(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        address: address,
        phone: phone,
        products: products,
        pendingAmount: 0,
      );

      await ref.read(customersProvider.notifier).addCustomer(customer);

      if (context.mounted) {
       showTopSnackBar(
  context,
  'Customer added successfully',
);
      }
    } catch (e) {
      if (context.mounted) {
       showTopSnackBar(
  context,
  'Error adding customer: $e',
  isError: true,
);
      }
    }
  }

  Future<void> updateCustomer({
    required Customer customer,
    required BuildContext context,
  }) async {
    try {
      await ref.read(customersProvider.notifier).updateCustomer(customer);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating customer: $e')),
        );
      }
    }
  }

  Future<void> deleteCustomer(String id, BuildContext context) async {
    try {
      await ref.read(customersProvider.notifier).deleteCustomer(id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting customer: $e')),
        );
      }
    }
  }

  void showAddCustomerDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CustomerFormBottomSheet(),
    );
  }

  void showEditCustomerDialog(BuildContext context, Customer customer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CustomerFormBottomSheet(customer: customer),
    );
  }
}