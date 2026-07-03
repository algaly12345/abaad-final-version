import 'package:abaad_flutter/controller/services_controller.dart';
import 'package:abaad_flutter/data/model/response/service_offer_model.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/screen/services/filter_bottom_sheet.dart';
import 'package:abaad_flutter/view/screen/services/service_details_screen.dart';
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
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildBody(Color primary) {
    return GetBuilder<ServicesController>(
      builder: (controller) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _SearchFilterHeader(
                controller: controller,
                searchController: _searchController,
                primary: primary,
              ),
            ),
            if ((controller.filtersData?.categories ?? []).isNotEmpty)
              SliverToBoxAdapter(
                child: _CategoryChips(
                  controller: controller,
                  primary: primary,
                ),
              )
            else
              SliverToBoxAdapter(
                child: Container(
                  color: primary,
                  child: Container(
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4F6F9),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(22)),
                    ),
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
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyServices(),
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
        title: Text(
          'دليل الخدمات العقارية',
          style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
        ),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(primary),
    );
  }
}

// ─── Search + Filter header ───────────────────────────────────────────────────

class _SearchFilterHeader extends StatelessWidget {
  final ServicesController controller;
  final TextEditingController searchController;
  final Color primary;

  const _SearchFilterHeader({
    required this.controller,
    required this.searchController,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: primary,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: searchController,
                onChanged: controller.searchServices,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'ابحث عن خدمة...',
                  hintStyle: robotoRegular.copyWith(
                      color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded,
                      color: Colors.grey.shade400),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon:
                              const Icon(Icons.close, size: 18),
                          color: Colors.grey,
                          onPressed: () {
                            searchController.clear();
                            controller.searchServices('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _FilterButton(controller: controller, primary: primary),
        ],
      ),
    );
  }
}

// ─── Filter button with active-count badge ────────────────────────────────────

class _FilterButton extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _FilterButton({required this.controller, required this.primary});

  int get _activeCount {
    int n = 0;
    if (controller.selectedOfferType != 'الكل') n++;
    if (controller.sortBy != 'الأحدث') n++;
    n += controller.selectedCategories.length;
    n += controller.selectedZones.length;
    n += controller.selectedServiceTypes.length;
    n += controller.selectedProviders.length;
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final count = _activeCount;
    return GestureDetector(
      onTap: () => Get.bottomSheet(
        const FilterBottomSheet(),
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: count > 0 ? Colors.white : Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: count > 0 ? Colors.white : Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              color: count > 0 ? primary : Colors.white,
              size: 22,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -6,
              left: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade600,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '$count',
                  style: robotoBold.copyWith(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Category chips ───────────────────────────────────────────────────────────

class _CategoryChips extends StatelessWidget {
  final ServicesController controller;
  final Color primary;

  const _CategoryChips(
      {required this.controller, required this.primary});

  @override
  Widget build(BuildContext context) {
    final categories = controller.filtersData!.categories!;

    return Container(
      color: primary,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF4F6F9),
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(22)),
        ),
        padding:
            const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
            itemBuilder: (_, i) {
              if (i == 0) {
                final allSelected =
                    controller.selectedCategories.isEmpty;
                return _ChipItem(
                  label: 'الكل',
                  selected: allSelected,
                  primary: primary,
                  onTap: () {
                    controller.selectedCategories.clear();
                    controller.getServicesList(1,
                        reload: true);
                  },
                );
              }
              final cat = categories[i - 1];
              final isSelected = controller.selectedCategories
                  .contains(cat.id);
              return _ChipItem(
                label: cat.nameAr ?? cat.name ?? '',
                selected: isSelected,
                primary: primary,
                onTap: () {
                  if (cat.id != null) {
                    controller.toggleCategory(cat.id!);
                    controller.getServicesList(1,
                        reload: true);
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final Color primary;
  final VoidCallback onTap;

  const _ChipItem({
    required this.label,
    required this.selected,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: selected
                  ? primary.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: 12,
            color: selected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// ─── Service card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceOffer service;
  final Color primary;

  const _ServiceCard(
      {required this.service, required this.primary});

  @override
  Widget build(BuildContext context) {
    final provider = (service.providers?.isNotEmpty ?? false)
        ? service.providers!.first
        : null;
    final isDiscount = service.offerType == 'discount';

    return GestureDetector(
      onTap: () => Get.to(
        () => ServiceDetailsScreen(serviceId: service.id!),
        transition: Transition.cupertino,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                  child: CustomImage(
                    image: service.image ?? '',
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(18)),
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
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDiscount
                          ? Colors.red.shade600
                          : Colors.green.shade600,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withValues(alpha: 0.22),
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
                        color:
                            Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        service.serviceType!.name!,
                        style: robotoMedium.copyWith(
                            color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title ?? '',
                    style: robotoBold.copyWith(
                        fontSize: 15,
                        color: const Color(0xFF1A2340)),
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
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color:
                              primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                            Icons.storefront_outlined,
                            size: 16,
                            color: primary),
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
                          size: 13,
                          color: Colors.grey.shade400),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
              borderRadius: BorderRadius.vertical(
                  top: Radius.circular(18)),
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
  const _EmptyServices();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded,
                size: 44, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            'لا توجد خدمات متاحة',
            style: robotoBold.copyWith(
                fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'جرّب تغيير الفلاتر أو البحث بكلمة مختلفة',
            style: robotoRegular.copyWith(
                fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}
