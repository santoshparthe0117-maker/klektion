import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageController {
  final picker = ImagePicker();
  final SupabaseClient supabase = Supabase.instance.client;
  Future pickImage() async {
    try {
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

  /// Upload multiple images to Supabase storage
  Future<List<String>> uploadImages(
    List<XFile> images,
    String bucketName,
  ) async {
    if (images.isEmpty) return [];

    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      List<String> uploadedUrls = [];

      for (int i = 0; i < images.length; i++) {
        final image = images[i];
        final fileName = await uploadSingleImage(image, bucketName);

        if (fileName != null) {
          final publicUrl = supabase.storage
              .from(bucketName)
              .getPublicUrl(fileName);
          uploadedUrls.add(publicUrl);
        }
      }

      return uploadedUrls;
    } catch (e) {
      print('Error uploading images: $e');
      Get.snackbar('Error', 'Failed to upload images: $e');
      return [];
    }
  }

  /// Upload single image file
  Future<String?> uploadSingleImage(XFile image, String bucketName) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      final bytes = await image.readAsBytes();
      final fileExt = path.extension(image.path).toLowerCase();
      final fileName =
          '${userId}/${DateTime.now().millisecondsSinceEpoch}$fileExt';

      // Get MIME type
      final mimeType = lookupMimeType(image.path) ?? 'image/jpeg';

      await supabase.storage
          .from(bucketName)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: FileOptions(contentType: mimeType, upsert: false),
          );

      return fileName;
    } catch (e) {
      print('Error uploading single image: $e');
      return null;
    }
  }

  /// Get all images for current user
  Future<List<Map<String, dynamic>>> getImages(
    List<String> publicUrls,
    String bucketName,
  ) async {
    try {
      // final userId = supabase.auth.currentUser?.id;
      // if (userId == null) return [];

      final response = await supabase.from(bucketName).select('*');
      // .in('public_url', publicUrls);
      // .order('uploaded_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching user images: $e');
      return [];
    }
  }
}
