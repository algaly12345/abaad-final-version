import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/shared/helpers/date_converter.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Date helpers ──────────────────────────────────────────────────────────────

String? _safeFormatDate(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return DateConverter.stringToLocalDateOnly(raw.split('T').first);
  } catch (_) {
    try {
      return DateConverter.isoStringToLocalDateOnly(raw);
    } catch (_) {
      return raw.split('T').first;
    }
  }
}

String _ensureScheme(String url) {
  if (url.startsWith('http://') || url.startsWith('https://')) return url;
  return 'https://$url';
}

Future<void> _launch(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

/// شاشة تفاصيل الخدمة، بنفس نمط "بيوت" المستخدم في تفاصيل العقار: صورة
/// بملء الشاشة خلف صفحة قابلة للسحب (DraggableScrollableSheet) تحوي السعر
/// والتفاصيل ومزود الخدمة، وشريط تواصل ثابت (واتساب/اتصال) أسفل الشاشة.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<ServicesController>(
        builder: (controller) {
          if (controller.isDetailsLoading || controller.serviceDetails == null) {
            return const _DetailsLoading();
          }

          final service = controller.serviceDetails!;
          final provider = (service.providers?.isNotEmpty ?? false)
              ? service.providers!.first
              : null;

          return Stack(
            children: [
              Positioned.fill(child: _ServiceFullScreenImage(service: service)),
              DraggableScrollableSheet(
                initialChildSize: 0.55,
                minChildSize: 0.55,
                maxChildSize: 0.93,
                builder: (context, scrollController) {
                  return ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Container(
                      color: Colors.white,
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                const SizedBox(height: 8),
                                Container(
                                  width: 36,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade300,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                _DetailsCard(service: service),
                                if (provider != null) ...[
                                  Divider(
                                    height: 1,
                                    thickness: 6,
                                    color: Colors.grey.shade100,
                                  ),
                                  _ProviderCard(provider: provider),
                                ],
                                const SizedBox(height: 90),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (provider?.phone != null && provider!.phone!.isNotEmpty)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _ContactBar(phone: provider.phone!),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─── صورة الخدمة بملء الشاشة (صورة واحدة، لا يوجد معرض متعدد) ────────────────

class _ServiceFullScreenImage extends StatelessWidget {
  final ServiceOffer service;

  const _ServiceFullScreenImage({required this.service});

  void _openFullScreen(BuildContext context) {
    final imageUrl = service.image ?? '';
    if (imageUrl.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: _FullScreenImageViewer(imageUrl: imageUrl),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () => _openFullScreen(context),
          child: CustomImage(
            image: service.image ?? '',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Align(
                alignment: Alignment.topLeft,
                child: _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Get.back(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// عارض صورة بملء الشاشة مع تكبير/تصغير بالإصبع (Pinch to zoom)، يُفتح عند
/// الضغط على صورة الخدمة. خلفية سوداء + زر إغلاق عائم.
class _FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImageViewer({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: CustomImage(
                image: imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Align(
                alignment: Alignment.topLeft,
                child: _CircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 19, color: Colors.black87),
        ),
      ),
    );
  }
}

// ─── بطاقة التفاصيل: السعر/الخصم + النوع/الفئات + الوصف + المناطق + معلومات إضافية ─

class _DetailsCard extends StatelessWidget {
  final ServiceOffer service;

  const _DetailsCard({required this.service});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDiscount = service.offerType == 'discount';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isDiscount ? Icons.local_offer_outlined : Icons.payments_outlined,
                color: isDiscount ? Colors.red.shade600 : Colors.green.shade600,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                isDiscount
                    ? '${service.formattedDiscount ?? '${service.discount}%'}  ${'discount_label'.tr}'
                    : '${service.servicePrice} ${'currency_sar'.tr}',
                style: robotoBold.copyWith(
                  fontSize: 18,
                  color: isDiscount ? Colors.red.shade600 : Colors.green.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          Text(
            service.title ?? '',
            style: robotoBold.copyWith(fontSize: 18, color: const Color(0xFF1A2340)),
          ),
          const SizedBox(height: 10),

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
            const SizedBox(height: 14),
            _SectionHeader(title: 'service_details'.tr, primary: primary),
            const SizedBox(height: 8),
            Text(
              service.description!,
              style: robotoRegular.copyWith(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.55,
              ),
            ),
          ],

          if (service.zones != null && service.zones!.isNotEmpty) ...[
            const SizedBox(height: 14),
            _SectionHeader(title: 'covered_zones'.tr, primary: primary),
            const SizedBox(height: 8),
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

          const SizedBox(height: 14),
          _SectionHeader(title: 'additional_info'.tr, primary: primary),
          const SizedBox(height: 8),
          _InfoGrid(service: service),
        ],
      ),
    );
  }
}

// ─── Additional info grid (dates + validity) ─────────────────────────────────

class _InfoGrid extends StatelessWidget {
  final ServiceOffer service;

  const _InfoGrid({required this.service});

  @override
  Widget build(BuildContext context) {
    final createdAt = _safeFormatDate(service.createdAt);
    final expiryDate = _safeFormatDate(service.expiryDate);
    final isExpired = service.isExpired ?? false;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.event_available_rounded,
                label: 'date_added'.tr,
                value: createdAt ?? '—',
                color: Colors.blueGrey.shade600,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _InfoTile(
                icon: isExpired
                    ? Icons.event_busy_rounded
                    : Icons.schedule_rounded,
                label: 'end_date'.tr,
                value: expiryDate ?? '—',
                color: isExpired ? Colors.red.shade600 : Colors.orange.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: (isExpired ? Colors.red : Colors.green).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: (isExpired ? Colors.red : Colors.green).withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isExpired ? Icons.cancel_rounded : Icons.check_circle_rounded,
                size: 18,
                color: isExpired ? Colors.red.shade600 : Colors.green.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                isExpired ? 'offer_expired_message'.tr : 'offer_active_message'.tr,
                style: robotoBold.copyWith(
                  fontSize: 13,
                  color: isExpired ? Colors.red.shade700 : Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: robotoBold.copyWith(fontSize: 13, color: const Color(0xFF1A2340)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── بطاقة مزود الخدمة (بدون واتساب/اتصال — انتقلا للشريط الثابت أسفل الشاشة) ──

class _ProviderCard extends StatelessWidget {
  final ProviderData provider;

  const _ProviderCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final hasSecondaryChannels = (provider.twitter?.isNotEmpty ?? false) ||
        (provider.instagram?.isNotEmpty ?? false) ||
        (provider.snapchat?.isNotEmpty ?? false) ||
        (provider.tiktok?.isNotEmpty ?? false) ||
        (provider.website?.isNotEmpty ?? false);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'service_provider'.tr, primary: primary),
          const SizedBox(height: 12),
          Row(
            children: [
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
          if (hasSecondaryChannels) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                if (provider.twitter != null && provider.twitter!.isNotEmpty)
                  _ContactBtn(
                    label: 'twitter_x_label'.tr,
                    icon: Icons.alternate_email_rounded,
                    color: Colors.black87,
                    onTap: () => _launch('https://twitter.com/${provider.twitter}'),
                  ),
                if (provider.instagram != null && provider.instagram!.isNotEmpty)
                  _ContactBtn(
                    label: 'instagram_label'.tr,
                    icon: Icons.camera_alt_rounded,
                    color: Colors.pink.shade600,
                    onTap: () => _launch('https://instagram.com/${provider.instagram}'),
                  ),
                if (provider.snapchat != null && provider.snapchat!.isNotEmpty)
                  _ContactBtn(
                    label: 'snapchat_label'.tr,
                    icon: Icons.camera_rounded,
                    color: Colors.amber.shade800,
                    onTap: () => _launch('https://www.snapchat.com/add/${provider.snapchat}'),
                  ),
                if (provider.tiktok != null && provider.tiktok!.isNotEmpty)
                  _ContactBtn(
                    label: 'tiktok_label'.tr,
                    icon: Icons.music_note_rounded,
                    color: Colors.teal.shade700,
                    onTap: () => _launch('https://www.tiktok.com/@${provider.tiktok}'),
                  ),
                if (provider.website != null && provider.website!.isNotEmpty)
                  _ContactBtn(
                    label: 'website_label'.tr,
                    icon: Icons.language_rounded,
                    color: Colors.indigo.shade600,
                    onTap: () => _launch(_ensureScheme(provider.website!)),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── شريط التواصل الثابت أسفل الشاشة (واتساب/اتصال) ───────────────────────────

class _ContactBar extends StatelessWidget {
  final String phone;

  const _ContactBar({required this.phone});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _ContactBarButton(
              label: 'whatsapp'.tr,
              icon: Icons.chat_rounded,
              color: Colors.green.shade600,
              onTap: () => _launch(
                'https://wa.me/${phone.replaceAll('+', '').replaceAll(' ', '')}',
              ),
            ),
            const SizedBox(width: 8),
            _ContactBarButton(
              label: 'call'.tr,
              icon: Icons.call_rounded,
              color: Colors.blue.shade600,
              onTap: () => _launch('tel:$phone'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactBarButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContactBarButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 21),
              const SizedBox(height: 3),
              Text(
                label,
                style: robotoMedium.copyWith(fontSize: 12, color: color),
              ),
            ],
          ),
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoMedium.copyWith(fontSize: 11, color: color),
            ),
          ],
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
