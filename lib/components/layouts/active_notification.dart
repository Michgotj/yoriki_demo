import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lightmachine/models/constants.dart';
import 'package:lightmachine/models/notification_controller.dart';
import 'package:lightmachine/style/assets.dart';
import 'package:lightmachine/types/social_type.dart';

import 'src/show_hide_ui_mixin.dart';

class ActiveNotification extends StatefulWidget {
  final Function(String) onApprove;
  final Function(String) onReject;

  const ActiveNotification({
    super.key,
    required this.onApprove,
    required this.onReject,
  });

  @override
  ActiveNotificationState createState() => ActiveNotificationState();
}

class ActiveNotificationState extends State<ActiveNotification>
    with SingleTickerProviderStateMixin, ShowHideUIMixin {
  final _notificationController = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: Duration(milliseconds: animUIDurationMillis),
      child: SizedBox(
        height: isUIVisible ? null : 0,
        child: Obx(
          () => _notificationController.activeNotification.value == null
              ? const SizedBox.shrink()
              : (() {
                  final notif =
                      _notificationController.activeNotification.value!;
                  return Container(
                    color: const Color(0xFFbaf8fc),
                    child: InkWell(
                      onTap: () => onTapNotification(notif.link, notif.id),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14.w),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/${getSocialTypeString(notif.socialType)}_logo_icon.png',
                              width: 20.r,
                              height: 20.r,
                            ),
                            SizedBox(
                              width: 8.w,
                            ),
                            SvgPicture.asset(
                              notificationController
                                  .getSenderBigIconAsset(notif),
                              //width: 20.r,
                              height: 33.r,
                            ),
                            SizedBox(
                              width: 12.w,
                            ),
                            const Expanded(
                              child: SizedBox(width: 10),
                            ),
                            IconButton(
                              onPressed: () => widget.onApprove(notif.id),
                              icon: Container(
                                padding: const EdgeInsets.all(4),
                                child: SvgPicture.asset(
                                  Assets.ic_check,
                                  width: 29.r,
                                  height: 29.r,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => widget.onReject(notif.id),
                              icon: Container(
                                padding: const EdgeInsets.all(2),
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
                    ),
                  );
                }()),
        ),
      ),
    );
  }

  void onTapNotification(String link, String id) {
    notificationController.removeActiveNotification();
  }
}
