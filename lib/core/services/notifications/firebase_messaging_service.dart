import 'dart:convert';
import 'dart:io' show Platform;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/routes/app_routes.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:anestrack_mobile/modules/common/devices/domain/usecases/device_usecases.dart';
import 'package:anestrack_mobile/modules/common/notifications/domain/usecases/notification_usecases.dart';
import 'package:anestrack_mobile/modules/common/notifications/presentation/blocs/unread_count_bloc.dart';

/// Android notification channel used to display foreground/heads-up messages.
/// Its id must match the `default_notification_channel_id` meta-data declared
/// in AndroidManifest.xml so background FCM messages land in the same channel.
const AndroidNotificationChannel kDefaultChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'الإشعارات العامة',
  description: 'إشعارات AnesTrack',
  importance: Importance.high,
);

/// firebase_messaging only ships Android/iOS platform implementations — on
/// Windows/web (both real `flutter run` targets for this repo) FCM calls
/// throw. Firebase.initializeApp()/FirebaseMessagingService must be skipped
/// there, same guard style as show_toast.dart's `!kIsWeb && Platform.isX`.
bool get isPushNotificationSupportedPlatform =>
    !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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
/// Responsibilities:
/// - initialise Firebase + FCM,
/// - request the runtime notification permission,
/// - display foreground messages via a local notification channel,
/// - register/unregister this device with the backend (integration-mobile.md
///   §2) so it receives direct and broadcast pushes,
/// - route a notification tap (foreground, background, or terminated launch)
///   to the right screen and mark the underlying row read (§3).
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
    if (!isPushNotificationSupportedPlatform) return;
    if (_initialised) return;
    _initialised = true;

    await _requestPermission();
    await _setupLocalNotifications();

    // Show foreground messages ourselves (FCM does not display them on Android
    // while the app is in the foreground), and keep the bell badge live.
    FirebaseMessaging.onMessage.listen((message) {
      _showForegroundNotification(message);
      sl<UnreadCountBloc>().add(FetchUnreadCountEvent());
    });

    // App was backgrounded (not terminated) and the user tapped the tray
    // notification to bring it back to the foreground.
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => _handleNotificationTap(message.data),
    );

    // App was launched cold by tapping the tray notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage.data);
    }

    // Log the token and, if the user is already logged in (app relaunch),
    // register this device straight away.
    await logToken();
    await registerCurrentDeviceIfLoggedIn();
    _messaging.onTokenRefresh.listen((token) {
      _logger.i('FCM token refreshed: $token');
      registerCurrentDeviceIfLoggedIn();
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
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        final data = Map<String, dynamic>.from(
          jsonDecode(payload) as Map<String, dynamic>,
        );
        _handleNotificationTap(data);
      },
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

  /// Marks the notification read and routes to the relevant screen, per the
  /// `data.type` contract in integration-mobile.md §3. Runs for a tap on the
  /// in-app foreground toast, the OS tray notification, or a cold launch.
  void _handleNotificationTap(Map<String, dynamic> data) {
    final id = data['notificationId'] as String?;
    if (id != null && id.isNotEmpty) {
      sl<MarkNotificationReadUseCase>()(id);
      sl<UnreadCountBloc>().add(FetchUnreadCountEvent());
    }

    final isStudent = CacheService().userRole == 'Student';
    final String? route;
    switch (data['type']) {
      case 'Approval':
      case 'Rejection':
        // The student's own procedure was co-signed/confirmed/rejected.
        route = isStudent ? '/student-home/procedures' : null;
        break;
      case 'Announcement':
        route = '/announcements';
        break;
      case 'Lecture':
        route = isStudent ? '/student-home/education' : '/supervisor/acadamic';
        break;
      default:
        route = null;
    }

    AppRoutes.router.push(route ?? '/notifications');
  }

  /// Current FCM registration token (null if unavailable, e.g. no Play services).
  Future<String?> getToken() => _messaging.getToken();

  Future<void> logToken() async {
    final token = await getToken();
    _logger.i('FCM token: $token');
  }

  /// Registers this device with the backend (integration-mobile.md §2) so it
  /// receives direct and broadcast pushes. No-op while logged out — the
  /// endpoint requires a session token. Fire-and-forget: called from login
  /// success and from `onTokenRefresh`, neither of which should block on it.
  Future<void> registerCurrentDeviceIfLoggedIn() async {
    if (!isPushNotificationSupportedPlatform) return;
    if (!CacheService().hasToken) return;

    final token = await getToken();
    if (token == null) return;

    final result = await sl<RegisterDeviceUseCase>()(
      token: token,
      platform: Platform.isIOS ? 'ios' : 'android',
      deviceInfo: '${Platform.operatingSystem} ${Platform.operatingSystemVersion}',
    );
    result.fold(
      (failure) => _logger.e('registerDevice failed: ${failure.message}'),
      (_) => _logger.i('Device registered for push notifications'),
    );
  }

  /// Call before clearing the session on logout, while the session token is
  /// still valid — see integration-mobile.md §2 (`unregisterDevice`).
  Future<void> unregisterCurrentDevice() async {
    if (!isPushNotificationSupportedPlatform) return;

    final token = await getToken();
    if (token == null) return;

    final result = await sl<UnregisterDeviceUseCase>()(token);
    result.fold(
      (failure) => _logger.e('unregisterDevice failed: ${failure.message}'),
      (_) => _logger.i('Device unregistered from push notifications'),
    );
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
