import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bill.dart';
import '../models/product.dart';

class FirestoreService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  String get userId {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User is not logged in');
    }

    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get bills =>
      _firestore.collection('bills');

  Stream<List<Product>> watchProducts() {
    return products
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map(
            (doc) => Product.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList(),
    );
  }

  Future<void> addProduct({
    required String name,
    required String category,
    required double price,
    required int quantity,
  }) async {
    await products.add({
      'userId': userId,
      'name': name.trim(),
      'category': category.trim(),
      'price': price,
      'quantity': quantity,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProductQuantity(
      String productId,
      int quantity,
      ) async {
    await products.doc(productId).update({
      'quantity': quantity,
    });
  }

  Stream<List<Bill>> watchBills() {
    return bills
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final result = snapshot.docs
          .map(
            (doc) => Bill.fromMap(
          doc.id,
          doc.data(),
        ),
      )
          .toList();

      result.sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );

      return result;
    });
  }
}