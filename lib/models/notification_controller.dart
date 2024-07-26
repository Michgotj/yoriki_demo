import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:animated_toast_list/animated_toast_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmachine/style/assets.dart';
import 'package:lightmachine/toasts/toast_model.dart';
import 'package:lightmachine/types/notification.dart';
import 'package:lightmachine/utils/constants.dart';
import 'package:lightmachine/utils/user_to_json.dart' as utils;
import 'package:shared_preferences/shared_preferences.dart';

NotificationController get notificationController =>
    Get.find<NotificationController>();

class NotificationController extends GetxService {
  final notifications = <NotificationType>[].obs;
  final activeNotification = Rx<NotificationType?>(null);
  Timer? timer;

  @override
  void onInit() {
    super.onInit();
    initNotifications();
  }

  void initPurgeNotifications(BuildContext context) {
    purgeExpiredNotifications(context);
    timer = Timer.periodic(const Duration(minutes: 60),
        (timer) => purgeExpiredNotifications(context));
  }

  void initNotifications() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(NOTIFICATION)) {
      final String notificationsString = prefs.getString(NOTIFICATION)!;
      notifications.value = (jsonDecode(notificationsString) as List<dynamic>)
          .map((item) => NotificationType.fromJson(item))
          .toList();
    }
  }

  Future<bool> addNotification(String notificationString) async {
    try {
      Map<String, dynamic> notificationJson =
          jsonDecode(notificationString) as Map<String, dynamic>;
      notificationJson['extra_text'] =
          utils.utils.getRandomElement(notificationJson);

      final notification =
          await NotificationType.createFromNotificationJson(notificationJson);

      notifications.insert(0, notification);
      persistNotifications();
      return true;
    } catch (exception, stackTrace) {
      debugPrint('$exception, $stackTrace');
      debugPrint('Failed to add notification $notificationString');
      return false;
    }
  }

  Future<void> removeNotification(String id) async {
    notifications.removeWhere((element) => element.id == id);
    await persistNotifications();
  }

  void removeAllNotification() {
    notifications.value = [];
    persistNotifications();
  }

  void purgeExpiredNotifications(BuildContext context) {
    List<NotificationType> expiredNotifications = _removeExpiredNotifications();
    if (expiredNotifications.isNotEmpty) {
      persistNotifications();
      _showExpiredNotificationSnackBar(expiredNotifications, context);
    }
  }

  List<NotificationType> _removeExpiredNotifications() {
    List<NotificationType> expiredNotifications = [];
    notifications.removeWhere((notification) {
      log('${notification.timestamp}, ${DateTime.now()}');
      final difference = DateTime.now().difference(notification.timestamp);
      bool isExpired = difference >= const Duration(minutes: 60);
      if (isExpired) expiredNotifications.add(notification);
      return isExpired;
    });
    return expiredNotifications;
  }

  void _showExpiredNotificationSnackBar(
      List<NotificationType> expiredNotifications, BuildContext context) {
    for (var notification in expiredNotifications) {
      context.showToast(MyToastModel(
          'Notification with ID: ${notification.id} has expired.',
          ToastType.failed));
    }
  }

  Future<void> persistNotifications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(
        NOTIFICATION,
        jsonEncode(notifications
            .map((notification) => notification.toJson())
            .toList()));
  }

  void setActiveNotification(NotificationType notification) {
    persistNotifications();
    activeNotification.value = notification;
  }

  NotificationType? setActiveNotificationById(String id) {
    final candidate =
        notifications.firstWhereOrNull((element) => element.id == id);
    if (candidate != null) {
      setActiveNotification(candidate);
      return candidate;
    }
    return null;
  }

  String getSenderIconAsset(NotificationType e) {
    // todo add logic for different senders
    return Assets.icLightMachine;
  }

  String getSenderBigIconAsset(NotificationType e) {
    // todo add logic for different senders
    return Assets.icLightMachineBig;
  }

  void removeActiveNotification() {
    activeNotification.value = null;
  }
}
