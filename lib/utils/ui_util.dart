import 'dart:ui';

import 'package:flutter/widgets.dart';

class UIUtil {
  UIUtil._();

  /// Returns a size of a widget by [GlobalKey]
  /// or null if widget is not rendered
  static Size? getSizeByGlobalKey<T extends State<StatefulWidget>>(
    GlobalKey<T> gKey,
  ) {
    final logPrefix = 'UIUtil getSizeByGlobalKey ${gKey.runtimeType}';
    Size? size;
    final context = gKey.currentContext;
    if (context == null) {
      debugPrint('$logPrefix (context is null)');
      return size;
    }
    final box = context.findRenderObject();
    if (box == null) {
      debugPrint('$logPrefix (RenderObject is null)');
    }
    if (box is RenderBox) {
      size = box.size;
    } else {
      size = context.size;
    }
    debugPrint('$logPrefix size: $size');
    return size;
  }

  static double? logicalPxToHardware(BuildContext context, double logicalPx) {
    final mq = MediaQuery.of(context);
    final devicePixelRatio = mq.devicePixelRatio;
    final hwPx = logicalPx * devicePixelRatio;
    return hwPx;
  }

  static double? hardwarePxToLogical(BuildContext context, double hwPx) {
    final mq = MediaQuery.of(context);
    final devicePixelRatio = mq.devicePixelRatio;
    final logicalPx = hwPx / devicePixelRatio;
    return logicalPx;
  }


  static Offset? getWidgetOffsetByGlobalKey<T extends State<StatefulWidget>>(
      GlobalKey<T> gKey,
      ) {
    final logPrefix = 'UIUtil getWidgetOffsetByGlobalKey ${gKey.runtimeType}';
    Offset? offset;
    final context = gKey.currentContext;
    if (context == null) {
      debugPrint('$logPrefix (context is null)');
      return offset;
    }
    final box = context.findRenderObject();
    if (box == null) {
      debugPrint('$logPrefix (RenderObject is null)');
    }
    if (box is RenderBox) {
      offset = box.localToGlobal(Offset.zero);
    }
    debugPrint('$logPrefix offset: $offset');
    return offset;
  }


}
