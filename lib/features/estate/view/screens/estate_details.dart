import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/features/estate/view/widgets/estate_broker_verification_card.dart';
import 'package:abaad_flutter/features/estate/view/widgets/estate_full_screen_gallery.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/map_details_view.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة تفاصيل العقار، بنمط "بيوت": معرض صور بملء الشاشة خلف صفحة قابلة
/// للسحب (DraggableScrollableSheet) تحوي السعر والإحصائيات والتفاصيل وبطاقة
/// الوسيط الموثّقة، وشريط تواصل ثابت أسفل الشاشة (واتساب/اتصال/إيميل).
class EstateDetails extends StatefulWidget {
  final Estate estate;

  const EstateDetails({super.key, required this.estate});

  @override
  State<EstateDetails> createState() => _EstateDetailsState();
}

class _EstateDetailsState extends State<EstateDetails> {
  @override
  void initState() {
    super.initState();
    Get.find<EstateController>().getEstateDetails(Estate(id: widget.estate.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<EstateController>(
        builder: (estateController) {
          final estate = estateController.estate;
          if (estate == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              Positioned.fill(child: EstateFullScreenGallery(estate: estate)),
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
                      color: const Color(0xFFF4F6F9),
                      child: _DetailsSheet(
                        estate: estate,
                        scrollController: scrollController,
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _ContactBar(estate: estate),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─── محتوى الصفحة القابلة للسحب ───────────────────────────────────────────────

class _DetailsSheet extends StatelessWidget {
  final Estate estate;
  final ScrollController scrollController;

  const _DetailsSheet({required this.estate, required this.scrollController});

  bool get _isLand => estate.categoryName == 'ارض' || estate.category == '5';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              _HeaderCard(estate: estate, isLand: _isLand, primary: primary),
              const SizedBox(height: 8),
              _LocationActionsCard(estate: estate),
              const SizedBox(height: 8),
              _DescriptionCard(estate: estate, primary: primary),
              const SizedBox(height: 8),
              _PropertyDetailsCard(estate: estate, primary: primary),
              EstateBrokerVerificationCard(estate: estate),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── رأس البطاقة: السعر + شارة التوثيق + الإحصائيات السريعة ──────────────────

class _HeaderCard extends StatelessWidget {
  final Estate estate;
  final bool isLand;
  final Color primary;

  const _HeaderCard({
    required this.estate,
    required this.isLand,
    required this.primary,
  });

  String? _bathroomsCount() {
    final list = estate.property ?? [];
    for (final p in list) {
      if ((p.name ?? '').contains('حمام')) return p.number;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final bathrooms = _bathroomsCount();
    final isVerifiedListing = (estate.adLicenseNumber ?? '').isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
            children: [
              if (isVerifiedListing)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.green.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'verified_info'.tr,
                        style: robotoBold.copyWith(
                          fontSize: 10,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Text(
                  estate.advertisementType ?? '',
                  textAlign: TextAlign.end,
                  style: robotoMedium.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                formatPrice(estate.price ?? '0'),
                style: robotoBold.copyWith(fontSize: 22, color: primary),
              ),
              const SizedBox(width: 6),
              Image.asset(
                'assets/image/riyals.png',
                width: 20,
                height: 20,
                color: primary,
              ),
              if (isLand && (estate.totalPrice ?? '').isNotEmpty) ...[
                const SizedBox(width: 14),
                Text(
                  '${'total_price'.tr}: ${formatPrice(estate.totalPrice!)}',
                  style: robotoMedium.copyWith(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              if (isLand) ...[
                const SizedBox(width: 6),
                Text(
                  'price_per_meter'.tr,
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          if ((estate.priceNegotiation ?? '').isNotEmpty)
            Text(
              estate.priceNegotiation == '1'
                  ? 'negotiable'.tr
                  : 'non_negotiable'.tr,
              style: robotoRegular.copyWith(
                fontSize: 12,
                color: Colors.grey.shade500,
              ),
            ),
          const SizedBox(height: 14),
          if (!isLand)
            Row(
              children: [
                if ((estate.numberOfRooms ?? '').isNotEmpty)
                  _QuickStat(
                    icon: Icons.bed_outlined,
                    label: 'bedroom'.tr,
                    value: estate.numberOfRooms!,
                  ),
                if (bathrooms != null && bathrooms.isNotEmpty)
                  _QuickStat(
                    icon: Icons.bathtub_outlined,
                    label: 'bathroom'.tr,
                    value: bathrooms,
                  ),
                if ((estate.space ?? '').isNotEmpty)
                  _QuickStat(
                    icon: Icons.square_foot_outlined,
                    label: 'space'.tr,
                    value: '${estate.space} ${'square_meter'.tr}',
                  ),
              ],
            )
          else if ((estate.space ?? '').isNotEmpty)
            _QuickStat(
              icon: Icons.square_foot_outlined,
              label: 'space'.tr,
              value: '${estate.space} ${'square_meter'.tr}',
            ),
          const SizedBox(height: 6),
          if ([
            estate.districts,
            estate.zoneNameAr,
            estate.city,
          ].any((s) => (s ?? '').isNotEmpty))
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    [estate.districts, estate.zoneNameAr, estate.city]
                        .where((s) => (s ?? '').isNotEmpty)
                        .join('، '),
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _QuickStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$value ${label.isNotEmpty ? label : ''}',
              style: robotoMedium.copyWith(fontSize: 12.5),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── الاتجاهات / عرض على الخريطة ──────────────────────────────────────────────

class _LocationActionsCard extends StatelessWidget {
  final Estate estate;

  const _LocationActionsCard({required this.estate});

  Future<void> _openDirections() async {
    final lat = estate.latitude;
    final lng = estate.longitude;
    if ((lat ?? '').isEmpty || (lng ?? '').isEmpty) return;
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    if ((estate.latitude ?? '').isEmpty || (estate.longitude ?? '').isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              _ActionChip(
                icon: Icons.directions_outlined,
                label: 'directions'.tr,
                onTap: _openDirections,
              ),
              const SizedBox(width: 10),
              _ActionChip(
                icon: Icons.map_outlined,
                label: 'view_on_map'.tr,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: const MapDetailsView(fromView: true),
          ),
        ),
      ],
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: robotoMedium.copyWith(fontSize: 12.5, color: primary),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── العنوان والوصف ────────────────────────────────────────────────────────────

class _DescriptionCard extends StatelessWidget {
  final Estate estate;
  final Color primary;

  const _DescriptionCard({required this.estate, required this.primary});

  @override
  Widget build(BuildContext context) {
    final hasShort = (estate.shortDescription ?? '').isNotEmpty;
    final hasLong = (estate.longDescription ?? '').isNotEmpty;
    if (!hasShort && !hasLong) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          if (hasShort) ...[
            Text(
              estate.shortDescription!,
              style: robotoBold.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 10),
          ],
          if (hasLong)
            Text(
              estate.longDescription!,
              style: robotoRegular.copyWith(
                fontSize: 13.5,
                height: 1.6,
                color: Colors.grey.shade700,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── تفاصيل العقار: جدول ديناميكي بدون تكرار ──────────────────────────────────

class _PropertyDetailsCard extends StatelessWidget {
  final Estate estate;
  final Color primary;

  const _PropertyDetailsCard({required this.estate, required this.primary});

  List<MapEntry<String, String>> _rows() {
    final entries = <MapEntry<String, String>>[];
    void add(String labelKey, String? value) {
      if (value != null && value.isNotEmpty) {
        entries.add(MapEntry(labelKey.tr, value));
      }
    }

    add('property_type', estate.categoryNameAr ?? estate.categoryName);
    add('zone', estate.zoneNameAr);
    add('city', estate.city);
    add('district', estate.districts);
    add('advertisement_type', estate.advertisementType);
    add('date_of_publication', estate.createdAt);
    add('ad_license_number', estate.adLicenseNumber);
    add('fal_license_number', estate.licenseNumber);
    add('deed_number', estate.deedNumber);
    add('plan_number', estate.planNumber);
    add('brokerage_marketing_license', estate.brokerageAndMarketingLicenseNumber);
    add('title_deed_type_name', estate.titleDeedTypeName);
    add('main_land_use_type', estate.mainLandUseTypeName);
    add('land_number', estate.landNumber);
    add('north_limit', estate.northLimit);
    add('east_limit', estate.eastLimit);
    add('west_limit', estate.westLimit);
    add('south_limit', estate.southLimit);
    add('street_width', estate.streetWidth);
    add('property_face', estate.propertyFace);
    add('obligations_on_property', estate.obligationsOnTheProperty);
    add('guarantees_and_duration', estate.guaranteesAndTheirDuration);
    add('location_description_deed', estate.locationDescriptionOnMOJDeed);
    if ((estate.propertyUtilities ?? []).isNotEmpty) {
      entries.add(
        MapEntry('property_utilities'.tr, estate.propertyUtilities!.join('، ')),
      );
    }

    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final rows = _rows();
    final endDate = estate.endDate;
    final isExpired = endDate != null && endDate.isNotEmpty
        ? (DateTime.tryParse(endDate)?.isBefore(DateTime.now()) ?? false)
        : null;

    if (rows.isEmpty && isExpired == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
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
          Row(
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
                'property_details'.tr,
                style: robotoBold.copyWith(fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isExpired != null)
            buildEndDateWithStatusBadge(
              context,
              label: 'end_date'.tr,
              value: endDate!,
              isExpired: isExpired,
            ),
          for (final row in rows)
            buildInfoTile(context, label: row.key, value: row.value),
        ],
      ),
    );
  }
}

// ─── شريط التواصل الثابت أسفل الشاشة ───────────────────────────────────────────

class _ContactBar extends StatelessWidget {
  final Estate estate;

  const _ContactBar({required this.estate});

  Future<void> _launch(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('an_error_occurred'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phone = estate.users?.phone ?? '';
    final email = estate.users?.email ?? '';
    if (phone.isEmpty && email.isEmpty) return const SizedBox.shrink();

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
            if (phone.isNotEmpty)
              _ContactButton(
                label: 'whatsapp'.tr,
                icon: Icons.chat_rounded,
                color: Colors.green.shade600,
                onTap: () => _launch(
                  context,
                  'https://wa.me/${phone.replaceAll('+', '').replaceAll(' ', '')}',
                ),
              ),
            if (phone.isNotEmpty) const SizedBox(width: 8),
            if (phone.isNotEmpty)
              _ContactButton(
                label: 'call'.tr,
                icon: Icons.call_rounded,
                color: Colors.blue.shade600,
                onTap: () => _launch(context, 'tel:$phone'),
              ),
            if (phone.isNotEmpty && email.isNotEmpty) const SizedBox(width: 8),
            if (email.isNotEmpty)
              _ContactButton(
                label: 'email'.tr,
                icon: Icons.email_outlined,
                color: Colors.indigo.shade600,
                onTap: () => _launch(context, 'mailto:$email'),
              ),
          ],
        ),
      ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: robotoMedium.copyWith(fontSize: 11.5, color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── دوال مشتركة (تُستخدم أيضاً بجدول تفاصيل العقار أعلاه) ─────────────────────

Widget buildInfoTile(BuildContext context, {String? label, required String value}) {
  return Container(
    constraints: const BoxConstraints(minHeight: 50),
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              label ?? '',
              style: robotoRegular.copyWith(
                fontSize: 12.5,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: robotoBold.copyWith(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                InkWell(
                  onTap: () {
                    FlutterClipboard.copy(value).then((_) {
                      showCustomSnackBar('copied'.tr, isError: false);
                    });
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildEndDateWithStatusBadge(
  BuildContext context, {
  String? label,
  required String value,
  required bool isExpired,
}) {
  return Container(
    constraints: const BoxConstraints(minHeight: 50),
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F8FA),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label ?? '',
            style: robotoRegular.copyWith(
              fontSize: 12.5,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: robotoBold.copyWith(fontSize: 13),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isExpired ? Colors.red : Colors.green,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isExpired ? 'inactive'.tr : 'active'.tr,
            style: robotoBold.copyWith(fontSize: 11, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

String formatPrice(String priceStr) {
  final num? price = num.tryParse(priceStr);
  if (price == null) return priceStr;

  if (price >= 1000000) {
    return '${(price / 1000000).toStringAsFixed(2)} ${'million'.tr}';
  } else if (price >= 1000) {
    return '${(price / 1000).toStringAsFixed(2)} ${'thousand'.tr}';
  }
  return price.toString();
}
