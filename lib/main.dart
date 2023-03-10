import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:chat_sample_app/core/routes/routes_manager.dart';
import 'package:chat_sample_app/core/routes/get_pages.dart';
import 'package:chat_sample_app/core/theme/theme_manager.dart';
import 'package:chat_sample_app/firebase/fb_notifications.dart';
import 'package:chat_sample_app/screens/core/unknown_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FbNotifications.initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(750, 1624),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(fontFamily: 'Montserrat'),
          themeMode: ThemeMode.dark,
          darkTheme: ThemeManager.dark(),
          initialRoute: RoutesManager.launchScreen,
          getPages: getPages,
          unknownRoute: GetPage(
            name: '/unknown_route',
            page: () => const UnknownScreen(),
          ),
        );
      },
    );
  }
}
