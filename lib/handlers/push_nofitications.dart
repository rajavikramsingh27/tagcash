import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:tagcash/services/networking.dart';

import 'agent_notification_handler.dart';
import 'lending_notification_handler.dart';
import 'models/received_status.dart';
import 'wallet_nofitication_handler.dart';
import 'dating_nofitication_handler.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      _firebaseMessaging.requestPermission();
      _initialized = true;
    }

    _firebaseMessaging
        .getToken(
            vapidKey:
                'BLytunpLBVC_xMr7axWX1h8z97FmSx0GtpwLPU26piHlp8qbsJF8My39201J2Ejc_3nWcCYlXiQj-J-hNLu6_-4')
        .then((token) {
      print("FirebaseMessaging token: $token");
      fcmRegister(token);
    });
  }

  void fcmRegister(String token) async {
    Map<String, String> apiBodyObj = {};
    apiBodyObj['fcm_regid'] = token;

    Map<String, dynamic> response =
        await NetworkHelper.request('FCM/Register', apiBodyObj);

    if (response['status'] == 'success') {
      // Map responseMap = response['result'];
    }
  }

  void listen(GlobalKey<NavigatorState> navigatorKey) {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage message) {
      if (message != null) {
        print('on launch $message');
        processNotification(
            navigatorKey.currentContext, ReceivedStatus.launch, message);
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('on message $message');
      processNotification(
          navigatorKey.currentContext, ReceivedStatus.message, message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');

      print('on resume $message');
      processNotification(
          navigatorKey.currentContext, ReceivedStatus.resume, message);
    });
  }

  processNotification(BuildContext context, ReceivedStatus receivedStatus,
      RemoteMessage message) {
    String activePage = '';

    Navigator.popUntil(context, (route) {
      print(route.settings.name);
      activePage = route.settings.name.toString();
      return true;
    });

    String nofiticationAction = message.data['action'];
    switch (nofiticationAction.toUpperCase()) {
      case 'WALLET':
        WalletNofiticationHandler walletHandler = WalletNofiticationHandler();
        walletHandler.messageProcess(
            context, receivedStatus, activePage, message);
        break;

      case 'AGENT':
        AgentNotificationHandler agentHandler = AgentNotificationHandler();
        agentHandler.messageProcess(
            context, receivedStatus, activePage, message);
        break;

      case 'LENDING':
        LendingNotificationHandler lendHandler = LendingNotificationHandler();
        lendHandler.messageProcess(
            context, receivedStatus, activePage, message);
        break;
      case 'DATING':
        DatingNofiticationHandler datingHandler = DatingNofiticationHandler();
        datingHandler.messageProcess(
            context, receivedStatus, activePage, message);
        break;
    }
  }
}
