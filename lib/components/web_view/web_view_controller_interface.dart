import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/web_view/desktop/base/desktop_web_view_controller.dart';
import 'package:lightmachine/components/web_view/mobile/mobile_web_view_controller.dart';
import 'package:lightmachine/types/social_type.dart';

class WCControllerFactory {
  WCControllerFactory._();

  static WebViewControllerInterface put() {
    if (kIsWeb) {
      throw UnimplementedError();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return Get.put<MobileWebViewComponentController>(
          MobileWebViewComponentController());
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return Get.put<DesktopWebViewComponentController>(
          DesktopWebViewComponentController());
    }
    throw UnimplementedError();
  }

  static WebViewControllerInterface find() {
    if (kIsWeb) {
      throw UnimplementedError();
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return Get.find<MobileWebViewComponentController>();
    } else if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return Get.find<DesktopWebViewComponentController>();
    }
    throw UnimplementedError();
  }
}

abstract class WebViewControllerInterface<T> {
  static const String initialUrl = 'https://www.twitter.com';
  static const String macOsUserAgent =
      'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';
  static const String windowsUserAgent =
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';
  static const String linuxUserAgent =
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36';

  static String get mayByDesktopUserAgent {
    if (kIsWeb) {
      return '';
    }
    if (Platform.isMacOS) {
      return macOsUserAgent;
    }
    if (Platform.isWindows) {
      return windowsUserAgent;
    }
    if (Platform.isLinux) {
      return linuxUserAgent;
    }
    return '';
  }

  final Rx<SocialType> currentPlatform = SocialType.other.obs;

  Function(String)? onJSChannelMessageReceived;

  void init();

  void onDispose();

  void updateController(covariant T value);

  void loadUrl(String uri);

  void goBack();

  void goForward();

  Future<void> runJavaScript(String s);

  Future<dynamic> runJavaScriptReturningResult(String s);

  Function(WebViewScrollPositionChange)? onScrollPositionChange;

  Function(String?)? onUrlChange;

  Function(int)? onLoadProgress;

}


class WebViewScrollPositionChange {
  final double x;
  final double y;
  const WebViewScrollPositionChange(this.x, this.y);
}
