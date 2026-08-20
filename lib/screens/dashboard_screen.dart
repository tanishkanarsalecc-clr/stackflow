import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
        title: const Text(
          'Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 15),
            child: CircleAvatar(
              radius: 17,
              child: Icon(
                Icons.person,
                size: 18,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            _RevenueCard(),

            const SizedBox(height: 15),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.65,
              children: const [
                StatCard(
                  title: 'Products',
                  value: '1,240',
                  icon: Icons.inventory_2_outlined,
                ),
                StatCard(
                  title: 'Low Stock',
                  value: '23',
                  icon: Icons.warning_amber_outlined,
                  iconColor:
                  StackFlowColors.orange,
                ),
                StatCard(
                  title: 'Customers',
                  value: '568',
                  icon: Icons.people_outline,
                  iconColor:
                  StackFlowColors.green,
                ),
                StatCard(
                  title: 'Suppliers',
                  value: '45',
                  icon: Icons.local_shipping_outlined,
                  iconColor:
                  StackFlowColors.blue,
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: StackFlowColors.text,
              ),
            ),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.9,
              children: [
                _Action(
                  icon: Icons.add_box_outlined,
                  title: 'Add Product',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.addProduct,
                    );
                  },
                ),
                _Action(
                  icon:
                  Icons.receipt_long_outlined,
                  title: 'New Bill',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.bill,
                    );
                  },
                ),
                _Action(
                  icon: Icons.people_outline,
                  title: 'Customers',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.customers,
                    );
                  },
                ),
                _Action(
                  icon: Icons.bar_chart_outlined,
                  title: 'Reports',
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.reports,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),

      bottomNavigationBar:
      const BottomNav(selectedIndex: 0),
    );
  }
}

class _RevenueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087FD1),
            Color(0xFF08AFA5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Revenue',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  '₹ 1,25,430',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  '+ 18.6% from last month',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 27,
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 13,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: StackFlowColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: StackFlowColors.primary,
              size: 22,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}