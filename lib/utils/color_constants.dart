import 'package:flutter/material.dart';

class AppColors {
  static const Color themeColor = Color(0xFF2B352C);
  static const Color primaryColor = Color(0xFFD4AF37);
  static const Color accentColor = Color(0xFF2E7D32);
  static const Color textColor = Color(0xFF333333);
  static const Color backgroundColor = Color(0xFFFFFFFF);
  static const Color errorColor = Color(0xFFE57373);
  static const Color appbarcolor1 = Color(0xFF0A646C);
  static const Color appbarcolor2 = Color.fromARGB(255, 98, 216, 177);
  static const Color appbartitle_text_color = Colors.black;
  static const Color buttonColor = Color(0xFF4CAF50);
  static const Color sloganTextColor = Color(0xFF0A646C);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static const background = Color(0xFF1A221D);
  static const card = Color(0xFF243026);
  static const accent = Color(0xFFC9A961);
  static const textPrimary = Colors.white;
  static const textSecondary = Colors.grey;
}

final LinearGradient goldGradient = const LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color.fromARGB(255, 214, 172, 74), // soft highlight gold
    Color.fromARGB(255, 205, 165, 48), // medium gold
    Color(0xFFD4AF37), // your base gold
    Color.fromARGB(255, 198, 156, 31), // deep gold shadow
  ],
  stops: [0.0, 0.35, 0.70, 1.0],
);

final buttonGradient = const LinearGradient(
  colors: [Color(0xFFB08A0B), Color(0xFFD4AF37), Color(0xFFFFE29F)],
);
