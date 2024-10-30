import 'package:firebase_messaging/firebase_messaging.dart';

import '../../main.dart';

class FirebaseApi {
  //Instance of Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  //Function to initialize notification
  Future<void> initNotifications() async {
    //Request permission from user (Prompt)
    await _firebaseMessaging.requestPermission();

    //Fetch FCM token for this device
    final fCMToken = await _firebaseMessaging.getToken();

    //Print Token (Testing - Normally goes to server)
    print('Token: $fCMToken');

    //Initialize Further settings for push notification
    initPushNotification();
  }

  //Function to handle received Messages
  void handleMessage(RemoteMessage? message) {
    if (message == null) return;

    navigatorKey.currentState?.pushNamed(
      '/notification_screen',
      arguments: message,
    );
  }

  //Function to initialize foreground and background settings
  Future initPushNotification() async {
    //Handle Notification if app was terminated and now opened
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);

    //Attach even listeners for when notification opens the app
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  }
}
