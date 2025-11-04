import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../controllers/collections_controller.dart';

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final CategoryController controller = Get.put(CategoryController());

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isActive = true;

  Uint8List? _selectedImageBytes;

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedImageBytes = result.files.first.bytes;
        });
      }
    } else {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _selectedImageBytes = bytes);
      }
    }
  }

  void _removeImage() {
    setState(() => _selectedImageBytes = null);
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF4CAF50); // green shade

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Category',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Name
              const Text(
                'Category Name',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter category name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                ),
                validator: (v) => v!.isEmpty ? 'Please enter name' : null,
              ),
              const SizedBox(height: 20),

              // Description
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter category description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                ),
                validator: (v) =>
                    v!.isEmpty ? 'Please enter description' : null,
              ),
              const SizedBox(height: 20),

              // Image
              const Text(
                'Category Image',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF6FFF6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: themeColor.withOpacity(0.4),
                      style: BorderStyle.solid,
                      width: 1.5,
                    ),
                  ),
                  child: _selectedImageBytes == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: themeColor, size: 35),
                            const SizedBox(height: 8),
                            const Text('Tap to upload image'),
                            const Text(
                              'Recommended size: 512×512px',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            Center(
                              child: Image.memory(
                                _selectedImageBytes!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Category Status',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Switch(
                    value: _isActive,
                    activeColor: themeColor,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Save Button
              Obx(
                () => ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            bool isSuceess = await controller.addCategory(
                              // from your controller/session
                              categoryName: _nameController.text,
                              categoryDescription: _descController.text,
                              //   imageBytes: _selectedImageBytes!,
                            );

                            if (isSuceess) {
                              if (Get.isSnackbarOpen) {
                                Get.closeAllSnackbars();
                              }

                              Get.back();
                              Get.back();
                            } else {}
                          }
                        },
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Category',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 15),

              // Cancel Button
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: themeColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Get.back(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.green),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
