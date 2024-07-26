import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:animated_toast_list/animated_toast_list.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lightmachine/models/app.states.dart';
import 'package:lightmachine/models/local_notification_service.dart';
import 'package:lightmachine/models/notification_controller.dart';
import 'package:lightmachine/models/object_detection_service.dart';
import 'package:lightmachine/models/services/analytics_service.dart';
import 'package:lightmachine/models/services/auth_service.dart';
import 'package:lightmachine/models/services/feature_service.dart';
import 'package:lightmachine/routes.dart';
import 'package:lightmachine/style/theme/theme_dark.dart';
import 'package:lightmachine/style/theme/theme_light.dart';
import 'package:lightmachine/types/notification.dart';
import 'package:lightmachine/utils/constants.dart';
import 'package:lightmachine/utils/i18n.dart';
import 'package:lightmachine/utils/orientation_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'toasts/toast_item.dart';
import 'toasts/toast_model.dart';
import 'utils/user_to_json.dart' as utils;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Get.put(FeatureService());
  Get.put(LocalNotificationService().init());
  try {
    List<NotificationType> notifications = [];
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.
    await Firebase.initializeApp();

    debugPrint('_firebaseMessagingBackgroundHandler data ${message.data}');
    debugPrint(
        '_firebaseMessagingBackgroundHandler body ${message.notification}');

    final String? messageData = message.notification?.body;
    if (messageData == null) {
      return;
    }
    Map<String, dynamic> notificationJson =
        jsonDecode(messageData!) as Map<String, dynamic>;

    notificationJson['extra_text'] =
        utils.utils.getRandomElement(notificationJson);
    final NotificationType notification =
        await NotificationType.createFromNotificationJson(notificationJson);

    final img =
        await localNotificationService.prepareImage(notification.imageUrl);

    localNotificationService.showImageNotification(
      'Lightmachine',
      notification.content,
      img,
    );

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.reload();

    if (prefs.containsKey(NOTIFICATION)) {
      final String notificationsString = prefs.getString(NOTIFICATION)!;
      log(notificationsString);
      debugPrint('xxxx $notificationsString');
      List<NotificationType> currentNotifications =
          (jsonDecode(notificationsString) as List<dynamic>)
              .map((item) => NotificationType.fromJson(item))
              .toList();
      currentNotifications.add(notification);
      notifications = currentNotifications;
      firstLink = notification.link;
    } else {
      notifications.add(notification);
    }
    await prefs.setString(
        NOTIFICATION,
        jsonEncode(notifications
            .map((notification) => notification.toJson())
            .toList()));
    log('string notifications: ${prefs.getString(NOTIFICATION)}');
    debugPrint('string notifications: ${prefs.getString(NOTIFICATION)}');
  } catch (exception, stackTrace) {
    debugPrint('$exception, $stackTrace');
  }
}

String firstLink = '';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(FeatureService());
  await OrientationExtension.lockVertical();
  if (featureService.isFirebaseEnabled) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// init services
  Get.put(LocalNotificationService().init());
  Get.put(NotificationController());
  Get.put(ObjectDetectionService());
  await objectDetectionService.init();
  await Get.putAsync(() => AnalyticsService().init());
  await Get.putAsync(() => AuthService().init());

  // ... (rest of your initialization code)

  if (featureService.isFirebaseEnabled) {
    // Check if the app was launched from a notification
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // Handle initial message if any
    if (initialMessage != null) {
      final firstLink = initialMessage.data['link'];
      final id = initialMessage.data['id'] ?? '';
      notificationController.setActiveNotificationById(id);
      debugPrint('Initial message: $firstLink');
    }
  }
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    Get.put(AppStateController());
    setLocale();
    _sub = authService.isAuthorized.listen((event) {
      debugPrint('$runtimeType got auth event $event');
      if (!event) {
        final currentRote = Get.routing.current;
        debugPrint('$runtimeType current route: $currentRote');
        if (currentRote != '/login') {
          Get.offAllNamed('/login');
        }
      }
    });
    localNotificationService.isAndroidPermissionGranted();
  }

  @override
  void dispose() {
    super.dispose();
    _sub?.cancel();
  }

  void setLocale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(APP_LANGUAGE) &&
        (prefs.getString(APP_LANGUAGE) == 'en')) {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('XXXX firstLink: $firstLink');
    return ToastListOverlay(
      itemBuilder: (BuildContext context, MyToastModel item, int index,
          Animation<double> animation) {
        return ToastItem(
          animation: animation,
          item: item,
          onTap: () => context.hideToast(
              item,
              (context, animation) =>
                  _buildItem(context, item, index, animation)),
        );
      },
      child: ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        child: GetMaterialApp(
          translations: AppTranslations(),
          // locale: const Locale('en', 'US'),
          locale: const Locale('he', 'IL'),
          theme: createLightTheme(),
          darkTheme: createDarkTheme(),
          themeMode: ThemeMode.light,
          builder: EasyLoading.init(),
          debugShowCheckedModeBanner: false,
          title: 'Lightmachine',
          getPages: routes,
          initialRoute: '/splash',
          //initialRoute: authService.isAuthorized.value ? '/' : '/login',
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    MyToastModel item,
    int index,
    Animation<double> animation,
  ) {
    return ToastItem(
      animation: animation,
      item: item,
      onTap: () => context.hideToast(
        item,
        (context, animation) => _buildItem(context, item, index, animation),
      ),
    );
  }
}
