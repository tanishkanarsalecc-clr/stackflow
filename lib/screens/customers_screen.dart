import 'package:flutter/material.dart';

import '../core/helpers.dart';
import '../core/theme.dart';
import '../models/customer.dart';
import '../services/firebase_service.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() =>
      _CustomersScreenState();
}

class _CustomersScreenState
    extends State<CustomersScreen> {
  final searchController = TextEditingController();

  String search = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void openCustomerForm({
    Customer? customer,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return CustomerForm(
          customer: customer,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              openCustomerForm();
            },
            icon: const Icon(
              Icons.person_add_alt_1,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          openCustomerForm();
        },
        backgroundColor:
        StackFlowColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(
          Icons.add,
        ),
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
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  search =
                      value.trim().toLowerCase();
                });
              },
              decoration: const InputDecoration(
                hintText:
                'Search customer...',
                prefixIcon: Icon(
                  Icons.search,
                ),
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<List<Customer>>(
              stream:
              FirebaseService.customerStream(),
              builder: (
                  context,
                  snapshot,
                  ) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.all(20),
                      child: Text(
                        'Unable to load customers.\n\n'
                            '${snapshot.error}',
                        textAlign:
                        TextAlign.center,
                      ),
                    ),
                  );
                }

                final customers =
                    snapshot.data ?? [];

                final filtered =
                customers.where((customer) {
                  if (search.isEmpty) {
                    return true;
                  }

                  return customer.name
                      .toLowerCase()
                      .contains(search) ||
                      customer.phone
                          .toLowerCase()
                          .contains(search) ||
                      customer.email
                          .toLowerCase()
                          .contains(search);
                }).toList();

                if (filtered.isEmpty) {
                  return const _EmptyCustomers();
                }

                return ListView.builder(
                  padding:
                  const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    90,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (
                      context,
                      index,
                      ) {
                    return _CustomerCard(
                      customer: filtered[index],
                      onEdit: () {
                        openCustomerForm(
                          customer:
                          filtered[index],
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
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;

  const _CustomerCard({
    required this.customer,
    required this.onEdit,
  });

  Future<void> deleteCustomer(
      BuildContext context,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            'Delete Customer?',
          ),
          content: Text(
            'Delete ${customer.name}? '
                'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color:
                  StackFlowColors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await FirebaseService.deleteCustomer(
        customer.id,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Customer deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Delete failed: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasOutstanding =
        customer.outstanding > 0;

    return Container(
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
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: StackFlowColors.primary
                  .withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Text(
              customer.name.isEmpty
                  ? '?'
                  : customer.name[0]
                  .toUpperCase(),
              style: const TextStyle(
                color:
                StackFlowColors.primary,
                fontWeight:
                FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  customer.name,
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.w600,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: StackFlowColors
                          .secondaryText,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        customer.phone.isEmpty
                            ? 'No phone'
                            : customer.phone,
                        style:
                        const TextStyle(
                          color:
                          StackFlowColors
                              .secondaryText,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),

                if (customer.email.isNotEmpty)
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 3,
                    ),
                    child: Text(
                      customer.email,
                      style:
                      const TextStyle(
                        color:
                        StackFlowColors
                            .secondaryText,
                        fontSize: 10,
                      ),
                    ),
                  ),

                const SizedBox(height: 5),

                Text(
                  hasOutstanding
                      ? 'Due: ${formatCurrency(customer.outstanding)}'
                      : 'No outstanding balance',
                  style: TextStyle(
                    color: hasOutstanding
                        ? StackFlowColors.orange
                        : StackFlowColors.green,
                    fontWeight:
                    FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              }

              if (value == 'delete') {
                deleteCustomer(context);
              }
            },
            itemBuilder: (_) {
              return const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        size: 19,
                      ),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 19,
                        color:
                        StackFlowColors.red,
                      ),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}

class CustomerForm extends StatefulWidget {
  final Customer? customer;

  const CustomerForm({
    super.key,
    this.customer,
  });

  @override
  State<CustomerForm> createState() =>
      _CustomerFormState();
}

class _CustomerFormState
    extends State<CustomerForm> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController
  nameController;

  late final TextEditingController
  phoneController;

  late final TextEditingController
  emailController;

  late final TextEditingController
  addressController;

  late final TextEditingController
  outstandingController;

  bool saving = false;

  bool get isEditing =>
      widget.customer != null;

  @override
  void initState() {
    super.initState();

    final customer = widget.customer;

    nameController =
        TextEditingController(
          text: customer?.name ?? '',
        );

    phoneController =
        TextEditingController(
          text: customer?.phone ?? '',
        );

    emailController =
        TextEditingController(
          text: customer?.email ?? '',
        );

    addressController =
        TextEditingController(
          text: customer?.address ?? '',
        );

    outstandingController =
        TextEditingController(
          text: customer == null
              ? '0'
              : customer.outstanding
              .toString(),
        );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    outstandingController.dispose();

    super.dispose();
  }

  Future<void> saveCustomer() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      saving = true;
    });

    try {
      final outstanding =
          double.tryParse(
            outstandingController
                .text
                .trim(),
          ) ??
              0;

      final customer = Customer(
        id: widget.customer?.id ?? '',
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        address:
        addressController.text.trim(),
        outstanding: outstanding,
      );

      if (isEditing) {
        await FirebaseService
            .updateCustomer(
          customer,
        );
      } else {
        await FirebaseService
            .addCustomer(
          customer,
        );
      }

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Customer updated.'
                : 'Customer added.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
        ),
      );
    }
  }

  InputDecoration decoration(
      String hint,
      IconData icon,
      ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom =
        MediaQuery.of(context)
            .viewInsets
            .bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color:
                    StackFlowColors.border,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                isEditing
                    ? 'Edit Customer'
                    : 'Add Customer',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: nameController,
                textCapitalization:
                TextCapitalization.words,
                decoration: decoration(
                  'Customer name',
                  Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Enter customer name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 11),

              TextFormField(
                controller: phoneController,
                keyboardType:
                TextInputType.phone,
                decoration: decoration(
                  'Phone number',
                  Icons.phone_outlined,
                ),
              ),

              const SizedBox(height: 11),

              TextFormField(
                controller: emailController,
                keyboardType:
                TextInputType.emailAddress,
                decoration: decoration(
                  'Email address',
                  Icons.email_outlined,
                ),
              ),

              const SizedBox(height: 11),

              TextFormField(
                controller: addressController,
                maxLines: 2,
                decoration: decoration(
                  'Address',
                  Icons.location_on_outlined,
                ),
              ),

              const SizedBox(height: 11),

              TextFormField(
                controller:
                outstandingController,
                keyboardType:
                const TextInputType
                    .numberWithOptions(
                  decimal: true,
                ),
                decoration: decoration(
                  'Outstanding balance',
                  Icons.account_balance_wallet_outlined,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed:
                  saving ? null : saveCustomer,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    StackFlowColors.primary,
                    foregroundColor:
                    Colors.white,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(11),
                    ),
                  ),
                  child: saving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Text(
                    isEditing
                        ? 'Update Customer'
                        : 'Add Customer',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCustomers
    extends StatelessWidget {
  const _EmptyCustomers();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: StackFlowColors
                    .primary
                    .withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 34,
                color:
                StackFlowColors.primary,
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              'No customers found',
              style: TextStyle(
                fontSize: 16,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Add your first customer to '
                  'start managing customer records.',
              textAlign: TextAlign.center,
              style: TextStyle(
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