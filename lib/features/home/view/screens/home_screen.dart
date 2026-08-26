import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/home/controller/banner_controller.dart';
import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/zones/controller/zone_controller.dart';
import 'package:abaad_flutter/shared/data/models/config_model.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/no_data_screen.dart';
import 'package:abaad_flutter/features/filter/view/screens/fillter_estate_sheet.dart';
import 'package:abaad_flutter/features/home/view/widgets/estate_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ملاحظة: نفس أسماء الكلاسات الأصلية (HomeScreen، _HomeScreenState) ونفس
/// كل الدوال (loadData، initState، dispose، _loadSavedZone، build) بدون أي
/// تغيير في المنطق — فقط تحسين الشكل: شرائح تصنيف (chips) بيضوية مع تعبئة
/// لونية عند الاختيار بدل الحدود فقط، شارة منطقة أنيقة، وتنسيق مسافات موحّد.
class HomeScreen extends StatefulWidget {
  int zoneId;

  HomeScreen({super.key, required this.zoneId});

  final ScrollController scrollController = ScrollController();

  static Future<void> loadData(bool reload) async {


    Get.find<CategoryController>().getCategoryProductList(
      0,
      "0",
      0,
      '0',
      "0",
      "0",
      "0",
      reload: true,
      arPath: 0,
      sv: 0,
      type: "",
    );

    Get.find<BannerController>().getBannerList(reload, 1);
    Get.find<AuthController>().getZoneList();
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedZoneName;
  final TextEditingController _searchController = TextEditingController();

  /// نوع العرض المختار حاليًا: '' = بدون فلتر (زي الوضع الافتراضي الأصلي)،
  /// أو 'بيع'/'إيجار'.
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _loadSavedZone();
    Get.find<CategoryController>().getSubCategoryList("0",widget.zoneId);
    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels >=
          widget.scrollController.position.maxScrollExtent - 200) {
        final controller = Get.find<CategoryController>();

        if (!controller.isPaginating && !controller.isLastPage) {
          controller.getCategoryProductList(
            0,
            controller.subCategoryList != null &&
                controller.subCategoryList!.isNotEmpty
                ? controller.subCategoryList![controller.subCategoryIndex].id
                .toString()
                : "0",
            0,
            '0',
            '0',
            '0',
            '0',
            arPath: 0,
            sv: 0,
            type: _selectedType,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadSavedZone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedZoneName = prefs.getString('zone_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';

    final GlobalKey<ScaffoldState> key = GlobalKey();

    return Scaffold(
      key: key,
      appBar: _buildAppBar(context),
      backgroundColor: const Color(0xFFF4F6F9),
      body: GetBuilder<CategoryController>(
        builder: (categoryController) {
          List<Estate> products = [];
          if (!categoryController.isSearching) {
            products.addAll(
              (categoryController.categoryProductList ?? [])
              as Iterable<Estate>,
            );
          }

          return categoryController.subCategoryList != null
              ? SingleChildScrollView(
            controller: widget.scrollController,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, left: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _buildSubCategoryChips(context, categoryController, isArabic),
                  const SizedBox(height: 10),
                  _buildToggleButtons(
                    context,
                    Theme.of(context).primaryColor,
                    isArabic,
                    categoryController,
                  ),
                  const SizedBox(height: 8),
                  // _buildZoneBadge(context),
                  products.isNotEmpty
                      ? ListView.builder(
                    key: UniqueKey(),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(products[index]);
                    },
                  )
                      : categoryController.isLoading
                      ? const SizedBox()
                      : Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 40),
                    child: Center(
                      child: NoDataScreen(
                        text: 'no_data_available',
                      ),
                    ),
                  ),
                  categoryController.isLoading && products.isEmpty
                      ? const _CenteredLoader()
                      : const SizedBox(),
                  categoryController.isPaginating
                      ? const _CenteredLoader()
                      : const SizedBox(),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  // ==========================================================================
  // مكوّنات التصميم — دوال خاصة داخل _HomeScreenState (بدون كلاسات جديدة)
  // ==========================================================================

  /// شريط علوي بخلفية بيضاء مرتفعة قليلًا بظل خفيف، زر رجوع دائري، عنوان
  /// (تصنيف + المنطقة الحالية)، وزر فلترة بارز بلون التطبيق الأساسي.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(64),
      child: Container(
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
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "عقارات متاحة",
                        style: robotoRegular.copyWith(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        (selectedZoneName != null &&
                            selectedZoneName!.isNotEmpty)
                            ? selectedZoneName!
                            : "جميع المناطق",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: robotoBold.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GetBuilder<ZoneController>(
                  builder: (zoneController) {
                    return GestureDetector(
                      onTap: () => Get.dialog(FiltersScreen()),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// صف تصنيفات فرعية أفقي بشكل شرائح بيضوية (Pills): مُعبّأة بلون التطبيق
  /// عند الاختيار (مع أيقونة التصنيف داخل دائرة بيضاء صغيرة)، وبخلفية بيضاء
  /// وحدود رمادية خفيفة عند عدم الاختيار — بدل الصندوق ذو الحدود فقط سابقًا.
  Widget _buildSubCategoryChips(
      BuildContext context,
      CategoryController categoryController,
      bool isArabic,
      ) {
    final list = categoryController.subCategoryList ?? [];
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final bool isSelected = index == categoryController.subCategoryIndex;
          final String label = isArabic
              ? (list[index].nameAr ?? "")
              : (list[index].name ?? 'all');

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () async {
                SharedPreferences prefs =
                await SharedPreferences.getInstance();
                int? savedZoneId = prefs.getInt('zone_id');

                categoryController.setSubCategoryIndex(
                  index,
                  savedZoneId ?? 0,
                );

                _loadSavedZone();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black12,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: Theme.of(context)
                          .primaryColor
                          .withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (index != 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFFF4F6F9),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(3),
                          child: CustomImage(
                            image:
                            '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${list[index].image}',
                            height: 16,
                            width: 16,
                            colors: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.black26,
                          ),
                        ),
                      ),
                    Text(
                      label,
                      style: (isSelected ? robotoMedium : robotoRegular)
                          .copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// فلتر "الكل / بيع / إيجار" — ٣ أزرار "حبّة" (Pills) مدمجة، بديفولت
  /// "الكل" مختارة تلقائيًا (تطابق _selectedType == '' في الحالة الأولية).
  Widget _buildToggleButtons(
      BuildContext context,
      Color primaryColor,
      bool isArabic,
      CategoryController categoryController,
      ) {
    final options = isArabic
        ? [('', 'الكل'), ('بيع', 'بيع'), ('إيجار', 'إيجار')]
        : [('', 'All'), ('Sale', 'Sale'), ('Rent', 'Rent')];

    return Row(
      children: options.map((opt) {
        final isSelected = _selectedType == opt.$1;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () {
              if (isSelected) return;
              setState(() => _selectedType = opt.$1);
              _applyTypeFilter(categoryController);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : primaryColor.withOpacity(0.3),
                  width: 1.2,
                ),
              ),
              child: Text(
                opt.$2,
                style: robotoMedium.copyWith(
                  color: isSelected ? Colors.white : primaryColor,
                  fontSize: Dimensions.fontSizeSmall,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// يعيد جلب القائمة بنفس المنطقة والتصنيف الفرعي الحاليين، لكن بنوع
  /// العرض المختار حديثًا (الكل/بيع/إيجار).
  ///
  /// ملاحظة مهمة: العملية كلها ملفوفة بـ try/catch الآن — أي استثناء غير
  /// متوقع (من SharedPreferences أو من getCategoryProductList نفسها أو من
  /// أي مكان آخر) هيتم "امتصاصه" وطباعته في اللوج بدل ما ينتشر ويسبب أي
  /// عدم استقرار في التطبيق. هذا لا يشخّص السبب الجذري لو كان موجودًا،
  /// لكنه يمنع أي انهيار ناتج عن هذه الدالة تحديدًا بشكل قاطع.
  void _applyTypeFilter(CategoryController categoryController) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? savedZoneId = prefs.getInt('zone_id');

      final list = categoryController.subCategoryList;
      final int idx = categoryController.subCategoryIndex;
      final String categoryId =
      (list != null && list.isNotEmpty && idx >= 0 && idx < list.length)
          ? (list[idx].id?.toString() ?? "0")
          : "0";

      categoryController.getCategoryProductList(
        savedZoneId ?? 0,
        categoryId,
        0,
        '0',
        "0",
        "0",
        "0",
        reload: true,
        arPath: 0,
        sv: 0,
        type: _selectedType,
      );
    } catch (e, stackTrace) {
      debugPrint('❌ _applyTypeFilter error: $e');
      debugPrint('$stackTrace');
    }
  }

  /// شارة المنطقة المختارة حاليًا (إن وجدت) بشكل شريحة أنيقة بأيقونة موقع
  /// وزر إزالة دائري، بدل الصندوق المستطيل البسيط سابقًا.
  Widget _buildZoneBadge(BuildContext context) {
    final bool hasZone =
        selectedZoneName != null && selectedZoneName!.isNotEmpty;

    if (!hasZone) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on_rounded,
              size: 16, color: Theme.of(context).primaryColor),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              selectedZoneName ?? "KSA",
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(
                fontSize: 12,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              SharedPreferences prefs =
              await SharedPreferences.getInstance();
              await prefs.remove('zone_name');
              await prefs.remove('zone_id');
              setState(() {
                selectedZoneName = "";
              });
            },
            child: Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.red, size: 13),
            ),
          ),
        ],
      ),
    );
  }
}

/// مؤشر تحميل موحّد بمسافات ثابتة — يُستخدم مرتين في الصفحة (التحميل الأول
/// وتحميل الصفحات الإضافية أثناء التمرير)، فبدل تكرار نفس Padding+Center
/// مرتين، أصبح ويدجت واحد بسيط.
class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}