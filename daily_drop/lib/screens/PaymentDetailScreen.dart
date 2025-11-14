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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          children: [
            // Header with TabBar
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 24,
                left: 20,
                right: 20,
                bottom: 0,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 178, 149, 139), Color.fromARGB(255, 34, 39, 133)],
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
                            const SizedBox(height: 4),
                            Text(
                              'Contact: ${customer.phone}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    tabs: [
                      Tab(text: 'Everyday'),
                      Tab(text: 'Transactions'),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs content
            Expanded(
              child: TabBarView(
                children: [
                  // Everyday tab
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _EverydayTab(
                      customer: customer,
                      deliveriesAsync: deliveriesAsync,
                    ),
                  ),

                  // Transactions tab
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: _TransactionsTab(
                      customer: customer,
                      deliveriesAsync: deliveriesAsync,
                      paymentsAsync: paymentsAsync,
                      pendingMapAsync: pendingMapAsync,
                      ref: ref,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EverydayTab extends StatelessWidget {
  final Customer customer;
  final AsyncValue<List<Delivery>> deliveriesAsync;
  const _EverydayTab({required this.customer, required this.deliveriesAsync});

  @override
  Widget build(BuildContext context) {
    return deliveriesAsync.when(
      data: (deliveries) {
        if (deliveries.isEmpty) {
          return Center(
            child: Text('No deliveries yet', style: TextStyle(color: Colors.grey.shade600)),
          );
        }

        // Group by date (yyyy-MM-dd)
        final Map<String, List<Delivery>> byDate = {};
        for (final d in deliveries) {
          final key = DateFormat('yyyy-MM-dd').format(d.date);
          byDate.putIfAbsent(key, () => <Delivery>[]).add(d);
        }
        final dates = byDate.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          itemCount: dates.length,
          itemBuilder: (context, index) {
            final key = dates[index];
            final date = DateTime.parse(key);
            final dayLabel = DateFormat('EEE').format(date);
            final dateLabel = DateFormat('dd MMM yyyy').format(date);

            // Aggregate products for the day
            final Map<String, _ProdAgg> agg = {};
            for (final del in byDate[key]!) {
              for (final it in del.items) {
                final e = agg.putIfAbsent(it.productName, () => _ProdAgg(unitPrice: it.price));
                e.qty += it.quantity;
              }
            }
            final entries = agg.entries.toList()
              ..sort((a, b) => a.key.compareTo(b.key));

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(dayLabel, style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...entries.map((e) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(e.key, overflow: TextOverflow.ellipsis),
                            ),
                            Text('${e.value.qty}x'),
                          ],
                        ),
                      )),
                ],
              ),
            );
          },
        );
      },
      loading: () => const Center(child: LoadingOverlay()),
      error: (e, _) => Text('Error: $e'),
    );
  }
}

class _ProdAgg {
  int qty = 0;
  final double unitPrice;
  _ProdAgg({required this.unitPrice});
}

class _TransactionsTab extends StatelessWidget {
  final Customer customer;
  final AsyncValue<List<Delivery>> deliveriesAsync;
  final AsyncValue<List<PaymentRecord>> paymentsAsync;
  final AsyncValue<Map<String, double>> pendingMapAsync;
  final WidgetRef ref;
  const _TransactionsTab({
    required this.customer,
    required this.deliveriesAsync,
    required this.paymentsAsync,
    required this.pendingMapAsync,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // Pending card
        pendingMapAsync.when(
          data: (map) {
            final pending = (map[customer.id] ?? 0);
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
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
                  const Text('Pending Amount', style: TextStyle(fontWeight: FontWeight.w600)),
                  Text('₹${pending.toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B35), fontSize: 18)),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),

        const SizedBox(height: 16),

        // Ledger-style statement
        deliveriesAsync.when(
          data: (deliveries) {
            return paymentsAsync.when(
              data: (payments) {
                // Build a chronological list of all transactions
                final List<_TxnEntry> allTxns = [];
                
                for (final d in deliveries) {
                  allTxns.add(_TxnEntry(
                    date: d.date,
                    label: 'Delivery',
                    amount: d.total,
                    isDebit: true,
                  ));
                }
                
                for (final p in payments) {
                  allTxns.add(_TxnEntry(
                    date: p.date,
                    label: 'Payment received',
                    amount: p.amount,
                    isDebit: false,
                  ));
                }

                if (allTxns.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('No transactions yet', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                  );
                }

                // Sort by date (oldest first for running balance)
                allTxns.sort((a, b) => a.date.compareTo(b.date));

                // Calculate running balance
                double runningBalance = 0;
                for (final txn in allTxns) {
                  if (txn.isDebit) {
                    runningBalance += txn.amount;
                  } else {
                    runningBalance -= txn.amount;
                  }
                  txn.balance = runningBalance;
                }

                // Reverse for display (newest first)
                final reversed = allTxns.reversed.toList();

                // Group by date for headers
                final Map<String, List<_TxnEntry>> byDate = {};
                for (final txn in reversed) {
                  final key = DateFormat('yyyy-MM-dd').format(txn.date);
                  byDate.putIfAbsent(key, () => []).add(txn);
                }
                final dates = byDate.keys.toList();

                final children = <Widget>[];

                // Ledger header
                children.add(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF223985),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Particulars',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'Out (₹)',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'In (₹)',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Balance',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                children.add(const SizedBox(height: 12));

                // Add transactions grouped by date
                for (final dateKey in dates) {
                  final date = DateTime.parse(dateKey);
                  final dayLabel = DateFormat('EEE').format(date);
                  final dateLabel = DateFormat('dd MMM yyyy').format(date);

                  // Date header
                  children.add(
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, top: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF223985),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$dateLabel  •  $dayLabel',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );

                  // Add ledger rows for this date
                  for (final txn in byDate[dateKey]!) {
                    children.add(_LedgerRow(entry: txn));
                  }
                }

                // Statement summary
                final totalDebit = allTxns.where((t) => t.isDebit).fold(0.0, (sum, t) => sum + t.amount);
                final totalCredit = allTxns.where((t) => !t.isDebit).fold(0.0, (sum, t) => sum + t.amount);
                final netBalance = totalDebit - totalCredit;

                children.add(const SizedBox(height: 16));
                children.add(
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Out', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('₹${totalDebit.toStringAsFixed(0)}', 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFF6B35))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total In', style: TextStyle(fontWeight: FontWeight.w600)),
                            Text('₹${totalCredit.toStringAsFixed(0)}', 
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Net Balance', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('₹${netBalance.toStringAsFixed(0)}', 
                              style: TextStyle(
                                fontWeight: FontWeight.bold, 
                                fontSize: 18,
                                color: netBalance > 0 ? const Color(0xFFFF6B35) : const Color(0xFF10B981),
                              )),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                return Column(children: children);
              },
              loading: () => const Center(child: LoadingOverlay()),
              error: (e, _) => Text('Error: $e'),
            );
          },
          loading: () => const Center(child: LoadingOverlay()),
          error: (e, _) => Text('Error: $e'),
        ),

        const SizedBox(height: 16),

        // Receive payment button
        pendingMapAsync.when(
          data: (map) {
            final pending = (map[customer.id] ?? 0);
            if (pending <= 0) return const SizedBox.shrink();
            return SizedBox(
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
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
                child: const Text('Receive Payment'),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _TxnEntry {
  final DateTime date;
  final String label;
  final double amount;
  final bool isDebit; // true = delivery (out), false = payment (in)
  double balance = 0;
  
  _TxnEntry({
    required this.date,
    required this.label,
    required this.amount,
    required this.isDebit,
  });
}

class _LedgerRow extends StatelessWidget {
  final _TxnEntry entry;
  const _LedgerRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('hh:mm a').format(entry.date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.label,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeStr,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Text(
                  entry.isDebit ? entry.amount.toStringAsFixed(0) : '-',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: entry.isDebit ? const Color(0xFFFF6B35) : Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  !entry.isDebit ? entry.amount.toStringAsFixed(0) : '-',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: !entry.isDebit ? const Color(0xFF10B981) : Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  entry.balance.toStringAsFixed(0),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: entry.balance > 0 ? const Color(0xFFFF6B35) : const Color(0xFF10B981),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

