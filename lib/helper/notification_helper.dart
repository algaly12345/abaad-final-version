// import 'dart:convert';
// import 'dart:io';
//
// import 'package:abaad_flutter/controller/auth_controller.dart';
// import 'package:abaad_flutter/controller/chat_controller.dart';
// import 'package:abaad_flutter/controller/notification_controller.dart';
// import 'package:abaad_flutter/data/model/body/notification_body.dart';
// import 'package:abaad_flutter/data/model/response/estate_model.dart';
// import 'package:abaad_flutter/helper/route_helper.dart';
// import 'package:abaad_flutter/helper/user_type.dart';
// //import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:http/http.dart' as http;
//
// import '../util/app_constants.dart';
//
// class NotificationHelper {
//   static Future<void> initialize(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//     var androidInitialize = const AndroidInitializationSettings('notification_icon');
//     // var iOSInitialize = const IOSInitializationSettings();
//     // var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
//     // flutterLocalNotificationsPlugin.initialize(initializationsSettings, onSelectNotification: (String? payload) async {
//     //   try {
//     //     if (payload != null && payload.isNotEmpty) {
//     //       NotificationBody notificationPayload = NotificationBody.fromJson(jsonDecode(payload));
//     //       if (notificationPayload.notificationType == NotificationType.order) {
//     //         // Navigate to order details
//     //       } else if (notificationPayload.notificationType == NotificationType.general) {
//     //        // Get.toNamed(RouteHelper.getNotificationRoute());
//     //       } else {
//     //         Get.toNamed(RouteHelper.getChatRoute(
//     //             notificationBody: notificationPayload,
//     //             conversationID: notificationPayload.conversationId!,
//     //             user: null,
//     //             index: 0 ,
//     //             estate_id: 0,
//     //             link: "",
//     //             estate: null
//     //         )
//     //         );
//     //       }
//     //     }
//     //   } catch (e) {}
//     //   return;
//     // });
//
//     // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//     //   //print("onMessage: \${message.notification?.title}/\${message.notification?.body}/\${message.data}");
//     //   if (message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.messages)) {
//     //     if (Get.find<AuthController>().isLoggedIn()) {
//     //       Get.find<ChatController>().getConversationList(1);
//     //       if (Get.find<ChatController>().messageModel?.conversation?.id.toString() == message.data['conversation_id'].toString()) {
//     //         Get.find<ChatController>().getMessages(
//     //           1,
//     //           NotificationBody(
//     //             notificationType: NotificationType.message,
//     //             adminId: message.data['sender_null'] == UserType.adnullname ? 0 : null,
//     //             orderId: null,
//     //             deliverymanId : null,
//     //             restaurantId: null,
//     //             type: '',
//     //             conversationId: null,
//     //           ),
//     //           null,
//     //           int.parse(message.data['conversation_id'].toString()),
//     //         );
//     //       } else {
//     //         NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
//     //       }
//     //     }
//     //   } else if (message.data['type'] == 'message' && Get.currentRoute.startsWith(RouteHelper.conversation)) {
//     //     if (Get.find<AuthController>().isLoggedIn()) {
//     //       Get.find<ChatController>().getConversationList(1);
//     //     }
//     //     NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
//     //   } else {
//     //     NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, false);
//     //     if (Get.find<AuthController>().isLoggedIn()) {
//     //       Get.find<NotificationController>().getNotificationList(true);
//     //     }
//     //   }
//     // });
//     //
//     // FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//     //   //print("onOpenApp: \${message.notification?.title}/\${message.notification?.body}/\${message.notification?.titleLocKey}");
//     //   try {
//     //     if (message.data.isNotEmpty) {
//     //       NotificationBody notificationBody = convertNotification(message.data , null);
//     //       if (notificationBody.notificationType == NotificationType.order) {
//     //         // Navigate to order details
//     //       } else if (notificationBody.notificationType == NotificationType.general) {
//     //         Get.toNamed(RouteHelper.getNotificationRoute());
//     //       } else {
//     //         Get.toNamed(RouteHelper.getChatRoute(
//     //             notificationBody: notificationBody,
//     //             conversationID: notificationBody.conversationId!,
//     //             user: null,
//     //             index: 0,
//     //             estate_id: 0,
//     //             link: '',
//     //             estate: null,
//     //         ));
//     //       }
//     //     }
//     //   } catch (e) {}
//     // });
//   }
//
//   // static Future<void> showNotification(RemoteMessage message, FlutterLocalNotificationsPlugin fln, bool data) async {
//   //   if (!GetPlatform.isIOS) {
//   //     String? title;
//   //     String? body;
//   //     String? orderID;
//   //     String? image;
//   //     NotificationBody notificationBody = convertNotification(message.data , null);
//   //     if (data) {
//   //       title = message.data['title'];
//   //       body = message.data['body'];
//   //       orderID = message.data['order_id'];
//   //       image = message.data['image'] != null && message.data['image'].isNotEmpty
//   //           ? message.data['image'].startsWith('http')
//   //           ? message.data['image']
//   //           : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.data['image']}'
//   //           : null;
//   //     } else {
//   //       title = message.notification?.title;
//   //       body = message.notification?.body;
//   //       orderID = message.notification?.titleLocKey;
//   //       if (GetPlatform.isAndroid) {
//   //         image = message.notification?.android?.imageUrl != null && message.notification!.android!.imageUrl!.isNotEmpty
//   //             ? message.notification!.android!.imageUrl!.startsWith('http')
//   //             ? message.notification!.android!.imageUrl!
//   //             : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification!.android!.imageUrl!}'
//   //             : null;
//   //       } else if (GetPlatform.isIOS) {
//   //         image = message.notification?.apple?.imageUrl != null && message.notification!.apple!.imageUrl!.isNotEmpty
//   //             ? message.notification!.apple!.imageUrl!.startsWith('http')
//   //             ? message.notification!.apple!.imageUrl!
//   //             : '${AppConstants.BASE_URL}/storage/app/public/notification/${message.notification!.apple!.imageUrl!}'
//   //             : null;
//   //       }
//   //     }
//   //
//   //     if (image != null && image.isNotEmpty) {
//   //       try {
//   //         await showBigPictureNotificationHiddenLargeIcon(title!, body!, orderID, notificationBody, image, fln);
//   //       } catch (e) {
//   //         await showBigTextNotification(title!, body!, orderID, notificationBody, fln);
//   //       }
//   //     } else {
//   //       await showBigTextNotification(title!, body!, orderID, notificationBody, fln);
//   //     }
//   //   }
//   // }
//
//   // static Future<void> showTextNotification(String title, String body, String? orderID, NotificationBody? notificationBody, FlutterLocalNotificationsPlugin fln) async {
//   //   const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//   //       'stackfood',
//   //       'stackfood',
//   //       'stackfood',
//   //        playSound: true,
//   //        importance: Importance.max,
//   //        priority: Priority.max,
//   //        sound: RawResourceAndroidNotificationSound('notification')
//   //   );
//   //   const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//   //   await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
//   // }
//   //
//   // static Future<void> showBigTextNotification(String title, String body, String? orderID, NotificationBody? notificationBody, FlutterLocalNotificationsPlugin fln) async {
//   //   BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
//   //     body, htmlFormatBigText: true,
//   //     contentTitle: title, htmlFormatContentTitle: true,
//   //   );
//   //   AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//   //     'stackfood', 'stackfood','stackfood', importance: Importance.max,
//   //     styleInformation: bigTextStyleInformation, priority: Priority.max, playSound: true,
//   //     sound: RawResourceAndroidNotificationSound('notification'),
//   //   );
//   //   NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//   //   await fln.show(0, title, body, platformChannelSpecifics, payload: notificationBody != null ? jsonEncode(notificationBody.toJson()) : null);
//   // }
//
//   static Future<void> showBigPictureNotificationHiddenLargeIcon(
//       String title, String body, String? orderID, NotificationBody notificationBody, String image, FlutterLocalNotificationsPlugin fln,
//       ) async {
//     final String largeIconPath = await _downloadAndSaveFile(image, 'largeIcon');
//     final String bigPicturePath = await _downloadAndSaveFile(image, 'bigPicture');
//     final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(
//       FilePathAndroidBitmap(bigPicturePath), hideExpandedLargeIcon: true,
//       contentTitle: title, htmlFormatContentTitle: true,
//       summaryText: body, htmlFormatSummaryText: true,
//     );
//     final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'abaad', 'abaaad',
//       largeIcon: FilePathAndroidBitmap(largeIconPath), priority: Priority.max, playSound: true,
//       styleInformation: bigPictureStyleInformation, importance: Importance.max,
//       sound: RawResourceAndroidNotificationSound('notification'),
//     );
//     final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
//     await fln.show(0, title, body, platformChannelSpecifics, payload: jsonEncode(notificationBody.toJson()));
//   }
//
//   static Future<String> _downloadAndSaveFile(String url, String fileName) async {
//     final Directory directory = await getApplicationDocumentsDirectory();
//     final String filePath = '${directory.path}/$fileName';
//     final http.Response response = await http.get(Uri.parse(url));
//     final File file = File(filePath);
//     await file.writeAsBytes(response.bodyBytes);
//     return filePath;
//   }
//
//   static NotificationBody convertNotification(Map<String, dynamic> data, dynamic? NotiferalionType) {
//     if (data['type'] == 'general') {
//       return NotificationBody(
//         notificationType : NotiferalionType.general,
//         orderId : null,
//         adminId : null,
//         deliverymanId : null,
//         restaurantId: null,
//         type : "",
//         conversationId : null
//       );
//     } else if (data['type'] == 'order_status') {
//       return NotificationBody(
//           notificationType : NotiferalionType.order,
//           orderId : int.parse(data['order_id']),
//           adminId : null,
//           deliverymanId : null,
//           restaurantId: null,
//           type : "",
//           conversationId : null
//       );
//     } else {
//       return NotificationBody(
//         notificationType: NotificationType.message,
//         deliverymanId: data['sender_type'] == 'delivery_man' ? 0 : null,
//         adminId: data['sender_type'] == 'admin' ? 0 : null,
//         restaurantId: data['sender_type'] == 'vendor' ? 0 : null,
//         conversationId: int.parse(data['conversation_id'].toString()),
//         type: "",
//         orderId: null
//       );
//     }
//   }
// }
//
// // Future<dynamic> myBackgroundMessageHandler(RemoteMessage message) async {
// //   //print("onBackground: \${message.notification?.title}/\${message.notification?.body}/\${message.notification?.titleLocKey}");
// //   var androidInitialize = const AndroidInitializationSettings('notification_icon');
// //   var iOSInitialize = const IOSInitializationSettings();
// //   var initializationsSettings = InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
// //   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// //   flutterLocalNotificationsPlugin.initialize(initializationsSettings);
// //   NotificationHelper.showNotification(message, flutterLocalNotificationsPlugin, true);
// // }
