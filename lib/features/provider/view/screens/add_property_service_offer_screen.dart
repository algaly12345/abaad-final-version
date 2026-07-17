import 'dart:io';

import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_setup_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/widgets/app_dropdown.dart';
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
  bool _checked = false;

  List<(String, String, String)> get _terms => [
    ('📋', 'term_accuracy_title'.tr, 'term_accuracy_body'.tr),
    ('⚖️', 'term_compliance_title'.tr, 'term_compliance_body'.tr),
    ('🔍', 'term_review_title'.tr, 'term_review_body'.tr),
    ('💳', 'term_payment_title'.tr, 'term_payment_body'.tr),
    ('🔒', 'term_privacy_title'.tr, 'term_privacy_body'.tr),
  ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          // ─── Scrollable content ───────────────────────────────────────
          CustomScrollView(
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
                      emoji: _terms[i].$1,
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
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: IconSpec.small),
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
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
                color: Colors.white,
                boxShadow: AppShadows.soft(blur: 16, opacity: 0.09),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox row
                  GestureDetector(
                    onTap: () => setState(() => _checked = !_checked),
                    child: AnimatedContainer(
                      duration: AnimSpec.button,
                      padding: const EdgeInsets.all(Spacing.md),
                      decoration: BoxDecoration(
                        color: _checked
                            ? primary.withValues(alpha: 0.06)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                        border: Border.all(
                          color:
                              _checked ? primary : Colors.grey.shade200,
                          width: _checked ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: AnimSpec.button,
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _checked ? primary : Colors.white,
                              borderRadius: BorderRadius.circular(AppRadius.small - 2),
                              border: Border.all(
                                color: _checked
                                    ? primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: _checked
                                ? const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14)
                                : null,
                          ),
                          const SizedBox(width: Spacing.md),
                          Expanded(
                            child: Text(
                              'agree_all_terms'.tr,
                              style: AppTypography.small.copyWith(
                                color: _checked
                                    ? primary
                                    : Colors.grey.shade700,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),

                  // Start button
                  AnimatedOpacity(
                    opacity: _checked ? 1.0 : 0.45,
                    duration: AnimSpec.dialog,
                    child: DSPrimaryButton(
                      label: 'start_adding_now'.tr,
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _checked ? widget.onAccepted : null,
                    ),
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
  final String emoji;
  final String title;
  final String body;
  const _TermItem(
      {required this.emoji, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Spacing.md),
      padding: const EdgeInsets.all(CardSpec.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 8, opacity: 0.04),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.smallBold
                        .copyWith(color: const Color(0xFF1A2340))),
                const SizedBox(height: Spacing.xs),
                Text(body,
                    style: AppTypography.caption.copyWith(
                        color: Colors.grey.shade600, height: 1.55)),
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
  void dispose() {
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
        return c.selectedPlanIndex >= 0;
      case 2:
        return c.selectedZoneIds.isNotEmpty &&
            c.selectedCategoryIds.isNotEmpty;
      case 3:
        return c.selectedDuration > 0;
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
            backgroundColor: const Color(0xFFF4F6FB),
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

  Widget _buildTopBar(BuildContext context, Color primary) {
    return Container(
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
            SizedBox(
              height: AppBarSpec.height,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          color: Colors.white, size: IconSpec.small),
                      onPressed: _goBack,
                    ),
                    Expanded(
                      child: Text(
                        'add_service_inside_estate'.tr,
                        style: AppTypography.bodyBold.copyWith(color: Colors.white),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),

            // Step indicators
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  Spacing.pagePadding, 0, Spacing.pagePadding, Spacing.xl),
              child: Row(
                children: List.generate(_totalSteps * 2 - 1, (i) {
                  if (i.isOdd) {
                    // connector line
                    final stepIndex = i ~/ 2;
                    final isCompleted = stepIndex < _step;
                    return Expanded(
                      child: Container(
                        height: 2,
                        color: isCompleted
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.25),
                      ),
                    );
                  }
                  final index = i ~/ 2;
                  final isActive = index == _step;
                  final isDone = index < _step;
                  return _StepDot(
                    index: index,
                    label: _stepLabels[index],
                    icon: _stepIcons[index],
                    isActive: isActive,
                    isDone: isDone,
                    primary: primary,
                  );
                }),
              ),
            ),
          ],
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
      padding: EdgeInsets.fromLTRB(
        Spacing.pagePadding,
        Spacing.md,
        Spacing.pagePadding,
        Spacing.md + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: AppShadows.soft(blur: 16, opacity: 0.08),
      ),
      child: Row(
        children: [
          if (_step > 0)
            SizedBox(
              height: ButtonSpec.primaryHeight,
              child: OutlinedButton(
                onPressed: _goBack,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.lg),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ButtonSpec.radius)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.arrow_back_rounded,
                        size: IconSpec.small, color: Colors.grey.shade600),
                    const SizedBox(width: Spacing.xs),
                    Text('previous'.tr,
                        style: AppTypography.smallMedium
                            .copyWith(color: Colors.grey.shade700)),
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
                      style: AppTypography.badge.copyWith(color: Colors.grey)),
                  c.isPriceLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          '${total.toStringAsFixed(0)} ريال',
                          style: AppTypography.subtitle
                              .copyWith(color: primary, fontWeight: FontWeight.w700),
                        ),
                ],
                DSPrimaryButton(
                  label: isLast ? 'complete_and_pay'.tr : 'next'.tr,
                  icon: isLast ? Icons.payments_outlined : Icons.arrow_forward_rounded,
                  loading: c.isSubmitting,
                  onPressed: canNext ? () => _goNext(c) : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final int index;
  final String label;
  final IconData icon;
  final bool isActive;
  final bool isDone;
  final Color primary;

  const _StepDot({
    required this.index,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.isDone,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedContainer(
          duration: AnimSpec.card,
          width: isActive ? 44 : 32,
          height: isActive ? 44 : 32,
          decoration: BoxDecoration(
            color: isDone
                ? Colors.white
                : isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: isActive ? AppShadows.soft(blur: 10, opacity: 0.2) : null,
          ),
          child: Center(
            child: isDone
                ? Icon(Icons.check_rounded, color: primary, size: 16)
                : Icon(
                    icon,
                    color: isActive
                        ? primary
                        : Colors.white.withValues(alpha: 0.6),
                    size: isActive ? 20 : 15,
                  ),
          ),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          label,
          style: (isActive ? AppTypography.badge.copyWith(fontWeight: FontWeight.w600) : AppTypography.badge).copyWith(
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.6),
          ),
        ),
      ],
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
                      color: const Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.25)),
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
                                      .copyWith(color: Colors.grey)),
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
                    ),
                    const SizedBox(width: Spacing.sm),
                    _OfferTypeCard(
                      controller: controller,
                      type: 'discount',
                      icon: Icons.percent_rounded,
                      title: 'خصم %',
                      sub: 'نسبة خصم على السعر',
                      primary: primary,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
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
            return GestureDetector(
              onTap: () => controller.selectPlan(i),
              child: AnimatedContainer(
                duration: AnimSpec.card,
                margin: const EdgeInsets.only(bottom: Spacing.md),
                padding: const EdgeInsets.all(CardSpec.padding),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.large),
                  border: Border.all(
                    color: selected ? primary : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: AppShadows.soft(
                      blur: selected ? 16 : 8, opacity: selected ? 0.08 : 0.04),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: selected
                                ? primary
                                : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.workspace_premium_rounded,
                              color: selected ? Colors.white : Colors.grey,
                              size: IconSpec.defaultSize),
                        ),
                        const SizedBox(width: Spacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plan.name ?? '',
                                  style: AppTypography.bodyBold
                                      .copyWith(color: const Color(0xFF1A2340))),
                              const SizedBox(height: 2),
                              Text(
                                '${plan.price?.toStringAsFixed(0)} ${'sar_per_month'.tr}',
                                style: AppTypography.subtitle.copyWith(
                                    color: primary, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                                color: primary, shape: BoxShape.circle),
                            child: const Icon(Icons.check_rounded,
                                color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                    const SizedBox(height: Spacing.md),
                    const Divider(height: 1),
                    const SizedBox(height: Spacing.md),
                    Wrap(
                      spacing: Spacing.sm,
                      runSpacing: Spacing.sm,
                      children: [
                        _PlanFeature('${plan.numberOfAds ?? 0} إعلانات',
                            Icons.campaign_outlined, primary, selected),
                        _PlanFeature(
                            '${plan.numberOfCategories ?? 0} أنواع',
                            Icons.category_outlined,
                            primary,
                            selected),
                        _PlanFeature('${plan.numberOfZone ?? 0} مناطق',
                            Icons.map_outlined, primary, selected),
                        if (plan.featuredDisplay ?? false)
                          _PlanFeature(
                              'featured_display'.tr, Icons.star_outline, primary, selected),
                        if (plan.interactiveReports ?? false)
                          _PlanFeature('reports_label'.tr, Icons.bar_chart_outlined,
                              primary, selected),
                        if (plan.crmSystem ?? false)
                          _PlanFeature(
                              'نظام CRM', Icons.people_outline, primary, selected),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: Spacing.xxxl),
        ],
      ),
    );
  }
}

class _PlanFeature extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color primary;
  final bool selected;
  const _PlanFeature(this.label, this.icon, this.primary, this.selected);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: selected
            ? primary.withValues(alpha: 0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(ChipSpec.radius),
        border: Border.all(
          color: selected ? primary.withValues(alpha: 0.3) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 13, color: selected ? primary : Colors.grey.shade500),
          const SizedBox(width: 5),
          Text(label,
              style: AppTypography.badge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? primary : Colors.grey.shade600)),
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

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _FieldLabel('المناطق', icon: Icons.location_on_outlined),
                    const Spacer(),
                    if (allowedZones > 0)
                      _LimitBadge(
                          current: controller.selectedZoneIds.length,
                          max: allowedZones,
                          primary: primary),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: controller.zones.map((z) {
                    final selected =
                        controller.selectedZoneIds.contains(z.id);
                    return _SelectChip(
                      label: (z.nameAr?.isNotEmpty ?? false)
                          ? z.nameAr!
                          : (z.name ?? ''),
                      selected: selected,
                      primary: primary,
                      onTap: () => controller.toggleZone(z.id ?? 0),
                    );
                  }).toList(),
                ),
                if (allowedZones > 0 &&
                    controller.selectedZoneIds.length > allowedZones)
                  _OverLimitWarning(
                      'ستُضاف 50 ريال على كل منطقة زيادة عن $allowedZones'),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _FieldLabel('أنواع العقار',
                        icon: Icons.apartment_outlined),
                    const Spacer(),
                    if (allowedCats > 0)
                      _LimitBadge(
                          current: controller.selectedCategoryIds.length,
                          max: allowedCats,
                          primary: primary),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.sm,
                  children: controller.categories.map((cat) {
                    final selected =
                        controller.selectedCategoryIds.contains(cat.id);
                    return _SelectChip(
                      label: (cat.nameAr?.isNotEmpty ?? false)
                          ? cat.nameAr!
                          : (cat.name ?? ''),
                      selected: selected,
                      primary: primary,
                      onTap: () =>
                          controller.toggleCategory(cat.id ?? 0),
                    );
                  }).toList(),
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
    final durations = [
      {'v': 1, 'l': 'one_month'.tr},
      {'v': 3, 'l': 'three_months'.tr},
      {'v': 6, 'l': 'six_months'.tr},
      {'v': 12, 'l': 'one_year'.tr},
    ];

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
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Duration
          _Card(
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
                  children: durations.map((d) {
                    final selected =
                        controller.selectedDuration == d['v'];
                    return GestureDetector(
                      onTap: () =>
                          controller.selectDuration(d['v'] as int),
                      child: AnimatedContainer(
                        duration: AnimSpec.card,
                        decoration: BoxDecoration(
                          color: selected ? primary : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(AppRadius.medium),
                          border: Border.all(
                            color: selected
                                ? primary
                                : Colors.grey.shade200,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            d['l'] as String,
                            style: AppTypography.smallMedium.copyWith(
                              color: selected
                                  ? Colors.white
                                  : Colors.grey.shade700,
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
                      border: Border.all(
                          color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded,
                            color: primary, size: IconSpec.small),
                        const SizedBox(width: Spacing.sm),
                        Text('${'subscription_expires'.tr}: ',
                            style: AppTypography.caption
                                .copyWith(color: Colors.grey.shade600)),
                        Text(controller.expiryDateText,
                            style: AppTypography.smallBold.copyWith(color: primary)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
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
                      .copyWith(color: const Color(0xFF1A2340))),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: AppTypography.caption.copyWith(color: Colors.grey.shade500)),
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
        color: Colors.white,
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
                .copyWith(color: const Color(0xFF1A2340))),
      ],
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
  const _OfferTypeCard({
    required this.controller,
    required this.type,
    required this.icon,
    this.useRiyalIcon = false,
    required this.title,
    required this.sub,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final selected = controller.offerType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setOfferType(type),
        child: AnimatedContainer(
          duration: AnimSpec.button,
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.08) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: selected ? primary : Colors.grey.shade200,
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
                      color: selected ? primary : Colors.grey.shade400,
                    )
                  : Icon(icon,
                      size: IconSpec.small,
                      color: selected ? primary : Colors.grey.shade400),
              const SizedBox(height: Spacing.sm),
              Text(title,
                  style: AppTypography.smallBold.copyWith(
                      color: selected ? primary : Colors.grey.shade800)),
              const SizedBox(height: 3),
              Text(sub,
                  style: AppTypography.badge.copyWith(color: Colors.grey.shade500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;
  const _SelectChip(
      {required this.label,
      required this.selected,
      required this.primary,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AnimSpec.tap,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(ChipSpec.radius),
          border: Border.all(
              color: selected ? primary : Colors.grey.shade200,
              width: selected ? 1.5 : 1),
        ),
        child: Text(label,
            style: AppTypography.captionMedium
                .copyWith(color: selected ? Colors.white : Colors.grey.shade700)),
      ),
    );
  }
}

class _LimitBadge extends StatelessWidget {
  final int current;
  final int max;
  final Color primary;
  const _LimitBadge(
      {required this.current, required this.max, required this.primary});

  @override
  Widget build(BuildContext context) {
    final over = current > max;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(
        color: over
            ? AppColors.warning.withValues(alpha: 0.12)
            : primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ChipSpec.radius),
        border: Border.all(
            color: over
                ? AppColors.warning.withValues(alpha: 0.4)
                : primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$current / $max',
        style: AppTypography.badge.copyWith(
            fontWeight: FontWeight.w600,
            color: over ? AppColors.warning : primary),
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
