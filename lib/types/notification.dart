import 'package:flutter/foundation.dart';
import 'package:lightmachine/types/social_type.dart';
import 'package:lightmachine/utils/domain.dart';
import 'package:lightmachine/utils/link_preview_util.dart';
import 'package:uuid/uuid.dart';

class NotificationType {
  NotificationType(
      {String? id,
      required this.socialType,
      required this.link,
      required this.content,
      required this.imageUrl,
      required this.timestamp})
      : id = id ?? const Uuid().v1();

  final String id;
  final SocialType socialType;
  final String link;
  String content;
  String? imageUrl;
  final DateTime timestamp;

  NotificationType.fromJson(Map<String, dynamic> json)
      : id = json['id'] ?? const Uuid().v1(),
        socialType = getSocialType(json['social']),
        link = json['link'],
        content = json['content'],
        imageUrl = json['imageUrl'],
        timestamp = DateTime.parse(json['timestamp']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'social': getSocialTypeString(socialType),
        'link': link,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
        'imageUrl': imageUrl,
      };

  static Future<NotificationType> createFromNotificationJson(
      Map<String, dynamic> json) async {
    final link = _parseUrl(json['link']);
    final imgPreview = await LinkPreviewUtil.getPreviewImageUrl(link);
    debugPrint('imgPreview  $imgPreview');
    final model = NotificationType(
        id: json['id'] ?? const Uuid().v1(),
        socialType: getSocialType(getDomain(link)),
        link: link,
        content: json['extra_text'],
        imageUrl: imgPreview?.url,
        timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']));
    return model;
  }
}

String _parseUrl(String text) {
  String url = text.replaceAll(RegExp(r'[<>]'), '').split('|')[0];
  if (url.split('://')[0] == 'http') {
    url = url.replaceFirst('http', 'https');
  }
  return url;
}

/*
 FormatException: Scheme not starting with alphabetic character (at character 1)
05-09 13:51:39.782 17059 17117 I flutter : *Nahum Nir*  [1:26 PM]
05-09 13:51:39.782 17059 17117 I flutter : ^
05-09 13:51:39.782 17059 17117 I flutter : , #0      _Uri._fail (dart:core/uri.dart:1734)
05-09 13:51:39.782 17059 17117 I flutter : #1      _Uri._makeScheme (dart:core/uri.dart:2270)
05-09 13:51:39.782 17059 17117 I flutter : #2      new _Uri.notSimple (dart:core/uri.dart:1596)
05-09 13:51:39.782 17059 17117 I flutter : #3      Uri.parse (dart:core/uri.dart:1138)
05-09 13:51:39.782 17059 17117 I flutter : #4      getDomain (package:lightmachine/utils/domain.dart:2)
05-09 13:51:39.782 17059 17117 I flutter : #5      new NotificationType.fromNotificationJson (package:lightmachine/types/notification.dart:31)
05-09 13:51:39.782 17059 17117 I flutter : #6      NotificationController.addNotification (package:lightmachine/models/notification_controller.dart:43)
05-09 13:51:39.782 17059 17117 I flutter : #7      _TitleBarState.init.<anonymous closure> (package:lightmachine/components/layouts/titlebar.dart:113)
05-09 13:51:39.782 17059 17117 I flutter : #8      _RootZone.runUnaryGuarded (dart:async/zone.dart:1594)
05-09 13:51:39.782 17059 17117 I flutter : #9      _BufferingStreamSubscription._sendData (dart:async/stream_impl.dart:339)
05-09 13:51:39.782 17059 17117 I flutter : #10     _DelayedData.perform (dart:async/stream_impl.dart:515)
05-09 13:51:39.782 17059 17117 I flutter : #11     _PendingEvents.handleNext (dart:async/stream_impl.dart:620)
05-09 13:51:39.782 17059 17117 I flutter : #12     _PendingEvents.schedule.<anonymous closure> (dart:async/stream_impl.dart:591)
05-09 13:51:39.782 17059 17117 I flutter : #13     _microtaskLoop (dart:async/schedule_microtask.dart:40)
05-09 13:51:39.782 17059 17117 I flutter : #14     _startMicrotaskLoop (dart:async/schedule_microtask.dart:49)
05-09 13:51:39.782 17059 17117 I flutter :
05-09 13:51:39.835 17059 18533 W FirebaseMessaging: Unable to log event: analytics library is missing
*/
