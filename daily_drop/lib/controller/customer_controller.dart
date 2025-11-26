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
        showTopSnackBar(
          context,
          'Customer updated successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showTopSnackBar(
          context,
          'Error updating customer: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> deleteCustomer(String id, BuildContext context) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text(
          'Are you sure you want to delete this customer? All customer data including orders and payment history will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
         TextButton(
  // When Delete is pressed → close dialog & return true
  onPressed: () {
    Navigator.pop(dialogContext, true); // Return "true" to parent
  },

  // Button text color
  style: TextButton.styleFrom(
    foregroundColor: Colors.red,
  ),

  child: const Text('Delete'),
),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(customersProvider.notifier).deleteCustomer(id);

      if (context.mounted) {
        Navigator.pop(context); // Close the edit dialog
        showTopSnackBar(
          context,
          'Customer deleted successfully',
        );
      }
    } catch (e) {
      if (context.mounted) {
        showTopSnackBar(
          context,
          'Error deleting customer: $e',
          isError: true,
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