// lib/model/delivery_model.dart

class DeliveryItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price; // unit price at time of delivery

  const DeliveryItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  double get lineTotal => quantity * price;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
      };

  factory DeliveryItem.fromJson(Map<String, dynamic> json) => DeliveryItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        quantity: json['quantity'] as int,
        price: (json['price'] as num).toDouble(),
      );
}

class Delivery {
  final String id;
  final String customerId;
  final String customerName;
  final String customerAddress;
  final DateTime date;
  final List<DeliveryItem> items;

  const Delivery({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.customerAddress,
    required this.date,
    required this.items,
  });

  double get total => items.fold(0.0, (s, i) => s + i.lineTotal);

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'customerAddress': customerAddress,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Delivery.fromJson(Map<String, dynamic> json) => Delivery(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String,
        customerAddress: json['customerAddress'] as String,
        date: DateTime.parse(json['date'] as String),
        items: (json['items'] as List)
            .map((e) => DeliveryItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class PaymentRecord {
  final String id;
  final String customerId;
  final DateTime date;
  final double amount;

  const PaymentRecord({
    required this.id,
    required this.customerId,
    required this.date,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'date': date.toIso8601String(),
        'amount': amount,
      };

  factory PaymentRecord.fromJson(Map<String, dynamic> json) => PaymentRecord(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        date: DateTime.parse(json['date'] as String),
        amount: (json['amount'] as num).toDouble(),
      );
}