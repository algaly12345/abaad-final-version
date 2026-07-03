import 'package:abaad_flutter/features/provider/data/models/service_offer_setup_model.dart';
import 'package:abaad_flutter/features/provider/data/repositories/service_offer_repo.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ServiceOfferController extends GetxController implements GetxService {
  final ServiceOfferRepo serviceOfferRepo;
  ServiceOfferController({required this.serviceOfferRepo});

  bool _isLoading = false;
  bool _isPriceLoading = false;
  bool _isSubmitting = false;

  List<ServiceTypeModel> _serviceTypes = [];
  List<OfferCategoryModel> _categories = [];
  List<OfferZoneModel> _zones = [];
  List<ServicePlanModel> _servicePlans = [];

  int _selectedServiceTypeIndex = -1;
  int _selectedPlanIndex = -1;
  final Set<int> _selectedCategoryIds = {};
  final Set<int> _selectedZoneIds = {};
  int _selectedDuration = 1; // أشهر

  String _offerType = 'discount'; // discount | price
  XFile? _pickedImage;

  PriceCalculationModel? _priceCalculation;

  bool get isLoading => _isLoading;
  bool get isPriceLoading => _isPriceLoading;
  bool get isSubmitting => _isSubmitting;
  List<ServiceTypeModel> get serviceTypes => _serviceTypes;
  List<OfferCategoryModel> get categories => _categories;
  List<OfferZoneModel> get zones => _zones;
  List<ServicePlanModel> get servicePlans => _servicePlans;
  int get selectedServiceTypeIndex => _selectedServiceTypeIndex;
  int get selectedPlanIndex => _selectedPlanIndex;
  Set<int> get selectedCategoryIds => _selectedCategoryIds;
  Set<int> get selectedZoneIds => _selectedZoneIds;
  int get selectedDuration => _selectedDuration;
  String get offerType => _offerType;
  XFile? get pickedImage => _pickedImage;
  PriceCalculationModel? get priceCalculation => _priceCalculation;

  ServicePlanModel? get selectedPlan =>
      (_selectedPlanIndex >= 0 && _selectedPlanIndex < _servicePlans.length)
      ? _servicePlans[_selectedPlanIndex]
      : null;

  String get expiryDateText {
    final date = DateTime.now().add(Duration(days: 30 * _selectedDuration));
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> loadSetupData() async {
    _isLoading = true;
    update();

    Response response = await serviceOfferRepo.getOfferSetupData();

    if (response.statusCode == 200 && response.body['status'] == 'success') {
      final OfferSetupDataModel data = OfferSetupDataModel.fromJson(
        response.body['data'],
      );
      _serviceTypes = data.serviceTypes ?? [];
      _categories = data.categories ?? [];
      _zones = data.zones ?? [];
      _servicePlans = data.servicePlans ?? [];

      if (_servicePlans.isNotEmpty) {
        int basicIndex = 0;
        for (int i = 0; i < _servicePlans.length; i++) {
          if ((_servicePlans[i].price ?? 0) <
              (_servicePlans[basicIndex].price ?? 0)) {
            basicIndex = i;
          }
        }
        _selectedPlanIndex = basicIndex;
      }
    } else {
      showCustomSnackBar('فشل جلب بيانات الإعداد، حاول لاحقًا');
    }

    _isLoading = false;
    update();
    recalculatePrice();
  }

  void selectServiceType(int index) {
    _selectedServiceTypeIndex = index;
    update();
  }

  void setOfferType(String type) {
    _offerType = type;
    update();
  }

  void selectPlan(int index) {
    _selectedPlanIndex = index;
    final plan = selectedPlan;
    final allowed = plan?.numberOfCategories ?? 0;
    if (allowed > 0 && _selectedCategoryIds.length > allowed) {
      final list = _selectedCategoryIds.toList();
      _selectedCategoryIds.clear();
      _selectedCategoryIds.addAll(list.take(allowed));
      showCustomSnackBar(
        'تم تعديل أنواع العقار المختارة حسب حدود الباقة الجديدة',
      );
    }
    update();
    recalculatePrice();
  }

  void toggleCategory(int id) {
    final allowed = selectedPlan?.numberOfCategories ?? 0;
    if (_selectedCategoryIds.contains(id)) {
      _selectedCategoryIds.remove(id);
    } else {
      if (allowed > 0 && _selectedCategoryIds.length >= allowed) {
        showCustomSnackBar('باقتك تسمح باختيار $allowed نوع عقار فقط');
        return;
      }
      _selectedCategoryIds.add(id);
    }
    update();
  }

  void toggleZone(int id) {
    if (_selectedZoneIds.contains(id)) {
      _selectedZoneIds.remove(id);
    } else {
      _selectedZoneIds.add(id);
    }
    update();
    recalculatePrice();
  }

  void selectDuration(int months) {
    _selectedDuration = months;
    update();
    recalculatePrice();
  }

  void pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        _pickedImage = image;
        update();
      }
    } catch (e) {
      showCustomSnackBar('فشل اختيار الصورة، تحقق من الصلاحيات');
    }
  }

  void removeImage() {
    _pickedImage = null;
    update();
  }

  Future<void> recalculatePrice() async {
    final plan = selectedPlan;
    if (plan?.id == null) return;

    _isPriceLoading = true;
    update();

    Response response = await serviceOfferRepo.calculatePrice(
      servicePlanId: plan!.id!,
      subscriptionDuration: _selectedDuration,
      zonesCount: _selectedZoneIds.length,
    );

    if (response.statusCode == 200 && response.body['status'] == 'success') {
      _priceCalculation = PriceCalculationModel.fromJson(response.body['data']);
    }

    _isPriceLoading = false;
    update();
  }

  Future<StoreOfferResponseModel?> submitOffer({
    required String title,
    required String description,
    required String priceOrDiscountValue,
  }) async {
    if (title.trim().isEmpty) {
      showCustomSnackBar('عنوان العرض مطلوب');
      return null;
    }
    if (_selectedServiceTypeIndex < 0) {
      showCustomSnackBar('اختر نوع الخدمة');
      return null;
    }
    if (priceOrDiscountValue.trim().isEmpty) {
      showCustomSnackBar(
        _offerType == 'discount' ? 'نسبة الخصم مطلوبة' : 'السعر مطلوب',
      );
      return null;
    }
    if (description.trim().isEmpty) {
      showCustomSnackBar('وصف الخدمة مطلوب');
      return null;
    }
    if (_pickedImage == null) {
      showCustomSnackBar('صورة العرض مطلوبة');
      return null;
    }
    if (selectedPlan?.id == null) {
      showCustomSnackBar('اختر الباقة المناسبة');
      return null;
    }
    if (_selectedCategoryIds.isEmpty) {
      showCustomSnackBar('يجب اختيار نوع عقار واحد على الأقل');
      return null;
    }
    if (_selectedZoneIds.isEmpty) {
      showCustomSnackBar('يجب اختيار منطقة واحدة على الأقل');
      return null;
    }

    _isSubmitting = true;
    update();

    Response response = await serviceOfferRepo.storeOffer(
      title: title.trim(),
      serviceType: _serviceTypes[_selectedServiceTypeIndex].name ?? '',
      offerType: _offerType,
      servicePrice: _offerType == 'price' ? priceOrDiscountValue.trim() : null,
      discount: _offerType == 'discount' ? priceOrDiscountValue.trim() : null,
      description: description.trim(),
      servicePlanId: selectedPlan!.id!,
      subscriptionDuration: _selectedDuration,
      categories: _selectedCategoryIds.toList(),
      zones: _selectedZoneIds.toList(),
      image: _pickedImage!,
    );

    _isSubmitting = false;
    update();

    if (response.statusCode == 201 && response.body['status'] == 'success') {
      return StoreOfferResponseModel.fromJson(response.body['data']);
    } else {
      final message = (response.body is Map)
          ? (response.body['message'] ?? 'فشلت العملية')
          : 'فشلت العملية';
      showCustomSnackBar(message);
      return null;
    }
  }

  Future<bool> checkSubscriptionStatus(String subscriptionNumber) async {
    Response response = await serviceOfferRepo.getSubscriptionStatus(
      subscriptionNumber,
    );
    if (response.statusCode == 200 && response.body['status'] == 'success') {
      return response.body['data']['is_paid'] == true;
    }
    return false;
  }

  void resetAll() {
    _selectedServiceTypeIndex = -1;
    _selectedPlanIndex = _servicePlans.isNotEmpty ? 0 : -1;
    _selectedCategoryIds.clear();
    _selectedZoneIds.clear();
    _selectedDuration = 1;
    _offerType = 'discount';
    _pickedImage = null;
    _priceCalculation = null;
    update();
  }
}
