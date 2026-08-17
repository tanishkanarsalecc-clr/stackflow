import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/empty_view.dart';
import '../../core/widgets/loading_view.dart';
import '../../models/bill.dart';
import '../../models/product.dart';
import '../../services/billing_service.dart';
import '../../services/firestore_service.dart';
import 'bill_success_dialog.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _customerController = TextEditingController();
  final _searchController = TextEditingController();
  final _discountController = TextEditingController();

  final _firestoreService = FirestoreService();
  final _billingService = BillingService();

  final List<BillItem> _cart = [];

  String _search = '';
  bool _loading = false;

  @override
  void dispose() {
    _customerController.dispose();
    _searchController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _addProduct(Product product) {
    if (product.quantity <= 0) return;

    final index = _cart.indexWhere(
          (item) => item.productId == product.id,
    );

    if (index >= 0) {
      final existing = _cart[index];

      if (existing.quantity >= product.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Maximum available stock reached'),
          ),
        );
        return;
      }

      setState(() {
        _cart[index] = BillItem(
          productId: existing.productId,
          name: existing.name,
          quantity: existing.quantity + 1,
          price: existing.price,
        );
      });

      return;
    }

    setState(() {
      _cart.add(
        BillItem(
          productId: product.id,
          name: product.name,
          quantity: 1,
          price: product.price,
        ),
      );
    });
  }

  void _changeQuantity(int index, int change) {
    final item = _cart[index];
    final newQuantity = item.quantity + change;

    if (newQuantity <= 0) {
      setState(() {
        _cart.removeAt(index);
      });
      return;
    }

    setState(() {
      _cart[index] = BillItem(
        productId: item.productId,
        name: item.name,
        quantity: newQuantity,
        price: item.price,
      );
    });
  }

  double get _subtotal {
    return _cart.fold<double>(
      0,
          (sum, item) => sum + item.total,
    );
  }

  double get _discount {
    return double.tryParse(
      _discountController.text,
    ) ??
        0;
  }

  double get _total {
    final total = _subtotal - _discount;
    return total < 0 ? 0 : total;
  }

  Future<void> _generateBill() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Add at least one product to the bill'),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final billNumber = await _billingService.createBill(
        customerName: _customerController.text,
        items: _cart,
        discount: _discount,
      );

      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => BillSuccessDialog(
          billNumber: billNumber,
          total: _total,
        ),
      );

      setState(() {
        _cart.clear();
        _customerController.clear();
        _discountController.clear();
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not generate bill'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _BillingBackground(),

          SafeArea(
            child: StreamBuilder<List<Product>>(
              stream: _firestoreService.watchProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const LoadingView();
                }

                final products = snapshot.data ?? [];

                final filtered = products.where((product) {
                  return product.name
                      .toLowerCase()
                      .contains(_search.toLowerCase());
                }).toList();

                return Column(
                  children: [
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          18,
                          20,
                          20,
                        ),
                        children: [
                          const _BillingHeader(),

                          const SizedBox(height: 20),

                          _CustomerCard(
                            controller: _customerController,
                          ),

                          const SizedBox(height: 25),

                          Row(
                            children: [
                              const Expanded(
                                child: _BillingSectionTitle(
                                  title: 'Products',
                                  subtitle:
                                  'Select items for this bill',
                                ),
                              ),
                              if (_cart.isNotEmpty)
                                Container(
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius:
                                    BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_cart.length} items',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 13),

                          TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() => _search = value);
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search products...',
                              prefixIcon:
                              Icon(Icons.search_rounded),
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (filtered.isEmpty)
                            const SizedBox(
                              height: 170,
                              child: EmptyView(
                                icon: Icons.inventory_2_outlined,
                                title: 'No products',
                                message:
                                'Add products to inventory first.',
                              ),
                            )
                          else
                            ...filtered.take(8).map(
                                  (product) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 8),
                                child: _ProductSelectionCard(
                                  product: product,
                                  onAdd: () =>
                                      _addProduct(product),
                                ),
                              ),
                            ),

                          const SizedBox(height: 25),

                          const _BillingSectionTitle(
                            title: 'Current bill',
                            subtitle:
                            'Review your items before checkout',
                          ),

                          const SizedBox(height: 12),

                          if (_cart.isEmpty)
                            Container(
                              padding:
                              const EdgeInsets.symmetric(
                                vertical: 25,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE7E8F0),
                                ),
                              ),
                              child: const Column(
                                children: [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    color:
                                    AppColors.textMuted,
                                    size: 30,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Your cart is empty',
                                    style: TextStyle(
                                      fontWeight:
                                      FontWeight.w700,
                                      color:
                                      AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Add a product above to begin.',
                                    style: TextStyle(
                                      color:
                                      AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._cart.asMap().entries.map(
                                  (entry) => Padding(
                                padding:
                                const EdgeInsets.only(bottom: 8),
                                child: _CartItem(
                                  item: entry.value,
                                  onDecrease: () =>
                                      _changeQuantity(
                                        entry.key,
                                        -1,
                                      ),
                                  onIncrease: () =>
                                      _changeQuantity(
                                        entry.key,
                                        1,
                                      ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 10),

                          TextField(
                            controller: _discountController,
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              labelText: 'Discount',
                              hintText: '0',
                              prefixIcon:
                              Icon(Icons.discount_outlined),
                            ),
                          ),

                          const SizedBox(height: 15),

                          _BillSummary(
                            subtotal: _subtotal,
                            discount: _discount,
                            total: _total,
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.97),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.07,
                            ),
                            blurRadius: 25,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      child: SafeArea(
                        top: false,
                        child: AppButton(
                          text: _cart.isEmpty
                              ? 'Add Products First'
                              : 'Generate Bill',
                          icon: Icons.check_circle_outline_rounded,
                          loading: _loading,
                          onPressed: _cart.isEmpty
                              ? null
                              : _generateBill,
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

class _BillingBackground extends StatelessWidget {
  const _BillingBackground();

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
                    AppColors.purple.withValues(alpha: 0.09),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 500,
            left: -130,
            child: Container(
              height: 260,
              width: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.06),
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

class _BillingHeader extends StatelessWidget {
  const _BillingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'New Bill',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Create a quick customer invoice',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 47,
          width: 47,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primaryDark,
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.receipt_long_rounded,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final TextEditingController controller;

  const _CustomerCard({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF3F4FF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: AppColors.primary,
                size: 19,
              ),
              SizedBox(width: 8),
              Text(
                'Customer',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Customer name',
              prefixIcon: Icon(Icons.person_outline),
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillingSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BillingSectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
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

class _ProductSelectionCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const _ProductSelectionCard({
    required this.product,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = product.quantity <= 0;

    return AppCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: disabled
                  ? Colors.grey.shade100
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: disabled
                  ? AppColors.textMuted
                  : AppColors.primary,
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
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.money(product.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  disabled
                      ? 'Out of stock'
                      : '${product.quantity} units available',
                  style: TextStyle(
                    color: disabled
                        ? AppColors.danger
                        : AppColors.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filled(
            onPressed: disabled ? null : onAdd,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final BillItem item;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  const _CartItem({
    required this.item,
    required this.onDecrease,
    required this.onIncrease,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            height: 43,
            width: 43,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.money(item.price),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onDecrease,
                  icon: const Icon(
                    Icons.remove_rounded,
                    size: 16,
                  ),
                ),
                Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onIncrease,
                  icon: const Icon(
                    Icons.add_rounded,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            Formatters.money(item.total),
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillSummary extends StatelessWidget {
  final double subtotal;
  final double discount;
  final double total;

  const _BillSummary({
    required this.subtotal,
    required this.discount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF5F5FF),
          ],
        ),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          _TotalRow(
            label: 'Subtotal',
            value: subtotal,
          ),
          const SizedBox(height: 10),
          _TotalRow(
            label: 'Discount',
            value: discount,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grand Total',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Amount payable',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
              Text(
                Formatters.money(total),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 23,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final double value;

  const _TotalRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          Formatters.money(value),
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}