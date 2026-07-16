import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/services/view/screens/services_catalog_screen.dart'
    show serviceCategoryIcon;
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/scroll_reveal_item.dart';
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
    final primary = Theme.of(context).primaryColor;

    return GetBuilder<ServicesController>(
      builder: (controller) {
        final activeCount = _activeCount(controller);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, primary, activeCount),

              // ─── Scrollable content ────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نوع العرض — تعبئة صلبة بارزة للمُختار (مطابقة للمرجع)
                      _Section(
                        title: 'offer_type'.tr,
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
                      // مباشرة. أما "نوع الخدمة" فله زر مخصّص خاص به أيضًا
                      // (TypeFilterSheet)، لكن "نوع العقار" بقي هنا في
                      // الفلاتر المتقدمة — مطابقةً لموضعه في التطبيق المرجعي.

                      // نوع العقار — بانتظار وصول filtersData يُعرض هيكل تحميل
                      // بنفس أبعاد الشبكة الفعلية بدل اختفاء القسم بالكامل، كي
                      // لا تقفز الأبعاد ولا يبدو القسم كأنه غير موجود أصلًا.
                      if (controller.filtersData == null) ...[
                        _Section(
                          title: 'property_type'.tr,
                          child: const _WrapGridSkeleton(count: 4),
                        ),
                        const _Divider(),
                      ] else if ((controller.filtersData?.categories ?? [])
                          .isNotEmpty) ...[
                        _Section(
                          title: 'property_type'.tr,
                          child: _CategoryGrid(
                            controller: controller,
                            primary: primary,
                            scrollController: _scrollController,
                          ),
                        ),
                        const _Divider(),
                      ],

                      // نطاق السعر
                      _Section(
                        title: 'نطاق السعر',
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
                          child: const _ChipRowSkeleton(),
                        ),
                        const _Divider(),
                      ] else if ((controller.filtersData?.providers ?? [])
                          .isNotEmpty) ...[
                        _Section(
                          title: 'service_provider'.tr,
                          child: _ProviderChips(
                            controller: controller,
                            primary: primary,
                            scrollController: _scrollController,
                          ),
                        ),
                        const _Divider(),
                      ],

                      // الترتيب (فرز + الأقرب مني)
                      _Section(
                        title: 'sort_by'.tr,
                        child: _ChipGrid(
                          options: ServicesController.sortOptions,
                          selected: {controller.sortBy},
                          primary: primary,
                          scrollController: _scrollController,
                          onTap: (v) => v == 'الأقرب مني'
                              ? controller.enableNearMe()
                              : controller.setSortBy(v),
                        ),
                      ),

                      // نطاق البحث (يظهر فقط عند تفعيل "الأقرب مني")
                      if (controller.nearMeActive) ...[
                        const _Divider(),
                        _Section(
                          title: 'نطاق البحث',
                          child: _ChipGrid(
                            options: ServicesController.radiusOptions
                                .map((r) => r['label']!)
                                .toList(),
                            selected: {
                              ServicesController.radiusOptions.firstWhere(
                                (r) => r['value'] == controller.radiusOption,
                              )['label']!
                            },
                            primary: primary,
                            scrollController: _scrollController,
                            onTap: (label) {
                              final value = ServicesController.radiusOptions
                                  .firstWhere((r) => r['label'] == label)['value']!;
                              controller.setRadiusOption(value);
                            },
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),
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
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1)),
      ),
      child: Column(
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
            padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        color: Colors.grey.shade600, size: 20),
                  ),
                ),
                const Spacer(),
                Text(
                  'filter_services'.tr,
                  style: robotoBold.copyWith(
                      fontSize: 17,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1A2340)),
                ),
                if (activeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$activeCount',
                      style: robotoBold.copyWith(
                          color: Colors.white, fontSize: 11),
                    ),
                  ),
                ],
                const Spacer(),
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
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => controller.clearFilters(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade300, width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'إعادة تعيين الحقول',
                style: robotoBold.copyWith(fontSize: 13.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.applyFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                activeCount > 0
                    ? '${'apply_filters'.tr} ($activeCount)'
                    : 'apply_filters'.tr,
                style: robotoBold.copyWith(fontSize: 14.5, color: Colors.white),
              ),
            ),
          ),
        ],
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

// ─── هياكل تحميل بنفس أبعاد كل قسم من أقسام الفلاتر المتقدمة (نوع العقار/
// نطاق السعر/مزود الخدمة) — تحل محل مؤشر دوّار عام واحد يظهر وسط الورقة
// بينما الأقسام نفسها تختفي بصمت، فلا تقفز الأبعاد لحظة وصول filtersData
// ولا تبدو الورقة فارغة بلا تفسير أثناء الانتظار ───────────────────────────

class _WrapGridSkeleton extends StatelessWidget {
  final int count;

  const _WrapGridSkeleton({this.count = 4});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        dark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFEEF0F5);
    final cardWidth = (MediaQuery.of(context).size.width - 40 - 30) / 4;

    return Shimmer(
      duration: const Duration(milliseconds: 1400),
      interval: const Duration(milliseconds: 350),
      color: dark ? Colors.white : Theme.of(context).primaryColor,
      colorOpacity: dark ? 0.16 : 0.3,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: List.generate(count, (i) {
          return Container(
            width: cardWidth,
            height: 96,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(16),
            ),
          );
        }),
      ),
    );
  }
}

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
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: _widths.map((w) {
          return Container(
            width: w,
            height: 30,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        }).toList(),
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
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Divider(height: 1, thickness: 1, color: Theme.of(context).dividerColor),
    );
  }
}

// ─── Section wrapper (flat, no card) ───────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _Section({required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: robotoBold.copyWith(
                fontSize: 15.5,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF1A2340)),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: robotoRegular.copyWith(
                  fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
          const SizedBox(height: 12),
          child,
        ],
      ),
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
            padding: EdgeInsets.only(left: opt != options.last ? 10 : 0),
            child: Material(
              color: isSelected
                  ? primary.withValues(alpha: dark ? 0.2 : 0.1)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(13),
              child: InkWell(
                onTap: () => onSelect(opt),
                borderRadius: BorderRadius.circular(13),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: isSelected ? primary : Theme.of(context).dividerColor,
                      width: isSelected ? 1.3 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      opt,
                      style: (isSelected ? robotoBold : robotoMedium).copyWith(
                        fontSize: 12.5,
                        color: isSelected ? primary : Colors.grey.shade700,
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

// ─── Chip Grid (multi-select, soft-tint) ───────────────────────────────────────

class _ChipGrid extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final Color primary;
  final ValueChanged<String> onTap;
  final ScrollController scrollController;

  const _ChipGrid({
    required this.options,
    required this.selected,
    required this.primary,
    required this.onTap,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return ScrollRevealItem(
          scrollController: scrollController,
          child: Material(
            color: isSelected ? primary.withValues(alpha: 0.08) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: () => onTap(opt),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? primary : Theme.of(context).dividerColor,
                    width: isSelected ? 1.4 : 1,
                  ),
                ),
                child: Text(
                  opt,
                  style: (isSelected ? robotoBold : robotoMedium).copyWith(
                    fontSize: 12,
                    color: isSelected ? primary : Colors.grey.shade700,
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

// ─── بطاقة خيار موحّدة (أيقونة داخل دائرة + نص) تُستخدم في كل شبكات الاختيار
// (نوع الخدمة/نوع العقار/المنطقة) — قالب واحد بأبعاد أكبر وأوضح مطابقةً
// لحجم البطاقات في التطبيق المرجعي بدل الأيقونات الصغيرة المزدحمة سابقًا ───

class _OptionGridCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color primary;
  final double width;
  final VoidCallback onTap;

  const _OptionGridCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // نص/أيقونة الحالة غير المختارة بلون داكن واضح (نفس لون عناوين الورقة)
    // بدل الرمادي الباهت السابق الذي كان يكاد يندمج مع خلفية الورقة البيضاء.
    final unselectedInk =
        dark ? Colors.white.withValues(alpha: 0.82) : const Color(0xFF1A2340);
    return SizedBox(
      width: width,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            constraints: const BoxConstraints(minHeight: 96),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            decoration: BoxDecoration(
              // خلفية مغايرة لخلفية الورقة (البيضاء) حتى تُرى حدود البطاقة
              // فعليًا، لا لونًا شفافًا يندمج بها.
              color: isSelected
                  ? primary.withValues(alpha: dark ? 0.2 : 0.1)
                  : Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? primary
                    : (dark ? Theme.of(context).dividerColor : Colors.grey.shade300),
                width: isSelected ? 1.6 : 1,
              ),
              boxShadow: !isSelected && !dark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  scale: isSelected ? 1.06 : 1.0,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? primary.withValues(alpha: dark ? 0.28 : 0.16)
                          : Theme.of(context).cardColor,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected ? primary : unselectedInk,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: (isSelected ? robotoBold : robotoMedium).copyWith(
                    fontSize: 11.5,
                    height: 1.2,
                    color: isSelected ? primary : unselectedInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Category (نوع العقار) icon grid — نفس نمط _ServiceTypeGrid ──────────────

class _CategoryGrid extends StatelessWidget {
  final ServicesController controller;
  final Color primary;
  final ScrollController scrollController;

  const _CategoryGrid({
    required this.controller,
    required this.primary,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final categories = controller.filtersData!.categories!;
    final cardWidth = (MediaQuery.of(context).size.width - 40 - 30) / 4;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: categories.map((cat) {
        final label = cat.nameAr ?? cat.name ?? '';
        final isSelected = controller.selectedCategories.contains(cat.id);
        return ScrollRevealItem(
          scrollController: scrollController,
          child: _OptionGridCard(
            icon: serviceCategoryIcon(label),
            label: label,
            isSelected: isSelected,
            primary: primary,
            width: cardWidth,
            onTap: () {
              if (cat.id != null) controller.toggleCategory(cat.id!);
            },
          ),
        );
      }).toList(),
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
            inactiveColor: Theme.of(context).dividerColor,
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
              child: _PriceBox(label: 'أقل سعر', value: currentMin),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text('إلى',
                  style: robotoRegular.copyWith(
                      fontSize: 12, color: Colors.grey.shade500)),
            ),
            Expanded(
              child: _PriceBox(label: 'أعلى سعر', value: currentMax),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: robotoRegular.copyWith(fontSize: 10.5, color: Colors.grey.shade500),
          ),
          const SizedBox(height: 2),
          Text(
            '${value.toStringAsFixed(0)} ر.س',
            style: robotoBold.copyWith(fontSize: 13),
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

/// حوار "الموقع": نفس بنية TypeFilterSheet تمامًا — رأس بعنوان+أيقونة يمينًا
/// وزر "إعادة ضبط" يسارًا (بلا زر إغلاق)، صف مناطق أفقي قابل للتمرير بنفس
/// قياسات صف نوع الخدمة (peek عند الحافة)، وزر "بحث" وحيد بعرض كامل —
/// مع الإبقاء على ميزتَي "استخدم موقعي الحالي" وحقل البحث اليدوي الخاصّتين
/// بالموقع فقط، فوق الصف الأفقي.
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
                            height: 106,
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
    final cardWidth = MediaQuery.of(context).size.width / 4.35;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
      itemCount: zones.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, i) {
        final zone = zones[i];
        final isSelected = controller.selectedZones.contains(zone.id);
        return _TypeOptionCard(
          icon: Icons.location_on_rounded,
          label: zone.nameAr ?? zone.name ?? '',
          isSelected: isSelected,
          primary: primary,
          width: cardWidth,
          leadingBuilder: (selected) =>
              _ZoneMapIcon(isSelected: selected, primary: primary),
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

/// حوار "نوع الخدمة": ورقة مستقلة بتصميم خاص بها (لا تعتمد على _MiniFilterSheet
/// العام) — رأس بشارة أيقونة وعدّاد تحديد حيّ، حقل بحث فوري عند تعدد الأنواع،
/// بطاقات اختيار بارزة (شارة صح + توهّج ملوّن عند التحديد)، هيكل تحميل بحركة
/// shimmer حقيقية بدل النبض البسيط، وتذييل بزر تطبيق يحمل عدّاد النتائج.
class TypeFilterSheet extends StatefulWidget {
  const TypeFilterSheet({super.key});

  @override
  State<TypeFilterSheet> createState() => _TypeFilterSheetState();
}

class _TypeFilterSheetState extends State<TypeFilterSheet>
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
        final types = controller.filtersData?.serviceTypes ?? [];
        final selectedCount = controller.selectedServiceTypes.length;

        return FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _header(context, primary, dark, selectedCount, controller),
                  SizedBox(
                    height: 106,
                    child: loading
                        ? const _HorizontalCardSkeleton(count: 6)
                        : types.isEmpty
                            ? _emptyState(context)
                            : _list(context, controller, primary, types),
                  ),
                  const SizedBox(height: 8),
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
      int selectedCount, ServicesController controller) {
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
                  Icon(Icons.apps_rounded, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'نوع الخدمة',
                    style: robotoBold.copyWith(
                        fontSize: 17,
                        color: dark ? Colors.white : const Color(0xFF1A2340)),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: selectedCount > 0
                    ? () {
                        controller.selectedServiceTypes.clear();
                        controller.update();
                      }
                    : null,
                child: Text(
                  'إعادة ضبط',
                  style: robotoBold.copyWith(
                    fontSize: 13.5,
                    color: selectedCount > 0 ? primary : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // قائمة أفقية قابلة للتمرير، بلا حشو نهائي — لتترك بطاقة آخر عنصر مقصوصة
  // جزئيًا عند الحافة (peek) كإيحاء بصري بوجود مزيد من العناصر للتمرير،
  // مطابقةً تمامًا لصف "نوع العقار" في التطبيق المرجعي.
  Widget _list(BuildContext context, ServicesController controller,
      Color primary, List<ServiceTypeData> types) {
    final cardWidth = MediaQuery.of(context).size.width / 4.35;
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
      itemCount: types.length,
      separatorBuilder: (_, __) => const SizedBox(width: 10),
      itemBuilder: (context, i) {
        final type = types[i];
        final label = type.name ?? '';
        final isSelected = controller.selectedServiceTypes.contains(type.id);
        return _TypeOptionCard(
          icon: serviceCategoryIcon(label),
          label: label,
          isSelected: isSelected,
          primary: primary,
          width: cardWidth,
          onTap: () {
            if (type.id != null) controller.toggleServiceType(type.id!);
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
            'لا توجد أنواع خدمات متاحة',
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

// ─── بطاقة اختيار نوع الخدمة: تصميم مسطّح (بلا ظلال ولا خلفية دائرية للأيقونة)
// مطابق لنمط بطاقات "نوع العقار" في التطبيق المرجعي — حدّ رمادي فاتح وأيقونة/
// نص رماديان في الحالة غير المحددة، وتعبئة خضراء فاتحة + حدّ وأيقونة ونص
// بلون التطبيق الأساسي عند التحديد ───────────────────────────────────────

class _TypeOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color primary;
  final double width;
  final VoidCallback onTap;
  // بديل اختياري عن الأيقونة المسطّحة الافتراضية (icon) — يُستخدم في بطاقات
  // المناطق لعرض خارطة مصغّرة (_ZoneMapIcon) بدل دبّوس عام.
  final Widget Function(bool isSelected)? leadingBuilder;

  const _TypeOptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.primary,
    required this.width,
    required this.onTap,
    this.leadingBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final unselectedInk = dark ? Colors.white.withValues(alpha: 0.75) : Colors.grey.shade700;

    return SizedBox(
      width: width,
      height: 100,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: dark ? 0.2 : 0.08)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? primary
                    : (dark ? Theme.of(context).dividerColor : Colors.grey.shade300),
                width: isSelected ? 1.4 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                leadingBuilder != null
                    ? leadingBuilder!(isSelected)
                    : Icon(icon, size: 27, color: isSelected ? primary : unselectedInk),
                const SizedBox(height: 8),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: (isSelected ? robotoBold : robotoMedium).copyWith(
                    fontSize: 11.5,
                    height: 1.2,
                    color: isSelected ? primary : unselectedInk,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── أيقونة "خارطة مصغّرة" لبطاقة المنطقة: مربّع مقرّب الحواف برسم تخطيطي
// بسيط (طرق منحنية + كتلتا مبانٍ + دبّوس موقع) بدل دبّوس مسطّح عام — تمنح
// الانطباع البصري بخارطة فعلية لكل منطقة دون الحاجة لجلب صور خرائط حقيقية
// عبر شبكة الإنترنت لكل بطاقة (تكلفة/بطء غير مبرَّرين هنا) ──────────────────

class _ZoneMapIcon extends StatelessWidget {
  final bool isSelected;
  final Color primary;

  const _ZoneMapIcon({required this.isSelected, required this.primary});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = isSelected
        ? primary.withValues(alpha: dark ? 0.24 : 0.13)
        : (dark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100);
    final road = isSelected ? primary.withValues(alpha: 0.6) : Colors.grey.shade400;
    final block = isSelected ? primary.withValues(alpha: 0.3) : Colors.grey.shade300;
    final pin = isSelected ? primary : Colors.grey.shade600;

    return Container(
      width: 42,
      height: 32,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(
        painter: _MiniMapPainter(roadColor: road, blockColor: block, pinColor: pin),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  final Color roadColor;
  final Color blockColor;
  final Color pinColor;

  _MiniMapPainter({
    required this.roadColor,
    required this.blockColor,
    required this.pinColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = roadColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.32)
        ..quadraticBezierTo(
            size.width * 0.5, size.height * 0.05, size.width, size.height * 0.38),
      roadPaint,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.18, 0)
        ..quadraticBezierTo(
            size.width * 0.42, size.height * 0.55, size.width * 0.3, size.height),
      roadPaint,
    );

    final blockPaint = Paint()..color = blockColor;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.06, size.height * 0.58, size.width * 0.22, size.height * 0.24),
        const Radius.circular(1.5),
      ),
      blockPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.64, size.height * 0.12, size.width * 0.26, size.height * 0.22),
        const Radius.circular(1.5),
      ),
      blockPaint,
    );

    final center = Offset(size.width * 0.56, size.height * 0.52);
    canvas.drawCircle(center, size.width * 0.15, Paint()..color = pinColor.withValues(alpha: 0.22));
    canvas.drawCircle(center, size.width * 0.08, Paint()..color = pinColor);
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) =>
      oldDelegate.roadColor != roadColor ||
      oldDelegate.blockColor != blockColor ||
      oldDelegate.pinColor != pinColor;
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
    final cardWidth = MediaQuery.of(context).size.width / 4.35;

    return Shimmer(
      duration: const Duration(milliseconds: 1400),
      interval: const Duration(milliseconds: 350),
      color: dark ? Colors.white : Theme.of(context).primaryColor,
      colorOpacity: dark ? 0.16 : 0.3,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.only(start: 20, end: 20),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          return Container(
            width: cardWidth,
            height: 100,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(14),
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
  final ScrollController scrollController;

  const _ProviderChips({
    required this.controller,
    required this.primary,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final providers = controller.filtersData!.providers!;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: providers.map((p) {
        final isSelected = controller.selectedProviders.contains(p.id);
        return ScrollRevealItem(
          scrollController: scrollController,
          child: Material(
            color: isSelected ? primary.withValues(alpha: 0.08) : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: () {
                if (p.id != null) controller.toggleProvider(p.id!);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primary : Theme.of(context).dividerColor,
                    width: isSelected ? 1.4 : 1,
                  ),
                ),
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
                      style: (isSelected ? robotoBold : robotoMedium).copyWith(
                        fontSize: 12,
                        color: isSelected ? primary : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
