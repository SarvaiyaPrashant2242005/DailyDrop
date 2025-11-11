// lib/controller/payments_controller.dart

import 'package:daily_drop/model/delivery_model.dart';
import 'package:daily_drop/provider/paymentsProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/customer_model.dart';

class PaymentsController {
  final WidgetRef ref;
  PaymentsController(this.ref);

  Future<void> addDeliveryFromOrder({
    required Customer customer,
    required List<CustomerProduct> products,
    required Map<String, int> overrideQuantities, // productId -> qty (from Orders screen UI)
    required BuildContext context,
  }) async {
    final items = products.map((p) {
      final qty = overrideQuantities[p.productId] ?? p.quantity;
      return DeliveryItem(
        productId: p.productId,
        productName: p.productName,
        quantity: qty,
        price: p.price,
      );
    }).where((i) => i.quantity > 0).toList();

    if (items.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nothing to deliver')),
        );
      }
      return;
    }

    final delivery = Delivery(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customer.id,
      customerName: customer.name,
      customerAddress: customer.address,
      date: DateTime.now(),
      items: items,
    );

    await ref.read(deliveriesProvider.notifier).add(delivery);

    // Also refresh totals selectors (computed from service)
    ref.invalidate(totalPendingProvider);
    ref.invalidate(pendingByCustomerProvider);
  }
  Future<void> undoTodayDelivery({
  required String customerId,
  required BuildContext context,
}) async {
  final svc = ref.read(paymentsServiceProvider);
  final latest = await svc.getLatestDeliveryForCustomerToday(customerId);
  if (latest == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No delivery to undo')),
      );
    }
    return;
  }

  // 2-minute window check
  final diff = DateTime.now().difference(latest.date);
  if (diff > const Duration(minutes: 2)) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Undo window expired')),
      );
    }
    return;
  }

  await ref.read(deliveriesProvider.notifier).removeById(latest.id);

  // Recompute pending totals
  ref.invalidate(totalPendingProvider);
  ref.invalidate(pendingByCustomerProvider);

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Moved back to Pending')),
    );
  }
}
  Future<void> addPayment({
    required String customerId,
    required double amount,
    required BuildContext context,
  }) async {
    if (amount <= 0) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid amount')),
        );
      }
      return;
    }

    final record = PaymentRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId,
      date: DateTime.now(),
      amount: amount,
    );

    await ref.read(paymentRecordsProvider.notifier).add(record);
    // recompute pendings
    ref.invalidate(totalPendingProvider);
    ref.invalidate(pendingByCustomerProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment recorded')),
      );
      Navigator.pop(context); // close bottom sheet if open
    }
  }
}