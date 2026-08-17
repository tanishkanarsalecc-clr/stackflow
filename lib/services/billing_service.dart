import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bill.dart';

class BillingService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<String> createBill({
    required String customerName,
    required List<BillItem> items,
    required double discount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    if (items.isEmpty) {
      throw Exception('Bill must contain at least one item');
    }

    // Make sure discount can never be negative.
    final double safeDiscount =
    discount < 0 ? 0.0 : discount;

    // Calculate subtotal.
    final double subtotal = items.fold<double>(
      0.0,
          (total, item) => total + item.total,
    );

    // Calculate final total.
    final double total =
    (subtotal - safeDiscount)
        .clamp(0.0, double.infinity)
        .toDouble();

    final billRef =
    _firestore.collection('bills').doc();

    final billNumber =
        'SF-${DateTime.now().millisecondsSinceEpoch}';

    final bill = Bill(
      id: billRef.id,
      userId: user.uid,
      billNumber: billNumber,
      customerName: customerName.trim().isEmpty
          ? 'Walk-in Customer'
          : customerName.trim(),
      items: items,
      subtotal: subtotal,
      discount: safeDiscount,
      total: total,
      createdAt: DateTime.now(),
    );

    await _firestore.runTransaction(
          (transaction) async {
        final Map<String, DocumentSnapshot<Map<String, dynamic>>>
        productSnapshots = {};

        // Get all products first.
        for (final item in items) {
          final productRef = _firestore
              .collection('products')
              .doc(item.productId);

          final snapshot =
          await transaction.get(productRef);

          if (!snapshot.exists) {
            throw Exception(
              'Product "${item.name}" no longer exists',
            );
          }

          productSnapshots[item.productId] = snapshot;
        }

        // Check stock and ownership.
        for (final item in items) {
          final snapshot =
          productSnapshots[item.productId]!;

          final data = snapshot.data();

          if (data == null) {
            throw Exception(
              'Could not read product "${item.name}"',
            );
          }

          final productUserId =
          data['userId'] as String?;

          if (productUserId != user.uid) {
            throw Exception(
              'You do not have access to "${item.name}"',
            );
          }

          final int stock =
              (data['quantity'] as num?)?.toInt() ?? 0;

          if (item.quantity <= 0) {
            throw Exception(
              'Invalid quantity for "${item.name}"',
            );
          }

          if (item.quantity > stock) {
            throw Exception(
              'Not enough stock for "${item.name}". '
                  'Available: $stock',
            );
          }
        }

        // Deduct stock.
        for (final item in items) {
          final productRef = _firestore
              .collection('products')
              .doc(item.productId);

          final snapshot =
          productSnapshots[item.productId]!;

          final data = snapshot.data()!;

          final int currentStock =
              (data['quantity'] as num?)?.toInt() ?? 0;

          transaction.update(
            productRef,
            {
              'quantity':
              currentStock - item.quantity,
            },
          );
        }

        // Save the bill.
        transaction.set(
          billRef,
          bill.toMap(),
        );
      },
    );

    return billNumber;
  }
}