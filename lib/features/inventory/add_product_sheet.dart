import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../services/firestore_service.dart';

class AddProductSheet extends StatefulWidget {
  const AddProductSheet({super.key});

  @override
  State<AddProductSheet> createState() =>
      _AddProductSheetState();
}

class _AddProductSheetState
    extends State<AddProductSheet> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  final _service = FirestoreService();

  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _service.addProduct(
        name: _nameController.text,
        category: _categoryController.text,
        price: double.parse(_priceController.text),
        quantity: int.parse(_quantityController.text),
      );

      if (!mounted) return;

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product added successfully'),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save product'),
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
    return SafeArea(
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                AppTextField(
                  controller: _nameController,
                  label: 'Product Name',
                  prefixIcon: Icons.inventory_2_outlined,
                  validator: (value) =>
                      Validators.required(
                        value,
                        label: 'Product name',
                      ),
                ),

                const SizedBox(height: 14),

                AppTextField(
                  controller: _categoryController,
                  label: 'Category',
                  prefixIcon: Icons.category_outlined,
                ),

                const SizedBox(height: 14),

                AppTextField(
                  controller: _priceController,
                  label: 'Price',
                  prefixIcon: Icons.currency_rupee,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (value) =>
                      Validators.positiveNumber(
                        value,
                        label: 'price',
                      ),
                ),

                const SizedBox(height: 14),

                AppTextField(
                  controller: _quantityController,
                  label: 'Quantity',
                  prefixIcon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      Validators.positiveNumber(
                        value,
                        label: 'quantity',
                      ),
                ),

                const SizedBox(height: 24),

                AppButton(
                  text: 'Save Product',
                  loading: _loading,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}