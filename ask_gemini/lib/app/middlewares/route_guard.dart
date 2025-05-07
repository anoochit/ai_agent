import 'package:app/app/routes/app_pages.dart';
import 'package:app/app/services/auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RouteGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (Get.find<AuthenticationService>().isLoggedIn()) {
      // Allow access to the route
      return null;
    } else {
      // Redirect to login page if not logged in
      return const RouteSettings(name: Routes.LOGIN);
    }
  }
}
