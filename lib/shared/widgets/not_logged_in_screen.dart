import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotLoggedInScreen extends StatelessWidget {
  const NotLoggedInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [

              const Spacer(),

              /// 🔹 Image
              Image.asset(
                Images.guest,
                height: 180,
              ),

              const SizedBox(height: 30),

              /// 🔹 Title
              Text(
                "تسجيل الدخول مطلوب",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              /// 🔹 Subtitle
              Text(
                "يجب تسجيل الدخول للوصول إلى هذه الصفحة\nوالاستفادة من جميع الميزات",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              /// 🔹 Primary Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () {
                    Get.toNamed(
                      RouteHelper.getSignInRoute(RouteHelper.main),
                    );
                  },
                  child: const Text(
                    "تسجيل الدخول",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              /// 🔹 Secondary Button
              TextButton(
                onPressed: () {
                  Get.offAllNamed(RouteHelper.getInitialRoute());
                },
                child: const Text(
                  "العودة للرئيسية",
                  style: TextStyle(fontSize: 14),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}