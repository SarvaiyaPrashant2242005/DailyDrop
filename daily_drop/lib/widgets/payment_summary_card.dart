import 'package:flutter/material.dart';

class PaymentSummaryCard extends StatelessWidget {
  final double totalPending;
  const PaymentSummaryCard({super.key, required this.totalPending});

  @override
  Widget build(BuildContext context) {
    final isNegative = totalPending < 0;
    final displayAmount = totalPending.abs();
    
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
          Text(
            isNegative ? 'Total Advance' : 'Total Pending',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '₹${displayAmount.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 28,
              color: isNegative ? const Color(0xFF10B981) : const Color(0xFFEF6C00),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}