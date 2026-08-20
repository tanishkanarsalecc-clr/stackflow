import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/firebase_service.dart';

class ProductProvider extends ChangeNotifier {
  String search = '';

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  Stream<List<Product>> get productsStream {
    return FirebaseService.productStream();
  }

  List<Product> filterProducts(
      List<Product> products,
      ) {
    if (search.trim().isEmpty) {
      return products;
    }

    final query = search.toLowerCase().trim();

    return products.where((product) {
      return product.name
          .toLowerCase()
          .contains(query) ||
          product.category
              .toLowerCase()
              .contains(query);
    }).toList();
  }

  Future<void> addProduct(
      Product product,
      ) async {
    await FirebaseService.addProduct(product);
  }

  Future<void> deleteProduct(
      String id,
      ) async {
    await FirebaseService.deleteProduct(id);
  }
}