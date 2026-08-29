import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/provider/controller/provider_permission_controller.dart';
import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/provider/view/widgets/provider_identity_form.dart';
import 'package:abaad_flutter/features/services/view/screens/my_services_screen.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:abaad_flutter/shared/widgets/root_fallback_scope.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ارتفاع/نصف قطر زرّ الرجوع الدائري — مطابقان حرفيًا لثوابت الشريط العلوي في
// صفحة قائمة الخدمات (services_catalog_screen.dart: _topBarHeight/_BackHomeButton)
// كي يتطابق الشكل تمامًا رغم أن هذه الشاشة لا يمكنها استيراد ذلك الودجت
// الخاص (private) من الملف الآخر مباشرة.
const double _topBarButtonSize = 48;

/// خطوة "إنشاء حساب مزود خدمة" السابقة لمعالج إنشاء أول عرض
/// (AddPropertyServiceOfferScreen). تجمع نوع الحساب (فرد/منشأة) وبيانات
/// التحقق المطلوبة قبل المتابعة لإنشاء العرض نفسه:
/// - فرد: رقم الهوية الوطنية + رقم عضوية العمل الحر (بدون توثيق نفاذ في هذه
///   الشاشة — يتحقق الأدمن من البيانات لاحقاً).
/// - منشأة: رقم السجل التجاري أو الرقم الموحد فقط.
class ProviderUpgradeScreen extends StatefulWidget {
  const ProviderUpgradeScreen({super.key});

  @override
  State<ProviderUpgradeScreen> createState() => _ProviderUpgradeScreenState();
}

class _ProviderUpgradeScreenState extends State<ProviderUpgradeScreen> {
  late final ServiceOfferController _offerController;

  // يغطي التسلسل الكامل لـ _continue() (حفظ الهوية + تحديث المستخدم + التنقّل)
  // لا استدعاء saveIdentityNow() فقط — controller.isSubmitting يعود false فور
  // انتهاء نداء الشبكة الأول فيه، أي قبل بدء getUserInfo() بلحظات، فيصبح زرّ
  // "متابعة" قابلاً للنقر مجدداً أثناء ذلك الفاصل ويُمكن أن يدفع معالج "إضافة
  // خدمة" مرتين متتاليتين على المكدّس بضغطة مزدوجة. نفس نمط _isSubmitting في
  // CompleteProviderProfileScreen._continue().
  bool _isNavigatingToOffer = false;

  @override
  void initState() {
    super.initState();
    _offerController = Get.find<ServiceOfferController>();
  }

  // حفظ بيانات الهوية فوراً في service_providers قبل المتابعة، بدل انتظار
  // إتمام معالج "إضافة خدمة" بالكامل — فلا تُفقَد لو غادر المستخدم المعالج
  // قبل إكماله. saveIdentityNow() تعرض رسالة الخطأ بنفسها لو فشل الحفظ.
  Future<void> _continue() async {
    if (_isNavigatingToOffer) return;
    setState(() => _isNavigatingToOffer = true);

    final saved = await _offerController.saveIdentityNow();
    if (!saved) {
      if (mounted) setState(() => _isNavigatingToOffer = false);
      return;
    }
    // ننتظر اكتمالها هنا عمداً (لا fire-and-forget): إن رجع المستخدم لاحقاً
    // من معالج "إضافة خدمة" إلى هذه الشاشة (المكدّس)، فحص hasChosenIdentityType
    // أعلى build() يقرأ userInfoModel المخزَّن نفسه — لو لم يكتمل هذا التحديث
    // بعد، يبقى قديماً (provider=null) فيُعاد عرض النموذج من جديد رغم أن
    // البيانات أُرسلت فعلياً للباكند بنجاح.
    await Get.find<UserController>().getUserInfo();

    if (!mounted) return;
    setState(() => _isNavigatingToOffer = false);
    Get.toNamed(RouteHelper.getAddServiceOfferRoute());
  }

  // يكفي اختيار فرد/منشأة للمتابعة. أرقام الهوية بيانات ضرورية يُطلب من
  // المزوّد استكمالها، لكنها لا تُحجب المتابعة هنا — تُستكمل/تُراجَع يدويًا
  // لاحقًا. تلميحات الصيغة (_FormatHint) تبقى ظاهرة لإرشاد المستخدم فقط،
  // دون منعه من المتابعة ببيانات ناقصة.
  bool get _canContinue =>
      _offerController.entityType != null && !_isNavigatingToOffer;

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      // بلا شاشة وسيطة: نقطة استهلاك pendingRedirect (sign_in_screen.dart /
      // verification_screen.dart) تجلب بيانات مستخدم طازجة قبل استدعاء هذا
      // الإغلاق، فيقرأ القرار الصحيح فوراً بلا أي انتقال إضافي — نوع الحساب
      // (users.user_type) هو الفيصل الوحيد: "خدماتي" لمزوّد فعلي، أو نموذج
      // الهوية من جديد لغيره.
      return NotLoggedInScreen(
        redirectAfterLogin: () =>
            Get.find<ProviderPermissionController>().isProviderByType
                ? const MyServicesScreen()
                : const ProviderUpgradeScreen(),
      );
    }

    // مستخدم مسجّل دخوله سبق له إرسال بيانات الهوية (فرد/منشأة) بالفعل —
    // الباكند يُرقّيه إلى provider فور تلك الخطوة (راجع
    // ServiceProviderService::updateProviderIdentity)، فلا داعي لعرض النموذج
    // من جديد. يمنع هذا تحديداً ظهور النموذج عند الرجوع بزر الرجوع من معالج
    // "إضافة خدمة" (AddPropertyServiceOfferScreen يفتح هذه الشاشة عبر
    // Get.toNamed لا Get.off، فتبقى ProviderUpgradeScreen في المكدّس) —
    // ينتقل مباشرة إلى "خدماتي" حيث تظهر عروضه بدل إعادة سؤاله عن فرد/منشأة.
    // نفس فيصل نوع الحساب (user_type) المستخدَم بكل مكان آخر، لا وجود سجل
    // service_providers وحده.
    if (Get.find<ProviderPermissionController>().isProviderByType) {
      return const MyServicesScreen();
    }

    return GetBuilder<ServiceOfferController>(
      builder: (controller) {
        return Scaffold(
          // لا Scaffold.appBar هنا: الشريط العلوي جزء من body مباشرة، بنفس
          // بنية صفحة قائمة الخدمات (_buildTopBar) بدل AppBar/PreferredSizeWidget
          // منفصل — Column + Expanded(ScrollView) + زرّ سفلي مثبّت خارج
          // التمرير داخل SafeArea خاصة به (_buildBottomBar).
          body: Column(
            children: [
              _buildTopBar(context),
              Expanded(child: _buildScrollableContent(context)),
              _buildBottomBar(),
            ],
          ),
        );
      },
    );
  }

  // ─── شريط علوي مطابق حرفيًا لتصميم صفحة قائمة الخدمات: خلفية cardColor
  // مسطّحة بلا تدرّج/ظل، زرّ رجوع دائري بحدّ رمادي وأيقونة primary — إضافة
  // عنوان في المنتصف (غير موجود بالمرجع أصلاً) لأن هذه شاشة نموذج تحتاج
  // عنوانًا واضحًا خلافًا لشريط بحث/فلاتر قائمة الخدمات.
  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface(context),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // يذهب مباشرة إلى "قائمة الخدمات" (لا Get.back() عبر
            // ProviderLandingScreen الوسيطة) — تجربة أنظف: من عدل عن التسجيل
            // كمزوّد خدمة يعود مباشرة لتصفّح الخدمات بدل المرور بشاشة تعريفية
            // رآها للتوّ.
            _TopBarBackButton(onTap: RootFallbackScope.goToServices),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'become_provider_title'.tr,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.smallBold.copyWith(
                  fontSize: 17,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            // موازن بصري بعرض زرّ الرجوع نفسه كي يبقى العنوان في المنتصف
            // الحقيقي للصفّ، بدل الانزياح نحو الطرف المقابل للزرّ.
            const SizedBox(width: _topBarButtonSize),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'choose_account_type'.tr,
            style: AppTypography.title.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            'provider_upgrade_subtitle'.tr,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: Spacing.xl),
          const ProviderIdentityForm(),
        ],
      ),
    );
  }

  // ─── زرّ "متابعة" مثبّت أسفل الشاشة خارج منطقة التمرير — حالته/لونه (فعّال
  // بلون primary أو معطّل بشفافية أقل) مربوطان مباشرة بـ _canContinue عبر
  // onPressed، دون أي منطق إضافي هنا.
  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: AppShadows.soft(blur: 16, opacity: 0.06),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          child: DSPrimaryButton(
            label: 'continue_label'.tr,
            loading: _isNavigatingToOffer || _offerController.isSubmitting,
            onPressed: _canContinue ? _continue : null,
          ),
        ),
      ),
    );
  }

}

/// زرّ رجوع دائري — نسخة طبق الأصل من _BackHomeButton في
/// services_catalog_screen.dart (حدّ رمادي رفيع، أيقونة primary، 48×48)، معاد
/// تعريفها محليًا لأن الأصل ودجت خاص (private) بذلك الملف ولا يمكن استيرادها.
class _TopBarBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TopBarBackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_topBarButtonSize / 2),
      child: Container(
        width: _topBarButtonSize,
        height: _topBarButtonSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 18, color: Theme.of(context).primaryColor),
      ),
    );
  }
}
