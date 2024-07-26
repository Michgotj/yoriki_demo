import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/notification_controller.dart';
import 'package:lightmachine/models/object_detection_service.dart';
import 'package:lightmachine/utils/ui_util.dart';
import 'package:lightmachine/views/home/home.dart';
import 'package:screenshot/screenshot.dart';

mixin UserFlowMixin on State<HomeScreen> {
  static const _timeoutWebPageLoadedMillis = 10000;
  static const _timeoutPostLoadedMillis = 10000;
  static const _timeoutWKeyboardOpenedMillis = 3000;
  static const platformMethodName = 'com.yoriki.app/general';
  static const platform = MethodChannel(platformMethodName);
  Widget? testObjDetectionWidget = null;
  List<DetectionResult>? testObjDetectionResult = null;

  Future<void> onApproveNotification({
    required String notificationId,
    required WebViewControllerInterface wvCtrl,
    required ScreenshotController screenShotCtrl,
    required GlobalKey webViewKey,
  }) async {
    const logTag = 'onApproveNotification';
    debugPrint('$runtimeType $logTag start with id $notificationId');
    try {
      /// Set active notification
      final notification =
          notificationController.setActiveNotificationById(notificationId);
      debugPrint('$runtimeType $logTag set active');
      if (notification == null) {
        debugPrint('$runtimeType $logTag set active failed');
        return;
      }

      /// Load post
      wvCtrl.loadUrl(notification.link);
      debugPrint('$runtimeType $logTag start loading ${notification.link}');

      /// Waiting web page loading
      await _waitingLoading(wvCtrl);
      debugPrint('$runtimeType $logTag finish loading');
      if (!mounted) {
        throw Exception('Screen was unmounted...');
      }

      /// Waiting post loading
      await _waitingPostLoading(wvCtrl);

      /// Taking screenshot
      final devicePixelRatio =
          mounted ? MediaQuery.of(context).devicePixelRatio : null;
      final wvScreenshot =
          await screenShotCtrl.capture(pixelRatio: devicePixelRatio);
      if (wvScreenshot == null) {
        throw Exception('Screenshot was not captured...');
      }

      /// Saving screenshot - debug
      // final currentTime = DateTime.now();
      // final directory = (await getDownloadsDirectory())?.path ??
      //     (await getApplicationCacheDirectory()).path;
      // final pathName =
      //     '$directory/heart_${currentTime.millisecondsSinceEpoch}.png';
      // File(pathName).writeAsBytesSync(wvScreenshot as List<int>);
      // debugPrint(pathName);
      // --> debug

      debugPrint('$runtimeType $logTag captured screenshot');

      /// Detect like button
      final heartDetectionResult =
          await objectDetectionService.detectHeartButton(wvScreenshot);
      debugPrint('$runtimeType $logTag heart detection');

      /// Simulate click
      simulateClick(
        detectionResult: heartDetectionResult,
        webViewKey: webViewKey,
      );
      await _wait(1000);
      debugPrint('$runtimeType $logTag simulate click called');
    } catch (e) {
      debugPrint('$runtimeType onApproveNotification exception');
      debugPrint('$e');
    } finally {
      debugPrint('$runtimeType $logTag finalize');
      notificationController.removeActiveNotification();
      notificationController.removeNotification(notificationId);
    }
  }

  Future<void> onRejectNotification({
    required String notificationId,
    required WebViewControllerInterface wvCtrl,
    required ScreenshotController screenShotCtrl,
    required GlobalKey webViewKey,
  }) async {
    const logTag = 'onRejectNotification';
    debugPrint('$runtimeType $logTag start with id $notificationId');
    try {
      ///  Set active notification
      final notification =
          notificationController.setActiveNotificationById(notificationId);
      debugPrint('$runtimeType $logTag set active id ${notification?.id}');
      if (notification == null) {
        debugPrint('$runtimeType $logTag set active failed');
        return;
      }

      /// Load post
      wvCtrl.loadUrl(notification.link);
      debugPrint('$runtimeType $logTag start loading ${notification.link}');

      /// Waiting web page loading
      await _waitingLoading(wvCtrl);

      /// Waiting post loading
      await _waitingPostLoading(wvCtrl);
      debugPrint('$runtimeType $logTag finish loading');
      if (!mounted) {
        throw Exception('Screen was unmounted...');
      }

      /// Taking screenshot
      final wvScreenshot = await screenShotCtrl.capture(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      if (wvScreenshot == null) {
        throw Exception('Screenshot was not captured...');
      }
      debugPrint('$runtimeType $logTag took screenshot 1');

      /// Detect Start Reply
      final detectionStartReplyButton =
          await objectDetectionService.detectStartReplyButton(wvScreenshot);
      debugPrint('$runtimeType $logTag detectionStartReplyButton');
      await _wait(1000);

      /// Simulate click on start reply
      simulateClick(
        detectionResult: detectionStartReplyButton,
        webViewKey: webViewKey,
      );
      await _wait(1000);

      /// Waiting webpage loading
      await _waitingLoading(wvCtrl);
      debugPrint('$runtimeType $logTag _simulateClick on StartReplyButton');
      await _wait(3000);

      /// Checking keyboard
      //await _waitingKeyboardOpened(wvCtrl);
      //debugPrint('$runtimeType $logTag finish _waitingKeyboardOpened');
      //await _wait(1000);

      /// Simulate input
      await simulateKeyboardInput('Interesting point of view!');
      debugPrint('$runtimeType $logTag  _simulateKeyboardInput');
      await _wait(1000);

      /// Taking screenshot
      final replyScreenshot = await screenShotCtrl.capture(
        pixelRatio: MediaQuery.of(context).devicePixelRatio,
      );
      if (replyScreenshot == null) {
        throw Exception('Screenshot was not captured...');
      }
      debugPrint('$runtimeType $logTag took screenshot 2');

      /// Detecting send reply
      final detectionSendReplyButton = await objectDetectionService
          .detectionSendReplyButton(replyScreenshot);
      debugPrint('$runtimeType $logTag got  detectionSendReplyButton');
      await _wait(1000);

      /// Simulate click
      simulateClick(
        detectionResult: detectionSendReplyButton,
        webViewKey: webViewKey,
      );
      await _wait(1000);
      debugPrint('$runtimeType $logTag _simulateClick on SendReplyButton');
    } catch (e) {
      debugPrint('$runtimeType $logTag exception');
      debugPrint('$e');
    } finally {
      debugPrint('$runtimeType $logTag finalize');
      notificationController.removeActiveNotification();
      notificationController.removeNotification(notificationId);
    }
  }

  Future<void> onApproveAllNotification({
    required GlobalKey<State<StatefulWidget>> webViewKey,
    required WebViewControllerInterface<dynamic> wvCtrl,
    required ScreenshotController screenShotCtrl,
  }) async {
    final notificationIds =
        notificationController.notifications.map((e) => e.id);
    if (notificationIds.isEmpty) {
      return;
    }
    for (final id in notificationIds) {
      onApproveNotification(
        notificationId: id,
        wvCtrl: wvCtrl,
        screenShotCtrl: screenShotCtrl,
        webViewKey: webViewKey,
      );
    }
  }

  Future<void> onRejectAllNotification({
    required WebViewControllerInterface wvCtrl,
    required ScreenshotController screenShotCtrl,
    required GlobalKey webViewKey,
  }) async {
    final notificationIds =
        notificationController.notifications.map((e) => e.id);
    if (notificationIds.isEmpty) {
      return;
    }
    for (final id in notificationIds) {
      onRejectNotification(
        notificationId: id,
        wvCtrl: wvCtrl,
        screenShotCtrl: screenShotCtrl,
        webViewKey: webViewKey,
      );
    }
  }

  //############################################

  Future<void> _wait(int millis) async {
    return Future.delayed(Duration(milliseconds: millis));
  }

  Future<void> _waitingLoading(WebViewControllerInterface wvCtrl) async {
    debugPrint('$runtimeType _waitingLoading call');
    void removeWebViewListeners() {
      wvCtrl.onLoadProgress = null;
    }

    final completer = Completer<void>();
    final timeoutTimer = Timer(
      const Duration(milliseconds: _timeoutWebPageLoadedMillis),
      () {
        debugPrint('$runtimeType _waitingLoading timeout');
        removeWebViewListeners();
        completer.complete();
      },
    );
    wvCtrl.onLoadProgress = (progress) {
      debugPrint('$runtimeType _waitingLoading onLoadProgress $progress');
      if (progress == 100) {
        debugPrint('$runtimeType _waitingLoading success');
        timeoutTimer.cancel();
        removeWebViewListeners();
        completer.complete();
      }
    };

    return completer.future;
  }

  Future<void> _waitingPostLoading(WebViewControllerInterface wvCtrl) async {
    var isLoading = true;
    final timeoutTimer = Timer(
      const Duration(milliseconds: _timeoutPostLoadedMillis),
      () {
        debugPrint('$runtimeType _waitingPostLoading timeout');
        isLoading = false;
      },
    );

    while (isLoading) {
      await _wait(500);
      final searchLoadingScript = '''
          document.querySelector('[role="progressbar"]').outerHTML
          ''';
      final res =
          await wvCtrl.runJavaScriptReturningResult(searchLoadingScript);
      print('JS: $res');

      if (res is String && res.toLowerCase() == 'null') {
        isLoading = false;
      } else if (res == null) {
        isLoading = false;
      }
    }
    timeoutTimer.cancel();
    await _wait(500);
    return Future.value();
  }

  Future<bool> _waitingKeyboardOpened(WebViewControllerInterface wvCtrl) async {
    debugPrint('$runtimeType _waitingKeyboardOpened onLoadProgress ');
    bool isKeepChecking = true;
    final timeoutTimer = Timer(
      const Duration(milliseconds: _timeoutWKeyboardOpenedMillis),
      () {
        isKeepChecking = false;
      },
    );
    while (true) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (isKeepChecking) {
        final bottomInsets = MediaQuery.of(context).viewInsets.bottom;
        if (bottomInsets > 0) {
          timeoutTimer.cancel();
          return true;
        } else {
          continue;
        }
      } else {
        return false;
      }
    }
  }

  void simulateClick({
    required List<DetectionResult>? detectionResult,
    required GlobalKey webViewKey,
  }) {
    if (detectionResult == null || detectionResult.isEmpty) {
      debugPrint('$runtimeType detectionResult is absent...');
      return;
    }

    DetectionResult? topObject;
    double minY = double.infinity;
    for (var i = 0; i < detectionResult.length; i++) {
      final res = detectionResult[i];
      if (res.targetPosition.dy < minY) {
        minY = res.targetPosition.dy;
        topObject = res;
      }
    }

    if (topObject == null) {
      debugPrint('$runtimeType detectionResult is absent...');
    }

    final chosenResult = topObject as DetectionResult;

    final targetBitmapX = chosenResult.targetPosition.dx;
    final targetBitmapY = chosenResult.targetPosition.dy;
    final bitmapW = chosenResult.bitmapMeasure.dx;
    final bitmapH = chosenResult.bitmapMeasure.dy;
    if (bitmapW <= 0 || bitmapH <= 0) {
      throw Exception('Bitmap width and height must be more then zero...');
    }
    if (!mounted) {
      throw Exception('Screen was unmounted...');
    }
    final transX = UIUtil.hardwarePxToLogical(context, targetBitmapX) ?? 0;
    final transY = UIUtil.hardwarePxToLogical(context, targetBitmapY) ?? 0;
    final wvOffset = UIUtil.getWidgetOffsetByGlobalKey(webViewKey);
    if (wvOffset == null) {
      throw Exception('Bitmap width and height must be more then zero...');
    }
    final deltaY = wvOffset.dy;
    debugPrint('Y logical pixel correction: $deltaY');
    final transXCorrected = transX;
    final transYCorrected = transY + deltaY;
    debugPrint(
        'Target corrected position on the screen x: $transXCorrected; y: $transYCorrected');
    // providing click
    final point = Offset(transXCorrected, transYCorrected);
    GestureBinding.instance.handlePointerEvent(
      PointerDownEvent(position: point),
    );
    GestureBinding.instance.handlePointerEvent(
      PointerUpEvent(position: point),
    );
  }

  Future<void> simulateKeyboardInput(String text) async {
    debugPrint('$runtimeType _simulateKeyboardInput call');
    try {
      // Log the text that will be sent to the native method
      debugPrint('Text to be input: $text');

      final result = await platform.invokeMethod('simulateKeyPress', {
        'text': text,
        'type': 0, // type of native function 0 or 1
      });

      // Log the result from the native method
      debugPrint('$runtimeType _simulateKeyboardInput result: $result');
    } on PlatformException catch (e) {
      // Log any exceptions that occur during the method invocation
      debugPrint('$runtimeType _simulateKeyboardInput PlatformException: $e');
    } catch (e) {
      // Log any other exceptions
      debugPrint('$runtimeType _simulateKeyboardInput Exception: $e');
    }
    // Confirm the simulated input
    debugPrint('Simulated input for: $text');
  }

  Future<void> testObjectDetection({
    required GlobalKey webViewKey,
    required ScreenshotController screenShotCtrl,
  }) async {
    if (testObjDetectionWidget != null) {
      if (mounted) {
        setState(() {
          testObjDetectionWidget = null;
        });
      }

      await Future.delayed(const Duration(milliseconds: 1000));
      simulateClick(
        detectionResult: testObjDetectionResult,
        webViewKey: webViewKey,
      );
      return;
    }

    final devicePixelRatio =
        mounted ? MediaQuery.of(context).devicePixelRatio : null;
    final wvScreenshot =
        await screenShotCtrl.capture(pixelRatio: devicePixelRatio);
    if (wvScreenshot == null) {
      debugPrint('wvScreenshot is null...');
      return;
    }
    final res = await objectDetectionService.testObjectDetection(
      wvScreenshot,
    );
    testObjDetectionWidget = res?.imageWidget;
    testObjDetectionResult = res?.result;

    if (mounted) {
      setState(() => VoidCallback);
    }
  }
}
