import 'package:flutter/material.dart';
import 'package:lightmachine/style/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.blackMain.withOpacity(0.7),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.diamondBlue,
        ),
      ),
    );
  }
}
