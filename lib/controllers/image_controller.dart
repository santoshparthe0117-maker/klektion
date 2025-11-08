import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ImageController {
  Future pickImage() async {
    try {
      final picker = ImagePicker();
      // Use the older, more compatible method for multiple image selection
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      return image;
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar('Error', 'Failed to pick images: $e');
      return null;
    }
  }

  Future pickMultipleImages({int limit = 4}) async {
    try {
      final picker = ImagePicker();
      // Use the older, more compatible method for multiple image selection
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
        limit: limit,
      );

      return images;
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar('Error', 'Failed to pick images: $e');
      return null;
    }
  }
}
