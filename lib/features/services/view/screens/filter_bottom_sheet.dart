import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/services/view/screens/services_catalog_screen.dart'
    show serviceCategoryIcon;
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/scroll_reveal_item.dart';
import 'package:abaad_flutter/shared/widgets/type_option_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);

    return GetBuilder<ServicesController>(
      builder: (controller) {
        final activeCount = _activeCount(controller);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface(context),
            borderRadius: const BorderRadius.vertical(
                top: Radius.circular(BottomSheetSpec.radius)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, primary, activeCount),

              // ─── Scrollable content ────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نوع العرض — تعبئة لونية ناعمة للمُختار
                      _Section(
                        title: 'offer_type'.tr,
                        icon: Icons.local_offer_rounded,
                        child: _SegmentedRow(
                          options: ServicesController.offerTypeOptions,
                          selected: controller.selectedOfferType,
                          primary: primary,
                          onSelect: controller.setOfferType,
                        ),
                      ),
                      const _Divider(),

                      // ملاحظة: قسم "الموقع" لم يعد هنا — أصبح له زر مخصّص
                      // وحيد أعلى قائمة الخدمات (_QuickFilterRow في
                      // services_catalog_screen.dart) يفتح ZoneFilterSheet
                      // مباشرة. أما "نوع الخدمة" فأصبح شريطًا أفقيًا دائم
                      // الظهور أسفل ذلك الزر (_ServiceTypesBar)، لكن "نوع
                      // العقار" بقي هنا في الفلاتر المتقدمة — مطابقةً لموضعه
                      // في التطبيق المرجعي.

                      // نوع العقار — بانتظار وصول filtersData يُعرض هيكل تحميل
                      // بنفس أبعاد الشبكة الفعلية بدل اختفاء القسم بالكامل، كي
                      // لا تقفز الأبعاد ولا يبدو القسم كأنه غير موجود أصلًا.
                      if (controller.filtersData == null) ...[
                        _Section(
                          title: 'property_type'.tr,
                          icon: Icons.home_work_rounded,
                          bleedChild: true,
                          child: const _HorizontalCardSkeleton(count: 5),
                        ),
                        const _Divider(),
                      ] else if ((controller.filtersData?.categories ?? [])
                          .isNotEmpty) ...[
                        _Section(
                          title: 'property_type'.tr,
                          icon: Icons.home_work_rounded,
                          bleedChild: true,
                          child: _CategoryList(
                            controller: controller,
                            primary: primary,
                          ),
                        ),
                        const _Divider(),
                      ],

                      // نطاق السعر
                      _Section(
                        title: 'price_range'.tr,
                        icon: Icons.sell_rounded,
                        child: controller.filtersData == null
                            ? const _PriceRangeSkeleton()
                            : _PriceRangeSection(
                                controller: controller,
                                primary: primary,
                              ),
                      ),
                      const _Divider(),

                      // مزود الخدمة
                      if (controller.filtersData == null) ...[
                        _Section(
                          title: 'service_provider'.tr,
                          icon: Icons.storefront_rounded,
                          bleedChild: true,
                          child: const _ChipRowSkeleton(),
                        ),
                        const _Divider(),
                      ] else if ((controller.filtersData?.providers ?? [])
                          .isNotEmpty) ...[
                        _Section(
                          title: 'service_provider'.tr,
                          icon: Icons.storefront_rounded,
                          bleedChild: true,
                          child: _ProviderChips(
                            controller: controller,
                            primary: primary,
                          ),
                        ),
                        const _Divider(),
                      ],

                      // الترتيب (فرز + الأقرب مني)
                      _Section(
                        title: 'sort_by'.tr,
                        icon: Icons.sort_rounded,
                        bleedChild: true,
                        child: _ChipRow(
                          options: ServicesController.sortOptions,
                          selected: {controller.sortBy},
                          primary: primary,
                          onTap: (v) => v == 'الأقرب مني'
                              ? controller.enableNearMe()
                              : controller.setSortBy(v),
                        ),
                      ),

                      // نطاق البحث (يظهر فقط عند تفعيل "الأقرب مني")
                      if (controller.nearMeActive) ...[
                        const _Divider(),
                        _Section(
                          title: 'search_radius'.tr,
                          icon: Icons.radar_rounded,
                          bleedChild: true,
                          child: _ChipRow(
                            options: ServicesController.radiusOptions
                                .map((r) => r['label']!)
                                .toList(),
                            selected: {
                              ServicesController.radiusOptions.firstWhere(
                                (r) => r['value'] == controller.radiusOption,
                              )['label']!
                            },
                            primary: primary,
                            onTap: (label) {
                              final value = ServicesController.radiusOptions
                                  .firstWhere((r) => r['label'] == label)['value']!;
                              controller.setRadiusOption(value);
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: Spacing.sm),
                    ],
                  ),
                ),
              ),

              // ─── Sticky footer ─────────────────────────────────────────
              _buildFooter(context, primary, controller, activeCount),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Color primary, int activeCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(BottomSheetSpec.radius)),
        border: Border(bottom: BorderSide(color: AppColors.divider(context))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider(context),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.fromLTRB(Spacing.lg, 14, Spacing.md, Spacing.md),
            child: Row(
              children: [
                _RoundIconButton(icon: Icons.close_rounded, onTap: () => Get.back()),
                Expanded(
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.tune_rounded, size: 16, color: primary),
                        ),
                        const SizedBox(width: Spacing.sm),
                        Flexible(
                          child: Text(
                            'filter_services'.tr,
                            style: AppTypography.smallBold.copyWith(
                                fontSize: 17, color: AppColors.textPrimary(context)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (activeCount > 0) ...[
                          const SizedBox(width: Spacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$activeCount',
                              style: AppTypography.badge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, Color primary,
      ServicesController controller, int activeCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        border: Border(top: BorderSide(color: AppColors.divider(context))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, Spacing.md),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: ButtonSpec.primaryHeight,
                  child: OutlinedButton(
                    onPressed: () => controller.clearFilters(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary(context),
                      side: BorderSide(color: AppColors.border(context), width: 1.4),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ButtonSpec.radius)),
                    ),
                    child: Text(
                      'reset_fields'.tr,
                      style: AppTypography.smallBold.copyWith(
                          fontSize: 13.5, color: AppColors.textSecondary(context)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                flex: 3,
                child: SizedBox(
                  height: ButtonSpec.primaryHeight,
                  child: ElevatedButton(
                    onPressed: () => controller.applyFilters(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ButtonSpec.radius)),
                    ),
                    child: Text(
                      activeCount > 0
                          ? '${'apply_filters'.tr} ($activeCount)'
                          : 'apply_filters'.tr,
                      style: AppTypography.bodyBold
                          .copyWith(fontSize: 14.5, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _activeCount(ServicesController c) {
    int count = 0;
    if (c.selectedOfferType != 'الكل') count++;
    if (c.sortBy != 'الأحدث') count++;
    count += c.selectedServiceTypes.length;
    count += c.selectedProviders.length;
    count += c.selectedZones.length;
    count += c.selectedCategories.length;
    return count;
  }
}

// ─── زر دائري صغير موحّد (إغلاق الورقة) — مقاس ثابت 32×32 يوازن بصريًا مع
// SizedBox(width: 32) بالطرف الآخر من رأس الورقة فيبقى العنوان مركزًا تمامًا ─

// ─── يزيل توهّج التمرير الزائد (glow) وشريط التمرير الافتراضي عن كل القوائم
// الأفقية (نوع العقار/الترتيب/نطاق البحث/مزود الخدمة) لمظهر أنظف عند وصول
// المستخدم لحافة القائمة ────────────────────────────────────────────────────

class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.grey.shade100,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, size: 18, color: AppColors.textSecondary(context)),
        ),
      ),
    );
  }
}

// ─── هياكل تحميل بنفس أبعاد كل قسم من أقسام الفلاتر المتقدمة (نوع العقار/
// نطاق السعر/مزود الخدمة) — تحل محل مؤشر دوّار عام واحد يظهر وسط الورقة
// بينما الأقسام نفسها تختفي بصمت، فلا تقفز الأبعاد لحظة وصول filtersData
// ولا تبدو الورقة فارغة بلا تفسير أثناء الانتظار ───────────────────────────

class _ChipRowSkeleton extends StatelessWidget {
  const _ChipRowSkeleton();

  static const List<double> _widths = [86, 112, 70, 96, 74];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEF0F5);

    return Shimmer(
      duration: const Duration(milliseconds: 1400),
      interval: const Duration(milliseconds: 350),
      color: dark ? Colors.white : Theme.of(context).primaryColor,
      colorOpacity: dark ? 0.16 : 0.3,
      child: SizedBox(
        height: 30,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
          itemCount: _widths.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => Container(
            width: _widths[i],
            height: 30,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceRangeSkeleton extends StatelessWidget {
  const _PriceRangeSkeleton();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEF0F5);

    return Shimmer(
      duration: const Duration(milliseconds: 1400),
      interval: const Duration(milliseconds: 350),
      color: dark ? Colors.white : Theme.of(context).primaryColor,
      colorOpacity: dark ? 0.16 : 0.3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 9),
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Thin section divider ──────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xl),
      child: Divider(
          height: 1,
          thickness: 1,
          color: AppColors.divider(context).withValues(alpha: 0.6)),
    );
  }
}

// ─── Section wrapper (flat, no card) ───────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  // أيقونة صغيرة داخل شارة مصبوغة بلون التطبيق تسبق عنوان القسم — تمنح كل
  // قسم هوية بصرية سريعة التمييز (نوع العرض/العقار/السعر/المزود/الترتيب)
  // بدل نص عنوان مجرّد فقط.
  final IconData? icon;
  final String? subtitle;
  final Widget child;
  // true لعناصر تُعرض كقائمة أفقية قابلة للتمرير (نوع العقار/الفرز/مزود
  // الخدمة) — يبقى العنوان بنفس هامش 20 كبقية الأقسام، بينما تمتد القائمة
  // نفسها حتى حافة الورقة فتُدير حشوتها الداخلية بنفسها (20 من البداية فقط)
  // ليطابق أول عنصر ظاهر حافة العنوان تمامًا، وتترك بقية العناصر "تُلمح"
  // (peek) عند الحافة المقابلة مطابقةً للتطبيق المرجعي، بدل أن تُحصر القائمة
  // بهامش 20 مكرر من الخارج والداخل معًا فتبتعد عن محاذاة العنوان.
  final bool bleedChild;

  const _Section({
    required this.title,
    this.icon,
    this.subtitle,
    required this.child,
    this.bleedChild = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.small),
                  ),
                  child: Icon(icon, size: 14, color: AppColors.primary(context)),
                ),
                const SizedBox(width: Spacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.smallBold.copyWith(
                          fontSize: 15.5, color: AppColors.textPrimary(context)),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary(context)),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md + 2),
        bleedChild
            ? child
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: child,
              ),
      ],
    );
  }
}

// ─── Segmented row: تعبئة لونية ناعمة (Soft Tint) + نص بلون التطبيق عند
// التحديد — بدل التعبئة الصلبة السابقة — مطابقةً لنمط المرجع بالضبط (رقاقة
// "للايجار" المختارة هناك بخلفية خضراء فاتحة ونص أخضر، لا تعبئة صلبة بيضاء) ─

class _SegmentedRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Color primary;
  final ValueChanged<String> onSelect;

  const _SegmentedRow({
    required this.options,
    required this.selected,
    required this.primary,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: opt != options.last ? Spacing.sm + 2 : 0),
            child: Material(
              color: isSelected
                  ? primary.withValues(alpha: dark ? 0.2 : 0.1)
                  : AppColors.surface(context),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: InkWell(
                onTap: () => onSelect(opt),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                child: AnimatedContainer(
                  duration: AnimSpec.card,
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.medium),
                    border: Border.all(
                      color: isSelected ? primary : AppColors.border(context),
                      width: isSelected ? 1.3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: (isSelected ? AppTypography.smallBold : AppTypography.smallMedium)
                          .copyWith(
                        fontSize: 12.5,
                        color: isSelected ? primary : AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Chip Row: قائمة أفقية قابلة للتمرير من رقائق بيضاوية الشكل (Stadium)
// بتعبئة لونية ناعمة عند التحديد — تحل محل الشبكة المتعددة الأسطر (Wrap)
// السابقة، مطابقةً لنمط "غرف النوم"/"التأثيث" في التطبيق المرجعي حيث كل
// مجموعة خيارات (فرز/نطاق البحث) تظهر كصف أفقي واحد بدل أسطر متكدّسة ───────

class _ChipRow extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final Color primary;
  final ValueChanged<String> onTap;

  const _ChipRow({
    required this.options,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ScrollConfiguration(
        behavior: const _NoGlowBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(start: Spacing.lg, end: Spacing.lg),
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm + 2),
          itemBuilder: (context, i) {
            final opt = options[i];
            final isSelected = selected.contains(opt);
            return Material(
              color: isSelected ? primary.withValues(alpha: 0.1) : AppColors.background(context),
              borderRadius: BorderRadius.circular(ChipSpec.radius + 4),
              child: InkWell(
                onTap: () => onTap(opt),
                borderRadius: BorderRadius.circular(ChipSpec.radius + 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: 9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ChipSpec.radius + 4),
                    border: Border.all(
                      color: isSelected ? primary : AppColors.border(context),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: (isSelected ? AppTypography.smallBold : AppTypography.smallMedium)
                          .copyWith(
                        fontSize: 12.5,
                        color: isSelected ? primary : AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Category (نوع العقار) — قائمة أفقية قابلة للتمرير بنفس بطاقة/قياسات
// صفّي "نوع الخدمة"/"المنطقة" (_TypeOptionCard) بالضبط، مع "لمحة" (peek) لبطاقة
// جزئية عند الحافة المقابلة — مطابقةً حرفيًا لقسم "نوع العقار" في التطبيق
// المرجعي بدل الشبكة ذات الأربعة أعمدة السابقة ─────────────────────────────

class _CategoryList extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _CategoryList({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final categories = controller.filtersData!.categories!;
    final cardWidth = MediaQuery.of(context).size.width / 3.8;

    return SizedBox(
      height: 118,
      child: ScrollConfiguration(
        behavior: const _NoGlowBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(start: Spacing.lg, end: Spacing.lg),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm + 2),
          itemBuilder: (context, i) {
            final cat = categories[i];
            final label = cat.nameAr ?? cat.name ?? '';
            final isSelected = controller.selectedCategories.contains(cat.id);
            return TypeOptionCard(
              icon: serviceCategoryIcon(label),
              label: label,
              isSelected: isSelected,
              primary: primary,
              width: cardWidth,
              onTap: () {
                if (cat.id != null) controller.toggleCategory(cat.id!);
              },
            );
          },
        ),
      ),
    );
  }
}

// ─── قسم "نطاق السعر": RangeSlider (Flutter الأصلي) بين حدود filtersData —
// حقل جديد كليًا، الباكند يدعمه فعلاً (min_price/max_price) دون أي تعديل ──

class _PriceRangeSection extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _PriceRangeSection({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final bounds = controller.filtersData;
    final floor = bounds?.minPrice ?? 0;
    final ceiling = (bounds?.maxPrice ?? 0) > floor ? bounds!.maxPrice! : floor + 1;

    final currentMin = (controller.minPriceFilter ?? floor).clamp(floor, ceiling);
    final currentMax = (controller.maxPriceFilter ?? ceiling).clamp(floor, ceiling);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3,
            rangeThumbShape:
                const RoundRangeSliderThumbShape(enabledThumbRadius: 9),
            overlayShape: SliderComponentShape.noOverlay,
          ),
          child: RangeSlider(
            min: floor,
            max: ceiling,
            activeColor: primary,
            inactiveColor: AppColors.divider(context),
            values: RangeValues(currentMin, currentMax),
            labels: RangeLabels(
              currentMin.toStringAsFixed(0),
              currentMax.toStringAsFixed(0),
            ),
            onChanged: (values) =>
                controller.setPriceRange(values.start, values.end),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _PriceBox(label: 'min_price'.tr, value: currentMin),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm + 2),
              child: Text('to_label'.tr,
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary(context))),
            ),
            Expanded(
              child: _PriceBox(label: 'max_price'.tr, value: currentMax),
            ),
          ],
        ),
      ],
    );
  }
}

class _PriceBox extends StatelessWidget {
  final String label;
  final double value;

  const _PriceBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(AppRadius.medium - 1),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.caption
                .copyWith(fontSize: 10.5, color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 3),
          // ترتيب صريح (رقم ثم "ر.س") بدل دمجهما في نص واحد — يمنع خوارزمية
          // Bidi من إعادة ترتيب الرقم والعملة عندما يحيط بهما سياق عربي RTL.
          Row(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.ltr,
            children: [
              Text(
                value.toStringAsFixed(0),
                style: AppTypography.smallBold
                    .copyWith(fontSize: 13, color: AppColors.textPrimary(context)),
              ),
              const SizedBox(width: 3),
              Text(
                'ر.س',
                style: AppTypography.smallBold
                    .copyWith(fontSize: 13, color: AppColors.textPrimary(context)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── قوالب الحوارات المصغّرة: كل رقاقة في الشريط العلوي (الفرز/السعر/المنطقة/
// النوع) تفتح ديالوقها الخاص المستقل بدل الورقة الشاملة، مطابقةً لتطبيق
// العقارات المرجعي حيث لكل فلتر نافذته المصغّرة، بينما ورقة الفلاتر الكاملة
// (FilterBottomSheet) تبقى متاحة عبر زر Sliders للفلترة الشاملة ─────────────

class _MiniFilterSheet extends StatefulWidget {
  final String title;
  final IconData icon;
  // Builder بدل Widget جاهز: يمنح المحتوى وصولاً إلى نفس ScrollController
  // الخاص بالورقة، حتى تتحرّك عناصر القوائم/الشبكات بداخله مع التمرير
  // (ScrollRevealItem) بدل بقائها ثابتة كلاسيكيًا.
  final Widget Function(BuildContext context, ScrollController scrollController)
      childBuilder;
  final VoidCallback onApply;
  final String applyLabel;
  final VoidCallback? onReset;

  const _MiniFilterSheet({
    required this.title,
    required this.icon,
    required this.childBuilder,
    required this.onApply,
    this.applyLabel = 'بحث',
    this.onReset,
  });

  @override
  State<_MiniFilterSheet> createState() => _MiniFilterSheetState();
}

class _MiniFilterSheetState extends State<_MiniFilterSheet>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void initState() {
    super.initState();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  // يشغّل حركة الاختفاء (تلاشي + انزلاق للأسفل) قبل إغلاق الورقة فعليًا، بدل
  // اختفائها الفجائي عند الضغط على زر التطبيق — تُستكمل الحركة أولاً ثم يُنفَّذ
  // الإغلاق والاستدعاء الفعلي (getServicesList) بعده مباشرة.
  Future<void> _applyAndClose() async {
    await _entranceController.reverse();
    if (!mounted) return;
    Get.back();
    widget.onApply();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  children: [
                    if (widget.onReset != null)
                      GestureDetector(
                        onTap: widget.onReset,
                        child: Text(
                          'إعادة ضبط',
                          style: robotoBold.copyWith(fontSize: 13, color: primary),
                        ),
                      ),
                    const Spacer(),
                    Text(
                      widget.title,
                      style: robotoBold.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : const Color(0xFF1A2340)),
                    ),
                    const SizedBox(width: 8),
                    Icon(widget.icon, color: primary, size: 20),
                  ],
                ),
              ),
              Divider(height: 1, color: Theme.of(context).dividerColor),
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  child: widget.childBuilder(context, _scrollController),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                    20, 10, 20, 14 + MediaQuery.of(context).padding.bottom),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _applyAndClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      widget.applyLabel,
                      style: robotoBold.copyWith(fontSize: 14.5, color: Colors.white),
                    ),
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

/// حوار "الترتيب": قائمة راديو لخيار فرز واحد، مطابقة لنمط المرجع.
class SortFilterSheet extends StatelessWidget {
  const SortFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicesController>(
      builder: (controller) {
        return _MiniFilterSheet(
          title: 'الترتيب',
          icon: Icons.sort_rounded,
          applyLabel: 'تطبيق',
          onApply: () {
            controller.getServicesList(1, reload: true);
          },
          childBuilder: (context, scrollController) => Column(
            mainAxisSize: MainAxisSize.min,
            children: ServicesController.sortOptions.map((opt) {
              final selected = controller.sortBy == opt;
              return ScrollRevealItem(
                scrollController: scrollController,
                child: RadioListTile<String>(
                  value: opt,
                  groupValue: controller.sortBy,
                  onChanged: (_) => opt == 'الأقرب مني'
                      ? controller.enableNearMe()
                      : controller.setSortBy(opt),
                  activeColor: Theme.of(context).primaryColor,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    opt,
                    style: (selected ? robotoBold : robotoMedium)
                        .copyWith(fontSize: 14),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

/// حوار "نطاق السعر": يعيد استخدام _PriceRangeSection كما هي.
class PriceFilterSheet extends StatelessWidget {
  const PriceFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return GetBuilder<ServicesController>(
      builder: (controller) {
        return _MiniFilterSheet(
          title: 'نطاق السعر',
          icon: Icons.sell_outlined,
          applyLabel: 'تطبيق',
          onReset: () {
            controller.minPriceFilter = null;
            controller.maxPriceFilter = null;
            controller.update();
          },
          onApply: () {
            controller.getServicesList(1, reload: true);
          },
          childBuilder: (context, scrollController) =>
              controller.filtersData == null
                  ? const _PriceRangeSkeleton()
                  : _PriceRangeSection(controller: controller, primary: primary),
        );
      },
    );
  }
}

/// حوار "الموقع": رأس بعنوان+أيقونة يمينًا وزر "إعادة ضبط" يسارًا (بلا زر
/// إغلاق)، صف مناطق أفقي قابل للتمرير (peek عند الحافة)، وزر "بحث" وحيد
/// بعرض كامل — مع الإبقاء على ميزتَي "استخدم موقعي الحالي" وحقل البحث اليدوي
/// الخاصّتين بالموقع فقط، فوق الصف الأفقي.
class ZoneFilterSheet extends StatefulWidget {
  const ZoneFilterSheet({super.key});

  @override
  State<ZoneFilterSheet> createState() => _ZoneFilterSheetState();
}

class _ZoneFilterSheetState extends State<ZoneFilterSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<double> _fade =
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.06),
    end: Offset.zero,
  ).animate(_fade);

  @override
  void initState() {
    super.initState();
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _applyAndClose(ServicesController controller) async {
    await _entranceController.reverse();
    if (!mounted) return;
    Get.back();
    controller.getServicesList(1, reload: true);
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return GetBuilder<ServicesController>(
      builder: (controller) {
        final loading = controller.filtersData == null;
        final zones = controller.filtersData?.zones ?? [];
        final hasSelection =
            controller.selectedZones.isNotEmpty || controller.nearMeActive;

        return FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.82,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _header(context, primary, dark, hasSelection, controller),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _nearMeButton(context, primary, controller),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                  child: Divider(
                                      height: 1, color: Theme.of(context).dividerColor)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text('أو اختر يدويًا',
                                    style: robotoRegular.copyWith(
                                        fontSize: 11.5, color: Colors.grey.shade500)),
                              ),
                              Expanded(
                                  child: Divider(
                                      height: 1, color: Theme.of(context).dividerColor)),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 126,
                            child: loading
                                ? const _HorizontalCardSkeleton(count: 6)
                                : zones.isEmpty
                                    ? _emptyState(context)
                                    : _list(context, controller, primary, zones),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _footer(context, primary, controller),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context, Color primary, bool dark,
      bool hasSelection, ServicesController controller) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'الموقع',
                    style: robotoBold.copyWith(
                        fontSize: 17,
                        color: dark ? Colors.white : const Color(0xFF1A2340)),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: hasSelection
                    ? () {
                        controller.selectedZones.clear();
                        if (controller.nearMeActive) controller.disableNearMe();
                        controller.update();
                      }
                    : null,
                child: Text(
                  'إعادة ضبط',
                  style: robotoBold.copyWith(
                    fontSize: 13.5,
                    color: hasSelection ? primary : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _nearMeButton(
      BuildContext context, Color primary, ServicesController c) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: c.nearMeActive
          ? primary.withValues(alpha: dark ? 0.16 : 0.08)
          : Theme.of(context).scaffoldBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: c.isResolvingLocation
            ? null
            : () => c.nearMeActive ? c.disableNearMe() : c.enableNearMe(),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: c.nearMeActive ? primary : Theme.of(context).dividerColor,
              width: c.nearMeActive ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  c.nearMeActive ? Icons.near_me_rounded : Icons.near_me_outlined,
                  key: ValueKey(c.nearMeActive),
                  size: 18,
                  color: c.nearMeActive ? primary : Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'استخدم موقعي الحالي تلقائيًا',
                  style: (c.nearMeActive ? robotoBold : robotoMedium).copyWith(
                    fontSize: 13,
                    color: c.nearMeActive
                        ? primary
                        : (dark ? Colors.white : const Color(0xFF1A2340)),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim, child: ScaleTransition(scale: anim, child: child)),
                child: c.isResolvingLocation
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2.2, color: primary),
                      )
                    : c.nearMeActive
                        ? Icon(Icons.check_circle_rounded,
                            key: const ValueKey('checked'), size: 20, color: primary)
                        : const SizedBox(key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // قائمة أفقية قابلة للتمرير بنفس قياسات صف "نوع الخدمة" بالضبط (peek عند
  // الحافة) — تُستخدم نفس بطاقة _TypeOptionCard، لكن بأيقونة "خارطة مصغّرة"
  // (_ZoneMapIcon) بدل دبّوس الموقع المسطّح، ليقرأها المستخدم كتمثيل بصري
  // للمنطقة نفسها لا كأيقونة عامة مكرّرة في كل بطاقة.
  Widget _list(BuildContext context, ServicesController controller,
      Color primary, List<ZoneData> zones) {
    final cardWidth = MediaQuery.of(context).size.width / 3.8;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
      itemCount: zones.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, i) {
        final zone = zones[i];
        final isSelected = controller.selectedZones.contains(zone.id);
        return TypeOptionCard(
          icon: Icons.location_on_rounded,
          label: zone.nameAr ?? zone.name ?? '',
          isSelected: isSelected,
          primary: primary,
          width: cardWidth,
          leadingBuilder: (selected) =>
              ZoneMapIcon(isSelected: selected, primary: primary),
          onTap: () {
            if (zone.id != null) controller.toggleZone(zone.id!);
          },
        );
      },
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded, size: 30, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'لا توجد مناطق متاحة',
            style: robotoMedium.copyWith(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _footer(
      BuildContext context, Color primary, ServicesController controller) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _applyAndClose(controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(
            'بحث',
            style: robotoBold.copyWith(fontSize: 15, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// ─── هيكل تحميل بحركة shimmer حقيقية (لمعة تمسح البطاقات قطريًا) بدل النبض
// البسيط بالشفافية — بنفس شكل الصف الأفقي الفعلي (نوع الخدمة/الموقع كلاهما)
// كي لا تقفز الأبعاد لحظة وصول البيانات ───────────────────────────────────

class _HorizontalCardSkeleton extends StatelessWidget {
  final int count;

  const _HorizontalCardSkeleton({this.count = 6});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEF0F5);
    final cardWidth = MediaQuery.of(context).size.width / 3.8;

    return Shimmer(
      duration: const Duration(milliseconds: 1400),
      interval: const Duration(milliseconds: 350),
      color: dark ? Colors.white : Theme.of(context).primaryColor,
      colorOpacity: dark ? 0.16 : 0.3,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.only(start: Spacing.lg, end: Spacing.lg),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm + 2),
        itemBuilder: (context, i) {
          return Container(
            width: cardWidth,
            height: 118,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(AppRadius.large),
            ),
          );
        },
      ),
    );
  }
}

// ─── Provider chips ───────────────────────────────────────────────────────────

class _ProviderChips extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _ProviderChips({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final providers = controller.filtersData!.providers!;
    return SizedBox(
      height: 40,
      child: ScrollConfiguration(
        behavior: const _NoGlowBehavior(),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsetsDirectional.only(start: Spacing.lg, end: Spacing.lg),
          itemCount: providers.length,
          separatorBuilder: (_, __) => const SizedBox(width: Spacing.sm + 2),
          itemBuilder: (context, i) {
            final p = providers[i];
            final isSelected = controller.selectedProviders.contains(p.id);
            return Material(
              color: isSelected ? primary.withValues(alpha: 0.1) : AppColors.background(context),
              borderRadius: BorderRadius.circular(ChipSpec.radius + 4),
              child: InkWell(
                onTap: () {
                  if (p.id != null) controller.toggleProvider(p.id!);
                },
                borderRadius: BorderRadius.circular(ChipSpec.radius + 4),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ChipSpec.radius + 4),
                    border: Border.all(
                      color: isSelected ? primary : AppColors.border(context),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  // الرمز (Avatar) دائمًا أول عنصر في الصف — في سياق RTL هذا
                  // يضعه تلقائيًا على جهة البداية (اليمين)، مطابقةً لبقية
                  // الرقائق ذات الأيقونة القيادية في هذه الورقة.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 11,
                        backgroundColor: isSelected
                            ? primary.withValues(alpha: 0.2)
                            : Colors.grey.shade200,
                        backgroundImage: (p.image != null && p.image!.isNotEmpty)
                            ? NetworkImage(p.image!)
                            : null,
                        child: (p.image == null || p.image!.isEmpty)
                            ? Icon(Icons.storefront_rounded,
                                size: 11,
                                color: isSelected ? primary : Colors.grey.shade500)
                            : null,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        p.name ?? '',
                        style:
                            (isSelected ? AppTypography.smallBold : AppTypography.smallMedium)
                                .copyWith(
                          fontSize: 12,
                          color: isSelected ? primary : AppColors.textSecondary(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
