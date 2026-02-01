import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:klektion/utils/color_constants.dart';
import '../controllers/auth_controller.dart';
import '../utils/constants.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _animation;

  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    // _checkAuthStatus();
    _navigateToNextScreen();
  }

  _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));

    final AuthController authController = Get.find<AuthController>();

    if (authController.currentUser.value != null) {
      _navigateToHome();
    } else {
      _navigateToSignIn();
    }
  }

  void _initializeAnimations() {
    // _animationController = AnimationController(
    //   duration: const Duration(seconds: 2),
    //   vsync: this,
    // );

    // _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    // );

    // _animationController.forward();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Wait until auth initialization completes
    while (authController.state == AuthState.initial ||
        authController.state == AuthState.loading) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
    }

    if (authController.isAuthenticated) {
      _navigateToHome();
    } else {
      _navigateToSignIn();
    }
  }

  void _navigateToHome() => Get.offAllNamed(AppRoutes.home);
  void _navigateToSignIn() => Get.offAllNamed(AppRoutes.signIn);

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.themeColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (_, __) {
                return CustomPaint(painter: WavePainter(_animation.value));
              },
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                // AnimatedBuilder(
                //   animation: _animationController,
                //   builder: (context, child) {
                //     return Transform.scale(
                //       scale: _scaleAnimation.value,
                //       child: FadeTransition(
                //         opacity: _fadeAnimation,
                //         child: Container(
                //           width: 120,
                //           height: 120,
                //           decoration: BoxDecoration(
                //             color: Colors.white,
                //             borderRadius: BorderRadius.circular(30),
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Colors.black.withValues(alpha: 0.2),
                //                 blurRadius: 20,
                //                 offset: const Offset(0, 10),
                //               ),
                //             ],
                //           ),
                //           // child: const Icon(
                //           //   Icons.collections,
                //           //   size: 60,
                //           //   color: Colors.deepPurple,
                //           // ),
                //         ),
                //       ),
                //     );
                //   },
                // ),
                const SizedBox(height: 30),

                // App Name
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
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
                  // Text(
                  //   AppConstants.appName,
                  //   style: GoogleFonts.poppins(
                  //     fontSize: 32,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.white,
                  //   ),
                  // ),
                ),

                const SizedBox(height: 10),

                // Tagline
                const SizedBox(height: 60),

                // ✅ Reactive Loading Text
                Obx(() {
                  final currentState = authController.state;
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      children: [
                        // const SizedBox(
                        //   width: 30,
                        //   height: 30,
                        //   child: CircularProgressIndicator(
                        //     valueColor: AlwaysStoppedAnimation<Color>(
                        //       Colors.white,
                        //     ),
                        //     strokeWidth: 3,
                        //   ),
                        // ),
                        const SizedBox(height: 20),
                        Text(
                          _getLoadingText(currentState),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLoadingText(AuthState state) {
    switch (state) {
      case AuthState.initial:
        return 'Initializing...';
      case AuthState.loading:
        return 'Checking authentication...';
      case AuthState.authenticated:
        return 'Welcome back!';
      case AuthState.unauthenticated:
        return 'Please sign in...';
      case AuthState.error:
        return 'Something went wrong...';
    }
  }
}

class WavePainter extends CustomPainter {
  final double value;
  WavePainter(this.value);

  @override
  void paint(Canvas canvas, Size size) {
    final gradient = LinearGradient(
      colors: [
        Color(0xFFFFE29F),
        Color(0xFFD4AF37),
        Color.fromARGB(255, 92, 72, 6),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    final path = Path();

    double y = size.height * 0.8 + (value * 30);

    path.moveTo(0, y);
    path.quadraticBezierTo(size.width * 0.25, y - 40, size.width * 0.5, y);
    path.quadraticBezierTo(size.width * 0.75, y + 40, size.width, y);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
