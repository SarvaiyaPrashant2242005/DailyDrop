import 'package:daily_drop/screens/CustomersScreen.dart';
import 'package:flutter/material.dart';
import 'ProductsScreen.dart';
import 'OrdersScreen.dart';
import 'PaymentsScreen.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;

  // Bottom Navigation handled in build via 'pages' list
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }
  final today = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardHome(onNavigate: (i) => setState(() => _currentIndex = i)),
      const OrdersScreen(),
      const ProductsScreen(),
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
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Delivery"),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: "Products"),
          BottomNavigationBarItem(icon: Icon(Icons.payments), label: "Payments"),
        ],
      ),
    );
  }
}

class DashboardHome extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  const DashboardHome({super.key, required this.onNavigate});

Widget build(BuildContext context) {
  return Scaffold(
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient Header Section (no top space)
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
        const Text(
          "Dashboard",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          DateFormat('EEEE, d MMMM yyyy').format(DateTime.now()), // 👈 Today’s date
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _statCard("Today's Deliveries", "1/1"),
            _statCard("Pending Amount", "₹910"),
          ],
        ),
      ],
    ),
  ),
),

            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Quick Actions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 10),

            // Quick Action Buttons
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
                      Navigator.push(context, 
                      MaterialPageRoute(builder: (context) => CustomersScreen(),),);
                    },
                  ),
                  _actionCard(
                    context,
                    title: "Products",
                    icon: Icons.inventory_2,
                    color: Colors.purple.shade100,
                    onTap: () {
                      onNavigate(2);
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
            )
          ],
        ),
      ),
    );
  }
}

// Stats Card
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
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 5),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// Action Card
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
          )
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
