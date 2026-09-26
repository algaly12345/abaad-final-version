import 'dart:async';
import 'dart:collection';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/zones/data/models/zone_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/map_marker_factory.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// شاشة المناطق.
///
/// التغيير الأساسي: حذف CustomGoogleMapMarkerBuilder (اللي كان يلتقط صورة
/// لكل Widget ويحتاج إعادة بناء مزدوجة بـ postFrameCallback حتى تظهر
/// الماركرات). الآن شرائح المناطق تُرسم مباشرة على Canvas وتُحفظ في كاش،
/// فتظهر فور جاهزية البيانات، والرجوع للشاشة يكون شبه فوري.
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

  Set<Marker> _markers = {};
  final Set<Polygon> _polygon = HashSet<Polygon>();

  /// لمنع إعادة بناء الماركرات لنفس القائمة أكثر من مرة.
  List<ZoneModel>? _markersBuiltFor;

  /// آخر قائمة مناطق وصلت من الكنترولر.
  List<ZoneModel>? _zones;

  /// لا نرسل الماركرات إلا بعد إنشاء الخريطة فعليًا — لو أُرسلت قبلها
  /// (وهذا يحدث عند فتح الشاشة مرة ثانية لأن الأيقونات تأتي من الكاش
  /// فورًا) تضيع ولا تظهر.
  bool _mapCreated = false;

  static const CameraPosition _initialCamera = CameraPosition(
    zoom: 5.0,
    target: LatLng(25.224141, 43.065535),
  );

  /// يخفي كل تسميات جوجل الافتراضية (دول، مدن، طرق، أماكن).
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
    _resetVisibleFlag();
  }

  Future<void> _resetVisibleFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("visible", 0);
  }

  get borderRadius => BorderRadius.circular(8.0);
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GetBuilder<AuthController>(
        builder: (authController) {
          final zones = authController.zoneList;

          if (zones != null && !identical(zones, _zones)) {
            _zones = zones;
            WidgetsBinding.instance.addPostFrameCallback((_) => _tryBuildMarkers());
          }

          // الخريطة تظهر فورًا (حتى قبل وصول المناطق) بدل سبينر بملء
          // الشاشة — الإحساس بالسرعة أعلى بكثير.
          return Stack(
            children: [
              GoogleMap(
                initialCameraPosition: _initialCamera,
                markers: _markers,
                polygons: _polygon,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                zoomControlsEnabled: true,
                minMaxZoomPreference: const MinMaxZoomPreference(0, 15),
                onTap: (position) =>
                    Get.find<SplashController>().setNearestEstateIndex(-1),
                onMapCreated: (GoogleMapController controller) async {
                  _controller = controller;
                  _controller?.setMapStyle(_mapStyleJson);
                  // ننتظر إطارًا واحدًا بعد الإنشاء ثم نضيف الماركرات.
                  await WidgetsBinding.instance.endOfFrame;
                  if (!mounted) return;
                  _mapCreated = true;
                  _tryBuildMarkers();
                },
              ),
              if (zones == null)
                const Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _tryBuildMarkers() {
    final zones = _zones;
    if (!mounted || !_mapCreated || zones == null) return;
    if (identical(zones, _markersBuiltFor)) return;
    _markersBuiltFor = zones;
    _buildZoneMarkers(zones);
  }

  Future<void> _buildZoneMarkers(List<ZoneModel> zones) async {
    final bool isArabic = Get.locale?.languageCode == 'ar';

    // كل الأيقونات تُولَّد بالتوازي (ومعظمها من الكاش عند الرجوع للشاشة).
    final futures = <Future<Marker?>>[
      MapMarkerFactory.asset(Images.mail, 20).then<Marker?>(
            (icon) => Marker(
          markerId: const MarkerId('id-0'),
          position: const LatLng(27.421792, 40.600602),
          icon: icon,
        ),
      ),
    ];

    for (int index = 0; index < zones.length; index++) {
      final zone = zones[index];
      final lat = double.tryParse(zone.latitude);
      final lng = double.tryParse(zone.longitude);
      if (lat == null || lng == null) continue;

      futures.add(
        MapMarkerFactory.pill(
          text: isArabic ? zone.nameAr : zone.name,
          background: const Color(0xFF2A7BF6),
          gradient: const [Color(0xFF2A7BF6), Color(0xFF4A9BFF)],
          textColor: Colors.white,
          borderColor: Colors.white,
          borderWidth: 1,
          withPointer: false,
          fontSize: 10,
          maxTextWidth: 104,
        ).then<Marker?>(
              (icon) => Marker(
            markerId: MarkerId('id-${index + 1}'),
            position: LatLng(lat, lng),
            icon: icon,
            anchor: const Offset(0.5, 0.5),
            consumeTapEvents: true,
            onTap: () => _openZone(zone),
          ),
        ),
      );
    }

    // لو فشلت أيقونة واحدة (مثلًا صورة Assets) لا تُسقط بقية الماركرات.
    Future<Marker?> safe(Future<Marker?> f) async {
      try {
        return await f;
      } catch (e) {
        debugPrint('zone marker error: $e');
        return null;
      }
    }

    final result = await Future.wait(futures.map(safe));
    if (!mounted || !identical(zones, _markersBuiltFor)) return;
    setState(() => _markers = result.whereType<Marker>().toSet());
  }

  Future<void> _openZone(ZoneModel zone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("visible", 1);
    Get.find<CategoryController>()
        .setFilterIndex(zone.id, 0, "0", "0", 0, 0, 0, "");
    Get.toNamed(
      RouteHelper.getCategoryRoute(zone.id, zone.longitude, zone.latitude),
    );
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