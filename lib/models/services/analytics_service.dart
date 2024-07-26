import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:lightmachine/models/services/feature_service.dart';

AnalyticsService get aService => Get.find<AnalyticsService>();

class AnalyticsService extends GetxService {
  bool _isSupported = false;
  FirebaseAnalytics? _fa;
  SocialLoginStatus? _socialLoginStatus;

  Future<AnalyticsService> init() async {
    if (!featureService.isFirebaseEnabled) {
      return this;
    }
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true);
    _isSupported = (await _fa?.isSupported() ?? false);
    if (!featureService.isFirebaseEnabled) {
      _isSupported = false;
      return this;
    }
    _fa = FirebaseAnalytics.instance;
    await _fa?.setAnalyticsCollectionEnabled(true);
    _isSupported = (await _fa?.isSupported()) ?? false;
    debugPrint('$runtimeType is supported: $_isSupported');
    return this;
  }

  void setUserId(String userId) {
    if (!_isSupported) {
      return;
    }
    _fa?.setUserId(id: userId);
  }

  void logEvent(String name, [Map<String, Object>? params]) {
    if (!_isSupported) {
      return;
    }
    _fa
        ?.logEvent(
          name: name,
          parameters: params,
        )
        .onError((error, stackTrace) => debugPrint('$error'));
  }

  void logAppOpen(bool isLoggedIn) {
    if (!_isSupported) {
      return;
    }
    _fa?.logAppOpen(parameters: {
      'is_logged_in': isLoggedIn ? 'logged_in' : 'logged_out',
    });
    logEvent(isLoggedIn ? AEvents.initAppLoggedIn : AEvents.initAppLoggedOut);
  }

  void onAnalyzeCookie(Map<String, String> cookie) {
    const cookieKeyX = 'twid';
    const cookieKeyFb = 'fbl_st';
    const cookieKeyIns = 'csrftoken';
    const cookieKeyTT = 'mstoken';
    final isLoggedInX = (cookie[cookieKeyX] != null);
    final isLoggedInFb = (cookie[cookieKeyFb] != null);
    final isLoggedInIns = (cookie[cookieKeyIns] != null);
    final isLoggedInTT = (cookie[cookieKeyTT] != null);
    debugPrint(
      '$runtimeType \n'
      'is logged in X: $isLoggedInX\n'
      'is logged in FB: $isLoggedInFb\n'
      'is logged in Ins: $isLoggedInIns\n'
      'is logged in TT: $isLoggedInTT\n',
    );

    if (_socialLoginStatus == null) {
      _socialLoginStatus = SocialLoginStatus(
        isLoggedInX: isLoggedInX,
        isLoggedInFb: isLoggedInFb,
        isLoggedInInstagram: isLoggedInIns,
        isLoggedInTikTok: isLoggedInTT,
      );
      logEvent(
        isLoggedInX
            ? AEvents.socialInitStatusXLoggedIn
            : AEvents.socialInitStatusXLoggedOut,
      );
      logEvent(
        isLoggedInFb
            ? AEvents.socialInitStatusFbLoggedIn
            : AEvents.socialInitStatusFbLoggedOut,
      );
      logEvent(
        isLoggedInIns
            ? AEvents.socialInitStatusInstagramLoggedIn
            : AEvents.socialInitStatusInstagramLoggedOut,
      );
      logEvent(
        isLoggedInTT
            ? AEvents.socialInitStatusTikTokLoggedIn
            : AEvents.socialInitStatusTikTokLoggedOut,
      );
    } else {
      if (isLoggedInX != _socialLoginStatus!.isLoggedInX) {
        logEvent(
          isLoggedInX ? AEvents.onSocialLogInX : AEvents.onSocialLogOutX,
        );
      }
      if (isLoggedInFb != _socialLoginStatus!.isLoggedInFb) {
        logEvent(
          isLoggedInFb ? AEvents.onSocialLogInFb : AEvents.onSocialLogOutFb,
        );
      }
      if (isLoggedInIns != _socialLoginStatus!.isLoggedInInstagram) {
        logEvent(
          isLoggedInIns
              ? AEvents.onSocialLogInInstagram
              : AEvents.onSocialLogOutInstagram,
        );
      }
      if (isLoggedInTT != _socialLoginStatus!.isLoggedInTikTok) {
        logEvent(
          isLoggedInTT
              ? AEvents.onSocialLogInTikTok
              : AEvents.onSocialLogOutTikTok,
        );
      }
      _socialLoginStatus = SocialLoginStatus(
        isLoggedInX: isLoggedInX,
        isLoggedInFb: isLoggedInFb,
        isLoggedInInstagram: isLoggedInIns,
        isLoggedInTikTok: isLoggedInTT,
      );
    }
  }
}

class SocialLoginStatus {
  final bool isLoggedInX;
  final bool isLoggedInFb;
  final bool isLoggedInInstagram;
  final bool isLoggedInTikTok;

  SocialLoginStatus({
    required this.isLoggedInX,
    required this.isLoggedInFb,
    required this.isLoggedInInstagram,
    required this.isLoggedInTikTok,
  });
}

class AEvents {
  AEvents._();

  static String get initAppLoggedIn => 'init_app_logged_in';

  static String get initAppLoggedOut => 'init_app_logged_out';

  static String get appSignIn => 'sign_in';

  static String get appSignOut => 'sign_out';

  static String get openPushNotification => 'open_push_notification';

  static String get onPressButtonHomeSave => 'on_button_home_save';

  static String get onPressButtonHomeCancel => 'on_button_home_cancel';

  static String get onPressButtonHomeWVDoubletap =>
      'on_button_home_wv_double_tap';

  static String get onPressButtonLoginGoogle => 'on_button_login_google';

  static String get onPressButtonSettingsLanguage =>
      'on_button_settings_language';

  static String get onPressButtonSettingsFifiLifo =>
      'on_button_settings_fifo_lifo';

  static String get onPressButtonSettingsHeaderHeight =>
      'on_button_settings_headers_height';

  static String get onWVUrlChanged => 'on_wv_url_changed';

  static String get onPressButtonHeaderApproved => 'on_button_header_approved';

  static String get onPressButtonHeaderRejected => 'on_button_header_rejected';

  static String get onPressButtonHeaderApprovedAll =>
      'on_button_header_approved_all';

  static String get onPressButtonHeaderRejectedAll =>
      'on_button_header_rejected_all';

  static String get onPressButtonFooterBack => 'on_button_footer_back';

  static String get onPressButtonFooterForward => 'on_button_footer_forward';

  static String get onPressButtonFooterGoHome => 'on_button_footer_go_home';

  static String get onPressButtonFooterSettings => 'on_button_footer_settings';

  static String get socialInitStatusXLoggedIn =>
      'social_init_status_x_logged_in';

  static String get socialInitStatusFbLoggedIn =>
      'social_init_status_fb_logged_in';

  static String get socialInitStatusInstagramLoggedIn =>
      'social_init_status_instagram_logged_in';

  static String get socialInitStatusTikTokLoggedIn =>
      'social_init_status_tik_tok_logged_in';

  static String get socialInitStatusXLoggedOut =>
      'social_init_status_x_logged_out';

  static String get socialInitStatusFbLoggedOut =>
      'social_init_status_fb_logged_out';

  static String get socialInitStatusInstagramLoggedOut =>
      'social_init_status_instagram_logged_out';

  static String get socialInitStatusTikTokLoggedOut =>
      'social_init_status_tik_tok_logged_out';

  static String get onSocialLogInX => 'on_social_log_in_x';

  static String get onSocialLogInFb => 'on_social_log_in_fb';

  static String get onSocialLogInInstagram => 'on_social_log_in_instagram';

  static String get onSocialLogInTikTok => 'on_social_log_in_tik_tok';

  static String get onSocialLogOutX => 'on_social_log_out_x';

  static String get onSocialLogOutFb => 'on_social_log_out_fb';

  static String get onSocialLogOutInstagram => 'on_social_log_out_instagram';

  static String get onSocialLogOutTikTok => 'on_social_log_out_tik_tok';
}
