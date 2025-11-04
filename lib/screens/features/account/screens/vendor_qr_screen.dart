import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../../utils/color_constants.dart';

class VendorQrScreen extends StatefulWidget {
  const VendorQrScreen({super.key});

  @override
  State<VendorQrScreen> createState() => _VendorQrScreenState();
}

class _VendorQrScreenState extends State<VendorQrScreen> {
  Map<String, dynamic>? vendor;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVendor();
  }

  Future<void> _loadVendor() async {
    try {
      final authController = Get.find<AuthController>();
      final user = authController.user;

      if (user == null || user.userId == null) {
        Get.snackbar(
          'Error',
          'User not logged in',
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
        );
        return;
      }

      final vendorData = await authController.getVendorByUserId(user.userId);

      setState(() {
        vendor = vendorData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red.shade50,
        colorText: Colors.red.shade800,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Vendor QR Code',
          style: TextStyle(color: Colors.white), // ✅ Title in white
        ),
        centerTitle: true,
        backgroundColor: AppColors.themeColor, // your theme color
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // ✅ Back button color
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : vendor == null
          ? const Center(
              child: Text(
                'No vendor found for this user',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                  shadowColor: AppColors.themeColor.withOpacity(0.4),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vendor!['vendor_name'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.themeColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: QrImageView(
                            data: vendor!['vendor_code'] ?? 'N/A',
                            version: QrVersions.auto,
                            size: 220,
                            gapless: false,
                            foregroundColor: AppColors.themeColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Vendor Code: ${vendor!['vendor_code']}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.themeColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            // Optional: Add share functionality
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.themeColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          icon: const Icon(Icons.share, color: Colors.white),
                          label: const Text(
                            'Share QR',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
