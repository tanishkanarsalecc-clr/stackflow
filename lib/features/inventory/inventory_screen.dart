import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../models/product.dart';
import '../../services/firestore_service.dart';
import 'add_product_sheet.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _service = FirestoreService();
  final _searchController = TextEditingController();

  String _search = '';
  String _category = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddProduct() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddProductSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddProduct,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 8,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Product',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Stack(
        children: [
          const _InventoryBackground(),

          SafeArea(
            child: StreamBuilder<List<Product>>(
              stream: _service.watchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const LoadingView();
                }

                final products = snapshot.data ?? [];

                final categories = [
                  'All',
                  ...products
                      .map((product) => product.category)
                      .where((category) => category.isNotEmpty)
                      .toSet(),
                ];

                final filtered = products.where((product) {
                  final query = _search.toLowerCase();

                  final matchesSearch =
                      product.name.toLowerCase().contains(query) ||
                          product.category
                              .toLowerCase()
                              .contains(query);

                  final matchesCategory =
                      _category == 'All' ||
                          product.category == _category;

                  return matchesSearch && matchesCategory;
                }).toList();

                final totalStock = products.fold<int>(
                  0,
                      (sum, product) => sum + product.quantity,
                );

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

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    18,
                    20,
                    115,
                  ),
                  children: [
                    const _InventoryHeader(),

                    const SizedBox(height: 20),

                    _InventoryOverview(
                      products: products.length,
                      stock: totalStock,
                      lowStock: lowStock,
                      outOfStock: outOfStock,
                    ),

                    const SizedBox(height: 18),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.035),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() => _search = value);
                        },
                        decoration: const InputDecoration(
                          hintText: 'Search products or categories...',
                          prefixIcon: Icon(Icons.search_rounded),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) =>
                        const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final category = categories[index];

                          return ChoiceChip(
                            label: Text(category),
                            selected: _category == category,
                            onSelected: (_) {
                              setState(() {
                                _category = category;
                              });
                            },
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: _category == category
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: _category == category
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                            side: BorderSide(
                              color: _category == category
                                  ? AppColors.primary.withValues(
                                alpha: 0.2,
                              )
                                  : const Color(0xFFE5E6ED),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 22),

                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Your products',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${filtered.length} items',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (filtered.isEmpty)
                      const SizedBox(
                        height: 280,
                        child: EmptyView(
                          icon: Icons.inventory_2_outlined,
                          title: 'No products found',
                          message:
                          'Add products to start managing your inventory.',
                        ),
                      )
                    else
                      ...filtered.map(
                            (product) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ProductCard(
                            product: product,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _InventoryBackground extends StatelessWidget {
  const _InventoryBackground();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -100,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.10),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 500,
            left: -120,
            child: Container(
              height: 230,
              width: 230,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withValues(alpha: 0.055),
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

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Inventory',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Keep your stock organized',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 45,
          width: 45,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: const Color(0xFFE7E8F0),
            ),
          ),
          child: const Icon(
            Icons.tune_rounded,
            color: AppColors.textSecondary,
            size: 21,
          ),
        ),
      ],
    );
  }
}

class _InventoryOverview extends StatelessWidget {
  final int products;
  final int stock;
  final int lowStock;
  final int outOfStock;

  const _InventoryOverview({
    required this.products,
    required this.stock,
    required this.lowStock,
    required this.outOfStock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF3F5FF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          _OverviewItem(
            value: '$products',
            label: 'Products',
            icon: Icons.inventory_2_rounded,
            color: AppColors.primary,
          ),
          _OverviewDivider(),
          _OverviewItem(
            value: '$stock',
            label: 'Stock units',
            icon: Icons.layers_rounded,
            color: AppColors.cyan,
          ),
          _OverviewDivider(),
          _OverviewItem(
            value: '$lowStock',
            label: 'Low stock',
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
          ),
          _OverviewDivider(),
          _OverviewItem(
            value: '$outOfStock',
            label: 'Empty',
            icon: Icons.remove_shopping_cart_rounded,
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }
}

class _OverviewItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _OverviewItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      width: 1,
      color: const Color(0xFFE5E6ED),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final status = _status(product.quantity);

    return AppCard(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            height: 55,
            width: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFF0F1FF),
                  Color(0xFFF8F8FF),
                ],
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: AppColors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category.isEmpty
                      ? 'Uncategorized'
                      : product.category,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  Formatters.money(product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${product.quantity}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              _StatusChip(
                label: status.$1,
                color: status.$2,
              ),
            ],
          ),
        ],
      ),
    );
  }

  (String, Color) _status(int quantity) {
    if (quantity <= 0) {
      return ('Out of stock', AppColors.danger);
    }

    if (quantity <= 5) {
      return ('Low stock', AppColors.warning);
    }

    return ('In stock', AppColors.success);
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 8,
        ),
      ),
    );
  }
}