import 'package:flutter/material.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/theme/theme_extension/theme_colors.dart';
import 'package:lightmachine/style/theme/theme_extension/theme_text_styles.dart';

ThemeData createDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.blackMain,
    extensions: [
      ThemeColors.dark(),
      ThemeTextStyles.dark(),
    ],
    dialogTheme: DialogTheme(backgroundColor: AppColors.diamondBlue),
  );
}
