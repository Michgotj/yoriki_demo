import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/web_view/desktop/base/desktop_web_view_controller.dart';
import 'package:lightmachine/components/web_view/web_view_controller_interface.dart';
import 'package:webview_cef/webview_cef.dart';

class DesktopWebViewComponent extends StatefulWidget {
  const DesktopWebViewComponent({super.key});

  @override
  State<DesktopWebViewComponent> createState() => DesktopWebViewComponentState();
}

class DesktopWebViewComponentState extends State<DesktopWebViewComponent>
    with AfterLayoutMixin {
  final componentController =
      WCControllerFactory.find() as DesktopWebViewComponentController;

  @override
  void initState() {
    super.initState();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) async {
    await componentController.init();
    componentController.onJSChannelMessageReceived = _onJSMessage;
  }

  @override
  void dispose() {
    componentController.onJSChannelMessageReceived = null;
    componentController.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => componentController.wvCtrl == null
          ? Center(
              child: Container(
                color: Colors.yellow,
              ),
            )
          : componentController.wvCtrl!.webviewWidget,
    );
  }

  void _onJSMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
