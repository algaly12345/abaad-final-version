import 'dart:io';

import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_setup_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/app_dropdown.dart';
import 'package:abaad_flutter/shared/widgets/my_text_field.dart';
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
    Get.find<ServiceOfferController>().resetAll();
    Get.find<ServiceOfferController>().loadSetupData();
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
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.3),
                                        width: 2),
                                  ),
                                  child: const Icon(Icons.handshake_outlined,
                                      color: Colors.white, size: 36),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'service_terms_title'.tr,
                                  style: robotoBold.copyWith(
                                      fontSize: 20, color: Colors.white),
                                ),
                                const SizedBox(height: 6),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40),
                                  child: Text(
                                    'service_terms_subtitle'.tr,
                                    style: robotoRegular.copyWith(
                                      fontSize: 12,
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      height: 1.55,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Terms list — flows naturally below header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
                            color: Colors.white, size: 20),
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
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPadding),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.09),
                    blurRadius: 20,
                    offset: const Offset(0, -6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Checkbox row
                  GestureDetector(
                    onTap: () => setState(() => _checked = !_checked),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _checked
                            ? primary.withValues(alpha: 0.06)
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color:
                              _checked ? primary : Colors.grey.shade200,
                          width: _checked ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color: _checked ? primary : Colors.white,
                              borderRadius: BorderRadius.circular(6),
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
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'agree_all_terms'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: 12.5,
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
                  const SizedBox(height: 12),

                  // Start button
                  AnimatedOpacity(
                    opacity: _checked ? 1.0 : 0.45,
                    duration: const Duration(milliseconds: 250),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _checked ? widget.onAccepted : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              primary.withValues(alpha: 0.4),
                          elevation: _checked ? 4 : 0,
                          shadowColor: primary.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'start_adding_now'.tr,
                              style: robotoBold.copyWith(
                                  fontSize: 15, color: Colors.white),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 18),
                          ],
                        ),
                      ),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: robotoBold.copyWith(
                        fontSize: 13, color: const Color(0xFF1A2340))),
                const SizedBox(height: 4),
                Text(body,
                    style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.55)),
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
                  const SizedBox(height: 16),
                  Text('loading_data'.tr,
                      style: robotoRegular.copyWith(color: Colors.grey)),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded,
                        color: Colors.white, size: 20),
                    onPressed: _goBack,
                  ),
                  Expanded(
                    child: Text(
                      'add_service_inside_estate'.tr,
                      style: robotoBold.copyWith(
                          fontSize: 16, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Step indicators
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
        20, 12, 20, 12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Row(
        children: [
          if (_step > 0)
            OutlinedButton(
              onPressed: _goBack,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 14),
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_rounded,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text('previous'.tr,
                      style: robotoMedium.copyWith(
                          color: Colors.grey.shade700, fontSize: 13)),
                ],
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLast && total > 0) ...[
                  Text('total'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: 10, color: Colors.grey)),
                  c.isPriceLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(
                          '${total.toStringAsFixed(0)} ريال',
                          style: robotoBold.copyWith(
                              fontSize: 18, color: primary),
                        ),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: c.isSubmitting
                      ? Center(
                          child: CircularProgressIndicator(color: primary))
                      : ElevatedButton(
                          onPressed: canNext ? () => _goNext(c) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                primary.withValues(alpha: 0.35),
                            elevation: canNext ? 3 : 0,
                            shadowColor: primary.withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLast ? 'complete_and_pay'.tr : 'next'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: 15, color: Colors.white),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLast
                                    ? Icons.payments_outlined
                                    : Icons.arrow_forward_rounded,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
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
          duration: const Duration(milliseconds: 300),
          width: isActive ? 44 : 32,
          height: isActive ? 44 : 32,
          decoration: BoxDecoration(
            color: isDone
                ? Colors.white
                : isActive
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3))
                  ]
                : null,
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
        const SizedBox(height: 6),
        Text(
          label,
          style: (isActive ? robotoMedium : robotoRegular).copyWith(
            fontSize: 10,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.miscellaneous_services_outlined,
            title: 'service_data'.tr,
            subtitle: 'enter_basic_service_info'.tr,
            primary: primary,
          ),
          const SizedBox(height: 20),

          // Image picker
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('صورة العرض', icon: Icons.image_outlined),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: controller.pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F6FB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.25)),
                    ),
                    child: controller.pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
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
                              const SizedBox(height: 8),
                              Text('tap_to_choose_image'.tr,
                                  style: robotoRegular.copyWith(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                  ),
                ),
                if (controller.pickedImage != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: controller.pickImage,
                    icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                    label: Text('change_image'.tr),
                    style: TextButton.styleFrom(foregroundColor: primary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Service type
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('نوع الخدمة', icon: Icons.category_outlined),
                const SizedBox(height: 10),
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
          const SizedBox(height: 14),

          // Title
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('عنوان العرض', icon: Icons.title_rounded),
                const SizedBox(height: 10),
                MyTextField(
                  hintText: 'اكتب عنواناً واضحاً للعرض',
                  controller: titleCtrl,
                  showBorder: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Offer type
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('نوع العرض', icon: Icons.sell_outlined),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _OfferTypeCard(
                      controller: controller,
                      type: 'price',
                      icon: Icons.attach_money_rounded,
                      title: 'سعر مباشر',
                      sub: 'سعر ثابت ومحدد',
                      primary: primary,
                    ),
                    const SizedBox(width: 10),
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
                const SizedBox(height: 14),
                _FieldLabel(
                  controller.offerType == 'discount'
                      ? 'نسبة الخصم (%)'
                      : 'السعر (ريال)',
                  icon: Icons.numbers_rounded,
                ),
                const SizedBox(height: 8),
                MyTextField(
                  hintText: controller.offerType == 'discount'
                      ? 'مثال: 20'
                      : 'مثال: 500',
                  controller: valueCtrl,
                  inputType: TextInputType.number,
                  showBorder: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Description
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('وصف الخدمة', icon: Icons.description_outlined),
                const SizedBox(height: 10),
                MyTextField(
                  hintText: 'اكتب وصفاً احترافياً وتفصيلياً للخدمة...',
                  controller: descCtrl,
                  maxLines: 4,
                  showBorder: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: [
          _StepHeader(
            icon: Icons.workspace_premium_outlined,
            title: 'choose_plan'.tr,
            subtitle: 'choose_plan_subtitle'.tr,
            primary: primary,
          ),
          const SizedBox(height: 20),
          ...List.generate(controller.servicePlans.length, (i) {
            final ServicePlanModel plan = controller.servicePlans[i];
            final selected = i == controller.selectedPlanIndex;
            return GestureDetector(
              onTap: () => controller.selectPlan(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.06)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? primary : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: selected ? 0.08 : 0.04),
                      blurRadius: selected ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
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
                              size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(plan.name ?? '',
                                  style: robotoBold.copyWith(
                                      fontSize: 15,
                                      color: const Color(0xFF1A2340))),
                              const SizedBox(height: 2),
                              Text(
                                '${plan.price?.toStringAsFixed(0)} ${'sar_per_month'.tr}',
                                style: robotoBold.copyWith(
                                    fontSize: 18, color: primary),
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
                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
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
          const SizedBox(height: 60),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? primary.withValues(alpha: 0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
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
              style: robotoMedium.copyWith(
                  fontSize: 11,
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.map_outlined,
            title: 'zones_and_categories'.tr,
            subtitle: 'zones_categories_subtitle'.tr,
            primary: primary,
          ),
          const SizedBox(height: 20),

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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
          const SizedBox(height: 14),

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
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
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
          const SizedBox(height: 80),
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.rate_review_outlined,
            title: 'review_and_duration'.tr,
            subtitle: 'review_subtitle'.tr,
            primary: primary,
          ),
          const SizedBox(height: 20),

          // Summary card
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('offer_summary'.tr, icon: Icons.summarize_outlined),
                const SizedBox(height: 14),
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
          const SizedBox(height: 14),

          // Duration
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('subscription_duration'.tr,
                    icon: Icons.calendar_month_outlined),
                const SizedBox(height: 12),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.4,
                  children: durations.map((d) {
                    final selected =
                        controller.selectedDuration == d['v'];
                    return GestureDetector(
                      onTap: () =>
                          controller.selectDuration(d['v'] as int),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: selected ? primary : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
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
                            style: robotoMedium.copyWith(
                              fontSize: 13,
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
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.event_available_rounded,
                            color: primary, size: 18),
                        const SizedBox(width: 10),
                        Text('${'subscription_expires'.tr}: ',
                            style: robotoRegular.copyWith(
                                fontSize: 12, color: Colors.grey.shade600)),
                        Text(controller.expiryDateText,
                            style: robotoBold.copyWith(
                                fontSize: 13, color: primary)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 80),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:',
              style: robotoMedium.copyWith(
                  fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value,
                style: robotoMedium.copyWith(
                    fontSize: 12, color: const Color(0xFF1A2340))),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

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
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: robotoBold.copyWith(
                      fontSize: 17, color: const Color(0xFF1A2340))),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: robotoRegular.copyWith(
                      fontSize: 12, color: Colors.grey.shade500)),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
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
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 6),
        Text(text,
            style: robotoMedium.copyWith(
                fontSize: 13, color: const Color(0xFF1A2340))),
      ],
    );
  }
}

class _OfferTypeCard extends StatelessWidget {
  final ServiceOfferController controller;
  final String type;
  final IconData icon;
  final String title;
  final String sub;
  final Color primary;
  const _OfferTypeCard({
    required this.controller,
    required this.type,
    required this.icon,
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
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? primary.withValues(alpha: 0.08) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? primary : Colors.grey.shade200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon,
                  size: 20,
                  color: selected ? primary : Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(title,
                  style: robotoBold.copyWith(
                      fontSize: 13,
                      color: selected ? primary : Colors.grey.shade800)),
              const SizedBox(height: 3),
              Text(sub,
                  style: robotoRegular.copyWith(
                      fontSize: 10, color: Colors.grey.shade500)),
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
              color: selected ? primary : Colors.grey.shade200,
              width: selected ? 1.5 : 1),
        ),
        child: Text(label,
            style: robotoMedium.copyWith(
                fontSize: 12,
                color: selected ? Colors.white : Colors.grey.shade700)),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: over
            ? Colors.orange.withValues(alpha: 0.12)
            : primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: over
                ? Colors.orange.withValues(alpha: 0.4)
                : primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        '$current / $max',
        style: robotoMedium.copyWith(
            fontSize: 11,
            color: over ? Colors.orange.shade700 : primary),
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
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 15, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: robotoRegular.copyWith(
                    fontSize: 11, color: Colors.orange.shade800)),
          ),
        ],
      ),
    );
  }
}
