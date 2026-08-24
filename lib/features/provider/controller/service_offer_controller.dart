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
      freelanceMembershipController.text = provider.freelanceMembershipNumber ?? '';
    } else {
      commercialRegistrationController.text =
          provider.commercialRegistrationNo ?? '';
    }
    _identityAlreadyOnFile = true;
    update();
  }

  /// تحقّق من اختيار فرد/منشأة فقط — مشترك بين saveIdentityNow() (الحفظ
  /// الفوري من ProviderUpgradeScreen) وsubmitOffer() (كتأكيد إضافي غير ضار
  /// عند إرسال العرض). لا يتحقق من صيغة/اكتمال أرقام الهوية عمداً: يُسمح
  /// بإرسالها ناقصة أو بصيغة غير مكتملة مع العرض لأن هناك مراجعة يدوية لاحقة
  /// (لوحة الأدمن) تتحقق من صحتها، فلا داعي لحجب المستخدم في هذه الخطوة.
  bool _validateEntityIdentity() {
    if (_entityType == null) {
      showCustomSnackBar('اختر فرد أو منشأة');
      return false;
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
      freelanceMembershipNumber: _entityType == 'individual'
          ? freelanceMembershipController.text.trim()
          : null,
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
  SubscriptionPricingSettingsModel _pricingSettings =
      SubscriptionPricingSettingsModel();
  List<DurationDiscountModel> _durationDiscounts = [];

  int _selectedServiceTypeIndex = -1;
  final Set<int> _selectedCategoryIds = {};
  final Set<int> _selectedZoneIds = {};
  int _selectedDuration = 1; // أشهر

  // تصنيف رقم التواصل الخاص بهذا العرض — يحدّد أزرار الاتصال/واتساب التي
  // تظهر لاحقاً في شاشة تفاصيل الخدمة.
  String _contactType = 'both'; // whatsapp | call | both

  String get contactType => _contactType;

  void setContactType(String type) {
    _contactType = type;
    update();
  }

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
  SubscriptionPricingSettingsModel get pricingSettings => _pricingSettings;
  List<DurationDiscountModel> get durationDiscounts => _durationDiscounts;
  int get selectedServiceTypeIndex => _selectedServiceTypeIndex;
  Set<int> get selectedCategoryIds => _selectedCategoryIds;
  Set<int> get selectedZoneIds => _selectedZoneIds;
  int get selectedDuration => _selectedDuration;
  String get offerType => _offerType;
  XFile? get pickedImage => _pickedImage;
  double? get selectedLatitude => _selectedLatitude;
  double? get selectedLongitude => _selectedLongitude;
  String? get selectedAddress => _selectedAddress;
  PriceCalculationModel? get priceCalculation => _priceCalculation;

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
      _pricingSettings = data.pricingSettings ?? SubscriptionPricingSettingsModel();
      _durationDiscounts = data.durationDiscounts ?? [];
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

  /// لا سقف على عدد الأنواع المختارة — كل نوع إضافي عن الحد المشمول (1) يرفع
  /// السعر بـ [pricingSettings.extraCategoryPrice] بدل رفضه، فيُعاد حساب
  /// السعر مباشرة (على خلاف toggleZone كانت toggleCategory سابقًا لا تُعيد
  /// الحساب لأن الأنواع لم تكن تُسعَّر في نظام الباقات القديم).
  void toggleCategory(int id) {
    if (_selectedCategoryIds.contains(id)) {
      _selectedCategoryIds.remove(id);
    } else {
      _selectedCategoryIds.add(id);
    }
    update();
    recalculatePrice();
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

  // شعار مزوّد الخدمة (service_providers.image) — حالة منفصلة عن _pickedImage
  // (صورة العرض) حتى لا يتداخل رفع أحدهما مع الآخر.
  XFile? _pickedLogo;
  bool _isUploadingLogo = false;
  XFile? get pickedLogo => _pickedLogo;
  bool get isUploadingLogo => _isUploadingLogo;

  Future<void> pickLogo() async {
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
        _pickedLogo = image;
        update();
      }
    } catch (e) {
      showCustomSnackBar('فشل اختيار الصورة، تحقق من الصلاحيات');
    }
  }

  /// يرفع الشعار المختار إلى service_providers.image، ثم يُفرغ الاختيار
  /// المحلي — استدعاء getUserInfo() بعدها من الشاشة يُحدّث userInfoModel.provider.image
  /// فيُعرض الشعار الجديد من الباكند بدل الملف المحلي المؤقت.
  Future<bool> uploadLogo() async {
    if (_pickedLogo == null) return false;

    _isUploadingLogo = true;
    update();

    final response = await serviceOfferRepo.updateLogo(_pickedLogo!);

    _isUploadingLogo = false;

    if (response.statusCode == 200 && response.body['status'] == 'success') {
      _pickedLogo = null;
      update();
      return true;
    }

    update();
    final message = (response.body is Map)
        ? (response.body['message'] ?? 'فشل تحديث الشعار')
        : 'فشل تحديث الشعار';
    showCustomSnackBar(message);
    return false;
  }

  // ─── عنوان "عمل" مزوّد الخدمة (service_providers.address) — يُجمَع في
  // CompleteProviderProfileScreen قبل أول عرض، ومنفصل تمامًا عن
  // _selectedAddress أدناه الخاص بموقع العرض نفسه لا عنوان مزوّد الخدمة العام
  // (راجع تعليق setSelectedLocation). المنطقة والموقع الجغرافي استُبعدا من
  // هذه الشاشة بناءً على طلب صريح.
  final TextEditingController businessAddressController = TextEditingController();
  bool _isSavingBusinessInfo = false;

  bool get isSavingBusinessInfo => _isSavingBusinessInfo;

  /// حفظ عنوان العمل — الحقل الوحيد الذي تجمعه CompleteProviderProfileScreen
  /// حاليًا من قسم "بيانات العمل" (إلى جانب الشعار المُرفَع بشكل منفصل).
  /// العنوان بيانات ضرورية لكنها لا تُحجب المتابعة: يُرسَل فارغًا لو لم
  /// يكتبه المستخدم، ويُستكمل/يُراجَع يدويًا لاحقًا بدل منعه من الاستمرار الآن.
  Future<bool> saveBusinessInfoNow() async {
    final address = businessAddressController.text.trim();

    _isSavingBusinessInfo = true;
    update();

    final response = await serviceOfferRepo.updateBusinessInfo(address: address);

    _isSavingBusinessInfo = false;
    update();

    if (response.statusCode == 200 && response.body['status'] == 'success') {
      return true;
    }

    final message = (response.body is Map)
        ? (response.body['message'] ?? 'فشل حفظ بيانات النشاط')
        : 'فشل حفظ بيانات النشاط';
    showCustomSnackBar(message);
    return false;
  }

  // ─── ربط رقم جوال جديد بحساب مصادَق عبر OTP (لمن سجّل عبر جوجل/فيسبوك
  // وبقي users.phone فارغًا — راجع SocialAuthController بالباكند) — يظهر
  // فقط في CompleteProviderProfileScreen عند نقص الرقم. التحقق الناجح هو
  // الحفظ نفسه بالباكند (auth()->user()->phone)، فلا حاجة لاستدعاء إضافي.
  final TextEditingController businessPhoneController = TextEditingController();
  bool _isSendingPhoneOtp = false;
  bool _isPhoneOtpSent = false;
  bool _isVerifyingPhoneOtp = false;
  bool _isPhoneVerified = false;

  bool get isSendingPhoneOtp => _isSendingPhoneOtp;
  bool get isPhoneOtpSent => _isPhoneOtpSent;
  bool get isVerifyingPhoneOtp => _isVerifyingPhoneOtp;
  bool get isPhoneVerified => _isPhoneVerified;

  Future<bool> sendBusinessPhoneOtp() async {
    final phone = businessPhoneController.text.trim();
    if (!RegExp(r'^0?5\d{8}$').hasMatch(phone)) {
      showCustomSnackBar('أدخل رقم جوال سعودي صحيح (يبدأ بـ 05)');
      return false;
    }

    _isSendingPhoneOtp = true;
    update();

    final response = await serviceOfferRepo.sendPhoneOtp(phone: phone);

    _isSendingPhoneOtp = false;

    if (response.statusCode == 200 && response.body['status'] == 'success') {
      _isPhoneOtpSent = true;
      update();
      return true;
    }

    update();
    // ردود الخطأ هنا بصيغة {errors: [{code, message}]} — ApiClient.handleResponse
    // ينقل الرسالة تلقائياً إلى statusText (راجع lib/core/api/api_client.dart).
    showCustomSnackBar(response.statusText ?? 'فشل إرسال رمز التحقق');
    return false;
  }

  /// تُستخدَم من صفّ "إعادة الإرسال" — نفس sendBusinessPhoneOtp() فعليًا،
  /// موجودة باسم منفصل ليكون القصد واضحًا من واجهة الشاشة.
  Future<bool> resendBusinessPhoneOtp() => sendBusinessPhoneOtp();

  Future<bool> verifyBusinessPhoneOtp(String otp) async {
    if (otp.trim().length != 4) return false;

    _isVerifyingPhoneOtp = true;
    update();

    final response = await serviceOfferRepo.verifyPhoneOtp(
      phone: businessPhoneController.text.trim(),
      otp: otp.trim(),
    );

    _isVerifyingPhoneOtp = false;

    if (response.statusCode == 200 && response.body['status'] == 'success') {
      _isPhoneVerified = true;
      update();
      return true;
    }

    update();
    showCustomSnackBar(
        response.statusText ?? 'رمز التحقق غير صحيح أو منتهي الصلاحية');
    return false;
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
    _isPriceLoading = true;
    update();

    Response response = await serviceOfferRepo.calculatePrice(
      subscriptionDuration: _selectedDuration,
      zonesCount: _selectedZoneIds.length,
      categoriesCount: _selectedCategoryIds.length,
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
    required String contactPhone,
    String? address,
  }) async {
    if (title.trim().isEmpty) {
      showCustomSnackBar('عنوان العرض مطلوب');
      return null;
    }
    if (contactPhone.trim().isEmpty) {
      showCustomSnackBar('رقم التواصل مطلوب');
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
      address: address?.trim(),
      contactPhone: contactPhone.trim(),
      contactType: _contactType,
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

  /// يولّد رابط دفع جديد لاشتراك غير مدفوع (unpaid/failed) — يُستدعى من زر
  /// "ادفع الآن" في شاشة تفاصيل الخدمة بديلاً عن رابط الدفع الأصلي المنتهي
  /// الصلاحية (ساعتان من إنشاء العرض).
  Future<Map<String, String>?> resumePayment(String subscriptionNumber) async {
    final response = await serviceOfferRepo.resumePayment(subscriptionNumber);

    if (response.statusCode == 200 && response.body['status'] == 'success') {
      final data = response.body['data'];
      return {
        'url': data['payment_url'] as String,
        'number': data['subscription_number'] as String,
      };
    }

    final message = (response.body is Map)
        ? (response.body['message'] ?? 'تعذر بدء عملية الدفع')
        : 'تعذر بدء عملية الدفع';
    showCustomSnackBar(message);
    return null;
  }

  // لا تُصفَّر بيانات فرد/منشأة (entityType وما يتبعها) هنا: تُجمَع في
  // ProviderUpgradeScreen مباشرة قبل الانتقال لهذا المعالج وتُرسَل معه في
  // storeOffer()، فتصفيرها في resetAll() (المستدعاة في initState() لهذا
  // المعالج) كانت تمحو تلك البيانات فور دخول المستخدم للخطوة الأولى — فيصل
  // للمراجعة النهائية ويُرفض submitOffer() بصمت لأن entityType أصبح null.
  void resetAll() {
    _selectedServiceTypeIndex = -1;
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
