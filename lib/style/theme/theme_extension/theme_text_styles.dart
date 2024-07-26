import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app_colors.dart';

class ThemeTextStyles extends ThemeExtension<ThemeTextStyles> {
  final TextStyle? button;
  final TextStyle? text;

  const ThemeTextStyles({
    this.button,
    this.text,
  });

  factory ThemeTextStyles.light() => ThemeTextStyles(
        button: GoogleFonts.ruda(
          textStyle: TextStyle(
            color: AppColors.black,
            fontSize: 16.0,
          ),
        ),
        text: GoogleFonts.ruda(
          textStyle: TextStyle(
            color: AppColors.black,
            fontSize: 12.0,
          ),
        ),
      );

  factory ThemeTextStyles.dark() => ThemeTextStyles(
        button: GoogleFonts.ruda(
          textStyle: TextStyle(
            color: AppColors.black,
            fontSize: 16.0,
          ),
        ),
        text: GoogleFonts.ruda(
          textStyle: TextStyle(
            color: AppColors.black,
            fontSize: 12.0,
          ),
        ),
      );

  @override
  ThemeExtension<ThemeTextStyles> copyWith({
    TextStyle? button,
    TextStyle? text,
  }) {
    return ThemeTextStyles(
      button: button ?? this.button,
      text: text ?? this.text,
    );
  }

  @override
  ThemeExtension<ThemeTextStyles> lerp(
    ThemeExtension<ThemeTextStyles>? other,
    double t,
  ) {
    if (other is! ThemeTextStyles) {
      return this;
    }
    return ThemeTextStyles(
      button: TextStyle.lerp(button, other.button, t),
      text: TextStyle.lerp(text, other.text, t),
    );
  }
}
