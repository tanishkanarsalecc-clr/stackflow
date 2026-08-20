import 'cart_item.dart';

class Invoice {
  final String id;
  final String invoiceNumber;
  final List<CartItem> items;
  final double subtotal;
  final double discount;
  final double tax;
  final double total;
  final DateTime createdAt;
  final String paymentStatus;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.total,
    required this.createdAt,
    this.paymentStatus = 'Paid',
  });

  Map<String, dynamic> toMap() {
    return {
      'invoiceNumber': invoiceNumber,
      'items': items.map((item) {
        return {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.sellingPrice,
          'quantity': item.quantity,
          'total': item.total,
        };
      }).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'total': total,
      'createdAt': createdAt,
      'paymentStatus': paymentStatus,
    };
  }
}