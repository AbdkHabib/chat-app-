import 'package:get/get.dart';
import 'package:chat_sample_app/get/controllers/app/home_screen_controller.dart';

class HomeScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeScreenController());
  }
}
