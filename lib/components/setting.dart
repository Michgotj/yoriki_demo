import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/widgets/app_button.dart';
import 'package:lightmachine/models/app.states.dart';
import 'package:lightmachine/models/services/analytics_service.dart';
import 'package:lightmachine/models/services/auth_service.dart';
import 'package:lightmachine/models/services/feature_service.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/theme/theme_extension/ext.dart';

import 'change_language.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<StatefulWidget> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final AppStateController appStateController = Get.find<AppStateController>();

  void onHeightPercentChanged(double value) {
    if (value < 45) {
      appStateController.setHeaderHeight(value);
    }
  }

  void onIsFIFOChanged(bool _) {
    appStateController.changeIsFIFO();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.diamondBlue,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'Settings'.tr,
          style: context.appTextStyles.text?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: -0.4,
            color: context.appColors.textWhite,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              children: [
                ChangeLanguage(),
                Obx(
                  () => SwitchListTile(
                    title: Text(
                      appStateController.isFIFO.value ? 'FIFO' : 'LIFO',
                      style: context.appTextStyles.text?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.4,
                        color: context.appColors.textWhite,
                      ),
                    ),
                    value: appStateController.isFIFO.value,
                    activeColor: context.appColors.splashBg,
                    inactiveTrackColor: AppColors.grayMain,
                    onChanged: (val) {
                      aService.logEvent(AEvents.onPressButtonSettingsFifiLifo);
                      onIsFIFOChanged(val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Height Percent of Header'.tr,
                    style: context.appTextStyles.text?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.4,
                      color: context.appColors.textWhite,
                    ),
                  ),
                ),
                Obx(
                  () => Slider(
                    activeColor: context.appColors.splashBg,
                    value: appStateController.headerHeight.value,
                    max: 100,
                    divisions: 20,
                    label: '${appStateController.headerHeight.value}%',
                    onChanged: (val) {
                      aService
                          .logEvent(AEvents.onPressButtonSettingsHeaderHeight);
                      onHeightPercentChanged(val);
                    },
                  ),
                ),
              ],
            ),
          ),
          if (featureService.isFirebaseEnabled)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              child: AppButtonLight(
                onPressed: () {
                  aService.logEvent(AEvents.appSignOut);
                  authService.signOutGoogle();
                },
                title: 'Sign Out'.tr,
              ),
            ),
        ],
      ),
    );
  }
}
