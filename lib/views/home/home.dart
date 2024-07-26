import 'dart:async';
import 'dart:io';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/layouts/active_notification.dart';
import 'package:lightmachine/components/layouts/address_bar.dart';
import 'package:lightmachine/components/layouts/footer.dart';
import 'package:lightmachine/components/layouts/header.dart';
import 'package:lightmachine/components/layouts/titlebar.dart';
import 'package:lightmachine/components/web_view/desktop/base/desktop_web_view_component.dart';
import 'package:lightmachine/components/web_view/mobile/mobile_web_view_component.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:lightmachine/models/notification_controller.dart';
import 'package:lightmachine/models/services/analytics_service.dart';
import 'package:lightmachine/style/app_colors.dart';
import 'package:lightmachine/style/theme/theme_extension/ext.dart';
import 'package:lightmachine/utils/ui_util.dart';
import 'package:lightmachine/views/home/_user_flow_mixin.dart';
import 'package:lightmachine/views/home/home_controller.dart';
import 'package:screenshot/screenshot.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AfterLayoutMixin, UserFlowMixin {
  final controller = Get.put(HomeController());
  final _webKey = GlobalKey<MobileWebViewComponentState>();

  final _titleKey = GlobalKey<TitleBarState>();
  final _activeNotificationKey = GlobalKey<ActiveNotificationState>();
  final _headerKey = GlobalKey<HeaderState>();
  final _addressBar = GlobalKey<AddressBarState>();
  final _footerKey = GlobalKey<FooterState>();
  bool _isUIVisibleState = true;

  StreamSubscription? _sub;

  double bitmapW = 0;
  double bitmapH = 0;
  double targetBitmapX = 0;
  double targetBitmapY = 0;
  WebViewScrollPositionChange? _lastScrollPosition;
  bool _isProcessing = false;
  double minDelta = 50.0;

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    _sub =
        notificationController.activeNotification.listen((activeNotification) {
      if (activeNotification == null) {
        showUI();
      } else {
        hideUI();
      }
    });

    if (isNeedImmersiveMode) {
      controller.wvComponentController.onScrollPositionChange = (scroll) async {
        if (_isProcessing) {
          return;
        }
        if (notificationController.activeNotification.value == null) {
          _lastScrollPosition = null;
          showUI();
        } else if (_lastScrollPosition == null) {
          _lastScrollPosition = scroll;
          if (_lastScrollPosition!.y == 0) {
            showUI();
          }
        } else {
          final delta = scroll.y - _lastScrollPosition!.y;
          if (delta.abs() < minDelta.abs()) {
            return;
          }
          _lastScrollPosition = scroll;
          if (delta < 0) {
            _isProcessing = true;
            showUI();
          } else {
            _isProcessing = true;
            hideUI();
          }
          await Future.delayed(Duration(milliseconds: 800));
          _lastScrollPosition = null;
          _isProcessing = false;
        }
      };
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: context.appColors.splashBg,
        body: Screenshot(
          controller: controller.fullScreenshotController,
          child: SafeArea(
            child: Column(
              children: <Widget>[
                TitleBar(
                  key: _titleKey,
                ),
                ActiveNotification(
                  key: _activeNotificationKey,
                  onApprove: (id) => onApproveNotification(
                    notificationId: id,
                    wvCtrl: controller.wvComponentController,
                    screenShotCtrl: controller.wvScreenshotController,
                    webViewKey: _webKey,
                  ),
                  onReject: (id) => onRejectNotification(
                    notificationId: id,
                    wvCtrl: controller.wvComponentController,
                    screenShotCtrl: controller.wvScreenshotController,
                    webViewKey: _webKey,
                  ),
                ),

                Header(
                  key: _headerKey,
                  minHeight: 0,
                  onApprove: (id) async {
                    // Call the existing onApproveNotification function
                    await onApproveNotification(
                      notificationId: id,
                      wvCtrl: controller.wvComponentController,
                      screenShotCtrl: controller.wvScreenshotController,
                      webViewKey: _webKey,
                    );

                    // Call testObjectDetection after approving a notification
                    await testObjectDetection(
                      webViewKey: _webKey,
                      screenShotCtrl: controller.wvScreenshotController,
                    );

                    // Adjust the delay as needed

                    await testObjectDetection(
                      webViewKey: _webKey,
                      screenShotCtrl: controller.wvScreenshotController,
                    );
                  },
                  onApproveAll: () async {
                    await onApproveAllNotification(
                      wvCtrl: controller.wvComponentController,
                      screenShotCtrl: controller.wvScreenshotController,
                      webViewKey: _webKey,
                    );
                  },
                  onReject: (id) async {
                    await onRejectNotification(
                      notificationId: id,
                      wvCtrl: controller.wvComponentController,
                      screenShotCtrl: controller.wvScreenshotController,
                      webViewKey: _webKey,
                    );
                  },
                  onRejectAll: () async {
                    await onRejectAllNotification(
                      wvCtrl: controller.wvComponentController,
                      screenShotCtrl: controller.wvScreenshotController,
                      webViewKey: _webKey,
                    );
                  },
                ),
                AddressBar(
                  key: _addressBar,
                ),
                Expanded(
                  child: Stack(
                    children: [
                      Listener(
                        behavior: HitTestBehavior.translucent,
                        onPointerDown: (event) {
                          debugPrint(
                              "LISTENER onPointerDown position: dx: ${event.position.dx} dy: ${event.position.dy}");
                          debugPrint(
                              "LISTENER onPointerDown localPosition: dx: ${event.localPosition.dx} dy: ${event.localPosition.dy}");
                        },
                        child: ColoredBox(
                          color: AppColors.blackMain,
                          child: GestureDetector(
                              onDoubleTapDown: (details) {
                                aService.logEvent(
                                    AEvents.onPressButtonHomeWVDoubletap);
                                _onDoubleTapDown(details, context);
                              },
                              child: (() {
                                if (kIsWeb) {
                                  return Center(
                                    child: Container(
                                      color: AppColors.blackMain,
                                    ),
                                  );
                                }
                                if (Platform.isAndroid || Platform.isIOS) {
                                  return Screenshot(
                                    controller:
                                        controller.wvScreenshotController,
                                    child: MobileWebViewComponent(
                                      key: _webKey,
                                    ),
                                  );
                                } else if (Platform.isMacOS ||
                                    Platform.isWindows) {
                                  return Screenshot(
                                    controller:
                                        controller.wvScreenshotController,
                                    child: DesktopWebViewComponent(
                                      key: _webKey,
                                    ),
                                  );
                                }
                                // todo
                                return Center(
                                  child: Container(color: Colors.black45),
                                );
                              }())),
                        ),
                      ),
                      if (kDebugMode)
                        testObjDetectionWidget ?? const SizedBox.shrink(),
                    ],
                  ),
                ),
                Footer(
                  key: _footerKey,
                ),
                // if (kDebugMode)
                //   ElevatedButton(
                //       onPressed: () {
                //         _log();
                //       },
                //       child: Text('Log heights')),
                /*if (kDebugMode)
                  ElevatedButton(
                    onPressed: () {
                      aService.logEvent('test_event');
                    },
                    child: Text('test analytics'),
                  ),
                if (kDebugMode)
                  ElevatedButton(
                      onPressed: () {
                        _log();
                      },
                      child: Text('Log heights')),*/

                // if (kDebugMode)
                //   MaterialButton(
                //     child: Text(testObjDetectionWidget != null
                //         ? 'Remove bitmap'
                //         : 'Test Object Detection'),
                //     onPressed: () {
                //       testObjectDetection(
                //         webViewKey: _webKey,
                //         screenShotCtrl: controller.wvScreenshotController,
                //       );
                //     },
                //   ),
                // if (kDebugMode)
                //   MaterialButton(
                //     child: Text('Test Input'),
                //     onPressed: () async {
                //       simulateKeyboardInput('Some long text!!!');
                //     },
                //   ),
                // if (kDebugMode)
                //   Column(
                //     mainAxisSize: MainAxisSize.min,
                //     children: [
                //       Row(
                //         children: [
                //           Flexible(
                //             child: TextField(
                //               decoration: InputDecoration(
                //                 label: Text('Bitmap W'),
                //               ),
                //               maxLines: 1,
                //               keyboardType: TextInputType.number,
                //               onChanged: (val) =>
                //                   bitmapW = double.tryParse('$val') ?? 0,
                //             ),
                //           ),
                //           Flexible(
                //             child: TextField(
                //               decoration: InputDecoration(
                //                 label: Text('Bitmap H'),
                //               ),
                //               maxLines: 1,
                //               keyboardType: TextInputType.number,
                //               onChanged: (val) =>
                //                   bitmapH = double.tryParse('$val') ?? 0,
                //             ),
                //           ),
                //           Flexible(
                //             child: TextField(
                //               decoration: InputDecoration(
                //                 label: Text('Target X'),
                //               ),
                //               maxLines: 1,
                //               keyboardType: TextInputType.number,
                //               onChanged: (val) =>
                //                   targetBitmapX = double.tryParse('$val') ?? 0,
                //             ),
                //           ),
                //           Flexible(
                //             child: TextField(
                //               decoration: InputDecoration(
                //                 label: Text('Target Y'),
                //               ),
                //               maxLines: 1,
                //               keyboardType: TextInputType.number,
                //               onChanged: (val) =>
                //                   targetBitmapY = double.tryParse('$val') ?? 0,
                //             ),
                //           ),
                //         ],
                //       ),
                //       MaterialButton(
                //         child: Text('Click'),
                //         onPressed: () {
                //           _clickFromBitmapUsingPointerEvent(
                //             targetBitmapX: targetBitmapX,
                //             targetBitmapY: targetBitmapY,
                //             bitmapW: bitmapW,
                //             bitmapH: bitmapH,
                //           );
                //         },
                //       ),
                //     ],
                //   ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showUI() {
    if (!isNeedImmersiveMode) {
      return;
    }
    _activeNotificationKey.currentState?.showUI();
    _headerKey.currentState?.showUI();
    _addressBar.currentState?.showUI();
    _footerKey.currentState?.showUI();
    _isUIVisibleState = true;
  }

  void hideUI() {
    if (!isNeedImmersiveMode) {
      return;
    }
    _activeNotificationKey.currentState?.hideUI();
    _headerKey.currentState?.hideUI();
    _addressBar.currentState?.hideUI();
    _footerKey.currentState?.hideUI();
    _isUIVisibleState = false;
  }

  bool isUIVisible() {
    if (!isNeedImmersiveMode) {
      return true;
    }
    final activeNotification = _activeNotificationKey.currentState?.isUIVisible;
    final header = _headerKey.currentState?.isUIVisible;
    final addressBar = _addressBar.currentState?.isUIVisible;
    final footer = _footerKey.currentState?.isUIVisible;
    return activeNotification ??
        header ??
        addressBar ??
        footer ??
        _isUIVisibleState;
  }

  // void _onActivityChanged(ActivityTransition transition) {
  //   if (notificationController.activeNotification.value == null) {
  //     if (!isUIVisible()) {
  //       showUI();
  //     }
  //     return;
  //   }
  //   switch (transition) {
  //     case ActivityTransition.becameActive:
  //       showUI();
  //     case ActivityTransition.becameInactive:
  //       hideUI();
  //   }
  // }

  bool get isNeedImmersiveMode => false;

  // !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  double? get titleHeight => UIUtil.getSizeByGlobalKey(_titleKey)?.height;

  double? get activeNotificationHeight =>
      UIUtil.getSizeByGlobalKey(_activeNotificationKey)?.height;

  double? get headerHeight => UIUtil.getSizeByGlobalKey(_headerKey)?.height;

  double? get addressBarHeight =>
      UIUtil.getSizeByGlobalKey(_addressBar)?.height;

  double? get webViewTop {
    final mayBeTitleHeight = titleHeight;
    final mayBeHeaderHeight = headerHeight;
    final mayBeAddressBar = addressBarHeight;
    final mayBeActiveNotificationHeight = activeNotificationHeight;
    if (mayBeTitleHeight == null ||
        mayBeHeaderHeight == null ||
        mayBeAddressBar == null ||
        mayBeActiveNotificationHeight == null) {
      return null;
    }
    final mayBeWebViewTop = mayBeTitleHeight +
        mayBeHeaderHeight +
        mayBeAddressBar +
        mayBeActiveNotificationHeight;
    return mayBeWebViewTop;
  }

  double? get webViewTopHW =>
      webViewTop == null ? 0 : UIUtil.logicalPxToHardware(context, webViewTop!);

  void _onDoubleTapDown(TapDownDetails details, BuildContext context) async {
    final devicePixelRatio =
        mounted ? MediaQuery.of(context).devicePixelRatio : null;
    final screenshot = await controller.takeScreenshot(devicePixelRatio);
    final wvScreenshot =
        await controller.takeWebviewScreenshot(devicePixelRatio);
    if (!mounted) {
      return;
    }
    final x = details.localPosition.dx;
    final y = details.localPosition.dy;
    _click(x, y);
    _showSaveConfirmDialog(screenshot, wvScreenshot);
  }

  Future<void> _showSaveConfirmDialog(
      Uint8List? screenshot, Uint8List? wvScreenshot) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Screenshot'),
          content: Image.memory(screenshot!),
          actions: [
            TextButton(
              onPressed: () async {
                aService.logEvent(AEvents.onPressButtonHomeSave);
                final path = await controller.saveScreenshot(screenshot);
                final wvpath =
                    await controller.saveWebviewScreenshot(wvScreenshot!);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Screenshot saved into: \n$path'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                aService.logEvent(AEvents.onPressButtonHomeSave);
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  //=========================

  /// structure: TitleBar, Header, AddressBar and then WebView
  void _log() {
    if (!mounted) {
      debugPrint('_log: Context is not mounted...');
    }
    final mq = MediaQuery.of(context);

    // logical pixels
    final screenHeight = mq.size.height;
    final mbTitleHeight = titleHeight;
    final mbActiveNotificationHeight = activeNotificationHeight;
    final mbHeaderHeight = headerHeight;
    final mbAddressBarHeight = addressBarHeight;
    final mbWebViewTop = webViewTop;

    // hardware pixels
    final hvmbTitleHeight =
        UIUtil.logicalPxToHardware(context, mbTitleHeight ?? 0);
    final hvmbHeaderHeight =
        UIUtil.logicalPxToHardware(context, mbHeaderHeight ?? 0);
    final hvmbActiveNotificationHeight =
        UIUtil.logicalPxToHardware(context, mbActiveNotificationHeight ?? 0);
    final hvmbAddressBarHeight =
        UIUtil.logicalPxToHardware(context, mbAddressBarHeight ?? 0);
    final hvmbWebViewTop = webViewTopHW;

    final mbTitleLog =
        mbTitleHeight == null ? 'Widget is not ready' : '$mbTitleHeight';
    final mbHeaderLog =
        mbHeaderHeight == null ? 'Widget is not ready' : '$mbHeaderHeight';
    final mbActiveNotificationLog = mbActiveNotificationHeight == null
        ? 'Widget is not ready'
        : '$mbActiveNotificationHeight';
    final mbAddressBarLog = hvmbAddressBarHeight == null
        ? 'Widget is not ready'
        : '$mbAddressBarHeight';
    final mbWVTopLog =
        mbWebViewTop == null ? 'Widget is not ready' : '$mbWebViewTop';

    FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;

    debugPrint(
      '_log: \n\n'
      'Screen devicePixelRatio: ${mq.devicePixelRatio}\n'
      'Screen height: $screenHeight\n'
      'Hardware screen height: ${screenHeight * mq.devicePixelRatio}\n'
      'Screen width: ${mq.size.width}\n'
      'Hardware screen width: ${mq.size.width * mq.devicePixelRatio}\n'
      'Screen top insets: ${mq.viewInsets.top}\n'
      'Hardware Screen top insets: ${mq.viewInsets.top * mq.devicePixelRatio}\n'
      'Screen bottom insets: ${mq.viewInsets.bottom}\n'
      'Hardware bottom insets: ${mq.viewInsets.bottom * mq.devicePixelRatio}\n'
      'Screen top padding: ${mq.padding.top}\n'
      'Hardware top padding: ${mq.padding.top * mq.devicePixelRatio}\n'
      'Screen bottom padding: ${mq.padding.bottom}\n'
      'Hardware bottom padding: ${mq.padding.bottom * mq.devicePixelRatio}\n'
      'FlutterView height: ${view.physicalSize.height}\n'
      '------------------------------------------\n'
      'Title height: $mbTitleLog\n'
      'Hardware Title height: $hvmbTitleHeight\n'
      '------------------------------------------\n'
      'Header height: $mbHeaderLog\n'
      'Hardware Header height: $hvmbHeaderHeight\n'
      '------------------------------------------\n'
      'Active Notification height: $mbActiveNotificationLog\n'
      'Hardware Active Notification height: $hvmbActiveNotificationHeight\n'
      '------------------------------------------\n'
      'AddressBar height: $mbAddressBarLog\n'
      'Hardware AddressBar height: $hvmbHeaderHeight\n'
      '------------------------------------------\n'
      'WebView top: $mbWVTopLog\n'
      'Hardware Web View top: $hvmbWebViewTop\n\n',
    );
  }

  void _clickFromBitmapUsingPointerEvent({
    required double bitmapW, //720
    required double bitmapH, //901
    required double targetBitmapX, //53
    required double targetBitmapY, // 25
  }) async {
    debugPrint('Bitmap size bitmapW: $bitmapW px; bitmapH: $bitmapH px');
    debugPrint(
        'Target position on bitmap targetBitmapX: $targetBitmapX; targetBitmapX: $targetBitmapY');

    if (bitmapW <= 0 || bitmapH <= 0) {
      debugPrint('Bitmap width and height must be more then zero...');
      return;
    }

    final wvSize = UIUtil.getSizeByGlobalKey(_webKey);
    if (wvSize == null) {
      debugPrint('WebView is not ready...');
      return;
    }

    final wvWidth = wvSize.width;
    final wvHeight = wvSize.height;
    final hwwvWidth = UIUtil.logicalPxToHardware(context, wvWidth) ?? 0;
    final hwwvHeight = UIUtil.logicalPxToHardware(context, wvHeight) ?? 0;
    debugPrint('WebView logical size w: $wvWidth; h: $wvHeight');
    debugPrint('WebView hardware size w: $hwwvWidth; h: $hwwvHeight');

    // translate pixels coordinates to logical
    // final hwTransX = (targetBitmapX * hwwvWidth) / bitmapW;
    // final hwTransY = (targetBitmapY * hwwvHeight) / bitmapH;
    final transX = UIUtil.hardwarePxToLogical(context, targetBitmapX) ?? 0;
    final transY = UIUtil.hardwarePxToLogical(context, targetBitmapY) ?? 0;

    // debugPrint(
    //     'Target position on WebView hardware x: $hwTransX; y: $hwTransY');
    debugPrint('Target position on WebView logical x: $transX; y: $transY');

    //top UI correction
    final wvOffset = UIUtil.getWidgetOffsetByGlobalKey(_webKey);
    print('wvOffset: $wvOffset');
    final deltaY = wvOffset?.dy ?? 0;
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

  void _clickFromBitmap(
    double targetBitmapX,
    double targetBitmapY,
    double bitmapW,
    double bitmapH,
  ) async {
    debugPrint('Bitmap size bitmapW: $bitmapW; bitmapH: $bitmapH');
    debugPrint(
        'Target position on bitmap targetBitmapX: $targetBitmapX; targetBitmapX: $targetBitmapY');

    if (bitmapW <= 0 || bitmapH <= 0) {
      debugPrint('Bitmap width and height must be more then zero...');
      return;
    }
    // Getting inner web view viewport size
    final webW = await controller.wvComponentController
        .runJavaScriptReturningResult('window.innerWidth');
    final webH = await controller.wvComponentController
        .runJavaScriptReturningResult('window.innerHeight');
    debugPrint('Click Web viewport w: $webW; y: $webH');
    // translate coordinates
    final transX = (targetBitmapX * (double.tryParse('$webW') ?? 0)) / bitmapW;
    final transY = (targetBitmapY * (double.tryParse('$webH') ?? 0)) / bitmapH;
    debugPrint(
        'Target position inner WebView translated: transX: $transX; transY: $transY');
    // providing click
    final script =
        'window.document.elementFromPoint($transX, $transY).click(); console.log(\'Done\');';
    controller.wvComponentController.runJavaScript(script);
  }

  void _click(double x, double y) async {
    debugPrint('Click target position dx: $x; dy: $y');
    // Getting inner web view viewport size
    final webW = await controller.wvComponentController
        .runJavaScriptReturningResult('window.innerWidth');
    final webH = await controller.wvComponentController
        .runJavaScriptReturningResult('window.innerHeight');
    debugPrint('Click web viewport w: $webW; y: $webH');
    // Getting widget size
    final widgetSize = _webKey.currentState?.context.size;
    debugPrint('Click widgetSize: $widgetSize');
    if (widgetSize == null) {
      // widget is not ready
      return;
    }
    // translate coordinates
    final transX = (x * (double.tryParse('$webW') ?? 0)) / widgetSize.width;
    final transY = (y * (double.tryParse('$webH') ?? 0)) / widgetSize.height;
    debugPrint(
        'Click target position translated: transX: $transX; transY: $transY');
    // providing click
    final script =
        'window.document.elementFromPoint($transX, $transY).click(); console.log(\'done click\');';
    controller.wvComponentController.runJavaScript(script);
  }
}
