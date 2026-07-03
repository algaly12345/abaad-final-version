import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return GetBuilder<ServicesController>(
      builder: (controller) {
        final activeCount = _activeCount(controller);

        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF4F6F9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Handle + Header ───────────────────────────────────────
              _buildHeader(context, primary, controller, activeCount),

              // ─── Scrollable content ────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نوع العرض
                      _Section(
                        icon: Icons.local_offer_outlined,
                        title: 'offer_type'.tr,
                        primary: primary,
                        child: _ToggleRow(
                          options: ServicesController.offerTypeOptions,
                          selected: controller.selectedOfferType,
                          primary: primary,
                          onSelect: controller.setOfferType,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ترتيب حسب
                      _Section(
                        icon: Icons.sort_rounded,
                        title: 'sort_by'.tr,
                        primary: primary,
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
                        const SizedBox(height: 16),
                        _Section(
                          icon: Icons.category_outlined,
                          title: 'service_type'.tr,
                          primary: primary,
                          child: _ChipGrid(
                            options: (controller.filtersData!.serviceTypes!)
                                .map((e) => e.name ?? '')
                                .toList(),
                            selected: controller.selectedServiceTypes
                                .map((id) {
                                  final match = controller
                                      .filtersData!.serviceTypes!
                                      .firstWhereOrNull((e) => e.id == id);
                                  return match?.name ?? '';
                                })
                                .where((n) => n.isNotEmpty)
                                .toSet(),
                            primary: primary,
                            onTap: (name) {
                              final type = controller.filtersData!.serviceTypes!
                                  .firstWhereOrNull((e) => e.name == name);
                              if (type?.id != null) {
                                controller.toggleServiceType(type!.id!);
                              }
                            },
                          ),
                        ),
                      ],

                      // مزود الخدمة
                      if ((controller.filtersData?.providers ?? [])
                          .isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _Section(
                          icon: Icons.storefront_outlined,
                          title: 'service_provider'.tr,
                          primary: primary,
                          child: _ProviderChips(
                            controller: controller,
                            primary: primary,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
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

  Widget _buildHeader(BuildContext context, Color primary,
      ServicesController controller, int activeCount) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.tune_rounded, color: primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'filter_services'.tr,
                  style: robotoBold.copyWith(fontSize: 17, color: const Color(0xFF1A2340)),
                ),
                if (activeCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
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
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 10, offset: Offset(0, -3)),
        ],
      ),
      child: Row(
        children: [
          if (activeCount > 0)
            Expanded(
              flex: 2,
              child: OutlinedButton.icon(
                onPressed: () => controller.clearFilters(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text('clear_all'.tr),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          if (activeCount > 0) const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: ElevatedButton.icon(
              onPressed: () => controller.applyFilters(),
              icon: const Icon(Icons.check_rounded, size: 16),
              label: Text(
                activeCount > 0
                    ? '${'apply_filters'.tr} ($activeCount)'
                    : 'apply_filters'.tr,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
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

// ─── Section wrapper ──────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color primary;
  final Widget child;

  const _Section({
    required this.icon,
    required this.title,
    required this.primary,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: robotoMedium.copyWith(
                        fontSize: 14, color: const Color(0xFF1A2340)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Toggle Row (radio style) ─────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final Color primary;
  final ValueChanged<String> onSelect;

  const _ToggleRow({
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
              margin: EdgeInsets.only(
                right: opt != options.last ? 8 : 0,
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : Colors.grey.shade200,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  opt,
                  style: (isSelected ? robotoBold : robotoRegular).copyWith(
                    fontSize: 12,
                    color:
                        isSelected ? Colors.white : Colors.grey.shade700,
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

// ─── Chip Grid (multi-select) ─────────────────────────────────────────────────

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
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onTap(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? primary : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Text(
              opt,
              style: (isSelected ? robotoMedium : robotoRegular).copyWith(
                fontSize: 12,
                color: isSelected ? primary : Colors.grey.shade700,
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

  const _ProviderChips(
      {required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final providers = controller.filtersData!.providers!;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: providers.map((p) {
        final isSelected = controller.selectedProviders.contains(p.id);
        return GestureDetector(
          onTap: () {
            if (p.id != null) controller.toggleProvider(p.id!);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? primary.withValues(alpha: 0.1)
                  : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isSelected ? primary : Colors.grey.shade200,
                width: 1.5,
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
                  child:
                      (p.image == null || p.image!.isEmpty)
                          ? Icon(Icons.storefront_rounded,
                              size: 12,
                              color: isSelected
                                  ? primary
                                  : Colors.grey.shade500)
                          : null,
                ),
                const SizedBox(width: 6),
                Text(
                  p.name ?? '',
                  style: (isSelected ? robotoMedium : robotoRegular)
                      .copyWith(
                    fontSize: 12,
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
