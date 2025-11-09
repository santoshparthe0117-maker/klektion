import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klektion/screens/features/items/models/items_model.dart';
import 'package:klektion/utils/color_constants.dart';

import '../controllers/items_controller.dart';

class AddItemScreen extends StatefulWidget {
  final ItemModel? item;
  const AddItemScreen({super.key, this.item});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final ItemController _itemController = Get.put(ItemController());

  final nameCtrl = TextEditingController();

  final descCtrl = TextEditingController();

  final priceCtrl = TextEditingController();

  final valueCtrl = TextEditingController();

  final RxString selectedCategory = ''.obs;

  final RxString selectedCollection = ''.obs;

  final RxString selectedPrivacy = 'Private'.obs;

  final goldGradient = const LinearGradient(
    colors: [Color(0xFFFFE29F), Color(0xFFD4AF37), Color(0xFFB08A0B)],
  );

  List<XFile> images = [];

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      print(widget.item?.toString());
      nameCtrl.text = widget.item!.name;
      descCtrl.text = widget.item!.description ?? '';
      priceCtrl.text = widget.item!.purchasePrice?.toString() ?? '';
      valueCtrl.text = widget.item!.estimatedValue?.toString() ?? '';
    }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Photos", style: TextStyle(color: Colors.white)),
            const SizedBox(height: 8),

            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    images = await _itemController.pickImage();

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.white24,
                        style: BorderStyle.solid,
                        width: 1,
                      ),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white70),
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

            const SizedBox(height: 16),

            _input("Item Name", "e.g., Rolex Submariner", nameCtrl),
            _dropdown("Category", ["Watch", "Comic", "Art"], selectedCategory),
            _dropdown("Add to Collection", [
              "Luxury Watches",
              "Rare Comics",
            ], selectedCollection),
            _currencyField("Purchase Price", priceCtrl),
            _currencyField("Current Value", valueCtrl),
            _dropdown("Privacy", ["Private", "Public"], selectedPrivacy),

            const SizedBox(height: 12),
            _textArea("Description", descCtrl),

            const SizedBox(height: 18),

            Obx(
              () => GestureDetector(
                onTap: _itemController.isLoading.value
                    ? null
                    : () async {
                        _itemController.isLoading.value = true;
                        List<String> imageUrls = await _itemController
                            .uploadImages(images);
                        if (imageUrls.isEmpty) {
                          _itemController.isLoading.value = false;
                          Get.snackbar("Error", "Failed to upload images");
                          return;
                        }
                        bool result = await _itemController.addItem(
                          name: nameCtrl.text.trim(),
                          collectionId:
                              "5a98cb59-54b5-49d9-af4f-4a06e9b36363", // TODO: dynamic later
                          categoryId: 'add6f410-21c9-4980-8a52-9873bc9c36b6',
                          purchasePrice: double.tryParse(priceCtrl.text),
                          estimatedValue: double.tryParse(valueCtrl.text),
                          description: descCtrl.text.trim(),
                          visibility: selectedPrivacy.value.toLowerCase(),
                          imageUrls: imageUrls,
                        );

                        if (result) {
                          Get.closeAllSnackbars();
                          Get.back(result: true);
                          Get.snackbar("Success", "Item added to collection");
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
    );
  }

  Widget _dropdown(String label, List<String> list, RxString value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        Obx(
          () => DropdownButtonFormField(
            dropdownColor: const Color(0xFF1C2B22),
            value: value.value.isEmpty ? null : value.value,
            onChanged: (v) => value.value = v.toString(),
            items: list
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(e, style: const TextStyle(color: Colors.white)),
                  ),
                )
                .toList(),
            decoration: _fieldDecoration(),
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
        TextField(
          controller: c,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(hint: hint),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _textArea(String label, TextEditingController c) {
    return _input(label, "", c);
  }

  Widget _currencyField(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: _fieldDecoration(
            prefix: Text("\$ ", style: TextStyle(color: Colors.white)),
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
