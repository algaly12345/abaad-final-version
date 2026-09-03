import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/shared/data/models/config_model.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/features/onboarding/data/repositories/splash_repo.dart';
import 'package:chottu_link/chottu_link.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashController extends GetxController implements GetxService {
  final SplashRepo splashRepo;
  SplashController({required this.splashRepo});

  ConfigModel? _configModel;
  bool _firstTimeConnectionCheck = true;
  bool _hasConnection = true;
  int _nearestRestaurantIndex = -1;

  ConfigModel? get configModel => _configModel;
  DateTime get currentTime => DateTime.now();
  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;
  bool get hasConnection => _hasConnection;
  int get nearestEstateIndex => _nearestRestaurantIndex;

  Future<bool> getConfigData() async {
    _hasConnection = true;

    // الخطوة 1: اعرض الإعدادات المخزَّنة محلياً فوراً إن وُجدت
    // (يجعل فتح التطبيق فورياً في كل مرة عدا أول تشغيل)
    final cachedData = splashRepo.getCachedConfigData();
    if (cachedData != null) {
      try {
        _configModel = ConfigModel.fromJson(cachedData);
        update();
      } catch (_) {
        // تجاهل أي خطأ في الكاش القديم، سنعتمد على الشبكة أدناه
      }
    }

    // الخطوة 2: اطلب أحدث نسخة من السيرفر (سواء ظهرت نسخة الكاش أو لا)
    Response response = await splashRepo.getConfigData();
    bool isSuccess = false;

    if (response.statusCode == 200) {
      _configModel = ConfigModel.fromJson(response.body);
      // احفظ النسخة الجديدة للاستخدام الفوري في المرة القادمة
      splashRepo.cacheConfigData(response.body);
      isSuccess = true;
    } else {
      // لو فشلت الشبكة لكن لدينا نسخة مخزَّنة، اعتبرها نجاحاً جزئياً
      // (التطبيق يعمل بالبيانات القديمة بدل التوقف بالكامل)
      if (cachedData != null) {
        isSuccess = true;
      } else {
        ApiChecker.checkApi(response, showToaster: true);
        isSuccess = false;
      }

      if (response.statusText == ApiClient.noInternetMessage) {
        _hasConnection = false;
      }
    }

    _applyChottuLinkConfig();

    update();
    return isSuccess;
  }

  /// يخزّن مفتاح ChottuLink للجوال ونطاقه (الواصلَين ضمن /api/v1/config من
  /// جدول business_settings) في SharedPreferences ليقرأهما main() مبكرًا في
  /// الفتح البارد التالي، ويُهيّئ الـ SDK الآن إن لم يكن مُهيّأً بعد (أول
  /// تشغيل، أو تدوير المفتاح). مجرّد تحسين — لا يعطّل شيئًا عند غياب القيم.
  void _applyChottuLinkConfig() {
    if (!GetPlatform.isMobile) return;

    final String key = _configModel?.chottulinkSdkKey ?? '';
    final String domain = _configModel?.chottulinkDomain ?? '';
    final SharedPreferences prefs = Get.find<SharedPreferences>();

    if (domain.isNotEmpty) {
      prefs.setString(AppConstants.CHOTTULINK_DOMAIN_PREF, domain);
      AppConstants.chottulinkDomain = domain;
    }
    if (key.isNotEmpty) {
      prefs.setString(AppConstants.CHOTTULINK_SDK_KEY_PREF, key);
      if (!ChottuLink.isInitialized()) {
        _initChottuLink(key);
      }
    }
  }

  Future<void> _initChottuLink(String key) async {
    try {
      await ChottuLink.init(apiKey: key);
    } catch (e) {
      debugPrint('ChottuLink init error: $e');
    }
  }

  Future<bool> initSharedData() {
    return splashRepo.initSharedData();
  }

  bool? showIntro() {
    return splashRepo.showIntro();
  }

  void disableIntro() {
    splashRepo.disableIntro();
  }

  void setFirstTimeConnectionCheck(bool isChecked) {
    _firstTimeConnectionCheck = isChecked;
  }

  void setNearestEstateIndex(int index, {bool notify = true}) {
    _nearestRestaurantIndex = index;
    if (notify) {
      update();
    }
  }
}