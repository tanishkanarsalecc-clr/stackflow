import 'package:flutter/material.dart';

import '../features/analytics/analytics_screen.dart';
import '../features/billing/billing_screen.dart';
import '../features/dashboard/dashboard_screen.dart';
import '../features/inventory/inventory_screen.dart';
import '../features/profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState
    extends State<MainNavigation> {
  int _index = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    InventoryScreen(),
    BillingScreen(),
    AnalyticsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon:
            Icon(Icons.home_rounded),
            label: 'Home',
          ),

          NavigationDestination(
            icon:
            Icon(Icons.inventory_2_outlined),
            selectedIcon:
            Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),

          NavigationDestination(
            icon:
            Icon(Icons.receipt_long_outlined),
            selectedIcon:
            Icon(Icons.receipt_long_rounded),
            label: 'Billing',
          ),

          NavigationDestination(
            icon:
            Icon(Icons.insights_outlined),
            selectedIcon:
            Icon(Icons.insights_rounded),
            label: 'Insights',
          ),

          NavigationDestination(
            icon:
            Icon(Icons.person_outline),
            selectedIcon:
            Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}