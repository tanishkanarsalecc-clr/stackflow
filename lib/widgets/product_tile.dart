import 'package:flutter/material.dart';

import '../core/helpers.dart';
import '../core/theme.dart';
import '../models/product.dart';

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onDelete;

  const ProductTile({
    super.key,
    required this.product,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final lowStock =
        product.stock <= product.lowStockAlert;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F6F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: product.imageUrl.isEmpty
                ? const Icon(
              Icons.inventory_2_outlined,
              color: StackFlowColors.primary,
            )
                : ClipRRect(
              borderRadius:
              BorderRadius.circular(10),
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
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: const TextStyle(
                    color:
                    StackFlowColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  formatCurrency(
                    product.sellingPrice,
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,
            children: [
              Text(
                lowStock
                    ? 'Low Stock'
                    : 'In Stock',
                style: TextStyle(
                  color: lowStock
                      ? StackFlowColors.red
                      : StackFlowColors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${product.stock}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          if (onDelete != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  onDelete!();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}