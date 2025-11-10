import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klektion/controllers/image_controller.dart';
import 'package:klektion/screens/features/account/controllers/categories_controller.dart';
import 'package:klektion/screens/features/account/models/category_model.dart';
import 'package:klektion/screens/features/collections/controllers/collections_controller.dart';
import 'package:klektion/screens/features/collections/models/collection_model.dart';
import 'package:klektion/screens/features/items/models/items_model.dart';
import 'package:klektion/utils/color_constants.dart';
import 'package:klektion/utils/constants.dart';

import '../controllers/items_controller.dart';

class AddItemScreen extends StatefulWidget {
  final ItemModel? item;
  const AddItemScreen({super.key, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final CollectionController _collectionController =
      Get.find<CollectionController>();
  final ItemController _itemController = Get.put(ItemController());
  final ImageController _imageController = ImageController();
  final CategoryController _categoryController = Get.find<CategoryController>();

  final _formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final valueCtrl = TextEditingController();

  CategoryModel? selectedCategory;
  CollectionModel? selectedCollection;
  String selectedPrivacy = 'Private';
  bool isLoading = true;

  final goldGradient = const LinearGradient(
    colors: [Color(0xFFB08A0B), Color(0xFFD4AF37), Color(0xFFFFE29F)],
  );

  List<XFile> images = [];

  List<Map<String, dynamic>> privacyList = [
    {"name": "Private", "id": "private"},
    {"name": "Friends only", "id": "Friends only"},
    {"name": "Public", "id": "public"},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      nameCtrl.text = widget.item!.name;
      descCtrl.text = widget.item!.description ?? '';
      priceCtrl.text = widget.item!.purchasePrice?.toString() ?? '';
      valueCtrl.text = widget.item!.estimatedValue?.toString() ?? '';
      selectedCategory = _categoryController.categories.firstWhere(
        (c) => c.categoryId == widget.item!.categoryId,
      );
      selectedCollection = _collectionController.collections.firstWhere(
        (c) => c.collectionId == widget.item!.collectionId,
      );
      selectedPrivacy = widget.item!.visibility == 'public'
          ? 'Public'
          : 'Private';
      images = widget.item!.images.map((e) => XFile(e)).toList();
    }
    initData();
  }

  initData() async {
    await _collectionController.getCollections();
    await _categoryController.fetchCategories();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        elevation: 0,
        title: const Text("Add Item", style: TextStyle(color: Colors.white)),
        leading: BackButton(color: Colors.white),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Photos", style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        images = await _imageController.pickMultipleImages();
                        if (mounted) setState(() {});
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24, width: 1),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    ...images.map(
                      (file) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            File(file.path),
                            width: 70,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              _input("Item Name", "e.g., Rolex Submariner", nameCtrl),
              _dropdown(
                "Category",
                _categoryController.categories
                    .map((c) => {'name': c.name, 'id': c.categoryId})
                    .toList(),
                (v) => selectedCategory = _categoryController.categories
                    .firstWhere((c) => c.categoryId == v['id']),
                selectedCategory != null
                    ? {
                        'name': selectedCategory?.name,
                        'id': selectedCategory?.categoryId,
                      }
                    : null,
              ),
              _dropdown(
                "Add to Collection",
                _collectionController.collections
                    .map((c) => {'name': c.name, 'id': c.collectionId})
                    .toList(),
                (v) => selectedCollection = _collectionController.collections
                    .firstWhere((c) => c.collectionId == v['id']),
                selectedCollection != null
                    ? {
                        'name': selectedCollection?.name,
                        'id': selectedCollection?.collectionId,
                      }
                    : null,
              ),

              _currencyField("Purchase Price", priceCtrl),
              _currencyField("Current Value", valueCtrl),

              _dropdown(
                "Privacy",
                privacyList,
                (v) => selectedPrivacy = v['name'],
                privacyList.firstWhere((p) => p['name'] == selectedPrivacy),
              ),
              const SizedBox(height: 12),
              _textArea("Description", descCtrl),

              const SizedBox(height: 18),

              Obx(
                () => GestureDetector(
                  onTap: _itemController.isLoading.value
                      ? null
                      : () async {
                          // ✅ FORM VALIDATION
                          if (!_formKey.currentState!.validate()) {
                            // Get.snackbar("Error", "Please fix the errors");
                            return;
                          }

                          // ✅ IMAGE VALIDATION
                          if (images.isEmpty) {
                            Get.snackbar(
                              "Error",
                              "Please upload at least one image",
                            );
                            return;
                          }

                          _itemController.isLoading.value = true;

                          List<String> imageUrls = await _imageController
                              .uploadImages(
                                images,
                                AppConstants.itemImagesBucket,
                              );

                          if (imageUrls.isEmpty) {
                            _itemController.isLoading.value = false;
                            Get.snackbar("Error", "Image upload failed");
                            return;
                          }

                          bool result = await _itemController.addItem(
                            name: nameCtrl.text.trim(),
                            collectionId:
                                selectedCollection?.collectionId ?? '',
                            // "5a98cb59-54b5-49d9-af4f-4a06e9b36363", // TODO: dynamic later
                            categoryId: selectedCategory?.categoryId ?? '',
                            // 'add6f410-21c9-4980-8a52-9873bc9c36b6',
                            purchasePrice: double.tryParse(priceCtrl.text),
                            estimatedValue: double.tryParse(valueCtrl.text),
                            description: descCtrl.text.trim(),
                            visibility: selectedPrivacy.toLowerCase(),
                            imageUrls: imageUrls,
                          );

                          if (result) {
                            Get.back(result: true);
                            Get.snackbar("Success", "Item added successfully");
                          } else {
                            Get.snackbar("Error", "Failed to add item");
                          }
                        },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: goldGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: _itemController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Add to Collection",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ VALIDATED DROPDOWN
  Widget _dropdown(
    String label,
    List<Map<String, dynamic>> list,
    Function(dynamic) onChanged,
    dynamic value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        DropdownButtonFormField(
          dropdownColor: const Color(0xFF1C2B22),
          value: value,
          onChanged: onChanged,
          validator: (v) => v == null ? "Please select $label" : null,
          items: list
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(
                    e['name'],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
          decoration: _fieldDecoration(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // ✅ INPUT WITH VALIDATOR
  Widget _input(String label, String hint, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          validator: (v) => v!.trim().isEmpty ? "$label is required" : null,
          decoration: _fieldDecoration(hint: hint),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _textArea(String label, TextEditingController c) {
    return _input(label, "", c);
  }

  // ✅ NUMERIC VALIDATION ADDED
  Widget _currencyField(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return "$label is required";
            }
            if (double.tryParse(v) == null) {
              return "Enter a valid number";
            }
            return null;
          },
          decoration: _fieldDecoration(
            prefix: const Text("\$ ", style: TextStyle(color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  InputDecoration _fieldDecoration({String? hint, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: const Color(0xFF1C2B22),
      prefixIcon: prefix == null
          ? null
          : Padding(padding: const EdgeInsets.only(left: 8), child: prefix),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
