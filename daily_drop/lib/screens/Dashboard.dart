import 'package:daily_drop/provider/paymentsProvider.dart';
import 'package:daily_drop/screens/CustomersScreen.dart';
import 'package:daily_drop/screens/OrdersScreen.dart';
import 'package:daily_drop/screens/PaymentDetailScreen.dart';
import 'package:daily_drop/widgets/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ProductsScreen.dart';
import 'PaymentsScreen.dart';
import 'package:intl/intl.dart';
import '../model/customer_model.dart';
import '../provider/customerProvider.dart';
import '../provider/auth_provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardHome(onNavigate: (i) => setState(() => _currentIndex = i)),
      const OrdersScreen(),
      const CustomersScreen(),
      const PaymentsScreen(),
    ];
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
        backgroundColor: Colors.blue,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_shipping),
            label: "Delivery",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Customers"),
          BottomNavigationBarItem(
            icon: Icon(Icons.payments),
            label: "Payments",
          ),
        ],
      ),
    );
  }
}

class DashboardHome extends ConsumerWidget {
  final ValueChanged<int> onNavigate;
  const DashboardHome({super.key, required this.onNavigate});

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
      case DeliveryFrequency.custom:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userName = authState.user?.name ?? 'User';
    final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
    final customersAsync = ref.watch(customersProvider);
    final deliveriesAsync = ref.watch(deliveriesProvider);
    final totalPendingAsync = ref.watch(totalPendingProvider);

    final now = DateTime.now();
    final completedTodayIds = deliveriesAsync.maybeWhen(
      data: (list) => list
          .where(
            (d) =>
                d.date.year == now.year &&
                d.date.month == now.month &&
                d.date.day == now.day,
          )
          .map((d) => d.customerId)
          .toSet(),
      orElse: () => <String>{},
    );

    int dueCount = customersAsync.maybeWhen(
      data: (customers) {
        int count = 0;
        for (final c in customers) {
          final hasDue = c.products.any((p) => _isDueToday(p, now));
          if (hasDue) count++;
        }
        return count;
      },
      orElse: () => 0,
    );

    final completedCount = completedTodayIds.length;
    final totalPending = totalPendingAsync.maybeWhen(
      data: (v) => v,
      orElse: () => 0.0,
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                top: 0,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6A5BFF), Color(0xFF4C8CFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      today,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _statCard(
                          "Today's Deliveries",
                          "$completedCount/$dueCount",
                        ),
                        _statCard(
                          "Pending Amount",
                          "₹${totalPending.toStringAsFixed(0)}",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Quick Actions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _actionCard(
                    context,
                    title: "Today's Delivery",
                    icon: Icons.local_shipping,
                    color: Colors.green.shade100,
                    onTap: () {
                      onNavigate(1);
                    },
                  ),
                  _actionCard(
                    context,
                    title: "Customers",
                    icon: Icons.people,
                    color: Colors.blue.shade100,
                    onTap: () {
                      onNavigate(2);
                    },
                  ),
                  _actionCard(
  context,
  title: "Products",
  icon: Icons.inventory_2,
  color: Colors.purple.shade100,
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          body: const ProductsScreen(),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0, // (change if needed)
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            backgroundColor: Colors.blue,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => Dashboard(initialIndex: i),
                ),
              );
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping),
                label: "Delivery",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: "Customers",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payments),
                label: "Payments",
              ),
            ],
          ),
        ),
      ),
    );
  },
),

                  _actionCard(
                    context,
                    title: "Payments",
                    icon: Icons.payments,
                    color: Colors.orange.shade100,
                    onTap: () {
                      onNavigate(3);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Recent Deliveries',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Consumer(
              builder: (context, ref, _) {
                final recentAsync = ref.watch(recentDeliveriesProvider);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: recentAsync.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return Text(
                          'No deliveries yet',
                          style: TextStyle(color: Colors.grey.shade600),
                        );
                      }
                      return Column(
                        children: list.map((d) {
                          final primary = d.customerName;
                          final productsSummary = d.items
                              .map((i) => '${i.quantity}x ${i.productName}')
                              .join(', ');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FFF4),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE6F4EA),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        primary,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        productsSummary,
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF10B981),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                    loading: () => const Center(child: const LoadingOverlay()),
                    error: (e, _) => Text('Error: $e'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget _statCard(String title, String value) {
  return Container(
    width: 150,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.3),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _actionCard(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Color color,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color,
            child: Icon(icon, size: 28, color: Colors.black),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
