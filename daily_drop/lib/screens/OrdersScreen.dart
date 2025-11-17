import 'package:daily_drop/controller/payments_controller.dart';
import 'package:daily_drop/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../model/customer_model.dart';
import '../provider/customerProvider.dart';
import '../provider/paymentsProvider.dart';
import 'package:daily_drop/widgets/loading.dart';


class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> {
  int _tabIndex = 0;
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
        if (p.monthlyDate == null) return false;
        return today.day == p.monthlyDate;
      case DeliveryFrequency.custom:
        if (p.customWeekDays == null || p.customWeekDays!.isEmpty) return false;
        final weekdayMap = {
          WeekDay.monday: DateTime.monday,
          WeekDay.tuesday: DateTime.tuesday,
          WeekDay.wednesday: DateTime.wednesday,
          WeekDay.thursday: DateTime.thursday,
          WeekDay.friday: DateTime.friday,
          WeekDay.saturday: DateTime.saturday,
          WeekDay.sunday: DateTime.sunday,
        };
        return p.customWeekDays!.any((day) => weekdayMap[day] == today.weekday);
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
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 30),
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  titleDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                customersAsync.when(
                  data: (customers) {
                    final deliveries = _buildTodayDeliveries(customers, today);
                    final pending = deliveries
                        .where((d) => !completedTodayCustomerIds.contains(d.customer.id))
                        .toList();
                    final completed = deliveries
                        .where((d) => completedTodayCustomerIds.contains(d.customer.id))
                        .toList();

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
                    children: [
                      Expanded(
                        child: _SegmentButton(
                          label: 'Pending',
                          selected: true,
                          onTap: null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SegmentButton(
                          label: 'Completed',
                          selected: false,
                          onTap: null,
                        ),
                      ),
                    ],
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _tabIndex == 0 ? Icons.check_circle_outline : Icons.history,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _tabIndex == 0 ? 'No pending deliveries' : 'No completed deliveries',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final item = list[index];

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

                    // Use expandable card for pending deliveries
                    if (_tabIndex == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExpandableDeliveryCard(
                          item: item,
                          getQty: _getQty,
                          setQty: _setQty,
                          onComplete: () async {
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
                          },
                        ),
                      );
                    }

                    // Expandable card for completed deliveries
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _CompletedExpandableCard(
                        item: item,
                        getQty: _getQty,
                        canUndo: canUndo,
                        onUndo: canUndo
                            ? () async {
                                final controller = PaymentsController(ref);
                                await controller.undoTodayDelivery(
                                  customerId: item.customer.id,
                                  context: context,
                                );
                                setState(() {});
                              }
                            : null,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: LoadingOverlay()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

// Expandable Card for Pending Deliveries
class _ExpandableDeliveryCard extends StatefulWidget {
  final _CustomerDelivery item;
  final int Function(String, String, int) getQty;
  final void Function(String, String, int) setQty;
  final VoidCallback onComplete;

  const _ExpandableDeliveryCard({
    required this.item,
    required this.getQty,
    required this.setQty,
    required this.onComplete,
  });

  @override
  State<_ExpandableDeliveryCard> createState() => _ExpandableDeliveryCardState();
}

class _ExpandableDeliveryCardState extends State<_ExpandableDeliveryCard> {
  bool _isExpanded = false;
  double _sliderValue = 0;
  bool _isCompleting = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              // Header - Always visible
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.item.customer.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.item.customer.address,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _isExpanded ? Icons.expand_less : Icons.expand_more,
                            color: Colors.grey.shade600,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${widget.item.products.length} Product${widget.item.products.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Expandable content
              if (_isExpanded) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Products list
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: widget.item.products.length,
                        itemBuilder: (context, index) {
                          final p = widget.item.products[index];
                          final qty = widget.getQty(widget.item.customer.id, p.productId, p.quantity);
                          
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                // Quantity controls
                                Container(
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () => widget.setQty(widget.item.customer.id, p.productId, qty - 1),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.remove, size: 16),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          '$qty',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () => widget.setQty(widget.item.customer.id, p.productId, qty + 1),
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.add, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Product name
                                Expanded(
                                  child: Text(
                                    p.productName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Swipe to complete slider
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFDCFCE7),
                              Color.lerp(const Color(0xFFDCFCE7), const Color(0xFF10B981), _sliderValue)!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Stack(
                          children: [
                            // Background text
                            Center(
                              child: Text(
                                _sliderValue > 0.8 ? 'Release to deliver' : 'Swipe to complete',
                                style: TextStyle(
                                  color: _sliderValue > 0.5 ? Colors.white : Colors.grey.shade600,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            // Draggable circle
                            Positioned(
                              left: _sliderValue * (MediaQuery.of(context).size.width - 104),
                              child: GestureDetector(
                                onHorizontalDragUpdate: (details) {
                                  setState(() {
                                    _sliderValue += details.delta.dx / (MediaQuery.of(context).size.width - 104);
                                    _sliderValue = _sliderValue.clamp(0.0, 1.0);
                                  });
                                },
                                onHorizontalDragEnd: (details) {
                                  if (_sliderValue > 0.85) {
                                    setState(() {
                                      _isCompleting = true;
                                    });
                                    widget.onComplete();
                                  } else {
                                    setState(() {
                                      _sliderValue = 0;
                                    });
                                  }
                                },
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _sliderValue > 0.8 ? Icons.check : Icons.chevron_right,
                                    color: _sliderValue > 0.8 ? const Color(0xFF10B981) : Colors.grey.shade600,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          // Loading overlay when completing
          if (_isCompleting)
  Container(
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.9),
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(
      child: LoadingOverlay(),  // inside Center in a ListView item
    ),
  ),
        ],
      ),
    );
  }
}

// Expandable Completed Delivery Card
class _CompletedExpandableCard extends StatefulWidget {
  final _CustomerDelivery item;
  final int Function(String, String, int) getQty;
  final bool canUndo;
  final VoidCallback? onUndo;

  const _CompletedExpandableCard({
    required this.item,
    required this.getQty,
    required this.canUndo,
    this.onUndo,
  });

  @override
  State<_CompletedExpandableCard> createState() => _CompletedExpandableCardState();
}

class _CompletedExpandableCardState extends State<_CompletedExpandableCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header - Always visible
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.item.customer.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.item.customer.address,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${widget.item.products.length} Product${widget.item.products.length > 1 ? 's' : ''} Delivered',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF047857),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expandable content
          if (_isExpanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Products list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.item.products.length,
                    itemBuilder: (context, index) {
                      final p = widget.item.products[index];
                      final qty = widget.getQty(widget.item.customer.id, p.productId, p.quantity);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${qty}x',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF047857),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                p.productName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  if (widget.canUndo) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: widget.onUndo,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Undo Delivery',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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

class _CustomerDelivery {
  final Customer customer;
  final List<CustomerProduct> products;
  _CustomerDelivery({required this.customer, required this.products});
}