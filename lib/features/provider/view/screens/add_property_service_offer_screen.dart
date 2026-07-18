import 'dart:io';

import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_setup_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/services/view/screens/services_catalog_screen.dart'
    show serviceCategoryIcon;
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/widgets/app_dropdown.dart';
import 'package:abaad_flutter/shared/widgets/package_option_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

class AddPropertyServiceOfferScreen extends StatefulWidget {
  const AddPropertyServiceOfferScreen({super.key});

  @override
  State<AddPropertyServiceOfferScreen> createState() =>
      _AddPropertyServiceOfferScreenState();
}

class _AddPropertyServiceOfferScreenState
    extends State<AddPropertyServiceOfferScreen> {
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    // تأجيل النداء لما بعد إطار البناء الحالي: هذه الشاشة تُفتح غالباً فوق
    // شاشة سابقة (ProviderUpgradeScreen) ما زالت مثبّتة أثناء انتقال الراوت،
    // ونداء update() هنا بشكل متزامن أثناء initState() قد يصطدم بـ
    // GetBuilder<ServiceOfferController> الخاص بتلك الشاشة وهو لسه قيد
    // البناء لنفس الإطار، فيسبب خطأ "setState()/markNeedsBuild() called
    // during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ServiceOfferController>().resetAll();
      Get.find<ServiceOfferController>().loadSetupData();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_agreedToTerms) {
      return _TermsScreen(onAccepted: () => setState(() => _agreedToTerms = true));
    }
    return const _WizardScreen();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TERMS SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class _TermsScreen extends StatefulWidget {
  final VoidCallback onAccepted;
  const _TermsScreen({required this.onAccepted});

  @override
  State<_TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<_TermsScreen> {
  // حالة صريحة (isAgreed) بدل _checked المبهم — تُقرأ مباشرة كنية العمل
  // (وافق/لم يوافق) وتُغذّي حالة زر البدء (مفعّل/معطّل) مباشرة دون أي منطق
  // إضافي بينهما.
  bool _isAgreed = false;

  final ScrollController _scrollController = ScrollController();
  // يظهر فقط عندما تبقى مسافة تمرير حقيقية أسفل الشاشة (قائمة طويلة) —
  // يختفي تلقائيًا فور وصول المستخدم للنهاية أو إن كانت القائمة قصيرة أصلًا
  // فلا تظهر إشارة "زد بالتمرير" بلا داع.
  bool _showScrollCue = true;

  List<(IconData, String, String)> get _terms => [
    (Icons.fact_check_rounded, 'term_accuracy_title'.tr, 'term_accuracy_body'.tr),
    (Icons.gavel_rounded, 'term_compliance_title'.tr, 'term_compliance_body'.tr),
    (Icons.search_rounded, 'term_review_title'.tr, 'term_review_body'.tr),
    (Icons.credit_card_rounded, 'term_payment_title'.tr, 'term_payment_body'.tr),
    (Icons.lock_rounded, 'term_privacy_title'.tr, 'term_privacy_body'.tr),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final atEnd = _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 24;
    if (atEnd == _showScrollCue) {
      setState(() => _showScrollCue = !atEnd);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: Stack(
        children: [
          // ─── Scrollable content ───────────────────────────────────────
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Collapsing gradient header — no ugly border radius
              SliverAppBar(
                expandedHeight: 255,
                pinned: false,
                automaticallyImplyLeading: false,
                backgroundColor: const Color(0xFF0B1628),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [primary, const Color(0xFF0B1628)],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          // Space for the fixed back button
                          const SizedBox(height: 52),
                          // Hero
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: AvatarSpec.profile,
                                  height: AvatarSpec.profile,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.3),
                                        width: 2),
                                  ),
                                  child: Icon(Icons.handshake_outlined,
                                      color: Colors.white, size: IconSpec.large),
                                ),
                                const SizedBox(height: Spacing.md),
                                Text(
                                  'service_terms_title'.tr,
                                  style: AppTypography.title
                                      .copyWith(color: Colors.white),
                                ),
                                const SizedBox(height: Spacing.sm),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Text(
                                    'service_terms_subtitle'.tr,
                                    style: AppTypography.small.copyWith(
                                      color:
                                          Colors.white.withValues(alpha: 0.85),
                                      height: 1.55,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Spacing.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Terms list — flows naturally below header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                    Spacing.pagePadding, Spacing.lg, Spacing.pagePadding, 0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _TermItem(
                      icon: _terms[i].$1,
                      title: _terms[i].$2,
                      body: _terms[i].$3,
                    ),
                    childCount: _terms.length,
                  ),
                ),
              ),

              // Space so content isn't hidden behind the fixed bottom bar
              const SliverToBoxAdapter(child: SizedBox(height: 170)),
            ],
          ),

          // ─── Fixed back button ───────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: Colors.white, size: 18),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ─── إشارة "زد بالتمرير": تلاشٍ فوق الشريط السفلي مباشرة، تظهر فقط
          // ما دام هناك محتوى أسفل نقطة التمرير الحالية ويختفي تلقائيًا عند
          // الوصول للنهاية أو إن كانت القائمة قصيرة أصلًا فلا تفيض عن الشاشة.
          Positioned(
            bottom: 170,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showScrollCue ? 1 : 0,
                duration: AnimSpec.dialog,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        AppColors.background(context),
                        AppColors.background(context).withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ─── Fixed bottom: checkbox + button ─────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(Spacing.pagePadding, Spacing.lg,
                  Spacing.pagePadding, Spacing.lg + bottomPadding),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                boxShadow: AppShadows.soft(blur: 16, opacity: 0.09),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox row
                  GestureDetector(
                    onTap: () => setState(() => _isAgreed = !_isAgreed),
                    child: AnimatedContainer(
                      duration: AnimSpec.button,
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color: _isAgreed
                            ? primary.withValues(alpha: 0.06)
                            : AppColors.background(context),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color: _isAgreed ? primary : AppColors.border(context),
                          width: _isAgreed ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: AnimSpec.button,
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _isAgreed ? primary : AppColors.surface(context),
                              borderRadius: BorderRadius.circular(AppRadius.small - 2),
                              border: Border.all(
                                color: _isAgreed ? primary : AppColors.border(context),
                              ),
                            ),
                            child: _isAgreed
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14)
                                : null,
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Text(
                              'agree_all_terms'.tr,
                              style: AppTypography.small.copyWith(
                                color: _isAgreed
                                    ? primary
                                    : AppColors.textSecondary(context),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),

                  // Start button — DSPrimaryButton يتكفّل وحده بحالتَي
                  // التفعيل/التعطيل (لون primary الكامل أو خلفية معطّلة
                  // بشفافية أقل عبر disabledBackgroundColor) بمجرّد تمرير
                  // onPressed: null، فلا حاجة لتغليفه بتعتيم إضافي (كان
                  // يُضاعف التعتيم فوق حالة التعطيل الداخلية فيصعب قراءة
                  // النص).
                  DSPrimaryButton(
                    label: 'start_adding_now'.tr,
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _isAgreed ? widget.onAccepted : null,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _TermItem(
      {required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(CardSpec.padding),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 8, opacity: 0.04),
      ),
      // الأيقونة أول عنصر في الصف — تقع في جهة البداية (اليمين تحت RTL)
      // تلقائيًا، وشارة دائرية ملوّنة بلون التطبيق بدل رمز إيموجي (يتفاوت
      // شكله بين الأجهزة) مطابقةً لبقية شارات الأيقونات في التطبيق.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: primary, size: 20),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.smallBold
                        .copyWith(color: AppColors.textPrimary(context))),
                const SizedBox(height: Spacing.xs),
                Text(body,
                    style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary(context), height: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WIZARD SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class _WizardScreen extends StatefulWidget {
  const _WizardScreen();

  @override
  State<_WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<_WizardScreen> {
  int _step = 0;
  final int _totalSteps = 4;
  final PageController _pageController = PageController();

  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _valueCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();

  List<String> get _stepLabels => [
    'service'.tr,
    'package'.tr,
    'zones'.tr,
    'review'.tr,
  ];
  static const _stepIcons = [
    Icons.miscellaneous_services_outlined,
    Icons.workspace_premium_outlined,
    Icons.map_outlined,
    Icons.rate_review_outlined,
  ];

  @override
  void initState() {
    super.initState();
    // بدون هذه المستمعات يبقى زرّ "التالي" في _buildBottomBar جامدًا أثناء
    // الكتابة: _canGoNext() تُحسَب فقط عند إعادة بناء GetBuilder (تغيّر نوع
    // الخدمة/نوع العرض عبر controller.update() الداخلي)، لا عند كل ضغطة مفتاح
    // في حقول العنوان/القيمة/الوصف — فيبقى الزرّ معطّلاً أو مفعّلاً بحالة
    // قديمة رغم أن المستخدم أكمل الكتابة فعليًا.
    _titleCtrl.addListener(_onFieldChanged);
    _valueCtrl.addListener(_onFieldChanged);
    _descCtrl.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _titleCtrl.removeListener(_onFieldChanged);
    _valueCtrl.removeListener(_onFieldChanged);
    _descCtrl.removeListener(_onFieldChanged);
    _pageController.dispose();
    _titleCtrl.dispose();
    _valueCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _goNext(ServiceOfferController c) {
    if (!_canGoNext(c)) return;
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submit(c);
    }
  }

  void _goBack() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.back();
    }
  }

  bool _canGoNext(ServiceOfferController c) {
    switch (_step) {
      case 0:
        return c.selectedServiceTypeIndex >= 0 &&
            _titleCtrl.text.trim().isNotEmpty &&
            _valueCtrl.text.trim().isNotEmpty &&
            _descCtrl.text.trim().isNotEmpty;
      case 1:
        // مدة الاشتراك دائماً محددة بقيمة افتراضية (شهر واحد)، فيكفي التحقق
        // من اختيار الباقة نفسها.
        return c.selectedPlanIndex >= 0;
      case 2:
        return c.selectedZoneIds.isNotEmpty &&
            c.selectedCategoryIds.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _submit(ServiceOfferController c) async {
    final result = await c.submitOffer(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      priceOrDiscountValue: _valueCtrl.text,
    );
    if (result != null && result.paymentUrl != null) {
      Get.toNamed(
        RouteHelper.getServiceOfferPaymentRoute(),
        arguments: {
          'url': result.paymentUrl,
          'number': result.subscriptionNumber,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return GetBuilder<ServiceOfferController>(
      builder: (c) {
        if (c.isLoading) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: primary),
                  const SizedBox(height: Spacing.lg),
                  Text('loading_data'.tr,
                      style: AppTypography.small.copyWith(color: Colors.grey)),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF4F6FB),
          body: Column(
            children: [
              // ─── Top header + step indicator ─────────────────────────
              _buildTopBar(context, primary),

              // ─── Page content ────────────────────────────────────────
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _Step1ServiceInfo(
                      titleCtrl: _titleCtrl,
                      valueCtrl: _valueCtrl,
                      descCtrl: _descCtrl,
                      controller: c,
                      primary: primary,
                    ),
                    _Step2Plan(controller: c, primary: primary),
                    _Step3ZoneCategory(controller: c, primary: primary),
                    _Step4Review(
                      titleCtrl: _titleCtrl,
                      valueCtrl: _valueCtrl,
                      descCtrl: _descCtrl,
                      controller: c,
                      primary: primary,
                    ),
                  ],
                ),
              ),

              // ─── Bottom bar ──────────────────────────────────────────
              _buildBottomBar(context, c, primary),
            ],
          ),
        );
      },
    );
  }

  // شريط علوي بسيط ومسطّح: بدل الدوائر الأربع والخطوط الرابطة بينها (تصميم
  // مزدحم يُجبر المستخدم على مسح كل الخطوات بصريًا)، شريط تقدّم خطي واحد +
  // اسم الخطوة الحالية فقط — إشارة تقدّم واحدة واضحة تقلّل التشتت بدل أربع
  // إشارات متزامنة.
  Widget _buildTopBar(BuildContext context, Color primary) {
    final progress = (_step + 1) / _totalSteps;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: AppShadows.soft(blur: 10, opacity: 0.05),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              Spacing.sm, Spacing.xs, Spacing.pagePadding, Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        color: AppColors.textPrimary(context), size: 18),
                    onPressed: _goBack,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _stepLabels[_step],
                          style: AppTypography.title
                              .copyWith(color: AppColors.textPrimary(context)),
                        ),
                        Text(
                          'step_x_of_y'.trParams({
                            'current': '${_step + 1}',
                            'total': '$_totalSteps',
                          }),
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textSecondary(context)),
                        ),
                      ],
                    ),
                  ),
                  Icon(_stepIcons[_step], color: primary, size: IconSpec.large),
                ],
              ),
              const SizedBox(height: Spacing.md),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: AnimSpec.dialog,
                  curve: Curves.easeInOutCubic,
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 6,
                    backgroundColor: primary.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(primary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(
      BuildContext context, ServiceOfferController c, Color primary) {
    final isLast = _step == _totalSteps - 1;
    final canNext = _canGoNext(c);
    final total = c.priceCalculation?.totalPrice ?? c.selectedPlan?.price ?? 0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: AppShadows.soft(blur: 16, opacity: 0.08),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.pagePadding,
            Spacing.md,
            Spacing.pagePadding,
            Spacing.md,
          ),
          child: Row(
            // بدون هذا المحاذاة (الافتراضي center) كان زرّ "السابق" الثابت
            // الارتفاع (48) يتمركز رأسياً مقابل عمود السعر+الزرّ الأطول في
            // خطوة المراجعة (نص "الإجمالي" فوق السعر فوق الزرّ)، فيظهر أعلى
            // من زرّ "إكمال والدفع" بدل أن يحاذيه في نفس السطر.
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (_step > 0)
                SizedBox(
                  height: ButtonSpec.primaryHeight,
                  child: OutlinedButton(
                    onPressed: _goBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                      side: BorderSide(color: AppColors.border(context)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ButtonSpec.radius)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.arrow_back_rounded,
                            size: IconSpec.small,
                            color: AppColors.textSecondary(context)),
                        const SizedBox(width: Spacing.xs),
                        Text('previous'.tr,
                            style: AppTypography.smallMedium
                                .copyWith(color: AppColors.textSecondary(context))),
                      ],
                    ),
                  ),
                ),
              if (_step > 0) const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLast && total > 0) ...[
                      Text('total'.tr,
                          style: AppTypography.badge
                              .copyWith(color: AppColors.textSecondary(context))),
                      c.isPriceLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              '${total.toStringAsFixed(0)} ريال',
                              style: AppTypography.subtitle.copyWith(
                                  color: primary, fontWeight: FontWeight.w700),
                            ),
                    ],
                    DSPrimaryButton(
                      label: isLast ? 'complete_and_pay'.tr : 'next'.tr,
                      icon: isLast
                          ? Icons.payments_outlined
                          : Icons.arrow_forward_rounded,
                      loading: c.isSubmitting,
                      onPressed: canNext ? () => _goNext(c) : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1: Service Info
// ─────────────────────────────────────────────────────────────────────────────

class _Step1ServiceInfo extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController valueCtrl;
  final TextEditingController descCtrl;
  final ServiceOfferController controller;
  final Color primary;

  const _Step1ServiceInfo({
    required this.titleCtrl,
    required this.valueCtrl,
    required this.descCtrl,
    required this.controller,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.miscellaneous_services_outlined,
            title: 'service_data'.tr,
            subtitle: 'enter_basic_service_info'.tr,
            primary: primary,
          ),
          const SizedBox(height: Spacing.xl),

          // Image picker
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('صورة العرض', icon: Icons.image_outlined),
                const SizedBox(height: Spacing.sm),
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: controller.pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.medium),
                            child: Image.file(
                              File(controller.pickedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 40, color: primary.withValues(alpha: 0.5)),
                              const SizedBox(height: Spacing.sm),
                              Text('tap_to_choose_image'.tr,
                                  style: AppTypography.caption
                                      .copyWith(color: AppColors.textSecondary(context))),
                            ],
                          ),
                  ),
                ),
                if (controller.pickedImage != null) ...[
                  const SizedBox(height: Spacing.sm),
                  TextButton.icon(
                    onPressed: controller.pickImage,
                    icon: const Icon(Icons.swap_horiz_rounded, size: IconSpec.small),
                    label: Text('change_image'.tr, style: AppTypography.smallMedium),
                    style: TextButton.styleFrom(foregroundColor: primary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Service type
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('نوع الخدمة', icon: Icons.category_outlined),
                const SizedBox(height: Spacing.sm),
                AppDropdown<int>(
                  value: controller.selectedServiceTypeIndex >= 0
                      ? controller.selectedServiceTypeIndex
                      : null,
                  hintText: 'select_service_type'.tr,
                  leadingIcon: Icons.category_outlined,
                  items: List.generate(
                    controller.serviceTypes.length,
                    (i) => DropdownMenuItem(
                      value: i,
                      child: Text(controller.serviceTypes[i].name ?? ''),
                    ),
                  ),
                  onChanged: (v) {
                    if (v != null) controller.selectServiceType(v);
                  },
                ),
                if (controller.selectedServiceTypeIndex < 0)
                  const _RequiredHint('يرجى اختيار نوع الخدمة'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Title
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('عنوان العرض', icon: Icons.title_rounded),
                const SizedBox(height: Spacing.sm),
                _dsTextField(
                  context,
                  hintText: 'اكتب عنواناً واضحاً للعرض',
                  controller: titleCtrl,
                ),
                if (titleCtrl.text.trim().isEmpty)
                  const _RequiredHint('يرجى إدخال عنوان العرض'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Offer type
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('نوع العرض', icon: Icons.sell_outlined),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    _OfferTypeCard(
                      controller: controller,
                      type: 'price',
                      icon: Icons.sell_outlined,
                      useRiyalIcon: true,
                      title: 'سعر مباشر',
                      sub: 'سعر ثابت ومحدد',
                      primary: primary,
                      // يُفرَّغ الحقل عند التبديل كي لا يبقى رقم من النوع
                      // السابق (مثلاً "20" نسبة خصم) ظاهرًا بمعنى مختلف كليًا
                      // تحت تسمية "السعر (ريال)" الجديدة.
                      onSelected: valueCtrl.clear,
                    ),
                    const SizedBox(width: Spacing.sm),
                    _OfferTypeCard(
                      controller: controller,
                      type: 'discount',
                      icon: Icons.percent_rounded,
                      title: 'خصم %',
                      sub: 'نسبة خصم على السعر',
                      primary: primary,
                      onSelected: valueCtrl.clear,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                // AnimatedSwitcher بدل تبديل فوري: تسمية/تلميح الحقل يتلاشيان
                // ويُستبدلان بانسيابية عند تغيير نوع العرض بدل قفزة بصرية
                // فجائية، رغم أن الحقل الأساسي (valueCtrl) نفسه واحد دومًا.
                AnimatedSwitcher(
                  duration: AnimSpec.card,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SizeTransition(
                        sizeFactor: anim, axisAlignment: -1, child: child),
                  ),
                  child: Column(
                    key: ValueKey(controller.offerType),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldLabel(
                        controller.offerType == 'discount'
                            ? 'نسبة الخصم (%)'
                            : 'السعر (ريال)',
                        icon: Icons.numbers_rounded,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _dsTextField(
                        context,
                        hintText: controller.offerType == 'discount'
                            ? 'مثال: 20'
                            : 'مثال: 500',
                        controller: valueCtrl,
                        keyboardType: TextInputType.number,
                      ),
                      if (valueCtrl.text.trim().isEmpty)
                        _RequiredHint(
                          controller.offerType == 'discount'
                              ? 'يرجى إدخال نسبة الخصم'
                              : 'يرجى إدخال السعر',
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Description
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('وصف الخدمة', icon: Icons.description_outlined),
                const SizedBox(height: Spacing.sm),
                _dsTextField(
                  context,
                  hintText: 'اكتب وصفاً احترافياً وتفصيلياً للخدمة...',
                  controller: descCtrl,
                  maxLines: 4,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: Plan
// ─────────────────────────────────────────────────────────────────────────────

class _Step2Plan extends StatelessWidget {
  final ServiceOfferController controller;
  final Color primary;

  const _Step2Plan({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      child: Column(
        children: [
          _StepHeader(
            icon: Icons.workspace_premium_outlined,
            title: 'choose_plan'.tr,
            subtitle: 'choose_plan_subtitle'.tr,
            primary: primary,
          ),
          const SizedBox(height: Spacing.xl),
          ...List.generate(controller.servicePlans.length, (i) {
            final ServicePlanModel plan = controller.servicePlans[i];
            final selected = i == controller.selectedPlanIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: PackageOptionCard(
                title: plan.name ?? '',
                priceLabel:
                    '${plan.price?.toStringAsFixed(0)} ${'sar_per_month'.tr}',
                selected: selected,
                onTap: () => controller.selectPlan(i),
                features: [
                  PackageFeatureItem(
                      '${plan.numberOfAds ?? 0} إعلانات', Icons.campaign_outlined),
                  PackageFeatureItem('${plan.numberOfCategories ?? 0} أنواع',
                      Icons.category_outlined),
                  PackageFeatureItem(
                      '${plan.numberOfZone ?? 0} مناطق', Icons.map_outlined),
                  if (plan.featuredDisplay ?? false)
                    PackageFeatureItem('featured_display'.tr, Icons.star_outline),
                  if (plan.interactiveReports ?? false)
                    PackageFeatureItem(
                        'reports_label'.tr, Icons.bar_chart_outlined),
                  if (plan.crmSystem ?? false)
                    PackageFeatureItem('نظام CRM', Icons.people_outline),
                ],
              ),
            );
          }),
          const SizedBox(height: Spacing.md),
          // مدة الاشتراك انتقلت من خطوة المراجعة إلى هنا كي يرى المستخدم
          // السعر النهائي فور اختيار الباقة، بدل اكتشافه بعد 3 خطوات إضافية.
          _DurationSelector(controller: controller, primary: primary),
          const SizedBox(height: Spacing.md),
          _LiveTotalCard(controller: controller, primary: primary),
          const SizedBox(height: Spacing.xxxl),
        ],
      ),
    );
  }
}

/// شبكة اختيار مدة الاشتراك — مستخرجة كي تُستخدم في خطوة الباقة (السعر
/// النهائي يظهر مبكرًا) وتبقى قابلة لإعادة الاستخدام في أي مكان آخر.
class _DurationSelector extends StatelessWidget {
  final ServiceOfferController controller;
  final Color primary;
  const _DurationSelector({required this.controller, required this.primary});

  static const List<(int, String)> _options = [
    (1, 'one_month'),
    (3, 'three_months'),
    (6, 'six_months'),
    (12, 'one_year'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel('subscription_duration'.tr,
              icon: Icons.calendar_month_outlined),
          const SizedBox(height: Spacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: Spacing.sm,
            mainAxisSpacing: Spacing.sm,
            childAspectRatio: 2.4,
            children: _options.map((o) {
              final (months, labelKey) = o;
              final selected = controller.selectedDuration == months;
              return GestureDetector(
                onTap: () => controller.selectDuration(months),
                child: AnimatedContainer(
                  duration: AnimSpec.card,
                  decoration: BoxDecoration(
                    color: selected
                        ? primary.withValues(alpha: 0.08)
                        : AppColors.background(context),
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: selected ? primary : AppColors.border(context),
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      labelKey.tr,
                      style: (selected
                              ? AppTypography.smallBold
                              : AppTypography.smallMedium)
                          .copyWith(
                        color: selected
                            ? primary
                            : AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          if (controller.expiryDateText.isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Container(
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.event_available_rounded,
                      color: primary, size: IconSpec.small),
                  const SizedBox(width: Spacing.sm),
                  Text('${'subscription_expires'.tr}: ',
                      style: AppTypography.caption
                          .copyWith(color: AppColors.textSecondary(context))),
                  Text(controller.expiryDateText,
                      style:
                          AppTypography.smallBold.copyWith(color: primary)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// بطاقة الإجمالي المباشر — تُعاد قراءتها في كل مرة يتغيّر فيها اختيار الباقة
/// أو المدة أو المناطق عبر [GetBuilder] المحيط، فتعكس السعر الفعلي القادم من
/// السيرفر (بما في ذلك رسوم تجاوز حد المناطق) دون أي حساب مكرر في الواجهة.
class _LiveTotalCard extends StatelessWidget {
  final ServiceOfferController controller;
  final Color primary;
  const _LiveTotalCard({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final total =
        controller.priceCalculation?.totalPrice ?? controller.selectedPlan?.price ?? 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CardSpec.padding),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.payments_outlined, color: primary, size: IconSpec.defaultSize),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Text('estimated_total'.tr,
                style: AppTypography.smallMedium
                    .copyWith(color: AppColors.textSecondary(context))),
          ),
          controller.isPriceLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : Text(
                  '${total.toStringAsFixed(0)} ريال',
                  style: AppTypography.title
                      .copyWith(color: primary, fontWeight: FontWeight.w800),
                ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: Zones & Categories
// ─────────────────────────────────────────────────────────────────────────────

class _Step3ZoneCategory extends StatelessWidget {
  final ServiceOfferController controller;
  final Color primary;
  const _Step3ZoneCategory(
      {required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final plan = controller.selectedPlan;
    final allowedZones = plan?.numberOfZone ?? 0;
    final allowedCats = plan?.numberOfCategories ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.map_outlined,
            title: 'zones_and_categories'.tr,
            subtitle: 'zones_categories_subtitle'.tr,
            primary: primary,
          ),
          const SizedBox(height: Spacing.xl),

          _TargetingSection(
            label: 'المناطق',
            icon: Icons.location_on_outlined,
            allowed: allowedZones,
            selectedCount: controller.selectedZoneIds.length,
            primary: primary,
            overLimitWarning: allowedZones > 0 &&
                    controller.selectedZoneIds.length > allowedZones
                ? 'ستُضاف 50 ريال على كل منطقة زيادة عن $allowedZones'
                : null,
            itemCount: controller.zones.length,
            itemBuilder: (i) {
              final z = controller.zones[i];
              final selected = controller.selectedZoneIds.contains(z.id);
              return _SelectTextCard(
                label: (z.nameAr?.isNotEmpty ?? false) ? z.nameAr! : (z.name ?? ''),
                selected: selected,
                primary: primary,
                onTap: () => controller.toggleZone(z.id ?? 0),
              );
            },
          ),
          const SizedBox(height: Spacing.md),

          _TargetingSection(
            label: 'أنواع العقار',
            icon: Icons.apartment_outlined,
            allowed: allowedCats,
            selectedCount: controller.selectedCategoryIds.length,
            primary: primary,
            itemCount: controller.categories.length,
            itemBuilder: (i) {
              final cat = controller.categories[i];
              final selected = controller.selectedCategoryIds.contains(cat.id);
              final label =
                  (cat.nameAr?.isNotEmpty ?? false) ? cat.nameAr! : (cat.name ?? '');
              return _SelectCard(
                icon: serviceCategoryIcon(label),
                label: label,
                selected: selected,
                primary: primary,
                onTap: () => controller.toggleCategory(cat.id ?? 0),
              );
            },
          ),
          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }
}

/// قسم استهداف واحد (منطقة أو نوع عقار) — يجمع العنوان وشارة الحد وشبكة
/// بطاقات ثلاثية الأعمدة، مستخرج لأن قسمَي المناطق وأنواع العقار كانا
/// يكرّران نفس الهيكل حرفياً.
class _TargetingSection extends StatelessWidget {
  static const int _columns = 3;

  final String label;
  final IconData icon;
  final int allowed;
  final int selectedCount;
  final Color primary;
  final int itemCount;
  final Widget Function(int index) itemBuilder;
  final String? overLimitWarning;

  const _TargetingSection({
    required this.label,
    required this.icon,
    required this.allowed,
    required this.selectedCount,
    required this.primary,
    required this.itemCount,
    required this.itemBuilder,
    this.overLimitWarning,
  });

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _FieldLabel(label, icon: icon),
              const Spacer(),
              if (allowed > 0)
                _LimitBadge(current: selectedCount, max: allowed, primary: primary),
            ],
          ),
          const SizedBox(height: Spacing.lg),
          if (itemCount > 0) _buildGrid(),
          if (overLimitWarning != null) _OverLimitWarning(overLimitWarning!),
        ],
      ),
    );
  }

  /// شبكة مبنية صفّاً صفّاً (بدل Wrap حرّة) — كل صفّ داخل [IntrinsicHeight] مع
  /// CrossAxisAlignment.stretch كي تتساوى ارتفاعات كل بطاقات نفس الصفّ تلقائياً
  /// بارتفاع أطولها؛ بدونها كانت بطاقة بتسمية سطرين (مثل "شقّة صغيرة
  /// (ستوديو)") تطول عن جارتيها في نفس الصفّ فيبدو الصفّ متكسراً وغير محاذى.
  Widget _buildGrid() {
    final rows = <Widget>[];
    for (int start = 0; start < itemCount; start += _columns) {
      final rowLength = (itemCount - start).clamp(0, _columns);
      if (rows.isNotEmpty) rows.add(const SizedBox(height: Spacing.sm));
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int j = 0; j < _columns; j++) ...[
                if (j > 0) const SizedBox(width: Spacing.sm),
                Expanded(
                  child: j < rowLength ? itemBuilder(start + j) : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}

/// بطاقة اختيار بأيقونة (أنواع العقار — لكل نوع أيقونة مميّزة فعلياً فتُبرز
/// الفرق بينها). الأيقونة داخل دائرة بلون primary فاتح دوماً (لا رمادي مسطّح
/// كما كان) لإحساس أكثر حيوية، وارتفاع البطاقة أدنى (minHeight) لا ثابت —
/// كانت النسخة السابقة تُقصّ عند تسميات سطرين ("BOTTOM OVERFLOWED") فتنمو
/// الآن بدل أن تفيض.
class _SelectCard extends StatelessWidget {
  static const double _minHeight = 104;
  static const double _iconBox = 46;

  final IconData icon;
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _SelectCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.large),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: AnimatedContainer(
          duration: AnimSpec.card,
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: _minHeight),
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: Spacing.md),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: dark ? 0.2 : 0.07)
                : AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: selected ? Border.all(color: primary, width: 1.6) : null,
            boxShadow: !dark ? AppShadows.soft(blur: 12, opacity: selected ? 0.1 : 0.05) : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: AnimSpec.card,
                    width: _iconBox,
                    height: _iconBox,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? primary : primary.withValues(alpha: dark ? 0.18 : 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 21, color: selected ? Colors.white : primary),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: (selected ? AppTypography.captionMedium : AppTypography.caption)
                          .copyWith(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        height: 1.25,
                        color: selected ? primary : AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
              if (selected)
                PositionedDirectional(
                  top: 2,
                  end: 2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface(context), width: 1.5),
                    ),
                    child: const Icon(Icons.check_rounded, size: 11, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// بطاقة نصّية بلا أيقونة (المناطق) — دبّوس الموقع كان يتكرر بنفس الشكل في
/// كل بطاقة منطقة دون أي قيمة تمييزية بينها، فحُذف لصالح تصميم أنظف يعتمد
/// على النص وحده مع تعبئة كاملة بلون primary عند التحديد (نمط شائع لاختيار
/// الوجهة/المدينة في تطبيقات الحجز)، بدل تكرار أيقونة زخرفية بلا معنى.
class _SelectTextCard extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _SelectTextCard({
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppRadius.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        child: AnimatedContainer(
          duration: AnimSpec.card,
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.sm),
          decoration: BoxDecoration(
            color: selected ? primary : AppColors.surface(context),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: selected ? null : Border.all(color: AppColors.border(context)),
            boxShadow:
                !dark ? AppShadows.soft(blur: 10, opacity: selected ? 0.16 : 0.04) : null,
          ),
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: (selected ? AppTypography.smallBold : AppTypography.smallMedium).copyWith(
              color: selected ? Colors.white : AppColors.textPrimary(context),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: Review & Duration
// ─────────────────────────────────────────────────────────────────────────────

class _Step4Review extends StatelessWidget {
  final TextEditingController titleCtrl;
  final TextEditingController valueCtrl;
  final TextEditingController descCtrl;
  final ServiceOfferController controller;
  final Color primary;

  const _Step4Review({
    required this.titleCtrl,
    required this.valueCtrl,
    required this.descCtrl,
    required this.controller,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    // مدة الاشتراك والسعر أصبحا يُختاران فعلياً في خطوة الباقة (_Step2Plan) —
    // هذه الخطوة الآن مراجعة نهائية فقط قبل الدفع، بلا حقول قابلة للتعديل،
    // فلا داعٍ لتكرار شبكة اختيار المدة هنا.
    final durationLabel = _DurationSelector._options
        .firstWhere((o) => o.$1 == controller.selectedDuration,
            orElse: () => _DurationSelector._options.first)
        .$2
        .tr;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.rate_review_outlined,
            title: 'review_and_duration'.tr,
            subtitle: 'review_subtitle'.tr,
            primary: primary,
          ),
          const SizedBox(height: Spacing.xl),

          // Summary card
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('offer_summary'.tr, icon: Icons.summarize_outlined),
                const SizedBox(height: Spacing.md),
                _ReviewRow('العنوان', titleCtrl.text.trim()),
                _ReviewRow(
                  'نوع العرض',
                  controller.offerType == 'discount'
                      ? 'خصم ${valueCtrl.text}%'
                      : 'سعر ${valueCtrl.text} ريال',
                ),
                if (controller.selectedPlan != null)
                  _ReviewRow('الباقة',
                      '${controller.selectedPlan!.name} — ${controller.selectedPlan!.price?.toStringAsFixed(0)} ريال/شهر'),
                _ReviewRow('subscription_duration'.tr, durationLabel),
                _ReviewRow(
                  'المناطق',
                  controller.selectedZoneIds.isEmpty
                      ? 'not_selected'.tr
                      : '${controller.selectedZoneIds.length} منطقة',
                ),
                _ReviewRow(
                  'أنواع العقار',
                  controller.selectedCategoryIds.isEmpty
                      ? 'not_selected'.tr
                      : '${controller.selectedCategoryIds.length} نوع',
                ),
                if (controller.expiryDateText.isNotEmpty)
                  _ReviewRow(
                      'subscription_expires'.tr, controller.expiryDateText),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          _LiveTotalCard(controller: controller, primary: primary),
          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;
  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:',
              style: AppTypography.captionMedium.copyWith(color: Colors.grey.shade600)),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(value,
                style: AppTypography.captionMedium
                    .copyWith(color: const Color(0xFF1A2340))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

/// حقل نصي محلي بمقاييس النظام (Height 56 / Radius 12) بدل MyTextField
/// المشترك (Radius 8) — استبدال محصور بهذه الشاشة فقط.
Widget _dsTextField(
  BuildContext context, {
  required String hintText,
  required TextEditingController controller,
  TextInputType keyboardType = TextInputType.text,
  int maxLines = 1,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    maxLines: maxLines,
    style: AppTypography.body.copyWith(color: AppColors.textPrimary(context)),
    decoration: dsInputDecoration(context, hint: hintText),
  );
}

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primary;
  const _StepHeader(
      {required this.icon,
      required this.title,
      required this.subtitle,
      required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
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
              Text(title,
                  style: AppTypography.title
                      .copyWith(color: AppColors.textPrimary(context))),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary(context))),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CardSpec.padding),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 10, opacity: 0.04),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  const _FieldLabel(this.text, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: IconSpec.small, color: Theme.of(context).primaryColor),
        const SizedBox(width: Spacing.xs),
        Text(text,
            style: AppTypography.small
                .copyWith(color: AppColors.textPrimary(context))),
      ],
    );
  }
}

/// تلميح تحقّق مبسّط أسفل الحقول الإلزامية (نوع الخدمة/العنوان/القيمة) — يظهر
/// فقط ما دام الحقل فارغًا، بدل انتظار محاولة إرسال النموذج، متسقًا مع نمط
/// _FormatHint في provider_upgrade_screen.dart (لون داعٍ للانتباه + أيقونة
/// صغيرة).
class _RequiredHint extends StatelessWidget {
  final String text;
  const _RequiredHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(text,
                style: AppTypography.caption.copyWith(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _OfferTypeCard extends StatelessWidget {
  final ServiceOfferController controller;
  final String type;
  final IconData icon;
  final bool useRiyalIcon;
  final String title;
  final String sub;
  final Color primary;
  // يُستدعى بعد controller.setOfferType(type) — يستخدمه _Step1ServiceInfo
  // لتفريغ حقل القيمة عند تبديل نوع العرض، كي لا يبقى رقم "20" (نسبة خصم)
  // ظاهرًا تحت تسمية "السعر (ريال)" بعد التبديل لسعر مباشر، وهو ما قد يُقرأ
  // خطأً كسعر 20 ريال.
  final VoidCallback? onSelected;
  const _OfferTypeCard({
    required this.controller,
    required this.type,
    required this.icon,
    this.useRiyalIcon = false,
    required this.title,
    required this.sub,
    required this.primary,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = controller.offerType == type;
    final unselectedText = AppColors.textSecondary(context);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          controller.setOfferType(type);
          onSelected?.call();
        },
        child: AnimatedContainer(
          duration: AnimSpec.button,
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.08)
                : AppColors.background(context),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: selected ? primary : AppColors.border(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              useRiyalIcon
                  ? Image.asset(
                      'assets/image/riyals.png',
                      width: IconSpec.small,
                      height: IconSpec.small,
                      color: selected ? primary : unselectedText,
                    )
                  : Icon(icon,
                      size: IconSpec.small,
                      color: selected ? primary : unselectedText),
              const SizedBox(height: Spacing.sm),
              Text(title,
                  style: AppTypography.smallBold.copyWith(
                      color: selected ? primary : AppColors.textPrimary(context))),
              const SizedBox(height: 3),
              Text(sub, style: AppTypography.badge.copyWith(color: unselectedText)),
            ],
          ),
        ),
      ),
    );
  }
}

/// شارة عائمة (Pill) توضح "المتبقي" من حد الباقة بدل رقم "current/max" جامد
/// — تتحول للون primary الممتلئ عند اكتمال الاختيار، وللتحذير عند التجاوز.
class _LimitBadge extends StatelessWidget {
  final int current;
  final int max;
  final Color primary;
  const _LimitBadge(
      {required this.current, required this.max, required this.primary});

  @override
  Widget build(BuildContext context) {
    final over = current > max;
    final remaining = max - current;
    final full = !over && remaining == 0;

    final String label;
    final IconData icon;
    if (over) {
      label = '+${current - max}';
      icon = Icons.info_rounded;
    } else if (full) {
      label = 'اكتمل الاختيار';
      icon = Icons.check_circle_rounded;
    } else {
      label = 'متبقي $remaining';
      icon = Icons.radio_button_unchecked_rounded;
    }

    final Color bg = over
        ? AppColors.warning.withValues(alpha: 0.12)
        : full
            ? primary
            : primary.withValues(alpha: 0.1);
    final Color fg = over ? AppColors.warning : (full ? Colors.white : primary);

    return AnimatedContainer(
      duration: AnimSpec.button,
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
        boxShadow: AppShadows.soft(blur: 8, opacity: full ? 0.18 : 0.05),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 4),
          Text(label,
              style: AppTypography.badge.copyWith(fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }
}

class _OverLimitWarning extends StatelessWidget {
  final String message;
  const _OverLimitWarning(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: Spacing.sm),
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.small),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 15, color: AppColors.warning),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(message,
                style: AppTypography.caption.copyWith(color: AppColors.warning)),
          ),
        ],
      ),
    );
  }
}
