import 'dart:convert';
import 'dart:io';

import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/chat/controller/chat_controller.dart';
import 'package:abaad_flutter/features/notification/controller/notification_controller.dart';
import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

const String _channelId = 'abaad_notifications';
const String _channelName = 'أبعاد';

final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// معالج رسائل FCM في الخلفية/عند إغلاق التطبيق — يجب أن تكون top-level (أو
/// static) لأن Flutter يستدعيها في isolate منفصل. لا حاجة لعرض إشعار يدويًا
/// هنا: عندما يحتوي الحمل على `notification` (وليس data-only) يعرضه نظام
/// التشغيل تلقائيًا؛ هذه الدالة موجودة فقط لتسجيل المعالج مع FCM.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

class NotificationHelper {
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidInitialize =
        AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings iosInitialize =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitialize,
      iOS: iosInitialize,
    );

    await _localNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handlePayload(response.payload);
      },
    );

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          importance: Importance.max,
        ));

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
  }

  /// التطبيق مفتوح حاليًا (foreground) — النظام لا يعرض الإشعار تلقائيًا في
  /// هذه الحالة، لذا نعرضه يدويًا عبر flutter_local_notifications، إلا إذا
  /// كانت محادثة الرسالة نفسها مفتوحة أمام المستخدم فنكتفي بتحديث القائمة.
  static void _onForegroundMessage(RemoteMessage message) {
    final NotificationBody notificationBody = _convert(message.data);

    if (notificationBody.notificationType == NotificationType.message &&
        Get.currentRoute.startsWith(RouteHelper.conversation)) {
      if (Get.isRegistered<ChatController>() &&
          Get.isRegistered<AuthController>() &&
          Get.find<AuthController>().isLoggedIn()) {
        Get.find<ChatController>().getConversationList(1);
      }
      return;
    }

    _showNotification(message);

    if (Get.isRegistered<NotificationController>() &&
        Get.isRegistered<AuthController>() &&
        Get.find<AuthController>().isLoggedIn()) {
      Get.find<NotificationController>().getNotificationList(true);
    }
  }

  static Future<void> _showNotification(RemoteMessage message) async {
    final String title = message.notification?.title ??
        (message.data['title'] ?? '').toString();
    final String body =
        message.notification?.body ?? (message.data['body'] ?? '').toString();
    if (title.isEmpty && body.isEmpty) return;

    final String? imageUrl =
        message.notification?.android?.imageUrl ??
            message.notification?.apple?.imageUrl;
    final String payload = jsonEncode(_convert(message.data).toJson());

    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        await _showBigPictureNotification(title, body, imageUrl, payload);
        return;
      } catch (_) {
        // فشل تنزيل الصورة (لا اتصال/رابط غير صالح) — نكمل بإشعار نصي.
      }
    }
    await _showBigTextNotification(title, body, payload);
  }

  static Future<void> _showBigTextNotification(
    String title,
    String body,
    String payload,
  ) async {
    final BigTextStyleInformation styleInformation = BigTextStyleInformation(
      body,
      htmlFormatBigText: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
    );
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: styleInformation,
      playSound: true,
    );
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );
    await _localNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  static Future<void> _showBigPictureNotification(
    String title,
    String body,
    String imageUrl,
    String payload,
  ) async {
    final String bigPicturePath =
        await _downloadAndSaveFile(imageUrl, 'bigPicture');
    final BigPictureStyleInformation styleInformation =
        BigPictureStyleInformation(
      FilePathAndroidBitmap(bigPicturePath),
      hideExpandedLargeIcon: true,
      contentTitle: title,
      htmlFormatContentTitle: true,
      summaryText: body,
      htmlFormatSummaryText: true,
    );
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      _channelId,
      _channelName,
      importance: Importance.max,
      priority: Priority.max,
      styleInformation: styleInformation,
      playSound: true,
    );
    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );
    await _localNotificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  static Future<String> _downloadAndSaveFile(
    String url,
    String fileName,
  ) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  /// الضغط على الإشعار وفتح التطبيق من الخلفية.
  static void _handleMessage(RemoteMessage message) {
    _navigate(_convert(message.data));
  }

  /// الضغط على الإشعار المحلي المعروض بينما التطبيق مفتوح (foreground).
  static void _handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      _navigate(NotificationBody.fromJson(jsonDecode(payload)));
    } catch (_) {}
  }

  static void _navigate(NotificationBody notificationBody) {
    if (notificationBody.notificationType == NotificationType.message &&
        notificationBody.conversationId != null &&
        notificationBody.conversationId != 0) {
      Get.toNamed(RouteHelper.getChatRoute(
        notificationBody: notificationBody,
        conversationID: notificationBody.conversationId,
        index: 0,
      ));
    } else if (notificationBody.notificationType == NotificationType.offerStatus ||
        notificationBody.notificationType == NotificationType.subscriptionStatus) {
      Get.toNamed(RouteHelper.getMyServicesRoute());
    } else {
      Get.toNamed(RouteHelper.getNotificationRoute());
    }
  }

  static NotificationBody _convert(Map<String, dynamic> data) {
    if (data['type'] == 'message') {
      return NotificationBody(
        notificationType: NotificationType.message,
        conversationId: int.tryParse(data['conversation_id'].toString()),
      );
    }
    if (data['type'] == 'offer_status') {
      return NotificationBody(
        notificationType: NotificationType.offerStatus,
        orderId: int.tryParse(data['order_id'].toString()),
      );
    }
    if (data['type'] == 'subscription_status') {
      return NotificationBody(
        notificationType: NotificationType.subscriptionStatus,
        orderId: int.tryParse(data['order_id'].toString()),
      );
    }
    if (data['type'] == 'account_status') {
      return NotificationBody(notificationType: NotificationType.accountStatus);
    }
    return NotificationBody(notificationType: NotificationType.general);
  }
}
