import 'package:flutter/material.dart';

class AppTheme {
  // Ana Renkler
  static const Color primaryColor = Color(0xFFE65100); // Turuncu
  static const Color secondaryColor = Color(0xFFFF8F00); // Altın Sarısı
  static const Color accentColor = Color(0xFF4CAF50); // Yeşil
  static const Color backgroundColor = Color(0xFFFFF3E0); // Krem
  static const Color surfaceColor = Color(0xFFFFECB3); // Açık Sarı
  static const Color errorColor = Color(0xFFD32F2F); // Kırmızı

  // Metin Renkleri
  static const Color textPrimaryColor = Color(0xFF212121); // Koyu Gri
  static const Color textSecondaryColor = Color(0xFF757575); // Orta Gri
  static const Color textLightColor = Color(0xFFBDBDBD); // Açık Gri

  // Gradient Renkler
  static const List<Color> primaryGradient = [
    Color(0xFFE65100),
    Color(0xFFFF8F00),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFFFECB3),
    Color(0xFFFFF3E0),
  ];

  // Tema
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        background: backgroundColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textPrimaryColor,
        onBackground: textPrimaryColor,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textLightColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: textLightColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: errorColor),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  // Özel Stiller
  static BoxDecoration get cardDecoration {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  static BoxDecoration get gradientDecoration {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: primaryGradient,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(15),
    );
  }

  static TextStyle get titleStyle {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: textPrimaryColor,
    );
  }

  static TextStyle get subtitleStyle {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: textSecondaryColor,
    );
  }

  static TextStyle get bodyStyle {
    return TextStyle(
      fontSize: 16,
      color: textPrimaryColor,
    );
  }

  // Material3 textTheme erişimi
  static TextTheme get textTheme => theme.textTheme;

  // Ana metin rengi
  static Color get textColor => textPrimaryColor;

  // LinearGradient getter
  static LinearGradient get primaryLinearGradient => LinearGradient(colors: primaryGradient);
  static LinearGradient get secondaryLinearGradient => LinearGradient(colors: secondaryGradient);
} 