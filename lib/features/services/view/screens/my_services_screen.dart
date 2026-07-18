import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/provider/controller/provider_permission_controller.dart';
import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:abaad_flutter/features/services/view/screens/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyServicesScreen extends StatefulWidget {
  const MyServicesScreen({super.key});

  @override
  State<MyServicesScreen> createState() => _MyServicesScreenState();
}

class _MyServicesScreenState extends State<MyServicesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Get.find<AuthController>().isLoggedIn()) {
        Get.find<ServicesController>().getServicesList(
          1,
          reload: true,
          myServices: true,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return NotLoggedInScreen();
    }

    // GetBuilder يُعيد بناء الشاشة عند انتهاء loadPermissions()
    return GetBuilder<ProviderPermissionController>(
      builder: (_) => _buildContent(context),
    );
  }

  // ─── الشريط العلوي: نفس بنية شريط "دليل الخدمات" حرفيًا — خلفية cardColor
  // مسطّحة بلا تدرّج/ظل، حدّ سفلي رفيع فقط، وزرّ رجوع دائري بحدّ خفيف ولون
  // Primary (راجع _BackHomeButton في services_catalog_screen.dart) ──────────
  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'my_services'.tr,
                style: robotoBold.copyWith(
                    fontSize: 17, color: AppColors.textPrimary(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── شريط التبويبات: يقع مباشرة أسفل الشريط العلوي بنفس خلفيته الفاتحة
  // (وليس داخل رأس داكن) — مؤشّر سفلي بلون Primary يميّز التبويب المحدَّد،
  // بنفس خط/ألوان بقية الشاشة ────────────────────────────────────────────
  Widget _buildTabBar(BuildContext context, Color primary) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: primary,
        unselectedLabelColor: Colors.grey.shade500,
        labelStyle: robotoBold.copyWith(fontSize: 13),
        unselectedLabelStyle: robotoRegular.copyWith(fontSize: 13),
        indicatorColor: primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        tabs: [
          Tab(text: 'active_status'.tr),
          Tab(text: 'under_review'.tr),
          Tab(text: 'rejected_status'.tr),
          Tab(text: 'expired_status'.tr),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final canCreate =
        Get.find<ProviderPermissionController>().canCreateServices;

    final content = GetBuilder<ServicesController>(
      builder: (controller) {
        if (controller.isMyServicesLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final all = controller.myServicesList ?? [];
        final active = all
            .where((e) => e.status == 'accept' && !(e.isExpired ?? false))
            .toList();
        final pending = all.where((e) => e.status == 'pending').toList();
        final rejected = all.where((e) => e.status == 'rejected').toList();
        final expired = all
            .where(
                (e) => e.status == 'cancelled' || (e.isExpired ?? false))
            .toList();

        return TabBarView(
          controller: _tabController,
          children: [
            _ServicesList(
              services: active,
              primary: primary,
              statusColor: Colors.green.shade600,
              statusLabel: 'active_status'.tr,
              emptyMessage: 'no_active_offers'.tr,
              emptyIcon: Icons.check_circle_outline_rounded,
            ),
            _ServicesList(
              services: pending,
              primary: primary,
              statusColor: Colors.orange.shade600,
              statusLabel: 'under_review'.tr,
              emptyMessage: 'no_pending_offers'.tr,
              emptyIcon: Icons.hourglass_empty_rounded,
            ),
            _ServicesList(
              services: rejected,
              primary: primary,
              statusColor: Colors.red.shade600,
              statusLabel: 'rejected_status'.tr,
              emptyMessage: 'no_rejected_offers'.tr,
              emptyIcon: Icons.block_rounded,
            ),
            _ServicesList(
              services: expired,
              primary: primary,
              statusColor: Colors.grey.shade600,
              statusLabel: 'expired_status'.tr,
              emptyMessage: 'no_expired_offers'.tr,
              emptyIcon: Icons.cancel_outlined,
            ),
          ],
        );
      },
    );

    // زرّ الإضافة العائم — بنفس تنسيق زرّ "إضافة خدمة" في نظام التصميم
    // (services_hub_screen.dart): خلفية Primary، أيقونة + نص أبيض عريض،
    // في أسفل يمين الشاشة (الموضع الافتراضي لـ FloatingActionButton.extended).
    final fab = canCreate
        ? FloatingActionButton.extended(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 4,
            onPressed: () =>
                Get.toNamed(RouteHelper.getAddServiceOfferRoute()),
            icon: const Icon(Icons.add_business),
            label: Text('add_service'.tr,
                style: robotoBold.copyWith(color: Colors.white, fontSize: 13)),
          )
        : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          _buildTopBar(context),
          _buildTabBar(context, primary),
          Expanded(child: content),
        ],
      ),
      floatingActionButton: fab,
    );
  }
}

// ─── Services list ────────────────────────────────────────────────────────────

class _ServicesList extends StatelessWidget {
  final List<ServiceOffer> services;
  final Color primary;
  final Color statusColor;
  final String statusLabel;
  final String emptyMessage;
  final IconData emptyIcon;

  const _ServicesList({
    required this.services,
    required this.primary,
    required this.statusColor,
    required this.statusLabel,
    required this.emptyMessage,
    required this.emptyIcon,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return _EmptyTab(
        icon: emptyIcon,
        message: emptyMessage,
        color: statusColor,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
      itemCount: services.length,
      itemBuilder: (context, index) => _ServiceCard(
        service: services[index],
        primary: primary,
        statusColor: statusColor,
        statusLabel: statusLabel,
      ),
    );
  }
}

// ─── Service card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final ServiceOffer service;
  final Color primary;
  final Color statusColor;
  final String statusLabel;

  const _ServiceCard({
    required this.service,
    required this.primary,
    required this.statusColor,
    required this.statusLabel,
  });

  @override
  Widget build(BuildContext context) {
    final canToggle = service.status != 'cancelled' &&
        service.status != 'rejected' &&
        service.id != null;
    final isActive = service.status == 'accept';

    return GestureDetector(
      onTap: () => Get.to(
        () => ServiceDetailsScreen(serviceId: service.id!),
        transition: Transition.cupertino,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppRadius.extraLarge),
          boxShadow: AppShadows.soft(
              blur: 16,
              opacity:
                  Theme.of(context).brightness == Brightness.dark ? 0.28 : 0.06),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(AppRadius.extraLarge)),
              child: CustomImage(
                image: service.image ?? '',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            service.title ?? '',
                            style: robotoBold.copyWith(
                                fontSize: 13,
                                color: AppColors.textPrimary(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _StatusBadge(
                            label: statusLabel, color: statusColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (service.expiryDate != null)
                      Row(
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              size: 11, color: Colors.grey.shade400),
                          const SizedBox(width: 4),
                          Text(
                            '${'expires_label'.tr}: ${service.expiryDate}',
                            style: robotoRegular.copyWith(
                                fontSize: 11,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    if (service.servicePrice != null ||
                        service.discount != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        service.offerType == 'discount'
                            ? '${service.formattedDiscount ?? '${service.discount}%'}  ${'discount_label'.tr}'
                            : '${service.servicePrice} ${'currency_sar'.tr}',
                        style: robotoMedium.copyWith(
                            fontSize: 12, color: primary),
                      ),
                    ],
                    if (service.status == 'rejected' &&
                        (service.rejectionReason ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 12, color: Colors.red.shade400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                service.rejectionReason!,
                                style: robotoRegular.copyWith(
                                    fontSize: 11,
                                    color: Colors.red.shade600),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Toggle switch
            Padding(
              padding: const EdgeInsets.only(left: 12, right: 4),
              child: Switch(
                value: isActive,
                activeThumbColor: primary,
                activeTrackColor: primary.withValues(alpha: 0.4),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.grey.shade200,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: canToggle
                    ? (_) => Get.find<ServicesController>()
                        .toggleServiceStatus(service.id!)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(fontSize: 10, color: color),
      ),
    );
  }
}

// ─── Empty tab state ──────────────────────────────────────────────────────────

class _EmptyTab extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  const _EmptyTab(
      {required this.icon, required this.message, required this.color});

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
                    color.withValues(alpha: 0.1),
                    color.withValues(alpha: 0.04),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: color.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 22),
            Text(
              message,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                  fontSize: 16, color: AppColors.textPrimary(context)),
            ),
          ],
        ),
      ),
    );
  }
}
