import 'package:flutter/material.dart';

class DeliveryHistoryTile extends StatelessWidget {
  final String title;
  final String subtitleRight;

  const DeliveryHistoryTile({
    super.key,
    required this.title,
    required this.subtitleRight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAF7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6F2E6)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600))),
          Text(subtitleRight, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}