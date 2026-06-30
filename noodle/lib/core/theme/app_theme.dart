import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData appTheme = ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accentBrown, 
        outline: AppColors.borderBrown,
      ),
      scaffoldBackgroundColor: AppColors.lightBrown,
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.borderBrown, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: AppColors.borderBrown),
        bodyMedium: TextStyle(color: AppColors.borderBrown),
      ),
    );
  