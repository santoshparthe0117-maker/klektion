import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  Future pickMultipleImages({int limit = 5}) async {
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

        // 🔥 COMPRESS IMAGE BEFORE UPLOADING
        final compressedBytes = await FlutterImageCompress.compressWithFile(
          image.path,
          quality: 60, // lower = more compression
          minWidth: 1080,
          minHeight: 1080,
          format: CompressFormat.jpeg,
        );

        if (compressedBytes == null) {
          print("Compression failed for: ${image.name}");
          continue;
        }

        // Create compressed file name
        final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

        // Upload compressed Bytes
        await supabase.storage
            .from(bucketName)
            .uploadBinary(
              fileName,
              compressedBytes,
              fileOptions: FileOptions(
                contentType: "image/jpeg",
                upsert: false,
              ),
            );

        // Get public URL
        final publicUrl = supabase.storage
            .from(bucketName)
            .getPublicUrl(fileName);

        uploadedUrls.add(publicUrl);
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

      // COMPRESS THE IMAGE 🔥
      final compressedBytes = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: 60, // Reduce this value to reduce size more
        minWidth: 1080,
        minHeight: 1080,
        format: CompressFormat.jpeg,
      );

      if (compressedBytes == null) {
        throw Exception('Image compression failed');
      }

      final fileExt = ".jpg"; // always upload as jpg
      final fileName =
          '$userId/${DateTime.now().millisecondsSinceEpoch}$fileExt';

      await supabase.storage
          .from(bucketName)
          .uploadBinary(
            fileName,
            compressedBytes,
            fileOptions: FileOptions(contentType: "image/jpeg", upsert: false),
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
