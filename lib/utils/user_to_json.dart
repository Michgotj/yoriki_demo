import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

Map<String, dynamic> userToJson(User user) {
  return {
    'displayName': user.displayName,
    'email': user.email,
    'isEmailVerified': user.emailVerified,
    'isAnonymous': user.isAnonymous,
    'creationTime': user.metadata.creationTime!.toIso8601String(),
    'lastSignInTime': user.metadata.lastSignInTime!.toIso8601String(),
    'phoneNumber': user.phoneNumber,
    'photoURL': user.photoURL,
    'providerData': user.providerData
        .map((info) => {
              'displayName': info.displayName,
              'email': info.email,
              'phoneNumber': info.phoneNumber,
              'photoURL': info.photoURL,
              'providerId': info.providerId,
              'uid': info.uid,
            })
        .toList(),
    'refreshToken': user.refreshToken,
    'tenantId': user.tenantId,
    'uid': user.uid,
  };
}

class utils {
  static String getRandomElement(Map<String, dynamic> notificationJson) {
    List<String> myArray = notificationJson['extra_text'].cast<String>();
    // Filter out empty strings
    List<String> filteredArray =
        myArray.where((item) => item.isNotEmpty).toList();
    String text = '';
    // Check if there are any non-empty elements
    if (filteredArray.isNotEmpty) {
      // Choose a random element (using Random class)
      Random random = Random();
      text = filteredArray[random.nextInt(filteredArray.length)];
      print("Randomly chosen element: $text");
    } else {
      print("No non-empty elements found in the array");
    }
    return text;
  }
}
