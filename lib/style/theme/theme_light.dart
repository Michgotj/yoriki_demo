import 'package:flutter/material.dart';
import 'package:lightmachine/style/theme/theme_extension/theme_colors.dart';
import 'package:lightmachine/style/theme/theme_extension/theme_text_styles.dart';

import '../app_colors.dart';

ThemeData createLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.blackMain,
    extensions: [
      ThemeColors.light(),
      ThemeTextStyles.light(),
    ],
    dialogTheme: DialogTheme(backgroundColor: AppColors.diamondBlue),
  );
}
