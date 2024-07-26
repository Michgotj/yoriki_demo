import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lightmachine/models/services/feature_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/user_to_json.dart';
import 'analytics_service.dart';

AuthService get authService => Get.find<AuthService>();

class AuthService extends GetxService {
  RxBool isAuthorized = false.obs;
  FirebaseAuth? _auth;
  GoogleSignIn? _googleSignIn;
  GoogleSignInAuthentication? _googleSignInAuthentication;

  Future<AuthService> init() async {
    if (!featureService.isFirebaseEnabled) {
      return this;
    }
    _auth = FirebaseAuth.instance;
    _googleSignIn = GoogleSignIn();
    _auth?.authStateChanges().listen((User? user) {
      debugPrint('$runtimeType authStateChanges user: $user');
      isAuthorized.value = user != null;
    });
    return this;
  }

  Future<bool> updateAuthStatus() async {
    if (!featureService.isFirebaseEnabled) {
      return true;
    }
    debugPrint('$runtimeType updateAuthStatus startr');
    if (currentUser == null) {
      isAuthorized.value = false;
      debugPrint('$runtimeType updateAuthStatus false');
      aService.logAppOpen(false);
    } else {
      try {
        await currentUser?.reload();
        aService.logAppOpen(true);
        isAuthorized.value = true;
        debugPrint('$runtimeType updateAuthStatus true');
      } catch (e) {
        aService.logAppOpen(false);
        await signOutGoogle();
        isAuthorized.value = false;
        debugPrint('$runtimeType updateAuthStatus false');
      }
    }
    return isAuthorized.value;
  }

  User? get currentUser => _auth?.currentUser;

  Future<User> signInWithGoogle() async {
    if (!featureService.isFirebaseEnabled) {
      throw Exception('Authorisation is not supported');
    }
    try {
      final googleUser = await _googleSignIn?.signIn();
      _googleSignInAuthentication = await googleUser?.authentication;
      final credentials = GoogleAuthProvider.credential(
          accessToken: _googleSignInAuthentication?.accessToken,
          idToken: _googleSignInAuthentication?.idToken);
      final userCredentials = await _auth?.signInWithCredential(credentials);
      final user = currentUser;
      if (user == null) {
        throw Exception('User is absent');
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userInfo', jsonEncode(userToJson(currentUser!)));
      aService.logEvent(AEvents.appSignIn);
      return user;
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> signOutGoogle() async {
    if (!featureService.isFirebaseEnabled) {
      throw Exception('Authorisation is not supported');
    }
    try {
      try {
        await _googleSignIn?.signOut();
      } catch (e) {
        // ignore
      }
      await _auth?.signOut();
      aService.logEvent(AEvents.appSignOut);
    } catch (e) {
      debugPrint('$e');
    }
  }

  /// if [FirebaseAuthException]:
  /// e.code == 'weak-password'
  /// e.code == 'email-already-in-use'
  Future<User> signUpWithPassword(
    String email,
    String password,
    String name,
  ) async {
    final credential = await _auth?.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await currentUser?.updateDisplayName(name);
    final user = currentUser;
    if (user == null) {
      throw Exception('User is absent');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userInfo', jsonEncode(userToJson(currentUser!)));
    aService.logEvent(AEvents.appSignIn);
    return user;
  }

  /// if [FirebaseAuthException]:
  /// e.code == 'user-not-found'
  /// e.code == 'wrong-password'
  Future<User> signInWithPassword(String email, String password) async {
    final credential = await _auth?.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = currentUser;
    if (user == null) {
      throw Exception('User is absent');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userInfo', jsonEncode(userToJson(currentUser!)));
    aService.logEvent(AEvents.appSignIn);
    return user;
  }
}
