import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../controllers/auth_controller.dart';
import '../../../../routes/app_routes.dart';
import '../../../../utils/color_constants.dart';
import 'vendor_qr_screen.dart';

class ProfileTabScreen extends StatefulWidget {
  const ProfileTabScreen({super.key});

  @override
  State<ProfileTabScreen> createState() => _ProfileTabScreenState();
}

class _ProfileTabScreenState extends State<ProfileTabScreen>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: GetX<AuthController>(
        builder: (authController) {
          final user = authController.user;

          return Stack(
            children: [
              /// 🌈 Animated Gradient Background
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return Container(
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                            const Color(0xFF2E7D32),
                            const Color(0xFF1B5E20),
                            sin(_waveController.value * pi),
                          )!,
                          Color.lerp(
                            const Color(0xFF66BB6A),
                            const Color(0xFF43A047),
                            cos(_waveController.value * pi),
                          )!,
                        ],
                      ),
                    ),
                  );
                },
              ),

              /// ✨ Floating Orbs Animation
              AnimatedBuilder(
                animation: _orbController,
                builder: (context, _) {
                  double t = _orbController.value;
                  return Stack(
                    children: [
                      _buildOrb(
                        top: 80 + sin(t * 2 * pi) * 15,
                        left: 40 + cos(t * 2 * pi) * 20,
                        size: 100,
                        color: Colors.white.withOpacity(0.08),
                      ),
                      _buildOrb(
                        top: 180 + cos(t * 2 * pi) * 25,
                        right: 60 + sin(t * 2 * pi) * 30,
                        size: 140,
                        color: Colors.white.withOpacity(0.05),
                      ),
                      _buildOrb(
                        top: 40 + sin(t * 2 * pi) * 10,
                        right: 10,
                        size: 80,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ],
                  );
                },
              ),

              /// 🌊 Animated Wave Shape Overlay
              AnimatedBuilder(
                animation: _waveController,
                builder: (context, _) {
                  return CustomPaint(
                    size: const Size(double.infinity, 300),
                    painter: _WavePainter(offset: _waveController.value * 100),
                  );
                },
              ),

              /// 💎 Glass Blur Layer for Depth
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(color: Colors.transparent),
                ),
              ),

              /// ✨ Glow Highlight
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.25),
                        Colors.transparent,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              // Profile content
              SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Profile Card (floating)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 30),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundColor: AppColors.primaryColor,
                            child: Text(
                              user?.name.substring(0, 1).toUpperCase() ?? 'U',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            user?.name ?? 'User',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '+91 ${user?.mobile ?? ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (user?.email != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              user!.email,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Profile Options
                    _buildProfileOption(
                      icon: Icons.edit_outlined,
                      title: 'Edit Profile',
                      color: AppColors.primaryColor,
                      onTap: () {
                        // TODO
                      },
                    ),
                    _buildProfileOption(
                      icon: Icons.qr_code,
                      title: 'QR code ',
                      color: AppColors.primaryColor,
                      onTap: () {
                        Get.to(VendorQrScreen());
                      },
                    ),
                    // _buildProfileOption(
                    //   icon: Icons.payment_outlined,
                    //   title: 'Payment Methods',
                    //   color: AppColors.primaryColor,
                    //   onTap: () {},
                    // ),
                    _buildProfileOption(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      color: AppColors.primaryColor,
                      onTap: () {},
                    ),
                    _buildProfileOption(
                      icon: Icons.info_outline,
                      title: 'About',
                      color: AppColors.primaryColor,
                      onTap: () {},
                    ),

                    const SizedBox(height: 30),

                    // Sign Out Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () =>
                            _showSignOutDialog(context, authController),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Text(
                          'Sign Out',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildOrb({
    double? top,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: Text(
            'Sign Out',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.grey[700]),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Get.back(); // Close dialog
                await authController.signOut();
                Get.offAllNamed(AppRoutes.signIn);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Sign Out', style: GoogleFonts.poppins()),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WavePainter extends CustomPainter {
  final double offset;

  _WavePainter({this.offset = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.9);
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(i, size.height * 0.9 - 10 * sin((i + offset) * 0.02));
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WavePainter oldDelegate) => oldDelegate.offset != offset;
}
