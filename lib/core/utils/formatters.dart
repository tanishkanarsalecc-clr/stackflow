import 'package:intl/intl.dart';

class Formatters {
  static final currency = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
  );

  static final date = DateFormat('dd MMM yyyy');

  static String money(num value) {
    return currency.format(value);
  }

  static String formatDate(DateTime value) {
    return date.format(value);
  }
}