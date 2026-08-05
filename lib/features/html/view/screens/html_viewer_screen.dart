import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/html_type.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatelessWidget {
  final HtmlType htmlType;
  const HtmlViewerScreen({super.key, required this.htmlType});

  static const Color _brandDark = Color(0xFF1A3C5E);
  static const Color _brandLight = Color(0xFF2E6DA4);

  /// عنوان الشاشة حسب نوع الصفحة — مكان واحد بدل تكراره 3 مرات بالكود.
  String _title() {
    switch (htmlType) {
      case HtmlType.TERMS_AND_CONDITION:
        return 'terms_conditions'.tr;
      case HtmlType.ABOUT_US:
        return 'about_us'.tr;
      case HtmlType.PRIVACY_POLICY:
        return 'privacy_policy'.tr;
      case HtmlType.SHIPPING_POLICY:
        return 'shipping_policy'.tr;
      case HtmlType.REFUND_POLICY:
        return 'refund_policy'.tr;
      case HtmlType.CANCELLATION_POLICY:
        return 'cancellation_policy'.tr;
      default:
        return 'no_data_found'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    final bool isArabic = currentLocale?.languageCode == 'ar';
    final splashCtrl = Get.find<SplashController>();

    String? data = htmlType == HtmlType.TERMS_AND_CONDITION
        ? splashCtrl.configModel?.termsAndConditions
        : htmlType == HtmlType.ABOUT_US
        ? splashCtrl.configModel?.aboutUs
        : htmlType == HtmlType.PRIVACY_POLICY
        ? splashCtrl.configModel?.privacyPolicy
        : null;

    if (data?.isNotEmpty == true) {
      data = data!.replaceAll('href=', 'target="_blank" href=');
    }

    // ⚠️ TODO: عرض HTML بالويب عبر IFrame كان معطّل أصلاً بالكود الأصلي
    // (dart:ui_web) وسبّب خطأ البناء لـ iOS لأن هذي المكتبة غير متاحة على
    // غير الويب. حذفته من هنا مؤقتًا. لو تحتاج تفعّله بالمستقبل، لازم
    // يكون بملف منفصل مع conditional import (وليس بنفس هذا الملف)، لأن
    // dart:ui_web ما يصير يُستورد إطلاقًا بملف يُبنى لمنصات الموبايل.
    // مثال الحل: قسّم الاستدعاء إلى ملفين stub/web واستوردهم شرطيًا:
    //   import 'x_stub.dart' if (dart.library.html) 'x_web.dart';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: CustomAppBar(title: _title()),
      body: Center(
        child: SizedBox(
          width: Dimensions.WEB_MAX_WIDTH,
          child: htmlType == HtmlType.TERMS_AND_CONDITION
              ? _buildTermsTabs(context, isArabic, splashCtrl)
              : _buildSingleContent(
            htmlType == HtmlType.ABOUT_US
                ? (isArabic
                ? splashCtrl.configModel?.aboutUsAr
                : splashCtrl.configModel?.aboutUs)
                : (isArabic
                ? splashCtrl.configModel?.privacyPolicyAr
                : splashCtrl.configModel?.privacyPolicy),
            // ⚠️ SHIPPING_POLICY / REFUND_POLICY / CANCELLATION_POLICY
            // تعرض حاليًا بيانات privacyPolicy بالخطأ. اربطها بحقولها
            // الصحيحة بـ configModel بمجرد ما تتأكد من أسمائها.
          ),
        ),
      ),
    );
  }

  /// شاشة الشروط والأحكام — التبويبين بنفس تدرّج ألوان العلامة التجارية.
  Widget _buildTermsTabs(
      BuildContext context,
      bool isArabic,
      SplashController splashCtrl,
      ) {
    final String content = isArabic
        ? (splashCtrl.configModel?.termsConditionsAr ?? "")
        : (splashCtrl.configModel?.termsConditions ?? "");

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_brandLight, _brandDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: TabBar(
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: Colors.white),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.65),
                labelStyle: robotoMedium.copyWith(fontSize: 15),
                unselectedLabelStyle: robotoRegular.copyWith(fontSize: 15),
                tabs: [
                  Tab(text: 'advertising_terms'.tr),
                  Tab(text: 'terms_use'.tr),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                buildTabContent(content),
                buildTabContent(content),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// شاشة محتوى مفرد (عن التطبيق / سياسة الخصوصية / ...) — بطاقة موحّدة.
  Widget _buildSingleContent(String? content) {
    return buildTabContent(content ?? "");
  }

  /// يبني بطاقة بيضاء بحواف دائرية للمحتوى، مع حالة فارغة واضحة
  /// بدل ما يظهر مربع أبيض فاضي لو ما وصل محتوى من السيرفر.
  Widget buildTabContent(String text) {
    if (text.trim().isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.description_outlined, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'no_data_found'.tr,
                style: robotoRegular.copyWith(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: HtmlWidget(
          text,
          textStyle: robotoRegular.copyWith(
            fontSize: 14,
            height: 1.7,
            color: const Color(0xFF3A4650),
          ),
          onTapUrl: (url) async {
            if (await canLaunchUrlString(url)) {
              await launchUrlString(url);
              return true;
            }
            return false;
          },
        ),
      ),
    );
  }
}