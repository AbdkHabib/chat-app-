import 'package:get/state_manager.dart';
import 'package:chat_sample_app/firebase/fb_firestore_users_controller.dart';

class HomeScreenController extends GetxController {
  final numOfOnlineUsers = 0.obs;
  final isLoggingOut = false.obs;
  final counterMessagingRequests = 0.obs;

  // @override
  // void onReady() async {
  // FbFireStoreUsersController().getPeerDetails(peerId)
  // super.onReady();
  // }
}
