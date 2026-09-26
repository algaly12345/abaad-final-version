import 'dart:convert';

import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/features/estate/data/bodies/filter_body.dart';
import 'package:abaad_flutter/shared/data/models/category_model.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/features/estate/data/models/facilities_model.dart';
import 'package:abaad_flutter/features/category/data/repositories/category_repo.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:get/get.dart';

/// تحويل استجابة الخريطة إلى قائمة عقارات في Isolate منفصل.
/// موديل Estate فيه أكثر من 100 حقل + قوائم متداخلة، فتحويله على الـ UI
/// thread كان يسبب تجميدًا لحظيًا عند وصول البيانات.
/// (لازم تكون خارج الكلاس — top-level.)
List<Estate> parseMapEstatesInBackground(String body) {
  final dynamic decoded = jsonDecode(body);
  if (decoded is! Map<String, dynamic>) return <Estate>[];
  return EstateModel.fromJson(decoded).estates ?? <Estate>[];
}

class _MapCacheEntry {
  final List<Estate> estates;
  final DateTime time;
  _MapCacheEntry(this.estates, this.time);
}

class CategoryController extends GetxController implements GetxService {
  final CategoryRepo categoryRepo;
  CategoryController({required this.categoryRepo});

  List<CategoryModel>? _categoryList;

  List<FacilitiesModel>? _facilitiesList = [];
  List<OtherAdvantages>? _advanList = [];
  List<CategoryModel>? _subCategoryList = [];
  List<Estate>? _categoryRestList = [];
  List<Property>? _propertiesRestList = [];
  final List<Estate> _searchEstList = [];
  List<bool>? _interestSelectedList = [];
  List<bool>? _advanSelectedList = [];
  int _subCategoryIndex = 0;
  final int _filterIndex = 0;
  List<Estate>? _categoryProductList = [];
  EstateModel? _estateModel;
  Estate? _estate;

  List<FilterBody>? _filterList;

  bool _isLoading = false;
  int? _pageSize;
  int? _estPageSize;
  bool _isSearching = false;
  final String _type = 'all';
  bool _isEstates = false;
  final String _searchText = '';
  final int _offset = 1;
  final String _nameCityIndex = "";


  List<CategoryModel>? get categoryList => _categoryList;
  List<FacilitiesModel>? get facilitiesList => _facilitiesList;
  List<OtherAdvantages>? get advanList => _advanList;
  List<Estate>? get categoryRestList => _categoryRestList;
  List<Estate> get searchEstList => _searchEstList;
  List<bool>? get interestSelectedList => _interestSelectedList;
  List<bool>? get advanSelectedList => _advanSelectedList;
  bool get isLoading => _isLoading;
  int? get pageSize => _pageSize;
  int? get esttPageSize => _estPageSize;
  bool get isSearching => _isSearching;
  String get type => _type;
  bool get isRestaurant => _isEstates;
  String get searchText => _searchText;
  List<Property>? get proRestListp => _propertiesRestList;
  int get offset => _offset;
  int get subCategoryIndex => _subCategoryIndex;
  List<Estate>? get categoryProductList => _categoryProductList;
  List<CategoryModel>? get subCategoryList => _subCategoryList;
  int get filterIndex => _filterIndex;

  List<FilterBody>? get filterList => _filterList;

  String get nameCityIndex => _nameCityIndex;
  EstateModel? get estateModel => _estateModel;
  Estate? get estate => _estate;




  List<OtherAdvantages> advanLists = []; // Assuming you have a list of OtherAdvantages
  List<bool> advanSelectedLists = []; // Initial



  List<Estate>? _mapEstateList = [];
  List<Estate>? get mapEstateList => _mapEstateList;

  bool _isMapLoading = false;
  bool get isMapLoading => _isMapLoading;

  bool _isMapPaginating = false;
  bool get isMapPaginating => _isMapPaginating;

  bool _isMapLastPage = false;
  bool get isMapLastPage => _isMapLastPage;

  int _mapCurrentPage = 1;
  int get mapCurrentPage => _mapCurrentPage;

  /// ⚠️ كان 10 فقط — أي أن الخريطة لا تعرض أكثر من 10 عقارات في أي مكان،
  /// لأن شاشة الخريطة تطلب الصفحة الأولى فقط لكل مساحة.
  /// 100 رقم مناسب لخريطة (عقار يعرض أكثر)، بشرط أن السيرفر يحترم limit.
  /// لو الاستجابة ثقيلة جدًا (كل عقار فيه 100 حقل) خفّضه إلى 50.
  final int _mapLimit = 100;
  int get mapLimit => _mapLimit;

  /// رقم آخر طلب خريطة — أي رد أقدم منه يُتجاهل.
  int _mapRequestId = 0;

  /// كاش في الذاكرة: فتح نفس المنطقة مرة ثانية خلال 3 دقائق يكون فوريًا.
  final Map<String, _MapCacheEntry> _mapCache = {};
  static const Duration _mapCacheTtl = Duration(minutes: 3);
  static const int _mapCacheMax = 20;

  /// كاش قائمة التصنيفات (نادرًا ما تتغير) — كانت تُطلب من السيرفر مع كل
  /// فتح لشاشة الخريطة.
  List<CategoryModel>? _allCategoriesCache;


  Future<void> getCategoryList(bool reload) async {

    if(reload) {
      Response response = await categoryRepo.getCategoryList();
      if (response.statusCode == 200) {

        _categoryList = [];
        // _interestSelectedList = [];
        response.body.forEach((category) {
          _categoryList?.add(CategoryModel.fromJson(category));
          _isLoading=false;
          // _interestSelectedList.add(false);

        });
      } else {
        ApiChecker.checkApi(response, showToaster: true);
      }
      update();
    }
  }



  Future<void> getFacilitiesList(bool reload) async {

    if(reload) {
      Response response = await categoryRepo.getFacilities();
      if (response.statusCode == 200) {

        _facilitiesList = [];
        _interestSelectedList = [];
        response.body.forEach((category) {
          _facilitiesList?.add(FacilitiesModel.fromJson(category));
          _interestSelectedList?.add(false);

        });
      } else {
        ApiChecker.checkApi(response, showToaster: true);
      }
      update();
    }
  }

  Future<void> getAdvantages(bool reload) async {

    if(reload) {
      Response response = await categoryRepo.getAdvantages();
      if (response.statusCode == 200) {

        _advanList = [];
        _advanSelectedList = [];
        response.body.forEach((category) {
          _advanList?.add(OtherAdvantages.fromJson(category));
          _advanSelectedList?.add(false);
        });
      } else {
        ApiChecker.checkApi(response, showToaster: true);
      }
      update();
    }
  }





  void getPropertiesList(int categoryID) async {

    Response response = await categoryRepo.getProperties(categoryID);
    if (response.statusCode == 200) {

      // _propertiesRestList.add(Property.fromJson(response.body));
      // //print("musa abdalll ${response.body}");
      // _isLoading = false;


      _propertiesRestList = [];
      // _interestSelectedList = [];
      response.body.forEach((category) {
        _propertiesRestList?.add(Property.fromJson(category));
        // _interestSelectedList.add(false);

      });

    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
    update();
  }




  void showBottomLoader() {
    _isLoading = true;
    update();
  }

  void addInterestSelection(int index) {
    _interestSelectedList?[index] = !_interestSelectedList![index];
    update();
  }


  void addAdvantSelection(int index) {
    _advanSelectedList?[index] = !_advanSelectedList![index];
    update();
  }


  void updateAdvantSelection(int index) {
    _advanSelectedList?[index] = !_advanSelectedList![index];
    update();
  }

  void setRestaurant(bool isRestaurant) {
    _isEstates = isRestaurant;
    update();
  }

  /// [loadProducts]: الافتراضي true (نفس السلوك القديم لباقي الشاشات).
  /// شاشة الخريطة تمرر false لأنها لا تستخدم categoryProductList إطلاقًا —
  /// كانت تطلب 25 عقارًا كاملًا (لمنطقة رقم 1 ثابتة!) مع كل فتح بلا فائدة.
  Future<void> getSubCategoryList(
      String categoryID,
      int zone_id, {
        bool loadProducts = true,
      }) async {
    _subCategoryIndex = 0;
    if (loadProducts) {
      _categoryProductList = [];
      _currentPage = 1;
      _isLastPage = false;
    }

    if (_allCategoriesCache == null) {
      _subCategoryList = null;
      Response response = await categoryRepo.getCategoryList();
      if (response.statusCode != 200) {
        ApiChecker.checkApi(response, showToaster: true);
        return;
      }
      final List<CategoryModel> all = [];
      response.body.forEach((category) {
        all.add(CategoryModel.fromJson(category));
      });
      _allCategoriesCache = all;
    }

    _isLoading = false;
    _subCategoryList = [
      CategoryModel(
        id: int.parse(categoryID),
        nameAr: 'الكل'.tr,
        name: 'all',
        slug: '',
        position: '',
        statusHome: '',
        image: '',
        createdAt: '',
        updatedAt: '',
      ),
      ..._allCategoriesCache!,
    ];

    if (loadProducts) {
      await getCategoryProductList(
        zone_id,
        categoryID,
        0,
        '0',
        '0',
        '0',
        '0',
        reload: true,
        arPath: 0,
        sv: 0,
        type: "",
      );
    }

    update();
  }

  /// [loadList]: شاشة الخريطة تمرر false — هي تعيد التحميل بنفسها حسب
  /// الجزء الظاهر، فلا داعي لطلب قائمة عادية إضافية مع كل ضغطة تصنيف.
  void setSubCategoryIndex(int index, int zoneId, {bool loadList = true}) {
    _subCategoryIndex = index;

    if (loadList) {
      getCategoryProductList(
        zoneId,
        _subCategoryList![index].id.toString(),
        0,
        '0',
        '0',
        '0',
        '0',
        reload: true,
        arPath: 0,
        sv: 0,
        type: '',
      );
    }

    update();
  }



  String _filterCity = "0";
  String _filterDistrict = "0";
  String _filterSpace = "0";

  String get filterCity => _filterCity;
  String get filterDistrict => _filterDistrict;
  String get filterSpace => _filterSpace;

  /// [loadList]: شاشة المناطق تمرر false لأن الشاشة التالية (الخريطة) هي
  /// التي تجلب بياناتها — كان الضغط على منطقة يطلب قائمة 25 عقارًا كاملة
  /// لا تُعرض في أي مكان.
  void setFilterIndex(
      int zoneId,
      int index,
      String cityName,
      String districts,
      int space,
      int arPath,
      int sv,
      String type, {
        bool loadList = true,
      }) {
    _filterCity = cityName.isEmpty ? "0" : cityName;
    _filterDistrict = districts.isEmpty ? "0" : districts;
    _filterSpace = space.toString();

    if (loadList) {
      getCategoryProductList(
        zoneId,
        index.toString(),
        0,
        cityName.isEmpty ? "0" : cityName,
        districts.isEmpty ? "0" : districts,
        space.toString(),
        "0",
        reload: true,
        arPath: arPath,
        sv: sv,
        type: type,
      );
    }

    update();
  }


  bool _isPaginating = false;
  bool get isPaginating => _isPaginating;

  bool _isLastPage = false;
  bool get isLastPage => _isLastPage;

  int _currentPage = 1;
  int get currentPage => _currentPage;

  final int _limit = 25;
  int get limit => _limit;

  Future<void> getCategoryProductList(
      int zoneId,
      String categoryID,
      int userId,
      String city,
      String districts,
      String space,
      String typeAdd, {
        bool reload = false,
        int arPath = 0,
        int sv = 0,
        String type = '',
      }) async {
    if (reload) {
      _currentPage = 1;
      _isLastPage = false;
      _categoryProductList = [];
      _isLoading = true;
      update();
    }

    if (_isLastPage || _isPaginating) {
      return;
    }

    if (_currentPage == 1) {
      _isLoading = true;
    } else {
      _isPaginating = true;
    }
    update();

    int offset = (_currentPage - 1) * _limit;

    Response response = await categoryRepo.getCategoryProductList(
      zoneId,
      categoryID,
      userId,
      city,
      districts,
      space,
      typeAdd,
      _limit,
      offset,
      arPath,
      sv,
      type,
    );

    if (response.statusCode == 200) {
      EstateModel estateModel = EstateModel.fromJson(response.body);

      List<Estate> newData = [];
      if (estateModel.estates != null) {
        newData.addAll(estateModel.estates as Iterable<Estate>);
      }

      if (_currentPage == 1) {
        _categoryProductList = [];
      }

      _categoryProductList?.addAll(newData);
      _estateModel = estateModel;

      if (newData.length < _limit) {
        _isLastPage = true;
      } else {
        _currentPage++;
      }
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }

    _isLoading = false;
    _isPaginating = false;
    update();
  }

  String getNameCityIndex() {
    return _nameCityIndex;
  }

  // ============================ الخريطة ============================

  /// يُستدعى عند فتح شاشة الخريطة لمسح عقارات المنطقة السابقة.
  void clearMapEstates() {
    _mapRequestId++; // يلغي أي رد قديم ما زال في الطريق
    _mapEstateList = [];
    _mapCurrentPage = 1;
    _isMapLastPage = false;
    _isMapLoading = false;
    _isMapPaginating = false;
    update();
  }

  Future<void> getMapCategoryProductListByBounds(
      int zoneId,
      String categoryID,
      int userId,
      String city,
      String districts,
      String space,
      String typeAdd,
      double northEastLat,
      double northEastLng,
      double southWestLat,
      double southWestLng, {
        bool reload = false,
        int arPath = 0,
        int sv = 0,
        String type = '',
      }) async {
    if (reload) {
      _mapCurrentPage = 1;
      _isMapLastPage = false;
      // ⚠️ لا نفرّغ _mapEstateList هنا — العقارات الحالية تبقى ظاهرة حتى
      // يصل الرد الجديد (سابقًا كانت الخريطة تفرغ ثم ترجع مع كل تحريك).
    } else if (_isMapPaginating || _isMapLastPage) {
      return;
    }

    final int page = _mapCurrentPage;

    // الكاش: نفس الفلاتر ونفس المساحة تقريبًا (تقريب 3 خانات ≈ 100م).
    String r(double v) => v.toStringAsFixed(3);
    final String cacheKey = [
      zoneId, categoryID, userId, city, districts, space, typeAdd, arPath, sv,
      type, page, _mapLimit, r(northEastLat), r(northEastLng),
      r(southWestLat), r(southWestLng),
    ].join('|');

    final cached = _mapCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.time) < _mapCacheTtl) {
      _mapRequestId++;
      _applyMapPage(page, cached.estates);
      _isMapLoading = false;
      _isMapPaginating = false;
      update();
      return;
    }

    final int requestId = ++_mapRequestId;

    if (page == 1) {
      _isMapLoading = true;
    } else {
      _isMapPaginating = true;
    }
    update();

    Response response;
    try {
      response = await categoryRepo.getMapEstateList(
        zoneId,
        categoryID,
        userId,
        city,
        districts,
        space,
        typeAdd,
        _mapLimit,
        page,
        arPath,
        sv,
        type,
        northEastLat,
        northEastLng,
        southWestLat,
        southWestLng,
      );
    } catch (e) {
      if (requestId == _mapRequestId) {
        _isMapLoading = false;
        _isMapPaginating = false;
        update();
      }
      return;
    }

    // المستخدم حرّك الخريطة أو غيّر الفلتر أثناء الانتظار → رد قديم.
    if (requestId != _mapRequestId) return;

    if (response.statusCode == 200) {
      List<Estate> newEstates;
      final String? raw = response.bodyString;
      if (raw != null && raw.isNotEmpty) {
        try {
          newEstates = await compute(parseMapEstatesInBackground, raw);
        } catch (_) {
          newEstates =
              EstateModel.fromJson(response.body).estates ?? <Estate>[];
        }
      } else {
        newEstates = EstateModel.fromJson(response.body).estates ?? <Estate>[];
      }

      if (requestId != _mapRequestId) return;

      _applyMapPage(page, newEstates);

      if (_mapCache.length >= _mapCacheMax) {
        _mapCache.remove(_mapCache.keys.first);
      }
      _mapCache[cacheKey] = _MapCacheEntry(newEstates, DateTime.now());
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }

    _isMapLoading = false;
    _isMapPaginating = false;
    update();
  }

  void _applyMapPage(int page, List<Estate> estates) {
    if (page == 1) {
      _mapEstateList = List<Estate>.of(estates);
    } else {
      _mapEstateList = [...?_mapEstateList, ...estates];
    }
    if (estates.length < _mapLimit) {
      _isMapLastPage = true;
    } else {
      _isMapLastPage = false;
      _mapCurrentPage = page + 1;
    }
  }

// Method to toggle the selection of an advantage

}