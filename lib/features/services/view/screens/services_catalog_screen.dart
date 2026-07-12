import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/features/services/view/screens/filter_bottom_sheet.dart';
import 'package:abaad_flutter/features/services/view/screens/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesCatalogScreen extends StatefulWidget {
  final bool showAppBar;

  const ServicesCatalogScreen({Key? key, this.showAppBar = true})
      : super(key: key);

  @override
  State<ServicesCatalogScreen> createState() => _ServicesCatalogScreenState();
}

class _ServicesCatalogScreenState extends State<ServicesCatalogScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<ServicesController>();
      c.getServicesList(1, reload: true);
      c.getFilters();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      final c = Get.find<ServicesController>();
      if (!c.isLoading && c.hasMore) {
        c.getServicesList(c.offset + 1);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildBody(Color primary) {
    return GetBuilder<ServicesController>(
      builder: (controller) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                child: Column(
                  children: [
                    AnimatedSize(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut,
                      child: controller.isSearchExpanded
                          ? _ServicesSearchBar(controller: controller)
                          : const SizedBox(width: double.infinity),
                    ),
                    _CategoriesStrip(controller: controller, primary: primary),
                  ],
                ),
              ),
            ),
            if (controller.servicesList == null) ...[
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, __) => const _SkeletonCard(),
                    childCount: 5,
                  ),
                ),
              ),
            ] else if (controller.servicesList!.isEmpty) ...[
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyServices(
                  primary: primary,
                  hasActiveFilters: controller.searchText.isNotEmpty ||
                      controller.selectedCategories.isNotEmpty ||
                      controller.selectedZones.isNotEmpty ||
                      controller.selectedServiceTypes.isNotEmpty ||
                      controller.selectedProviders.isNotEmpty ||
                      controller.selectedOfferType != 'الكل',
                  onReset: controller.clearFilters,
                ),
              ),
            ] else ...[
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, index) {
                      if (index < controller.servicesList!.length) {
                        return _ServiceCard(
                          service: controller.servicesList![index],
                          primary: primary,
                        );
                      }
                      return controller.hasMore
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child:
                                  Center(child: CircularProgressIndicator()),
                            )
                          : const Padding(
                              padding:
                                  EdgeInsets.only(bottom: 20, top: 8),
                              child: Center(
                                child: Text(
                                  'تم عرض جميع الخدمات',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            );
                    },
                    childCount: controller.servicesList!.length + 1,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    // عند التضمين داخل شاشة أخرى، نُرجع المحتوى مباشرة بدون Scaffold
    if (!widget.showAppBar) {
      return ColoredBox(
        color: const Color(0xFFF4F6F9),
        child: _buildBody(primary),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 64,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withValues(alpha: 0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const ServicesAppBarTitle(
          title: 'دليل الخدمات العقارية',
          subtitle: 'أفضل العروض والخصومات الحصرية',
        ),
        actions: const [ServicesAppBarActions()],
      ),
      body: _buildBody(primary),
    );
  }
}

// ─── Icon mapping for categories ──────────────────────────────────────────────

IconData serviceCategoryIcon(String? name) {
  final n = (name ?? '').trim();
  if (n.isEmpty || n == 'الكل') return Icons.apps_rounded;

  // الأكثر تحديدًا أولاً لتفادي التطابق مع كلمات عامة (مثل "شقة صغيرة" قبل "شقة")
  const map = <String, IconData>{
    'شقة صغيرة': Icons.single_bed_rounded,
    'استوديو': Icons.single_bed_rounded,
    'الطاقة الشمسية': Icons.solar_power_rounded,
    'شمسية': Icons.solar_power_rounded,
    'شمسي': Icons.solar_power_rounded,
    'مكافحة الحريق': Icons.local_fire_department_rounded,
    'حريق': Icons.local_fire_department_rounded,
    'مكافحة الحشرات': Icons.pest_control_rounded,
    'مكافحة': Icons.fire_extinguisher_rounded,
    'مصاعد': Icons.elevator_rounded,
    'مصعد': Icons.elevator_rounded,
    'التخزين': Icons.inventory_2_rounded,
    'تخزين': Icons.inventory_2_rounded,
    'الري والزراعة': Icons.water_drop_rounded,
    'الري': Icons.water_drop_rounded,
    'زراع': Icons.agriculture_rounded,
    'ذكية': Icons.sensors_rounded,
    'ذكي': Icons.sensors_rounded,
    'التراخيص': Icons.verified_user_rounded,
    'تراخيص': Icons.verified_user_rounded,
    'تصاريح': Icons.verified_user_rounded,
    'تصريح': Icons.verified_user_rounded,
    'دهانات': Icons.format_paint_rounded,
    'دهان': Icons.format_paint_rounded,
    'تشطيب': Icons.format_paint_rounded,
    'تأثيث': Icons.chair_alt_rounded,
    'إستراحة': Icons.cottage_rounded,
    'استراحة': Icons.cottage_rounded,
    'شاليه': Icons.cabin_rounded,
    'كوخ': Icons.cabin_rounded,
    'قصر': Icons.castle_rounded,
    'ورشة': Icons.handyman_rounded,
    'مستودع': Icons.warehouse_rounded,
    'مصنع': Icons.factory_rounded,
    'معمل': Icons.factory_rounded,
    'برج': Icons.location_city_rounded,
    'مزرعة': Icons.agriculture_rounded,
    'مدرسة': Icons.school_rounded,
    'جامعة': Icons.school_rounded,
    'مستشفى': Icons.local_hospital_rounded,
    'عيادة': Icons.medical_services_rounded,
    'صيدلية': Icons.local_pharmacy_rounded,
    'مسبح': Icons.pool_rounded,
    'قاعة': Icons.celebration_rounded,
    'صالة': Icons.fitness_center_rounded,
    'مغسلة': Icons.local_laundry_service_rounded,
    'موقف': Icons.local_parking_rounded,
    'كراج': Icons.garage_rounded,
    'جراج': Icons.garage_rounded,
    'غرفة': Icons.meeting_room_rounded,
    'دور': Icons.stairs_rounded,
    'أرض': Icons.terrain_rounded,
    'ارض': Icons.terrain_rounded,
    'معرض': Icons.storefront_rounded,
    'محل': Icons.storefront_rounded,
    'مكتب': Icons.business_center_rounded,
    'سينما': Icons.local_movies_rounded,
    'ترفيه': Icons.celebration_rounded,
    'ملعب': Icons.sports_soccer_rounded,
    'عمارة': Icons.apartment_rounded,
    'عقار': Icons.apartment_rounded,
    'مبنى': Icons.apartment_rounded,
    'صراف': Icons.currency_exchange_rounded,
    'بنك': Icons.account_balance_rounded,
    'مالي': Icons.account_balance_wallet_rounded,
    'شقة': Icons.home_rounded,
    'سكن': Icons.home_rounded,
    'فيلا': Icons.villa_rounded,
    'مطعم': Icons.restaurant_rounded,
    'مقهى': Icons.local_cafe_rounded,
    'كافيه': Icons.local_cafe_rounded,
    'صيانة': Icons.build_rounded,
    'نقل': Icons.local_shipping_rounded,
    'عفش': Icons.local_shipping_rounded,
    'تنظيف': Icons.cleaning_services_rounded,
    'أمن': Icons.security_rounded,
    'حراسة': Icons.security_rounded,
    'تصميم': Icons.design_services_rounded,
    'ديكور': Icons.design_services_rounded,
    'كهرباء': Icons.electrical_services_rounded,
    'سباكة': Icons.plumbing_rounded,
    'تكييف': Icons.ac_unit_rounded,
    'حديقة': Icons.grass_rounded,
    'تنسيق': Icons.grass_rounded,
    'مقاولات': Icons.construction_rounded,
    'بناء': Icons.construction_rounded,
    'تأمين': Icons.shield_rounded,
    'تسوق': Icons.shopping_bag_rounded,
    'متجر': Icons.storefront_rounded,
    'صحة': Icons.local_hospital_rounded,
    'طبي': Icons.local_hospital_rounded,
    'تعليم': Icons.school_rounded,
    'رياضة': Icons.fitness_center_rounded,
    'نادي': Icons.fitness_center_rounded,
    'فندق': Icons.hotel_rounded,
    'سياح': Icons.card_travel_rounded,
    'سيار': Icons.directions_car_rounded,
    'تأجير': Icons.car_rental_rounded,
    'قانون': Icons.gavel_rounded,
    'محاما': Icons.gavel_rounded,
    'تصوير': Icons.camera_alt_rounded,
    'انترنت': Icons.wifi_rounded,
    'اتصالات': Icons.wifi_rounded,
  };

  for (final entry in map.entries) {
    if (n.contains(entry.key)) return entry.value;
  }
  return Icons.miscellaneous_services_rounded;
}

// ─── App-bar title ─────────────────────────────────────────────────────────────

int _activeFilterCount(ServicesController controller) {
  int n = 0;
  if (controller.selectedOfferType != 'الكل') n++;
  if (controller.sortBy != 'الأحدث') n++;
  n += controller.selectedCategories.length;
  n += controller.selectedZones.length;
  n += controller.selectedServiceTypes.length;
  n += controller.selectedProviders.length;
  return n;
}

class ServicesAppBarTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const ServicesAppBarTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.local_offer_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
              ),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: robotoRegular.copyWith(
                    fontSize: 10.5, color: Colors.white.withValues(alpha: 0.8)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── App-bar actions: search toggle + filter icon with badge ─────────────────

class ServicesAppBarActions extends StatelessWidget {
  const ServicesAppBarActions({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ServicesController>(
      builder: (controller) {
        final count = _activeFilterCount(controller);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => controller.isSearchExpanded
                  ? controller.closeSearch()
                  : controller.openSearch(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Icon(
                  controller.isSearchExpanded
                      ? Icons.close_rounded
                      : Icons.search_rounded,
                  key: ValueKey(controller.isSearchExpanded),
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => Get.bottomSheet(
                      const FilterBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    ),
                    icon: const Icon(Icons.tune_rounded, color: Colors.white),
                  ),
                  if (count > 0)
                    Positioned(
                      top: 6,
                      right: 4,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.4),
                          ),
                          child: Text(
                            '$count',
                            style: robotoBold.copyWith(
                                color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─── Search bar (revealed under the app bar via the search toggle) ───────────

class _ServicesSearchBar extends StatelessWidget {
  final ServicesController controller;

  const _ServicesSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8ECF0), width: 1.2),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            controller.isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : Icon(Icons.search_rounded,
                    color: Colors.grey.shade500, size: 21),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.searchServices,
                autofocus: true,
                textAlignVertical: TextAlignVertical.center,
                style: robotoMedium.copyWith(
                    fontSize: 14, color: const Color(0xFF1A2340)),
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة أو مزود...',
                  hintStyle: robotoRegular.copyWith(
                      color: Colors.grey.shade400, fontSize: 13.5),
                  filled: false,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller.searchController,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox(width: 14);
                return Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: GestureDetector(
                    onTap: () {
                      controller.searchController.clear();
                      controller.searchServices('');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close_rounded,
                          size: 13, color: Colors.grey.shade600),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Categories strip (compact, sits right under the app bar) ────────────────

class _CategoriesStrip extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _CategoriesStrip({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final hasCategories = (controller.filtersData?.categories ?? []).isNotEmpty;
    if (!hasCategories) return const SizedBox(height: 12);
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
      child: _CategoryChips(controller: controller, primary: primary),
    );
  }
}

// ─── Category chips (icon cards) ──────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _CategoryChips({required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final categories = controller.filtersData!.categories!;

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          if (i == 0) {
            final allSelected = controller.selectedCategories.isEmpty;
            return _CategoryIconChip(
              label: 'الكل',
              icon: Icons.apps_rounded,
              selected: allSelected,
              primary: primary,
              onTap: () {
                controller.selectedCategories.clear();
                controller.getServicesList(1, reload: true);
              },
            );
          }
          final cat = categories[i - 1];
          final isSelected = controller.selectedCategories.contains(cat.id);
          final label = cat.nameAr ?? cat.name ?? '';
          return _CategoryIconChip(
            label: label,
            icon: serviceCategoryIcon(label),
            selected: isSelected,
            primary: primary,
            onTap: () {
              if (cat.id != null) {
                controller.toggleCategory(cat.id!);
                controller.getServicesList(1, reload: true);
              }
            },
          );
        },
      ),
    );
  }
}

class _CategoryIconChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _CategoryIconChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: selected
                    ? LinearGradient(
                        colors: [primary, primary.withValues(alpha: 0.78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: selected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? Colors.transparent : const Color(0xFFE8ECF0),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? primary.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: selected ? 14 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: (selected ? robotoBold : robotoMedium).copyWith(
                fontSize: 11,
                color: selected ? primary : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Service card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceOffer service;
  final Color primary;

  const _ServiceCard({required this.service, required this.primary});

  @override
  Widget build(BuildContext context) {
    final provider = (service.providers?.isNotEmpty ?? false)
        ? service.providers!.first
        : null;
    final isDiscount = service.offerType == 'discount';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F2F5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.to(
            () => ServiceDetailsScreen(serviceId: service.id!),
            transition: Transition.cupertino,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(19)),
                    child: CustomImage(
                      image: service.image ?? '',
                      height: 170,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.45),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDiscount
                              ? [Colors.red.shade600, Colors.red.shade400]
                              : [Colors.green.shade600, Colors.green.shade500],
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.22),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDiscount
                                ? Icons.local_offer_outlined
                                : Icons.payments_outlined,
                            color: Colors.white,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isDiscount
                                ? '${service.discount}%  خصم'
                                : '${service.servicePrice} ر.س',
                            style: robotoBold.copyWith(
                                color: Colors.white, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (service.serviceType?.name != null)
                    Positioned(
                      bottom: 10,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              serviceCategoryIcon(service.serviceType!.name),
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              service.serviceType!.name!,
                              style: robotoMedium.copyWith(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title ?? '',
                      style: robotoBold.copyWith(
                          fontSize: 15, color: const Color(0xFF1A2340)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (service.description != null &&
                        service.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        service.description!,
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          height: 1.45,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primary.withValues(alpha: 0.14),
                                  primary.withValues(alpha: 0.06),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.storefront_outlined,
                                size: 16, color: primary),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider?.name ?? 'مزود خدمة',
                              style: robotoMedium.copyWith(
                                  fontSize: 13, color: primary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 13, color: Colors.grey.shade400),
                        ],
                      ),
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

// ─── Skeleton card ────────────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF0F2F5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 170,
            decoration: const BoxDecoration(
              color: Color(0xFFE8ECF0),
              borderRadius: BorderRadius.vertical(top: Radius.circular(19)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sh(double.infinity, 16),
                const SizedBox(height: 8),
                _sh(220, 12),
                const SizedBox(height: 12),
                Row(children: [
                  _sc(32),
                  const SizedBox(width: 10),
                  _sh(120, 12),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sh(double w, double h) => Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
          color: const Color(0xFFE8ECF0),
          borderRadius: BorderRadius.circular(8)));

  Widget _sc(double s) => Container(
      width: s,
      height: s,
      decoration: const BoxDecoration(
          color: Color(0xFFE8ECF0), shape: BoxShape.circle));
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyServices extends StatelessWidget {
  final Color primary;
  final bool hasActiveFilters;
  final VoidCallback onReset;

  const _EmptyServices({
    required this.primary,
    required this.hasActiveFilters,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: 0.1),
                    primary.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 42, color: primary.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 22),
            Text(
              'لا توجد خدمات متاحة',
              style: robotoBold.copyWith(
                  fontSize: 16, color: const Color(0xFF1A2340)),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب تغيير الفلاتر أو البحث بكلمة مختلفة',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                  fontSize: 13, color: Colors.grey.shade500, height: 1.5),
            ),
            if (hasActiveFilters) ...[
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: onReset,
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  backgroundColor: primary.withValues(alpha: 0.08),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('إعادة تعيين الفلاتر',
                    style: robotoBold.copyWith(fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
