import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:lightmachine/models/services/feature_service.dart';
import 'package:path_provider/path_provider.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(
    'LocalNotificationService notificationTapBackground\n'
    'Handling a background message: ${notificationResponse.payload}',
  );
}

int notificationId = 0;

LocalNotificationService get localNotificationService =>
    Get.find<LocalNotificationService>();

class LocalNotificationService extends GetxService {
  static const String channelId = '1115';
  static const String channelTitle = 'Lightmachine';
  static const String channelDescription = 'Lightmachine Notifications';
  static const String androidIconRes = '@mipmap/launcher_icon';

  final flnPlugin = FlutterLocalNotificationsPlugin();
  NotificationAppLaunchDetails? notificationAppLaunchDetails;

  bool get isSupported => !kIsWeb && featureService.isLocalNotificationEnable;

  LocalNotificationService init() {
    if (!isSupported) {
      return this;
    }

    const initSettingsAndroid = AndroidInitializationSettings(androidIconRes);
    final initSettingsDarwin = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        notificationCategories: [
          DarwinNotificationCategory('defaultCategory'),
        ]);
    final initializationSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsDarwin,
    );
    flnPlugin.initialize(
      initializationSettings,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    if (Platform.isIOS) {
      final isPermitted = flnPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    return this;
  }

  Future<void> isAndroidPermissionGranted() async {
    if (!isSupported) {
      return;
    }
    if (Platform.isAndroid) {
      final bool granted = await flnPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
    }
  }

  void onDidReceiveLocalNotification(
    int id,
    String? title,
    String? body,
    String? payload,
  ) async {
    if (!isSupported) {
      return;
    }
    debugPrint(
      '$runtimeType onDidReceiveLocalNotification:\n'
      'id $id\n'
      'title: $title\n'
      'body: $body\n'
      'payload $payload\n',
    );
  }

  void onDidReceiveNotificationResponse(NotificationResponse details) {
    if (!isSupported) {
      return;
    }
    debugPrint('$runtimeType onDidReceiveNotificationResponse:\n'
        'id ${details.id}\n'
        'payload: ${details.payload}\n'
        'actionId: ${details.actionId}\n'
        'input: ${details.input}\n'
        'notificationResponseType: ${details.notificationResponseType}\n');
    final payload = details.payload ?? '';
  }

  /// For Android: [image] is base64 string
  /// For iOs: [image] is file path
  Future<void> showImageNotification(String title, String body, String? image,
      [String? payload]) async {
    if (!isSupported) {
      return;
    }

    AndroidNotificationDetails? androidNotificationDetails;
    DarwinNotificationDetails? iosNotificationDetails;

    if (Platform.isAndroid) {
      androidNotificationDetails = AndroidNotificationDetails(
        channelId,
        channelTitle,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: image != null
            ? BigPictureStyleInformation(
                ByteArrayAndroidBitmap.fromBase64String(image),
                largeIcon: ByteArrayAndroidBitmap.fromBase64String(image),
              )
            : null,
        ticker: 'ticker',
      );
    }

    if (Platform.isIOS) {
      iosNotificationDetails = DarwinNotificationDetails(
        categoryIdentifier: 'defaultCategory',
        attachments: image != null
            ? [
                DarwinNotificationAttachment(
                  image,
                  hideThumbnail: false,
                ),
              ]
            : null,
      );
    }
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    await flnPlugin.show(
      notificationId++,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<String?> prepareImage(String? imgUrl) async {
    if (imgUrl == null) {
      return null;
    }
    try {
      String? image;
      http.Response response = await http.get(Uri.parse(imgUrl));
      final bytes = response.bodyBytes;

      if (Platform.isAndroid) {
        image = base64Encode(bytes);
      } else if (Platform.isIOS) {
        final dir = await getTemporaryDirectory();
        final filename = '${dir.path}/notifimage.png';
        final file = File(filename);
        await file.writeAsBytes(response.bodyBytes);
        image = filename;
      }
      return image;
    } catch(e) {
      debugPrint('Seems, this url is not an image url...');
      return null;
    }
  }





}
