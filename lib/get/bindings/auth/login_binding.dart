import 'package:get/get.dart';
import 'package:chat_sample_app/get/controllers/auth/login_controller.dart';

class LoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
  }
}
