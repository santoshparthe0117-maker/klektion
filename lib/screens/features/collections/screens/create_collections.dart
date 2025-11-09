import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klektion/controllers/image_controller.dart';
import 'package:klektion/utils/constants.dart';

import '../../../../utils/color_constants.dart';
import '../controllers/collections_controller.dart';

class CreateCollectionScreen extends StatefulWidget {
  const CreateCollectionScreen({super.key});

  @override
  State<CreateCollectionScreen> createState() => _CreateCollectionScreenState();
}

class _CreateCollectionScreenState extends State<CreateCollectionScreen> {
  final _formKey = GlobalKey<FormState>();
  final CollectionController controller = Get.find();
  final ImageController _imageController = ImageController();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? coverImage;
  String privacy = 'Public';

  Future<void> _saveCollection() async {
    if (!_formKey.currentState!.validate()) return;

    if (coverImage == null) {
      Get.snackbar(
        'Error',
        'Please upload a cover image',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    List<String> imageUrls = await _imageController.uploadImages([
      XFile(coverImage!.path),
    ], AppConstants.collectionImagesBucket);
    if (imageUrls.isEmpty) {
      Get.snackbar(
        'Error',
        'Failed to upload cover image',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }
    final success = await controller.addCollection(
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      privacy: privacy,
      coverImageUrl: imageUrls[0],
    );

    if (success) {
      Get.back();
      Get.snackbar(
        'Success',
        'Collection created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.snackbar(
        'Error',
        'Failed to create collection',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        title: const Text(
          'Create Collection',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.themeColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: () async {
                  var image = await _imageController.pickImage();
                  if (image != null) {
                    coverImage = File(image.path);
                  }
                  if (mounted) {
                    setState(() {});
                  }
                },
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2B25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: coverImage == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.upload, color: Colors.amber, size: 40),
                              Text(
                                "Upload cover image",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            coverImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Collection Name',
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter collection name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter description' : null,
              ),
              const SizedBox(height: 16),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Privacy',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 8),
              Column(
                children: ['Public', 'Friends Only', 'Private']
                    .map(
                      (option) => RadioListTile(
                        activeColor: Colors.amber,
                        tileColor: const Color(0xFF1B2B25),
                        value: option,
                        groupValue: privacy,
                        onChanged: (v) =>
                            setState(() => privacy = v.toString()),
                        title: Text(
                          option,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveCollection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "Create Collection",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
