import 'dart:async';
import 'dart:collection';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/zones/data/models/zone_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ملاحظة: نفس أسماء الكلاسات الأصلية بالكامل (MapViewScreen،
/// _MapViewScreenState، ArcClipper). الإضافة هنا: تنسيق مخصّص لخريطة
/// جوجل (_mapStyleJson) بيوقف ظهور كل تسميات الخريطة الافتراضية (أسماء
/// الدول، المدن، الطرق، الأماكن) — فتبقى الخريطة نظيفة وتظهر فيها بس
/// علامات المناطق المخصّصة بتاعت التطبيق (الشرائح الزرقاء بأسماء
/// المناطق) بدون أي تشويش من نصوص جوجل الافتراضية.
class MapViewScreen extends StatefulWidget {
  const MapViewScreen({Key? key}) : super(key: key);

  static Future<void> loadData(bool reload) async {
    Get.find<AuthController>().getZoneList();
  }

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  GoogleMapController? _controller;

  List<MarkerData> _customMarkersZone = [];
  int _reload = 0;
  final Set<Polygon> _polygon = HashSet<Polygon>();

  static const CameraPosition _initialCamera = CameraPosition(
    zoom: 5.0,
    target: LatLng(25.224141, 43.065535
    ),
  );

  /// تنسيق خريطة مخصّص يوقف ظهور كل التسميات (Labels) — أسماء الدول
  /// والمدن والطرق والأماكن — مع الإبقاء على شكل الخريطة الجغرافي نفسه
  /// (الألوان، الحدود، المسطحات المائية) زي ما هو، بدون أي نص عليه.
  static const String _mapStyleJson = '''
  [
    {
      "elementType": "labels",
      "stylers": [
        { "visibility": "off" }
      ]
    }
  ]
  ''';

  @override
  void initState() {
    super.initState();
    MapViewScreen.loadData(false);
  }

  get borderRadius => BorderRadius.circular(8.0);
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  List<ZoneModel>? _zoneList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _zoneList != null
          ? _buildMap(_zoneList!)
          : GetBuilder<AuthController>(
        builder: (authController) {
          if (authController.zoneList == null) {
            return const Center(child: CircularProgressIndicator());
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _zoneList == null) {
              setState(() => _zoneList = authController.zoneList);
            }
          });

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildMap(List<ZoneModel> zoneList) {
    return CustomGoogleMapMarkerBuilder(
      customMarkers: _customMarkersZone,
      builder: (context, markers) {
        return Stack(
          children: [
            GoogleMap(
              initialCameraPosition: _initialCamera,
              markers: markers ?? const {},
              polygons: _polygon,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              compassEnabled: false,
              zoomControlsEnabled: true,
              minMaxZoomPreference: const MinMaxZoomPreference(0, 15),
              onTap: (position) =>
                  Get.find<SplashController>().setNearestEstateIndex(-1),
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                // 🔹 تطبيق التنسيق المخصّص فور إنشاء الخريطة — يوقف كل
                // تسميات جوجل الافتراضية فورًا.
                _controller?.setMapStyle(_mapStyleJson);
                _setMarkersZone(zoneList);
              },
            ),
          ],
        );
      },
    );
  }

  void _setMarkersZone(List<ZoneModel> zone) async {
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<LatLng> latLngs = [];
    _customMarkersZone = [];
    await prefs.setInt("visible", 0);

    _customMarkersZone.add(MarkerData(
      marker: const Marker(
        markerId: MarkerId('id-0'),
        position: LatLng(27.421792, 40.600602
        ),
      ),
      child: Image.asset(Images.mail, height: 20, width: 20),
    ));
    int index0 = 0;
    for (int index = 0; index < zone.length; index++) {
      index0++;
      LatLng latLng = LatLng(
        double.parse(zone[index].latitude),
        double.parse(zone[index].longitude),
      );
      latLngs.add(latLng);

      _customMarkersZone.add(
        MarkerData(
          marker: Marker(
            markerId: MarkerId('id-$index0'),
            position: latLng,
            onTap: () async {
              await prefs.setInt("visible", 1);
              Get.find<CategoryController>()
                  .setFilterIndex(zone[index].id, 0, "0", "0", 0, 0, 0, "");
              Get.toNamed(RouteHelper.getCategoryRoute(
                  zone[index].id, zone[index].longitude, zone[index].latitude));
            },
          ),
          child: Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2A7BF6),
                    Color(0xFF4A9BFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 3,
                    offset: const Offset(1, 2),
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 60,
                maxWidth: 120,
              ),
              child: Text(
                isArabic ? zone[index].nameAr : zone[index].name,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_reload == 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {});
            _reload = 1;
          }
        });
      });
    }
  }
}

class ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width * .03, size.height);
    path.quadraticBezierTo(
        size.width * .2, size.height * .5, size.width * .03, 0);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper old) => false;
}