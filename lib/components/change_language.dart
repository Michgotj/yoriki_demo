import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/theme/theme_extension/ext.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/services/analytics_service.dart';
import '../utils/constants.dart';

class ChangeLanguage extends StatefulWidget {
  const ChangeLanguage({Key? key}) : super(key: key);

  @override
  _ChangeLanguageState createState() => _ChangeLanguageState();
}

class _ChangeLanguageState extends State<ChangeLanguage> with AfterLayoutMixin {
  bool language = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    setState(() {
      language = Get.locale!.languageCode == 'en';
    });
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        'Change Language to Hebrew'.tr,
        style: context.appTextStyles.text?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.4,
          color: context.appColors.textWhite,
        ),
      ),
      activeColor: context.appColors.splashBg,
      inactiveTrackColor: AppColors.grayMain,
      value: language,
      onChanged: (val) {
        aService.logEvent(AEvents.onPressButtonSettingsLanguage);
        onLanguageChange(val);
      },
    );
  }

  void onLanguageChange(value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      language = value;
    });
    Get.updateLocale(
        value ? (const Locale('en', 'US')) : (const Locale('he', 'IL')));
    prefs.setString(APP_LANGUAGE, Get.locale!.languageCode);
  }
}
