import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:after_layout/after_layout.dart';
import 'package:animated_toast_list/animated_toast_list.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/notification_controller.dart';
import 'package:lightmachine/models/services/feature_service.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/toasts/toast_model.dart';
import 'package:lightmachine/types/notification.dart';
import 'package:lightmachine/utils/user_to_json.dart' as utils;
import 'package:shared_preferences/shared_preferences.dart';

import '../../style/assets.dart';

class TitleBar extends StatefulWidget {
  const TitleBar({super.key});

  @override
  State<StatefulWidget> createState() => TitleBarState();
}

class TitleBarState extends State<TitleBar>
    with WidgetsBindingObserver, AfterLayoutMixin {
  NotificationController notificationController =
      Get.find<NotificationController>();
  final webViewController = WCControllerFactory.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    notificationController.initPurgeNotifications(context);
    init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      reload();
    }
  }

  void reload() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    notificationController.initNotifications();
  }

  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    try {
      debugPrint('${message.toMap()}');
      final notification = message.notification;
      if (notification != null) {
        developer.log('${notification.body}');
        Map<String, dynamic> notificationJson =
            jsonDecode(notification.body!) as Map<String, dynamic>;

        notificationJson['extra_text'] =
            utils.utils.getRandomElement(notificationJson);
        final notificationObject =
            await NotificationType.createFromNotificationJson(notificationJson);
        webViewController.loadUrl(notificationObject.link);
      }
    } catch (err) {
      debugPrint('err: $err');
    }
  }

  void init() async {
    if (featureService.isFirebaseEnabled) {
      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
      developer.log('${settings.authorizationStatus}');
      final token = await FirebaseMessaging.instance.getToken();
      developer.log('$token');
      final apnsToken = await FirebaseMessaging.instance.getAPNSToken();
      developer.log('$apnsToken');
      FirebaseMessaging.instance.subscribeToTopic('all');
      setupInteractedMessage();
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final notification = message.notification;
        if (notification != null) {
          developer.log('${notification.body}');
          final bool isReceived =
              await notificationController.addNotification(notification.body!);
          context.showToast(MyToastModel(
              isReceived
                  ? 'New notification is arrived'.tr
                  : 'New notification type is invalid'.tr,
              isReceived ? ToastType.success : ToastType.failed));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => notificationController.activeNotification.value != null
        ? SizedBox.shrink()
        : Container(
            height: featureService.isDesktop ? 60 : 60.h,
            width: double.infinity,
            color: AppColors.diamondBlue,
            child: Center(
              child: SvgPicture.asset(
                Assets.ninja,
                width: featureService.isDesktop ? 62 : 62.r,
                height: featureService.isDesktop ? 54 : 54.r,
              ),
            ),
          ));
  }
}
