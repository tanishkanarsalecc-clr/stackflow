import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/helpers.dart';
import '../core/theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../services/firebase_service.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  final searchController = TextEditingController();
  final discountController = TextEditingController();

  bool saving = false;

  @override
  void dispose() {
    searchController.dispose();
    discountController.dispose();
    super.dispose();
  }

  void updateDiscount(CartProvider cart, String value) {
    final discount = double.tryParse(value) ?? 0;
    cart.setDiscount(discount);
  }

  // =============================================================
  // CLEAR BILL
  // =============================================================

  Future<void> clearBill() async {
    final cart = context.read<CartProvider>();

    if (cart.items.isEmpty && discountController.text.isEmpty) {
      return;
    }

    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear bill?'),
          content: const Text(
            'All products and the discount will be removed from this bill.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                backgroundColor: StackFlowColors.red,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear != true) return;

    cart.clear();
    discountController.clear();
  }

  // =============================================================
  // SAVE BILL
  // =============================================================

  Future<void> saveBill() async {
    final cart = context.read<CartProvider>();

    if (cart.items.isEmpty) {
      _message('Add at least one product.');
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final items = cart.items.map((item) {
        return {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.sellingPrice,
          'quantity': item.quantity,
          'total': item.total,
        };
      }).toList();

      // Save total BEFORE clearing cart.
      final finalTotal = cart.total;

      final invoiceNumber = await FirebaseService.createInvoice(
        items: items,
        subtotal: cart.subtotal,
        discount: cart.discount,
        tax: cart.tax,
        total: finalTotal,
      );

      // Clear only after successful invoice creation.
      cart.clear();
      discountController.clear();

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: StackFlowColors.green.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: StackFlowColors.green,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Bill Saved'),
              ],
            ),
            content: Text(
              'Invoice $invoiceNumber\n\n'
                  'Total: ${formatCurrency(finalTotal)}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Done'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      _message(
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
      );
    }
  }

  // =============================================================
  // MESSAGE
  // =============================================================

  void _message(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Text(message),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final products = context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Bill',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Create a new invoice',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.normal,
                color: StackFlowColors.secondaryText,
              ),
            ),
          ],
        ),

        // DELETE / CLEAR OPTION REMAINS AT TOP
        actions: [
          IconButton(
            tooltip: 'Clear bill',
            onPressed: clearBill,
            icon: const Icon(
              Icons.delete_outline_rounded,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Column(
        children: [
          // =======================================================
          // SEARCH
          // =======================================================

          _SearchField(
            controller: searchController,
            onChanged: products.setSearch,
            onClear: () {
              searchController.clear();
              products.setSearch('');
              setState(() {});
            },
          ),

          // =======================================================
          // PRODUCTS / BILL ITEMS
          // =======================================================

          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: products.productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const _MessageState(
                    icon: Icons.error_outline_rounded,
                    title: 'Unable to load products',
                    subtitle: 'Please try again in a moment.',
                  );
                }

                final filtered = products.filterProducts(
                  snapshot.data ?? [],
                );

                return ListView(
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    20,
                  ),
                  children: [
                    // SEARCH RESULTS
                    if (products.search.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Products',
                        trailing: '${filtered.length} found',
                      ),
                      const SizedBox(height: 8),

                      if (filtered.isEmpty)
                        const _MessageState(
                          icon: Icons.search_off_rounded,
                          title: 'No products found',
                          subtitle:
                          'Try another product name or barcode.',
                        )
                      else
                        ...filtered.map(
                              (product) => _SearchProduct(
                            product: product,
                          ),
                        ),
                    ],

                    // EMPTY BILL
                    if (products.search.isEmpty &&
                        cart.items.isEmpty)
                      const _MessageState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Start a new bill',
                        subtitle:
                        'Search for a product above to add it to the bill.',
                      ),

                    // BILL ITEMS
                    if (cart.items.isNotEmpty) ...[
                      const SizedBox(height: 8),

                      _SectionHeader(
                        title: 'Bill Items',
                        trailing: '${cart.items.length} items',
                      ),

                      const SizedBox(height: 8),

                      ...cart.items.map(
                            (item) => _CartProduct(
                          product: item.product,
                          quantity: item.quantity,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),

          // =======================================================
          // BILL SUMMARY
          // =======================================================

          _BillSummary(
            saving: saving,
            discountController: discountController,
            onDiscountChanged: (value) {
              updateDiscount(cart, value);
            },
            onSave: saveBill,
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// SEARCH FIELD
// ===============================================================

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        2,
        16,
        12,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search product or barcode',
          prefixIcon: const Icon(
            Icons.search_rounded,
            size: 21,
          ),
          suffixIcon:
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Clear search',
                onPressed: onClear,
                icon: const Icon(
                  Icons.close_rounded,
                  size: 19,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// SECTION HEADER
// ===============================================================

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: StackFlowColors.text,
          ),
        ),
        const Spacer(),
        Text(
          trailing,
          style: const TextStyle(
            fontSize: 11,
            color: StackFlowColors.secondaryText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ===============================================================
// MESSAGE STATE
// ===============================================================

class _MessageState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _MessageState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 28,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: StackFlowColors.primary.withValues(
                alpha: 0.09,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: StackFlowColors.primary,
              size: 25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: StackFlowColors.text,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: StackFlowColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// SEARCH PRODUCT
// ===============================================================

class _SearchProduct extends StatelessWidget {
  final Product product;

  const _SearchProduct({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    final lowStock =
        product.stock <= product.lowStockAlert;

    final outOfStock =
        product.stock <= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: outOfStock
            ? null
            : () {
          cart.addProduct(product);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: StackFlowColors.border,
            ),
          ),
          child: Row(
            children: [
              _ProductImage(
                product: product,
              ),

              const SizedBox(width: 11),

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
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: StackFlowColors.text,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.category,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color:
                        StackFlowColors.secondaryText,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      formatCurrency(
                        product.sellingPrice,
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: StackFlowColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment:
                CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: outOfStock
                          ? StackFlowColors.red
                          .withValues(alpha: 0.08)
                          : lowStock
                          ? StackFlowColors.orange
                          .withValues(alpha: 0.10)
                          : StackFlowColors.green
                          .withValues(alpha: 0.09),
                      borderRadius:
                      BorderRadius.circular(7),
                    ),
                    child: Text(
                      outOfStock
                          ? 'Out of stock'
                          : lowStock
                          ? 'Low: ${product.stock}'
                          : '${product.stock} in stock',
                      style: TextStyle(
                        color: outOfStock
                            ? StackFlowColors.red
                            : lowStock
                            ? StackFlowColors.orange
                            : StackFlowColors.green,
                        fontSize: 9,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Icon(
                    outOfStock
                        ? Icons.block_rounded
                        : Icons.add_circle_rounded,
                    size: 23,
                    color: outOfStock
                        ? StackFlowColors.secondaryText
                        : StackFlowColors.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===============================================================
// PRODUCT IMAGE
// ===============================================================

class _ProductImage extends StatelessWidget {
  final Product product;

  const _ProductImage({
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F8),
        borderRadius:
        BorderRadius.circular(11),
      ),
      child: product.imageUrl.isEmpty
          ? const Icon(
        Icons.inventory_2_outlined,
        color: StackFlowColors.primary,
      )
          : ClipRRect(
        borderRadius:
        BorderRadius.circular(11),
        child: Image.network(
          product.imageUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return const Icon(
              Icons.inventory_2_outlined,
              color:
              StackFlowColors.primary,
            );
          },
        ),
      ),
    );
  }
}

// ===============================================================
// CART PRODUCT
// ===============================================================

class _CartProduct extends StatelessWidget {
  final Product product;
  final int quantity;

  const _CartProduct({
    required this.product,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: StackFlowColors.primary
              .withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: StackFlowColors.primary
                  .withValues(alpha: 0.08),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              size: 21,
              color: StackFlowColors.primary,
            ),
          ),

          const SizedBox(width: 10),

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
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: StackFlowColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${formatCurrency(product.sellingPrice)} each',
                  style: const TextStyle(
                    color:
                    StackFlowColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Container(
            height: 34,
            decoration: BoxDecoration(
              color: StackFlowColors.background,
              borderRadius:
              BorderRadius.circular(9),
              border: Border.all(
                color: StackFlowColors.border,
              ),
            ),
            child: Row(
              children: [
                _QuantityButton(
                  icon: Icons.remove_rounded,
                  onPressed: () {
                    cart.decrease(product);
                  },
                ),
                SizedBox(
                  width: 27,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                _QuantityButton(
                  icon: Icons.add_rounded,
                  onPressed: () {
                    cart.increase(product);
                  },
                  primary: true,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 65,
            child: Text(
              formatCurrency(
                product.sellingPrice * quantity,
              ),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: StackFlowColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===============================================================
// QUANTITY BUTTON
// ===============================================================

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;

  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    this.primary = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius:
      BorderRadius.circular(8),
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          size: 17,
          color: primary
              ? StackFlowColors.primary
              : StackFlowColors.secondaryText,
        ),
      ),
    );
  }
}

// ===============================================================
// BILL SUMMARY
// ===============================================================

class _BillSummary extends StatelessWidget {
  final bool saving;
  final TextEditingController discountController;
  final ValueChanged<String> onDiscountChanged;
  final VoidCallback onSave;

  const _BillSummary({
    required this.saving,
    required this.discountController,
    required this.onDiscountChanged,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final hasItems = cart.items.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        14,
        16,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(
            color: StackFlowColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          // =====================================================
          // SUBTOTAL
          // =====================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    StackFlowColors.secondaryText,
                  ),
                ),
              ),
              Text(
                formatCurrency(cart.subtotal),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // =====================================================
          // DISCOUNT
          // =====================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Discount',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    StackFlowColors.secondaryText,
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                height: 36,
                child: TextField(
                  controller:
                  discountController,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged:
                  onDiscountChanged,
                  textAlign: TextAlign.end,
                  decoration:
                  const InputDecoration(
                    hintText: '₹0',
                    contentPadding:
                    EdgeInsets.symmetric(
                      horizontal: 10,
                    ),
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      color:
                      StackFlowColors.secondaryText,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // =====================================================
          // TAX
          // =====================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Tax (5%)',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                    StackFlowColors.secondaryText,
                  ),
                ),
              ),
              Text(
                formatCurrency(cart.tax),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const Padding(
            padding:
            EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),

          // =====================================================
          // TOTAL
          // =====================================================

          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 12,
                        color:
                        StackFlowColors.secondaryText,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Amount to pay',
                      style: TextStyle(
                        fontSize: 10,
                        color:
                        StackFlowColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                formatCurrency(cart.total),
                style: const TextStyle(
                  color:
                  StackFlowColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =====================================================
          // SAVE / BILL & PAY
          //
          // Delete/Clear button intentionally removed from here.
          // Clear is available from the top AppBar.
          // =====================================================

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
              !hasItems || saving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                StackFlowColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                StackFlowColors.primary
                    .withValues(alpha: 0.35),
                minimumSize:
                const Size(double.infinity, 48),
                elevation: 0,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(11),
                ),
              ),
              child: saving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Row(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Bill & Pay',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}