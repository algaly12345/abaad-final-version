import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// عرض مُحسّن لعروض مزودي الخدمة داخل صفحة تفاصيل العقار.
///
/// التحسينات الرئيسية عن النسخة السابقة:
/// - تدرّج لوني (Gradient) خلف النصوص بدل صناديق كحلية صلبة، لقراءة أوضح
///   فوق أي صورة دون حجب تفاصيلها.
/// - بطاقة موحّدة بحواف دائرية وظل ناعم بدل التصاق العنصر بالحواف.
/// - مؤشر نقاط (dots) بحركة سلسة (AnimatedContainer) لتنقّل أوضح بين العروض.
/// - شارة سعر/خصم بتصميم "Pill" بلون مميّز (أخضر للخصم، أساسي للسعر) —
///   مبنية داخل نفس الكلاس مباشرة (دالة خاصة) بدون إضافة أي كلاس جديد.
/// - معالجة آمنة للقيم الفارغة (بدون استخدام ! في أماكن قد تُسبب كراش).
/// - حالة تحميل (Skeleton بسيط) أثناء عدم توفر العروض بدل حاوية فارغة.
///
/// ملاحظة: تم الإبقاء على نفس أسماء الكلاسات الأصلية بالضبط
/// (ServiceProivderView و _ServiceProivderViewState) دون إضافة أي كلاس
/// مساعد جديد، بناءً على طلبك.
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
    final bool hasDiscount = discount != null;

    return Container(
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
                  height: 190,
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
                    Colors.black.withOpacity(0.15),
                    Colors.black.withOpacity(0.75),
                  ],
                  stops: const [0.0, 0.5, 1.0],
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
                // العنوان
                if (title.isNotEmpty)
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: robotoBold.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),

                const SizedBox(height: 4),

                // شارة السعر / الخصم (مبنية inline عبر _buildPillBadge)
                Row(
                  children: [
                    _buildPillBadge(
                      icon: hasDiscount
                          ? Icons.local_offer_rounded
                          : Icons.payments_rounded,
                      color: hasDiscount
                          ? const Color(0xFF2E9E5B)
                          : theme.primaryColor,
                      text: hasDiscount
                          ? 'خصم ${discount}%'
                          : (servicePrice != null
                          ? '$servicePrice ريال'
                          : 'عرض خاص'),
                    ),
                    const SizedBox(width: 8),
                    if (offers.length > 1)
                      Text(
                        '${currentIndex + 1}/${offers.length}',
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.85),
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
                      color: Colors.white.withOpacity(0.92),
                    ),
                  ),
                ],

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
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// شارة صغيرة بشكل "حبّة" (Pill) لعرض السعر أو الخصم بأيقونة مصاحبة.
  /// دالة مساعدة داخل نفس الكلاس (وليست كلاسًا منفصلًا).
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