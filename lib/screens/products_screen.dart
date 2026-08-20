import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../providers/product_provider.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/product_tile.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<ProductProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Products',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.shopping_bag_outlined),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              10,
            ),
            child: TextField(
              onChanged: provider.setSearch,
              decoration: const InputDecoration(
                hintText: 'Search products...',
                prefixIcon: Icon(
                  Icons.search,
                  size: 20,
                ),
                suffixIcon: Icon(
                  Icons.tune,
                  size: 19,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 45,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              scrollDirection: Axis.horizontal,
              children: const [
                _CategoryChip(
                  text: 'All',
                  selected: true,
                ),
                _CategoryChip(text: 'Electronics'),
                _CategoryChip(text: 'Stationery'),
                _CategoryChip(text: 'Grocery'),
                _CategoryChip(text: 'Other'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder(
              stream: provider.productsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Unable to load products.\n'
                          '${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final products =
                provider.filterProducts(
                  snapshot.data ?? [],
                );

                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 50,
                          color:
                          StackFlowColors.secondaryText,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    90,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, index) {
                    final product =
                    products[index];

                    return ProductTile(
                      product: product,
                      onDelete: () async {
                        await provider.deleteProduct(
                          product.id,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: StackFlowColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.pushNamed(
            context,
            AppRoutes.addProduct,
          );
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar:
      const BottomNav(selectedIndex: 1),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String text;
  final bool selected;

  const _CategoryChip({
    required this.text,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(text),
        backgroundColor: selected
            ? StackFlowColors.blue
            : Colors.white,
        labelStyle: TextStyle(
          color: selected
              ? Colors.white
              : StackFlowColors.text,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide(
          color: selected
              ? StackFlowColors.blue
              : StackFlowColors.border,
        ),
      ),
    );
  }
}