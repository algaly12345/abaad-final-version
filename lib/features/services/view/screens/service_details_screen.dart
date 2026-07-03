import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailsScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ServicesController>().getServiceDetails(widget.serviceId);
    });
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: GetBuilder<ServicesController>(
        builder: (controller) {
          if (controller.isDetailsLoading || controller.serviceDetails == null) {
            return const _DetailsLoading();
          }

          final service = controller.serviceDetails!;
          final provider = (service.providers?.isNotEmpty ?? false)
              ? service.providers!.first
              : null;
          final isDiscount = service.offerType == 'discount';

          return CustomScrollView(
            slivers: [
              // ── Collapsible image app bar ────────────────────────────────
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: primary,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImage(
                        image: service.image ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Gradient overlay
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                      // Price badge
                      Positioned(
                        bottom: 20,
                        right: 20,
                        child: _PriceBadge(
                          isDiscount: isDiscount,
                          discount: service.discount,
                          price: service.servicePrice,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body ────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main card
                    _DetailsCard(service: service, primary: primary),
                    const SizedBox(height: 12),

                    // Provider card
                    if (provider != null)
                      _ProviderCard(
                          provider: provider,
                          primary: primary,
                          onCall: () =>
                              _launch('tel:${provider.phone}'),
                          onWhatsApp: () => _launch(
                              'https://wa.me/${provider.phone?.replaceAll('+', '').replaceAll(' ', '')}'),
                          onTwitter: (provider.twitter?.isNotEmpty ?? false)
                              ? () => _launch(
                                  'https://twitter.com/${provider.twitter}')
                              : null),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── Price badge ──────────────────────────────────────────────────────────────

class _PriceBadge extends StatelessWidget {
  final bool isDiscount;
  final dynamic discount;
  final dynamic price;

  const _PriceBadge(
      {required this.isDiscount, required this.discount, required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDiscount ? Colors.red.shade600 : Colors.green.shade600,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDiscount ? Icons.local_offer_outlined : Icons.payments_outlined,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            isDiscount ? '$discount%  خصم' : '$price ر.س',
            style: robotoBold.copyWith(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

// ─── Details card ─────────────────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  final ServiceOffer service;
  final Color primary;

  const _DetailsCard({required this.service, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            service.title ?? '',
            style: robotoBold.copyWith(fontSize: 20, color: const Color(0xFF1A2340)),
          ),
          const SizedBox(height: 12),

          // Type & category chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (service.serviceType?.name != null)
                _TagChip(
                  label: service.serviceType!.name!,
                  color: primary,
                  icon: Icons.category_outlined,
                ),
              if (service.categories != null)
                ...service.categories!.map((c) => _TagChip(
                      label: c.nameAr ?? c.name ?? '',
                      color: Colors.orange.shade700,
                      icon: Icons.label_outline_rounded,
                    )),
            ],
          ),

          if (service.description != null &&
              service.description!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(title: 'تفاصيل الخدمة', primary: primary),
            const SizedBox(height: 10),
            Text(
              service.description!,
              style: robotoRegular.copyWith(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.65,
              ),
            ),
          ],

          // Zones
          if (service.zones != null && service.zones!.isNotEmpty) ...[
            const SizedBox(height: 20),
            _SectionHeader(title: 'المناطق المشمولة', primary: primary),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: service.zones!
                  .map((z) => _TagChip(
                        label: z.nameAr ?? z.name ?? '',
                        color: Colors.teal.shade600,
                        icon: Icons.location_on_outlined,
                      ))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Provider card ────────────────────────────────────────────────────────────

class _ProviderCard extends StatelessWidget {
  final ProviderData provider;
  final Color primary;
  final VoidCallback onCall;
  final VoidCallback onWhatsApp;
  final VoidCallback? onTwitter;

  const _ProviderCard({
    required this.provider,
    required this.primary,
    required this.onCall,
    required this.onWhatsApp,
    this.onTwitter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'مزود الخدمة', primary: primary),
          const SizedBox(height: 14),
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: primary.withValues(alpha: 0.25), width: 2),
                ),
                child: ClipOval(
                  child: provider.image != null && provider.image!.isNotEmpty
                      ? CustomImage(
                          image: provider.image!,
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                        )
                      : Icon(Icons.storefront_rounded,
                          size: 28, color: primary),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name ?? '',
                      style: robotoBold.copyWith(
                          fontSize: 15, color: const Color(0xFF1A2340)),
                    ),
                    if (provider.phone != null && provider.phone!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        provider.phone!,
                        style: robotoRegular.copyWith(
                            fontSize: 13, color: Colors.grey.shade500),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Action buttons
          Row(
            children: [
              _ContactBtn(
                label: 'اتصال',
                icon: Icons.call_rounded,
                color: Colors.blue.shade600,
                onTap: onCall,
              ),
              const SizedBox(width: 10),
              _ContactBtn(
                label: 'واتساب',
                icon: Icons.chat_rounded,
                color: Colors.green.shade600,
                onTap: onWhatsApp,
              ),
              if (onTwitter != null) ...[
                const SizedBox(width: 10),
                _ContactBtn(
                  label: 'تويتر',
                  icon: Icons.public_rounded,
                  color: Colors.lightBlue.shade600,
                  onTap: onTwitter!,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color primary;

  const _SectionHeader({required this.title, required this.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: robotoBold.copyWith(
              fontSize: 15, color: const Color(0xFF1A2340)),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _TagChip(
      {required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: robotoMedium.copyWith(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}

class _ContactBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContactBtn(
      {required this.label,
      required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style:
                    robotoMedium.copyWith(fontSize: 11, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Details loading skeleton ─────────────────────────────────────────────────

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(height: 280, color: const Color(0xFFE8ECF0)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sh(double.infinity, 24),
                const SizedBox(height: 12),
                _sh(180, 14),
                const SizedBox(height: 24),
                _sh(double.infinity, 14),
                const SizedBox(height: 8),
                _sh(double.infinity, 14),
                const SizedBox(height: 8),
                _sh(260, 14),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sh(double w, double h) => Container(
        width: w,
        height: h,
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFE8ECF0),
          borderRadius: BorderRadius.circular(8),
        ),
      );
}
