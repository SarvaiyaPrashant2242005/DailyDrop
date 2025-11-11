import 'package:flutter/material.dart';

class CustomerPaymentTile extends StatelessWidget {
  final String name;
  final String address;
  final double pending;
  final VoidCallback onTap;

  const CustomerPaymentTile({
    super.key,
    required this.name,
    required this.address,
    required this.pending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(address, style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('Pending', style: TextStyle(color: Colors.grey)),
                Text('₹${pending.toStringAsFixed(0)}',
                    style: const TextStyle(color: Color(0xFFEF6C00), fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}