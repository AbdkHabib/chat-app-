import 'dart:convert';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chat_sample_app/firebase_options.dart';
import 'package:chat_sample_app/models/notification_model.dart';
import 'package:http/http.dart' as http;
import 'package:chat_sample_app/models/process_response.dart';

Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

mixin FbNotifications {
  static Future<void> initNotifications() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> requestNotificationPermissions() async {
    NotificationSettings notificationSettings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      announcement: false,
      provisional: false,
      criticalAlert: false,
    );
    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      log('GRANT PERMISSION');
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      log('Permission Denied');
    }
  }

  Future<ProcessResponse> sendNotification(
      {required NotificationModel notificationModel}) {
    return http
        .post(Uri.parse("https://fcm.googleapis.com/fcm/send"),
            headers: <String, String>{
              "Authorization":
                  "key=AAAAqeAmiY0:APA91bFDcJvG4xqhTm2AEY3k1JLXnQcdlOgSmC7zJNA9ZcBhyNqiO2rjcnJW7SStBmc7-QqtsrhEn1kxdkUPQvDnO3bFJoIruccGblb-1xBMqT8M09DQEgjm7xNsbTE3TBxsMx4JFUiK",
              "Content-Type": "application/json; charset=UTF-8"
            },
            body: json.encode(notificationModel.toJson()))
        .then((data) {
      return ProcessResponse(data.body);
    }).catchError((e) {
      ProcessResponse(e.toString(), false);
    });
  }
}
