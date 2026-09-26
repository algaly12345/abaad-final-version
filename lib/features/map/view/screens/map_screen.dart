import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
import 'package:abaad_flutter/features/map/controller/location_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/features/zones/data/models/zone_model.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/details_dilog.dart';
import 'package:abaad_flutter/shared/widgets/drawer_menu.dart';
import 'package:abaad_flutter/shared/widgets/estate_item.dart';
import 'package:abaad_flutter/shared/widgets/no_data_screen.dart';
import 'package:abaad_flutter/features/filter/view/screens/fillter_estate_sheet.dart';
import 'package:abaad_flutter/shared/widgets/web_menu_bar.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/map_marker_factory.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/location_search_dialog.dart';
import 'package:abaad_flutter/features/estate/view/screens/estate_search_screen.dart';
import '../widgets/permission_dialog.dart';
import '../widgets/service_provider.dart';

class MapScreen extends StatefulWidget {
  ZoneModel mainCategory;
  final bool fromSignUp;
  final bool fromAddAddress;
  final bool canRoute;
  final String route;
  final GoogleMapController? googleMapController;

  MapScreen({
    Key? key,
    required this.mainCategory,
    required this.fromSignUp,
    required this.fromAddAddress,
    required this.canRoute,
    required this.route,
    this.googleMapController,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  late CameraPosition _cameraPosition;
  late Uint8List imageDataBytes;
  var markerIcon;
  String selectedOption = 'all';

  final Set<Polygon> _polygon = HashSet<Polygon>();
  final Set<Circle> _circles = <Circle>{};

  bool cardTapped = false;
  bool card = false;
  bool searchToggle = false;
  bool radiusSlider = false;
  bool backProider = false;

  late LatLng _initialPosition;
  var photoGalleryIndex = 0;
  final bool _ltr = Get.find<LocalizationController>().isLtr;

  /// الخريطة العادية أخف بكثير في التحميل من القمر الصناعي (مثل عقار).
  /// زر الطبقات ما زال يبدّل بينهما.
  MapType _currentMapType = MapType.normal;

  var tappedPoint;
  Estate? estate;

  late PageController _pageController;
  int prevPage = 0;
  bool showBlankCard = false;
  bool pressedNear = false;

  var radiusValue = 3000.0;
  String tokenKey = '';
  late int index;
  int selectedIndex = 0;

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final cardKey = GlobalKey<FlipCardState>();

  // ===================== حالة الخريطة والتحميل =====================

  /// زوم فتح المنطقة (كان 13 ثم تحريك إلى 9 بأنيميشن = تحميلان).
  static const double _zoneZoom = 11;

  /// نسبة التوسيع حول الجزء الظاهر عند الطلب: نجلب مساحة أكبر قليلًا من
  /// الشاشة، فالسحب البسيط لا يحتاج طلبًا جديدًا (نفس أسلوب عقار).
  static const double _prefetchPadding = 0.35;

  bool _mapReady = false;
  bool _showMap = false;
  bool _isFetchingBounds = false;
  bool _pendingFetch = false;
  bool _pendingForce = false;
  Timer? _idleDebounce;

  LatLngBounds? _fetchedBounds;
  double? _fetchedZoom;
  String _fetchedFilterKey = '';

  /// الماركرات الحالية (بالمعرّف) + القائمة التي بُنيت منها.
  final Map<MarkerId, Marker> _markerMap = {};
  List<Estate> _products = const [];
  String _lastListSignature = '';
  int _markerBuildSeq = 0;
  Color _primaryColor = const Color(0xFF2A7BF6);
  bool _animatingFromMarker = false;

  late double lat;
  late double lot;
  int? _filterZoneId;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
      _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  void _onScroll() {
    if (_pageController.hasClients && _pageController.page != null) {
      if (_pageController.page!.toInt() != prevPage) {
        prevPage = _pageController.page!.toInt();
        cardTapped = false;
        photoGalleryIndex = 1;
        showBlankCard = false;
        card = false;
      }
    }
  }

  void _setCircle(LatLng point) async {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 12),
      ),
    );
    setState(() {
      _circles.clear();
      _circles.add(
        Circle(
          circleId: const CircleId('raj'),
          center: point,
          fillColor: Colors.blue.withOpacity(0.1),
          radius: radiusValue,
          strokeColor: Colors.blue,
          strokeWidth: 1,
        ),
      );
      searchToggle = false;
      radiusSlider = true;
    });
  }

  @override
  void initState() {
    super.initState();
    Get.find<CategoryController>().getSubCategoryList("0", 1);
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85)
      ..addListener(_onScroll);
    lat = double.parse(widget.mainCategory.latitude);
    lot = double.parse(widget.mainCategory.longitude);

    _initialPosition = LatLng(lat, lot);
    _cameraPosition = CameraPosition(target: _initialPosition, zoom: _zoneZoom);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // (بعد أول إطار وليس داخل initState لأن الكنترولر يستدعي update().)
      // نمسح عقارات المنطقة السابقة حتى لا تظهر لحظة الفتح.
      Get.find<CategoryController>().clearMapEstates();

      // 🔹 نبدأ جلب البيانات فورًا — بالتوازي مع حركة فتح الصفحة وإنشاء
      // الخريطة، بدل انتظار onMapCreated.
      _loadMapEstatesByBounds(reload: true);

      // 🔹 إنشاء GoogleMap أثناء أنيميشن فتح الصفحة هو سبب "التقطيع"
      // والثقل عند الفتح. نؤجله حتى تنتهي الحركة.
      final anim = ModalRoute.of(context)?.animation;
      if (anim == null || anim.status == AnimationStatus.completed) {
        setState(() => _showMap = true);
        return;
      }
      void listener(AnimationStatus s) {
        if (s == AnimationStatus.completed) {
          anim.removeStatusListener(listener);
          if (mounted) setState(() => _showMap = true);
        }
      }
      anim.addStatusListener(listener);
    });

    // نستمع للكنترولر مباشرة بدل فحص عدد العناصر داخل build.
    Get.find<CategoryController>().addListener(_onCategoryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onCategoryChanged();
    });
  }

  @override
  void dispose() {
    _idleDebounce?.cancel();
    Get.find<CategoryController>().removeListener(_onCategoryChanged);
    _pageController.dispose();
    if (_mapReady) _controller.dispose();
    super.dispose();
  }

  BorderRadius get borderRadius => BorderRadius.circular(8.0);

  Future<void> getCustomMarkerIcon(GlobalKey iconKey) async {
    return;
  }

  Future<void> _applyFilterZoneIfChanged() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final double? newLat = prefs.getDouble('filter_zone_lat');
    final double? newLng = prefs.getDouble('filter_zone_lng');
    final int? newZoneId = prefs.getInt('zone_id');

    if (newLat != null && newLng != null) {
      lat = newLat;
      lot = newLng;
      _filterZoneId = (newZoneId != null && newZoneId != 0)
          ? newZoneId
          : widget.mainCategory.id;

      if (_mapReady) {
        // moveCamera فوري — بدل animate + انتظار 600 مللي ثانية.
        await _controller.moveCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(lat, lot), zoom: 12),
          ),
        );
      }
    }
    await _loadMapEstatesByBounds(reload: true);
  }

  // ===================== جلب البيانات حسب الجزء الظاهر =====================

  /// لا نطلب مع كل توقف للكاميرا فورًا؛ ننتظر حتى يتوقف المستخدم عن
  /// التحريك (debounce) ثم نطلب مرة واحدة فقط.
  void _onCameraIdle() {
    if (!_mapReady) return;
    _idleDebounce?.cancel();
    _idleDebounce = Timer(
      const Duration(milliseconds: 350),
          () => _loadMapEstatesByBounds(reload: false),
    );
  }

  String _currentFilterKey() {
    final c = Get.find<CategoryController>();
    return [
      _filterZoneId ?? widget.mainCategory.id,
      c.subCategoryIndex,
      c.filterCity,
      c.filterDistrict,
      c.filterSpace,
      selectedOption,
    ].join('|');
  }

  bool _contains(LatLngBounds outer, LatLngBounds inner) =>
      inner.northeast.latitude <= outer.northeast.latitude &&
          inner.northeast.longitude <= outer.northeast.longitude &&
          inner.southwest.latitude >= outer.southwest.latitude &&
          inner.southwest.longitude >= outer.southwest.longitude;

  LatLngBounds _expand(LatLngBounds b, double ratio) {
    final dLat = (b.northeast.latitude - b.southwest.latitude) * ratio;
    final dLng = (b.northeast.longitude - b.southwest.longitude) * ratio;
    return LatLngBounds(
      southwest: LatLng(b.southwest.latitude - dLat, b.southwest.longitude - dLng),
      northeast: LatLng(b.northeast.latitude + dLat, b.northeast.longitude + dLng),
    );
  }

  /// [reload] = true: إجبار الطلب (تغيير فلتر/تصنيف/نوع).
  /// [reload] = false: يطلب فقط إذا خرج المستخدم عن المساحة المحمّلة أو
  /// غيّر الزوم بمستوى كامل.
  /// تقدير الجزء الظاهر من الخريطة رياضيًا (من المركز + الزوم + حجم
  /// الشاشة) — يسمح ببدء طلب البيانات قبل أن تنتهي الخريطة من الإنشاء.
  LatLngBounds _estimateVisible(CameraPosition cam) {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final Size size = view.physicalSize / view.devicePixelRatio;
    final double degPerPx = 360 / (256 * pow(2, cam.zoom));
    final double lngSpan = size.width * degPerPx;
    final double latSpan =
        size.height * degPerPx * cos(cam.target.latitude * pi / 180);
    final c = cam.target;
    return LatLngBounds(
      southwest: LatLng(c.latitude - latSpan / 2, c.longitude - lngSpan / 2),
      northeast: LatLng(c.latitude + latSpan / 2, c.longitude + lngSpan / 2),
    );
  }

  Future<void> _loadMapEstatesByBounds({bool reload = true}) async {
    // لو فيه طلب شغال، لا نرمي الطلب الجديد (كان يضيع آخر مكان وقف عنده
    // المستخدم) — نسجله وننفذه مرة واحدة بعد انتهاء الحالي.
    if (_isFetchingBounds) {
      _pendingFetch = true;
      _pendingForce = _pendingForce || reload;
      return;
    }

    _isFetchingBounds = true;
    try {
      LatLngBounds visible;
      double zoom;
      if (_mapReady) {
        visible = await _controller.getVisibleRegion();
        zoom = await _controller.getZoomLevel();
        // أحيانًا (أندرويد) تُرجع الخريطة مساحة صفرية قبل أول رسم.
        if (visible.northeast.latitude == visible.southwest.latitude ||
            visible.northeast.longitude == visible.southwest.longitude) {
          visible = _estimateVisible(_cameraPosition);
        }
      } else {
        // الخريطة لم تُنشأ بعد: نطلب البيانات بالتوازي مع إنشائها.
        visible = _estimateVisible(_cameraPosition);
        zoom = _cameraPosition.zoom;
      }

      final filterKey = _currentFilterKey();
      final bool sameFilters = filterKey == _fetchedFilterKey;
      final bool insideLoaded =
          _fetchedBounds != null && _contains(_fetchedBounds!, visible);
      final bool sameZoomLevel =
          _fetchedZoom != null && (zoom - _fetchedZoom!).abs() < 1.0;

      if (!reload && sameFilters && insideLoaded && sameZoomLevel) {
        return; // البيانات الموجودة تغطي الشاشة — لا داعي لطلب جديد.
      }

      final fetch = _expand(visible, _prefetchPadding);
      final categoryController = Get.find<CategoryController>();

      await categoryController.getMapCategoryProductListByBounds(
        _filterZoneId ?? widget.mainCategory.id,
        categoryController.subCategoryList != null &&
            categoryController.subCategoryList!.isNotEmpty
            ? categoryController
            .subCategoryList![categoryController.subCategoryIndex].id
            .toString()
            : "0",
        0,
        categoryController.filterCity,
        categoryController.filterDistrict,
        categoryController.filterSpace,
        "0",
        fetch.northeast.latitude,
        fetch.northeast.longitude,
        fetch.southwest.latitude,
        fetch.southwest.longitude,
        reload: true,
        arPath: 0,
        sv: 0,
        type: selectedOption,
      );

      _fetchedBounds = fetch;
      _fetchedZoom = zoom;
      _fetchedFilterKey = filterKey;
    } finally {
      _isFetchingBounds = false;
      if (_pendingFetch && mounted) {
        final force = _pendingForce;
        _pendingFetch = false;
        _pendingForce = false;
        _loadMapEstatesByBounds(reload: force);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';
    var width = MediaQuery.of(context).size.width;
    _primaryColor = Theme.of(context).primaryColor;



    return Scaffold(
      key: _key,
      appBar: WebMenuBar(
        ontop: () => _key.currentState!.openDrawer(),
        fromPage: "main",
      ),
      drawer: DrawerMenu(),
      onDrawerChanged: (isOpened) {
        if (isOpened) DrawerMenu.ensureUserDataLoaded();
      },
      body: GetBuilder<CategoryController>(
        builder: (categoryController) {
          return GetBuilder<LocationController>(
            builder: (locationController) {
              // القائمة نفسها التي بُنيت منها الماركرات — فيبقى رقم الماركر
              // ورقم البطاقة متطابقين دائمًا.
              final List<Estate> products = _products;

              final googleMap = GoogleMap(
                initialCameraPosition: CameraPosition(
                  zoom: _zoneZoom,
                  target: LatLng(lat, lot),
                ),
                markers: Set<Marker>.of(_markerMap.values),
                zoomControlsEnabled: false,
                mapType: _currentMapType,
                // يقلل رسم عناصر إضافية لا نحتاجها.
                mapToolbarEnabled: false,
                buildingsEnabled: false,
                indoorViewEnabled: false,
                trafficEnabled: false,
                onTap: (point) {
                  tappedPoint = point;
                  _setCircle(point);
                },
                onCameraMove: (position) {
                  _cameraPosition = position;
                },
                onCameraIdle: _onCameraIdle,
                minMaxZoomPreference: const MinMaxZoomPreference(0, 40),
                circles: _circles,
                polygons: _polygon,
                onMapCreated: (GoogleMapController controller) {
                  _controller = controller;
                  _mapReady = true;
                  // نعرض أي بيانات موجودة مسبقًا بعد جاهزية الخريطة.
                  WidgetsBinding.instance.endOfFrame.then((_) {
                    if (mounted) _onCategoryChanged();
                  });
                  // الطلب بدأ مسبقًا في initState؛ هذا لا يرسل طلبًا
                  // جديدًا إلا إذا كانت الشاشة الفعلية خارج المساحة المحمّلة.
                  _loadMapEstatesByBounds(reload: false);
                },
              );

              return Stack(
                children: [
                  _showMap
                      ? googleMap
                      : const ColoredBox(
                    color: Color(0xFFEDEBE6),
                    child: SizedBox.expand(),
                  ),

                  // 🔹 شريط تحميل علوي عائم بدل سبينر كبير في نص
                  // الشاشة — لا يحجب الخريطة، ويعطي إحساسًا بسرعة
                  // أكبر لأن المستخدم يقدر يبدأ يتفاعل مع الخريطة
                  // فورًا أثناء التحميل بدل انتظار مؤشر مركزي.
                  if (categoryController.isMapLoading)
                    Positioned(
                      top: 12,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 15,
                                height: 15,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "جاري التحميل...",
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // if (!categoryController.isMapLoading &&
                  //     products.isEmpty)
                  //   const Center(
                  //     child: NoDataScreen(
                  //       text: 'no_data_available',
                  //     ),
                  //   ),

                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 7.0),
                        child: Container(
                          margin: const EdgeInsets.only(
                            left: 10.0,
                            right: 7.0,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      // 🔹 بحث العقارات الشامل بدل بحث
                                      // الموقع الجغرافي (LocationSearchDialog).
                                      Get.to(() => const EstateSearchScreen());
                                    },
                                    child: Container(
                                      height: 43,
                                      padding: EdgeInsets.symmetric(
                                        horizontal:
                                        Dimensions.PADDING_SIZE_SMALL,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius:
                                        BorderRadius.circular(
                                          Dimensions.RADIUS_SMALL,
                                        ),
                                      ),
                                      width: width - 130,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 25,
                                            color: Theme.of(context)
                                                .primaryColor,
                                          ),
                                          SizedBox(
                                            width: Dimensions
                                                .PADDING_SIZE_EXTRA_SMALL,
                                          ),
                                          Expanded(
                                            child: Text(
                                              locationController.pickAddress,
                                              style:
                                              robotoRegular.copyWith(
                                                fontSize: Dimensions
                                                    .fontSizeLarge,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: Dimensions
                                                .PADDING_SIZE_SMALL,
                                          ),
                                          Icon(
                                            Icons.search,
                                            size: 25,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodyLarge!
                                                .color,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(
                                        left: 4.0, right: 4.0),
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius:
                                      BorderRadius.circular(5),
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.qr_code,
                                      size: 25,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      cardTapped = true;
                                      await Get.dialog(FiltersScreen());
                                      await _applyFilterZoneIfChanged();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(7),
                                      margin: const EdgeInsets.only(
                                          left: 4.0, right: 4.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                        BorderRadius.circular(5),
                                        border: Border.all(
                                          width: 1,
                                          color: Colors.white,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.filter_list_alt,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),

                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.start,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        selectedOption = 'بيع';
                                      });
                                      await _loadMapEstatesByBounds(
                                        reload: true,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      selectedOption == 'بيع'
                                          ? Colors.blue
                                          : Colors.white,
                                      foregroundColor:
                                      selectedOption == 'بيع'
                                          ? Colors.white
                                          : Colors.black,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.blue),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('بيع'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        selectedOption = 'إيجار';
                                      });
                                      await _loadMapEstatesByBounds(
                                        reload: true,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      selectedOption == 'إيجار'
                                          ? Colors.blue
                                          : Colors.white,
                                      foregroundColor:
                                      selectedOption == 'إيجار'
                                          ? Colors.white
                                          : Colors.black,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.blue),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('إيجار'),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () async {
                                      setState(() {
                                        selectedOption = 'all';
                                      });
                                      await _loadMapEstatesByBounds(
                                        reload: true,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                      selectedOption == 'all'
                                          ? Colors.blue
                                          : Colors.white,
                                      foregroundColor:
                                      selectedOption == 'all'
                                          ? Colors.white
                                          : Colors.black,
                                      shape: RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.blue),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('الكل'),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 5),

                              SizedBox(
                                child: categoryController.subCategoryList !=
                                    null
                                    ? Center(
                                  child: SizedBox(
                                    height: 40,
                                    child: ListView.builder(
                                      scrollDirection:
                                      Axis.horizontal,
                                      itemCount: categoryController
                                          .subCategoryList!.length,
                                      padding: EdgeInsets.only(
                                        left: Dimensions
                                            .PADDING_SIZE_SMALL,
                                      ),
                                      physics:
                                      const BouncingScrollPhysics(),
                                      itemBuilder:
                                          (context, index) {
                                        return Padding(
                                          padding:
                                          const EdgeInsets.only(
                                            right: 6,
                                            left: 6,
                                          ),
                                          child: InkWell(
                                            onTap: () async {
                                              categoryController
                                                  .setSubCategoryIndex(
                                                index,
                                                widget.mainCategory.id,
                                              );
                                              await _loadMapEstatesByBounds(
                                                reload: true,
                                              );
                                            },
                                            child: Container(
                                              padding:
                                              EdgeInsets.only(
                                                left: index == 0
                                                    ? Dimensions
                                                    .PADDING_SIZE_LARGE
                                                    : Dimensions
                                                    .PADDING_SIZE_SMALL,
                                                right: index ==
                                                    categoryController
                                                        .subCategoryList!
                                                        .length -
                                                        1
                                                    ? Dimensions
                                                    .PADDING_SIZE_LARGE
                                                    : Dimensions
                                                    .PADDING_SIZE_SMALL,
                                              ),
                                              decoration:
                                              BoxDecoration(
                                                border: Border.all(
                                                  color: index ==
                                                      categoryController
                                                          .subCategoryIndex
                                                      ? Theme.of(
                                                      context)
                                                      .primaryColor
                                                      : Colors
                                                      .black12,
                                                  width: 2,
                                                ),
                                                borderRadius:
                                                BorderRadius
                                                    .circular(
                                                    8.0),
                                                color: Colors.white,
                                              ),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    isArabic
                                                        ? categoryController
                                                        .subCategoryList![
                                                    index]
                                                        .nameAr ??
                                                        ""
                                                        : categoryController
                                                        .subCategoryList![
                                                    index]
                                                        .name ??
                                                        "all",
                                                    style: index ==
                                                        categoryController
                                                            .subCategoryIndex
                                                        ? robotoMedium
                                                        .copyWith(
                                                      fontSize:
                                                      Dimensions.fontSizeDefault,
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                    )
                                                        : robotoRegular
                                                        .copyWith(
                                                      fontSize:
                                                      Dimensions.fontSizeDefault,
                                                      color: Theme.of(context)
                                                          .disabledColor,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      width: 5),
                                                  index == 0
                                                      ? Container()
                                                      : CustomImage(
                                                    image:
                                                    '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.subCategoryList![index].image}',
                                                    height: 25,
                                                    width: 25,
                                                    colors: index ==
                                                        categoryController.subCategoryIndex
                                                        ? Theme.of(context)
                                                        .primaryColor
                                                        : Colors
                                                        .black12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                                    : const SizedBox(),
                              ),

                              SizedBox(
                                height: 200,
                                child: Column(
                                  children: [
                                    Container(
                                      height: 60,
                                      width: 60,
                                      padding:
                                      const EdgeInsets.all(10.0),
                                      child: FloatingActionButton(
                                        mini: true,
                                        backgroundColor:
                                        Theme.of(context).cardColor,
                                        onPressed: () => _checkPermission(
                                              () {
                                            Get.find<LocationController>()
                                                .getCurrentLocation(
                                              false,
                                              mapController: _controller,
                                              defaultLatLng:
                                              const LatLng(0, 0),
                                            );
                                          },
                                        ),
                                        child: Icon(
                                          Icons.my_location,
                                          color: Theme.of(context)
                                              .primaryColor,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 60,
                                      width: 60,
                                      padding:
                                      const EdgeInsets.all(10.0),
                                      child: FloatingActionButton(
                                        backgroundColor: Colors.white,
                                        heroTag: 'recenterr',
                                        onPressed: _onMapTypeButtonPressed,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10.0),
                                          side: const BorderSide(
                                            color: Color(0xFFECEDF1),
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.layers_outlined,
                                          color: Theme.of(context)
                                              .primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // cardTapped
                  //     ? Positioned(
                  //   top: 100.0,
                  //   left: 15.0,
                  //   child: FlipCard(
                  //     key: cardKey,
                  //     front: Container(
                  //       height: 180.0,
                  //       width: 175.0,
                  //       decoration: const BoxDecoration(
                  //         color: Colors.white,
                  //         borderRadius: BorderRadius.all(
                  //           Radius.circular(8.0),
                  //         ),
                  //       ),
                  //       child: SingleChildScrollView(
                  //         child: Column(
                  //           children: [
                  //             Align(
                  //               alignment: Alignment.bottomRight,
                  //               child: GestureDetector(
                  //                 onTap: () {
                  //                   setState(() {
                  //                     cardTapped = !cardTapped;
                  //                   });
                  //                 },
                  //                 child: Container(
                  //                   decoration:
                  //                   const BoxDecoration(
                  //                     color: Colors.red,
                  //                     shape: BoxShape.circle,
                  //                   ),
                  //                   padding:
                  //                   const EdgeInsets.all(4),
                  //                   child: const Icon(
                  //                     Icons.close,
                  //                     size: 16,
                  //                     color: Colors.white,
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //             Container(
                  //               height: 100.0,
                  //               width: 175.0,
                  //               decoration: const BoxDecoration(
                  //                 borderRadius: BorderRadius.only(
                  //                   topLeft: Radius.circular(8.0),
                  //                   topRight: Radius.circular(8.0),
                  //                 ),
                  //                 image: DecorationImage(
                  //                   image:
                  //                   AssetImage(Images.offer),
                  //                   fit: BoxFit.cover,
                  //                 ),
                  //               ),
                  //             ),
                  //             Container(
                  //               padding:
                  //               const EdgeInsets.fromLTRB(
                  //                 7.0,
                  //                 0.0,
                  //                 7.0,
                  //                 0.0,
                  //               ),
                  //               width: 175.0,
                  //               child: Row(
                  //                 crossAxisAlignment:
                  //                 CrossAxisAlignment.center,
                  //                 children: [
                  //                   SizedBox(
                  //                     width: 150,
                  //                     child: Text(
                  //                       "this_offer_includes_offers_and_discounts"
                  //                           .tr,
                  //                       style: robotoBlack.copyWith(
                  //                         fontSize: 10,
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ],
                  //               ),
                  //             ),
                  //           ],
                  //         ),
                  //       ),
                  //     ),
                  //     back: Container(
                  //       width: 225.0,
                  //       decoration: BoxDecoration(
                  //         color: Colors.white.withOpacity(0.95),
                  //         borderRadius:
                  //         BorderRadius.circular(8.0),
                  //       ),
                  //       child: Column(
                  //         children: [
                  //           estate == null
                  //               ? const SizedBox()
                  //               : ServiceProviderItem(
                  //             estate: estate!,
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //     autoFlipDuration:
                  //     const Duration(seconds: 1),
                  //   ),
                  // )
                  //     : Container(),

                  // 🔹 دليل الشارات — يظهر فقط لو فيه عقار واحد على الأقل
                  // عليه خدمات أو جولة افتراضية أو فيديو.
                  if (products.any((e) =>
                  (e.serviceOffers ?? []).isNotEmpty ||
                      _hasLink(e.arPath) ||
                      _hasLink(e.videoUrl)))
                    PositionedDirectional(
                      start: 10,
                      bottom: products.isNotEmpty ? 210 : 20,
                      child: _badgesLegend(),
                    ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: products.isNotEmpty
                        ? SizedBox(
                      height: 200,
                      child: nearbyPlacesList(products),
                    )
                        : const Text(""),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _checkPermission(Function onTap) async {
    onTap();
  }

  // ===================== الماركرات (سريعة + كاش) =====================

  bool _hasCoords(Estate e) =>
      (e.latitude ?? '').isNotEmpty &&
          (e.longitude ?? '').isNotEmpty &&
          double.tryParse(e.latitude!) != null &&
          double.tryParse(e.longitude!) != null;

  MarkerId _markerIdFor(Estate e, int i) => MarkerId('e-${e.id ?? 'i$i'}');

  /// يُستدعى عند كل update() في CategoryController، لكنه لا يعيد بناء
  /// الماركرات إلا إذا تغيّرت القائمة فعلًا (وليس عددها فقط كما كان سابقًا).
  void _onCategoryChanged() {
    // نفس مشكلة شاشة المناطق: لا نرسل ماركرات قبل إنشاء الخريطة.
    if (!_mapReady) return;
    final c = Get.find<CategoryController>();
    final List<Estate> list =
    c.isSearching ? const <Estate>[] : (c.mapEstateList ?? const <Estate>[]);

    final sig = '${list.length}:' +
        list
            .map((e) =>
        '${e.id}_${e.price}_${e.totalPrice}_${e.serviceOffers?.length ?? 0}'
            '_${_hasLink(e.arPath)}_${_hasLink(e.videoUrl)}')
            .join(',');
    if (sig == _lastListSignature) return;
    _lastListSignature = sig;

    assert(() {
      final offers = list.where((e) => (e.serviceOffers ?? []).isNotEmpty).length;
      final tours = list.where((e) => _hasLink(e.arPath)).length;
      final videos = list.where((e) => _hasLink(e.videoUrl)).length;
      debugPrint('🗺️ map estates=${list.length} offers=$offers '
          'tours=$tours videos=$videos');
      return true;
    }());

    _rebuildMarkers(list.where(_hasCoords).toList());
  }

  Future<void> _rebuildMarkers(List<Estate> list) async {
    final int seq = ++_markerBuildSeq;

    // نحافظ على العقار المحدد لو ما زال موجودًا في القائمة الجديدة.
    final prevId = selectedIndex < _products.length
        ? _products[selectedIndex].id
        : null;
    final int kept =
    prevId == null ? -1 : list.indexWhere((e) => e.id == prevId);
    selectedIndex = kept < 0 ? 0 : kept;

    final built = await Future.wait([
      for (int i = 0; i < list.length; i++) _buildEstateMarker(list[i], i),
    ]);

    // لو وصلت قائمة أحدث أثناء التوليد، نتجاهل هذه النتيجة القديمة.
    if (!mounted || seq != _markerBuildSeq) return;

    setState(() {
      _products = list;
      _markerMap
        ..clear()
        ..addEntries(built.map((m) => MapEntry(m.markerId, m)));
    });

    if (_pageController.hasClients && list.isNotEmpty) {
      final current = (_pageController.page ?? 0).round();
      if (current != selectedIndex) {
        _pageController.jumpToPage(selectedIndex);
      }
    }
  }

  Widget _badgesLegend() {
    Widget item(MarkerBadge b, String label) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: b.color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(b.icon, size: 10, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: 11,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          item(_offerBadge, 'خدمات مزودين'),
          item(_tourBadge, 'جولة افتراضية'),
          item(_videoBadge, 'فيديو'),
        ],
      ),
    );
  }

  static const MarkerBadge _offerBadge = MapMarkerFactory.offerFeature;
  static const MarkerBadge _tourBadge = MapMarkerFactory.tourFeature;
  static const MarkerBadge _videoBadge = MapMarkerFactory.videoFeature;

  /// رابط صالح فعلًا (السيرفر أحيانًا يرجّع "null" أو "0" أو نص فارغ).
  bool _hasLink(String? v) {
    final s = v?.trim() ?? '';
    return s.isNotEmpty && s != 'null' && s != '0';
  }

  Future<Marker> _buildEstateMarker(Estate e, int i) async {
    final bool selected = i == selectedIndex;
    final bool hasOffer = (e.serviceOffers ?? []).isNotEmpty;
    final bool hasTour = _hasLink(e.arPath);
    final bool hasVideo = _hasLink(e.videoUrl);
    final Color primary = _primaryColor;

    // الشارات فوق شريحة السعر (بنفس الترتيب دائمًا):
    // برتقالي = خدمات مزودين، بنفسجي = جولة افتراضية 360، أحمر = فيديو.
    final int featuresCount =
        (hasOffer ? 1 : 0) + (hasTour ? 1 : 0) + (hasVideo ? 1 : 0);

    final String label = formatPrice(
      e.categoryName == "ارض" ? (e.totalPrice ?? "0") : (e.price ?? "0"),
    );

    final icon = await MapMarkerFactory.estate(
      price: label,
      primary: primary,
      selected: selected,
      hasOffer: hasOffer,
      hasTour: hasTour,
      hasVideo: hasVideo,
    );

    return Marker(
      markerId: _markerIdFor(e, i),
      position: LatLng(double.parse(e.latitude!), double.parse(e.longitude!)),
      icon: icon,
      // العقارات التي عليها مزايا تظهر فوق غيرها عند التزاحم.
      zIndex: selected ? 10 : (1 + featuresCount).toDouble(),
      // يمنع جوجل من تحريك الكاميرا عند الضغط (كان يسبب طلب API إضافي).
      consumeTapEvents: true,
      onTap: () => _onMarkerTap(i),
    );
  }

  void _onMarkerTap(int i) {
    _selectEstate(i);
    if (_pageController.hasClients) {
      _animatingFromMarker = true;
      _pageController
          .animateToPage(
        i,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      )
          .whenComplete(() => _animatingFromMarker = false);
    }
  }

  /// تغيير العقار المحدد: نعيد رسم ماركرين فقط (القديم والجديد) بدل الكل.
  Future<void> _selectEstate(int i) async {
    if (i == selectedIndex || i < 0 || i >= _products.length) return;
    final int old = selectedIndex;
    selectedIndex = i;
    final int seq = _markerBuildSeq;

    final updates = await Future.wait([
      if (old >= 0 && old < _products.length)
        _buildEstateMarker(_products[old], old),
      _buildEstateMarker(_products[i], i),
    ]);

    if (!mounted || seq != _markerBuildSeq) return;
    setState(() {
      for (final m in updates) {
        _markerMap[m.markerId] = m;
      }
    });
  }

  bool _isDiscountOffer(ServiceOffers offer) {
    return (offer.discount ?? '').isNotEmpty && offer.discount != '0';
  }

  String _offerMainValue(ServiceOffers offer) {
    if (_isDiscountOffer(offer)) {
      return '${offer.discount}% خصم';
    }

    if ((offer.servicePrice ?? '').isNotEmpty && offer.servicePrice != '0') {
      return '${offer.servicePrice} ر.س';
    }

    return 'عرض خاص';
  }

  Widget _offerInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: 11,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget nearbyPlacesList(List<Estate> products) {
    return PageView.builder(
      controller: _pageController,
      itemCount: products.length,
      onPageChanged: (int value) {
        if (!_animatingFromMarker) _selectEstate(value);
        // _controller.animateCamera(
        //   CameraUpdate.newCameraPosition(
        //     CameraPosition(
        //       target: LatLng(
        //         double.parse(products[selectedIndex].latitude!),
        //         double.parse(products[selectedIndex].longitude!),
        //       ),
        //       zoom: 25.0,
        //       bearing: 45.0,
        //       tilt: 45.0,
        //     ),
        //   ),
        // );

        // if (products[selectedIndex].serviceOffers!.isNotEmpty) {
        //   estate = products[selectedIndex];
        //   cardTapped = true;
        // } else {
        //   cardTapped = false;
        // }
      },
      itemBuilder: (BuildContext context, int index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (BuildContext? context, Widget? widget) {
            return Center(child: SizedBox(child: widget));
          },
          child: InkWell(
            onTap: () async {
              setState(() {
                // cardTapped = !cardTapped;
              });
            },
            child: Column(
              children: [
                SizedBox(
                  width: context.width,
                  child: products[index].serviceOffers!.isNotEmpty
                      ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.96, end: 1.04),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      final bool hasDiscount = products[index]
                          .serviceOffers!
                          .any((e) => _isDiscountOffer(e));

                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _showServiceOffersDialog(products[index]);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: hasDiscount
                                ? const Color(0xFFFFF7ED)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasDiscount
                                  ? const Color(0xFFFDBA74)
                                  : const Color(0xFF93C5FD),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (hasDiscount
                                    ? const Color(0xFFEA580C)
                                    : const Color(0xFF2563EB))
                                    .withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: scale,
                                child: Icon(
                                  hasDiscount
                                      ? Icons.discount_rounded
                                      : Icons.local_offer_rounded,
                                  size: 15,
                                  color: hasDiscount
                                      ? const Color(0xFFEA580C)
                                      : const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                hasDiscount ? "خصومات وخدمات" : "خدمات مرفقة",
                                style: robotoMedium.copyWith(
                                  fontSize: 11,
                                  color: hasDiscount
                                      ? const Color(0xFF9A3412)
                                      : const Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                children: [
                                  for (var i = 0;
                                  i <
                                      (products[index].serviceOffers!.length > 3
                                          ? 3
                                          : products[index].serviceOffers!.length);
                                  i++)
                                    Container(
                                      margin:
                                      const EdgeInsetsDirectional.only(start: 3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: CustomImage(
                                          image:
                                          '${Get.find<SplashController>().configModel!.baseUrls!.provider}'
                                              '/${products[index].serviceOffers![i].image ?? Images.image}',
                                          height: 20,
                                          width: 20,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  if (products[index].serviceOffers!.length > 3)
                                    Container(
                                      margin:
                                      const EdgeInsetsDirectional.only(start: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: hasDiscount
                                            ? const Color(0xFFEA580C)
                                            : const Color(0xFF2563EB),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '+${products[index].serviceOffers!.length - 3}',
                                        style: robotoMedium.copyWith(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 16,
                                color: hasDiscount
                                    ? const Color(0xFF9A3412)
                                    : const Color(0xFF1E3A8A),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      : const SizedBox(height: 12),
                ),
                Center(
                  child: EstateItem(
                    estate: products[index],
                    onPressed: () {
                      Get.find<UserController>()
                          .getUserInfoByID(products[index].userId!);
                      Get.find<UserController>().getEstateByUser(
                        1,
                        false,
                        products[index].userId!,
                      );
                      Get.dialog(DettailsDilog(estate: products[index]));
                    },
                    fav: false,
                    isMyProfile: 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatPrice(String priceStr) {
    final num? price = num.tryParse(priceStr);
    if (price == null) return "0";

    String trim(num v) => v
        .toStringAsFixed(2)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');

    if (price >= 1000000) {
      return "${trim(price / 1000000)} مليون";
    } else if (price >= 1000) {
      return "${trim(price / 1000)} ألف";
    } else {
      return trim(price);
    }
  }
}
void _showServiceOffersDialog(Estate estate) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: Color(0xFFEA580C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'الخدمات المرفقة',
                  style: robotoBold.copyWith(
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.black87,
                  ),
                  splashRadius: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: estate.serviceOffers?.length ?? 0,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final offer = estate.serviceOffers![i];
                final bool isDiscount = _isDiscountOffer(offer);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDiscount
                        ? const Color(0xFFFFFBEB)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDiscount
                          ? const Color(0xFFF59E0B).withOpacity(0.35)
                          : const Color(0xFF3B82F6).withOpacity(0.18),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDiscount
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF3B82F6))
                            .withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CustomImage(
                              image:
                              '${Get.find<SplashController>().configModel!.baseUrls!.provider}'
                                  '/${offer.image ?? Images.image}',
                              height: 52,
                              width: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.title?.isNotEmpty == true
                                      ? offer.title!
                                      : 'عرض مرفق',
                                  style: robotoBold.copyWith(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  offer.provider_name?.isNotEmpty == true
                                      ? offer.provider_name!
                                      : 'مزود خدمة',
                                  style: robotoMedium.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isDiscount
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isDiscount ? 'خصم' : 'سعر خاص',
                              style: robotoBold.copyWith(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDiscount
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDiscount
                                  ? Icons.discount_rounded
                                  : Icons.payments_outlined,
                              size: 18,
                              color: isDiscount
                                  ? const Color(0xFFEA580C)
                                  : const Color(0xFF1D4ED8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _offerMainValue(offer),
                              style: robotoBold.copyWith(
                                fontSize: 14,
                                color: isDiscount
                                    ? const Color(0xFF9A3412)
                                    : const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((offer.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          offer.description!,
                          style: robotoRegular.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if ((offer.expiryDate ?? '').isNotEmpty)
                            _offerInfoChip(
                              icon: Icons.event_outlined,
                              label: 'ينتهي: ${offer.expiryDate}',
                            ),
                          if ((offer.offerType ?? '').isNotEmpty)
                            _offerInfoChip(
                              icon: isDiscount
                                  ? Icons.local_offer_outlined
                                  : Icons.sell_outlined,
                              label: offer.offerType!,
                            ),
                        ],
                      ),
                      if ((offer.phoneProvider ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _makePhoneCall(offer.phoneProvider!);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFBFDBFE),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.call_outlined,
                                        size: 18,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'اتصال',
                                        style: robotoBold.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _openWhatsApp(
                                    phoneNumber: offer.phoneProvider!,
                                    estate: estate,
                                    offer: offer,
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 18,
                                        color: Color(0xFF059669),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'واتساب',
                                        style: robotoBold.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFF065F46),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          offer.phoneProvider!,
                          style: robotoMedium.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
bool _isDiscountOffer(ServiceOffers offer) {
  return (offer.discount ?? '').isNotEmpty && offer.discount != '0';
}

String _offerMainValue(ServiceOffers offer) {
  if (_isDiscountOffer(offer)) {
    return '${offer.discount}% خصم';
  }

  if ((offer.servicePrice ?? '').isNotEmpty && offer.servicePrice != '0') {
    return '${offer.servicePrice} ر.س';
  }

  return 'عرض خاص';
}

Widget _offerInfoChip({
  required IconData icon,
  required String label,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: 11,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    ),
  );
}

String _buildEstateShareMessage(Estate estate, {ServiceOffers? offer}) {
  final String title =
  estate.title?.isNotEmpty == true ? estate.title! : 'عقار';
  final String category =
  estate.categoryName?.isNotEmpty == true ? estate.categoryName! : 'عقار';
  final String space =
  estate.space?.isNotEmpty == true ? estate.space! : '-';
  final String price =
  estate.price?.isNotEmpty == true ? estate.price! : '-';
  final String city =
  estate.city?.isNotEmpty == true ? estate.city! : '-';
  final String districts =
  estate.districts?.isNotEmpty == true ? estate.districts! : '-';
  final String provider =
  offer?.provider_name?.isNotEmpty == true ? offer!.provider_name! : '-';
  final String offerTitle =
  offer?.title?.isNotEmpty == true ? offer!.title! : 'عرض مرفق';

  return '''
السلام عليكم
وجدت هذا العرض في تطبيق العقار وأرغب بالاستفسار عنه.

بيانات العقار:
العنوان: $title
النوع: $category
المدينة: $city
الحي: $districts
المساحة: $space
السعر: $price

بيانات العرض:
$offerTitle
مزود الخدمة: $provider

أرجو التواصل معي، شكرًا.
''';
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final String cleaned = phoneNumber
      .replaceAll(' ', '')
      .replaceAll('-', '');

  final Uri phoneUri = Uri(
    scheme: 'tel',
    path: cleaned,
  );

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    showCustomSnackBar('تعذر فتح الاتصال', isError: true);
  }
}

Future<void> _openWhatsApp({
  required String phoneNumber,
  required Estate estate,
  required ServiceOffers offer,
}) async {
  final String cleaned = phoneNumber
      .replaceAll(' ', '')
      .replaceAll('+', '')
      .replaceAll('-', '');

  final String message = _buildEstateShareMessage(
    estate,
    offer: offer,
  );

  final Uri waUri = Uri.parse(
    'https://wa.me/$cleaned?text=${Uri.encodeComponent(message)}',
  );

  if (await canLaunchUrl(waUri)) {
    await launchUrl(
      waUri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    showCustomSnackBar('تعذر فتح واتساب', isError: true);
  }
}





class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 ||
        oldDelegate.minExtent != 50 ||
        child != oldDelegate.child;
  }
}