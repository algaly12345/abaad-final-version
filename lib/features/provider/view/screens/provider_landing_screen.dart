import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة تعريفية (Landing) لتحويل المستخدم/الزائر العادي إلى مزود خدمة —
/// تُعرض قبل [ProviderUpgradeScreen] (نموذج بيانات الحساب الفعلي)، وتنتهي
/// إما بالمتابعة لمسار /service-provider أو بتخطيها والعودة لما قبلها.
class ProviderLandingScreen extends StatelessWidget {
  const ProviderLandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _HeaderIllustration(primary: primary),
                    const SizedBox(height: 32),
                    Text(
                      'انضم إلى شبكة مزودي الخدمات',
                      textAlign: TextAlign.center,
                      style: AppTypography.h3.copyWith(
                        color: primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'وسّع نطاق عملك وقدّم خدماتك لعملاء يبحثون عن خبراتك مباشرة.',
                      textAlign: TextAlign.center,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 36),
                    _FeatureItem(
                      icon: Icons.groups_rounded,
                      primary: primary,
                      title: 'وصول مباشر للعملاء',
                      description: 'عرض خدماتك أمام شريحة واسعة ومستهدفة.',
                    ),
                    const SizedBox(height: 24),
                    _FeatureItem(
                      icon: Icons.dashboard_rounded,
                      primary: primary,
                      title: 'لوحة تحكم متكاملة',
                      description:
                          'إدارة حجوزاتك، خدماتك، ومتابعة الأداء بكل سهولة.',
                    ),
                    const SizedBox(height: 24),
                    _FeatureItem(
                      icon: Icons.settings_rounded,
                      primary: primary,
                      title: 'مرونة في العرض',
                      description:
                          'تحكم كامل في التسعير ونطاق تغطية خدماتك.',
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomActions(context, primary),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: AppShadows.soft(blur: 16, opacity: 0.06),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
          child: Column(
            children: [
              DSPrimaryButton(
                label: 'إنشاء حساب مزود خدمة',
                onPressed: () =>
                    Get.toNamed(RouteHelper.getServiceProviderRoute()),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'تخطي الآن',
                  style: AppTypography.smallMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── غلاف علوي نظيف بدل صورة توضيحية فعلية: دائرة متدرّجة اللون بأيقونة
// "مصافحة" في المنتصف — لمسة احترافية هادئة يسهل استبدالها لاحقاً بصورة
// توضيحية حقيقية دون تعديل بنية الشاشة ─────────────────────────────────────

class _HeaderIllustration extends StatelessWidget {
  final Color primary;

  const _HeaderIllustration({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary.withValues(alpha: 0.12), primary.withValues(alpha: 0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.bottomSheet),
      ),
      alignment: Alignment.center,
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.handshake_rounded, size: 44, color: primary),
      ),
    );
  }
}

// ─── عنصر ميزة واحد: أيقونة داخل شارة دائرية مصبوغة + عنوان ووصف — نمط
// موحّد يسهل تمديده لعدد ميزات أكبر لاحقاً دون تغيير الشكل العام.
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color primary;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.primary,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Icon(icon, color: primary, size: IconSpec.defaultSize),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.smallBold.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary(context),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
