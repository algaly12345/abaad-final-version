import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/features/language/view/widgets/language_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChooseLanguageScreen extends StatelessWidget {
  final bool fromMenu;
  const ChooseLanguageScreen({super.key, this.fromMenu = false});

  static const Color _brandDark = Color(0xFF1A3C5E);
  static const Color _brandLight = Color(0xFF2E6DA4);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: (fromMenu || ResponsiveHelper.isDesktop(context))
          ? CustomAppBar(title: 'language'.tr, isBackButtonExist: true)
          : null,
      body: SafeArea(
        child: GetBuilder<LocalizationController>(
          builder: (localizationController) {
            return Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Center(
                        child: SizedBox(
                          width: Dimensions.WEB_MAX_WIDTH,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(height: 12),

                              // 🔹 الشعار داخل دائرة ناعمة بدل ما يكون معلّق بفراغ
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _brandLight.withOpacity(0.08),
                                ),
                                child: Image.asset(Images.logo, width: 90),
                              ),

                              const SizedBox(height: 28),

                              // 🔹 عنوان رئيسي وشرح بسيط بدل نص واحد جاف
                              Text(
                                'select_language'.tr,
                                style: robotoMedium.copyWith(
                                  fontSize: 20,
                                  color: _brandDark,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'choose_your_preferred_app_language'.tr,
                                // ⚠️ مفتاح ترجمة جديد، أضفه لملفات اللغة عندك
                                style: robotoRegular.copyWith(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 28),

                              // 🔹 شبكة اللغات بمسافات أوسع بين البطاقات
                              GridView.builder(
                                gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                  ResponsiveHelper.isDesktop(context)
                                      ? 4
                                      : ResponsiveHelper.isTab(context)
                                      ? 3
                                      : 2,
                                  childAspectRatio: (1 / 0.42),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: localizationController.languages.length,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) => LanguageWidget(
                                  languageModel:
                                  localizationController.languages[index],
                                  localizationController: localizationController,
                                  index: index,
                                ),
                              ),

                              const SizedBox(height: 24),

                              // 🔹 ملاحظة صغيرة داخل شارة بدل نص عادي مفكوك
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.info_outline_rounded,
                                      size: 15,
                                      color: Colors.grey.shade500,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'you_can_change_language'.tr,
                                        style: robotoRegular.copyWith(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 🔹 زر الحفظ — عرض كامل مع تدرّج ألوان العلامة التجارية
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_brandLight, _brandDark],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _brandDark.withOpacity(0.28),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            if (localizationController.languages.isNotEmpty &&
                                localizationController.selectedIndex != -1) {
                              localizationController.setLanguage(Locale(
                                AppConstants
                                    .languages[
                                localizationController.selectedIndex]
                                    .languageCode,
                                AppConstants
                                    .languages[
                                localizationController.selectedIndex]
                                    .countryCode,
                              ));
                              if (fromMenu) {
                                Navigator.pop(context);
                              } else {
                                Get.offNamed(RouteHelper.getOnBoardingRoute());
                              }
                            } else {
                              showCustomSnackBar('select_a_language'.tr);
                            }
                          },
                          child: Center(
                            child: Text(
                              'save'.tr,
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
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}