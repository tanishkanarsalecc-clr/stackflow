import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../models/bill.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final service = FirestoreService();

    final email = user?.email ?? 'User';
    final firstName = email.split('@').first;

    return Scaffold(
      body: Stack(
        children: [
          const _DashboardBackground(),

          SafeArea(
            child: StreamBuilder<List<Product>>(
              stream: service.watchProducts(),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const LoadingView();
                }

                final products = productSnapshot.data ?? [];

                return StreamBuilder<List<Bill>>(
                  stream: service.watchBills(),
                  builder: (context, billSnapshot) {
                    if (billSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const LoadingView();
                    }

                    final bills = billSnapshot.data ?? [];

                    final lowStock = products
                        .where(
                          (product) =>
                      product.quantity > 0 &&
                          product.quantity <= 5,
                    )
                        .length;

                    final outOfStock = products
                        .where((product) => product.quantity <= 0)
                        .length;

                    final totalRevenue = bills.fold<double>(
                      0,
                          (sum, bill) => sum + bill.total,
                    );

                    final today = DateTime.now();

                    final todayBills = bills.where(
                          (bill) =>
                      bill.createdAt.year == today.year &&
                          bill.createdAt.month == today.month &&
                          bill.createdAt.day == today.day,
                    );

                    final todaySales = todayBills.fold<double>(
                      0,
                          (sum, bill) => sum + bill.total,
                    );

                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        18,
                        20,
                        110,
                      ),
                      children: [
                        _DashboardHeader(
                          name: firstName,
                          email: email,
                        ),

                        const SizedBox(height: 22),

                        _RevenueHero(
                          revenue: totalRevenue,
                          bills: bills,
                        ),

                        const SizedBox(height: 18),

                        _StatsGrid(
                          products: products.length,
                          lowStock: lowStock,
                          todaySales: todaySales,
                          outOfStock: outOfStock,
                        ),

                        const SizedBox(height: 28),

                        const _SectionHeader(
                          title: 'Quick actions',
                          subtitle: 'Your everyday tools',
                        ),

                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.add_box_rounded,
                                title: 'Add product',
                                subtitle: 'Stock up',
                                color: AppColors.primary,
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _ActionCard(
                                icon: Icons.point_of_sale_rounded,
                                title: 'New bill',
                                subtitle: 'Make a sale',
                                color: AppColors.purple,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        Row(
                          children: [
                            const Expanded(
                              child: _SectionHeader(
                                title: 'Recent bills',
                                subtitle: 'Latest transactions',
                              ),
                            ),
                            if (bills.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius:
                                  BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${bills.length} total',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        if (bills.isEmpty)
                          const SizedBox(
                            height: 230,
                            child: EmptyView(
                              icon: Icons.receipt_long_outlined,
                              title: 'No bills yet',
                              message:
                              'Your recent sales will appear here.',
                            ),
                          )
                        else
                          ...bills.take(5).map(
                                (bill) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 10,
                              ),
                              child: _BillCard(bill: bill),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _DashboardBackground extends StatelessWidget {
  const _DashboardBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 310,
            left: -120,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.purple.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final String name;
  final String email;

  const _DashboardHeader({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
    email.isEmpty ? 'U' : email.substring(0, 1).toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DashboardScreen._greeting(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                name.length > 18
                    ? '${name.substring(0, 18)}...'
                    : name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(17),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.20),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RevenueHero extends StatelessWidget {
  final double revenue;
  final List<Bill> bills;

  const _RevenueHero({
    required this.revenue,
    required this.bills,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366F1),
            Color(0xFF4338CA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(27),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.24),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -35,
            child: Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: -45,
            child: Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'BUSINESS OVERVIEW',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const Text(
                'Total revenue',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                Formatters.money(revenue),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _HeroInfo(
                    icon: Icons.receipt_long_rounded,
                    label: 'Bills',
                    value: '${bills.length}',
                  ),
                  const SizedBox(width: 20),
                  _HeroInfo(
                    icon: Icons.analytics_rounded,
                    label: 'Average',
                    value: bills.isEmpty
                        ? '₹0'
                        : Formatters.money(
                      revenue / bills.length,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _MiniRevenueChart(bills: bills),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroInfo({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 15,
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 9,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniRevenueChart extends StatelessWidget {
  final List<Bill> bills;

  const _MiniRevenueChart({
    required this.bills,
  });

  @override
  Widget build(BuildContext context) {
    final values = bills.take(7).map((e) => e.total).toList();

    return SizedBox(
      height: 42,
      width: double.infinity,
      child: CustomPaint(
        painter: _ChartPainter(values),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<double> values;

  _ChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxValue =
    values.reduce((a, b) => a > b ? a : b);

    final minValue =
    values.reduce((a, b) => a < b ? a : b);

    final range = maxValue - minValue;

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    for (var i = 0; i < values.length; i++) {
      final x =
          i * size.width / (values.length - 1);

      final normalized = range == 0
          ? 0.5
          : (values[i] - minValue) / range;

      final y =
          size.height - (normalized * (size.height - 8)) - 4;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _StatsGrid extends StatelessWidget {
  final int products;
  final int lowStock;
  final double todaySales;
  final int outOfStock;

  const _StatsGrid({
    required this.products,
    required this.lowStock,
    required this.todaySales,
    required this.outOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _StatCard(
          title: 'Products',
          value: '$products',
          icon: Icons.inventory_2_rounded,
          color: AppColors.primary,
          background: AppColors.primaryLight,
        ),
        _StatCard(
          title: 'Low stock',
          value: '$lowStock',
          icon: Icons.warning_amber_rounded,
          color: AppColors.warning,
          background: AppColors.warningLight,
        ),
        _StatCard(
          title: "Today's sales",
          value: Formatters.money(todaySales),
          icon: Icons.shopping_bag_rounded,
          color: AppColors.cyan,
          background: AppColors.cyanLight,
        ),
        _StatCard(
          title: 'Out of stock',
          value: '$outOfStock',
          icon: Icons.remove_shopping_cart_rounded,
          color: AppColors.danger,
          background: AppColors.dangerLight,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AppCard(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill;

  const _BillCard({
    required this.bill,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.primary.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: AppColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  bill.customerName.isEmpty
                      ? 'Walk-in customer'
                      : bill.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  bill.billNumber,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.money(bill.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                Formatters.formatDate(bill.createdAt),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}