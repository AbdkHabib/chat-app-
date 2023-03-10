import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:chat_sample_app/core/routes/routes_manager.dart';
import 'package:chat_sample_app/firebase/fb_auth_controller.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({Key? key}) : super(key: key);

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 3),
      () {
        Get.offNamed(
          (FbAuthController().loggedIn &&
                  FbAuthController().currentUser!.uid.isNotEmpty)
              ? RoutesManager.homeScreen
              : RoutesManager.loginScreen,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Type App',
              style: TextStyle(fontSize: 80.sp),
            ),
          ],
        ),
      ),
    );
  }
}
