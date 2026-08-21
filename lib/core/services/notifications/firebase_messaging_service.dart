import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';

/// Android notification channel used to display foreground/heads-up messages.
/// Its id must match the `default_notification_channel_id` meta-data declared
/// in AndroidManifest.xml so background FCM messages land in the same channel.
const AndroidNotificationChannel kDefaultChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'الإشعارات العامة',
  description: 'إشعارات AnesTrack',
  importance: Importance.high,
);

/// Handles background/terminated FCM messages. Must be a top-level function
/// annotated with `@pragma('vm:entry-point')` because it runs in a separate
/// isolate with no access to app state.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase must be re-initialised in the background isolate.
  await Firebase.initializeApp();
  // Notification-type messages are shown by the system automatically; nothing
  // else is required here for the notifications-only setup.
}

/// Thin wrapper around Firebase Cloud Messaging for the notifications feature.
///
/// Responsibilities (notifications only):
/// - initialise Firebase + FCM,
/// - request the runtime notification permission,
/// - display foreground messages via a local notification channel,
/// - expose the FCM token and topic (channel) subscription helpers.
///
/// Topic/channel subscription and backend token registration are intentionally
/// left to the caller — the app decides *which* channels a user subscribes to.
class FirebaseMessagingService {
  FirebaseMessagingService._();
  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final Logger _logger = Logger();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  bool _initialised = false;

  /// Call once, after `Firebase.initializeApp()`, early in app startup.
  Future<void> init() async {
    if (_initialised) return;
    _initialised = true;

    await _requestPermission();
    await _setupLocalNotifications();

    // Show foreground messages ourselves (FCM does not display them on Android
    // while the app is in the foreground).
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // Log the token so it can be wired to the backend later.
    await logToken();
    _messaging.onTokenRefresh.listen((token) {
      _logger.i('FCM token refreshed: $token');
    });
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission();
    _logger.i(
      'Notification permission: ${settings.authorizationStatus.name}',
    );
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    await _localNotifications.initialize(
      settings: const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Register the Android channel (safe to call repeatedly).
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(kDefaultChannel);
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;

    _localNotifications.show(
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          kDefaultChannel.id,
          kDefaultChannel.name,
          channelDescription: kDefaultChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: message.data.isEmpty ? null : jsonEncode(message.data),
    );
  }

  /// Current FCM registration token (null if unavailable, e.g. no Play services).
  Future<String?> getToken() => _messaging.getToken();

  Future<void> logToken() async {
    final token = await getToken();
    _logger.i('FCM token: $token');
  }

  /// Subscribe the device to a topic ("channel"). Wired by the caller once the
  /// channel rules are defined.
  Future<void> subscribeToChannel(String channel) async {
    await _messaging.subscribeToTopic(channel);
    _logger.i('Subscribed to channel: $channel');
  }

  Future<void> unsubscribeFromChannel(String channel) async {
    await _messaging.unsubscribeFromTopic(channel);
    _logger.i('Unsubscribed from channel: $channel');
  }
}
