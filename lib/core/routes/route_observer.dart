import 'package:flutter/material.dart';

/// مراقب مسارات عام يُسجَّل في GetMaterialApp.navigatorObservers — يتيح لأي
/// شاشة معرفة لحظة عودتها للواجهة بعد إغلاق شاشة فوقها (didPopNext)، بخلاف
/// initState() التي لا تُعاد عند العودة لنفس نسخة الودجت القائمة (مثلاً بعد
/// Get.back()/Get.until() من شاشة "إضافة خدمة" إلى "خدماتي" الموجودة أصلاً
/// في المكدّس).
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
