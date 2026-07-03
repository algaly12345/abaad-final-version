import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/home/controller/banner_controller.dart';
import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/features/home/view/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widet/banner_view.dart';

class ZonesScreen extends StatefulWidget {

  const ZonesScreen({super.key});

  static Future<void> loadData(bool reload) async {
    Get.find<CategoryController>().getCategoryProductList(
      0, "0", 0, '0', "0", "0", "0",
      reload: true, arPath: 0, sv: 0, type: "",
    );
    Get.find<BannerController>().getBannerList(reload, 1);
    Get.find<AuthController>().getZoneList();
  }

  @override
  State<ZonesScreen> createState() => _ZonesScreenState();
}

class _ZonesScreenState extends State<ZonesScreen> {
  late String selectedZoneName;

  @override
  void initState() {
    super.initState();
    _loadSavedZone();
    Get.find<AuthController>().getZoneList();
    Get.find<BannerController>().getBannerList(false, 1);
  }

  void _loadSavedZone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedZoneName = prefs.getString('zone_name') ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GetBuilder<CategoryController>(builder: (categoryController) {
        return (categoryController.subCategoryList != null)
            ? CustomScrollView(
                slivers: [
                  // Header with gradient
                  SliverToBoxAdapter(
                    child: _buildHeader(context, isArabic),
                  ),
                  // Banner
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: BannerView(),
                    ),
                  ),
                  // Section title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'اختر منطقتك',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Zones grid
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: GetBuilder<AuthController>(
                      builder: (locationController) {
                        final zones = locationController.zoneList ?? [];
                        return SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 14,
                            childAspectRatio: 1.15,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final zone = zones[index];
                              return _buildZoneCard(context, zone);
                            },
                            childCount: zones.length,
                          ),
                        );
                      },
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              )
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  Widget _buildHeader(BuildContext context, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً بك',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'في أبعاد العقارية',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_city_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Search hint bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.search_rounded,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'ابحث عن عقارك المثالي...',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZoneCard(BuildContext context, dynamic zone) {
    return GestureDetector(
      onTap: () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('zone_name', zone!.nameAr);
        await prefs.setInt('zone_id', zone.id);
        Get.find<CategoryController>().setFilterIndex(
          zone.id, 0, "0", "0", 0, 0, 0, "",
        );
        Get.to(() => HomeScreen(zoneId: zone.id));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomImage(
                image: "${AppConstants.BASE_URL}/storage/app/public/zone/${zone?.image ?? ''}",
                fit: BoxFit.cover,
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.6),
                    ],
                  ),
                ),
              ),
              // Zone name
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  zone?.nameAr ?? "",
                  style: const TextStyle(
                    fontFamily: 'Roboto',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
