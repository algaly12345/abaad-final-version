
import 'dart:convert';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/banner_controller.dart';
import 'package:abaad_flutter/controller/category_controller.dart';
import 'package:abaad_flutter/controller/chat_controller.dart';
import 'package:abaad_flutter/controller/estate_controller.dart';
import 'package:abaad_flutter/controller/localization_controller.dart';
import 'package:abaad_flutter/controller/location_controller.dart';
import 'package:abaad_flutter/controller/notification_controller.dart';
import 'package:abaad_flutter/controller/onboarding_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/theme_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/controller/wallet_controller.dart';
import 'package:abaad_flutter/controller/wishlist_controller.dart';
import 'package:abaad_flutter/controller/zone_controller.dart';
import 'package:abaad_flutter/data/api/api_client.dart';
import 'package:abaad_flutter/data/model/response/language_model.dart';

import 'package:abaad_flutter/data/model/response/splash_repo.dart';
import 'package:abaad_flutter/data/repository/auth_repo.dart';
import 'package:abaad_flutter/data/repository/banner_repo.dart';
import 'package:abaad_flutter/data/repository/category_repo.dart';
import 'package:abaad_flutter/data/repository/chat_repo.dart';
import 'package:abaad_flutter/data/repository/estate_repo.dart';
import 'package:abaad_flutter/data/repository/language_repo.dart';
import 'package:abaad_flutter/data/repository/location_repo.dart';
import 'package:abaad_flutter/data/repository/notification_repo.dart';
import 'package:abaad_flutter/data/repository/onboarding_repo.dart';
import 'package:abaad_flutter/data/repository/user_repo.dart';
import 'package:abaad_flutter/data/repository/wallet_repo.dart';
import 'package:abaad_flutter/data/repository/wishlist_repo.dart';
import 'package:abaad_flutter/data/repository/zone_repo.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  // Get.lazyPut(() => sharedPreferences);
  Get.lazyPut<SharedPreferences>(() => sharedPreferences); // 👈 register properly
  Get.lazyPut(() => ApiClient(appBaseUrl: AppConstants.BASE_URL, sharedPreferences: Get.find<SharedPreferences>()));

  // Repository
  Get.lazyPut(() => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => LanguageRepo());
  Get.lazyPut(() => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => EstateRepo(apiClient: Get.find()));
  Get.lazyPut(() => CategoryRepo(apiClient: Get.find()));
  Get.lazyPut(() => UserRepo(apiClient: Get.find()));
  Get.lazyPut(() => BannerRepo(apiClient: Get.find()));
  Get.lazyPut(() => NotificationRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => ZoneRepo(apiClient: Get.find()));
  Get.lazyPut(() => ChatRepo(apiClient: Get.find(), sharedPreferences: Get.find()));
  Get.lazyPut(() => WishListRepo(apiClient: Get.find()));
  Get.lazyPut(() => WalletRepo(apiClient: Get.find()));
  // Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find(), apiClient: Get.find()));
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => LocationController(locationRepo: Get.find()));
  Get.lazyPut(() => LocationRepo(apiClient: Get.find(), sharedPreferences: Get.find()));

  Get.lazyPut(() => OnBoardingController(onboardingRepo: Get.find()));
  Get.lazyPut(() => OnBoardingRepo());

  Get.lazyPut(() => EstateController(estateRepo: Get.find()));
  Get.lazyPut(() =>CategoryController(categoryRepo: Get.find()));
  Get.lazyPut(() => UserController(userRepo: Get.find()));
  Get.lazyPut(() => BannerController(bannerRepo: Get.find()));
  Get.lazyPut(() => ZoneController(zoneRepo: Get.find()));
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => ChatController(chatRepo: Get.find()));
  Get.lazyPut(() => WishListController(wishListRepo: Get.find()));
  Get.lazyPut(() => WalletController(walletRepo: Get.find()));

  // Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  for(LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues =  await rootBundle.loadString('assets/language/${languageModel.languageCode}.json');
    Map<String, String> json = {};
    Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);// json.decode(jsonStringValues);
    mappedJson.forEach((key, value) {
      json[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] = json;
  }
  return languages;
}
