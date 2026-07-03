import 'dart:convert';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/home/controller/banner_controller.dart';
import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/features/chat/controller/chat_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
import 'package:abaad_flutter/features/map/controller/location_controller.dart';
import 'package:abaad_flutter/features/notification/controller/notification_controller.dart';
import 'package:abaad_flutter/features/onboarding/controller/onboarding_controller.dart';
import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/controllers/theme_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/wallet/controller/wallet_controller.dart';
import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
import 'package:abaad_flutter/features/zones/controller/zone_controller.dart';
import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/features/language/data/models/language_model.dart';

import 'package:abaad_flutter/features/onboarding/data/repositories/splash_repo.dart';
import 'package:abaad_flutter/features/auth/data/repositories/auth_repo.dart';
import 'package:abaad_flutter/features/home/data/repositories/banner_repo.dart';
import 'package:abaad_flutter/features/category/data/repositories/category_repo.dart';
import 'package:abaad_flutter/features/chat/data/repositories/chat_repo.dart';
import 'package:abaad_flutter/features/estate/data/repositories/estate_repo.dart';
import 'package:abaad_flutter/features/language/data/repositories/language_repo.dart';
import 'package:abaad_flutter/features/map/data/repositories/location_repo.dart';
import 'package:abaad_flutter/features/notification/data/repositories/notification_repo.dart';
import 'package:abaad_flutter/features/onboarding/data/repositories/onboarding_repo.dart';
import 'package:abaad_flutter/features/services/data/repositories/services_repo.dart';
import 'package:abaad_flutter/features/profile/data/repositories/user_repo.dart';
import 'package:abaad_flutter/features/wallet/data/repositories/wallet_repo.dart';
import 'package:abaad_flutter/features/favourite/data/repositories/wishlist_repo.dart';
import 'package:abaad_flutter/features/zones/data/repositories/zone_repo.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

import 'package:abaad_flutter/features/provider/controller/provider_permission_controller.dart';
import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/provider/data/repositories/provider_permission_repo.dart';
import 'package:abaad_flutter/features/provider/data/repositories/service_offer_repo.dart';

Future<Map<String, Map<String, String>>> init() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  // Get.lazyPut(() => sharedPreferences);
  Get.lazyPut<SharedPreferences>(
    () => sharedPreferences,
  ); // 👈 register properly
  Get.lazyPut(
    () => ApiClient(
      appBaseUrl: AppConstants.BASE_URL,
      sharedPreferences: Get.find<SharedPreferences>(),
    ),
  );

  // Repository
  Get.lazyPut(
    () => SplashRepo(sharedPreferences: Get.find(), apiClient: Get.find()),
  );
  Get.lazyPut(() => LanguageRepo());
  Get.lazyPut(
    () => AuthRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
  );
  Get.lazyPut(() => EstateRepo(apiClient: Get.find()));
  Get.lazyPut(() => CategoryRepo(apiClient: Get.find()));
  Get.lazyPut(() => UserRepo(apiClient: Get.find()));
  Get.lazyPut(() => BannerRepo(apiClient: Get.find()));
  Get.lazyPut(
    () =>
        NotificationRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
  );
  Get.lazyPut(() => ZoneRepo(apiClient: Get.find()));
  Get.lazyPut(
    () => ChatRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
  );
  Get.lazyPut(() => WishListRepo(apiClient: Get.find()));
  Get.lazyPut(() => WalletRepo(apiClient: Get.find()));
  // Controller
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(splashRepo: Get.find()));
  Get.lazyPut(
    () => LocalizationController(
      sharedPreferences: Get.find(),
      apiClient: Get.find(),
    ),
  );
  Get.lazyPut(() => AuthController(authRepo: Get.find()));
  Get.lazyPut(() => LocationController(locationRepo: Get.find()));
  Get.lazyPut(
    () => LocationRepo(apiClient: Get.find(), sharedPreferences: Get.find()),
  );

  Get.lazyPut(() => OnBoardingController(onboardingRepo: Get.find()));
  Get.lazyPut(() => OnBoardingRepo());

  Get.lazyPut(() => EstateController(estateRepo: Get.find()));
  Get.lazyPut(() => CategoryController(categoryRepo: Get.find()));
  Get.lazyPut(() => UserController(userRepo: Get.find()));
  Get.lazyPut(() => BannerController(bannerRepo: Get.find()));
  Get.lazyPut(() => ZoneController(zoneRepo: Get.find()));
  Get.lazyPut(() => NotificationController(notificationRepo: Get.find()));
  Get.lazyPut(() => ChatController(chatRepo: Get.find()));
  Get.lazyPut(() => WishListController(wishListRepo: Get.find()));
  Get.lazyPut(() => WalletController(walletRepo: Get.find()));

  Get.lazyPut(() => ServiceOfferRepo(apiClient: Get.find()));
  Get.lazyPut(() => ServiceOfferController(serviceOfferRepo: Get.find()));

  Get.lazyPut(() => ServicesRepo(apiClient: Get.find()));
  Get.lazyPut(() => ServicesController(servicesRepo: Get.find()));

  Get.lazyPut(() => ProviderPermissionRepo(apiClient: Get.find()));
  Get.lazyPut(() => ProviderPermissionController(repo: Get.find()));

  // Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  for (LanguageModel languageModel in AppConstants.languages) {
    String jsonStringValues = await rootBundle.loadString(
      'assets/language/${languageModel.languageCode}.json',
    );
    Map<String, String> json = {};
    Map<String, dynamic> mappedJson = jsonDecode(
      jsonStringValues,
    ); // json.decode(jsonStringValues);
    mappedJson.forEach((key, value) {
      json[key] = value.toString();
    });
    languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
        json;
  }
  return languages;
}
