import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

FeatureService get featureService => Get.find<FeatureService>();

class FeatureService extends GetxService {
  bool get isFirebaseEnabled =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isLocalNotificationEnable =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  bool get isDesktop =>
      kIsWeb || Platform.isWindows || Platform.isMacOS || Platform.isLinux;
}
