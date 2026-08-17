import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String userId;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.createdAt,
  });

  factory Product.fromMap(
      String id,
      Map<String, dynamic> map,
      ) {
    return Product(
      id: id,
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      createdAt:
      (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}