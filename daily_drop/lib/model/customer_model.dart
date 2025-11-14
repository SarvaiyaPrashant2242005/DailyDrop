// lib/model/customer_model.dart

class CustomerProduct {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String unit;
  final DeliveryFrequency frequency;
  final AlternateDayStart? alternateDayStart; // For alternate day frequency
  final WeekDay? weeklyDay; // For weekly frequency
  final int? monthlyDate; // For monthly frequency (1-31)
  final List<WeekDay>? customWeekDays; // For custom frequency

  CustomerProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.frequency,
    this.alternateDayStart,
    this.weeklyDay,
    this.monthlyDate,
    this.customWeekDays,
  });

  CustomerProduct copyWith({
    String? productId,
    String? productName,
    int? quantity,
    double? price,
    String? unit,
    DeliveryFrequency? frequency,
    AlternateDayStart? alternateDayStart,
    WeekDay? weeklyDay,
    int? monthlyDate,
    List<WeekDay>? customWeekDays,
  }) {
    return CustomerProduct(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      frequency: frequency ?? this.frequency,
      alternateDayStart: alternateDayStart ?? this.alternateDayStart,
      weeklyDay: weeklyDay ?? this.weeklyDay,
      monthlyDate: monthlyDate ?? this.monthlyDate,
      customWeekDays: customWeekDays ?? this.customWeekDays,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'unit': unit,
      'frequency': frequency.toString(),
      'alternateDayStart': alternateDayStart?.toString(),
      'weeklyDay': weeklyDay?.toString(),
      'monthlyDate': monthlyDate,
      'customWeekDays': customWeekDays?.map((d) => d.toString()).toList(),
    };
  }

  factory CustomerProduct.fromJson(Map<String, dynamic> json) {
    return CustomerProduct(
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      frequency: DeliveryFrequency.values.firstWhere(
        (e) => e.toString() == json['frequency'],
        orElse: () => DeliveryFrequency.everyday,
      ),
      alternateDayStart: json['alternateDayStart'] != null
          ? AlternateDayStart.values.firstWhere(
              (e) => e.toString() == json['alternateDayStart'],
              orElse: () => AlternateDayStart.today,
            )
          : null,
      weeklyDay: json['weeklyDay'] != null
          ? WeekDay.values.firstWhere(
              (e) => e.toString() == json['weeklyDay'],
              orElse: () => WeekDay.monday,
            )
          : null,
      monthlyDate: json['monthlyDate'] as int?,
      customWeekDays: json['customWeekDays'] != null
          ? (json['customWeekDays'] as List)
              .map((d) => WeekDay.values.firstWhere(
                    (e) => e.toString() == d,
                    orElse: () => WeekDay.monday,
                  ))
              .toList()
          : null,
    );
  }
}

enum DeliveryFrequency {
  everyday('Everyday'),
  oneDayOnOneDayOff('Alternate day'),
  weekly('Weekly'),
  monthly('Monthly'),
  custom('Custom Days');

  final String label;
  const DeliveryFrequency(this.label);
}

enum AlternateDayStart {
  today('Today'),
  tomorrow('Tomorrow');

  final String label;
  const AlternateDayStart(this.label);
}

enum WeekDay {
  monday('Monday'),
  tuesday('Tuesday'),
  wednesday('Wednesday'),
  thursday('Thursday'),
  friday('Friday'),
  saturday('Saturday'),
  sunday('Sunday');

  final String label;
  const WeekDay(this.label);
  
  String get shortLabel {
    switch (this) {
      case WeekDay.monday:
        return 'Mon';
      case WeekDay.tuesday:
        return 'Tue';
      case WeekDay.wednesday:
        return 'Wed';
      case WeekDay.thursday:
        return 'Thu';
      case WeekDay.friday:
        return 'Fri';
      case WeekDay.saturday:
        return 'Sat';
      case WeekDay.sunday:
        return 'Sun';
    }
  }
}

class Customer {
  final String id;
  final String name;
  final String address;
  final String phone;
  final List<CustomerProduct> products;
  final double pendingAmount;

  Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.products,
    this.pendingAmount = 0.0,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    List<CustomerProduct>? products,
    double? pendingAmount,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      products: products ?? this.products,
      pendingAmount: pendingAmount ?? this.pendingAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'products': products.map((p) => p.toJson()).toList(),
      'pendingAmount': pendingAmount,
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      products: (json['products'] as List)
          .map((p) => CustomerProduct.fromJson(p as Map<String, dynamic>))
          .toList(),
      pendingAmount: (json['pendingAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String getDailyProductsSummary() {
    if (products.isEmpty) return 'No products';
    return products
        .map((p) => '${p.quantity}x ${p.productName}')
        .join(', ');
  }
}