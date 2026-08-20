import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final sellingController = TextEditingController();
  final costController = TextEditingController();
  final stockController = TextEditingController();
  final lowStockController =
  TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? selectedImage;

  String? category;

  bool saving = false;

  final categories = const [
    'Electronics',
    'Stationery',
    'Grocery',
    'Other',
  ];

  @override
  void dispose() {
    nameController.dispose();
    sellingController.dispose();
    costController.dispose();
    stockController.dispose();
    lowStockController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> saveProduct() async {
    if (nameController.text.trim().isEmpty) {
      _showMessage('Enter product name.');
      return;
    }

    if (category == null) {
      _showMessage('Select a category.');
      return;
    }

    final selling =
        double.tryParse(
          sellingController.text.trim(),
        ) ??
            0;

    final cost =
        double.tryParse(
          costController.text.trim(),
        ) ??
            0;

    final stock =
        int.tryParse(
          stockController.text.trim(),
        ) ??
            0;

    final lowStock =
        int.tryParse(
          lowStockController.text.trim(),
        ) ??
            10;

    setState(() {
      saving = true;
    });

    try {
      final product = Product(
        id: '',
        name: nameController.text.trim(),
        category: category!,
        sellingPrice: selling,
        costPrice: cost,
        stock: stock,
        lowStockAlert: lowStock,
      );

      final provider =
      context.read<ProductProvider>();

      await provider.addProduct(product);

      if (!mounted) return;

      setState(() {
        saving = false;
      });

      _showMessage('Product saved successfully.');

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        saving = false;
      });

      _showMessage(
        'Could not save product.',
      );
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Add Product',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 145,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFFAF8),
                  borderRadius:
                  BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFCDEDEA),
                  ),
                ),
                child: selectedImage == null
                    ? const Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .add_photo_alternate_outlined,
                      color:
                      StackFlowColors.primary,
                      size: 32,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Upload Product Image',
                      style: TextStyle(
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'JPG, PNG up to 2MB',
                      style: TextStyle(
                        color:
                        StackFlowColors
                            .secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                )
                    : ClipRRect(
                  borderRadius:
                  BorderRadius.circular(14),
                  child: Image.file(
                    selectedImage!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            AppTextField(
              controller: nameController,
              hint: 'Enter product name',
              label: 'Product Name',
            ),

            const SizedBox(height: 15),

            const Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 7),

            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(
                hintText: 'Select category',
              ),
              items: categories.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  category = value;
                });
              },
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller:
                    sellingController,
                    hint: 'Enter selling price',
                    label: 'Selling Price (₹)',
                    keyboardType:
                    TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: costController,
                    hint: 'Enter cost price',
                    label: 'Cost Price (₹)',
                    keyboardType:
                    TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            AppTextField(
              controller: stockController,
              hint: 'Enter stock quantity',
              label: 'Stock Quantity',
              keyboardType:
              TextInputType.number,
            ),

            const SizedBox(height: 15),

            AppTextField(
              controller: lowStockController,
              hint: 'Enter low stock alert',
              label: 'Low Stock Alert',
              keyboardType:
              TextInputType.number,
            ),

            const SizedBox(height: 25),

            AppButton(
              text: 'Save Product',
              loading: saving,
              icon: Icons.save_outlined,
              onPressed: saveProduct,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}