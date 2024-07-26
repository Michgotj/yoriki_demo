import 'dart:math';

import 'package:animated_toast_list/animated_toast_list.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lightmachine/components/layouts/src/show_hide_ui_mixin.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/app.states.dart';
import 'package:lightmachine/models/constants.dart';
import 'package:lightmachine/models/notification_controller.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/assets.dart';
import 'package:lightmachine/toasts/toast_model.dart';
import 'package:lightmachine/types/social_type.dart';

class Header extends StatefulWidget {
  final Function(String) onApprove;
  final Function() onApproveAll;
  final Function(String) onReject;
  final Function() onRejectAll;

  const Header({
    super.key,
    required this.minHeight,
    required this.onApprove,
    required this.onApproveAll,
    required this.onReject,
    required this.onRejectAll,
  });

  final double minHeight;

  @override
  State<StatefulWidget> createState() => HeaderState();
}

class HeaderState extends State<Header>
    with SingleTickerProviderStateMixin, ShowHideUIMixin {
  final webViewController = WCControllerFactory.find();
  final NotificationController notificationController =
      Get.find<NotificationController>();
  final appStateController = Get.find<AppStateController>();

  double get buttonHeight => 28.h;

  void onApproved(String id) {
    // notificationController.removeNotification(id);
    // context.showToast(MyToastModel('Approved'.tr, ToastType.success));
    widget.onApprove(id);
  }

  void onApprovedAll() {
    // notificationController.removeAllNotification();
    // context.showToast(MyToastModel('All approved!'.tr, ToastType.success));
    widget.onApproveAll();
  }

  void onReject(String id) {
    // notificationController.removeNotification(id);
    // context.showToast(MyToastModel('Rejected'.tr, ToastType.failed));
    widget.onReject(id);
  }

  void onRejectAll() {
    // notificationController.removeAllNotification();
    // context.showToast(MyToastModel('All rejected!'.tr, ToastType.failed));
    widget.onRejectAll();
  }

  void onTapNotification(String link, String id) async {
    final notification = notificationController.notifications
        .firstWhere((element) => element.id == id);
    notificationController.setActiveNotification(notification);
    webViewController.loadUrl(link);
  }

  double get getImagePreviewHeight => min(context.height * 0.2, 100);

  @override
  Widget build(BuildContext context) {
    final maxHeight =
        (context.height) * appStateController.headerHeight.value / 150;
    return AnimatedSize(
      duration: Duration(milliseconds: animUIDurationMillis),
      child: SizedBox(
        height: isUIVisible ? null : 0,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: widget.minHeight),
          child: Obx(() => (appStateController.headerHeight.value == 0 ||
                  notificationController.notifications.isEmpty ||
                  notificationController.activeNotification.value != null)
              ? const SizedBox.shrink()
              : Column(
                  children: [
                    Container(
                      color: Colors.white,
                      constraints:
                          BoxConstraints(maxHeight: maxHeight - buttonHeight),
                      child: Scrollbar(
                        thumbVisibility: true,
                        trackVisibility: true,
                        thickness: 6,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(
                                () => ListView.builder(
                                  shrinkWrap: true,
                                  // Use this
                                  physics: const NeverScrollableScrollPhysics(),
                                  // And this
                                  itemCount: notificationController
                                      .notifications.length,
                                  itemBuilder: (context, index) {
                                    var e = notificationController
                                        .notifications[index];
                                    final link = e.link;
                                    debugPrint('link: $link');
                                    return InkWell(
                                      onTap: () =>
                                          onTapNotification(e.link, e.id),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 14.w),
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  'assets/images/${getSocialTypeString(e.socialType)}_logo_icon.png',
                                                  width: 20.r,
                                                  height: 20.r,
                                                ),
                                                SizedBox(
                                                  width: 8.w,
                                                ),
                                                SvgPicture.asset(
                                                  notificationController
                                                      .getSenderIconAsset(e),
                                                  width: 20.r,
                                                  height: 20.r,
                                                ),
                                                SizedBox(
                                                  width: 12.w,
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12),
                                                    child: Text(
                                                      e.content,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.start,
                                                      style:
                                                          GoogleFonts.openSans(
                                                        textStyle: TextStyle(
                                                          fontSize: 12.sp,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              AppColors.black,
                                                        ),
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      onApproved(e.id),
                                                  icon: Container(
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: SvgPicture.asset(
                                                      Assets.ic_check,
                                                      width: 29.r,
                                                      height: 29.r,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  onPressed: () =>
                                                      onReject(e.id),
                                                  icon: Container(
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: SvgPicture.asset(
                                                      Assets.ic_close_cross,
                                                      width: 29.r,
                                                      height: 29.r,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (e.imageUrl != null)
                                            Container(
                                              width: double.infinity,
                                              height: getImagePreviewHeight,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16),
                                              child: Center(
                                                child: Image.network(
                                                  e.imageUrl!,
                                                  height: getImagePreviewHeight,
                                                ),
                                              ),
                                            ),
                                          const Divider(
                                            color: Color(0xFF01E6F5),
                                            height: 8,
                                            thickness: 1.5,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      color: const Color(0xFF01E6F5),
                      width: double.infinity,
                      height: 3.h,
                    ),
                    // Container(
                    //   color: Colors.white,
                    //   width: double.infinity,
                    //   height: buttonHeight,
                    //   padding: const EdgeInsets.symmetric(vertical: 2),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.center,
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       InkWell(
                    //         onTap: onApprovedAll,
                    //         child: Container(
                    //           height: buttonHeight,
                    //           padding: EdgeInsets.symmetric(horizontal: 24.w),
                    //           child: Center(
                    //             child: AutoSizeText(
                    //               'Approve all'.tr,
                    //               maxLines: 1,
                    //               style: GoogleFonts.openSans(
                    //                 textStyle: TextStyle(
                    //                   fontSize: 14.sp,
                    //                   fontWeight: FontWeight.w700,
                    //                   color: const Color(0xFF0C8C11),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //         Align(
                    //           alignment: Alignment.topCenter,
                    //           child: Container(
                    //             color: const Color(0xFF01E6F5),
                    //             width: 3.w,
                    //             height: 27.h,
                    //           ),
                    //         ),
                    //         InkWell(
                    //           onTap: onRejectAll,
                    //           child: Container(
                    //             height: buttonHeight,
                    //             padding: EdgeInsets.symmetric(horizontal: 24.w),
                    //             child: AutoSizeText(
                    //               'Reject all'.tr,
                    //               maxLines: 1,
                    //               style: GoogleFonts.openSans(
                    //                 textStyle: TextStyle(
                    //                   fontSize: 14.sp,
                    //                   fontWeight: FontWeight.w700,
                    //                   color: const Color(0xFFBE0A0A),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   )
                  ],
                )),
        ),
      ),
    );
  }
}
