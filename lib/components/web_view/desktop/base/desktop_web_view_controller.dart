import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/services/analytics_service.dart';
import 'package:lightmachine/types/social_type.dart';
import 'package:lightmachine/utils/domain.dart';
import 'package:webview_cef/webview_cef.dart';

class DesktopWebViewComponentController extends GetxController
    implements WebViewControllerInterface<WebViewController> {
  final _wvCtrl = Rx<WebViewController?>(null);

  @override
  final Rx<SocialType> currentPlatform = SocialType.other.obs;

  WebViewController? get wvCtrl => _wvCtrl.value;

  @override
  Future<void> init() async {
    await WebviewManager().initialize(userAgent: WebViewControllerInterface.mayByDesktopUserAgent);
    final controller = WebviewManager().createWebView();
    controller.setWebviewListener(WebviewEventsListener(
      onTitleChanged: (t) {
      },
      onUrlChanged: (url) {
        aService.logEvent(AEvents.onWVUrlChanged);
        _onCheckingCookies();
        debugPrint('url change to ${url}');
        if (url != null) {
          currentPlatform.value = getSocialType(getDomain(url!));
        }
        final Set<JavascriptChannel> jsChannels = {
          JavascriptChannel(
              name: 'Toaster',
              onMessageReceived: (JavascriptMessage message) {
                _wvCtrl.value?.sendJavaScriptChannelCallBack(
                    false,
                    "{'code':'200','message':'print succeed!'}",
                    message.callbackId,
                    message.frameId,
                );
                onJSChannelMessageReceived?.call(message.message);
              },),
        };
        _wvCtrl.value?.setJavaScriptChannels(jsChannels);
      },
    ));

    await controller.initialize(WebViewControllerInterface.initialUrl);
    updateController(controller);
  }

  @override
  void updateController(WebViewController controller) {
    _wvCtrl.value = controller;
  }

  @override
  void goBack() async {
    await _wvCtrl.value?.goBack();
  }

  @override
  void goForward() async {
    await _wvCtrl.value?.goForward();
  }

  @override
  void loadUrl(String uri) async {
    if (uri.isNotEmpty) {
      await _wvCtrl.value?.loadUrl(uri);
    }
  }

  @override
  Function(String p1)? onJSChannelMessageReceived;

  void _onCheckingCookies() async {
    if (_wvCtrl.value == null) {
      return;
    }
    try {
      final cookies = await runJavaScriptReturningResult(
        'document.cookie',
      );
      debugPrint('$runtimeType cookies: $cookies');
      final cookiesMap = <String, String>{};
      if (cookies is String) {
        final values = cookies.split(';');
        if (values.isNotEmpty) {
          for (var item in values) {
            final itemCandidate = item.trim().split('=');
            if (itemCandidate.length == 2) {
              cookiesMap[itemCandidate[0]] = itemCandidate[1];
            }
          }
        }
      }
      //debugPrint('$runtimeType cookiesMap: $cookiesMap');
      aService.onAnalyzeCookie(cookiesMap);
    } catch (e) {
      debugPrint('$runtimeType error : $e');
    }
  }

  @override
  Future<void> runJavaScript(String s) async {
    return await _wvCtrl.value?.executeJavaScript(s);
  }

  @override
  Future runJavaScriptReturningResult(String s) async {
    return await _wvCtrl.value?.evaluateJavascript(s);
  }

  void onUrlChanged(String url) {
    _onCheckingCookies();
    aService.logEvent(AEvents.onWVUrlChanged);

    debugPrint('url change to ${url}');
    if (url != null) {
      currentPlatform.value = getSocialType(getDomain(url!));
    }
  }

  @override
  void onDispose() {
    _wvCtrl.value?.dispose();
    WebviewManager().quit();
  }

  @override
  Function(WebViewScrollPositionChange scroll)? onScrollPositionChange;

  @override
  Function(String? url)? onUrlChange;

  @override
  Function(int progress)? onLoadProgress;
}
