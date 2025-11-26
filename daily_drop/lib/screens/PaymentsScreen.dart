import 'package:daily_drop/model/customer_model.dart';
import 'package:daily_drop/provider/customerProvider.dart';
import 'package:daily_drop/provider/paymentsProvider.dart';
import 'package:daily_drop/screens/PaymentDetailScreen.dart';
import 'package:daily_drop/widgets/loading.dart';
import 'package:daily_drop/widgets/payment_summary_card.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                colors: [Color(0xFF4C8CFF), Color(0xFF8B5CF6)],
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
                
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search customers...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
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
                        // Filter customers based on search query
                        var filteredCustomers = customers.where((customer) {
                          return customer.name.toLowerCase().contains(_searchQuery) ||
                              customer.address.toLowerCase().contains(_searchQuery) ||
                              customer.phone.contains(_searchQuery);
                        }).toList();

                        final items = filteredCustomers
                            .map((c) => _CustomerPending(
                                  customer: c,
                                  pending: (map[c.id] ?? 0),
                                ))
                            .toList()
                          ..sort((a, b) => b.pending.compareTo(a.pending));

                        if (items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 40),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isEmpty ? 'No customers' : 'No customers found',
                                    style: TextStyle(color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        return Column(
                          children: items
                              .map((e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: _CustomerTile(
                                      customer: e.customer,
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

class _CustomerTile extends StatelessWidget {
  final Customer customer;
  final double pending;
  final VoidCallback onTap;
  const _CustomerTile({required this.customer, required this.pending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          customer.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(customer.address, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('Contact: ${customer.phone}')
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Pending', style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text('₹${pending.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}