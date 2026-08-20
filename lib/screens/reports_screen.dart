import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../services/firebase_service.dart';
import '../widgets/bottom_nav.dart';
import 'invoices_screen.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.dashboard,
              );
            }
          },
          icon: const Icon(
            Icons.arrow_back,
          ),
        ),
        title: const Text(
          'Reports',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseService.invoiceStream(),
        builder: (
            context,
            snapshot,
            ) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _ErrorState(
              message:
              'Unable to load reports.\n\n'
                  '${snapshot.error}',
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          if (documents.isEmpty) {
            return const _EmptyReports();
          }

          return _ReportsContent(
            documents: documents,
          );
        },
      ),

      bottomNavigationBar:
      const BottomNav(selectedIndex: 0),
    );
  }
}

class _ReportsContent extends StatelessWidget {
  final List<
      QueryDocumentSnapshot<Map<String, dynamic>>> documents;

  const _ReportsContent({
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    double totalSales = 0;
    double totalSubtotal = 0;
    double totalDiscount = 0;
    double totalTax = 0;

    int paidInvoices = 0;
    int unpaidInvoices = 0;
    int totalItemsSold = 0;

    for (final document in documents) {
      final data = document.data();

      totalSales +=
          ((data['total'] ?? 0) as num).toDouble();

      totalSubtotal +=
          ((data['subtotal'] ?? 0) as num).toDouble();

      totalDiscount +=
          ((data['discount'] ?? 0) as num).toDouble();

      totalTax +=
          ((data['tax'] ?? 0) as num).toDouble();

      final status =
      (data['paymentStatus'] ?? 'Paid')
          .toString()
          .toLowerCase();

      if (status == 'paid') {
        paidInvoices++;
      } else {
        unpaidInvoices++;
      }

      final items =
          (data['items'] as List?) ?? [];

      for (final item in items) {
        if (item is Map) {
          totalItemsSold +=
              ((item['quantity'] ?? 0) as num)
                  .toInt();
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.delayed(
          const Duration(milliseconds: 400),
        );
      },
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _RevenueCard(
            totalSales: totalSales,
            invoiceCount: documents.length,
          ),

          const SizedBox(height: 18),

          const Text(
            'Sales Overview',
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
            childAspectRatio: 1.55,
            children: [
              _ReportCard(
                title: 'Total Invoices',
                value: documents.length.toString(),
                icon: Icons.receipt_long_outlined,
                iconColor:
                StackFlowColors.primary,
              ),
              _ReportCard(
                title: 'Paid',
                value: paidInvoices.toString(),
                icon: Icons.check_circle_outline,
                iconColor:
                StackFlowColors.green,
              ),
              _ReportCard(
                title: 'Unpaid',
                value: unpaidInvoices.toString(),
                icon: Icons.pending_outlined,
                iconColor:
                StackFlowColors.orange,
              ),
              _ReportCard(
                title: 'Items Sold',
                value: totalItemsSold.toString(),
                icon: Icons.inventory_2_outlined,
                iconColor:
                StackFlowColors.blue,
              ),
            ],
          ),

          const SizedBox(height: 22),

          const Text(
            'Financial Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: StackFlowColors.text,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(14),
              border: Border.all(
                color: StackFlowColors.border,
              ),
            ),
            child: Column(
              children: [
                _SummaryRow(
                  title: 'Subtotal',
                  value: _currency(
                    totalSubtotal,
                  ),
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  title: 'Discount',
                  value: _currency(
                    totalDiscount,
                  ),
                  valueColor:
                  StackFlowColors.orange,
                ),
                const SizedBox(height: 12),
                _SummaryRow(
                  title: 'Tax',
                  value: _currency(
                    totalTax,
                  ),
                ),
                const Divider(
                  height: 24,
                ),
                _SummaryRow(
                  title: 'Total Sales',
                  value: _currency(
                    totalSales,
                  ),
                  bold: true,
                  valueColor:
                  StackFlowColors.primary,
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Recent Sales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: StackFlowColors.text,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.invoices,
                  );
                },
                child: const Text(
                  'View All',
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ...documents
              .take(5)
              .map(
                (document) => _RecentInvoiceCard(
              document: document,
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static String _currency(double value) {
    return '₹ ${value.toStringAsFixed(2)}';
  }
}

class _RevenueCard extends StatelessWidget {
  final double totalSales;
  final int invoiceCount;

  const _RevenueCard({
    required this.totalSales,
    required this.invoiceCount,
  });

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
        borderRadius:
        BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Revenue',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '₹ ${totalSales.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$invoiceCount invoice'
                      '${invoiceCount == 1 ? '' : 's'} recorded',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius:
              BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.bar_chart_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _ReportCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius:
              BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: StackFlowColors
                        .secondaryText,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color:
                    StackFlowColors.text,
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: bold ? 14 : 12,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: StackFlowColors.text,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 12,
            fontWeight: bold
                ? FontWeight.bold
                : FontWeight.w600,
            color: valueColor ??
                StackFlowColors.text,
          ),
        ),
      ],
    );
  }
}

class _RecentInvoiceCard
    extends StatelessWidget {
  final QueryDocumentSnapshot<
      Map<String, dynamic>> document;

  const _RecentInvoiceCard({
    required this.document,
  });

  String _dateText(dynamic value) {
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
    (data['invoiceNumber'] ??
        'Invoice')
        .toString();

    final status =
    (data['paymentStatus'] ??
        'Paid')
        .toString();

    final total =
    ((data['total'] ?? 0) as num)
        .toDouble();

    final items =
        (data['items'] as List?) ?? [];

    final isPaid =
        status.toLowerCase() == 'paid';

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                _InvoiceDetailsRoute(
                  invoiceId: document.id,
                ),
          ),
        );
      },
      borderRadius:
      BorderRadius.circular(14),
      child: Container(
        margin:
        const EdgeInsets.only(bottom: 10),
        padding:
        const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(14),
          border: Border.all(
            color: StackFlowColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: StackFlowColors.primary
                    .withOpacity(0.10),
                borderRadius:
                BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color:
                StackFlowColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    invoiceNumber,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_dateText(data['createdAt'])} • '
                        '${items.length} item'
                        '${items.length == 1 ? '' : 's'}',
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
            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  '₹ ${total.toStringAsFixed(2)}',
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Small route wrapper so Reports can open
/// the existing InvoiceDetailsScreen without
/// exposing implementation details.
class _InvoiceDetailsRoute
    extends StatelessWidget {
  final String invoiceId;

  const _InvoiceDetailsRoute({
    required this.invoiceId,
  });

  @override
  Widget build(BuildContext context) {
    return InvoiceDetailsScreen(
      invoiceId: invoiceId,
    );
  }
}

class _EmptyReports extends StatelessWidget {
  const _EmptyReports();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 50),
        Container(
          width: 80,
          height: 80,
          margin:
          const EdgeInsets.symmetric(
            horizontal: 100,
          ),
          decoration: BoxDecoration(
            color: StackFlowColors.primary
                .withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bar_chart_outlined,
            size: 38,
            color: StackFlowColors.primary,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'No sales data yet',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Create your first bill and your sales '
              'reports will appear here automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: StackFlowColors.secondaryText,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
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
            const Icon(
              Icons.error_outline,
              size: 48,
              color: StackFlowColors.orange,
            ),
            const SizedBox(height: 12),
            const Text(
              'Reports unavailable',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
          ],
        ),
      ),
    );
  }
}