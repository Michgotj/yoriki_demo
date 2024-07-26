import 'package:flutter/material.dart';

import '../../app_colors.dart';

class ThemeColors extends ThemeExtension<ThemeColors> {
  final Color splashBg;
  final Color scaffoldBg;
  final Color textDark;
  final Color textWhite;
  final Color inputLightBg;
  final Color inputLightBorder;
  final Color inputLightText;
  final Color inputDarkText;

  const ThemeColors({
    required this.splashBg,
    required this.scaffoldBg,
    required this.textDark,
    required this.textWhite,
    required this.inputLightBg,
    required this.inputLightBorder,
    required this.inputLightText,
    required this.inputDarkText,
  });

  factory ThemeColors.light() => ThemeColors(
        splashBg: AppColors.diamondBlue,
        scaffoldBg: AppColors.blackMain,
        textDark: AppColors.black,
        textWhite: AppColors.white,
    inputLightBg: AppColors.white,
    inputLightBorder: AppColors.grayMain,
    inputLightText: AppColors.grayDark,
    inputDarkText: AppColors.blackMain,
      );

  factory ThemeColors.dark() => ThemeColors(
        splashBg: AppColors.diamondBlue,
        scaffoldBg: AppColors.blackMain,
        textDark: AppColors.black,
        textWhite: AppColors.white,
    inputLightBg: AppColors.white,
    inputLightBorder: AppColors.grayMain,
    inputLightText: AppColors.grayDark,
    inputDarkText: AppColors.blackMain,
      );

  @override
  ThemeExtension<ThemeColors> copyWith({
    Color? splashBg,
    Color? scaffoldBg,
    Color? textDark,
    Color? textWhite,
    Color? inputLight,
    Color? inputLightBorder,
  }) {
    return ThemeColors(
      splashBg: splashBg ?? this.splashBg,
      scaffoldBg: scaffoldBg ?? this.scaffoldBg,
      textDark: textDark ?? this.textDark,
      textWhite: textWhite ?? this.textWhite,
      inputLightBg: inputLight ?? this.inputLightBg,
      inputLightBorder: inputLightBorder ?? this.inputLightBorder,
      inputLightText: inputLightBorder ?? this.inputLightText,
      inputDarkText: inputLightBorder ?? this.inputDarkText,
    );
  }

  @override
  ThemeExtension<ThemeColors> lerp(
    ThemeExtension<ThemeColors>? other,
    double t,
  ) {
    if (other is! ThemeColors) {
      return this;
    }
    return ThemeColors(
      splashBg: Color.lerp(splashBg, other.splashBg, t) ?? splashBg,
      scaffoldBg: Color.lerp(scaffoldBg, other.scaffoldBg, t) ?? scaffoldBg,
      textDark: Color.lerp(textDark, other.textDark, t) ?? textDark,
      textWhite: Color.lerp(textWhite, other.textWhite, t) ?? textWhite,
      inputLightBg: Color.lerp(inputLightBg, other.inputLightBg, t) ?? inputLightBg,
      inputLightBorder: Color.lerp(inputLightBorder, other.inputLightBorder, t) ?? inputLightBorder,
      inputLightText: Color.lerp(inputLightText, other.inputLightText, t) ?? inputLightText,
      inputDarkText: Color.lerp(inputDarkText, other.inputDarkText, t) ?? inputDarkText,
    );
  }
}
