import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/color_constants.dart';

// 🔹 Replace this with your own color class

// 🔹 Unique Vendor Code Generator
String generateUniqueCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final random = Random.secure();
  return List.generate(
    6,
    (index) => chars[random.nextInt(chars.length)],
  ).join();
}

class AddVendorScreen extends StatefulWidget {
  const AddVendorScreen({super.key});

  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final authController = Get.find<AuthController>();

  double? latitude;
  double? longitude;
  File? businessProofImage;

  bool isLoading = false;

  // 📍 Get current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Please enable location services');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Location permission denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Location permission permanently denied');
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  Future<void> pickBusinessProofImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        businessProofImage = File(image.path);
      });
    }
  }

  // 🧩 Insert vendor into Supabase
  Future<void> _addVendor() async {
    if (!_formKey.currentState!.validate()) return;

    // ✅ Check if location is selected
    if (latitude == null || longitude == null) {
      Get.snackbar('Error', 'Please pick your current location');
      return;
    }

    // ✅ Check if business proof image is uploaded
    // if (businessProofImage == null) {
    //   Get.snackbar('Error', 'Please upload business proof image');
    //   return;
    // }

    setState(() => isLoading = true);

    try {
      // ✅ Get logged-in user
      final authController = Get.find<AuthController>();
      final user = authController.user;

      if (user == null) {
        throw Exception("User ID not found. Please log in again.");
      }

      // ✅ Generate unique vendor code
      String vendorCode = generateUniqueCode();
      bool codeExists = true;
      while (codeExists) {
        final existing = await supabase
            .from('vendors')
            .select('vendor_code')
            .eq('vendor_code', vendorCode)
            .maybeSingle();

        if (existing == null) {
          codeExists = false;
        } else {
          vendorCode = generateUniqueCode();
        }
      }

      // ✅ Prepare vendor data
      final vendorData = {
        'user_id': user.userId, // add logged-in user ID
        'vendor_name': nameController.text.trim(),
        'vendor_email': emailController.text.trim(),
        'vendor_phone': phoneController.text.trim(),
        'vendor_address': addressController.text.trim(),
        'vendor_latitude': latitude,
        'vendor_longitude': longitude,
        'business_proof_image_path': '',
        // businessProofImage!.path, // store uploaded image path
        'is_active': true,
        'is_deleted': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
        'vendor_code': vendorCode,
      };

      // ✅ Insert vendor into Supabase
      await supabase.from('vendors').insert(vendorData);

      Get.snackbar(
        'Success',
        'Vendor added successfully',
        backgroundColor: Colors.green.shade50,
        colorText: Colors.green.shade800,
      );

      // ✅ Reset form and location
      _formKey.currentState!.reset();
      setState(() {
        latitude = null;
        longitude = null;
        businessProofImage = null;
      });

      // ✅ Navigate to Dashboard/Home
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.themeColor),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.themeColor.withOpacity(0.5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.themeColor.withOpacity(0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.themeColor, width: 1.8),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() {
    final authController = Get.find<AuthController>();
    final user = authController.user;

    if (user != null) {
      setState(() {
        nameController.text = user.name ?? '';
        emailController.text = user.email ?? '';
        phoneController.text = user.mobile ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'Vendor Details',
                style: TextStyle(
                  color: AppColors.themeColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // 🧾 Form Fields
              TextFormField(
                controller: nameController,
                decoration: _inputDecoration('Vendor Name', Icons.person),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter vendor name' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: emailController,
                decoration: _inputDecoration('Email', Icons.email),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter email';
                  final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (!regex.hasMatch(v)) return 'Enter valid email';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration('Phone', Icons.phone),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter phone number' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: addressController,
                decoration: _inputDecoration('Address', Icons.location_city),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter address' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 22),

              InkWell(
                onTap: pickBusinessProofImage,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                    color: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.upload_file, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        businessProofImage == null
                            ? "Upload Business Proof"
                            : "Image Selected",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              if (businessProofImage != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    businessProofImage!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // 🌍 Location Picker
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: AppColors.themeColor.withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        latitude == null
                            ? 'No location selected'
                            : 'Lat: ${latitude!.toStringAsFixed(4)}\nLng: ${longitude!.toStringAsFixed(4)}',
                        style: TextStyle(color: AppColors.textColor),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.themeColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.my_location, color: Colors.white),
                      label: const Text(
                        'Pick Location',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // 💾 Submit Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _addVendor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.themeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Add Vendor',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// 🏠 Dummy Dashboard Screen for navigation
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.themeColor,
      ),
      body: const Center(
        child: Text(
          'Welcome to Dashboard!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
