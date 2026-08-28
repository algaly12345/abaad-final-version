import 'dart:async';

import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/details_dilog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة بحث شامل عن العقارات — بحث فوري أثناء الكتابة (Debounced)، حالة
/// تحميل، حالة "لا نتائج"، وكل نتيجة كبطاقة أنيقة (صورة + سعر + موقع).
///
/// طريقة الاستخدام: Get.to(() => const EstateSearchScreen())
/// أو Get.dialog(const EstateSearchScreen()) لو تفضّلها كديلوق بدل صفحة
/// كاملة — الودجت مصمم يشتغل بالطريقتين.
class EstateSearchScreen extends StatefulWidget {
  const EstateSearchScreen({super.key});

  @override
  State<EstateSearchScreen> createState() => _EstateSearchScreenState();
}

class _EstateSearchScreenState extends State<EstateSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // فتح لوحة المفاتيح تلقائيًا فور دخول الشاشة — تجربة بحث سلسة.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// بحث مؤجّل (Debounce) — بينتظر 450 مللي ثانية بعد آخر حرف يكتبه
  /// المستخدم قبل ما يبعت النداء الفعلي، عشان مايبعتش نداء API مع كل حرف.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      Get.find<EstateController>().searchEstateByName(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    final bool isArabic = currentLocale?.languageCode == 'ar';
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(context, primaryColor, isArabic),
            Expanded(
              child: GetBuilder<EstateController>(
                builder: (estateController) {
                  return _buildBody(
                    context,
                    estateController,
                    primaryColor,
                    isArabic,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // شريط البحث العلوي
  // ==========================================================================

  Widget _buildSearchBar(
      BuildContext context, Color primaryColor, bool isArabic) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_rounded,
                color: primaryColor,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: primaryColor, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      textInputAction: TextInputAction.search,
                      onChanged: _onQueryChanged,
                      onSubmitted: (value) {
                        _debounce?.cancel();
                        Get.find<EstateController>().searchEstateByName(value);
                      },
                      decoration: InputDecoration(
                        hintText: isArabic
                            ? 'ابحث عن عقار (اسم، مدينة، حي...)'
                            : 'Search a property (name, city...)',
                        hintStyle: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Colors.grey[500],
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      style: robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchController,
                    builder: (context, value, _) {
                      if (value.text.isEmpty) return const SizedBox();
                      return GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _debounce?.cancel();
                          Get.find<EstateController>().clearEstateSearch();
                        },
                        child: Icon(Icons.close_rounded,
                            size: 18, color: Colors.grey[500]),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // محتوى النتائج — حالات: البداية، التحميل، لا نتائج، نتائج
  // ==========================================================================

  Widget _buildBody(
      BuildContext context,
      EstateController estateController,
      Color primaryColor,
      bool isArabic,
      ) {
    final String query = _searchController.text.trim();

    // الحالة الابتدائية: لسه المستخدم مكتبش حاجة
    if (query.isEmpty && estateController.searchResults == null) {
      return _buildEmptyState(
        icon: Icons.travel_explore_rounded,
        title: isArabic ? 'ابحث عن عقارك' : 'Find your property',
        subtitle: isArabic
            ? 'اكتب اسم المدينة أو الحي أو أي وصف للعقار'
            : 'Type a city, district, or property description',
        primaryColor: primaryColor,
      );
    }

    // حالة التحميل
    if (estateController.isSearchingEstates) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      );
    }

    final List<Estate>? results = estateController.searchResults;

    // حالة "لا نتائج"
    if (results != null && results.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        title: isArabic ? 'لا توجد نتائج' : 'No results found',
        subtitle: isArabic
            ? 'جرّب كلمة بحث مختلفة'
            : 'Try a different search term',
        primaryColor: primaryColor,
      );
    }

    if (results == null) return const SizedBox();

    // النتائج
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        return _buildResultCard(context, results[index], primaryColor, isArabic);
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color primaryColor,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: primaryColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: robotoBold.copyWith(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // بطاقة نتيجة واحدة
  // ==========================================================================

  /// يجيب تفاصيل العقار الكاملة من السيرفر أولًا (await كامل)، وبس بعد
  /// ما تخلص تحميل، بيفتح ديلوق التفاصيل — بدل ما يفتح الديلوق فورًا
  /// ببيانات ناقصة (Estate(id: ...) بس) ويستنى التحديث يوصله لاحقًا، وهو
  /// ما كان يسبب ظهور "الموقع غير متوفر" وبيانات ناقصة عمومًا.
  Future<void> _openEstateDialog(int estateId) async {
    final estateController = Get.find<EstateController>();

    // مؤشر تحميل بسيط أثناء انتظار التفاصيل الكاملة.
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    final Estate estate = await estateController.getEstateDetails(
      Estate(id: estateId),
    );

    if (Get.isDialogOpen == true) {
      Get.back(); // يقفل مؤشر التحميل
    }

    Get.dialog(DettailsDilog(estate: estate), barrierDismissible: true);
  }

  Widget _buildResultCard(
      BuildContext context, Estate estate, Color primaryColor, bool isArabic) {
    final String baseUrl =
        Get.find<SplashController>().configModel?.baseUrls?.estateImageUrl ??
            '';
    final String? firstImage =
    (estate.images != null && estate.images!.isNotEmpty)
        ? estate.images!.first
        : null;

    final String priceText = (estate.categoryName == "ارض"
        ? estate.totalPrice
        : estate.price) ??
        '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          if (estate.userId != null) {
            Get.find<UserController>().getUserInfoByID(estate.userId!);
            Get.find<UserController>()
                .getEstateByUser(1, false, estate.userId!);
          }
          if (estate.id != null) {
            await _openEstateDialog(estate.id!);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomImage(
                  image: firstImage != null ? '$baseUrl/$firstImage' : '',
                  height: 84,
                  width: 84,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((estate.title ?? '').isNotEmpty)
                      Text(
                        estate.title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(
                          fontSize: 13.5,
                          color: Colors.black87,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (priceText.isNotEmpty)
                      Text(
                        isArabic ? '$priceText ريال' : '$priceText SAR',
                        style: robotoBold.copyWith(
                          fontSize: 14,
                          color: primaryColor,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            size: 13, color: Colors.grey[500]),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            [
                              if ((estate.city ?? '').isNotEmpty) estate.city,
                              if ((estate.districts ?? '').isNotEmpty)
                                estate.districts,
                            ].whereType<String>().join(' - '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: robotoRegular.copyWith(
                              fontSize: 11.5,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if ((estate.advertisementType ?? '').isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          estate.advertisementType!,
                          style: robotoMedium.copyWith(
                            fontSize: 10.5,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                isArabic
                    ? Icons.arrow_back_ios_new_rounded
                    : Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}