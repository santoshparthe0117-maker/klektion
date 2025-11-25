import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:klektion/utils/color_constants.dart';
import '../../../../controllers/auth_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final authController = Get.find<AuthController>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController bioController;

  bool isLoading = false;
  XFile? selectedAvatar;

  @override
  void initState() {
    super.initState();
    final user = authController.user;

    nameController = TextEditingController(text: user?.name ?? "");
    emailController = TextEditingController(text: user?.email ?? "");
    bioController = TextEditingController(text: user?.bio ?? "");
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    bioController.dispose();
    super.dispose();
  }

  Future<void> pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.gallery);

    if (file != null) {
      setState(() => selectedAvatar = file);
    }
  }

  Future<void> saveProfile() async {
    setState(() => isLoading = true);

    final success = await authController.updateProfile(
      name: nameController.text,
      // email: emailController.text,
      bio: bioController.text,
      avatarFile: selectedAvatar,
    );

    setState(() => isLoading = false);

    if (success) {
      Get.snackbar("Success", "Profile updated successfully");
      //Get.back();
      authController.reloadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.user;

    return Scaffold(
      backgroundColor: AppColors.themeColor,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: AppColors.primaryColor,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: selectedAvatar != null
                        ? FileImage(File(selectedAvatar!.path))
                        : (user?.avatarUrl != ""
                                  ? NetworkImage(user!.avatarUrl)
                                  : const AssetImage(
                                      "assets/images/no_data_found.png",
                                    ))
                              as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: pickAvatar,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildInput("Name", nameController),
            const SizedBox(height: 15),

            _buildInput("Email", emailController),
            const SizedBox(height: 15),

            _buildInput("Bio", bioController, maxLines: 3),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: InkWell(
                onTap: isLoading ? null : saveProfile,

                child: Container(
                  padding: EdgeInsets.all(12),
                  alignment: Alignment.center,

                  decoration: BoxDecoration(
                    gradient: buttonGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save Changes",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget buildAvatar(String? avatarUrl) {
    return ClipOval(
      child: SizedBox(
        width: 110,
        height: 110,
        child: selectedAvatar != null
            ? Image.file(File(selectedAvatar!.path), fit: BoxFit.cover)
            : FadeInImage(
                placeholder: const AssetImage("assets/default_user.png"),
                image: avatarUrl != null && avatarUrl.isNotEmpty
                    ? NetworkImage(avatarUrl)
                    : const AssetImage("assets/default_user.png")
                          as ImageProvider,
                fit: BoxFit.cover,
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/default_user.png",
                    fit: BoxFit.cover,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: "Enter $label",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
