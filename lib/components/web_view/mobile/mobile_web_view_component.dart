import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lightmachine/components/web_view/mobile/mobile_web_view_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MobileWebViewComponent extends StatefulWidget {
  const MobileWebViewComponent({super.key});

  @override
  State<MobileWebViewComponent> createState() => MobileWebViewComponentState();
}

class MobileWebViewComponentState extends State<MobileWebViewComponent>
    with AfterLayoutMixin {
  final componentController = Get.find<MobileWebViewComponentController>();

  @override
  void initState() {
    super.initState();
    componentController.init();
  }

  @override
  FutureOr<void> afterFirstLayout(BuildContext context) {
    componentController.onJSChannelMessageReceived = _onJSMessage;
  }

  @override
  void dispose() {
    componentController.onJSChannelMessageReceived = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (componentController.wvCtrl == null) {
      return Center(
        child: Container(
          color: Colors.black54,
        ),
      );
    }
    return WebViewWidget(
      controller: componentController.wvCtrl!,
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
