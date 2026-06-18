import 'dart:async';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/estate_controller.dart';
import 'package:abaad_flutter/data/api/api_checker.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/data/model/response/response_model.dart';
import 'package:abaad_flutter/data/model/response/userinfo_model.dart';
import 'package:abaad_flutter/data/repository/user_repo.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
//import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


class UserController extends GetxController implements GetxService {
  final UserRepo userRepo;
  UserController({required this.userRepo});

  UserInfoModel? _userInfoModel;
  UserInfoModel? _agentInfoModel;
  XFile? _pickedFile;
  XFile? get pickedFile => _pickedFile;
  bool _isLoading = false;
  EstateModel? _estateModel;
  final String _estateType = 'all';

  UserInfoModel? get userInfoModel => _userInfoModel;
  UserInfoModel? get agentInfoModel => _agentInfoModel;

  bool get isLoading => _isLoading;
  EstateModel? get estateModel => _estateModel;
  String get estateType => _estateType;

  var latitude = '0'.obs;
  var longitude = '0'.obs;
  var address = 'Getting Address..'.obs;
   StreamSubscription<Position>? streamSubscription;


  Future<ResponseModel> getUserInfo() async {
    _pickedFile = null;
    ResponseModel responseModel;
    Response? response = await userRepo.getUserInfo();
   //print("user respone =====================>${response?.body}");
    if (response.statusCode == 200) {
      _userInfoModel = UserInfoModel.fromJson(response.body);
      //print('---------------------------body${response?.body}');
      responseModel = ResponseModel(true, 'successful');
    } else {
      responseModel = ResponseModel(false, response.statusText.toString());
  //    ApiChecker.checkApi(response, showToaster: true);
    }
    update();
    return responseModel;
  }





  Future<ResponseModel> getUserInfoByID(int id) async {
    //print("mohammed  =====================>");
    _pickedFile = null;
    ResponseModel responseModel;
    Response? response = await userRepo?.getUserInfoById(id);
    //print("mohammed  =====================>${response?.body}");
    if (response?.statusCode == 200) {
      _agentInfoModel = UserInfoModel.fromJson(response?.body);
      responseModel = ResponseModel(true, 'successful');
    } else {
      responseModel = ResponseModel(false, response!.statusText.toString());
     // ApiChecker.checkApi(response, showToaster: true);
    }
    update();
    return responseModel;
  }

  /*Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String password) async {
    _isLoading = true;
    update();
    ResponseModel _responseModel;
    Response response = await userRepo.updateProfile(updateUserModel, password, _pickedFile);
    _isLoading = false;
    if (response.statusCode == 200) {
      Map map = jsonDecode(await response.body);
      String message = map["message"];
      _userInfoModel = updateUserModel;
      _responseModel = ResponseModel(true, message);
    } else {
      _responseModel = ResponseModel(false, response.statusText);
      //print('${response.statusCode} ${response.statusText}');
    }
    update();
    return _responseModel;
  }*/
  //
  // Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String token) async {
  //   _isLoading = true;
  //   update();
  //   ResponseModel responseModel;
  //   Response? response = await userRepo.updateProfile(updateUserModel, _pickedFile!, token);
  //   _isLoading = false;
  //   if (response.statusCode == 200) {
  //     _userInfoModel = updateUserModel;
  //     responseModel = ResponseModel(true, response.bodyString!);
  //     _pickedFile = null;
  //     getUserInfo();
  //     //print(response.bodyString);
  //   } else {
  //     responseModel = ResponseModel(false, response.statusText!);
  //     //print(response.statusText);
  //   }
  //   update();
  //   return responseModel;
  // }


  // Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String token) async {
  //   _isLoading = true;
  //   update();
  //   ResponseModel responseModel;
  //
  //   // تمرير الصورة فقط إذا كانت موجودة، وإلا null
  //   Response? response = await userRepo.updateProfile(updateUserModel, _pickedFile!, token);
  //
  //   _isLoading = false;
  //   if (response.statusCode == 200) {
  //     _userInfoModel = updateUserModel;
  //     responseModel = ResponseModel(true, response.bodyString!);
  //     _pickedFile = null;
  //     getUserInfo();
  //   } else {
  //     responseModel = ResponseModel(false, response.statusText!);
  //   }
  //
  //   update();
  //   return responseModel;
  // }


  Future<ResponseModel> updateUserInfo(UserInfoModel updateUserModel, String token) async {
    _isLoading = true;
    update();

    ResponseModel responseModel;

    // استدعاء الدالة بناءً على وجود صورة أو لا
    Response? response;
    if (_pickedFile != null) {
      response = await userRepo.updateProfile(updateUserModel, _pickedFile, token);
    } else {
      response = await userRepo.updateProfile(updateUserModel, null, token);
    }

    _isLoading = false;

    if (response.statusCode == 200) {
      _userInfoModel = updateUserModel;
      responseModel = ResponseModel(true, response.bodyString!);
      _pickedFile = null;
      getUserInfo();
    } else {
      responseModel = ResponseModel(false, response.statusText!);
    }

    update();
    return responseModel;
  }

  void pickImage() async {
    _pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    update();
  }

  void initData() {
    _pickedFile = null;
  }

  Future removeUser() async {
    _isLoading = true;
    update();
    Response? response ;

    if (response?.statusCode == 200) {
      showCustomSnackBar('your_account_remove_successfully'.tr);
      Get.find<AuthController>().clearSharedData();
      Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));

    }else{
      Get.back();
      ApiChecker.checkApi(response ?? Response() , showToaster: true);
    }
  }


  void updateUserWithNewData(Userinfo user) {
    _userInfoModel?.userinfo = user;
  }


  @override
  void onInit() async {
    super.onInit();
    //getLocation();
  }


  @override
  void onClose() {
    streamSubscription?.cancel();
  }

  // getLocation() async {
  //   bool serviceEnabled;
  //
  //   LocationPermission permission;
  //   // Test if location services are enabled.
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     // Location services are not enabled don't continue
  //     // accessing the position and request users of the
  //     // App to enable the location services.
  //     await Geolocator.openLocationSettings();
  //     return Future.error('Location services are disabled.');
  //   }
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       // Permissions are denied, next time you could try
  //       // requesting permissions again (this is also where
  //       // Android's shouldShowRequestPermissionRationale
  //       // returned true. According to Android guidelines
  //       // your App should show an explanatory UI now.
  //       return Future.error('Location permissions are denied');
  //     }
  //   }
  //   if (permission == LocationPermission.deniedForever) {
  //     // Permissions are denied forever, handle appropriately.
  //     return Future.error(
  //         'Location permissions are permanently denied, we cannot request permissions.');
  //   }
  //   // When we reach here, permissions are granted and we can
  //   // continue accessing the position of the device.
  //   streamSubscription =
  //       Geolocator.getPositionStream().listen((Position position) {
  //         latitude.value = '${position.latitude}';
  //         longitude.value = '${position.longitude}';
  //         //print("addressssssssssss");
  //         // getAddressFromLatLang(position);
  //       });
  //   //print("addressssssssssss");
  // }

  // Future<void> getAddressFromLatLang(Position position) async {
  //   List<Placemark> placemark =
  //   await placemarkFromCoordinates(position.latitude, position.longitude);
  //   Placemark place = placemark[0];
  //   address.value = ' ${place.subLocality}, ${place.locality},${place.country}';
  //   //print("adress-------------------------------------${place.locality},${place.country}");
  // }


  Future<void> getEstateByUser(int offset, bool reload,int userId) async {
    if (reload) {
      _estateModel = null;
      update();
    }
    Response? response = await userRepo?.getEstateList(offset, _estateType,userId);
    if (response?.statusCode == 200) {
      if (offset == 1) {
        _estateModel = EstateModel.fromJson(response?.body);
        //print("estate response ...............${response?.body}");
      } else {
        _estateModel?.totalSize = EstateModel
            .fromJson(response?.body)
            .totalSize;
        _estateModel?.offset = EstateModel
            .fromJson(response?.body)
            .offset;
        _estateModel?.estates?.addAll(EstateModel
            .fromJson(response?.body)
            .estates as Iterable<Estate>);
        Get.find<EstateController>() .getCategoryList(response?.body);
      }
      update();
    } else {
      ApiChecker.checkApi(response! , showToaster: true);
    }
  }


  String?  transId ;
  var random = ''.obs;
  int?  codeStatus ;

  // void validateNafath(String idNumber,BuildContext context) async {
  //   _isLoading = true;
  //   update();
  //   try {
  //     final response = await userRepo?.validateNafath(idNumber);
  //
  //     codeStatus=response?.statusCode;
  //     if (response?.statusCode != 200) {
  //       final errorMessage = response?.body['message']['message'].toString();
  //       Get.snackbar('Error', errorMessage!);
  //     } else {
  //       transId = response?.body['transId'];
  //       random.value = response?.body['random'];
  //       // Handle the successful response
  //       //print("----------$transId");
  //       //print("----------${random.value}");
  //
  //
  //       // AwesomeDialog(
  //       //   context: context,
  //       //   btnCancelColor:Theme.of(context).primaryColor ,
  //       //   btnOkColor: Theme.of(context).primaryColor,
  //       //   barrierColor: Theme.of(context).primaryColor,
  //       //   dialogType: DialogType.success,
  //       //   borderSide:  BorderSide(
  //       //     color:Theme.of(context).primaryColor,
  //       //     width: 2,
  //       //   ),
  //       //
  //       //   buttonsBorderRadius: const BorderRadius.all(
  //       //     Radius.circular(2),
  //       //   ),
  //       //   dismissOnTouchOutside: true,
  //       //   dismissOnBackKeyPress: false,
  //       //   onDismissCallback: (type) {
  //       //     ScaffoldMessenger.of(context).showSnackBar(
  //       //       SnackBar(
  //       //         content: Text('Dismissed by $type'),
  //       //       ),
  //       //     );
  //       //   },
  //       //   headerAnimationLoop: false,
  //       //   animType: AnimType.bottomSlide,
  //       //   title: '$random',
  //       //   desc: 'click_on_confirm_the_authentication_process'.tr,
  //       //   showCloseIcon: true,
  //       //   btnOkOnPress: () {
  //       //     //print("--------------------------------------------idNumber-${idNumber}random  $random transId$transId ");
  //       //     checkRequestStatus(idNumber,transId!,random.toString());
  //       //   },
  //       // ).show();
  //
  //     }
  //   } catch (e) {
  //
  //     Get.snackbar('Error', e.toString());
  //   } finally {
  //     _isLoading = false;
  //   }
  // }
  //
  //


  Future<void> validateNafath(String idNumber, BuildContext context) async {
    _isLoading = true;
    update();
    try {
      final response = await userRepo?.validateNafath(idNumber);

      codeStatus = response?.statusCode;

      if (response?.statusCode == 200) {
        // نجاح العملية
        transId = response?.body['transId'];
        random.value = response?.body['random'];

        Get.snackbar('Success', 'تم إنشاء طلب التحقق بنجاح');

        // عرض الديالوج المخصص مع إرسال الطلب تلقائيًا
        showVerificationDialogAuto(context, idNumber, transId!, random.value);

      } else if (response?.statusCode == 400) {
        final errorMessage = response?.body['message']['message'].toString();
        if (errorMessage != null && errorMessage.contains("There Is Active Trx")) {
          Get.snackbar('تنبيه', 'يوجد عملية تحقق سابقة لم تنته بعد. حاول لاحقًا.');
        } else {
          Get.snackbar('خطأ', errorMessage ?? 'حدث خطأ غير معروف');
        }

      } else {
        final errorMessage = response?.body['message']['message'].toString();
        Get.snackbar('خطأ', errorMessage ?? 'حدث خطأ غير معروف');
      }

    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      _isLoading = false;
      update();
    }
  }

  // تعديل checkRequestStatus لإرجاع bool
  Future<bool> checkRequestStatus(String nationalId, String transId, String random) async {
    final response = await userRepo?.checkRequestStatus(nationalId, transId, random);

    if (response?.statusCode == 200) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      showCustomSnackBar('registration_successful'.tr, isError: false);
      return true;
    } else {
      final errorMessage = response?.body['message']['message'].toString();
      showCustomSnackBar(errorMessage ?? 'حدث خطأ');
      return false;
    }
  }

  // Future<ResponseModel?> checkRequestStatus(String nationalId, String transId, String random) async {
  //   final response = await userRepo?.checkRequestStatus(nationalId,transId,random);
  //
  //   if (response?.statusCode == 200) {
  //     Get.offAllNamed(RouteHelper.getInitialRoute() );
  //     showCustomSnackBar('registration_successful'.tr, isError: false);
  //
  //   } else {
  //     final errorMessage = response?.body['message']['message'].toString();
  //   //  Get.snackbar('Error', errorMessage);
  //     showCustomSnackBar(errorMessage!);
  //     //print("=============================================$errorMessage");
  //     //print("=============================================${response?.body}");
  //     //throw Exception('Failed to check status: ${response.body}');
  //   }
  //   return null;
  // }
  //

  void showVerificationDialogAuto(BuildContext context, String idNumber, String transId, String random) {
    int countdown = 60; // الوقت بالثواني
    Timer? timerCountdown;
    Timer? timerRequest;

    showDialog(
      context: context,
      barrierDismissible: false, // منع الإغلاق باللمس خارج الديالوج
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // بدء العد التنازلي
            if (timerCountdown == null) {
              timerCountdown = Timer.periodic(const Duration(seconds: 1), (t) {
                if (countdown == 0) {
                  t.cancel();
                  timerRequest?.cancel(); // إيقاف طلبات التحقق
                  Navigator.of(context).pop(); // اغلاق الديالوج
                } else {
                  setState(() {
                    countdown--;
                  });
                }
              });
            }

            // بدء إرسال الطلب كل 5 ثواني
            if (timerRequest == null) {
              timerRequest = Timer.periodic(const Duration(seconds: 5), (t) async {
                bool success = await checkRequestStatus(idNumber, transId, random);
                if (success) {
                  t.cancel();
                  timerCountdown?.cancel();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                }
              });
            }

            return Dialog(
              backgroundColor: Colors.white.withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Text(
                        random,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'click_on_confirm_the_authentication_process'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Time remaining: $countdown s',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            timerCountdown?.cancel();
                            timerRequest?.cancel();
                            Navigator.of(context).pop(); // اغلاق الديالوج
                          },
                          child: Text(
                            'Cancel'.tr,
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).then((_) {
      timerCountdown?.cancel();
      timerRequest?.cancel();
    });
  }
}


