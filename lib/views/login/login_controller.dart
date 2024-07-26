import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lightmachine/models/services/auth_service.dart';
import 'package:lightmachine/models/types/controller_result.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isSignUp = true.obs;
  String name = '';
  String email = '';
  String password = '';

  void switchFormAction() {
    final current = isSignUp.value;
    isSignUp.value = !current;
  }

  /// Result is User's name and Error Message
  Future<ControllerResult<String?, String?>> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await authService.signInWithGoogle();
      return ControllerResult(result: user.displayName, error: null);
    } catch (e) {
      debugPrint('$e');
      return ControllerResult(result: null, error: 'Action failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Result is User's name and Error Message
  Future<ControllerResult<String?, String?>> submitForm() async {
    try {
      isLoading.value = true;
      final user = isSignUp.value
          ? await authService.signUpWithPassword(email, password, name)
          : await authService.signInWithPassword(email, password);
      return ControllerResult(result: user.displayName, error: null);
    } catch (e) {
      debugPrint('$e');
      if (e is FirebaseAuthException) {
        final code = e.code;
        return ControllerResult(result: null, error: 'Action failed: $code');
      } else {
        return ControllerResult(result: null, error: 'Action failed: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
