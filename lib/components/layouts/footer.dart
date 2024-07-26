import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/layouts/src/show_hide_ui_mixin.dart';
import 'package:lightmachine/components/setting.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/app.states.dart';
import 'package:lightmachine/models/constants.dart';
import 'package:lightmachine/models/services/analytics_service.dart';
import 'package:lightmachine/models/services/feature_service.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/assets.dart';
import 'package:lightmachine/types/setting_bar_type.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  State<StatefulWidget> createState() => FooterState();
}

final List<SettingBarType> settingBarItems = [
  SettingBarType(
    type: FooterSettingOptions.goForward,
    icon: Assets.forward_button_active,
    isVisible: true,
  ),
  SettingBarType(
    type: FooterSettingOptions.goSetting,
    icon: Assets.setting_button_active,
    isVisible: true,
  ),
  SettingBarType(
    type: FooterSettingOptions.goHome,
    icon: 'assets/images/footer/home_button_active.png',
    isVisible: kDebugMode ? true : false,
  ),
  SettingBarType(
    type: FooterSettingOptions.goBack,
    icon: Assets.back_button_active,
    isVisible: true,
  ),
];

class FooterState extends State<Footer>
    with SingleTickerProviderStateMixin, ShowHideUIMixin {
  final webViewController = WCControllerFactory.find();
  final AppStateController appStateController = Get.find<AppStateController>();
  late int currentIndex = 5;

  void onTapAddress(String link, int index) {
    setState(() {
      currentIndex = index;
    });
    webViewController.loadUrl(link);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: animUIDurationMillis),
      child: SizedBox(
        height: isUIVisible ? null : 0,
        child: Container(
          width: double.infinity,
          color: AppColors.diamondBlue,
          padding: EdgeInsets.symmetric(horizontal: 21.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: settingBarItems
                .where((e) => e.isVisible)
                .toList()
                .asMap()
                .entries
                .map(
                  (e) => InkWell(
                    onTap: () {
                      switch (e.value.type) {
                        case FooterSettingOptions.goForward:
                          aService.logEvent(AEvents.onPressButtonFooterForward);
                          webViewController.goForward();
                          break;
                        case FooterSettingOptions.goBack:
                          aService.logEvent(AEvents.onPressButtonFooterBack);
                          webViewController.goBack();
                          break;

                        case FooterSettingOptions.goHome:
                          aService.logEvent(AEvents.onPressButtonFooterGoHome);
                          webViewController.loadUrl('https://www.twitter.com');
                          break;
                        case FooterSettingOptions.goSetting:
                          aService
                              .logEvent(AEvents.onPressButtonFooterSettings);
                          Get.to(() => const Setting());
                          break;
                        default:
                      }
                    },
                    child: Container(
                      height: featureService.isDesktop ? 38 : 38.r,
                      width: featureService.isDesktop ? 60 : 60.r,
                      child: Center(
                        child: e.value.type == FooterSettingOptions.goHome
                            ? Image.asset(
                                e.value.icon,
                                width: featureService.isDesktop ? 30 : 30.r,
                                height: featureService.isDesktop ? 30 : 30.r,
                              )
                            : SvgPicture.asset(
                                e.value.icon,
                                width: featureService.isDesktop ? 19 : 19.r,
                                height: featureService.isDesktop ? 19 : 19.r,
                              ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}
