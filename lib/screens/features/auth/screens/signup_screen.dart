import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klektion/screens/base_screen.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../utils/color_constants.dart';
import '../../../../utils/validators.dart';
import '../../../../utils/constants.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstnameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameUserController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to the Terms and Conditions');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final authController = Get.find<AuthController>();

    final success = await authController.signUp(
      userNameUser: _userNameUserController.text,
      username:
          "${_firstnameController.text.trim()} ${_lastnameController.text}",
      password: _passwordController.text,
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Get.offAll(() => const BaseScreen());
    } else {
      _showErrorSnackBar(
        authController.errorMessage ?? AppConstants.genericErrorMessage,
      );
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeGold = AppColors.primaryColor;
    final bgGreen = AppColors.themeColor;

    return Scaffold(
      backgroundColor: bgGreen,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 30),

              // Logo
              Container(
                height: 120,
                width: 150,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  // color: Color.fromARGB(255, 20, 3, 3), // Gold circle
                ),
                child: Image.asset(
                  'assets/images/app_logo_k.png',
                  fit: BoxFit.fill,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "Create Account",
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: themeGold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Start your collection journey",
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.3),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildField(
                        controller: _userNameUserController,
                        label: "User Name",
                        icon: Icons.person_outline,
                        validator: Validators.validateUsername,
                        hint: "Enter your user name",
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _firstnameController,
                        label: "First Name",
                        icon: Icons.person_outline,
                        validator: Validators.validateUsername,
                        hint: "Enter your first name",
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _lastnameController,
                        label: "Last Name",
                        icon: Icons.person_outline,
                        validator: Validators.validateUsername,
                        hint: "Enter your last name",
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _mobileController,
                        label: "Mobile Number",
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        prefixText: " ",
                        validator: Validators.validateMobileNumber,
                        hint: "Enter your mobile number",
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        controller: _emailController,
                        label: "Email",
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                        hint: "your@email.com",
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _passwordController,
                        label: "Password",
                        obscureText: !_isPasswordVisible,
                        isVisible: _isPasswordVisible,
                        toggle: () {
                          setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          );
                        },
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 16),
                      _buildPasswordField(
                        controller: _confirmPasswordController,
                        label: "Confirm Password",
                        obscureText: !_isConfirmPasswordVisible,
                        isVisible: _isConfirmPasswordVisible,
                        toggle: () {
                          setState(
                            () => _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                          );
                        },
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                      ),
                      const SizedBox(height: 20),

                      // Terms
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _agreeToTerms,
                            onChanged: (v) =>
                                setState(() => _agreeToTerms = v ?? false),
                            activeColor: themeGold,
                            checkColor: bgGreen,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.white70,
                                  ),
                                  children: [
                                    const TextSpan(text: 'I agree to the '),
                                    TextSpan(
                                      text: 'Terms and Conditions',
                                      style: TextStyle(
                                        color: themeGold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: TextStyle(
                                        color: themeGold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [themeGold, themeGold.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                      Colors.white,
                                    ),
                                    strokeWidth: 2,
                                  )
                                : Text(
                                    "Create Account",
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: bgGreen,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      Text(
                        "Already have an account?",
                        style: GoogleFonts.poppins(color: Colors.white70),
                      ),
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Text(
                          "Sign In",
                          style: GoogleFonts.poppins(
                            color: themeGold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    String? prefixText,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        prefixText: prefixText,
        filled: true,
        fillColor: Colors.transparent,

        // ✅ BLACK BORDER
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required bool isVisible,
    required VoidCallback toggle,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD4AF37)),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed: toggle,
        ),
        filled: true,
        fillColor: Colors.transparent,

        // ✅ BLACK BORDER
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
    );
  }
}
