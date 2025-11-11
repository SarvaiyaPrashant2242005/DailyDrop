import 'package:flutter/material.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double totalPending;
  const PaymentSummaryCard({super.key, required this.totalPending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text('Total Pending', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('₹${totalPending.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 28, color: Color(0xFFEF6C00), fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}