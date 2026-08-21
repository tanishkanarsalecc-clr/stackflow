import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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

class InvoiceDetailsScreen extends StatefulWidget {
  final String invoiceId;

  const InvoiceDetailsScreen({
    super.key,
    required this.invoiceId,
  });

  @override
  State<InvoiceDetailsScreen> createState() =>
      _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState
    extends State<InvoiceDetailsScreen> {
  bool _pdfBusy = false;

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

  // =============================================================
  // SHOW PDF OPTIONS
  // =============================================================

  Future<void> _showPdfOptions(
      BuildContext context,
      Map<String, dynamic> data,
      ) async {
    if (_pdfBusy) {
      return;
    }

    final invoiceNumber =
    (data['invoiceNumber'] ?? 'invoice').toString();

    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'Invoice PDF',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  invoiceNumber,
                  style: const TextStyle(
                    color:
                    StackFlowColors.secondaryText,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 18),

                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: StackFlowColors.primary
                          .withValues(alpha: 0.10),
                      borderRadius:
                      BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.print_outlined,
                      color:
                      StackFlowColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Print / Save as PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Open the system print screen',
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      'print',
                    );
                  },
                ),

                const SizedBox(height: 5),

                ListTile(
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: StackFlowColors.green
                          .withValues(alpha: 0.10),
                      borderRadius:
                      BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color:
                      StackFlowColors.green,
                    ),
                  ),
                  title: const Text(
                    'Share PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Save or send the invoice file',
                  ),
                  onTap: () {
                    Navigator.pop(
                      sheetContext,
                      'share',
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || action == null) {
      return;
    }

    setState(() {
      _pdfBusy = true;
    });

    try {
      final bytes = await _generateInvoicePdf(
        data,
        PdfPageFormat.a4,
      );

      final safeFileName =
      invoiceNumber
          .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');

      if (action == 'print') {
        await Printing.layoutPdf(
          name: '$safeFileName.pdf',
          onLayout: (format) {
            return _generateInvoicePdf(
              data,
              format,
            );
          },
        );
      } else {
        await Printing.sharePdf(
          bytes: bytes,
          filename: '$safeFileName.pdf',
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Invoice PDF error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Could not create invoice PDF: $e',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _pdfBusy = false;
        });
      }
    }
  }

  // =============================================================
  // GENERATE PDF
  // =============================================================

  Future<Uint8List> _generateInvoicePdf(
      Map<String, dynamic> data,
      PdfPageFormat format,
      ) async {
    final pdf = pw.Document();

    final invoiceNumber =
    (data['invoiceNumber'] ?? 'Invoice').toString();

    final status =
    (data['paymentStatus'] ?? 'Paid').toString();

    final subtotal =
    ((data['subtotal'] ?? 0) as num).toDouble();

    final discount =
    ((data['discount'] ?? 0) as num).toDouble();

    final tax =
    ((data['tax'] ?? 0) as num).toDouble();

    final total =
    ((data['total'] ?? 0) as num).toDouble();

    final items =
        (data['items'] as List?) ?? [];

    final date =
    _formatDate(data['createdAt']);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // ===================================================
            // HEADER
            // ===================================================

            pw.Row(
              mainAxisAlignment:
              pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'StackFlow',
                      style: pw.TextStyle(
                        fontSize: 25,
                        fontWeight:
                        pw.FontWeight.bold,
                        color: PdfColors.blue800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Inventory & Billing System',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color:
                        PdfColors.grey600,
                      ),
                    ),
                  ],
                ),

                pw.Column(
                  crossAxisAlignment:
                  pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight:
                        pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      invoiceNumber,
                      style: const pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      date,
                      style: const pw.TextStyle(
                        fontSize: 9,
                        color:
                        PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            pw.SizedBox(height: 22),

            pw.Divider(
              color: PdfColors.grey300,
            ),

            pw.SizedBox(height: 16),

            // ===================================================
            // STATUS
            // ===================================================

            pw.Row(
              children: [
                pw.Text(
                  'Payment Status: ',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight:
                    pw.FontWeight.bold,
                  ),
                ),
                pw.Container(
                  padding:
                  const pw.EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: status.toLowerCase() ==
                        'paid'
                        ? PdfColors.green100
                        : PdfColors.orange100,
                    borderRadius:
                    pw.BorderRadius.circular(10),
                  ),
                  child: pw.Text(
                    status,
                    style: pw.TextStyle(
                      fontSize: 9,
                      color:
                      status.toLowerCase() ==
                          'paid'
                          ? PdfColors.green800
                          : PdfColors.orange800,
                      fontWeight:
                      pw.FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 22),

            // ===================================================
            // ITEMS TABLE
            // ===================================================

            pw.Text(
              'Items',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight:
                pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 9),

            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColors.grey300,
                width: 0.6,
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(4),
                1: const pw.FlexColumnWidth(1.2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                pw.TableRow(
                  decoration:
                  const pw.BoxDecoration(
                    color: PdfColors.grey100,
                  ),
                  children: [
                    _pdfCell(
                      'Product',
                      bold: true,
                    ),
                    _pdfCell(
                      'Qty',
                      bold: true,
                      align:
                      pw.TextAlign.center,
                    ),
                    _pdfCell(
                      'Price',
                      bold: true,
                      align:
                      pw.TextAlign.right,
                    ),
                    _pdfCell(
                      'Total',
                      bold: true,
                      align:
                      pw.TextAlign.right,
                    ),
                  ],
                ),

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
                    ((itemMap['quantity'] ?? 1)
                    as num)
                        .toDouble();

                    final itemTotal =
                    ((itemMap['total'] ?? 0)
                    as num)
                        .toDouble();

                    return pw.TableRow(
                      children: [
                        _pdfCell(name),
                        _pdfCell(
                          quantity % 1 == 0
                              ? quantity
                              .toInt()
                              .toString()
                              : quantity
                              .toString(),
                          align:
                          pw.TextAlign.center,
                        ),
                        _pdfCell(
                          formatCurrency(price),
                          align:
                          pw.TextAlign.right,
                        ),
                        _pdfCell(
                          formatCurrency(itemTotal),
                          align:
                          pw.TextAlign.right,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            pw.SizedBox(height: 20),

            // ===================================================
            // TOTALS
            // ===================================================

            pw.Align(
              alignment:
              pw.Alignment.centerRight,
              child: pw.Container(
                width: 260,
                padding:
                const pw.EdgeInsets.all(14),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(
                    color: PdfColors.grey300,
                  ),
                  borderRadius:
                  pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  children: [
                    _pdfTotalRow(
                      'Subtotal',
                      formatCurrency(subtotal),
                    ),

                    pw.SizedBox(height: 7),

                    _pdfTotalRow(
                      'Discount',
                      discount > 0
                          ? '-${formatCurrency(discount)}'
                          : formatCurrency(0),
                    ),

                    pw.SizedBox(height: 7),

                    _pdfTotalRow(
                      'Tax',
                      formatCurrency(tax),
                    ),

                    pw.SizedBox(height: 8),

                    pw.Divider(
                      color: PdfColors.grey300,
                    ),

                    pw.SizedBox(height: 5),

                    _pdfTotalRow(
                      'Total',
                      formatCurrency(total),
                      bold: true,
                    ),
                  ],
                ),
              ),
            ),

            pw.SizedBox(height: 30),

            // ===================================================
            // FOOTER
            // ===================================================

            pw.Center(
              child: pw.Text(
                'Thank you for your business.',
                style: const pw.TextStyle(
                  fontSize: 10,
                  color: PdfColors.grey600,
                ),
              ),
            ),

            pw.SizedBox(height: 5),

            pw.Center(
              child: pw.Text(
                'Generated by StackFlow',
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey500,
                ),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  // =============================================================
  // PDF TABLE CELL
  // =============================================================

  pw.Widget _pdfCell(
      String text, {
        bool bold = false,
        pw.TextAlign align = pw.TextAlign.left,
      }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight:
          bold ? pw.FontWeight.bold : null,
        ),
      ),
    );
  }

  // =============================================================
  // PDF TOTAL ROW
  // =============================================================

  pw.Widget _pdfTotalRow(
      String title,
      String value, {
        bool bold = false,
      }) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: bold ? 11 : 9,
              fontWeight:
              bold ? pw.FontWeight.bold : null,
            ),
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: bold ? 12 : 9,
            fontWeight:
            bold ? pw.FontWeight.bold : null,
          ),
        ),
      ],
    );
  }

  // =============================================================
  // BUILD
  // =============================================================

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
            onPressed: _pdfBusy
                ? null
                : () async {
              final snapshot =
              await FirebaseService.getInvoice(
                widget.invoiceId,
              );

              if (!mounted) {
                return;
              }

              if (!snapshot.exists ||
                  snapshot.data() == null) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Invoice not found.',
                    ),
                  ),
                );
                return;
              }

              await _showPdfOptions(
                context,
                snapshot.data()!,
              );
            },
            icon: _pdfBusy
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(
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
          widget.invoiceId,
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
                            .withValues(
                          alpha: 0.10,
                        )
                            : StackFlowColors.orange
                            .withValues(
                          alpha: 0.10,
                        ),
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
                onPressed: _pdfBusy
                    ? null
                    : () async {
                  await _showPdfOptions(
                    context,
                    data,
                  );
                },
                icon: _pdfBusy
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(
                  Icons.print_outlined,
                  size: 20,
                ),
                label: Text(
                  _pdfBusy
                      ? 'Preparing Invoice...'
                      : 'Print Invoice',
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