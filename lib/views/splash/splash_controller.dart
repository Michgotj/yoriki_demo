import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:lightmachine/models/services/auth_service.dart';

class SplashController extends GetxController {
  Future<bool> initApp() async {
    debugPrint('$runtimeType initApp start');
    final maxMillis = 2000;
    final start = DateTime.now();
    final res = await authService.updateAuthStatus();
    final end = DateTime.now();
    final elapsedMillis =
        end.millisecondsSinceEpoch - start.millisecondsSinceEpoch;
    if (elapsedMillis < maxMillis) {
      final waitingMillis = maxMillis - elapsedMillis;
      debugPrint('$runtimeType initApp waitingMillis: $waitingMillis');
      await Future.delayed(Duration(milliseconds: waitingMillis));
    }
    debugPrint('$runtimeType initApp end elapsedMillis: $elapsedMillis');
    return res;
  }
}
