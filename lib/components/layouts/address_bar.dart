import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/layouts/src/show_hide_ui_mixin.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/constants.dart';
import 'package:lightmachine/models/notification_controller.dart';
import 'package:lightmachine/models/services/feature_service.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/assets.dart';
import 'package:lightmachine/style/theme/theme_extension/ext.dart';
import 'package:lightmachine/types/addressbar_item_type.dart';
import 'package:lightmachine/types/social_type.dart';

class AddressBar extends StatefulWidget {
  const AddressBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => AddressBarState();
}

final List<AddressBarItemDataType> addressItemData = [
  AddressBarItemDataType(
    type: SocialType.twitter,
    icon: Assets.twitter_inactive,
    activeIcon: Assets.twitter_active,
    link: 'https://www.twitter.com/',
    isVisible: true,
  ),
  AddressBarItemDataType(
    type: SocialType.facebook,
    icon: Assets.facebook_inactive,
    activeIcon: Assets.facebook_active,
    link: 'https://www.facebook.com/',
    isVisible: false,
  ),
  AddressBarItemDataType(
    type: SocialType.instagram,
    icon: Assets.instagram_inactive,
    activeIcon: Assets.instagram_active,
    link: 'https://www.instagram.com//',
    isVisible: false,
  ),
  AddressBarItemDataType(
    type: SocialType.tiktok,
    icon: Assets.tiktok_inactive,
    activeIcon: Assets.tiktok_active,
    link: 'https://www.tiktok.com/',
    isVisible: false,
  ),
];

class AddressBarState extends State<AddressBar>
    with SingleTickerProviderStateMixin, ShowHideUIMixin {
  final webViewController = WCControllerFactory.find();
  final urlTextFieldController = TextEditingController();
  bool isABCClicked = false;
  bool isExpanded = false;
  bool isError = false;

  void onTapAddress(String link, int index) {
    webViewController.loadUrl(link);
  }

  void onSubmitAddress(String value) async {
    if (value.isEmpty) {
      setState(() {
        isError = true;
      });
      return;
    }
    final Uri? uri = Uri.tryParse(value);
    if (uri == null || uri.scheme.isEmpty) {
      setState(() {
        isError = true;
      });
      return;
    }
    webViewController.loadUrl(value);
    urlTextFieldController.clear();
    setState(() {
      isExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: animUIDurationMillis),
      child: SizedBox(
        height: isUIVisible ? null : 0,
        child: Container(
          color: AppColors.diamondBlue,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5.h,
                width: double.infinity,
                color: Colors.white,
              ),
              Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...addressItemData
                          .where((element) => element.isVisible)
                          .toList()
                          .asMap()
                          .entries
                          .map(
                            (e) => Expanded(
                              child: InkWell(
                                onTap: () => onTapAddress(e.value.link, e.key),
                                child: Obx(
                                  () => Container(
                                    height: featureService.isDesktop ? 38 : 38.r,
                                    decoration: BoxDecoration(
                                      color: e.value.type ==
                                              webViewController
                                                  .currentPlatform.value
                                          ? AppColors.diamondBlue
                                          : AppColors.blackMain,
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        e.value.type ==
                                                webViewController
                                                    .currentPlatform.value
                                            ? e.value.activeIcon
                                            : e.value.icon,
                                        width: featureService.isDesktop ? 20 : 20.r,
                                        height:
                                            featureService.isDesktop ? 20 : 20.r,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isExpanded = true;
                            });
                          },
                          child: Container(
                            height: featureService.isDesktop ? 38 : 38.h,
                            decoration: BoxDecoration(
                              color: AppColors.blackMain,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                Assets.abc_inactive,
                                width: featureService.isDesktop ? 37 : 37.r,
                                height: featureService.isDesktop ? 18.5 : 18.5.r,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AnimatedContainer(
                      height: featureService.isDesktop ? 38 : 38.h,
                      duration: const Duration(milliseconds: 300),
                      width: isExpanded ? MediaQuery.of(context).size.width : 0,
                      child: Stack(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 0.w, horizontal: 10.h),
                            child: TextField(
                              controller: urlTextFieldController,
                              onSubmitted: onSubmitAddress,
                              style: context.appTextStyles.text?.copyWith(
                                fontSize: featureService.isDesktop ? 14 : 12.sp,
                                color: context.appColors.inputLightText,
                                fontWeight: FontWeight.w400,
                                letterSpacing: -0.4,
                              ),
                              decoration: InputDecoration(
                                hintText: 'https://www.domain.com',
                                contentPadding:
                                    EdgeInsets.only(left: 20, right: 20),
                                fillColor: Colors.grey.shade300,
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0.r),
                                  borderSide: BorderSide(
                                    color: isError ? Colors.red : Colors.black,
                                    style: BorderStyle.solid,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.0.r),
                                  borderSide: BorderSide(
                                    color: isError ? Colors.red : Colors.black,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: EdgeInsets.only(right: 6.h),
                              child: IconButton(
                                onPressed: () {
                                  urlTextFieldController.clear();
                                  setState(() {
                                    isExpanded = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.close_rounded,
                                  size: 18.r,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 5.h,
                width: double.infinity,
                color: AppColors.diamondBlue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
