import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/app.states.dart';
import 'package:lightmachine/models/notification_controller.dart';
import 'package:lightmachine/types/notification.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class HomeController extends GetxController {
  final appStateController = Get.find<AppStateController>();
  final wvComponentController = WCControllerFactory.put();
  final fullScreenshotController = ScreenshotController();
  final wvScreenshotController = ScreenshotController();
  final notificationService = Get.find<NotificationController>();

  Rx<NotificationType?> get activeNotification => notificationService.activeNotification;

  Future<Uint8List?> takeScreenshot(double? devicePixelRatio) async {
    final screenshot = await fullScreenshotController.capture(
      pixelRatio: devicePixelRatio,
    );

    if (kDebugMode) {
      if (screenshot != null) {
        final decodedImage = await decodeImageFromList(screenshot);
        debugPrint('_log: screenshot height: ${decodedImage.height}');
      }
    }
    return screenshot;
  }



  Future<String?> saveScreenshot(Uint8List screenshot) async {
    final currentTime = DateTime.now();
    final formattedDate = DateFormat('yyyy_MM_dd_HH_mm_ss').format(currentTime);
    final directory = (await getApplicationDocumentsDirectory()).path;
    final pathName = '$directory/screenshot_$formattedDate.png';
    File(pathName).writeAsBytesSync(screenshot as List<int>);
    debugPrint(pathName);
    return pathName;
  }

  //########################
  Future<Uint8List?> takeWebviewScreenshot(double? devicePixelRatio) async {
    final screenshot = await wvScreenshotController.capture(
      pixelRatio: devicePixelRatio,
    );

    if (kDebugMode) {
      if (screenshot != null) {
        final decodedImage = await decodeImageFromList(screenshot);
        debugPrint('_log: screenshot width: ${decodedImage.width}; height: ${decodedImage.height}');
      }
    }
    return screenshot;
  }

  Future<String?> saveWebviewScreenshot(Uint8List screenshot) async {
    try {
      final currentTime = DateTime.now();
      final formattedDate = DateFormat('yyyy_MM_dd_HH_mm_ss').format(
          currentTime);
      final directory = (await getDownloadsDirectory())!.path;
      final pathName = '$directory/w_screenshot_$formattedDate.png';
      File(pathName).writeAsBytesSync(screenshot as List<int>);
      debugPrint(pathName);
      return pathName;
    } catch(e) {
      debugPrint('$e');
      return '';
    }
  }
}
