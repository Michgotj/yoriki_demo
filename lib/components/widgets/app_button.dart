import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/theme/theme_extension/ext.dart';

abstract class DefaultColorButton extends StatelessWidget {
  static final kDefaultButtonHeight = 40.0;
  static final btnBorder = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(13.0),
  );
  final String title;
  final VoidCallback? onPressed;
  final Widget? child;
  final bool buttonEnabled;
  final Color overlayColorPressed;
  final Color backgroundColorDefault;
  final Color backgroundColorPressed;
  final Color backgroundColorDisabled;
  final Color titleColor;

  DefaultColorButton({
    Key? key,
    required this.title,
    this.onPressed,
    required this.overlayColorPressed,
    required this.backgroundColorDefault,
    required this.backgroundColorPressed,
    required this.backgroundColorDisabled,
    required this.titleColor,
    this.child,
    this.buttonEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return overlayColorPressed;
          }
          return Colors.transparent;
        }),
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.pressed)) {
            return backgroundColorPressed;
          }
          if (states.contains(MaterialState.disabled)) {
            return backgroundColorDisabled;
          }
          return backgroundColorDefault;
        }),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
          (_) => btnBorder,
        ),
        maximumSize: MaterialStateProperty.resolveWith<Size>(
          (_) => Size.fromHeight(kDefaultButtonHeight),
        ),
      ),
      onPressed: buttonEnabled ? onPressed : null,
      child: child != null
          ? child!
          : Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title,
                  textAlign: TextAlign.center,
                  style: context.appTextStyles.button?.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.4,
                    color: context.appColors.textDark,
                  ),
                ),
              ),
            ),
    );
  }
}

class AppButtonLight extends DefaultColorButton {
  AppButtonLight({
    Key? key,
    required String title,
    VoidCallback? onPressed,
    Widget? child,
    bool buttonEnabled = true,
  }) : super(
          key: key,
          title: title,
          onPressed: onPressed,
          child: child,
          buttonEnabled: buttonEnabled,
          overlayColorPressed: AppColors.grayMain.withOpacity(0.6),
          backgroundColorDefault: AppColors.diamondBlue,
          backgroundColorPressed: AppColors.diamondBlue.withOpacity(0.6),
          backgroundColorDisabled: AppColors.grayMain,
          titleColor: Colors.black,
        );
}

