import 'package:app/firebase.dart';
import 'package:get/get.dart';

class AuthenticationService extends GetxService {
  bool isLoggedIn() {
    return (auth.currentUser != null);
  }
}
