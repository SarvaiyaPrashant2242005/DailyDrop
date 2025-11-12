import 'package:daily_drop/controller/payments_controller.dart';
import 'package:daily_drop/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/customer_model.dart';
import '../provider/customerProvider.dart';
import '../provider/paymentsProvider.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _tabIndex = 0;
  final Set<String> _completedCustomerIds = <String>{};
  final Map<String, Map<String, int>> _quantities = <String, Map<String, int>>{};

  bool _isDueToday(CustomerProduct p, DateTime today) {
    switch (p.frequency) {
      case DeliveryFrequency.everyday:
        return true;
      case DeliveryFrequency.oneDayOnOneDayOff:
        return p.alternateDayStart == AlternateDayStart.today;
      case DeliveryFrequency.weekly:
        if (p.weeklyDay == null) return false;
        final weekdayMap = {
          WeekDay.monday: DateTime.monday,
          WeekDay.tuesday: DateTime.tuesday,
          WeekDay.wednesday: DateTime.wednesday,
          WeekDay.thursday: DateTime.thursday,
          WeekDay.friday: DateTime.friday,
          WeekDay.saturday: DateTime.saturday,
          WeekDay.sunday: DateTime.sunday,
        };
        return weekdayMap[p.weeklyDay] == today.weekday;
      case DeliveryFrequency.monthly:
        return false;
    }
  }
  
  List<_CustomerDelivery> _buildTodayDeliveries(List<Customer> customers, DateTime today) {
    final List<_CustomerDelivery> result = [];
    for (final c in customers) {
      final due = c.products.where((p) => _isDueToday(p, today)).toList();
      if (due.isNotEmpty) {
        result.add(_CustomerDelivery(customer: c, products: due));
      }
    }
    return result;
  }

  int _getQty(String customerId, String productId, int fallback) {
    return _quantities[customerId]?[productId] ?? fallback;
  }

  void _setQty(String customerId, String productId, int value) {
    _quantities.putIfAbsent(customerId, () => <String, int>{});
    _quantities[customerId]![productId] = value.clamp(0, 999);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final today = DateTime.now();
    final titleDate = DateFormat('EEEE, d MMMM').format(today);

    // Completed today comes from recorded deliveries
    final deliveriesAsync = ref.watch(deliveriesProvider);
    final Set<String> completedTodayCustomerIds = deliveriesAsync.maybeWhen(
      data: (list) {
        return list
            .where((d) => d.date.year == today.year && d.date.month == today.month && d.date.day == today.day)
            .map((d) => d.customerId)
            .toSet();
      },
      orElse: () => <String>{},
    );

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 0, left: 20, right: 20, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF06B6D4)],
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
                const Text(
                  "Today's Deliveries",
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  titleDate,
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                ),
                const SizedBox(height: 16),
                customersAsync.when(
                  data: (customers) {
                    final deliveries = _buildTodayDeliveries(customers, today);
                    final pending = deliveries.where((d) => !completedTodayCustomerIds.contains(d.customer.id)).toList();
                    final completed = deliveries.where((d) => completedTodayCustomerIds.contains(d.customer.id)).toList();

                    return Row(
                      children: [
                        Expanded(
                          child: _SegmentButton(
                            label: 'Pending (${pending.length})',
                            selected: _tabIndex == 0,
                            onTap: () => setState(() => _tabIndex = 0),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SegmentButton(
                            label: 'Completed (${completed.length})',
                            selected: _tabIndex == 1,
                            onTap: () => setState(() => _tabIndex = 1),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => Row(
                    children: const [Expanded(child: _SegmentButton(label: 'Pending', selected: true)), Expanded(child: _SegmentButton(label: 'Completed', selected: false))],
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                final deliveries = _buildTodayDeliveries(customers, today);
                final list = _tabIndex == 0
                    ? deliveries.where((d) => !completedTodayCustomerIds.contains(d.customer.id)).toList()
                    : deliveries.where((d) => completedTodayCustomerIds.contains(d.customer.id)).toList();

                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      _tabIndex == 0 ? 'No pending deliveries' : 'No completed deliveries',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];
                    double total = 0;
                    for (final p in item.products) {
                      final q = _getQty(item.customer.id, p.productId, p.quantity);
                      total += q * p.price;
                    }

                    // Determine if undo is allowed for this customer
                    final latestToday = deliveriesAsync.maybeWhen(
                      data: (list) {
                        final todayList = list.where((d) =>
                            d.customerId == item.customer.id &&
                            d.date.year == today.year &&
                            d.date.month == today.month &&
                            d.date.day == today.day);
                        if (todayList.isEmpty) return null;
                        final latest = todayList.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
                        return latest;
                      },
                      orElse: () => null,
                    );
                    final bool canUndo = latestToday != null &&
                        DateTime.now().difference(latestToday.date) <= const Duration(minutes: 2);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.shade200,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.customer.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(item.customer.address, style: TextStyle(color: Colors.grey.shade600)),
                          const SizedBox(height: 12),
                          ...item.products.map((p) {
                            final qty = _getQty(item.customer.id, p.productId, p.quantity);
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7FAF7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE6F2E6)),
                              ),
                              child: Row(
                                children: [
                                  _QtyButton(
                                    icon: Icons.remove,
                                    color: const Color(0xFFFEE2E2),
                                    onTap: () => _setQty(item.customer.id, p.productId, qty - 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                  ),
                                  _QtyButton(
                                    icon: Icons.add,
                                    color: const Color(0xFFE6F4EA),
                                    onTap: () => _setQty(item.customer.id, p.productId, qty + 1),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(p.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                  Text('₹${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }).toList(),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Today's Total:", style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('₹${total.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: _tabIndex == 0
                                  ? () async {
                                      final qtyMap = <String, int>{};
                                      for (final p in item.products) {
                                        qtyMap[p.productId] = _getQty(item.customer.id, p.productId, p.quantity);
                                      }
                                      final controller = PaymentsController(ref);
                                      await controller.addDeliveryFromOrder(
                                        customer: item.customer,
                                        products: item.products,
                                        overrideQuantities: qtyMap,
                                        context: context,
                                      );
                                      setState(() {});
                                    }
                                  : (canUndo
                                      ? () async {
                                          final controller = PaymentsController(ref);
                                          await controller.undoTodayDelivery(
                                            customerId: item.customer.id,
                                            context: context,
                                          );
                                          setState(() {});
                                        }
                                      : null),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _tabIndex == 0
                                    ? const Color(0xFF10B981)
                                    : (canUndo ? const Color(0xFFEF4444) : Colors.grey),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: Icon(
                                _tabIndex == 0 ? Icons.check : (canUndo ? Icons.undo : Icons.check_circle),
                                color: Colors.white,
                              ),
                              label: Text(
                                _tabIndex == 0
                                    ? 'Mark as Delivered'
                                    : (canUndo ? 'Send to Pending' : 'Delivered'),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: const LoadingOverlay()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const _SegmentButton({required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF047857) : Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 18),
      ),
    );
  }
}

class _CustomerDelivery {
  final Customer customer;
  final List<CustomerProduct> products;
  _CustomerDelivery({required this.customer, required this.products});
}