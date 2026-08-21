import 'package:flutter/material.dart';

import '../core/theme.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final List<_Supplier> suppliers = [
    const _Supplier(
      name: 'ABC Wholesale',
      phone: '9876543210',
      business: 'General Products',
    ),
    const _Supplier(
      name: 'Fresh Stock Traders',
      phone: '9876501234',
      business: 'Grocery & FMCG',
    ),
  ];

  // ============================================================
  // ADD SUPPLIER
  // ============================================================

  void _showAddSupplierDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final businessController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Add Supplier',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  textCapitalization:
                  TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Supplier Name',
                    hintText: 'Enter supplier name',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter phone number',
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: businessController,
                  textCapitalization:
                  TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Business / Products',
                    hintText: 'Example: Grocery',
                    prefixIcon: const Icon(
                      Icons.business_outlined,
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                final name =
                nameController.text.trim();

                final phone =
                phoneController.text.trim();

                final business =
                businessController.text.trim();

                if (name.isEmpty) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please enter supplier name.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  suppliers.add(
                    _Supplier(
                      name: name,
                      phone: phone.isEmpty
                          ? 'No phone number'
                          : phone,
                      business: business.isEmpty
                          ? 'General Supplier'
                          : business,
                    ),
                  );
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Supplier added successfully.',
                    ),
                  ),
                );
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DELETE SUPPLIER
  // ============================================================

  void _deleteSupplier(int index) {
    final supplier = suppliers[index];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Supplier?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Remove ${supplier.name} from the supplier list?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            TextButton(
              onPressed: () {
                setState(() {
                  suppliers.removeAt(index);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Supplier removed.',
                    ),
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SUPPLIER DETAILS
  // ============================================================

  void _showSupplierDetails(_Supplier supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            supplier.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.business_outlined,
                    size: 20,
                    color: StackFlowColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      supplier.business,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: StackFlowColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      supplier.phone,
                      style: const TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suppliers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showAddSupplierDialog,
            icon: const Icon(Icons.add),
            tooltip: 'Add supplier',
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: suppliers.isEmpty
          ? _EmptySuppliers(
        onAdd: _showAddSupplierDialog,
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // =================================================
          // INFO CARD
          // =================================================

          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: StackFlowColors.primary
                  .withValues(alpha: 0.08),
              borderRadius:
              BorderRadius.circular(14),
              border: Border.all(
                color: StackFlowColors.primary
                    .withValues(alpha: 0.15),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color:
                  StackFlowColors.primary,
                  size: 22,
                ),

                SizedBox(width: 10),

                Expanded(
                  child: Text(
                    'Suppliers are the businesses or people you purchase stock from.',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                      StackFlowColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // =================================================
          // TITLE
          // =================================================

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Supplier List',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    StackFlowColors.text,
                  ),
                ),
              ),

              Text(
                '${suppliers.length} supplier'
                    '${suppliers.length == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: StackFlowColors
                      .secondaryText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // =================================================
          // SUPPLIER LIST
          // =================================================

          ...List.generate(
            suppliers.length,
                (index) {
              final supplier =
              suppliers[index];

              return _SupplierCard(
                supplier: supplier,
                onTap: () {
                  _showSupplierDetails(
                    supplier,
                  );
                },
                onPhoneTap: () {
                  _showSupplierPhone(
                    supplier.phone,
                  );
                },
                onDelete: () {
                  _deleteSupplier(index);
                },
              );
            },
          ),

          const SizedBox(height: 12),

          // =================================================
          // ADD BUTTON
          // =================================================

          OutlinedButton.icon(
            onPressed:
            _showAddSupplierDialog,
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Supplier',
            ),
            style:
            OutlinedButton.styleFrom(
              minimumSize: const Size(
                double.infinity,
                48,
              ),
              foregroundColor:
              StackFlowColors.primary,
              side: const BorderSide(
                color:
                StackFlowColors.primary,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(
                  11,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),

      // ==========================================================
      // FLOATING ADD BUTTON
      // ==========================================================

      floatingActionButton:
      FloatingActionButton(
        onPressed: _showAddSupplierDialog,
        backgroundColor:
        StackFlowColors.primary,
        foregroundColor: Colors.white,
        tooltip: 'Add supplier',
        child: const Icon(Icons.add),
      ),
    );
  }

  // ============================================================
  // PHONE
  // ============================================================

  void _showSupplierPhone(String phone) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Supplier Contact',
          ),
          content: Text(
            phone,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// SUPPLIER MODEL FOR THIS SCREEN
// ================================================================

class _Supplier {
  final String name;
  final String phone;
  final String business;

  const _Supplier({
    required this.name,
    required this.phone,
    required this.business,
  });
}

// ================================================================
// SUPPLIER CARD
// ================================================================

class _SupplierCard extends StatelessWidget {
  final _Supplier supplier;
  final VoidCallback onTap;
  final VoidCallback onPhoneTap;
  final VoidCallback onDelete;

  const _SupplierCard({
    required this.supplier,
    required this.onTap,
    required this.onPhoneTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // ==================================================
              // ICON
              // ==================================================

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: StackFlowColors.primary
                      .withValues(alpha: 0.10),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_shipping_outlined,
                  color:
                  StackFlowColors.primary,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              // ==================================================
              // DETAILS
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier.name,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        StackFlowColors.text,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      supplier.business,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: StackFlowColors
                            .secondaryText,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      supplier.phone,
                      style: const TextStyle(
                        fontSize: 11,
                        color: StackFlowColors
                            .secondaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 4),

              // ==================================================
              // PHONE
              // ==================================================

              IconButton(
                onPressed: onPhoneTap,
                tooltip: 'Contact supplier',
                icon: const Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color:
                  StackFlowColors.primary,
                ),
              ),

              // ==================================================
              // DELETE
              // ==================================================

              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete supplier',
                icon: const Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// EMPTY SUPPLIERS
// ================================================================

class _EmptySuppliers extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptySuppliers({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: StackFlowColors.primary
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                size: 38,
                color:
                StackFlowColors.primary,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No suppliers yet',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: StackFlowColors.text,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add suppliers that you purchase products from.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color:
                StackFlowColors.secondaryText,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Supplier',
              ),
            ),
          ],
        ),
      ),
    );
  }
}