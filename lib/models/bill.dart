import 'package:cloud_firestore/cloud_firestore.dart';

class BillItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;

  BillItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
  });

  double get total => quantity * price;

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }
}

class Bill {
  final String id;
  final String userId;
  final String billNumber;
  final String customerName;
  final List<BillItem> items;
  final double subtotal;
  final double discount;
  final double total;
  final DateTime createdAt;

  Bill({
    required this.id,
    required this.userId,
    required this.billNumber,
    required this.customerName,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.createdAt,
  });

  factory Bill.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    final rawItems = map['items'] as List<dynamic>? ?? [];

    return Bill(
      id: id,
      userId: map['userId'] ?? '',
      billNumber: map['billNumber'] ?? '',
      customerName: map['customerName'] ?? 'Walk-in Customer',
      items: rawItems.map((item) {
        final data = Map<String, dynamic>.from(item);

        return BillItem(
          productId: data['productId'] ?? '',
          name: data['name'] ?? '',
          quantity: (data['quantity'] as num?)?.toInt() ?? 0,
          price: (data['price'] as num?)?.toDouble() ?? 0,
        );
      }).toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      createdAt:
      (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'billNumber': billNumber,
      'customerName': customerName,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'total': total,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}