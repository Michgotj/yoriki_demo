import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lightmachine/style/theme/theme_extension/ext.dart';
import 'package:lightmachine/views/splash/splash_controller.dart';

import '../../style/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with AfterLayoutMixin {
  final _controller = Get.put(SplashController());

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    final res = await _controller.initApp();
    if (res) {
      Get.offAllNamed('/');
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.splashBg,
      body: SizedBox.expand(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                Assets.splash_logo,
                width: 382.w,
                height: 290.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
