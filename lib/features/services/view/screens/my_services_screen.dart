import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/provider/controller/provider_permission_controller.dart';
import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
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
    _tabController = TabController(length: 3, vsync: this);
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

  Widget _buildContent(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

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
              services: expired,
              primary: primary,
              statusColor: Colors.red.shade600,
              statusLabel: 'expired_status'.tr,
              emptyMessage: 'no_expired_offers'.tr,
              emptyIcon: Icons.cancel_outlined,
            ),
          ],
        );
      },
    );

    final tabBar = TabBar(
      controller: _tabController,
      labelColor: Colors.white,
      unselectedLabelColor: Colors.white.withValues(alpha: 0.65),
      indicatorColor: Colors.white,
      indicatorWeight: 3,
      labelStyle: robotoMedium.copyWith(fontSize: 13),
      unselectedLabelStyle: robotoRegular.copyWith(fontSize: 13),
      tabs: [
        Tab(text: 'active_status'.tr),
        Tab(text: 'under_review'.tr),
        Tab(text: 'expired_status'.tr),
      ],
    );

    final canCreate =
        Get.find<ProviderPermissionController>().canCreateServices;

    final fab = canCreate
        ? FloatingActionButton.extended(
            onPressed: () =>
                Get.toNamed(RouteHelper.getAddServiceOfferRoute()),
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 4,
            icon: const Icon(Icons.add_rounded),
            label: Text('add_service'.tr,
                style: robotoMedium.copyWith(fontSize: 13)),
          )
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text('my_services'.tr,
            style: robotoBold.copyWith(fontSize: 17, color: Colors.white)),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: tabBar,
      ),
      floatingActionButton: fab,
      body: content,
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
    final canToggle =
        service.status != 'cancelled' && service.id != null;
    final isActive = service.status == 'accept';

    return GestureDetector(
      onTap: () => Get.to(
        () => ServiceDetailsScreen(serviceId: service.id!),
        transition: Transition.cupertino,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                  right: Radius.circular(18)),
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
                                color: const Color(0xFF1A2340)),
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
                            ? '${service.discount}% خصم'
                            : '${service.servicePrice} ر.س',
                        style: robotoMedium.copyWith(
                            fontSize: 12, color: primary),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: robotoMedium.copyWith(
                fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
