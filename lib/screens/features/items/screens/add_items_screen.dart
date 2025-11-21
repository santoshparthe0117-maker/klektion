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
  final String? collectionId;
  const AddItemScreen({super.key, this.item, this.collectionId});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  // controllers (assumed to exist in your app)
  final CollectionController _collectionController =
      Get.find<CollectionController>();
  final ItemController _itemController = Get.put(ItemController());
  final ImageController _imageController = Get.find<ImageController>();
  final CategoryController _categoryController = Get.find<CategoryController>();
  final picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();

  // text controllers
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController shortDescCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController valueCtrl = TextEditingController();

  // dropdown selected ids (use String ids to avoid Dropdown duplicate/value issues)
  String? selectedCategoryId;
  String? selectedCollectionId;
  String selectedPrivacy = 'private';

  // images management
  List<XFile> newImages = []; // newly picked files
  List<String> oldImageUrls = []; // existing uploaded image urls (for edit)
  List<String> removedOldImageUrls =
      []; // old urls user removed (we'll delete from DB)

  bool isLoadingLocal = true; // for initial data load
  bool isEditMode = false;
  bool isCollectionLocked = false;

  final goldGradient = const LinearGradient(
    colors: [Color(0xFFB08A0B), Color(0xFFD4AF37), Color(0xFFFFE29F)],
  );

  final List<Map<String, String>> privacyList = [
    {'name': 'Private', 'id': 'private'},
    {'name': 'Friends only', 'id': 'friends'},
    {'name': 'Public', 'id': 'public'},
  ];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    // load collections/categories (if not already loaded)

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _collectionController.getCollections();
    });

    await _category_controllerSafeFetch();
    // set initial values if editing
    if (widget.item != null) {
      isEditMode = true;
      final item = widget.item!;
      nameCtrl.text = item.name;
      descCtrl.text = item.description ?? '';
      shortDescCtrl.text =
          (item as dynamic).shortDescription ?? ''; // if field exists
      priceCtrl.text = item.purchasePrice?.toString() ?? '';
      valueCtrl.text = item.estimatedValue?.toString() ?? '';
      selectedCategoryId = item.categoryId;
      selectedCollectionId = item.collectionId;
      selectedPrivacy = item.visibility ?? 'private';
      // keep old images as URL list
      oldImageUrls = List<String>.from(item.images);
    }
    if (widget.collectionId != null) {
      setState(() {
        isCollectionLocked = true; // 🔒 LOCK THE DROPDOWN
      });
      selectedCollectionId = widget.collectionId;
    }
    setState(() {
      isLoadingLocal = false;
    });
  }

  Future<void> _category_controllerSafeFetch() async {
    try {
      await _category_controllerCall();
    } catch (_) {
      // swallow, lists might be already present
    }
  }

  Future<void> _category_controllerCall() async {
    await _categoryController.fetchCategories();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    shortDescCtrl.dispose();
    descCtrl.dispose();
    priceCtrl.dispose();
    valueCtrl.dispose();
    super.dispose();
  }

  // -----------------------------------------------------------
  // UI
  // -----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        backgroundColor: AppColors.themeColor,
        elevation: 0,
        title: Text(
          isEditMode ? 'Edit Item' : 'Add Item',
          style: const TextStyle(color: AppColors.primaryColor),
        ),
        leading: BackButton(color: AppColors.primaryColor),
      ),
      body: isLoadingLocal
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Photos", style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    _buildImagesRow(),

                    const SizedBox(height: 16),
                    _input("Item Name", "e.g., Rolex Submariner", nameCtrl),
                    _dropdownWithId(
                      label: "Category",
                      items: _categoryController.categories
                          .map((c) => {'name': c.name, 'id': c.categoryId})
                          .toList(),
                      value: selectedCategoryId,
                      onChanged: (v) => setState(() => selectedCategoryId = v),
                    ),
                    _dropdownWithId(
                      label: "Add to Collection",
                      isCollectionLocked: isCollectionLocked,
                      items: _collectionController.collections
                          .map((c) => {'name': c.name, 'id': c.collectionId})
                          .toList(),
                      value: selectedCollectionId,
                      onChanged: (v) =>
                          setState(() => selectedCollectionId = v),
                    ),
                    _currencyField("Purchase Price", priceCtrl),
                    _currencyField("Current Value", valueCtrl),
                    _dropdownWithId(
                      label: "Privacy",
                      items: privacyList
                          .map((p) => {'name': p['name']!, 'id': p['id']!})
                          .toList(),
                      value: selectedPrivacy,
                      onChanged: (v) =>
                          setState(() => selectedPrivacy = v ?? 'private'),
                      isRequired: false, // privacy optional selection
                    ),
                    const SizedBox(height: 12),
                    _shortDescriptionField(
                      "Short Description (optional)",
                      shortDescCtrl,
                    ),
                    const SizedBox(height: 12),
                    _textArea("Description", descCtrl),
                    const SizedBox(height: 18),

                    Obx(() {
                      final loading = _itemController.isLoading.value;
                      return GestureDetector(
                        onTap: loading ? null : _handleSubmit,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            gradient: goldGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: loading
                                ? const CircularProgressIndicator(
                                    color: Colors.black,
                                  )
                                : Text(
                                    isEditMode
                                        ? "Update Item"
                                        : "Add to Collection",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
    );
  }

  // -----------------------------------------------------------
  // Widgets helpers
  // -----------------------------------------------------------

  Widget _buildImagesRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // add button
          GestureDetector(
            onTap: () async {
              // final picked = await _image_controllerPickMultiple();
              // if (picked != null && picked.isNotEmpty) {
              //   setState(() {
              //     newImages.addAll(picked);
              //   });
              // }
              _showImageSourceSheet();
            },
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 8),
          // existing uploaded images (network)
          ...oldImageUrls.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      url,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          removedOldImageUrls.add(url);
                          oldImageUrls.removeAt(index);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          // newly picked local files
          ...newImages.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      File(file.path),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          newImages.removeAt(index);
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey.shade800,
      alignment: Alignment.center,
      child: const Icon(Icons.image_not_supported, color: Colors.white38),
    );
  }

  Widget _dropdownWithId({
    required String label,
    required List<Map<String, dynamic>> items,
    required String? value,
    required Function(String?) onChanged,
    bool isRequired = true,
    bool? isCollectionLocked,
  }) {
    // Build items
    final dropdownItems = items.map((e) {
      final id = e['id']?.toString() ?? '';
      final name = e['name']?.toString() ?? '';

      return DropdownMenuItem<String>(
        value: id,
        child: SizedBox(
          width: double.infinity, // ⬅️ critical for long text
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }).toList();

    // Ensure valid value
    final valueExists = dropdownItems.any((d) => d.value == value);
    final effectiveValue = valueExists ? value : null;

    bool isDisabled = isCollectionLocked ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),

        // important: give dropdown full width using SizedBox
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            isExpanded: true, // ⬅️ expansion fix for long text
            dropdownColor: const Color(0xFF1C2B22),

            value: effectiveValue,
            onChanged: isDisabled ? null : onChanged,

            validator: (v) => (isRequired && (v == null || v.isEmpty))
                ? "Please select $label"
                : null,

            items: dropdownItems,
            decoration: _fieldDecoration(),

            // prevent text being overly padded
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          maxLines: 5,
          decoration: _fieldDecoration(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _shortDescriptionField(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextFormField(
          controller: c,
          maxLines: 3,
          minLines: 1,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

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

  // -----------------------------------------------------------
  // Actions: pick/upload/submit
  // -----------------------------------------------------------

  Future<List<XFile>?> _image_controllerPickMultiple() async {
    try {
      return await _imageController.pickMultipleImages();
    } catch (e) {
      Get.snackbar("Error", "Image pick failed: $e");
      return null;
    }
  }

  Future<XFile?> _pickFromCamera() async {
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      return image;
    } catch (e) {
      Get.snackbar("Error", "Camera failed: $e");
      return null;
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Camera"),
                onTap: () async {
                  Navigator.pop(context);
                  final photo = await _pickFromCamera();
                  if (photo != null) {
                    setState(() => newImages.add(photo));
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Gallery"),
                onTap: () async {
                  Navigator.pop(context);
                  final picked = await _image_controllerPickMultiple();
                  if (picked != null && picked.isNotEmpty) {
                    setState(() => newImages.addAll(picked));
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // 🔍 Image validation rules
    if (!isEditMode && newImages.isEmpty) {
      Get.snackbar("Error", "Please select at least 1 image");
      return;
    }
    if (isEditMode && newImages.isEmpty && oldImageUrls.isEmpty) {
      Get.snackbar("Error", "Please have at least 1 image");
      return;
    }

    _itemController.isLoading.value = true;

    try {
      // -----------------------------------------------------
      // 1) Upload newly added images
      // -----------------------------------------------------
      List<String> uploadedUrls = [];

      if (newImages.isNotEmpty) {
        uploadedUrls = await _imageController.uploadImages(
          newImages,
          AppConstants.itemImagesBucket,
        );

        if (uploadedUrls.isEmpty) {
          _itemController.isLoading.value = false;
          Get.snackbar("Error", "Image upload failed");
          return;
        }
      }

      // -----------------------------------------------------
      // 2) Prepare all form values
      // -----------------------------------------------------
      final name = nameCtrl.text.trim();
      final shortDesc = shortDescCtrl.text.trim();
      final description = descCtrl.text.trim();
      final purchasePrice = double.tryParse(priceCtrl.text);
      final estimatedValue = double.tryParse(valueCtrl.text);
      final visibility = selectedPrivacy.toLowerCase();
      final categoryId = selectedCategoryId;
      final collectionId = selectedCollectionId;

      // Combine old + newly uploaded urls
      final finalImageList = [...oldImageUrls, ...uploadedUrls];

      // -----------------------------------------------------
      // 3) ADD MODE
      // -----------------------------------------------------
      if (!isEditMode) {
        final success = await _itemController.addItem(
          name: name,
          collectionId: collectionId ?? '',
          categoryId: categoryId,
          purchasePrice: purchasePrice,
          estimatedValue: estimatedValue,
          description: description,
          visibility: visibility,
          acquisitionDate: null,
          condition: null,
          imageUrls: finalImageList,
          shortDesciption: shortDesc,
        );

        if (success) {
          Get.back(result: true);
          Get.snackbar("Success", "Item added successfully");
          _itemController.getRecentItems();
        } else {
          Get.snackbar("Error", "Failed to add item");
        }

        return;
      }

      // -----------------------------------------------------
      // 4) EDIT MODE → Use Controller.updateItem()
      // -----------------------------------------------------
      final itemId = widget.item!.itemId;

      final updated = await _itemController.updateItem(
        itemId: itemId,
        name: name,
        collectionId: collectionId ?? '',
        categoryId: categoryId,
        purchasePrice: purchasePrice,
        estimatedValue: estimatedValue,
        description: description,
        shortDesciption: shortDesc,
        visibility: visibility,
        acquisitionDate: null,
        condition: null,

        // 👇 pass final + removed list
        finalImageUrls: finalImageList,
        removedOldImageUrls: removedOldImageUrls,
      );

      if (updated) {
        // remove deleted images from DB

        Get.back(result: true);
        Get.snackbar("Success", "Item updated successfully");
      } else {
        Get.snackbar("Error", "Failed to update item");
      }
    } catch (e) {
      Get.snackbar("Error", "Operation failed: $e");
    } finally {
      _itemController.isLoading.value = false;
    }
  }
}
