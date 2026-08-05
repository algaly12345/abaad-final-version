import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotLoggedInScreen extends StatelessWidget {
  const NotLoggedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              /// 🔹 دائرة خلفية ناعمة خلف الصورة لإعطاء عمق بصري
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 220,
                    width: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF2E6DA4).withOpacity(0.08),
                          const Color(0xFF2E6DA4).withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                  Image.asset(
                    Images.guest,
                    height: 170,
                  ),
                ],
              ),

              const SizedBox(height: 36),

              /// 🔹 العنوان
              Text(
                "تسجيل الدخول مطلوب",
                style: robotoBold.copyWith(
                  fontSize: 22,
                  color: const Color(0xFF1A3C5E),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              /// 🔹 الوصف
              Text(
                "يجب تسجيل الدخول للوصول إلى هذه الصفحة\nوالاستفادة من جميع الميزات",
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              /// 🔹 زر تسجيل الدخول الرئيسي
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2E6DA4), Color(0xFF1A3C5E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A3C5E).withOpacity(0.30),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Get.toNamed(
                          RouteHelper.getSignInRoute(RouteHelper.main),
                        );
                      },
                      child: Center(
                        child: Text(
                          "تسجيل الدخول",
                          style: robotoMedium.copyWith(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              /// 🔹 زر العودة للرئيسية
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                },
                child: Text(
                  "العودة للرئيسية",
                  style: robotoMedium.copyWith(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }
}