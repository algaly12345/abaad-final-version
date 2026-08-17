import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/helpers/date_converter.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

// إحداثيات العرض نفسها (تُحدَّد على الخارطة عند إنشائه) أدق من إحداثيات
// منطقة التغطية، فتُستخدم أولاً — وتبقى منطقة التغطية احتياطًا للعروض
// الأقدم التي أُنشئت قبل إضافة هذا الحقل.
LatLng? _effectiveLatLng(ServiceOffer service, ZoneData? mappableZone) {
  if (service.latitude != null && service.longitude != null) {
    return LatLng(service.latitude!, service.longitude!);
  }
  if (mappableZone != null) {
    return LatLng(mappableZone.latitude!, mappableZone.longitude!);
  }
  return null;
}

/// شاشة تفاصيل الخدمة — إعادة تصميم مسطّحة (Uber/Airbnb): SliverAppBar بصورة
/// الخدمة بدل صفحة قابلة للسحب فوق صورة ملء الشاشة، وجسم أبيض متصل تفصل بين
/// أقسامه مسافات + خطوط فاصلة رفيعة بدل تغليف كل قسم ببطاقة محدودة الحواف.
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
    return GetBuilder<ServicesController>(
      builder: (controller) {
        if (controller.isDetailsLoading || controller.serviceDetails == null) {
          return const Scaffold(body: _DetailsLoading());
        }

        final service = controller.serviceDetails!;
        final provider = (service.providers?.isNotEmpty ?? false)
            ? service.providers!.first
            : null;
        final mappableZone = _mappableZone(service);
        final mapLatLng = _effectiveLatLng(service, mappableZone);
        // رقم التواصل الخاص بهذا العرض تحديداً (contact_phone) له الأولوية —
        // يسقط احتياطياً على رقم حساب المزوّد العام للعروض القديمة التي أُنشئت
        // قبل إضافة هذا الحقل.
        final effectivePhone = (service.contactPhone?.trim().isNotEmpty ?? false)
            ? service.contactPhone!.trim()
            : provider?.phone;
        final contactType = service.contactType ?? 'both';
        final hasPhone = effectivePhone != null && effectivePhone.isNotEmpty;
        // عرض هذا المزوّد نفسه لم يُدفع بعد (unpaid) أو فشل دفعه (failed) —
        // payment_status/subscription_number لا يصلان إلا لمالك العرض
        // (ServiceOfferResource::isOwnedBy)، فهذا الشرط لا يتحقق أبداً لعرض
        // يشاهده مستخدم آخر غير مالكه. مقيّد أيضاً بـ status=='pending' مطابقةً
        // لتبويب "غير مدفوعة" في my_services_screen.dart: عروض اعتمدتها
        // الإدارة يدوياً رغم بقاء اشتراكها unpaid تبقى تعرض شريط CTA العادي
        // لا "ادفع الآن" — هي بالفعل نشطة ومرئية للعملاء.
        final needsPayment = service.status == 'pending' &&
            (service.paymentStatus == 'unpaid' ||
                service.paymentStatus == 'failed') &&
            (service.subscriptionNumber?.isNotEmpty ?? false);
        final includesLabels = <String>[
          if (service.serviceType?.name != null) service.serviceType!.name!,
          ...?service.categories?.map((c) => c.nameAr ?? c.name ?? ''),
        ].where((l) => l.isNotEmpty).toList();
        final zoneLabels = (service.zones?.length ?? 0) >= 2
            ? service.zones!.map((z) => z.nameAr ?? z.name ?? '').toList()
            : <String>[];

        return Scaffold(
          backgroundColor: Theme.of(context).cardColor,
          body: CustomScrollView(
            slivers: [
              _ServiceSliverAppBar(service: service),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, hasPhone ? 110 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TitleAndLocation(
                        service: service,
                        mappableZone: mappableZone,
                        showInlinePrice: !hasPhone,
                      ),
                      const _SectionDivider(),
                      _LocationMapSection(position: mapLatLng),
                      if (includesLabels.isNotEmpty) ...[
                        const _SectionDivider(),
                        _ChipsSection(title: 'يشمل الخدمة', labels: includesLabels),
                      ],
                      if ((service.description ?? '').isNotEmpty) ...[
                        const _SectionDivider(),
                        _AboutSection(text: service.description!),
                      ],
                      if (zoneLabels.isNotEmpty) ...[
                        const _SectionDivider(),
                        _ChipsSection(
                            title: 'covered_zones'.tr, labels: zoneLabels),
                      ],
                      const _SectionDivider(),
                      _AdditionalInfoSection(service: service),
                      if (provider != null) ...[
                        const _SectionDivider(),
                        _ProviderSection(
                          provider: provider,
                          phone: effectivePhone,
                          contactType: contactType,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: needsPayment
              ? _PayNowBottomBar(service: service)
              : (hasPhone
              ? _StickyBottomBar(
            service: service,
            phone: effectivePhone,
            contactType: contactType,
          )
              : null),
        );
      },
    );
  }
}

// ─── رأس الصورة: SliverAppBar بدل صورة خلفية + ورقة قابلة للسحب — يتصرّف
// كرأس صفحة عادي (ينضغط عند التمرير) مطابقةً لأسلوب Uber/Airbnb المرجعي، مع
// زرّ رجوع دائري أبيض شبه شفاف بظلّ ناعم (frosted/solid + shadow) ─────────────

class _ServiceSliverAppBar extends StatelessWidget {
  final ServiceOffer service;

  const _ServiceSliverAppBar({required this.service});

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
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).cardColor,
      foregroundColor: AppColors.textPrimary(context),
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: _CircleIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Get.back(),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: GestureDetector(
          onTap: () => _openFullScreen(context),
          child: CustomImage(
            image: service.image ?? '',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
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
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.3),
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

// ─── العنوان + الموقع: العنوان بارز (20sp Bold) يليه سطر الموقع القابل للنقر
// (بلا شارة تقييم — provider.rating لا يصل من الباكند فعليًا حتى الآن). عند
// غياب شريط CTA السفلي (بلا رقم هاتف)، يُعرض السعر هنا كي لا يختفي كليًا ────

class _TitleAndLocation extends StatelessWidget {
  final ServiceOffer service;
  final ZoneData? mappableZone;
  final bool showInlinePrice;

  const _TitleAndLocation({
    required this.service,
    required this.mappableZone,
    required this.showInlinePrice,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final zonesLabel = _zonesSummary(service.zones);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.title ?? '',
          style: robotoBold.copyWith(
              fontSize: 20, color: AppColors.textPrimary(context), height: 1.3),
        ),
        if (zonesLabel != null) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: mappableZone != null
                ? () => _launch(
                'https://www.google.com/maps/search/?api=1&query=${mappableZone!.latitude},${mappableZone!.longitude}')
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded,
                    size: 16,
                    color:
                    mappableZone != null ? primary : Colors.grey.shade500),
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
        if (showInlinePrice) ...[
          const SizedBox(height: 16),
          _PriceRow(service: service, large: true),
        ],
      ],
    );
  }
}

// ─── الموقع على الخريطة: خارطة تفاعلية مضمّنة (قابلة للتحريك/التكبير) داخل
// بطاقة مدوّرة الحواف بظلّ ناعم، بدل الرابط الخارجي وحده — يبقى رابط "فتح في
// الخرائط" متاحًا فوقها لمن يفضّل تطبيق الخرائط الكامل ──────────────────────

class _LocationMapSection extends StatelessWidget {
  final LatLng? position;

  const _LocationMapSection({required this.position});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final pos = position;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('الموقع على الخريطة',
                style: robotoBold.copyWith(
                    fontSize: 16, color: AppColors.textPrimary(context))),
            if (pos != null)
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _launch(
                    'https://www.google.com/maps/search/?api=1&query=${pos.latitude},${pos.longitude}'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('فتح في الخرائط',
                          style: robotoMedium.copyWith(
                              fontSize: 12.5, color: primary)),
                      const SizedBox(width: 3),
                      Icon(Icons.open_in_new_rounded, size: 14, color: primary),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (pos == null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28),
            decoration: BoxDecoration(
              color: dark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(AppRadius.extraLarge),
            ),
            child: Column(
              children: [
                Icon(Icons.location_off_outlined, size: 26, color: Colors.grey.shade500),
                const SizedBox(height: 8),
                Text('لم يحدّد مزود الخدمة موقعًا لهذا العرض',
                    style: robotoMedium.copyWith(
                        fontSize: 12.5, color: Colors.grey.shade500)),
              ],
            ),
          )
        else
          Container(
            height: 190,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.extraLarge),
              boxShadow: AppShadows.soft(blur: 16, opacity: dark ? 0.28 : 0.08),
            ),
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: pos, zoom: 15),
                  markers: {
                    Marker(markerId: const MarkerId('provider_location'), position: pos),
                  },
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: false,
                  rotateGesturesEnabled: false,
                  tiltGesturesEnabled: false,
                ),
                Positioned(
                  left: 10,
                  bottom: 10,
                  child: _CircleIconButton(
                    icon: Icons.fullscreen_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => _FullScreenLocationMap(position: pos),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// عرض الخريطة بملء الشاشة عند الضغط على زرّ التكبير — نفس العلامة بلا أي
/// إجراء إضافي، للتصفّح المريح فقط قبل العودة أو فتح تطبيق الخرائط الخارجي.
class _FullScreenLocationMap extends StatelessWidget {
  final LatLng position;

  const _FullScreenLocationMap({required this.position});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: position, zoom: 16),
            markers: {
              Marker(markerId: const MarkerId('provider_location'), position: position),
            },
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
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
          Positioned(
            left: 14,
            right: 14,
            bottom: 24,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () => _launch(
                      'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: Text('فتح في تطبيق الخرائط',
                      style: robotoBold.copyWith(fontSize: 14.5, color: Colors.white)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── سطر السعر/الخصم — مُشترك بين العرض الاحتياطي أعلى الصفحة (بلا هاتف)
// وشريط الـCTA السفلي، بحجمين (large/compact) بدل تكرار المنطق مرتين ────────

class _PriceRow extends StatelessWidget {
  final ServiceOffer service;
  final bool large;

  const _PriceRow({required this.service, this.large = false});

  @override
  Widget build(BuildContext context) {
    final isDiscount = service.offerType == 'discount';
    final hasPrice = service.servicePrice != null && service.servicePrice!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isDiscount) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${service.formattedDiscount ?? '${service.discount}%'} خصم',
              style: robotoBold.copyWith(
                  fontSize: large ? 13 : 12, color: Colors.red.shade600),
            ),
          ),
          if (hasPrice) const SizedBox(height: 4),
        ],
        if (hasPrice)
          Text(
            '${service.servicePrice} ${'currency_sar'.tr}',
            style: isDiscount
                ? robotoMedium.copyWith(
              fontSize: large ? 14 : 12.5,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            )
                : robotoBold.copyWith(
                fontSize: large ? 18 : 16, color: AppColors.textPrimary(context)),
          ),
      ],
    );
  }
}

// ─── فاصل رفيع بين الأقسام — بديل تغليف كل قسم ببطاقة محدودة الحواف
// (Colors.grey[200])، بمسافة سخيّة 24 أعلاه وأسفله (شبكة 8pt) ───────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1, thickness: 1, color: Colors.grey[200]),
    );
  }
}

// ─── قسم شرائح عام (يُستخدم لـ"يشمل الخدمة" و"المناطق المشمولة"): شرائح غير
// محاطة بحدّ، خلفية فاتحة ناعمة، نص داكن — بدل الحدود الملوّنة/الأيقونات
// المتفرّقة سابقًا ───────────────────────────────────────────────────────────

class _ChipsSection extends StatelessWidget {
  final String title;
  final List<String> labels;

  const _ChipsSection({required this.title, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
            robotoBold.copyWith(fontSize: 16, color: AppColors.textPrimary(context))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: labels
              .where((l) => l.isNotEmpty)
              .map((l) => _TagChip(label: l))
              .toList(),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: robotoMedium.copyWith(
            fontSize: 12.5, color: dark ? Colors.white70 : const Color(0xFF1A2340)),
      ),
    );
  }
}

// ─── "تفاصيل الخدمة": نص وصفي بسيط — بلا أيقونة بجانب العنوان (زائدة) ───────

class _AboutSection extends StatelessWidget {
  final String text;

  const _AboutSection({required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('service_details'.tr,
            style:
            robotoBold.copyWith(fontSize: 16, color: AppColors.textPrimary(context))),
        const SizedBox(height: 10),
        Text(
          text,
          style: robotoRegular.copyWith(
              fontSize: 14, color: Colors.grey.shade700, height: 1.5),
        ),
      ],
    );
  }
}

// ─── "معلومات إضافية": تواريخ الإضافة/الانتهاء + حالة العرض — حاويات ناعمة
// بلا حدود صلبة (فقط تلوين خلفية خفيف) ───────────────────────────────────────

class _AdditionalInfoSection extends StatelessWidget {
  final ServiceOffer service;

  const _AdditionalInfoSection({required this.service});

  @override
  Widget build(BuildContext context) {
    final createdAt = _safeFormatDate(service.createdAt);
    final expiryDate = _safeFormatDate(service.expiryDate);
    final isExpired = service.isExpired ?? false;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('additional_info'.tr,
            style:
            robotoBold.copyWith(fontSize: 16, color: AppColors.textPrimary(context))),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _InfoTile(
                icon: Icons.event_available_rounded,
                label: 'date_added'.tr,
                value: createdAt ?? '—',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InfoTile(
                icon: isExpired
                    ? Icons.event_busy_rounded
                    : Icons.schedule_rounded,
                label: 'end_date'.tr,
                value: expiryDate ?? '—',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: (isExpired ? Colors.red : Colors.green)
                .withValues(alpha: dark ? 0.16 : 0.08),
            borderRadius: BorderRadius.circular(14),
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

  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: Colors.grey.shade500),
          const SizedBox(height: 8),
          Text(label,
              style: robotoRegular.copyWith(fontSize: 11, color: Colors.grey.shade500)),
          const SizedBox(height: 2),
          Text(
            value,
            style: robotoBold.copyWith(fontSize: 13, color: AppColors.textPrimary(context)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── مزوّد الخدمة: الاسم + الصورة الرمزية + زر الاتصال في صفّ واحد بأسلوب
// ListTile، بدل بطاقة منفصلة — الاتصال انتقل إلى هنا مباشرةً بجانب اسم
// المزوّد (بدل زرّ عريض قائم بذاته أعلى الصفحة)؛ "تواصل واتساب" (واتساب) بقي
// وحده في شريط الـCTA السفلي ─────────────────────────────────────────────────

class _ProviderSection extends StatelessWidget {
  final ProviderData provider;
  // رقم التواصل الفعلي لهذا العرض (contact_phone أو رقم المزوّد العام
  // احتياطياً) وتصنيفه — منفصلان عن provider.phone كي يعكسا اختيار المزوّد
  // الفعلي لهذا العرض تحديداً.
  final String? phone;
  final String contactType;

  const _ProviderSection({
    required this.provider,
    required this.phone,
    required this.contactType,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final dark = Theme.of(context).brightness == Brightness.dark;
    // زر الاتصال هنا يظهر ما دام هناك رقم ونوع التواصل ليس "واتساب فقط" — لو
    // كان "واتساب فقط" فالاتصال ليس وسيلة تواصل مفضّلة لهذا العرض.
    final hasPhone =
        phone != null && phone!.isNotEmpty && contactType != 'whatsapp';
    final hasSecondaryChannels = (provider.twitter?.isNotEmpty ?? false) ||
        (provider.instagram?.isNotEmpty ?? false) ||
        (provider.snapchat?.isNotEmpty ?? false) ||
        (provider.tiktok?.isNotEmpty ?? false) ||
        (provider.website?.isNotEmpty ?? false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('service_provider'.tr,
            style:
            robotoBold.copyWith(fontSize: 16, color: AppColors.textPrimary(context))),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: (provider.image?.isNotEmpty ?? false)
                  ? CustomImage(
                image: provider.image!,
                fit: BoxFit.cover,
                width: 52,
                height: 52,
              )
                  : Icon(Icons.storefront_rounded, size: 26, color: primary),
            ),
          ),
          title: Text(
            provider.name ?? '',
            style: robotoBold.copyWith(fontSize: 15, color: AppColors.textPrimary(context)),
          ),
          subtitle: hasPhone
              ? Text(phone!,
              style: robotoRegular.copyWith(
                  fontSize: 13, color: Colors.grey.shade500))
              : null,
          trailing: hasPhone
              ? Material(
            color: primary.withValues(alpha: dark ? 0.2 : 0.1),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _launch('tel:$phone'),
              child: Padding(
                padding: const EdgeInsets.all(11),
                child: Icon(Icons.call_rounded, size: 20, color: primary),
              ),
            ),
          )
              : null,
        ),
        if (hasSecondaryChannels) ...[
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (provider.twitter?.isNotEmpty ?? false)
                _ContactChip(
                  label: 'twitter_x_label'.tr,
                  icon: Icons.alternate_email_rounded,
                  onTap: () => _launch('https://twitter.com/${provider.twitter}'),
                ),
              if (provider.instagram?.isNotEmpty ?? false)
                _ContactChip(
                  label: 'instagram_label'.tr,
                  icon: Icons.camera_alt_rounded,
                  onTap: () =>
                      _launch('https://instagram.com/${provider.instagram}'),
                ),
              if (provider.snapchat?.isNotEmpty ?? false)
                _ContactChip(
                  label: 'snapchat_label'.tr,
                  icon: Icons.camera_rounded,
                  onTap: () => _launch(
                      'https://www.snapchat.com/add/${provider.snapchat}'),
                ),
              if (provider.tiktok?.isNotEmpty ?? false)
                _ContactChip(
                  label: 'tiktok_label'.tr,
                  icon: Icons.music_note_rounded,
                  onTap: () =>
                      _launch('https://www.tiktok.com/@${provider.tiktok}'),
                ),
              if (provider.website?.isNotEmpty ?? false)
                _ContactChip(
                  label: 'website_label'.tr,
                  icon: Icons.language_rounded,
                  onTap: () => _launch(_ensureScheme(provider.website!)),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _ContactChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ContactChip({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F4F9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.textPrimary(context)),
            const SizedBox(width: 6),
            Text(label,
                style: robotoMedium.copyWith(
                    fontSize: 12, color: AppColors.textPrimary(context))),
          ],
        ),
      ),
    );
  }
}

// ─── شريط الـCTA السفلي الثابت: خلفية بيضاء + ظلّ علوي ناعم. السعر/الخصم
// يمين الصفّ (RTL) بعرضه الطبيعي، وزرّ "تواصل واتساب" الأساسي يملأ الباقي
// (~65-70% حسب طول نص السعر) يسارًا ─────────────────────────────────────────

class _StickyBottomBar extends StatelessWidget {
  final ServiceOffer service;
  final String phone;
  final String contactType;

  const _StickyBottomBar({
    required this.service,
    required this.phone,
    required this.contactType,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // النوع "اتصال فقط" يستبدل زر واتساب بزر اتصال — بقية الأنواع (واتساب/
    // كلاهما) تُبقي زر واتساب كما كان (زر الاتصال المستقل يظهر أصلاً بجانب
    // اسم المزوّد في _ProviderSection).
    final isCallOnly = contactType == 'call';

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              _PriceRow(service: service),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => _launch(
                      isCallOnly
                          ? 'tel:$phone'
                          : 'https://wa.me/${_cleanPhoneForWhatsapp(phone)}',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: Icon(isCallOnly ? Icons.call_rounded : Icons.chat_rounded,
                        size: 18),
                    label: Text(isCallOnly ? 'اتصال' : 'تواصل واتساب',
                        style: robotoBold.copyWith(fontSize: 14.5, color: Colors.white)),
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

// ─── شريط "ادفع الآن": يحلّ محل شريط الـCTA العادي عندما يكون العرض المعروض
// عرض المستخدم نفسه ولم يُدفع اشتراكه بعد (unpaid) أو فشل دفعه (failed) —
// يولّد رابط دفع جديد عبر resumePayment() (الرابط الأصلي المُرجَع عند إنشاء
// العرض صالح لساعتين فقط) ثم يفتح ServiceOfferPaymentScreen، بنفس نداء
// التنقّل المستخدم في معالج "إضافة خدمة" (add_property_service_offer_screen)
// عند أول دفعة ──────────────────────────────────────────────────────────────

class _PayNowBottomBar extends StatefulWidget {
  final ServiceOffer service;

  const _PayNowBottomBar({required this.service});

  @override
  State<_PayNowBottomBar> createState() => _PayNowBottomBarState();
}

class _PayNowBottomBarState extends State<_PayNowBottomBar> {
  bool _isLoading = false;

  Future<void> _payNow() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    final controller = Get.find<ServiceOfferController>();
    final result = await controller.resumePayment(widget.service.subscriptionNumber!);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null) {
      Get.toNamed(
        RouteHelper.getServiceOfferPaymentRoute(),
        arguments: {'url': result['url'], 'number': result['number']},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              _PriceRow(service: widget.service),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _payNow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                        : const Icon(Icons.payment_rounded, size: 18),
                    label: Text('pay_now'.tr,
                        style: robotoBold.copyWith(
                            fontSize: 14.5, color: Colors.white)),
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
