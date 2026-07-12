import 'dart:async';

import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
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
  bool isSearchExpanded = false;
  List<int> selectedCategories = [];
  List<int> selectedZones = [];
  List<int> selectedServiceTypes = [];
  List<int> selectedProviders = [];

  String selectedOfferType = 'الكل';
  String sortBy = 'الأحدث';

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
    'ينتهي قريبًا',
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
    'ينتهي قريبًا': 'expiry_soon',
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

  void openSearch() {
    isSearchExpanded = true;
    update();
  }

  void closeSearch() {
    isSearchExpanded = false;
    if (searchController.text.isNotEmpty) {
      searchController.clear();
      searchText = '';
      getServicesList(1, reload: true);
    } else {
      update();
    }
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
    sortBy = sort;
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
    sortBy = 'الأحدث';
    searchText = '';
    searchController.clear();
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
