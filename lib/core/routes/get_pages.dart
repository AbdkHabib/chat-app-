import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:chat_sample_app/core/routes/routes_manager.dart';
import 'package:chat_sample_app/get/bindings/app/home_screen_binding.dart';
import 'package:chat_sample_app/get/bindings/app/profile_screen_binding.dart';
import 'package:chat_sample_app/get/bindings/auth/change_password_binding.dart';
import 'package:chat_sample_app/get/bindings/auth/forget_password_binding.dart';
import 'package:chat_sample_app/get/bindings/auth/login_binding.dart';
import 'package:chat_sample_app/get/bindings/auth/register_binding.dart';
import 'package:chat_sample_app/screens/app/all_contacts_screen.dart';
import 'package:chat_sample_app/screens/app/chat_screen.dart';
import 'package:chat_sample_app/screens/app/home_screen.dart';
import 'package:chat_sample_app/screens/app/message_requests_screen.dart';
import 'package:chat_sample_app/screens/app/profile_screen.dart';
import 'package:chat_sample_app/screens/auth/change_password_screen.dart';
import 'package:chat_sample_app/screens/auth/forget_password_screen.dart';
import 'package:chat_sample_app/screens/auth/login_screen.dart';
import 'package:chat_sample_app/screens/auth/register_screen.dart';
import 'package:chat_sample_app/screens/core/launch_screen.dart';

final List<GetPage<dynamic>> getPages = [
  GetPage(
    name: RoutesManager.launchScreen,
    page: () => const LaunchScreen(),
  ),
  GetPage(
    name: RoutesManager.loginScreen,
    page: () => const LoginScreen(),
    binding: LoginBinding(),
  ),
  GetPage(
    name: RoutesManager.registerScreen,
    page: () => const RegisterScreen(),
    binding: RegisterBinding(),
  ),
  GetPage(
    name: RoutesManager.forgetPasswordScreen,
    page: () => const ForgetPasswordScreen(),
    binding: ForgetPasswordBinding(),
  ),
  GetPage(
    name: RoutesManager.changePasswordScreen,
    page: () => const ChangePasswordScreen(),
    binding: ChangePasswordBinding(),
  ),
  GetPage(
    name: RoutesManager.homeScreen,
    page: () => const HomeScreen(),
    binding: HomeScreenBinding(),
  ),
  GetPage(
    name: RoutesManager.chatScreen,
    page: () => const ChatScreen(),
  ),
  GetPage(
    name: RoutesManager.allContactsScreen,
    page: () => const AllContactsScreen(),
  ),
  GetPage(
    name: RoutesManager.profileScreen,
    page: () => const ProfileScreen(),
    binding: ProfileScreenBinding(),
  ),
  GetPage(
    name: RoutesManager.messageRequestsScreen,
    page: () => const MessageRequestsScreen(),
  ),
];
