import 'dart:async';
import 'dart:convert';

import 'package:abaad_flutter/features/map/controller/location_controller.dart';
import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/features/estate/data/bodies/business_plan_body.dart';
import 'package:abaad_flutter/features/auth/data/models/signup_body.dart';
import 'package:abaad_flutter/shared/data/models/address_model.dart';
import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  AuthRepo({required this.apiClient, required this.sharedPreferences});


  // Future<Response> login({String? phone, String ?password }) async {
  //
  //   return await apiClient.postData(AppConstants.LOGIN_URI, {"phone": phone, "password": password}, headers: {});
  // }



  Future<Response> login({String? phone, String? password}) async {
    return await apiClient.postData(AppConstants.LOGIN_URI, {"phone": phone, "password": password});
  }

  Future<Response> registration(SignUpBody signUpBody) async {
    return await apiClient.postData(AppConstants.REGISTER_URI, signUpBody.toJson());
 //   return await apiClient.postData(AppConstants.REGISTER_URI, signUpBody.toJson(), headers: {});
  }





  Future<Response> getZoneList() async {
    return await apiClient.getData(AppConstants.ZONE_ALL);
  }



  StreamSubscription<String>? _tokenRefreshSubscription;

  /// يطلب صلاحية الإشعارات (iOS)، يحصل على FCM token، يشترك في القناة العامة
  /// ويرسل التوكن للباك اند. يُستدعى بعد تسجيل الدخول وعند إقلاع التطبيق
  /// لمستخدم مسجّل دخوله بالفعل.
  Future<Response?> updateToken() async {
    if (GetPlatform.isWeb) return null;

    if (GetPlatform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      final NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus != AuthorizationStatus.authorized &&
          settings.authorizationStatus !=
              AuthorizationStatus.provisional) {
        return null;
      }
    }

    final String? deviceToken = await _saveDeviceToken();
    if (deviceToken == null || deviceToken.isEmpty) return null;

    await FirebaseMessaging.instance.subscribeToTopic(AppConstants.TOPIC);

    _tokenRefreshSubscription ??=
        FirebaseMessaging.instance.onTokenRefresh.listen((String newToken) {
      if (isLoggedIn()) {
        apiClient.postData(
          AppConstants.TOKEN_URI,
          {"cm_firebase_token": newToken},
        );
      }
    });

    return await apiClient.postData(
      AppConstants.TOKEN_URI,
      {"cm_firebase_token": deviceToken},
    );
  }

  Future<String?> _saveDeviceToken() async {
    try {
      final String? deviceToken = await FirebaseMessaging.instance.getToken();
      if (deviceToken != null) {
        debugPrint('--------Device Token---------- $deviceToken');
      }
      return deviceToken;
    } catch (_) {
      return null;
    }
  }


  Future<Response> verifyToken(String phone, String token) async {
    return await apiClient.postData(AppConstants.VERIFY_TOKEN_URI, {"phone": phone, "reset_token": token},);
  }





  Future<Response> updateZone() async {
    return await apiClient.getData(AppConstants.UPDATE_ZONE_URL, query: {});
  }


  // Future<bool> saveUserToken(String token, {bool alreadyInApp = false}) async {
  //   apiClient.token = token;
  //
  //   if(alreadyInApp && sharedPreferences.getString(AppConstants.userAddress) != null){
  //     AddressModel? addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
  //     apiClient.updateHeader(
  //       token, addressModel.zoneIds, sharedPreferences.getString(AppConstants.languageCode),
  //       addressModel.latitude, addressModel.longitude,
  //     );
  //   }else{
  //     apiClient.updateHeader(token, null, sharedPreferences.getString(AppConstants.languageCode),null, null);
  //   }
  //
  //
  //   sharedPreferences.setString('token', token);
  //
  //   // return await sharedPreferences.setString(AppConstants.TOKEN, token);
  // }

  Future<bool> saveUserToken(String token, {bool alreadyInApp = false}) async {
    apiClient.token = token;


    //print("header ------------------$token");

    if(alreadyInApp){
      AddressModel addressModel = AddressModel.fromJson(jsonDecode(sharedPreferences.getString(AppConstants.userAddress)!));
      apiClient.updateHeader(
        token,
        addressModel.zoneIds!,
        sharedPreferences.getString(AppConstants.languageCode)!,
        addressModel.latitude!,
        addressModel.longitude!,
      );
    }else{
      apiClient.updateHeader(
          token,
          [],
          sharedPreferences.getString(AppConstants.languageCode)!,
          "",
          ""
      );
    }

    return await sharedPreferences.setString(AppConstants.TOKEN, token);
  }


  String getUserToken() {
    return sharedPreferences.getString(AppConstants.TOKEN) ?? "";
  }

  bool isLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.TOKEN);
  }

  bool clearSharedData() {
    if(!GetPlatform.isWeb) {
      FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.TOPIC);
      apiClient.postData(AppConstants.TOKEN_URI, {"cm_firebase_token": '@'});
    }
    sharedPreferences.remove(AppConstants.TOKEN);
    sharedPreferences.remove(AppConstants.userAddress);
    apiClient.token = null;
    apiClient.updateHeader("", [], "", "", "");
    return true;
  }

  // for  Remember Email
  Future<void> saveUserNumberAndPassword(String number, String password, String countryCode) async {
    try {
      await sharedPreferences.setString(AppConstants.USER_PASSWORD, password);
      await sharedPreferences.setString(AppConstants.USER_NUMBER, number);
      await sharedPreferences.setString(AppConstants.USER_COUNTRY_CODE, countryCode);
    } catch (e) {
      rethrow;
    }
  }

  String getUserNumber() {
    return sharedPreferences.getString(AppConstants.USER_NUMBER) ?? "";
  }

  String getUserCountryCode() {
    return sharedPreferences.getString(AppConstants.USER_COUNTRY_CODE) ?? "";
  }

  String getUserPassword() {
    return sharedPreferences.getString(AppConstants.USER_PASSWORD) ?? "";
  }

  bool isNotificationActive() {
    return sharedPreferences.getBool(AppConstants.NOTIFICATION) ?? true;
  }

  void setNotificationActive(bool isActive) {
    if(isActive) {
      updateToken();
    }else {
      if(!GetPlatform.isWeb) {
        FirebaseMessaging.instance.unsubscribeFromTopic(AppConstants.TOPIC);
      }
    }
    sharedPreferences.setBool(AppConstants.NOTIFICATION, isActive);
  }

  Future<bool> clearUserNumberAndPassword() async {
    await sharedPreferences.remove(AppConstants.USER_PASSWORD);
    await sharedPreferences.remove(AppConstants.USER_COUNTRY_CODE);
    return await sharedPreferences.remove(AppConstants.USER_NUMBER);
  }

  bool clearSharedAddress(){
    sharedPreferences.remove(AppConstants.userAddress);
    return true;
  }
  Future<Response> verifyPhone(String? phone, String otp) async {
    return await apiClient.postData(AppConstants.VERIFY_PHONE_URI, {"phone": phone, "otp": otp});
  }



  // Future<Response> verifyPhone(String? phone, String? otp) async {
  //   return await apiClient.postData(AppConstants.VERIFY_PHONE_URI, {"phone": phone, "otp": otp}, headers: {});
  // }



  Future<Response> registerAgent(Userinfo agnetBody) async {
    return apiClient.postData(AppConstants.REGISTER_AS_AGENT, agnetBody.toJson(), headers: {});
  }


  Future<Response> getPackageList() async {
    return await apiClient.getData(AppConstants.RESTAURANT_PACKAGES_URI, query: {}, headers: {});
  }

  Future<Response> setUpBusinessPlan(BusinessPlanBody businessPlanBody) async {
    return await apiClient.postData(AppConstants.BUSINESS_PLAN_URI, businessPlanBody.toJson(), headers: {});
  }


}