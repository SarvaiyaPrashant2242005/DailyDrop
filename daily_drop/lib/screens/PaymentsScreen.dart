import 'package:daily_drop/controller/payments_controller.dart';
import 'package:daily_drop/model/customer_model.dart';
import 'package:daily_drop/provider/customerProvider.dart';
import 'package:daily_drop/provider/paymentsProvider.dart';
import 'package:daily_drop/screens/PaymentDetailScreen.dart';
import 'package:daily_drop/widgets/customer_payment_tile.dart';
import 'package:daily_drop/widgets/loading.dart';
import 'package:daily_drop/widgets/payment_summary_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final totalPendingAsync = ref.watch(totalPendingProvider);
    final customersAsync = ref.watch(customersProvider);
    final pendingMapAsync = ref.watch(pendingByCustomerProvider);

    return Scaffold(
      body: Column(
        children: [
          // Full-width header with gradient
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF7043), Color(0xFFFF3D00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Track pending payments',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Content area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                totalPendingAsync.when(
                  data: (total) => PaymentSummaryCard(totalPending: total),
                  loading: () => const Center(child: LoadingOverlay()),
                  error: (e, _) => Text('Error: $e'),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Customer Payments',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),
                customersAsync.when(
                  data: (customers) {
                    return pendingMapAsync.when(
                      data: (map) {
                        final items = customers
                            .map((c) => _CustomerPending(
                                  customer: c,
                                  pending: (map[c.id] ?? 0),
                                ))
                            .where((e) => e.pending > 0)
                            .toList()
                          ..sort((a, b) => b.pending.compareTo(a.pending));

                        if (items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Text(
                                'No pending payments',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: items
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: CustomerPaymentTile(
                                      name: e.customer.name,
                                      address: e.customer.address,
                                      pending: e.pending,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => PaymentDetailScreen(
                                              customer: e.customer,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                      loading: () => const Center(child: LoadingOverlay()),
                      error: (e, _) => Text('Error: $e'),
                    );
                  },
                  loading: () => const Center(child: LoadingOverlay()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerPending {
  final Customer customer;
  final double pending;
  _CustomerPending({required this.customer, required this.pending});
}