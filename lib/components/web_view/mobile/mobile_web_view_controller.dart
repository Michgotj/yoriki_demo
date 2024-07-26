import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/services/analytics_service.dart';
import 'package:lightmachine/types/social_type.dart';
import 'package:lightmachine/utils/domain.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class MobileWebViewComponentController extends GetxController
    implements WebViewControllerInterface<WebViewController> {
  final _wvCtrl = Rx<WebViewController?>(null);

  @override
  final Rx<SocialType> currentPlatform = SocialType.other.obs;

  WebViewController? get wvCtrl => _wvCtrl.value;

  @override
  void init() {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final controller = WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
            onLoadProgress?.call(progress);
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint(
              '''
              Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
            ''',
            );
          },
          onUrlChange: (UrlChange change) {
            aService.logEvent(AEvents.onWVUrlChanged);
            _onCheckingCookies();
            debugPrint('url change to ${change.url}');
            if (change.url != null) {
              currentPlatform.value = getSocialType(getDomain(change.url!));
            }
            onUrlChange?.call(change.url);
          },
        ),
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          onJSChannelMessageReceived?.call(message.message);
        },
      )
      ..setOnScrollPositionChange((change) {
        //debugPrint('setOnScrollPositionChange: ${change.x} ${change.y}');
        if (onScrollPositionChange!= null) {
          final scroll = WebViewScrollPositionChange(change.x, change.y);
          onScrollPositionChange?.call(scroll);
        }
      })
      ..clearCache();

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(true);
    }
    // #enddocregion platform_features

    updateController(controller);
    loadUrl('https://www.twitter.com');
    //controller.loadFlutterAsset('assets/clicks.html');
  }

  @override
  void updateController(WebViewController controller) {
    _wvCtrl.value = controller;
  }

  @override
  void goBack() async {
    if (await _wvCtrl.value?.canGoBack() ?? false) {
      await _wvCtrl.value?.goBack();
    }
  }

  @override
  void goForward() async {
    if (await _wvCtrl.value?.canGoForward() ?? false) {
      await _wvCtrl.value?.goForward();
    }
  }

  @override
  void loadUrl(String uri) async {
    if (uri.isNotEmpty) {
      await _wvCtrl.value?.loadRequest(Uri.parse(uri));
    }
  }

  @override
  Function(String p1)? onJSChannelMessageReceived;

  void _onCheckingCookies() async {
    if (_wvCtrl.value == null) {
      return;
    }
    try {
      final wvCtrl = _wvCtrl.value!;
      final cookies = await wvCtrl.runJavaScriptReturningResult(
        'document.cookie',
      );
      //debugPrint('$runtimeType cookies: $cookies');
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
    return await _wvCtrl.value?.runJavaScript(s);
  }

  @override
  Future runJavaScriptReturningResult(String s) async {
    return await _wvCtrl.value?.runJavaScriptReturningResult(s);
  }

  @override
  void onDispose() {
    // TODO: implement onDispose
  }

  @override
  Function(WebViewScrollPositionChange event)? onScrollPositionChange;

  @override
  Function(String? url)? onUrlChange;

  @override
  Function(int progress)? onLoadProgress;

}
