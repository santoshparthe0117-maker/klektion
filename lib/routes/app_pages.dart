import 'package:get/get.dart';
import '../bindings/auth_binding.dart';
import '../screens/splash_screen.dart';
import '../screens/features/auth/screens/signin_screen.dart';
import '../screens/features/auth/screens/signup_screen.dart';
import '../screens/base_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const BaseScreen(),
      binding: AuthBinding(),
    ),
  ];
}
