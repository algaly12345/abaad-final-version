import 'dart:convert';

import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/features/estate/data/bodies/estate_body.dart';
import 'package:abaad_flutter/shared/data/models/category_model.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/features/estate/data/repositories/estate_repo.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
class EstateController extends GetxController implements GetxService {
  final EstateRepo estateRepo;

  EstateController({required this.estateRepo});

  var currentStep = 0.obs;
  EstateModel? _estateModel;
  EstateModel? _estateModel1;
  List<Estate>? _estateList;
  Estate? _restaurant;
  Estate? _estate;
  int _categoryIndex = 0;
  int _categoryPostion = 0;

  int _categoryName = 0;

  List<CategoryModel>? _categoryList;
  bool _isLoading = false;
  String _estateType = 'all';
  final String _type = 'all';
  final String _searchType = 'all';
  final String _searchText = '';
  int _foodOffset = 1;
  final List<int> _foodOffsetList = [];
  int? _foodPageSize;
  bool _foodPaginate = false;
  XFile? _pickedLogo;
  XFile? _pickedCover;
  List<Property>? _categoryRestList;
  XFile? _pickedImage;
  XFile? _pickedPlanedImage;
  List<XFile> _pickedIdentities = [];

  List<XFile> _pickPlaned = [];
  int _currentIndex = 0;
  String? _address;

  List<int> _categoryIds = [];

  final List<String> _tagList = [];
  List<String> options = [
    "ممرات مكيفة",
    "التحكم بالستائر",
    "التحكم باإنارة",
    "اطلالة بحرية",
    "الدخول الزكي",
    "التحكم بالتكيف"
  ];
  final List<String> _reportList = ['مالك عقار', 'وسيط عقاري'];

  Rx<List<String>> selectedOptionList = Rx<List<String>>([]);
  var selectedOption = ''.obs;
  List<bool>? _advantagesSelectedList;

  int _reportIndex = 0;

  EstateModel? get estateModel => _estateModel;
  EstateModel? get estateModel1 => _estateModel1;

  List<Estate>? get estateList => _estateList;

  Estate? get estate => _estate;

  int get categoryIndex => _categoryIndex;

  List<CategoryModel>? get categoryList => _categoryList;

  bool get isLoading => _isLoading;

  String get estateType => _estateType;

  String get type => _type;

  String get searchType => _searchType;

  String get searchText => _searchText;

  XFile? get pickedLogo => _pickedLogo;

  XFile? get pickedCover => _pickedCover;

  List<Property>? get categoryRestList => _categoryRestList;

  List<String> get tagList => _tagList;

  int get categoryPostion => _categoryPostion;

  int get categoryName => _categoryName;

  XFile? get pickedImage => _pickedImage;
  XFile? get pickedPlanedImage => _pickedPlanedImage;

  List<XFile> get pickedIdentities => _pickedIdentities;
  List<XFile> get pickPlaned => _pickPlaned;

  int get currentIndex => _currentIndex;

  String? get address => _address;
  List<bool>? get advantagesSelectedList => _advantagesSelectedList;
  List<int> get categoryIds => _categoryIds;
  Estate? get restaurant => _restaurant;
  List<String> get reportList => _reportList;
  RxBool isLoading2 = false.obs;




  int advertiserType = 0; // القيمة الافتراضية 0

  void setAdvertiserType(String type) {
    if (type == 'فرد') {
      advertiserType = 1;
    } else if (type == 'منشأة') {
      advertiserType = 2;
    } else {
      advertiserType = 0; // قيمة افتراضية إذا لم يتم تحديد النوع
    }
    update(); // تحديث واجهة المستخدم
  }


  Future<void> getEstateList(int offset, bool reload ,int categoryId) async {
    if (reload) {
      _estateModel = null;
      update();
    }
    Response response = await estateRepo.getEstateList(offset, _estateType,0,0);
    if (response.statusCode == 200) {
      if (offset == 1) {
        _estateModel = EstateModel.fromJson(response.body);
        // //print("estate response ...............${response.body}");
      } else {
        _estateModel?.totalSize = EstateModel.fromJson(response.body).totalSize;
        _estateModel?.offset = EstateModel.fromJson(response.body).offset;
        _estateModel?.estates?.addAll(EstateModel.fromJson(response.body).estates as Iterable<Estate>);
      }
      update();
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
  }


  void setReportIndex(String dmType, bool notify) {
    _reportIndex = _reportList.indexOf(dmType);
    if(notify) {
      update();
    }
  }

  void setRestaurantType(String type) {
    _estateType = type;
    update();
  }



  void setCategoryList() {
    _categoryList = [];
    _categoryList?.add(CategoryModel(id: 0, name: 'all'.tr, nameAr: '', slug: '', position: '', statusHome: '', image: '', createdAt: '', updatedAt: ''));
    Get.find<CategoryController>().categoryList?.forEach((category) {
      _categoryList?.add(category);

    });
  }


  void showBottomLoader() {
    _isLoading = true;
    update();
  }


  void setCategoryIndex(int index) {

    _categoryIndex = index;
    getEstateList(1, false, 1);
    update();
    //    estateList.clear();
  }

  void setCategoryPostion(int index) {
    _categoryPostion = index;
    update();
  }


  void setCategoryName(int index) {
    _categoryName = index;
    update();
  }


  int getCategoryIndex() {
    return _categoryIndex;
  }

  int getCategoryPostion() {
    return _categoryPostion;
  }


  int getCategoryName() {
    return _categoryPostion;
  }

  void setFoodOffset(int offset) {
    _foodOffset = offset;
  }


  void showFoodBottomLoader() {
    _foodPaginate = true;
    update();
  }

  // Future<EstateModel?> getEstateDetails(Estate estate) async {
  //   _estate = estate;
  //
  //   //print("--------------------${_estateModel!.estates!.length}");
  //     return _estateModel;
  // }



  // Future<EstateModel> getEstateDetails(Estate estate) async {
  //   if (estate.shortDescription != null) {
  //     _estate = estate;
  //   } else {
  //     _isLoading = true;
  //     _estate = null;
  //     Response response = await estateRepo.getEstateDetails(estate.id.toString());
  //     if (response.statusCode == 200) {
  //       _estate = Estate.fromJson(response.body);
  //     } else {
  //       // ApiChecker.checkApi(response);
  //       ApiChecker.checkApi(response, showToaster: true);
  //     }
  //     _isLoading = false;
  //     update();
  //   }
  //   return _estateModel!;
  // }

  Future<Estate> getEstateDetails(Estate estate) async {
    if (estate.shortDescription != null) {
      _estate = estate;
    } else {
      _isLoading = true;
      _estate = null;

      Response response = await estateRepo.getEstateDetails(estate.id.toString());

      if (response.statusCode == 200) {
        _estate = Estate.fromJson(response.body);
      } else {
        ApiChecker.checkApi(response, showToaster: true);
      }

      _isLoading = false;
      update();
    }

    return _estate!;
  }


  void pickImage(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedLogo = null;
      _pickedCover = null;
    } else {
      if (isLogo) {
        _pickedLogo =
        await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        _pickedCover =
        await ImagePicker().pickImage(source: ImageSource.gallery);
      }
      update();
    }
  }



  void pickDmImage(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedImage = null;
      _pickedIdentities = [];
    } else {
      if (isLogo) {
        _pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        XFile? xFile = await ImagePicker().pickImage(
            source: ImageSource.gallery);
        _pickedIdentities.add(xFile!);
      }
      update();
    }
  }


  void pickPlanedImage(bool isLogo, bool isRemove) async {
    if (isRemove) {
      _pickedPlanedImage = null;
      _pickPlaned = [];
    } else {
      if (isLogo) {
        _pickedPlanedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
      } else {
        XFile? xFile = await ImagePicker().pickImage(
            source: ImageSource.gallery);
        _pickPlaned.add(xFile!);
      }
      update();
    }
  }

  void removeIdentityImage(int index) {
    _pickedIdentities.removeAt(index);
    update();
  }



  void removePlanedImage(int index) {
    _pickPlaned.removeAt(index);
    update();
  }





  Future<void> addEstate(EstateBody estateBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoading = true;
    update();


    Response response = await estateRepo.addEstate(
        estateBody);
    prefs.setString('estate_id', response.body["estate_id"].toString());
    _pickPlaned.clear();
    if (response.statusCode == 200) {
      _isLoading=false;
      _pickPlaned.clear();
      _pickedIdentities.clear();
      _categoryIndex=0;
      //  Get.offNamed(RouteHelper.getUploadRoute(161));


      String estateIdStr = response.body["estate_id"].toString();

      int estateId = int.tryParse(estateIdStr) ?? 0;
      Get.offNamed(RouteHelper.getUploadRoute(estateId));

      //   Get.offAllNamed(RouteHelper.getSuccess());
    } else {
      ApiChecker.checkApi(response, showToaster: true);
      // //print("🔴 Error: Status Code: ${response.body["message"].toString()}");
      print("🔴 Error Body: ${response.statusText}");
      print("🔴 Error Body2: ${response.statusCode}");
      //   //print("error estate---------------------------------------------------${response}");
    }
    _isLoading = false;
    update();
  }





  Future<void> updatEstate(EstateBody estatetBody) async {
    _isLoading = true;
    //  update();
    // List<MultipartBody> _multiParts = [];
    // _multiParts.add(MultipartBody('image', _pickedImage));
    // for (XFile file in _pickedIdentities) {
    //   _multiParts.add(MultipartBody('identity_image[]', file));
    // }
    //
    // _multiParts.add(MultipartBody('image', _pickedPlanedImage));
    // for (XFile file in _pickPlaned) {
    //   _multiParts.add(MultipartBody('planed_image[]', file));
    // }
    Response response = await estateRepo.updateEstate(estatetBody);
    update();
    if (response.statusCode == 200) {
      Get.offAllNamed(RouteHelper.getProfileRoute());
      showCustomSnackBar('update_successful'.tr, isError: false);


    } else {
      ApiChecker.checkApi(response, showToaster: true);
      //print("error estate---------------------------------------------------${response.body}");
    }
    _isLoading = false;
    update();
  }




  Future<void> deleteEstate(int estateId) async {
    _isLoading = true;
    update();
    Response response = await estateRepo.deleteEstate(estateId);
    if(response.statusCode == 200) {
      Get.back();
      showCustomSnackBar('estate deleted successfully'.tr, isError: false);
      Get.toNamed(RouteHelper.getProfileRoute());

    }else {
      ApiChecker.checkApi(response, showToaster: true);
    }
    _isLoading = false;
    update();
  }


  @override
  void onClose() {}

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }


  void addInterestSelection(int index) {
    _advantagesSelectedList?[index] = !_advantagesSelectedList![index];
    update();
  }


  Future<void> getCategoryList(Estate product) async {
    _categoryIds = [];
    //  _subCategoryIds = [];
    _categoryIds.add(0);
    //   _subCategoryIds.add(0);
    _isLoading = true;
    Response response = await estateRepo.getCategoryList();
    if (response.statusCode == 200) {
      _categoryList = [];
      _isLoading = false;
      response.body.forEach((category) => _categoryList?.add(CategoryModel.fromJson(category)));
      for(int index=0; index<_categoryList!.length; index++) {
        _categoryIds.add(_categoryList![index].id ?? 0);
      }
      setCategoryIndex(_categoryIds.indexOf(product.categoryId ?? 0));
      //  await getSubCategoryList(int.parse(product.categoryIds[0].id), product);
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
    update();
  }



  Future<void> insertEstate(String title, String description, int estateId ,BuildContext ctx) async {
    _isLoading = true;

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.BASE_URL}/api/v1/estate/create-report'), // Replace with your Laravel API endpoint
        body: {
          'title': title,
          'description': description,
          'estate_id': estateId.toString(),
        },
      );



      if (response.statusCode == 200) {
        _isLoading = false;
        Get.snackbar(
          'Thanks'.tr,
          'operation_accomplished_successfully'.tr,
          backgroundColor: Colors.green, // Customize snackbar color
          colorText: Colors.white, // Customize text color
          duration: Duration(seconds: 3), // Set duration in seconds
          snackPosition: SnackPosition.BOTTOM, // Set snackbar position
          margin: EdgeInsets.all(10), // Set margin around the snackbar
          isDismissible: true, // Allow dismissing the snackbar with a tap// Dismiss direction
        );
        Navigator.pop(ctx);// Show success snackbar
      } else {
        Get.snackbar('Error', 'Error inserting estate'); // Show error snackbar
      }
      // Handle response here

    } catch (error) {
      //print("--------------------------------$error");
    } finally {
      _isLoading = false;
    }
  }


  Map<String, dynamic> licenseData = {};

  void setIsLoading(bool loading) {
    _isLoading = loading;
    update();
  }


  // Future<bool> verifyLicense(String licenseNumber, String advertiserNumber, int type) async {
  //   try {
  //     final response = await estateRepo.verifyLicense(licenseNumber, advertiserNumber, type);
  //
  //     if (response.statusCode == 200) {
  //       //print("📦 Raw API response body:");
  //       ////print(jsonEncode(response.body)); // هذا يطبع كل شيء كـ JSON
  //
  //       if (response.body['success'] == true) {
  //         // طباعة البيانات المتداخلة بشكل منسق
  //         //print("✅ Success: License verified");
  //
  //         // طباعة كل المفاتيح مع القيم
  //         //print("🔍 Full parsed response:");
  //         Map<String, dynamic> fullResponse = response.body;
  //         fullResponse.forEach((key, value) {
  //           //print("------------------------------------------------------------------------------------------$key: ${jsonEncode(value)}");
  //         });
  //
  //         licenseData = response.body['data'];
  //         var licenseBorders = response.body['data2'];
  //
  //         SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //         // تخزين البيانات
  //         String licenseJson = jsonEncode(licenseData);
  //         await prefs.setString('license_data', licenseJson);
  //
  //         String data2Json = jsonEncode(response.body['data2']);
  //         await prefs.setString('license_data2', data2Json);
  //
  //         String bordersJson = jsonEncode(licenseBorders);
  //         await prefs.setString('license_borders', bordersJson);
  //
  //         // يمكنك أيضًا تخزين data3 إذا أردت:
  //         String data3Json = jsonEncode(response.body['data3']);
  //         await prefs.setString('license_data3', data3Json);
  //
  //         ////print('✅ Stored data2: $data2Json');
  //         ////print('✅ Stored data3: $data3Json');
  //
  //         return true;
  //       } else {
  //         ////print('❌ Error: ${response.body['message']}');
  //         return false;
  //       }
  //     } else {
  //       ////print('❌ API error: ${response.statusCode} - ${response.statusText}');
  //       return false;
  //     }
  //   } catch (e) {
  //     //print('⚠️ Exception: $e');
  //     return false;
  //   }
  // }
  String licenseVerificationMessage = '';
  Future<bool> verifyLicense(String licenseNumber, String advertiserNumber, int type) async {
    try {
      final response = await estateRepo.verifyLicense(licenseNumber, advertiserNumber, type);

      if (response.statusCode == 200) {
        if (response.body['success'] == true) {
          Map<String, dynamic> fullResponse = response.body;


          licenseData = response.body['data'];
          var licenseBorders = response.body['data2'];

          SharedPreferences prefs = await SharedPreferences.getInstance();

          await prefs.setString('license_data', jsonEncode(licenseData));
          await prefs.setString('license_data2', jsonEncode(response.body['data2']));
          await prefs.setString('license_borders', jsonEncode(licenseBorders));
          await prefs.setString('license_data3', jsonEncode(response.body['data3']));

          licenseVerificationMessage = response.body['message'] ?? 'تم التحقق من الترخيص بنجاح';

          return true;
        }
        else if (response.statusCode == 409) {
          // 💥 إعلان مكرر
          licenseVerificationMessage = response.body['message'] ?? 'الإعلان موجود مسبقاً';
          return false;
        }else {
          licenseVerificationMessage = response.body['message'] ?? 'رقم الترخيص غير صالح';
          return false;
        }
      } else {
        licenseVerificationMessage = '  ${response.body['message']}';
        return false;
      }
    } catch (e) {
      //licenseVerificationMessage = 'حدث خطأ أثناء التحقق: ${!response.body}';
      return false;
    }
  }




  Future<bool> validateAdvertisement({
    required String adLicenseNumber,
    required String advertiserId,
    required String idType,
  }) async {

    try {

      final response = await http.post(
        Uri.parse(
          '${AppConstants.BASE_URL}/api/v1/banners/advertisement/validate',
        ),

        body: {
          'adLicenseNumber': adLicenseNumber,
          'advertiserId': advertiserId,
          'idType': idType,
        },
      );

      final body = jsonDecode(response.body);

      print("STATUS CODE: ${response.statusCode}");
      print("FULL RESPONSE: $body");

      if (response.statusCode == 200 &&
          body['success'] == true) {

        print("✅ الترخيص صالح");

        return true;

      } else {

        print("❌ الترخيص غير صالح");
        print("MESSAGE: ${body['message']}");

        return false;
      }

    } catch (e) {

      print("ERROR: $e");

      return false;
    }
  }


// void addToWishList(Estate restaurant, bool isRestaurant) async {
//   Response response = await wishListRepo.addWishList( restaurant.id, isRestaurant);
//   if (response.statusCode == 200) {
//     _wishRestIdList.add(restaurant.id);
//     _wishRestList.add(restaurant);
//
//     showCustomSnackBar(response.body['message'], isError: false);
//   } else {
//     ApiChecker.checkApi(response, showToaster: true);
//   }
//   update();
// }

}
