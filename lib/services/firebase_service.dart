import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/customer.dart';
import '../models/product.dart';

class FirebaseService {
  static final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  static final FirebaseAuth _auth =
      FirebaseAuth.instance;

  // ============================================================
  // CURRENT USER
  // ============================================================

  static String get uid {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    return user.uid;
  }

  // ============================================================
  // COLLECTIONS
  // ============================================================

  static CollectionReference<Map<String, dynamic>>
  get products => _db.collection('products');

  static CollectionReference<Map<String, dynamic>>
  get customers => _db.collection('customers');

  static CollectionReference<Map<String, dynamic>>
  get suppliers => _db.collection('suppliers');

  static CollectionReference<Map<String, dynamic>>
  get invoices => _db.collection('invoices');

  static CollectionReference<Map<String, dynamic>>
  get bills => _db.collection('bills');

  // ============================================================
  // USER PROFILE
  // ============================================================

  static DocumentReference<Map<String, dynamic>>
  get userProfile {
    return _db.collection('users').doc(uid);
  }

  static Future<Map<String, dynamic>>
  getUserProfile() async {
    final snapshot = await userProfile.get();

    if (!snapshot.exists) {
      return {};
    }

    return snapshot.data() ?? {};
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>>
  userProfileStream() {
    return userProfile.snapshots();
  }

  static Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? email,
    String? profileImageUrl,
  }) async {
    final data = <String, dynamic>{
      'userId': uid,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (name != null) {
      data['name'] = name;
    }

    if (phone != null) {
      data['phone'] = phone;
    }

    if (email != null) {
      data['email'] = email;
    }

    if (profileImageUrl != null) {
      data['profileImageUrl'] = profileImageUrl;
    }

    await userProfile.set(
      data,
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  static Future<void> updateProfileImage(
      String imageUrl,
      ) async {
    await userProfile.set(
      {
        'userId': uid,
        'profileImageUrl': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  static Future<void> removeProfileImage() async {
    await userProfile.set(
      {
        'profileImageUrl': FieldValue.delete(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // BUSINESS INFORMATION
  // ============================================================

  static Future<Map<String, dynamic>>
  getBusinessInformation() async {
    final snapshot = await userProfile.get();

    final data = snapshot.data();

    if (data == null) {
      return {};
    }

    return {
      'businessName':
      data['businessName'] ?? '',
      'businessPhone':
      data['businessPhone'] ?? '',
      'businessEmail':
      data['businessEmail'] ?? '',
      'businessAddress':
      data['businessAddress'] ?? '',
      'gstNumber':
      data['gstNumber'] ?? '',
    };
  }

  static Future<void> updateBusinessInformation({
    required String businessName,
    required String businessPhone,
    required String businessEmail,
    required String businessAddress,
    required String gstNumber,
  }) async {
    await userProfile.set(
      {
        'userId': uid,
        'businessName': businessName,
        'businessPhone': businessPhone,
        'businessEmail': businessEmail,
        'businessAddress': businessAddress,
        'gstNumber': gstNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // NOTIFICATION SETTINGS
  // ============================================================

  static Future<Map<String, dynamic>>
  getNotificationSettings() async {
    final snapshot = await userProfile.get();

    final data = snapshot.data();

    if (data == null) {
      return {
        'lowStock': true,
        'sales': true,
        'invoice': true,
      };
    }

    return {
      'lowStock':
      data['notificationLowStock'] ?? true,
      'sales':
      data['notificationSales'] ?? true,
      'invoice':
      data['notificationInvoice'] ?? true,
    };
  }

  static Future<void> updateNotificationSettings({
    required bool lowStock,
    required bool sales,
    required bool invoice,
  }) async {
    await userProfile.set(
      {
        'userId': uid,
        'notificationLowStock': lowStock,
        'notificationSales': sales,
        'notificationInvoice': invoice,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // PRODUCTS
  // ============================================================

  static Future<void> addProduct(
      Product product,
      ) async {
    final data = Map<String, dynamic>.from(
      product.toMap(),
    );

    data['userId'] = uid;

    await products.add(data);
  }

  static Future<void> updateProduct(
      Product product,
      ) async {
    final data = Map<String, dynamic>.from(
      product.toMap(),
    );

    data['userId'] = uid;

    await products.doc(product.id).update(data);
  }

  static Future<void> deleteProduct(
      String id,
      ) async {
    await products.doc(id).delete();
  }

  static Stream<List<Product>> productStream() {
    return products
        .where(
      'userId',
      isEqualTo: uid,
    )
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // ============================================================
  // CUSTOMERS
  // ============================================================

  static Stream<List<Customer>> customerStream() {
    return customers
        .where(
      'userId',
      isEqualTo: uid,
    )
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  static Future<void> addCustomer(
      Customer customer,
      ) async {
    final data = Map<String, dynamic>.from(
      customer.toMap(),
    );

    data['userId'] = uid;

    await customers.add(data);
  }

  static Future<void> updateCustomer(
      Customer customer,
      ) async {
    final data = Map<String, dynamic>.from(
      customer.toMap(),
    );

    data['userId'] = uid;

    await customers.doc(customer.id).update(data);
  }

  static Future<void> deleteCustomer(
      String id,
      ) async {
    await customers.doc(id).delete();
  }

  // ============================================================
  // INVOICES
  // ============================================================

  static Stream<QuerySnapshot<Map<String, dynamic>>>
  invoiceStream() {
    return invoices
        .where(
      'userId',
      isEqualTo: uid,
    )
        .orderBy(
      'createdAt',
      descending: true,
    )
        .snapshots();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>>
  getInvoice(
      String invoiceId,
      ) async {
    return await invoices.doc(invoiceId).get();
  }

  // ============================================================
  // CREATE INVOICE + UPDATE STOCK
  // ============================================================

  static Future<String> createInvoice({
    required List<Map<String, dynamic>> items,
    required double subtotal,
    required double discount,
    required double tax,
    required double total,
  }) async {
    final currentUid = uid;

    final invoiceRef = invoices.doc();

    final invoiceNumber =
        'INV-${DateTime.now().millisecondsSinceEpoch}';

    await _db.runTransaction(
          (transaction) async {
        // --------------------------------------------------------
        // READ ALL PRODUCTS FIRST
        // --------------------------------------------------------

        final productSnapshots =
        <DocumentReference<Map<String, dynamic>>,
            DocumentSnapshot<Map<String, dynamic>>>{};

        for (final item in items) {
          final productId =
          item['productId'] as String;

          final quantity =
          item['quantity'] as int;

          final productRef =
          products.doc(productId);

          final productSnapshot =
          await transaction.get(productRef);

          if (!productSnapshot.exists) {
            throw Exception(
              'Product no longer exists.',
            );
          }

          final data =
          productSnapshot.data()!;

          if (data['userId'] != currentUid) {
            throw Exception(
              'You do not have access to this product.',
            );
          }

          final currentStock =
          (data['stock'] ?? 0) as int;

          final productName =
          (data['name'] ?? 'Product')
              .toString();

          if (currentStock < quantity) {
            throw Exception(
              'Not enough stock for $productName.',
            );
          }

          productSnapshots[productRef] =
              productSnapshot;
        }

        // --------------------------------------------------------
        // REDUCE STOCK
        // --------------------------------------------------------

        for (final item in items) {
          final productId =
          item['productId'] as String;

          final quantity =
          item['quantity'] as int;

          final productRef =
          products.doc(productId);

          final productSnapshot =
          productSnapshots[productRef]!;

          final data =
          productSnapshot.data()!;

          final currentStock =
          (data['stock'] ?? 0) as int;

          transaction.update(
            productRef,
            {
              'stock': currentStock - quantity,
            },
          );
        }

        // --------------------------------------------------------
        // CREATE INVOICE
        // --------------------------------------------------------

        transaction.set(
          invoiceRef,
          {
            'userId': currentUid,
            'invoiceNumber': invoiceNumber,
            'items': items,
            'subtotal': subtotal,
            'discount': discount,
            'tax': tax,
            'total': total,
            'paymentStatus': 'Paid',
            'createdAt':
            FieldValue.serverTimestamp(),
          },
        );
      },
    );

    return invoiceNumber;
  }

  // ============================================================
  // DELETE INVOICE
  // ============================================================

  static Future<void> deleteInvoice(
      String invoiceId,
      ) async {
    await invoices.doc(invoiceId).delete();
  }

  // ============================================================
  // DASHBOARD STATISTICS
  // ============================================================

  static Future<double> getTotalSales() async {
    final snapshot = await invoices
        .where(
      'userId',
      isEqualTo: uid,
    )
        .get();

    double total = 0;

    for (final doc in snapshot.docs) {
      final data = doc.data();

      total +=
          ((data['total'] ?? 0) as num)
              .toDouble();
    }

    return total;
  }

  static Future<int> getInvoiceCount() async {
    final snapshot = await invoices
        .where(
      'userId',
      isEqualTo: uid,
    )
        .get();

    return snapshot.docs.length;
  }

  static Future<int> getCustomerCount() async {
    final snapshot = await customers
        .where(
      'userId',
      isEqualTo: uid,
    )
        .get();

    return snapshot.docs.length;
  }

  static Future<int> getProductCount() async {
    final snapshot = await products
        .where(
      'userId',
      isEqualTo: uid,
    )
        .get();

    return snapshot.docs.length;
  }
}