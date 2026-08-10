import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/zones/controller/zone_controller.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/features/filter/view/widgets/slider_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abaad_flutter/features/estate/data/models/district_model.dart';
import '../widgets/popular_filter_list.dart';

/// ملاحظة: نفس أسماء الكلاسات والدوال الأصلية بالكامل. إصلاحان فقط:
///
/// 1) اللغة كانت تُحدَّد عبر `LocalizationController.isLtr`، وهذه القيمة لم
///    تكن تتزامن دائمًا مع اللغة الفعلية المطبَّقة على التطبيق (`Get.locale`)
///    — فكان الديلوق يظل إنجليزيًا حتى بعد تغيير اللغة للعربية. تم توحيد
///    الكشف عن اللغة بنفس الطريقة المستخدمة في باقي شاشات التطبيق
///    (`Get.locale?.languageCode == 'ar'`).
///
/// 2) زر الإغلاق وزر "تطبيق الفلتر" كانا يستخدمان `Navigator.pop(context)`
///    لإغلاق الديلوق، لكن هذه الشاشة تُفتح عبر `Get.dialog(FiltersScreen())`
///    (تعتمد على الـ Navigator الخاص بـ GetX وليس Navigator الأساسي
///    للتطبيق)، لذلك `Navigator.pop` كان أحيانًا لا يجد الـ route الصحيح
///    ليغلقه. تم استبداله بـ `Get.back()` — الطريقة الصحيحة لإغلاق أي
///    ديلوق/شاشة فُتحت عبر GetX.
class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;

  List<PopularFilterListData> accomodationListData =
      PopularFilterListData.accomodationList;

  late String type_properties;
  String? ctiy_name;
  String? districts;
  late int zone_id;
  late String zone_name;

  double distValue = 0;

  /// حالتا تحميل محليتان: بتظهر مؤشر دوّار بدل الـ dropdown أثناء جلب
  /// المدن (بعد اختيار المنطقة) أو جلب الأحياء (بعد اختيار المدينة) —
  /// كانت هذه العمليات تحدث بصمت تمامًا بدون أي مؤشر تحميل.
  bool _isLoadingCities = false;
  bool _isLoadingDistricts = false;
  int _value1 = 0;
  List<String> selectedFilters = [];
  String selectedPropertyType = 'بيع';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  /// تم توحيد الكشف عن اللغة عبر `Get.locale` (نفس الطريقة المستخدمة في
  /// باقي شاشات التطبيق) بدل `LocalizationController.isLtr` التي كانت لا
  /// تتزامن دائمًا مع اللغة الفعلية المطبَّقة، فيظل الديلوق إنجليزيًا حتى
  /// بعد تبديل اللغة للعربية.
  bool get isArabic => Get.locale?.languageCode == 'ar';

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    Get.find<ZoneController>().getCategoryList();
    Get.find<CategoryController>().getSubCategoryList("0");
    ctiy_name = "";

    int offset = 1;
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent &&
          !Get.find<CategoryController>().isLoading) {
        final int? rawPageSize = Get.find<CategoryController>().pageSize;
        if (rawPageSize == null) return;
        int pageSize = (rawPageSize / 10).ceil();
        if (offset < pageSize) {
          offset++;
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryProductList(
            0, "0", 0, '0', "0", "0", "0",
            reload: false, arPath: 0, sv: 0, type: "",
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    final primaryColor = theme.primaryColor;

    List<String> filters = ['it_includes_offers'.tr, 'virtual_ture'.tr];

    return GetBuilder<EstateController>(builder: (restController) {
      return GetBuilder<ZoneController>(builder: (zoneController) {
        return GetBuilder<CategoryController>(builder: (categoryController) {

          if (zoneController.subCategoryList == null) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            );
          }

          return Scaffold(
            backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
            body: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ─── AppBar ─────────────────────────────────────
                  _buildAppBar(primaryColor),

                  // ─── Body ───────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── نوع العملية (بيع / إيجار) ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  isArabic ? 'نوع العملية' : 'Operation Type',
                                  Icons.swap_horiz_rounded,
                                  primaryColor,
                                ),
                                const SizedBox(height: 12),
                                _buildToggleButtons(primaryColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── نوع العقار ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  'type_property'.tr,
                                  Icons.home_work_rounded,
                                  primaryColor,
                                ),
                                const SizedBox(height: 12),

                                // Sub categories
                                if (categoryController.subCategoryList != null)
                                  _buildHorizontalChips(
                                    items: categoryController.subCategoryList!
                                        .map((e) => isArabic
                                        ? e.nameAr ?? ''
                                        : e.name ?? 'all')
                                        .toList(),
                                    images: categoryController.subCategoryList!
                                        .map((e) =>
                                    '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${e.image}')
                                        .toList(),
                                    selectedIndex:
                                    categoryController.subCategoryIndex,
                                    primaryColor: primaryColor,
                                    onTap: (index) async {
                                      SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                      int? savedZoneId =
                                      prefs.getInt('zone_id');
                                      categoryController.setSubCategoryIndex(
                                          index, savedZoneId ?? 0);
                                      int selectedId = categoryController
                                          .subCategoryList![index].id!;
                                      await prefs.setInt(
                                          'sub_category_id', selectedId);
                                    },
                                    showImage: true,
                                  ),

                                const SizedBox(height: 12),

                                // Main categories
                                if (categoryController.categoryList != null)
                                  _buildHorizontalChips(
                                    items: categoryController.categoryList!
                                        .map((e) => isArabic
                                        ? e.nameAr ?? ''
                                        : e.name ?? '')
                                        .toList(),
                                    images: categoryController.categoryList!
                                        .map((e) =>
                                    '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${e.image}')
                                        .toList(),
                                    selectedIndex: categoryController
                                        .categoryList!
                                        .indexWhere((e) =>
                                    e.id ==
                                        restController.categoryIndex),
                                    primaryColor: primaryColor,
                                    onTap: (index) {
                                      restController.setCategoryIndex(
                                          categoryController
                                              .categoryList![index].id ?? 0);
                                      restController.setCategoryPostion(
                                          int.parse(categoryController
                                              .categoryList?[index].position ??
                                              "0"));
                                      setState(() {
                                        type_properties = categoryController
                                            .categoryList![index].name ?? "";
                                      });
                                    },
                                    showImage: true,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── الموقع ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  isArabic ? 'الموقع' : 'Location',
                                  Icons.location_on_rounded,
                                  primaryColor,
                                ),
                                const SizedBox(height: 12),

                                // المنطقة و المدينة جنباً إلى جنب
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStyledDropdown(
                                        label: 'zone'.tr,
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        child: DropdownButton<int>(
                                          value: _value1,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          dropdownColor: isDark
                                              ? const Color(0xFF2A2A3C)
                                              : Colors.white,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 14,
                                          ),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: primaryColor,
                                          ),
                                          items: zoneController.zoneIds
                                              .map((int value) {
                                            final idx = zoneController.zoneIds
                                                .indexOf(value);
                                            return DropdownMenuItem<int>(
                                              value: idx,
                                              child: Text(
                                                value != 0
                                                    ? (isArabic
                                                    ? zoneController
                                                    .categoryList![
                                                idx - 1]
                                                    .nameAr
                                                    : zoneController
                                                    .categoryList![
                                                idx - 1]
                                                    .nameEn)
                                                    : (isArabic
                                                    ? 'اختر المنطقة'
                                                    : 'Select Region'),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (int? value) async {
                                            setState(() {
                                              _value1 = value!;
                                              _isLoadingCities = true;
                                            });
                                            zoneController.setCategoryIndex(
                                                value!, true);
                                            await zoneController.getSubCategoryList(
                                                value != 0
                                                    ? zoneController
                                                    .categoryList![
                                                value - 1]
                                                    .regionId
                                                    : 0);
                                            if (mounted) {
                                              setState(
                                                      () => _isLoadingCities = false);
                                            }
                                            SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                            if (value != 0) {
                                              final selectedZone =
                                                  zoneController.categoryList![
                                                      value - 1];
                                              await prefs.setString(
                                                  'zone_name',
                                                  isArabic
                                                      ? selectedZone.nameAr
                                                      : selectedZone.nameEn);
                                              await prefs.setInt(
                                                  'zone_id',
                                                  selectedZone.regionId);
                                              // نحفظ موقع المنطقة أيضًا حتى
                                              // تقدر شاشة الخريطة تنقل
                                              // الكاميرا لهذا الموقع مباشرة
                                              // بعد تطبيق الفلتر.
                                              final double? zoneLat =
                                                  double.tryParse(
                                                      selectedZone.latitude);
                                              final double? zoneLng =
                                                  double.tryParse(
                                                      selectedZone.longitude);
                                              if (zoneLat != null) {
                                                await prefs.setDouble(
                                                    'filter_zone_lat',
                                                    zoneLat);
                                              }
                                              if (zoneLng != null) {
                                                await prefs.setDouble(
                                                    'filter_zone_lng',
                                                    zoneLng);
                                              }
                                            } else {
                                              await prefs.remove('zone_name');
                                              await prefs.remove('zone_id');
                                              await prefs
                                                  .remove('filter_zone_lat');
                                              await prefs
                                                  .remove('filter_zone_lng');
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _isLoadingCities
                                          ? _buildStyledDropdown(
                                        label: 'city'.tr,
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        child: SizedBox(
                                          height: 40,
                                          child: Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child:
                                              CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                AlwaysStoppedAnimation<
                                                    Color>(
                                                  primaryColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                          : _buildStyledDropdown(
                                        label: 'city'.tr,
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        child: DropdownButton<int>(
                                          value:
                                          zoneController.subCategoryIndex,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          dropdownColor: isDark
                                              ? const Color(0xFF2A2A3C)
                                              : Colors.white,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 14,
                                          ),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: primaryColor,
                                          ),
                                          items: zoneController.cityIds
                                              .map((int value) {
                                            final idx = zoneController.cityIds
                                                .indexOf(value);
                                            return DropdownMenuItem<int>(
                                              value: idx,
                                              child: Text(
                                                value != 0
                                                    ? (isArabic
                                                    ? zoneController
                                                    .subCategoryList![
                                                idx - 1]
                                                    .nameAr
                                                    : zoneController
                                                    .subCategoryList![
                                                idx - 1]
                                                    .nameEn)
                                                    : (isArabic
                                                    ? 'اختر المدينة'
                                                    : 'Select City'),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (int? value) async {
                                            zoneController
                                                .setSubCategoryIndex(
                                                value!, true);
                                            setState(
                                                    () => _isLoadingDistricts = true);
                                            await zoneController
                                                .getSubSubCategoryList(
                                                value != 0
                                                    ? zoneController
                                                    .subCategoryList![
                                                value - 1]
                                                    .cityId
                                                    : 0);
                                            if (mounted) {
                                              setState(() =>
                                              _isLoadingDistricts = false);
                                            }
                                            ctiy_name = zoneController
                                                .subCategoryList![value - 1]
                                                .nameAr;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // الحي
                                Row(
                                  children: [
                                    Text(
                                      'district'.tr,
                                      style: robotoRegular.copyWith(
                                        fontSize: Dimensions.fontSizeSmall,
                                        color: theme.hintColor,
                                      ),
                                    ),
                                    if (_isLoadingDistricts) ...[
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                            primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () => _showDistrictPicker(
                                      context, zoneController, primaryColor),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF2A2A3C)
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (districts ?? '').isNotEmpty
                                            ? primaryColor.withOpacity(0.5)
                                            : (isDark
                                            ? Colors.white12
                                            : Colors.grey.shade200),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (districts ?? '').isNotEmpty
                                              ? districts!
                                              : (isArabic
                                              ? 'اختر الحي'
                                              : 'Select District'),
                                          style: TextStyle(
                                            color: (districts ?? '').isEmpty
                                                ? Colors.grey[400]
                                                : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── المساحة ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  'space'.tr,
                                  Icons.square_foot_rounded,
                                  primaryColor,
                                ),
                                SliderView(
                                  distValue: distValue,
                                  onChangedistValue: (double value) {
                                    setState(() => distValue = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── خيارات إضافية ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  isArabic ? 'خيارات إضافية' : 'Extra Options',
                                  Icons.tune_rounded,
                                  primaryColor,
                                ),
                                const SizedBox(height: 8),
                                ...filters.map((filter) {
                                  final isSelected =
                                  selectedFilters.contains(filter);
                                  return _buildModernSwitch(
                                    label: filter,
                                    value: isSelected,
                                    primaryColor: primaryColor,
                                    isDark: isDark,
                                    onChanged: (bool val) {
                                      setState(() {
                                        if (val) {
                                          selectedFilters.add(filter);
                                        } else {
                                          selectedFilters.remove(filter);
                                        }
                                      });
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),

                  // ─── Apply Button ────────────────────────────────
                  _buildApplyButton(primaryColor, categoryController),
                ],
              ),
            ),
          );
        });
      });
    });
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر الإغلاق — Get.back() بدل Navigator.pop(context) لأن
              // هذه الشاشة تُفتح عبر Get.dialog(FiltersScreen())، والذي
              // يعتمد على الـ Navigator الخاص بـ GetX. Navigator.pop قد لا
              // يجد الـ route المطابق فيبدو الزر معطّلًا.
              IconButton(
                onPressed: () => Get.back(),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                ),
              ),

              // العنوان
              Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'filter'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // زر إعادة الضبط
              TextButton(
                onPressed: () {
                  setState(() {
                    _value1 = 0;
                    ctiy_name = "";
                    districts = null;
                    distValue = 0;
                    selectedFilters.clear();
                    selectedPropertyType = isArabic ? 'بيع' : 'Sale';
                  });
                },
                child: Text(
                  isArabic ? 'إعادة' : 'Reset',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section Card ────────────────────────────────────────────────────────────
  Widget _buildSectionCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ─── Section Title ───────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  // ─── Toggle Buttons (بيع / إيجار) ───────────────────────────────────────────
  Widget _buildToggleButtons(Color primaryColor) {
    final options = isArabic
        ? [('بيع', 'بيع'), ('إيجار', 'إيجار')]
        : [('Sale', 'Sale'), ('Rent', 'Rent')];

    return Row(
      children: options.map((opt) {
        final isSelected = selectedPropertyType == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedPropertyType = opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  left: opt.$1 == options[0].$1 ? 0 : 6,
                  right: opt.$1 == options[0].$1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  opt.$2,
                  style: robotoMedium.copyWith(
                    color: isSelected ? Colors.white : primaryColor,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Horizontal Chips ────────────────────────────────────────────────────────
  Widget _buildHorizontalChips({
    required List<String> items,
    required List<String> images,
    required int selectedIndex,
    required Color primaryColor,
    required Function(int) onTap,
    bool showImage = false,
  }) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    items[index],
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isSelected ? Colors.white : primaryColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (showImage && index != 0) ...[
                    const SizedBox(width: 6),
                    CustomImage(
                      image: images[index],
                      height: 20,
                      width: 20,
                      colors: isSelected ? Colors.white : primaryColor,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Styled Dropdown Wrapper ─────────────────────────────────────────────────
  Widget _buildStyledDropdown({
    required String label,
    required bool isDark,
    required Color primaryColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A3C) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  // ─── Modern Switch ───────────────────────────────────────────────────────────
  Widget _buildModernSwitch({
    required String label,
    required bool value,
    required Color primaryColor,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  // ─── District Picker ─────────────────────────────────────────────────────────
  Future<void> _showDistrictPicker(
      BuildContext context,
      dynamic zoneController,
      Color primaryColor,
      ) async {
    final selected = await showModalBottomSheet<DistrictModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        TextEditingController searchController = TextEditingController();
        List<DistrictModel> filteredList =
        List.from(zoneController.subSubCategoryList ?? []);

        return StatefulBuilder(
          builder: (context, setModalState) => Container(
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? const Color(0xFF1E1E2C)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Icon(Icons.location_city_rounded,
                          color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'اختر الحي' : 'Select District',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: isArabic
                          ? 'ابحث عن الحي...'
                          : 'Search district...',
                      prefixIcon:
                      Icon(Icons.search_rounded, color: primaryColor),
                      filled: true,
                      fillColor: Get.isDarkMode
                          ? const Color(0xFF2A2A3C)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: primaryColor, width: 1.5),
                      ),
                    ),
                    onChanged: (query) {
                      setModalState(() {
                        filteredList = (zoneController.subSubCategoryList ?? <DistrictModel>[])
                            .where((DistrictModel d) =>
                            d.nameAr.toLowerCase().contains(query.toLowerCase()))
                            .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            primaryColor.withOpacity(0.1),
                            radius: 16,
                            child: Text(
                              item.nameAr.isNotEmpty
                                  ? item.nameAr[0]
                                  : '',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            isArabic ? item.nameAr : item.nameEn,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          // ملاحظة: هذا Navigator.pop سليم كما هو، لأنه
                          // خاص بـ showModalBottomSheet العادي (Flutter
                          // القياسي) وليس بديلوق GetX — لا علاقة له بمشكلة
                          // زر الإغلاق الرئيسي.
                          onTap: () =>
                              Navigator.pop(context, item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      final index = zoneController.subSubCategoryList!
          .indexWhere((e) => e.districtId == selected.districtId);
      if (index != -1) {
        zoneController.setSubSubCategoryIndex(index + 1, true);
        setState(() => districts = isArabic
            ? selected.nameAr
            : selected.nameEn);
      }
    }
  }

  // ─── Apply Button ────────────────────────────────────────────────────────────
  Widget _buildApplyButton(
      Color primaryColor, dynamic categoryController) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? const Color(0xFF1E1E2C)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () async {
            SharedPreferences prefs =
            await SharedPreferences.getInstance();
            int? savedZoneId = prefs.getInt('zone_id');
            int? categoryId = prefs.getInt('sub_category_id');

            Get.find<CategoryController>().setFilterIndex(
              savedZoneId ?? 0,
              categoryId ?? 0,
              ctiy_name ?? "",
              districts ?? "",
              distValue ~/ 10,
              selectedFilters.join(', ') == 'virtual_ture'.tr ? 1 : 0,
              selectedFilters.join(', ') == 'it_includes_offers'.tr
                  ? 1
                  : 0,
              selectedPropertyType,
            );
            // Get.back() بدل Navigator.pop(context) لنفس سبب زر الإغلاق —
            // الديلوق فُتح عبر Get.dialog، والإغلاق الصحيح له عبر GetX.
            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'تطبيق الفلتر' : 'Apply Filter',
                style: robotoMedium.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}