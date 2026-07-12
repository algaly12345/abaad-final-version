import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/services/view/screens/services_catalog_screen.dart'
    show serviceCategoryIcon;
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({super.key});

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
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, primary, activeCount),

              // ─── Scrollable content ────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نوع العرض
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

                      // ترتيب حسب
                      _Section(
                        title: 'sort_by'.tr,
                        child: _ChipGrid(
                          options: ServicesController.sortOptions,
                          selected: {controller.sortBy},
                          primary: primary,
                          onTap: (v) => controller.setSortBy(v),
                        ),
                      ),

                      // نوع الخدمة
                      if ((controller.filtersData?.serviceTypes ?? [])
                          .isNotEmpty) ...[
                        const _Divider(),
                        _Section(
                          title: 'service_type'.tr,
                          subtitle: 'اختر واحدًا أو أكثر لتضييق النتائج',
                          child: _ServiceTypeGrid(
                            controller: controller,
                            primary: primary,
                          ),
                        ),
                      ],

                      // مزود الخدمة
                      if ((controller.filtersData?.providers ?? [])
                          .isNotEmpty) ...[
                        const _Divider(),
                        _Section(
                          title: 'service_provider'.tr,
                          child: _ProviderChips(
                            controller: controller,
                            primary: primary,
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
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(bottom: BorderSide(color: Color(0xFFF0F2F5), width: 1)),
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
                      fontSize: 17, color: const Color(0xFF1A2340)),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F2F5), width: 1)),
      ),
      child: Row(
        children: [
          if (activeCount > 0)
            Expanded(
              flex: 2,
              child: OutlinedButton(
                onPressed: () => controller.clearFilters(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  'إعادة تعيين',
                  style: robotoBold.copyWith(fontSize: 13.5),
                ),
              ),
            ),
          if (activeCount > 0) const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton(
              onPressed: () => controller.applyFilters(),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
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

// ─── Thin section divider ──────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F2F5)),
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
                fontSize: 15.5, color: const Color(0xFF1A2340)),
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

// ─── Segmented row (equal-width, soft-tint selection) ─────────────────────────

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
    return Row(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelect(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(left: opt != options.last ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primary.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? primary : const Color(0xFFE2E6EC),
                  width: isSelected ? 1.6 : 1.2,
                ),
              ),
              child: Center(
                child: Text(
                  opt,
                  style: (isSelected ? robotoBold : robotoMedium).copyWith(
                    fontSize: 13,
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

// ─── Chip Grid (multi-select, soft-tint) ───────────────────────────────────────

class _ChipGrid extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final Color primary;
  final ValueChanged<String> onTap;

  const _ChipGrid({
    required this.options,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onTap(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? primary.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? primary : const Color(0xFFE2E6EC),
                width: isSelected ? 1.6 : 1.2,
              ),
            ),
            child: Text(
              opt,
              style: (isSelected ? robotoBold : robotoMedium).copyWith(
                fontSize: 12.5,
                color: isSelected ? primary : Colors.grey.shade700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─── Service-type icon grid (matches the icon-card look used across the app) ──

class _ServiceTypeGrid extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _ServiceTypeGrid({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final types = controller.filtersData!.serviceTypes!;
    // عرض بطاقة يسمح بسطرين من النص لتفادي قصّ الأسماء الطويلة
    final cardWidth = (MediaQuery.of(context).size.width - 40 - 20) / 3;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((type) {
        final label = type.name ?? '';
        final isSelected = controller.selectedServiceTypes.contains(type.id);
        return SizedBox(
          width: cardWidth,
          child: GestureDetector(
            onTap: () {
              if (type.id != null) controller.toggleServiceType(type.id!);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
              constraints: const BoxConstraints(minHeight: 92),
              decoration: BoxDecoration(
                color:
                    isSelected ? primary.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? primary : const Color(0xFFE2E6EC),
                  width: isSelected ? 1.6 : 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    serviceCategoryIcon(label),
                    color: isSelected ? primary : Colors.grey.shade500,
                    size: 22,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: (isSelected ? robotoBold : robotoMedium).copyWith(
                      fontSize: 11,
                      height: 1.25,
                      color: isSelected ? primary : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: providers.map((p) {
        final isSelected = controller.selectedProviders.contains(p.id);
        return GestureDetector(
          onTap: () {
            if (p.id != null) controller.toggleProvider(p.id!);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? primary.withValues(alpha: 0.08) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? primary : const Color(0xFFE2E6EC),
                width: isSelected ? 1.6 : 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: isSelected
                      ? primary.withValues(alpha: 0.2)
                      : Colors.grey.shade200,
                  backgroundImage: (p.image != null && p.image!.isNotEmpty)
                      ? NetworkImage(p.image!)
                      : null,
                  child: (p.image == null || p.image!.isEmpty)
                      ? Icon(Icons.storefront_rounded,
                          size: 12,
                          color: isSelected ? primary : Colors.grey.shade500)
                      : null,
                ),
                const SizedBox(width: 6),
                Text(
                  p.name ?? '',
                  style: (isSelected ? robotoBold : robotoMedium).copyWith(
                    fontSize: 12.5,
                    color: isSelected ? primary : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
