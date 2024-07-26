import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'package:lightmachine/views/login/login.dart';
import 'package:lightmachine/views/splash/splash.dart';

import 'views/home/home.dart';

final routes = [
  GetPage(
    name: '/splash',
    page: () => const SplashScreen(),
  ),
  GetPage(
    name: '/',
    page: () => const HomeScreen(),
  ),
  GetPage(
    name: '/login',
    page: () => const LoginScreen(),
  ),
];