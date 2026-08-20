import 'package:flutter/material.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items {
    return List.unmodifiable(_items);
  }

  double discount = 0;

  double get subtotal {
    return _items.fold(
      0,
          (sum, item) => sum + item.total,
    );
  }

  double get tax {
    final taxableAmount = subtotal - discount;

    if (taxableAmount <= 0) {
      return 0;
    }

    return taxableAmount * 0.05;
  }

  double get total {
    return subtotal - discount + tax;
  }

  int get itemCount {
    return _items.fold(
      0,
          (sum, item) => sum + item.quantity,
    );
  }

  bool containsProduct(String productId) {
    return _items.any(
          (item) => item.product.id == productId,
    );
  }

  void addProduct(Product product) {
    final index = _items.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index >= 0) {
      if (_items[index].quantity < product.stock) {
        _items[index].quantity++;
      }
    } else {
      if (product.stock > 0) {
        _items.add(
          CartItem(
            product: product,
            quantity: 1,
          ),
        );
      }
    }

    notifyListeners();
  }

  void increase(Product product) {
    final index = _items.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index == -1) return;

    if (_items[index].quantity < product.stock) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrease(Product product) {
    final index = _items.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index == -1) return;

    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }

    notifyListeners();
  }

  void remove(Product product) {
    _items.removeWhere(
          (item) => item.product.id == product.id,
    );

    notifyListeners();
  }

  void setDiscount(double value) {
    if (value < 0) {
      discount = 0;
    } else if (value > subtotal) {
      discount = subtotal;
    } else {
      discount = value;
    }

    notifyListeners();
  }

  void clear() {
    _items.clear();
    discount = 0;
    notifyListeners();
  }
}