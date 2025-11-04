import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
  late Animation<double> _scaleAnimation;

  final authController = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkAuthStatus();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
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
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Icon
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      // child: const Icon(
                      //   Icons.collections,
                      //   size: 60,
                      //   color: Colors.deepPurple,
                      // ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // App Name
            FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                AppConstants.appName,
                style: GoogleFonts.poppins(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
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
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
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
