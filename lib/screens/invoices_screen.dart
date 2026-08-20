import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/helpers.dart';
import '../core/routes.dart';
import '../core/theme.dart';
import '../services/firebase_service.dart';

class InvoicesScreen extends StatefulWidget {
  const InvoicesScreen({super.key});

  @override
  State<InvoicesScreen> createState() => _InvoicesScreenState();
}

class _InvoicesScreenState extends State<InvoicesScreen> {
  String selectedFilter = 'All';

  final List<String> filters = const [
    'All',
    'Paid',
    'Unpaid',
  ];

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.dashboard,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _goBack(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text(
          'Invoices',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          // =====================================================
          // FILTERS
          // =====================================================

          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) {
                return const SizedBox(width: 8);
              },
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      selectedFilter = filter;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? StackFlowColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? StackFlowColors.primary
                            : StackFlowColors.border,
                      ),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : StackFlowColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // =====================================================
          // INVOICE LIST
          // =====================================================

          Expanded(
            child: StreamBuilder<
                QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseService.invoiceStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return _InvoiceError(
                    message: snapshot.error.toString(),
                  );
                }

                final documents = snapshot.data?.docs ?? [];

                final filtered = documents.where((doc) {
                  final data = doc.data();

                  final status =
                  (data['paymentStatus'] ?? 'Paid').toString();

                  if (selectedFilter == 'All') {
                    return true;
                  }

                  return status.toLowerCase() ==
                      selectedFilter.toLowerCase();
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyInvoices(
                    filter: selectedFilter,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    20,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _InvoiceCard(
                      document: filtered[index],
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
}

// ===============================================================
// INVOICE CARD
// ===============================================================

class _InvoiceCard extends StatelessWidget {
  final QueryDocumentSnapshot<Map<String, dynamic>> document;

  const _InvoiceCard({
    required this.document,
  });

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Just now';
    }

    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return 'Recently';
  }

  @override
  Widget build(BuildContext context) {
    final data = document.data();

    final invoiceNumber =
    (data['invoiceNumber'] ?? 'Invoice').toString();

    final status =
    (data['paymentStatus'] ?? 'Paid').toString();

    final total =
    ((data['total'] ?? 0) as num).toDouble();

    final items =
        (data['items'] as List?) ?? [];

    final date = _formatDate(
      data['createdAt'],
    );

    final isPaid =
        status.toLowerCase() == 'paid';

    return Container(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InvoiceDetailsScreen(
                invoiceId: document.id,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // =================================================
              // TOP SECTION
              // =================================================

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: StackFlowColors.primary
                          .withValues(alpha: 0.10),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: StackFlowColors.primary,
                      size: 22,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          invoiceNumber,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$date • ${items.length} '
                              '${items.length == 1 ? 'item' : 'items'}',
                          style: const TextStyle(
                            color: StackFlowColors
                                .secondaryText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    formatCurrency(total),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 13),

              const Divider(height: 1),

              const SizedBox(height: 11),

              // =================================================
              // BOTTOM SECTION
              // =================================================

              Row(
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? StackFlowColors.green
                          .withValues(alpha: 0.10)
                          : StackFlowColors.orange
                          .withValues(alpha: 0.10),
                      borderRadius:
                      BorderRadius.circular(7),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: isPaid
                            ? StackFlowColors.green
                            : StackFlowColors.orange,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  const Text(
                    'View details',
                    style: TextStyle(
                      color:
                      StackFlowColors.primary,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 3),

                  const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color:
                    StackFlowColors.primary,
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
// EMPTY INVOICE STATE
// ===============================================================

class _EmptyInvoices extends StatelessWidget {
  final String filter;

  const _EmptyInvoices({
    required this.filter,
  });

  @override
  Widget build(BuildContext context) {
    String title;
    String message;

    if (filter == 'Paid') {
      title = 'No paid invoices';
      message =
      'There are no paid invoices to display.';
    } else if (filter == 'Unpaid') {
      title = 'No unpaid invoices';
      message =
      'There are no unpaid invoices to display.';
    } else {
      title = 'No invoices yet';
      message =
      'Create your first bill and it will appear here.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: StackFlowColors.primary
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 34,
                color: StackFlowColors.primary,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                StackFlowColors.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// ERROR STATE
// ===============================================================

class _InvoiceError extends StatelessWidget {
  final String message;

  const _InvoiceError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: StackFlowColors.orange
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 34,
                color:
                StackFlowColors.orange,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to load invoices',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color:
                StackFlowColors.secondaryText,
                fontSize: 11,
              ),
            ),

            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const InvoicesScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===============================================================
// INVOICE DETAILS SCREEN
// ===============================================================

class InvoiceDetailsScreen extends StatelessWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoiceId,
  });

  String _formatDate(dynamic value) {
    if (value == null) {
      return 'Just now';
    }

    if (value is Timestamp) {
      final date = value.toDate();

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    return 'Recently';
  }

  void _goBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.invoices,
      );
    }
  }

  void _showPrintMessage(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Print feature will be added next.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _goBack(context),
          icon: const Icon(
            Icons.arrow_back,
          ),
          tooltip: 'Back',
        ),
        title: const Text(
          'Invoice Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        // =====================================================
        // PRINT ACTION
        // =====================================================

        actions: [
          IconButton(
            onPressed: () {
              _showPrintMessage(context);
            },
            icon: const Icon(
              Icons.print_outlined,
            ),
            tooltip: 'Print invoice',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseService.getInvoice(
          invoiceId,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Invoice not found.',
              ),
            );
          }

          final data =
          snapshot.data!.data()!;

          final invoiceNumber =
          (data['invoiceNumber'] ?? 'Invoice')
              .toString();

          final status =
          (data['paymentStatus'] ?? 'Paid')
              .toString();

          final subtotal =
          ((data['subtotal'] ?? 0) as num)
              .toDouble();

          final discount =
          ((data['discount'] ?? 0) as num)
              .toDouble();

          final tax =
          ((data['tax'] ?? 0) as num)
              .toDouble();

          final total =
          ((data['total'] ?? 0) as num)
              .toDouble();

          final items =
              (data['items'] as List?) ?? [];

          final isPaid =
              status.toLowerCase() == 'paid';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // =================================================
              // INVOICE HEADER
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(14),
                  border: Border.all(
                    color:
                    StackFlowColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: StackFlowColors.primary
                            .withValues(alpha: 0.09),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        color:
                        StackFlowColors.primary,
                        size: 29,
                      ),
                    ),

                    const SizedBox(height: 11),

                    Text(
                      invoiceNumber,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        StackFlowColors.text,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _formatDate(
                        data['createdAt'],
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: StackFlowColors
                            .secondaryText,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? StackFlowColors.green
                            .withValues(alpha: 0.10)
                            : StackFlowColors.orange
                            .withValues(alpha: 0.10),
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: isPaid
                              ? StackFlowColors.green
                              : StackFlowColors.orange,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // ITEMS TITLE
              // =================================================

              const Text(
                'Items',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: StackFlowColors.text,
                ),
              ),

              const SizedBox(height: 9),

              // =================================================
              // ITEMS
              // =================================================

              ...items.map(
                    (item) {
                  final itemMap =
                  Map<String, dynamic>.from(
                    item as Map,
                  );

                  final name =
                  (itemMap['name'] ??
                      'Product')
                      .toString();

                  final price =
                  ((itemMap['price'] ?? 0)
                  as num)
                      .toDouble();

                  final quantity =
                  (itemMap['quantity'] ?? 1)
                  as num;

                  final itemTotal =
                  ((itemMap['total'] ?? 0)
                  as num)
                      .toDouble();

                  return Container(
                    width: double.infinity,
                    margin:
                    const EdgeInsets.only(
                      bottom: 9,
                    ),
                    padding:
                    const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(12),
                      border: Border.all(
                        color:
                        StackFlowColors.border,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: StackFlowColors
                                .background,
                            borderRadius:
                            BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color:
                            StackFlowColors.primary,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                maxLines: 1,
                                overflow:
                                TextOverflow.ellipsis,
                                style:
                                const TextStyle(
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w600,
                                ),
                              ),

                              const SizedBox(
                                height: 4,
                              ),

                              Text(
                                '${quantity.toInt()} × '
                                    '${formatCurrency(price)}',
                                style:
                                const TextStyle(
                                  color: StackFlowColors
                                      .secondaryText,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 12),

                        Text(
                          formatCurrency(itemTotal),
                          textAlign: TextAlign.right,
                          style:
                          const TextStyle(
                            fontSize: 12,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),

              // =================================================
              // TOTALS
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(14),
                  border: Border.all(
                    color:
                    StackFlowColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    _TotalRow(
                      title: 'Subtotal',
                      value:
                      formatCurrency(subtotal),
                    ),

                    const SizedBox(height: 9),

                    _TotalRow(
                      title: 'Discount',
                      value: discount > 0
                          ? '-${formatCurrency(discount)}'
                          : formatCurrency(0),
                    ),

                    const SizedBox(height: 9),

                    _TotalRow(
                      title: 'Tax',
                      value:
                      formatCurrency(tax),
                    ),

                    const Padding(
                      padding:
                      EdgeInsets.symmetric(
                        vertical: 5,
                      ),
                      child: Divider(),
                    ),

                    _TotalRow(
                      title: 'Total',
                      value:
                      formatCurrency(total),
                      bold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =================================================
              // PRINT BUTTON
              // =================================================

              OutlinedButton.icon(
                onPressed: () {
                  _showPrintMessage(context);
                },
                icon: const Icon(
                  Icons.print_outlined,
                  size: 20,
                ),
                label: const Text(
                  'Print Invoice',
                ),
                style: OutlinedButton.styleFrom(
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
                    BorderRadius.circular(11),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

// ===============================================================
// TOTAL ROW
// ===============================================================

class _TotalRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const _TotalRow({
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: bold ? 15 : 12,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: StackFlowColors.text,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            fontSize: bold ? 16 : 12,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.w500,
            color: bold
                ? StackFlowColors.primary
                : StackFlowColors.text,
          ),
        ),
      ],
    );
  }
}