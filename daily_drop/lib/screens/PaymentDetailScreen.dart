import 'package:daily_drop/controller/payments_controller.dart';
import 'package:daily_drop/model/customer_model.dart';
import 'package:daily_drop/model/delivery_model.dart';
import 'package:daily_drop/provider/paymentsProvider.dart';
import 'package:daily_drop/widgets/loading.dart';
import 'package:daily_drop/widgets/receive_payment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class PaymentDetailScreen extends ConsumerWidget {
  final Customer customer;
  const PaymentDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deliveriesAsync = ref.watch(deliveriesByCustomerProvider(customer.id));
    final paymentsAsync = ref.watch(paymentsByCustomerProvider(customer.id));
    final pendingMapAsync = ref.watch(pendingByCustomerProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // ✅ Updated header section with your provided container
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 24,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF4500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
             children: [
  Row(
    children: [
      IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              customer.address,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
  const SizedBox(height: 20),
],
            ),
          ),

          // ✅ Main content section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Pending Amount Card
                pendingMapAsync.when(
                  data: (map) {
                    final pending = (map[customer.id] ?? 0);
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pending Amount',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹${pending.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                const SizedBox(height: 30),

                // Deliveries Section
                Text(
                  'Deliveries',
                  style: TextStyle(
                    color: const Color(0xFF1A3A52),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                deliveriesAsync.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            'No deliveries yet',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ),
                      );
                    }

                    // Group by date
                    final Map<String, List<Delivery>> byDate = {};
                    for (final d in list) {
                      final key = DateFormat('yyyy-MM-dd').format(d.date);
                      byDate.putIfAbsent(key, () => <Delivery>[]).add(d);
                    }
                    final sortedKeys = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

                    return Column(
                      children: sortedKeys.expand((key) {
                        final dateLabel =
                            DateFormat('EEE, d MMM').format(DateTime.parse(key));
                        final group = byDate[key]!;

                        return [
                          // Date Header
                          Padding(
                            padding:
                                const EdgeInsets.only(bottom: 12, top: 8),
                            child: Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF6B35),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  dateLabel,
                                  style: const TextStyle(
                                    color: Color(0xFF1A3A52),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Delivery Items
                          ...group.expand((delv) => delv.items.map((it) =>
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${it.quantity}x ${it.productName}',
                                        style: const TextStyle(
                                          color: Color(0xFF1A3A52),
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '₹${(it.quantity * it.price).toStringAsFixed(0)}',
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ))),

                          // Day's Total
                          Container(
                            margin:
                                const EdgeInsets.only(bottom: 20, top: 4),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Day's Total",
                                  style: TextStyle(
                                    color: Color(0xFF1A3A52),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  '₹${group.fold<double>(
                                          0, (s, d) => s + d.total)
                                      .toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ];
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: LoadingOverlay()),
                  error: (e, _) => Text('Error: $e'),
                ),

                const SizedBox(height: 20),

                // Receive Payment Button
                pendingMapAsync.when(
                  data: (map) {
                    final pending = (map[customer.id] ?? 0);
                    if (pending <= 0) return const SizedBox.shrink();

                    return Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => ReceivePaymentBottomSheet(
                              pendingAmount: pending,
                              onConfirm: (amount) {
                                final controller = PaymentsController(ref);
                                controller.addPayment(
                                  customerId: customer.id,
                                  amount: amount,
                                  context: context,
                                );
                              },
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Receive Payment',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
