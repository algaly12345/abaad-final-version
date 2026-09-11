import 'dart:convert';

import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/shared/data/models/address_model.dart';
import 'package:abaad_flutter/features/language/data/models/language_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationController extends GetxController implements GetxService {
  final SharedPreferences sharedPreferences;
  final ApiClient apiClient;

  LocalizationController({required this.sharedPreferences, required this.apiClient}) {
    loadCurrentLanguage();
  }

  // الافتراضي العربية (تطبيق سعودي): يُستخدم فقط قبل قراءة التفضيل المحفوظ أو
  // حين لا يوجد تفضيل (تثبيت جديد فُتح عبر رابط عميق فتخطّى شاشة اختيار اللغة).
  Locale _locale = const Locale('ar', 'SA');
  bool _isLtr = true;
  List<LanguageModel> _languages = [];

  Locale get locale => _locale;
  bool get isLtr => _isLtr;
  List<LanguageModel> get languages => _languages;

  void setLanguage(Locale locale) {
    Get.updateLocale(locale);
    _locale = locale;
    _isLtr = _locale.languageCode != 'ar';
    AddressModel addressModel = AddressModel(id: 0, addressType: '', contactPersonNumber: '', address: '', latitude: '', longitude: '', zoneId: 0, zoneIds: [], method: '', contactPersonName: '', road: '', house: '', floor: '', zoneData: []);
    try {
      addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
    }catch(_) {}
    apiClient.updateHeader(
      sharedPreferences.getString(AppConstants.TOKEN) ?? "", addressModel.zoneIds ?? [],
      locale.languageCode,   "24.263867",
      "45.033284",
    );
    saveLanguage(_locale);



    update();

    Get.offNamed(RouteHelper.getInitialRoute());
  }

  void loadCurrentLanguage() async {
    // بلا تفضيل محفوظ → العربية (تطبيق سعودي)، لا languages[0] (الإنجليزية).
    _locale = Locale(sharedPreferences.getString(AppConstants.languageCode) ?? 'ar',
        sharedPreferences.getString(AppConstants.countryCode) ?? 'SA');
    _isLtr = _locale.languageCode != 'ar';
    for(int index = 0; index<AppConstants.languages.length; index++) {
      if(AppConstants.languages[index].languageCode == _locale.languageCode) {
        _selectedIndex = index;
        break;
      }
    }
    _languages = [];
    _languages.addAll(AppConstants.languages);
    update();
  }

  void saveLanguage(Locale locale) async {
    sharedPreferences.setString(AppConstants.languageCode, locale.languageCode);
    sharedPreferences.setString(AppConstants.countryCode, locale.countryCode ?? "SA");
  }

  int _selectedIndex = 0;

  int get selectedIndex => _selectedIndex;

  void setSelectIndex(int index) {
    _selectedIndex = index;
    update();
  }

  void searchLanguage(String query) {
    if (query.isEmpty) {
      _languages  = [];
      _languages = AppConstants.languages;
    } else {
      _selectedIndex = -1;
      _languages = [];
      for (var language in AppConstants.languages) {
        if (language.languageName.toLowerCase().contains(query.toLowerCase())) {
          _languages.add(language);
        }
      }
    }
    update();
  }
}