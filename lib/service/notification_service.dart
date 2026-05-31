import 'dart:developer';
import 'dart:io';
import 'package:family_management_app/service/secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Call this in main() after Firebase.initializeApp()
  static Future<void> initFCM() async {
    await requestPermission();
    await initLocalNotification();

    // ✅ iOS foreground notification display
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    String? fcmtoken;

    if (Platform.isIOS) {
      // iOS: wait for APNs first (required)
      String? apnsToken = await _messaging.getAPNSToken();

      int attempts = 0;
      while (apnsToken == null && attempts < 8) {
        await Future.delayed(const Duration(milliseconds: 800));
        apnsToken = await _messaging.getAPNSToken();
        attempts++;
      }

      if (apnsToken == null) {
        log("⚠️ iOS APNS token not ready yet. Skipping FCM token for now.");
        return;
      }

      fcmtoken = await _messaging.getToken();
    } else {
      // Android: direct safe call
      fcmtoken = await _messaging.getToken();
    }

    if (fcmtoken != null) {
      await AppStorage.save(key: "fcmToken", data: fcmtoken);
      log("FCM Token: $fcmtoken");
    }
    // ✅ Get FCM Token
    // String? fcmtoken = await _messaging.getToken();
    // if (fcmtoken != null) {
    //   await AppStorage.save(key: "fcmToken", data: fcmtoken);
    //   log("FCM Token: $fcmtoken");
    // }

    // ✅ Foreground listener
    FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
      log("Foreground message: ${msg.notification?.title}");
      showFCMNotification(msg);
    });

    // ✅ Notification tap listener (background or terminated)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage msg) {
      log('Notification opened: ${msg.notification?.title}');
      if (msg.data.containsKey('payload')) {
        handleNotificationTap(msg.data['payload']);
      }
    });
  }

  /// Request push notification permission
  static Future<bool> requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log("🚫 Notification permission denied");
      return false;
    } else {
      log("✅ Notification permission granted");
      return true;
    }
  }

  /// Local notification initialization
  static Future<void> initLocalNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        log("Notification tapped with payload: ${response.payload}");
        if (response.payload != null) {
          handleNotificationTap(response.payload!);
        }
      },
    );
  }

  /// Handle notification tap
  static void handleNotificationTap(String payload) {
    log("Handle navigation for payload: $payload");
    // TODO: Navigate to different screens based on payload
    // Example: if (payload == "board_created") { navigateToBoardScreen(); }
  }

  /// Show FCM notification
  static Future<void> showFCMNotification(RemoteMessage msg) async {
    final androidDetails = AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      channelDescription: "Channel for important notifications",
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      msg.hashCode,
      msg.notification?.title ?? '',
      msg.notification?.body ?? '',
      details,
      payload: msg.data['payload'] ?? '', // use custom data from FCM if any
    );
  }

  /// Show a local notification instantly (Board Created)
  static Future<void> showLocalBoardCreatedNotification() async {
    await _showLocalNotification(
      id: 0,
      title: "Board Created",
      body: "Your board has been successfully created!",
      payload: "board_created",
    );
  }

  /// Show a local notification instantly (Board Joining Request)
  static Future<void> showLocalBoardJoiningNotification() async {
    await _showLocalNotification(
      id: 1,
      title: "Request Sent",
      body: "Your request to join the board has been sent!",
      payload: "board_join_request",
    );
  }

  /// Helper function to show local notification
  static Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required String payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      "high_importance_channel",
      "High Importance Notifications",
      channelDescription: "Channel for important notifications",
      importance: Importance.high,
      priority: Priority.high,
    );

    final iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
}

/// Background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage msg) async {
  log("📩 Background message: ${msg.notification?.title}");
}
