import 'package:get/get.dart';
import 'package:chat_sample_app/get/controllers/auth/forget_password_controller.dart';

class ForgetPasswordBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgetPasswordController());
  }
}
