import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class NearbyPosition {
  final double latitude;
  final double longitude;
  const NearbyPosition(this.latitude, this.longitude);
}

/// مساعد موقع خفيف مخصص لميزة "أقرب مزود خدمة": فحص/طلب الإذن ثم قراءة
/// الموقع مرة واحدة فقط. مستقل عمداً عن LocationController (lib/features/map)
/// لأن ذاك مبني حول تدفق اختيار عنوان كامل عبر خريطة تفاعلية (camera
/// animation + geocoding + حفظ عنوان) وهو تعقيد لا يلزم هنا. لا يُطلب الإذن
/// إلا عند استدعاء [resolveCurrentPosition] صراحة (أي عند ضغط المستخدم على
/// زر "الأقرب مني")، وليس عند فتح الشاشة.
class NearbyLocationHelper {
  /// [silent]: يُستخدم عند المحاولة التلقائية لأول فتح للشاشة — يطلب إذن
  /// الموقع من النظام (حوار النظام نفسه لا يمكن كتمه) لكن يتجنب أي رسالة/
  /// حوار إضافي من التطبيق عند الرفض، حتى لا يُفاجَأ المستخدم برسائل قبل أي
  /// تفاعل منه. الاستدعاء اليدوي (زر "أقرب مني") يبقى بكل رسائله كاملة.
  static Future<NearbyPosition?> resolveCurrentPosition({
    bool silent = false,
  }) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!silent) showCustomSnackBar('يرجى تفعيل خدمة الموقع في جهازك');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!silent) await _showPermissionDeniedDialog();
      return null;
    }

    if (permission == LocationPermission.denied) {
      if (!silent) showCustomSnackBar('لم يتم منح إذن الموقع');
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return NearbyPosition(position.latitude, position.longitude);
    } catch (_) {
      if (!silent) showCustomSnackBar('تعذر تحديد موقعك، حاول مرة أخرى');
      return null;
    }
  }

  static Future<void> _showPermissionDeniedDialog() async {
    await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on_rounded,
                  color: Get.theme.primaryColor, size: 56),
              const SizedBox(height: 16),
              Text(
                'فعّل موقعك واعثر على أقرب مزود خدمة',
                textAlign: TextAlign.center,
                style: robotoBold.copyWith(fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'اسمح لتطبيق أبعاد باستخدام موقعك لعرض مزودي الخدمات والعروض '
                'المتاحة بالقرب منك. يُستخدم موقعك فقط أثناء تفعيل هذه الخاصية.',
                textAlign: TextAlign.center,
                style: robotoRegular.copyWith(
                    fontSize: 12, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await Geolocator.openAppSettings();
                        Get.back();
                      },
                      child: const Text('الإعدادات'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
