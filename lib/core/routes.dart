import 'package:flutter/material.dart';

import '../screens/auth_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/products_screen.dart';
import '../screens/add_product_screen.dart';
import '../screens/bill_screen.dart';
import '../screens/invoices_screen.dart';
import '../screens/customers_screen.dart';
import '../screens/suppliers_screen.dart';
import '../screens/reports_screen.dart';
import '../screens/settings_screen.dart';

class AppRoutes {
  static const String auth = '/';
  static const String dashboard = '/dashboard';
  static const String products = '/products';
  static const String addProduct = '/add-product';
  static const String bill = '/bill';
  static const String invoices = '/invoices';
  static const String customers = '/customers';
  static const String suppliers = '/suppliers';
  static const String reports = '/reports';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes {
    return {
      // REAL AUTH SCREEN
      auth: (_) => const AuthScreen(),

      dashboard: (_) => const DashboardScreen(),

      products: (_) => const ProductsScreen(),

      addProduct: (_) => const AddProductScreen(),

      bill: (_) => const BillScreen(),

      invoices: (_) => const InvoicesScreen(),

      customers: (_) => const CustomersScreen(),

      suppliers: (_) => const SuppliersScreen(),

      reports: (_) => const ReportsScreen(),

      settings: (_) => const SettingsScreen(),
    };
  }
}