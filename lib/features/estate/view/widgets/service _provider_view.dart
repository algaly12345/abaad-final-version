import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// عرض مُحسّن لعروض مزودي الخدمة داخل صفحة تفاصيل العقار.
///
/// إضافات هذه النسخة عن السابقة:
/// - اسم مزود الخدمة ونوع العرض يظهران الآن في البطاقة نفسها (كانا غير
///   ظاهرين رغم توفرهما في الموديل: provider_name، offer_type).
/// - تاريخ انتهاء العرض (expiry_date) كشارة صغيرة إن وُجد.
/// - البطاقة أصبحت قابلة للضغط لفتح ورقة تفاصيل كاملة (Bottom Sheet)
///   تعرض كل الحقول المتاحة في الموديل + زرّي اتصال وواتساب مباشرين
///   لرقم مزود الخدمة (phone_provider) إن وُجد.
///
/// ملاحظة: تم الإبقاء على نفس أسماء الكلاسات الأصلية بالضبط
/// (ServiceProivderView و _ServiceProivderViewState) دون إضافة أي كلاس
/// جديد على مستوى الملف — كل الإضافات دوال خاصة داخل نفس الكلاس.
class ServiceProivderView extends StatefulWidget {
  final Estate estate;
  final bool fromView;

  const ServiceProivderView({
    super.key,
    required this.estate,
    required this.fromView,
  });

  @override
  State<ServiceProivderView> createState() => _ServiceProivderViewState();
}

class _ServiceProivderViewState extends State<ServiceProivderView> {
  final CarouselSliderController carouselController =
  CarouselSliderController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Get.find<EstateController>()
        .getEstateDetails(Estate(id: widget.estate.id));
  }

  @override
  Widget build(BuildContext context) {
    final bool isArabic = Get.locale?.languageCode == 'ar';
    final offers = widget.estate.serviceOffers;

    if (offers == null) {
      return _buildLoadingSkeleton(context);
    }

    if (offers.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final current = offers[currentIndex.clamp(0, offers.length - 1)];

    final String title = current.title ?? '';
    final String? description = current.description;
    final String? servicePrice = current.servicePrice;
    final String? discount = current.discount;
    final bool hasDiscount = (discount ?? '').isNotEmpty && discount != '0';
    final String providerName = (current.provider_name ?? '').trim();
    final String offerType = (current.offerType ?? '').trim();
    final String expiryDate = (current.expiryDate ?? '').trim();
    final String address = (current.address ?? '').trim();

    return GestureDetector(
      onTap: () => _showOfferDetailsSheet(context, current, theme, isArabic),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
        ),
        height: 190,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL + 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ============ خلفية بديلة ريثما تُحمَّل الصور ============
            Image.asset(
              Images.background_gray,
              fit: BoxFit.cover,
            ),

            // ============ الكاروسيل ============
            GetBuilder<SplashController>(
              builder: (splashController) {
                final baseUrl =
                    Get.find<SplashController>().configModel?.baseUrls?.provider ??
                        '';
                return CarouselSlider(
                  items: offers
                      .map(
                        (item) => CustomImage(
                      image: '$baseUrl/${item.image ?? ''}',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  )
                      .toList(),
                  carouselController: carouselController,
                  options: CarouselOptions(
                    scrollPhysics: const BouncingScrollPhysics(),
                    autoPlay: offers.length > 1,
                    autoPlayInterval: const Duration(seconds: 4),
                    aspectRatio: 2,
                    viewportFraction: 1,
                    height: 246,
                    onPageChanged: (index, reason) {
                      setState(() => currentIndex = index);
                    },
                  ),
                );
              },
            ),

            // ============ تدرّج لوني لقراءة أوضح للنصوص ============
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.18),
                      Colors.black.withOpacity(0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // ============ شارة نوع العرض أعلى يمين البطاقة ============
            if (offerType.isNotEmpty)
              Positioned(
                top: 10,
                right: 10,
                child: _buildPillBadge(
                  icon: Icons.sell_outlined,
                  color: Colors.black.withOpacity(0.45),
                  text: _localizedOfferType(offerType, isArabic),
                ),
              ),

            // ============ زر الخريطة أعلى يسار البطاقة (لو الإحداثيات
            // متوفرة وصالحة) — يفتح ديلوق الموقع مباشرة من غير المرور
            // بورقة التفاصيل الكاملة. ============
            if (_hasValidLocation(current))
              Positioned(
                top: 10,
                left: 10,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => _showLocationDialog(context, current, theme, isArabic),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.map_rounded,
                          size: 15, color: Colors.white),
                    ),
                  ),
                ),
              ),

            // ============ محتوى النص أسفل البطاقة ============
            Positioned(
              left: 12,
              right: 12,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // اسم مزود الخدمة
                  if (providerName.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.storefront_rounded,
                            size: 13, color: Colors.white.withOpacity(0.95)),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            providerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(
                              fontSize: 11.5,
                              color: Colors.white.withOpacity(0.95),
                              shadows: const [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                  if (providerName.isNotEmpty) const SizedBox(height: 3),

                  // عنوان العرض (Title)
                  if (title.isNotEmpty)
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        fontSize: 14,
                        color: Colors.white,
                        height: 1.2,
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 5,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),

                  // عنوان الموقع (Address) — إن وُجد
                  if (address.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 12, color: Colors.white.withOpacity(0.9)),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: 10.5,
                              color: Colors.white.withOpacity(0.9),
                              shadows: const [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 4),

                  // شارة السعر / الخصم + تاريخ الانتهاء + عداد الصور
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildPillBadge(
                        icon: hasDiscount
                            ? Icons.local_offer_rounded
                            : Icons.payments_rounded,
                        color: hasDiscount
                            ? const Color(0xFF2E9E5B)
                            : theme.primaryColor,
                        text: _priceOrDiscountLabel(
                          discount: discount,
                          servicePrice: servicePrice,
                          isArabic: isArabic,
                        ),
                      ),
                      if (expiryDate.isNotEmpty)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.event_outlined,
                                size: 12,
                                color: Colors.white.withOpacity(0.9)),
                            const SizedBox(width: 3),
                            Text(
                              isArabic ? 'حتى $expiryDate' : 'Until $expiryDate',
                              style: robotoRegular.copyWith(
                                fontSize: 10.5,
                                color: Colors.white.withOpacity(0.9),
                                shadows: const [
                                  Shadow(
                                    color: Colors.black87,
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (offers.length > 1)
                        Text(
                          '${currentIndex + 1}/${offers.length}',
                          style: robotoRegular.copyWith(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                            shadows: const [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),






                  if (description != null && description.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description.length > 90
                          ? '${description.substring(0, 90)}…'
                          : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        height: 1.4,
                        color: Colors.white.withOpacity(0.95),
                        shadows: const [
                          Shadow(
                            color: Colors.black87,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],


                  // زر "عرض التفاصيل" — سطر نصي بسيط متسق مع باقي محتوى
                  // البطاقة (أبيض بظل)، بدل زر عائم منفصل كان بيتراكب مع
                  // باقي العناصر.



                  if (offers.length > 1) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: offers.asMap().entries.map((entry) {
                        final bool isActive = currentIndex == entry.key;
                        return GestureDetector(
                          onTap: () =>
                              carouselController.animateToPage(entry.key),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            width: isActive ? 18 : 6,
                            height: 6,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.45),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],


                  const SizedBox(height: 7),

                  InkWell(
                    onTap: () =>
                        _showOfferDetailsSheet(context, current, theme, isArabic),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isArabic ? 'عرض التفاصيل' : 'View details',
                          style: robotoBold.copyWith(
                            fontSize: 11.5,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white.withOpacity(0.7),
                            shadows: const [
                              Shadow(
                                color: Colors.black87,
                                blurRadius: 4,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          isArabic
                              ? Icons.arrow_back_ios_new_rounded
                              : Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // ورقة تفاصيل العرض الكاملة (Bottom Sheet)
  // ==========================================================================

  /// تعرض كل الحقول المتاحة في ServiceOffers (النوع، السعر/الخصم، الوصف،
  /// تاريخ الانتهاء، مزود الخدمة) + زرّي اتصال وواتساب لرقم مزود الخدمة.
  void _showOfferDetailsSheet(
      BuildContext context, ServiceOffers offer, ThemeData theme, bool isArabic) {
    final bool hasDiscount =
        (offer.discount ?? '').isNotEmpty && offer.discount != '0';
    final String providerName = (offer.provider_name ?? '').trim();
    final String phone = (offer.phoneProvider ?? '').trim();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // صورة العرض + العنوان + اسم المزود
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CustomImage(
                      image:
                      '${Get.find<SplashController>().configModel?.baseUrls?.provider ?? ''}/${offer.image ?? ''}',
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (offer.title ?? '').isNotEmpty
                              ? offer.title!
                              : (isArabic ? 'عرض مرفق' : 'Attached offer'),
                          style: robotoBold.copyWith(
                              fontSize: 16, color: Colors.black87),
                        ),
                        if (providerName.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.storefront_rounded,
                                  size: 14, color: theme.primaryColor),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  providerName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: robotoMedium.copyWith(
                                    fontSize: 13,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // السعر / الخصم — بتسمية واضحة فوق القيمة تحدد نوعها فورًا
              Text(
                hasDiscount
                    ? (isArabic ? 'نوع العرض' : 'Offer type')
                    : (isArabic ? 'السعر' : 'Price'),
                style: robotoRegular.copyWith(
                  fontSize: 11.5,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: hasDiscount
                      ? const Color(0xFFFFF7ED)
                      : const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasDiscount
                        ? const Color(0xFFF59E0B).withOpacity(0.35)
                        : const Color(0xFF3B82F6).withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      hasDiscount
                          ? Icons.discount_rounded
                          : Icons.payments_outlined,
                      size: 18,
                      color: hasDiscount
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF1D4ED8),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _priceOrDiscountLabel(
                        discount: offer.discount,
                        servicePrice: offer.servicePrice,
                        isArabic: isArabic,
                      ),
                      style: robotoBold.copyWith(
                        fontSize: 15,
                        color: hasDiscount
                            ? const Color(0xFF9A3412)
                            : const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ),

              // الوصف
              if ((offer.description ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  offer.description!,
                  style: robotoRegular.copyWith(
                    fontSize: 13,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],

              // 🔹 زر "الموقع على الخريطة" — يظهر فقط لو خط الطول والعرض
              // موجودان وصالحان للتحويل لرقم.
              if (_hasValidLocation(offer)) ...[
                const SizedBox(height: 12),
                InkWell(
                  onTap: () => _showLocationDialog(context, offer, theme, isArabic),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F6FB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFDCE4F0)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.map_rounded,
                            size: 18, color: theme.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            (offer.address ?? '').isNotEmpty
                                ? offer.address!
                                : (isArabic
                                ? 'عرض الموقع على الخريطة'
                                : 'View location on map'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoMedium.copyWith(
                              fontSize: 12.5,
                              color: theme.primaryColor,
                            ),
                          ),
                        ),
                        Icon(Icons.chevron_left_rounded,
                            size: 18, color: theme.primaryColor),
                      ],
                    ),
                  ),
                ),
              ],

              // تفاصيل إضافية: نوع العرض + تاريخ الانتهاء
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if ((offer.offerType ?? '').isNotEmpty)
                    _buildDetailChip(
                      icon: Icons.sell_outlined,
                      label: _localizedOfferType(offer.offerType!, isArabic),
                    ),
                  if ((offer.expiryDate ?? '').isNotEmpty)
                    _buildDetailChip(
                      icon: Icons.event_outlined,
                      label: isArabic
                          ? 'ينتهي: ${offer.expiryDate}'
                          : 'Expires: ${offer.expiryDate}',
                    ),
                ],
              ),

              // زرّي اتصال وواتساب
              if (phone.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.call_outlined,
                        label: isArabic ? 'اتصال' : 'Call',
                        bg: const Color(0xFFEFF6FF),
                        border: const Color(0xFFBFDBFE),
                        iconColor: const Color(0xFF1D4ED8),
                        textColor: const Color(0xFF1E3A8A),
                        onTap: () => _makePhoneCall(phone, isArabic),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: isArabic ? 'واتساب' : 'WhatsApp',
                        bg: const Color(0xFFECFDF5),
                        border: const Color(0xFFA7F3D0),
                        iconColor: const Color(0xFF059669),
                        textColor: const Color(0xFF065F46),
                        onTap: () => _openWhatsApp(phone, offer, isArabic),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildDetailChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade700),
          const SizedBox(width: 5),
          Text(
            label,
            style: robotoMedium.copyWith(
                fontSize: 11, color: Colors.grey.shade800),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color border,
    required Color iconColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: robotoBold.copyWith(fontSize: 12, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber, bool isArabic) async {
    final String cleaned =
    phoneNumber.replaceAll(' ', '').replaceAll('-', '');
    final Uri phoneUri = Uri(scheme: 'tel', path: cleaned);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      showCustomSnackBar(
        isArabic ? 'تعذر فتح الاتصال' : 'Could not open the dialer',
        isError: true,
      );
    }
  }

  Future<void> _openWhatsApp(
      String phoneNumber, ServiceOffers offer, bool isArabic) async {
    final String cleaned = phoneNumber
        .replaceAll(' ', '')
        .replaceAll('+', '')
        .replaceAll('-', '');
    final String message = isArabic
        ? 'مرحبًا، أرغب بالاستفسار عن عرض "${offer.title ?? ''}"'
        : 'Hello, I would like to ask about the offer "${offer.title ?? ''}"';
    final Uri waUri = Uri.parse(
      'https://wa.me/$cleaned?text=${Uri.encodeComponent(message)}',
    );
    if (await canLaunchUrl(waUri)) {
      await launchUrl(waUri, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar(
        isArabic ? 'تعذر فتح واتساب' : 'Could not open WhatsApp',
        isError: true,
      );
    }
  }

  /// يتحقق أن خط الطول والعرض موجودان وصالحان للتحويل لأرقام حقيقية
  /// قبل عرض زر الخريطة — لتفادي فتح ديلوق فارغ أو كراش عند التحويل.
  bool _hasValidLocation(ServiceOffers offer) {
    final lat = double.tryParse((offer.latitude ?? '').trim());
    final lng = double.tryParse((offer.longitude ?? '').trim());
    return lat != null && lng != null;
  }

  /// ديلوق بسيط يعرض موقع الخدمة على خريطة جوجل بعلامة واحدة، مع عنوان
  /// الخدمة (إن وُجد) واسم مزود الخدمة أعلى الخريطة.
  void _showLocationDialog(
      BuildContext context, ServiceOffers offer, ThemeData theme, bool isArabic) {
    final double lat = double.parse((offer.latitude ?? '').trim());
    final double lng = double.parse((offer.longitude ?? '').trim());
    final LatLng position = LatLng(lat, lng);

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 420,
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: position,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('service_location'),
                    position: position,
                    infoWindow: InfoWindow(
                      title: (offer.title ?? '').isNotEmpty
                          ? offer.title
                          : (isArabic ? 'موقع الخدمة' : 'Service location'),
                      snippet: offer.address,
                    ),
                  ),
                },
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
              ),

              // شريط علوي بعنوان الخدمة وزر إغلاق
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 18, color: theme.primaryColor),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          (offer.address ?? '').isNotEmpty
                              ? offer.address!
                              : ((offer.title ?? '').isNotEmpty
                              ? offer.title!
                              : (isArabic
                              ? 'موقع الخدمة'
                              : 'Service location')),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: robotoMedium.copyWith(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(Icons.close_rounded,
                              size: 20, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  /// يبني نص شارة السعر/الخصم بوضوح تام: "خصم X%" باللون الأخضر عند وجود
  /// خصم فعلي، أو "السعر: X ريال" (بفواصل الآلاف) عند وجود سعر عادي، أو
  /// "عرض خاص" لو مفيش سعر ولا خصم مسجّل خالص. دالة موحّدة تُستخدم في
  /// السلايد وورقة التفاصيل معًا لضمان نفس التنسيق في المكانين.
  String _priceOrDiscountLabel({
    required String? discount,
    required String? servicePrice,
    required bool isArabic,
  }) {
    final bool hasDiscount = (discount ?? '').isNotEmpty && discount != '0';
    if (hasDiscount) {
      return isArabic ? 'خصم ${discount}%' : 'Discount ${discount}%';
    }
    if ((servicePrice ?? '').isNotEmpty) {
      final String formatted = _formatNumber(servicePrice!);
      return isArabic
          ? 'السعر: $formatted ريال'
          : 'Price: $formatted SAR';
    }
    return isArabic ? 'عرض خاص' : 'Special offer';
  }

  /// حقل offer_type يجي من السيرفر كنص خام (زي "Discount")، مش نص واجهة
  /// نتحكم فيه مباشرة، فبيفضل بنفس اللغة اللي السيرفر أرجعها بيها بغض
  /// النظر عن لغة التطبيق. هذه الدالة تترجم القيم الإنجليزية الشائعة
  /// المعروفة للعربية عند الحاجة، وترجع القيمة كما هي لو مش معروفة (بدل
  /// إخفائها أو التسبب بخطأ).
  String _localizedOfferType(String rawType, bool isArabic) {
    if (!isArabic) return rawType;

    final Map<String, String> knownTypes = {
      'discount': 'خصم',
      'sale': 'تخفيض',
      'special': 'عرض خاص',
      'special offer': 'عرض خاص',
      'promotion': 'عرض ترويجي',
      'offer': 'عرض',
      'free': 'مجاني',
      'gift': 'هدية',
      'cashback': 'استرداد نقدي',
      'new': 'جديد',
    };

    final String? match = knownTypes[rawType.trim().toLowerCase()];
    return match ?? rawType;
  }

  /// يضيف فواصل الآلاف لرقم نصي (مثال: "15000" → "15,000") لوضوح أكبر في
  /// عرض الأسعار. لو النص مش رقمًا صافيًا (فيه حروف مثلاً)، يُرجعه كما هو
  /// بدون أي تعديل بدل التسبب بخطأ.
  String _formatNumber(String raw) {
    final String trimmed = raw.trim();
    final num? value = num.tryParse(trimmed);
    if (value == null) return trimmed;

    final String intPart = value.truncate().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      final int posFromEnd = intPart.length - i;
      buffer.write(intPart[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) {
        buffer.write(',');
      }
    }
    return buffer.toString();
  }

  /// بأيقونة مصاحبة. دالة مساعدة داخل نفس الكلاس (وليست كلاسًا منفصلًا).
  Widget _buildPillBadge({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: robotoBold.copyWith(fontSize: 11, color: Colors.white),
          ),
        ],
      ),
    );
  }

  /// حالة تحميل بسيطة (Skeleton) بدل حاوية فارغة أثناء انتظار البيانات.
  /// دالة مساعدة داخل نفس الكلاس (وليست كلاسًا منفصلًا).
  Widget _buildLoadingSkeleton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: Dimensions.PADDING_SIZE_EXTRA_SMALL,
      ),
      height: 190,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL + 4),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 26,
        height: 26,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}