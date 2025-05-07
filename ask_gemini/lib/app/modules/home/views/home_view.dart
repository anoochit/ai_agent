import 'package:app/app/routes/app_pages.dart';
import 'package:app/firebase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('HomeView is working', style: TextStyle(fontSize: 20)),
            (auth.currentUser != null)
                ? FilledButton(
                  onPressed: () => Get.toNamed(Routes.CHAT),
                  child: Text('Start Chat'),
                )
                : FilledButton(
                  onPressed: () => Get.toNamed(Routes.LOGIN),
                  child: Text('Login'),
                ),
          ],
        ),
      ),
    );
  }
}
