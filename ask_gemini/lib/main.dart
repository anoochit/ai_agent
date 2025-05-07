import 'package:app/app/services/auth.dart';
import 'package:app/firebase.dart';
import 'package:app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';

Future<void> main() async {
  // Ensure that the Flutter engine is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Use emulators if available
  if (kDebugMode) {
    auth.useAuthEmulator('127.0.0.1', 9099);
    firestore.useFirestoreEmulator('127.0.0.1', 8080);
  }

  Get.put(AuthenticationService(), permanent: true);

  runApp(
    GetMaterialApp(
      title: "AI Agent",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      theme: ThemeData(colorSchemeSeed: Colors.blueGrey),
    ),
  );
}
