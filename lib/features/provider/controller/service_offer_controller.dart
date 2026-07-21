import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
import 'package:abaad_flutter/features/provider/data/models/service_offer_setup_model.dart';
import 'package:abaad_flutter/features/provider/data/repositories/service_offer_repo.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ServiceOfferController extends GetxController implements GetxService {
  final ServiceOfferRepo serviceOfferRepo;
  ServiceOfferController({required this.serviceOfferRepo});

  bool _isLoading = false;
  bool _isPriceLoading = false;
  bool _isSubmitting = false;

  // بيانات "ترقية مزود الخدمة" (فرد/منشأة) — تُجمع في ProviderUpgradeScreen
  // قبل بدء معالج إنشاء العرض، وتُرسل معه معاً في storeOffer().
  String? _entityType; // 'individual' | 'organization'
  // نوع رقم المنشأة (يظهر فقط لو entityType == 'organization'): كل خيار له
  // شكل تحقق مختلف، فلا نفقد شرط أي منهما بدمجهما بحقل واحد بلا تمييز.
  String? _organizationIdType; // 'commercial' | 'unified'
  final TextEditingController identityNumberController =
      TextEditingController();
  final TextEditingController freelanceMembershipController =
      TextEditingController();
  final TextEditingController commercialRegistrationController =
      TextEditingController();

  // صحيح فقط عندما جاءت بيانات الهوية من ملف مزوّد الخدمة المحفوظ بالباكند
  // (hydrateEntityFromProvider) بدل إدخال جديد عبر ProviderUpgradeScreen —
  // تُستخدَم في submitOffer() لتخطي إعادة التحقق من صيغة بيانات محفوظة سلفاً.
  bool _identityAlreadyOnFile = false;

  String? get entityType => _entityType;
  String? get organizationIdType => _organizationIdType;

  void setEntityType(String type) {
    _entityType = type;
    _organizationIdType = null;
    commercialRegistrationController.clear();
    update();
  }

  void setOrganizationIdType(String type) {
    _organizationIdType = type;
    commercialRegistrationController.clear();
    update();
  }

  /// يعبّئ بيانات الهوية من ملف مزوّد الخدمة المحفوظ بالباكند (service_providers)
  /// بدل مطالبة مزوّد معتمد سلفاً بإعادة إدخالها عبر ProviderUpgradeScreen.
  void hydrateEntityFromProvider(ProviderIdentity provider) {
    _entityType = provider.identityType == 'company' ? 'organization' : 'individual';
    if (provider.identityType == 'individual') {
      identityNumberController.text = provider.identityNumber ?? '';
    } else {
      commercialRegistrationController.text =
          provider.commercialRegistrationNo ?? '';
    }
    _identityAlreadyOnFile = true;
    update();
  }

  /// تحقّق من اختيار فرد/منشأة وصحة صيغة بيانات الهوية المدخلة — مشترك بين
  /// saveIdentityNow() (الحفظ الفوري من ProviderUpgradeScreen) وsubmitOffer()
  /// (كتأكيد إضافي غير ضار عند إرسال العرض). يعرض رسالة الخطأ المناسبة
  /// ويعيد false عند أول مخالفة، أو true لو كانت البيانات محفوظة سلفاً
  /// (identityAlreadyOnFile) فلا داعي لإعادة التحقق من صيغتها.
  bool _validateEntityIdentity() {
    if (_entityType == null) {
      showCustomSnackBar('اختر فرد أو منشأة');
      return false;
    }
    if (_identityAlreadyOnFile) {
      return true;
    }
    if (_entityType == 'individual') {
      final identityNumber = identityNumberController.text.trim();
      if (identityNumber.isEmpty) {
        showCustomSnackBar('رقم الهوية الوطنية مطلوب');
        return false;
      }
      if (!RegExp(r'^[12]\d{9}$').hasMatch(identityNumber)) {
        showCustomSnackBar('رقم الهوية يجب أن يتكون من 10 أرقام ويبدأ بـ 1 أو 2');
        return false;
      }
      final freelanceNumber = freelanceMembershipController.text.trim();
      if (freelanceNumber.isEmpty) {
        showCustomSnackBar('رقم وثيقة العمل الحر مطلوب');
        return false;
      }
      if (!RegExp(r'^FL-\d+$').hasMatch(freelanceNumber)) {
        showCustomSnackBar(
          'رقم وثيقة العمل الحر يجب أن يبدأ بـ FL- متبوعاً بأرقام (مثال: FL-240629681)',
        );
        return false;
      }
    } else if (_entityType == 'organization') {
      if (_organizationIdType == null) {
        showCustomSnackBar('اختر رقم السجل التجاري أو الرقم الموحد');
        return false;
      }
      final registrationNumber = commercialRegistrationController.text.trim();
      if (registrationNumber.isEmpty) {
        showCustomSnackBar(
          _organizationIdType == 'unified'
              ? 'الرقم الموحد مطلوب'
              : 'رقم السجل التجاري مطلوب',
        );
        return false;
      }
      final isUnified = _organizationIdType == 'unified';
      final regex = isUnified ? RegExp(r'^70\d{8}$') : RegExp(r'^\d{10}$');
      if (!regex.hasMatch(registrationNumber)) {
        showCustomSnackBar(
          isUnified
              ? 'الرقم الموحد يجب أن يتكون من 10 أرقام ويبدأ بـ 70'
              : 'رقم السجل التجاري يجب أن يتكون من 10 أرقام',
        );
        return false;
      }
    }
    return true;
  }

  /// حفظ فوري لبيانات الهوية في service_providers بمجرد إكمالها في
  /// ProviderUpgradeScreen، بدل انتظار إتمام معالج "إضافة خدمة" بالكامل —
  /// فلا تُفقَد لو غادر المستخدم المعالج قبل إكماله.
  Future<bool> saveIdentityNow() async {
    if (!_validateEntityIdentity()) {
      return false;
    }
    if (_identityAlreadyOnFile) {
      return true;
    }

    _isSubmitting = true;
    update();

    final response = await serviceOfferRepo.updateIdentity(
      entityType: _entityType!,
      identityNumber:
          _entityType == 'individual' ? identityNumberController.text.trim() : null,
      commercialRegistrationNo: _entityType == 'organization'
          ? commercialRegistrationController.text.trim()
          : null,
    );

    _isSubmitting = false;
    update();

    if (response.statusCode == 200 && response.body['status'] == 'success') {
      _identityAlreadyOnFile = true;
      update();
      return true;
    }

    final message = (response.body is Map)
        ? (response.body['message'] ?? 'فشل حفظ بيانات الهوية')
        : 'فشل حفظ بيانات الهوية';
    showCustomSnackBar(message);
    return false;
  }

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

  // موقع هذا العرض تحديداً (لا موقع مزوّد الخدمة العام) — يُختار في خطوة
  // "الموقع" من المعالج، إما عبر الموقع الحالي أو التقاط نقطة من الخارطة.
  double? _selectedLatitude;
  double? _selectedLongitude;
  String? _selectedAddress;

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
  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;
  String? get selectedAddress => _selectedAddress;
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
      PermissionStatus status = await Permission.photos.status;
      if (!status.isGranted && !status.isLimited) {
        status = await Permission.photos.request();
      }
      if (status.isPermanentlyDenied) {
        showCustomSnackBar('permission_permanently_denied_msg'.tr);
        await openAppSettings();
        return;
      }
      if (!status.isGranted && !status.isLimited) {
        showCustomSnackBar('فشل اختيار الصورة، تحقق من الصلاحيات');
        return;
      }

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

  /// يُستدعى من خطوة "الموقع" بالمعالج عند تحريك الخارطة أو التقاط الموقع
  /// الحالي — [address] اختياري (نتيجة عكس ترميز جغرافي) ويُعرض فقط، لا يؤثر
  /// على ما يُرسَل للباكند (latitude/longitude هما مصدر الحقيقة الوحيد).
  void setSelectedLocation(double latitude, double longitude, {String? address}) {
    _selectedLatitude = latitude;
    _selectedLongitude = longitude;
    _selectedAddress = address;
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
    if (_selectedLatitude == null || _selectedLongitude == null) {
      showCustomSnackBar('يجب تحديد موقع الخدمة على الخارطة');
      return null;
    }
    if (!_validateEntityIdentity()) {
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
      latitude: _selectedLatitude!,
      longitude: _selectedLongitude!,
      image: _pickedImage!,
      entityType: _entityType!,
      identityNumber: _entityType == 'individual'
          ? identityNumberController.text.trim()
          : null,
      freelanceMembershipNumber: _entityType == 'individual'
          ? freelanceMembershipController.text.trim()
          : null,
      commercialRegistrationNo: _entityType == 'organization'
          ? commercialRegistrationController.text.trim()
          : null,
      organizationIdType: _entityType == 'organization'
          ? _organizationIdType
          : null,
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

  // لا تُصفَّر بيانات فرد/منشأة (entityType وما يتبعها) هنا: تُجمَع في
  // ProviderUpgradeScreen مباشرة قبل الانتقال لهذا المعالج وتُرسَل معه في
  // storeOffer()، فتصفيرها في resetAll() (المستدعاة في initState() لهذا
  // المعالج) كانت تمحو تلك البيانات فور دخول المستخدم للخطوة الأولى — فيصل
  // للمراجعة النهائية ويُرفض submitOffer() بصمت لأن entityType أصبح null.
  void resetAll() {
    _selectedServiceTypeIndex = -1;
    _selectedPlanIndex = _servicePlans.isNotEmpty ? 0 : -1;
    _selectedCategoryIds.clear();
    _selectedZoneIds.clear();
    _selectedDuration = 1;
    _offerType = 'discount';
    _pickedImage = null;
    _priceCalculation = null;
    _selectedLatitude = null;
    _selectedLongitude = null;
    _selectedAddress = null;
    update();
  }
}
