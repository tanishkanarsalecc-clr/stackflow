import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/widgets/stackflow_background.dart';
import '../../core/widgets/stat_card.dart';
import '../../models/bill.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      body: StackFlowBackground(
        child: SafeArea(
          child: StreamBuilder<List<Product>>(
            stream: service.watchProducts(),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const LoadingView();
              }

              final products =
                  productSnapshot.data ?? <Product>[];

              return StreamBuilder<List<Bill>>(
                stream: service.watchBills(),
                builder: (context, billSnapshot) {
                  if (billSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const LoadingView();
                  }

                  final bills =
                      billSnapshot.data ?? <Bill>[];

                  return _AnalyticsBody(
                    products: products,
                    bills: bills,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  final List<Product> products;
  final List<Bill> bills;

  const _AnalyticsBody({
    required this.products,
    required this.bills,
  });

  double get revenue {
    return bills.fold(
      0,
          (sum, bill) => sum + bill.total,
    );
  }

  double get inventoryValue {
    return products.fold(
      0,
          (sum, product) =>
      sum + (product.price * product.quantity),
    );
  }

  int get lowStock {
    return products.where(
          (product) => product.quantity > 0 &&
          product.quantity <= 5,
    ).length;
  }

  int get outOfStock {
    return products.where(
          (product) => product.quantity <= 0,
    ).length;
  }

  double get averageBill {
    if (bills.isEmpty) return 0;

    return revenue / bills.length;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(
          const Duration(milliseconds: 500),
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          20,
          18,
          20,
          30,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Analytics',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Understand your business at a glance.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.insights_rounded,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          _RevenueHero(
            revenue: revenue,
            bills: bills.length,
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 142,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Products',
                    value: '${products.length}',
                    icon: Icons.inventory_2_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Inventory value',
                    value:
                    Formatters.money(inventoryValue),
                    icon:
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 142,
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Average bill',
                    value:
                    Formatters.money(averageBill),
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.cyan,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Low stock',
                    value: '$lowStock',
                    subtitle:
                    outOfStock > 0
                        ? '$outOfStock out of stock'
                        : 'Everything looks good',
                    icon:
                    Icons.warning_amber_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const Text(
            'Business health',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          _HealthCard(
            icon: Icons.inventory_2_rounded,
            title: 'Inventory status',
            value: products.isEmpty
                ? 'No products'
                : '$lowStock items need attention',
            color: lowStock > 0
                ? AppColors.warning
                : AppColors.success,
          ),

          const SizedBox(height: 10),

          _HealthCard(
            icon: Icons.receipt_long_rounded,
            title: 'Sales activity',
            value: bills.isEmpty
                ? 'No sales yet'
                : '${bills.length} bills recorded',
            color: bills.isEmpty
                ? AppColors.textMuted
                : AppColors.primary,
          ),

          const SizedBox(height: 28),

          const Text(
            'Top products',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          if (products.isEmpty)
            const SizedBox(
              height: 200,
              child: EmptyView(
                icon: Icons.analytics_outlined,
                title: 'Nothing to analyze',
                message:
                'Add products and create bills to see insights.',
              ),
            )
          else
            ...products
                .take(5)
                .map(
                  (product) => Padding(
                padding:
                const EdgeInsets.only(bottom: 10),
                child: _ProductInsight(
                  product: product,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RevenueHero extends StatelessWidget {
  final double revenue;
  final int bills;

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
            Color(0xFF5B5FEF),
            Color(0xFF4338CA),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.24,
            ),
            blurRadius: 30,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total revenue',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.money(revenue),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$bills ${bills == 1 ? 'bill' : 'bills'} generated',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 29,
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _HealthCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
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
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF777B8A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

class _ProductInsight extends StatelessWidget {
  final Product product;

  const _ProductInsight({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final percentage =
    (product.quantity / 50).clamp(0.0, 1.0);

    final color = product.quantity <= 0
        ? AppColors.danger
        : product.quantity <= 5
        ? AppColors.warning
        : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.84),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color:
                  AppColors.primaryLight,
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      product.category.isEmpty
                          ? 'Uncategorized'
                          : product.category,
                      style: const TextStyle(
                        color:
                        Color(0xFF777B8A),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${product.quantity}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius:
            BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor:
              Colors.grey.shade200,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}