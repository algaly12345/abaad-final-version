import 'dart:async';

import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/features/map/controller/location_controller.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/features/services/controller/nearby_location_helper.dart';
import 'package:abaad_flutter/features/services/data/repositories/services_repo.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ServicesController extends GetxController implements GetxService {
  final ServicesRepo servicesRepo;

  ServicesController({required this.servicesRepo});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isMyServicesLoading = false;
  bool get isMyServicesLoading => _isMyServicesLoading;

  bool _isDetailsLoading = false;
  bool get isDetailsLoading => _isDetailsLoading;

  // true فقط أثناء انتظار الإذن/الموقع الفعلي (قبل بدء إعادة تحميل القائمة) —
  // يسمح للواجهة بعرض حالة "جاري تحديد موقعك..." مميزة عن حالة تحميل القائمة العادية
  bool _isResolvingLocation = false;
  bool get isResolvingLocation => _isResolvingLocation;

  List<ServiceOffer>? _servicesList;
  List<ServiceOffer>? get servicesList => _servicesList;

  List<ServiceOffer>? _myServicesList;
  List<ServiceOffer>? get myServicesList => _myServicesList;

  FiltersData? _filtersData;
  FiltersData? get filtersData => _filtersData;

  ServiceOffer? _serviceDetails;
  ServiceOffer? get serviceDetails => _serviceDetails;

  int offset = 1;
  int? pageSize;
  bool isPaginating = false;

  bool get hasMore => (_servicesList?.length ?? 0) < (pageSize ?? 0);
  bool get hasMoreMyServices => (_myServicesList?.length ?? 0) < (pageSize ?? 0);

  String searchText = '';
  final TextEditingController searchController = TextEditingController();
  List<int> selectedCategories = [];
  List<int> selectedZones = [];
  List<int> selectedServiceTypes = [];
  List<int> selectedProviders = [];

  String selectedOfferType = 'الكل';
  String sortBy = 'الأحدث';

  // ─── "أقرب مزود خدمة": يُحاوَل تلقائياً مرة واحدة عند فتح شاشة الخدمات
  // (enableNearMe(silent: true))، ويبقى الزر اليدوي متاحاً لإعادة التفعيل ───
  bool nearMeActive = false;
  double? userLat;
  double? userLng;
  // القيم الممكنة: '5', '10', '25', '50', 'city' (city = بدون حد أقصى للمسافة)
  String radiusOption = 'city';

  // true إذا فشلت المحاولة التلقائية الصامتة (رفض/تعطيل) — تُستخدم لعرض
  // تلميح لطيف بدل رسالة مقتحمة، ويختفي بمجرد نجاح enableNearMe لاحقاً.
  bool nearMeAutoDenied = false;
  bool _autoNearMeAttempted = false;

  // ─── نطاق السعر: null يعني عدم تفعيل الفلتر بعد (يُضبط أول مرة من filtersData) ───
  double? minPriceFilter;
  double? maxPriceFilter;

  static const List<String> offerTypeOptions = [
    'الكل',
    'خصومات',
    'أسعار محددة',
  ];

  static const List<String> sortOptions = [
    'الأحدث',
    'الأقدم',
    'الأقل سعرًا',
    'الأعلى سعرًا',
    'أعلى خصم',
    'الأعلى تقييمًا',
    'ينتهي قريبًا',
    'الأقرب مني',
  ];

  static const List<Map<String, String>> radiusOptions = [
    {'value': '5', 'label': '٥ كم'},
    {'value': '10', 'label': '١٠ كم'},
    {'value': '25', 'label': '٢٥ كم'},
    {'value': '50', 'label': '٥٠ كم'},
    {'value': 'city', 'label': 'المدينة'},
  ];

  static const Map<String, String?> _offerTypeApiMap = {
    'الكل': null,
    'خصومات': 'discount',
    'أسعار محددة': 'price',
  };

  static const Map<String, String> _sortByApiMap = {
    'الأحدث': 'latest',
    'الأقدم': 'oldest',
    'الأقل سعرًا': 'price_asc',
    'الأعلى سعرًا': 'price_desc',
    'أعلى خصم': 'discount_desc',
    'الأعلى تقييمًا': 'rating_desc',
    'ينتهي قريبًا': 'expiry_soon',
    'الأقرب مني': 'nearest',
  };

  Timer? _debounce;

  Future<void> getServicesList(
    int currentOffset, {
    bool reload = false,
    bool myServices = false,
  }) async {
    if (reload) {
      offset = 1;
      if (myServices) {
        _myServicesList = null;
        _isMyServicesLoading = true;
      } else {
        _servicesList = null;
        _isLoading = true;
      }
      update();
    }

    try {
      final response = await servicesRepo.getServices(
        offset: currentOffset,
        myServices: myServices,
        search: searchText,
        categoryId: selectedCategories.join(','),
        zoneId: selectedZones.join(','),
        serviceTypeId: selectedServiceTypes.join(','),
        providerId: selectedProviders.join(','),
        offerType: _offerTypeApiMap[selectedOfferType],
        sortBy: _sortByApiMap[sortBy] ?? 'latest',
        latitude: nearMeActive ? userLat : null,
        longitude: nearMeActive ? userLng : null,
        radiusKm: (nearMeActive && radiusOption != 'city') ? radiusOption : null,
        minPrice: minPriceFilter,
        maxPrice: maxPriceFilter,
      );

      if (response.statusCode == 200 && response.body is Map) {
        final model = ServiceModel.fromJson(response.body);

        if (currentOffset == 1) {
          if (myServices) {
            _myServicesList = [];
          } else {
            _servicesList = [];
          }
        }

        if (myServices) {
          _myServicesList ??= [];
          _myServicesList!.addAll(model.services ?? []);
        } else {
          _servicesList ??= [];
          _servicesList!.addAll(model.services ?? []);
        }

        pageSize = model.totalSize;
        offset = currentOffset;
      } else {
        if (myServices) {
          _myServicesList ??= [];
        } else {
          _servicesList ??= [];
        }
        ApiChecker.checkApi(response, showToaster: true);
      }
    } catch (e) {
      if (myServices) {
        _myServicesList ??= [];
      } else {
        _servicesList ??= [];
      }
      showCustomSnackBar('تعذّر تحميل الخدمات');
    } finally {
      if (myServices) {
        _isMyServicesLoading = false;
      } else {
        _isLoading = false;
      }
      update();
    }
  }

  Future<void> getFilters() async {
    try {
      final response = await servicesRepo.getFiltersMetadata();
      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['data'] != null) {
        _filtersData = FiltersData.fromJson(response.body['data']);
      }
    } catch (e) {
      showCustomSnackBar('تعذّر تحميل الفلاتر');
    } finally {
      update();
    }
  }

  Future<void> getServiceDetails(int id) async {
    _isDetailsLoading = true;
    _serviceDetails = null;
    update();

    try {
      final response = await servicesRepo.getServiceDetails(id);

      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['data'] != null) {
        _serviceDetails = ServiceOffer.fromJson(response.body['data']);
      } else {
        ApiChecker.checkApi(response, showToaster: true);
      }
    } catch (e) {
      showCustomSnackBar('تعذّر تحميل تفاصيل الخدمة');
    } finally {
      _isDetailsLoading = false;
      update();
    }
  }

  Future<void> toggleServiceStatus(int id) async {
    try {
      final response = await servicesRepo.toggleServiceStatus(id);

      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['status'] == 'success') {
        showCustomSnackBar(
          response.body['message'] ?? 'تم تحديث حالة الخدمة',
          isError: false,
        );
        await getServicesList(1, reload: true, myServices: true);
      } else {
        final message = (response.body is Map)
            ? (response.body['message'] ?? 'فشل تحديث حالة الخدمة')
            : 'فشل تحديث حالة الخدمة';
        showCustomSnackBar(message);
      }
    } catch (e) {
      showCustomSnackBar('فشل تحديث حالة الخدمة');
    }
  }

  void searchServices(String text) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchText = text;
      getServicesList(1, reload: true);
    });
  }

  void toggleCategory(int id) {
    if (selectedCategories.contains(id)) {
      selectedCategories.remove(id);
    } else {
      selectedCategories.add(id);
    }
    update();
  }

  void toggleZone(int id) {
    if (selectedZones.contains(id)) {
      selectedZones.remove(id);
    } else {
      selectedZones.add(id);
    }
    update();
  }

  void toggleServiceType(int id) {
    if (selectedServiceTypes.contains(id)) {
      selectedServiceTypes.remove(id);
    } else {
      selectedServiceTypes.add(id);
    }
    update();
  }

  void toggleProvider(int id) {
    if (selectedProviders.contains(id)) {
      selectedProviders.remove(id);
    } else {
      selectedProviders.add(id);
    }
    update();
  }

  void setOfferType(String type) {
    selectedOfferType = type;
    update();
  }

  void setSortBy(String sort) {
    // "الأقرب مني" يحتاج موقعًا فعليًا أولاً؛ يُضبط عبر enableNearMe() بدلاً
    // من هذه الدالة (راجع filter_bottom_sheet.dart)
    if (sort != 'الأقرب مني') {
      nearMeActive = false;
    }
    sortBy = sort;
    update();
  }

  /// يعبّئ فلتر "المنطقة" تلقائيًا من عنوان المستخدم المحفوظ محليًا (إن وُجد)
  /// دون أي طلب إذن موقع جديد — يلبي "تظهر الخدمات بحسب منطقتي" افتراضيًا،
  /// بينما "الأقرب مني" (GPS حي) يبقى اختياريًا صراحةً عبر enableNearMe().
  void applySavedZoneDefault() {
    if (selectedZones.isNotEmpty) return;
    final savedZoneIds = Get.find<LocationController>().getUserAddress()?.zoneIds;
    if (savedZoneIds != null && savedZoneIds.isNotEmpty) {
      selectedZones = List<int>.from(savedZoneIds);
    }
  }

  /// يطلب الإذن ثم الموقع الحالي عبر NearbyLocationHelper، ثم يفعّل فرز/
  /// فلترة "الأقرب مني". [silent]: للمحاولة التلقائية عند فتح الشاشة —
  /// تُكتم رسائل الرفض عندها (راجع NearbyLocationHelper).
  Future<void> enableNearMe({bool silent = false}) async {
    if (silent) {
      if (_autoNearMeAttempted || nearMeActive) return;
      _autoNearMeAttempted = true;
    }

    _isResolvingLocation = true;
    update();

    final position =
        await NearbyLocationHelper.resolveCurrentPosition(silent: silent);

    _isResolvingLocation = false;
    if (position == null) {
      if (silent) nearMeAutoDenied = true;
      update();
      return;
    }

    userLat = position.latitude;
    userLng = position.longitude;
    nearMeActive = true;
    nearMeAutoDenied = false;
    sortBy = 'الأقرب مني';
    update();
    await getServicesList(1, reload: true);
  }

  void disableNearMe() {
    nearMeActive = false;
    userLat = null;
    userLng = null;
    radiusOption = 'city';
    sortBy = 'الأحدث';
    update();
    getServicesList(1, reload: true);
  }

  void setRadiusOption(String value) {
    radiusOption = value;
    update();
    if (nearMeActive) {
      getServicesList(1, reload: true);
    }
  }

  // ترتيب دفاعي: بعض تفاعلات RangeSlider (خصوصًا مع اتجاه RTL) قد تُرسل
  // start أكبر من end، فتُخزَّن القيم مقلوبة (مثال: "1 - 0")، ما يجعل فلتر
  // السعر يطلب مدى مستحيلًا فتختفي كل النتائج. الفرز هنا يمنع ذلك من المصدر.
  void setPriceRange(double min, double max) {
    minPriceFilter = min <= max ? min : max;
    maxPriceFilter = min <= max ? max : min;
    update();
  }

  void applyFilters() {
    Get.back();
    getServicesList(1, reload: true);
  }

  void clearFilters() {
    selectedCategories.clear();
    selectedZones.clear();
    selectedServiceTypes.clear();
    selectedProviders.clear();
    selectedOfferType = 'الكل';
    nearMeActive = false;
    userLat = null;
    userLng = null;
    radiusOption = 'city';
    sortBy = 'الأحدث';
    searchText = '';
    searchController.clear();
    minPriceFilter = null;
    maxPriceFilter = null;
    update();
    getServicesList(1, reload: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    searchController.dispose();
    super.onClose();
  }
}
