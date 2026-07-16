import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/shared/helpers/date_converter.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── Helpers ────────────────────────────────────────────────────────────────

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

String _cleanPhoneForWhatsapp(String phone) =>
    phone.replaceAll('+', '').replaceAll(' ', '');

// أول منطقة تغطية تملك إحداثيات — تقريب معقول لعدم وجود إحداثي مقر مستقل
// لمزود الخدمة نفسه (نفس منطق _ServiceActionButtons في شاشة القائمة).
ZoneData? _mappableZone(ServiceOffer service) {
  final zones = service.zones;
  if (zones == null) return null;
  for (final zone in zones) {
    if (zone.latitude != null && zone.longitude != null) return zone;
  }
  return null;
}

String? _zonesSummary(List<ZoneData>? zones) {
  if (zones == null || zones.isEmpty) return null;
  if (zones.length == 1) return zones.first.nameAr ?? zones.first.name;
  return '${zones.length} مناطق';
}

({String text, Color color}) _priceInfo(ServiceOffer service) {
  final isDiscount = service.offerType == 'discount';
  final color = isDiscount ? Colors.red.shade600 : Colors.green.shade600;
  final text = isDiscount
      ? '${service.formattedDiscount ?? '${service.discount}%'} ${'discount_label'.tr}'
      : '${service.servicePrice} ${'currency_sar'.tr}';
  return (text: text, color: color);
}

/// شاشة تفاصيل الخدمة — صورة بملء الشاشة خلف صفحة قابلة للسحب
/// (DraggableScrollableSheet)، مع صف إجراءات سريعة (اتصال/خريطة) ثابت ضمن
/// رأس الورقة نفسها (لا عائمًا فوق الصورة)، وشريط سعر + CTA ثابت أسفل
/// الشاشة، مطابقةً لبنية تصميم مرجعي مقترح (عنوان+تقييم، موقع، شرائح "يشمل
/// الخدمة"، "عن الخدمة"، ثم السعر وزر التواصل) بألوان التطبيق نفسها.
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
          final mappableZone = _mappableZone(service);
          final hasPhone = provider?.phone != null && provider!.phone!.isNotEmpty;
          // شريط السعر/CTA السفلي لا يظهر إلا مع رقم هاتف صالح — عندها يُنقَل
          // السعر بالكامل إليه (مطابقةً للمرجع)، وإلا يبقى السعر ظاهرًا ضمن
          // رأس البطاقة كي لا يختفي كليًا.

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
                      color: Theme.of(context).cardColor,
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
                                const SizedBox(height: 16),
                                _HeaderInfo(
                                  service: service,
                                  provider: provider,
                                  mappableZone: mappableZone,
                                  showInlinePrice: !hasPhone,
                                ),
                                const SizedBox(height: 16),
                                _QuickActionsRow(
                                  provider: hasPhone ? provider : null,
                                  mappableZone: mappableZone,
                                ),
                                const SizedBox(height: 4),
                                _ServicesIncludeSection(service: service),
                                _AboutSection(service: service),
                                _ZonesSection(service: service),
                                _AdditionalInfoSection(service: service),
                                if (provider != null)
                                  _ProviderCard(provider: provider),
                                SizedBox(height: hasPhone ? 100 : 24),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (hasPhone)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _BottomCtaBar(service: service, provider: provider),
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
        // تعتيم علوي (لوضوح زر الرجوع) + تعتيم سفلي خفيف يمهّد الانتقال إلى
        // حدّ الصفحة القابلة للسحب — يمنح الصورة "مزاجًا" أقرب للتصميم
        // المرجعي بدل صورة خام بلا أي تدرّج عند حافتها السفلية.
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
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.32),
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

// ─── صف إجراءات سريعة (اتصال + خريطة) ثابت ضمن تدفّق الصفحة نفسها — لا يعود
// عنصرًا عائمًا فوق الصورة (كان يبدو منفصلاً/غير مستقر عند سحب الصفحة)، بل
// جزء أصيل من رأس الورقة، بنفس نمط أزرار الإجراء المُسمّاة (أيقونة + نص)
// المعتمد أصلاً في بطاقة القائمة — بدل دائرتين مجرّدتين بلا تسمية ───────────

class _QuickActionsRow extends StatelessWidget {
  final ProviderData? provider;
  final ZoneData? mappableZone;

  const _QuickActionsRow({this.provider, this.mappableZone});

  @override
  Widget build(BuildContext context) {
    if (provider == null && mappableZone == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          if (provider != null)
            Expanded(
              child: _QuickActionButton(
                icon: Icons.call_rounded,
                label: 'اتصال',
                color: Colors.blue.shade600,
                onTap: () => _launch('tel:${provider!.phone}'),
              ),
            ),
          if (provider != null && mappableZone != null) const SizedBox(width: 10),
          if (mappableZone != null)
            Expanded(
              child: _QuickActionButton(
                icon: Icons.map_outlined,
                label: 'الخريطة',
                color: Colors.deepOrange.shade400,
                onTap: () => _launch(
                  'https://www.google.com/maps/search/?api=1&query=${mappableZone!.latitude},${mappableZone!.longitude}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: color.withValues(alpha: dark ? 0.16 : 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label, style: robotoBold.copyWith(fontSize: 13.5, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── رأس البطاقة: العنوان + تقييم مزود الخدمة (إن وُجد) + سطر الموقع القابل
// للنقر لفتح الخريطة (عند توفّر منطقة بإحداثيات) — مطابقةً لرأس التصميم
// المرجعي (العنوان بجانب شارة التقييم، ثم سطر 📍 الموقع أسفله مباشرة) ───────

class _HeaderInfo extends StatelessWidget {
  final ServiceOffer service;
  final ProviderData? provider;
  final ZoneData? mappableZone;
  final bool showInlinePrice;

  const _HeaderInfo({
    required this.service,
    required this.provider,
    required this.mappableZone,
    required this.showInlinePrice,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final textColor = dark ? Colors.white : const Color(0xFF1A2340);
    final zonesLabel = _zonesSummary(service.zones);
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  service.title ?? '',
                  style: robotoBold.copyWith(fontSize: 20, color: textColor),
                ),
              ),
              if (provider?.rating != null) ...[
                const SizedBox(width: 10),
                _RatingBadge(
                    rating: provider!.rating!, count: provider!.reviewsCount),
              ],
            ],
          ),
          if (showInlinePrice) ...[
            const SizedBox(height: 8),
            _PriceTag(service: service),
          ],
          if (zonesLabel != null) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap:
                  mappableZone != null ? () => _openMap(mappableZone!) : null,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 16,
                      color: mappableZone != null
                          ? primary
                          : Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(zonesLabel,
                      style: robotoMedium.copyWith(
                          fontSize: 13, color: Colors.grey.shade600)),
                  if (mappableZone != null) ...[
                    const SizedBox(width: 2),
                    Icon(Icons.chevron_left_rounded, size: 16, color: primary),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _openMap(ZoneData zone) => _launch(
      'https://www.google.com/maps/search/?api=1&query=${zone.latitude},${zone.longitude}');
}

class _RatingBadge extends StatelessWidget {
  final double rating;
  final int? count;

  const _RatingBadge({required this.rating, this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: robotoBold.copyWith(fontSize: 13, color: Colors.amber.shade800),
          ),
        ],
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  final ServiceOffer service;

  const _PriceTag({required this.service});

  @override
  Widget build(BuildContext context) {
    final isDiscount = service.offerType == 'discount';
    final info = _priceInfo(service);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isDiscount ? Icons.local_offer_outlined : Icons.payments_outlined,
          size: 18,
          color: info.color,
        ),
        const SizedBox(width: 6),
        Text(info.text, style: robotoBold.copyWith(fontSize: 15, color: info.color)),
      ],
    );
  }
}

// ─── بطاقة قسم موحّدة: خلفية خفيفة + حواف مقرّبة تفصل كل قسم بصريًا عن
// المجاور له، بدل نص متتابع على خلفية الورقة المسطّحة مباشرة — هذا ما يمنح
// الصفحة طابعًا "احترافيًا" مقسّمًا بوضوح بدل الشعور بقائمة نصوص متلاصقة ────

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.035) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: dark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade200,
        ),
      ),
      child: child,
    );
  }
}

// ─── "يشمل الخدمة": شرائح نوع الخدمة/الفئات ─────────────────────────────────

class _ServicesIncludeSection extends StatelessWidget {
  final ServiceOffer service;

  const _ServicesIncludeSection({required this.service});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final items = <_ChipData>[
      if (service.serviceType?.name != null)
        _ChipData(service.serviceType!.name!, Icons.category_outlined, primary),
      ...?service.categories?.map((c) => _ChipData(
          c.nameAr ?? c.name ?? '', Icons.label_outline_rounded,
          Colors.orange.shade700)),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: 'يشمل الخدمة',
              icon: Icons.checklist_rounded,
              primary: primary),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .map((i) =>
                    _TagChip(label: i.label, icon: i.icon, color: i.color))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ChipData {
  final String label;
  final IconData icon;
  final Color color;

  _ChipData(this.label, this.icon, this.color);
}

// ─── "عن الخدمة": نص الوصف الكامل ───────────────────────────────────────────

class _AboutSection extends StatelessWidget {
  final ServiceOffer service;

  const _AboutSection({required this.service});

  @override
  Widget build(BuildContext context) {
    if (service.description == null || service.description!.isEmpty) {
      return const SizedBox.shrink();
    }
    final primary = Theme.of(context).primaryColor;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: 'service_details'.tr,
              icon: Icons.info_outline_rounded,
              primary: primary),
          const SizedBox(height: 10),
          Text(
            service.description!,
            style: robotoRegular.copyWith(
              fontSize: 14,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── "المناطق المغطّاة": التفصيل الكامل للمناطق (سطر الموقع أعلاه يكتفي
// بملخّص/اسم أول منطقة) — معلومة حقيقية يحتاجها المستخدم عند تعدّد المناطق،
// لا يقابلها شيء في التصميم المرجعي أحاديّ الموقع فأُبقيت كما هي ─────────────

class _ZonesSection extends StatelessWidget {
  final ServiceOffer service;

  const _ZonesSection({required this.service});

  @override
  Widget build(BuildContext context) {
    final zones = service.zones;
    if (zones == null || zones.length < 2) return const SizedBox.shrink();
    final primary = Theme.of(context).primaryColor;

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: 'covered_zones'.tr,
              icon: Icons.travel_explore_rounded,
              primary: primary),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: zones
                .map((z) => _TagChip(
                      label: z.nameAr ?? z.name ?? '',
                      color: Colors.teal.shade600,
                      icon: Icons.location_on_outlined,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── "معلومات إضافية": تواريخ الإضافة/الانتهاء + حالة العرض ─────────────────

class _AdditionalInfoSection extends StatelessWidget {
  final ServiceOffer service;

  const _AdditionalInfoSection({required this.service});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: 'additional_info'.tr,
              icon: Icons.event_note_rounded,
              primary: primary),
          const SizedBox(height: 10),
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

// ─── بطاقة مزود الخدمة (بدون واتساب/اتصال — انتقلا لصف الإجراءات السريعة
// أعلى الورقة وشريط الـCTA السفلي) ───────────────────────────────────────────

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

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
              title: 'service_provider'.tr,
              icon: Icons.storefront_rounded,
              primary: primary),
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

// ─── شريط السعر + زر "طلب الخدمة" الثابت أسفل الشاشة — يحلّ محل زر
// واتساب/اتصال المزدوج السابق: الاتصال انتقل لصف الإجراءات السريعة أعلى
// الورقة، فبقي هنا إجراء واحد بارز (واتساب) بجانب السعر، مطابقةً لتذييل
// السعر/زر الحجز في التصميم المرجعي ─────────────────────────────────────────

class _BottomCtaBar extends StatelessWidget {
  final ServiceOffer service;
  final ProviderData provider;

  const _BottomCtaBar({required this.service, required this.provider});

  @override
  Widget build(BuildContext context) {
    final info = _priceInfo(service);
    final dark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: dark ? 0.4 : 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'السعر',
                  style: robotoRegular.copyWith(
                      fontSize: 10.5, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  info.text,
                  style: robotoBold.copyWith(fontSize: 15, color: info.color),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _launch(
                  'https://wa.me/${_cleanPhoneForWhatsapp(provider.phone!)}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.chat_rounded, size: 18),
                label: Text('طلب الخدمة',
                    style: robotoBold.copyWith(fontSize: 14, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primary;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: dark ? 0.22 : 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: primary),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: robotoBold.copyWith(
              fontSize: 15, color: dark ? Colors.white : const Color(0xFF1A2340)),
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
