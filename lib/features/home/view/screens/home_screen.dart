// import 'dart:convert';
//
// import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
// import 'package:abaad_flutter/features/home/controller/banner_controller.dart';
// import 'package:abaad_flutter/features/category/controller/category_controller.dart';
// import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
// import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
// import 'package:abaad_flutter/features/zones/controller/zone_controller.dart';
// import 'package:abaad_flutter/shared/data/models/config_model.dart';
// import 'package:abaad_flutter/shared/data/models/estate_model.dart';
// import 'package:abaad_flutter/core/routes/route_helper.dart';
// import 'package:abaad_flutter/shared/utils/dimensions.dart';
// import 'package:abaad_flutter/shared/utils/styles.dart';
// import 'package:abaad_flutter/shared/widgets/custom_image.dart';
// import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
// import 'package:abaad_flutter/shared/widgets/no_data_screen.dart';
// import 'package:abaad_flutter/features/filter/view/screens/fillter_estate_sheet.dart';
// import 'package:abaad_flutter/features/home/view/widgets/estate_card.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// // import 'package:barcode_scan2/barcode_scan2.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
//
// import '../../base/web_menu_bar.dart';
//
// class HomeScreen extends StatefulWidget {
//   int zoneId;
//
//   HomeScreen({super.key, required this.zoneId});
//
//   final ScrollController scrollController = ScrollController();
//   final bool _ltr = Get.find<LocalizationController>().isLtr;
//
//
//   final ConfigModel? _configModel = Get.find<SplashController>().configModel;
//
//   static Future<void> loadData(bool reload) async {
//     Get.find<CategoryController>().showBottomLoader();
//     Get.find<CategoryController>()
//         .getCategoryProductList(0, "0", 0, '0', "0", "0", "0", "0", 0, 0, "");
//     // Get.find<CategoryController>().getSubCategoryList("0");
//     int offset = 1;
//     Get.find<BannerController>().getBannerList(reload, 1);
//     Get.find<AuthController>().getZoneList();
//
//
//     int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
//     if (offset < pageSize) {
//       offset++;
//       //print('end of the page');
//       Get.find<CategoryController>().showBottomLoader();
//       Get.find<CategoryController>().getCategoryProductList(
//           0, "0", 0, '0', "0", "0", "0", offset.toString(), 0, 0, "");
//     }
//   }
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedZone();
//   }
//
//   String? selectedZoneName = null;
//
//  // final ScrollController _searchController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//
//   void _loadSavedZone() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       selectedZoneName = prefs.getString('zone_name')!;
//     });
//   }
//
//   static const _locale = 'en';
//   String result = "Scan a QR Code"; // Initialize with a default message
//   bool isFlashOn = false;
//
//   // Future<void> scanQRCode() async {
//   //   try {
//   //     final ScanResult scanResult = await BarcodeScanner.scan(
//   //       options: ScanOptions(
//   //         useCamera: -1, // Use the back camera by default
//   //         autoEnableFlash: isFlashOn,
//   //       ),
//   //     );
//   //     setState(() {
//   //       result = scanResult.rawContent;
//   //       Get.toNamed(RouteHelper.getDetailsRoute(162));
//   //     });
//   //   } catch (e) {
//   //     setState(() {
//   //       result = "Error: $e";
//   //     });
//   //   }
//   // }
//
//   void toggleFlash() {
//     setState(() {
//       isFlashOn = !isFlashOn;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentLocale = Get.locale;
//     bool isArabic = currentLocale?.languageCode == 'ar';
//     bool isNull = true;
//     int length = 0;
//
//     var width = MediaQuery.of(context).size.width;
//     final GlobalKey<ScaffoldState> _key = GlobalKey();
//
//     return Scaffold(
//       key: _key,
//
//         appBar:
//
//
//         PreferredSize(
//           preferredSize: const Size.fromHeight(60),
//           child: AppBar(
//             actions: [
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     GestureDetector(
//                       // onTap: scanQRCode,
//                       child: Container(
//                         // margin: const EdgeInsets.only(
//                         //     left: 4.0, right: 4.0),
//                         padding:
//                         const EdgeInsets.all(7),
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius:
//                             BorderRadius.circular(
//                                 4),
//                             border: Border.all(
//                               width: 1,
//                               color: Colors.blue,
//                             )),
//                         child: const Icon(
//                           Icons.qr_code,
//                           size: 25,
//                           color: Colors.blue,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       width: 3,
//                     ),
//                     GetBuilder<ZoneController>(
//                         builder: (zoneController) {
//                           return GestureDetector(
//                             onTap: () {
//                               //    zoneController.categoryList.clear();
//                               zoneController
//                                   .categoryIndex ==
//                                   0;
//
//                               Get.dialog(FiltersScreen());
//                             },
//                             child: Container(
//                               padding:
//                               const EdgeInsets.all(7),
//                               // margin: const EdgeInsets.only(
//                               //     left: 4.0, right: 4.0),
//                               decoration: BoxDecoration(
//                                   color: Colors.blue,
//                                   borderRadius:
//                                   BorderRadius.circular(
//                                       5),
//                                   border: Border.all(
//                                     width: 1,
//                                     color: Colors.white,
//                                   )),
//
//                               child: const Icon(
//                                 Icons.filter_list_alt,
//                                 size: 25,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           );
//                         }),
//                   ],
//                 ),
//               )
//
//
//               // هام لإضافة مسافة بين الأيقونات وحافة الشاشة
//             ],
//             backgroundColor: Colors.white,
//             elevation: 0, // نلغي الظل لأنه سنضيف بوردر يدوي
//             leading: IconButton(
//               icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//             ),
//             title: Row(
//               children: [
//                 const SizedBox(width: 12),
//                 Text(
//                   "قائمة في منطقه ${ selectedZoneName}",
//                   style: const TextStyle(
//
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),
//               ],
//             ),
//             bottom: PreferredSize(
//               preferredSize: const Size.fromHeight(1.0),
//               child: Container(
//                 color: Colors.grey.shade300,
//                 height: 1.0,
//               ),
//             ),
//           ),
//         ),
//
//
//
//         backgroundColor: Theme.of(context).cardColor,
//         body: GetBuilder<CategoryController>(builder: (categoryController) {
//           List<Estate> products;
//           products = [];
//           if (categoryController.isSearching) {
//           } else {
//             products.addAll((categoryController.categoryProductList ?? []) as Iterable<Estate>);
//           }
//
//           isNull = products == null;
//           if (!isNull) {
//             length = products.length;
//           }
//
//           return (categoryController.subCategoryList != null)
//               ? SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.only(right: 5, left: 5),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//
//                         // Container(
//                         //   height: 150.0,
//                         //   child: BannerView(),
//                         // ),
//
//                         SizedBox(height: 9),
//
//                         (categoryController.subCategoryList != null)
//                             ? Center(
//                                 child: SizedBox(
//                                     height: 40,
//                                     child: ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: categoryController
//                                           .subCategoryList!.length,
//                                       padding: EdgeInsets.only(
//                                           left: Dimensions.PADDING_SIZE_SMALL),
//                                       physics: BouncingScrollPhysics(),
//                                       itemBuilder: (context, index) {
//                                         return Padding(
//                                           padding: const EdgeInsets.only(
//                                               right: 6, left: 6),
//                                           child: InkWell(
//                                             onTap: () async {
//
//
//                                               // حفظ معرف القسم الفرعي الذي تم اختياره
//
//
//                                               SharedPreferences prefs = await SharedPreferences.getInstance();
//                                               int? savedZoneId = prefs.getInt('zone_id');
//
//
//
//
//                                               categoryController
//                                                   .setSubCategoryIndex(
//                                                       index, savedZoneId!);
//                                               //  categoryController.subCategoryIndex==index;
//
//                                               _loadSavedZone();
//
//                                               // Get.find<CategoryController>().setFilterIndex(savedZoneId,categoryController.categoryList[index].id,"0","0",0,0,0,"0");
//                                             },
//                                             child: Container(
//                                               padding: EdgeInsets.only(
//                                                 left: index ==
//                                                         categoryController
//                                                                 .subCategoryList!
//                                                                 .length -
//                                                             1
//                                                     ? Dimensions
//                                                         .PADDING_SIZE_LARGE
//                                                     : Dimensions
//                                                         .PADDING_SIZE_SMALL,
//                                                 right: index ==
//                                                         categoryController
//                                                                 .subCategoryList!
//                                                                 .length -
//                                                             1
//                                                     ? Dimensions
//                                                         .PADDING_SIZE_LARGE
//                                                     : Dimensions
//                                                         .PADDING_SIZE_SMALL,
//                                                 //   top: Dimensions.PADDING_SIZE_SMALL,
//                                               ),
//                                               decoration: BoxDecoration(
//                                                 border: Border.all(
//                                                     color: index ==
//                                                             categoryController
//                                                                 .subCategoryIndex
//                                                         ? Theme.of(context)
//                                                             .primaryColor
//                                                         : Colors.black12,
//                                                     width: 2),
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.0),
//                                                 color: Colors.white30,
//                                               ),
//                                               child: Row(children: [
//                                                 Text(
//                                                   isArabic
//                                                       ? categoryController
//                                                           .subCategoryList![
//                                                               index]
//                                                           .nameAr ?? ""
//                                                       : categoryController
//                                                               .subCategoryList![
//                                                                   index]
//                                                               .name ??
//                                                           'all',
//                                                   style: index ==
//                                                           categoryController
//                                                               .subCategoryIndex
//                                                       ? robotoMedium.copyWith(
//                                                           fontSize: Dimensions
//                                                               .fontSizeDefault,
//                                                           color:
//                                                               Theme.of(context)
//                                                                   .primaryColor)
//                                                       : robotoRegular.copyWith(
//                                                           fontSize: Dimensions
//                                                               .fontSizeDefault,
//                                                           color: Theme.of(
//                                                                   context)
//                                                               .disabledColor),
//                                                 ),
//                                                 SizedBox(width: 10),
//                                                 index == 0
//                                                     ? Container()
//                                                     : CustomImage(
//                                                         image:
//                                                             '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.subCategoryList![index].image}',
//                                                         height: 25,
//                                                         width: 25,
//                                                         colors: index ==
//                                                                 categoryController
//                                                                     .subCategoryIndex
//                                                             ? Theme.of(context)
//                                                                 .primaryColor
//                                                             : Colors.black12),
//                                               ]),
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     )))
//                             : SizedBox(),
//                         SizedBox(height: 2),
//                         selectedZoneName != null
//                             ? Container(
//                                 margin: EdgeInsets.only(bottom: 6),
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 7, vertical: 4),
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue.shade50,
//                                   borderRadius: BorderRadius.circular(4),
//                                   border: Border.all(color: Colors.blue),
//                                 ),
//                                 child: Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       selectedZoneName ?? "KSA",
//                                       style: TextStyle(
//                                           color: Colors.blue,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     SizedBox(width: 5),
//                                     InkWell(
//                                       onTap: () async {
//                                         SharedPreferences prefs =
//                                             await SharedPreferences
//                                                 .getInstance();
//                                         await prefs.remove('zone_name');
//                                         await prefs.remove('zone_id');
//                                         setState(() {
//                                           selectedZoneName = "";
//                                           //_value1 = 0; // إعادة تعيين dropdown
//                                         });
//                                       },
//                                       child: Icon(Icons.close,
//                                           color: Colors.red, size: 18),
//                                     )
//                                   ],
//                                 ),
//                               )
//                             : SizedBox.shrink(),
//
//                         !isNull
//                             ? products.isNotEmpty
//                                 ? Container(
//                                     child: ListView.builder(
//                                       key: UniqueKey(),
//                                       physics: NeverScrollableScrollPhysics(),
//                                       shrinkWrap: true,
//                                       itemCount: products.length,
//                                       itemBuilder: (context, index) {
//                                         return PropertyCard(products[index]);
//                                       },
//                                     ),
//                                   )
//                                 : Center(
//                                     child: NoDataScreen(
//                                       text: 'no_data_available',
//                                     ),
//                                   )
//                             : const SizedBox(),
//
//                         categoryController.isLoading
//                             ? Center(
//                                 child: Padding(
//                                 padding: EdgeInsets.all(
//                                     Dimensions.PADDING_SIZE_SMALL),
//                                 child: CircularProgressIndicator(
//                                     valueColor: AlwaysStoppedAnimation<Color>(
//                                         Theme.of(context).primaryColor)),
//                               ))
//                             : SizedBox(),
//                       ],
//                     ),
//                   ),
//                 )
//               : Center(child: CircularProgressIndicator());
//         }));
//   }
//   List<dynamic> _searchResults = [];
//
//   Future<void> _searchEstates(String query) async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://app.abaadapp.sa/api/v1/estate/search?name=$query'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _searchResults = data['estate']; // تأكد من المسار الصحيح داخل response
//         });
//       } else {
//         showCustomSnackBar('فشل في جلب النتائج');
//       }
//     } catch (e) {
//       showCustomSnackBar('حدث خطأ: $e');
//     }
//   }
//
//
//
//
// }
//
// class SliverDelegate extends SliverPersistentHeaderDelegate {
//   Widget child;
//
//   SliverDelegate({required this.child});
//
//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return child;
//   }
//
//   @override
//   double get maxExtent => 50;
//
//   @override
//   double get minExtent => 50;
//
//   @override
//   bool shouldRebuild(SliverDelegate oldDelegate) {
//     return oldDelegate.maxExtent != 50 ||
//         oldDelegate.minExtent != 50 ||
//         child != oldDelegate.child;
//   }
// }
//
// Widget _textField({
//   required TextEditingController? controller,
//   FocusNode? focusNode,
//   String? label,
//   String? hint,
//   double? width,
//   Icon? prefixIcon,
//   suffixIcon,
//   Function(String)? locationCallback,
// }) {
//   return SizedBox(
//     width: (width ?? 1) * 0.7,
//     height: 45,
//     child: TextField(
//       onChanged: (value) {
//         locationCallback!(value);
//       },
//       controller: controller,
//       focusNode: focusNode,
//       decoration: InputDecoration(
//         prefixIcon: prefixIcon,
//         suffixIcon: suffixIcon,
//         labelText: label,
//         filled: true,
//         fillColor: Colors.white,
//         enabledBorder: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(
//             Radius.circular(5.0),
//           ),
//           borderSide: BorderSide(
//             color: Colors.blue,
//             width: 2,
//           ),
//         ),
//         focusedBorder: const OutlineInputBorder(
//           borderRadius: BorderRadius.all(
//             Radius.circular(10.0),
//           ),
//           borderSide: BorderSide(
//             color: Colors.blue,
//             width: 2,
//           ),
//         ),
//         contentPadding: const EdgeInsets.all(15),
//         hintText: hint,
//       ),
//     ),
//   );
// }

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/home/controller/banner_controller.dart';
import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/zones/controller/zone_controller.dart';
import 'package:abaad_flutter/shared/data/models/config_model.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/no_data_screen.dart';
import 'package:abaad_flutter/features/filter/view/screens/fillter_estate_sheet.dart';
import 'package:abaad_flutter/features/home/view/widgets/estate_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  int zoneId;

  HomeScreen({super.key, required this.zoneId});

  final ScrollController scrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;
  final ConfigModel? _configModel = Get.find<SplashController>().configModel;

  static Future<void> loadData(bool reload) async {
    Get.find<CategoryController>().getCategoryProductList(
      0,
      "0",
      0,
      '0',
      "0",
      "0",
      "0",
      reload: true,
      arPath: 0,
      sv: 0,
      type: "",
    );

    Get.find<BannerController>().getBannerList(reload, 1);
    Get.find<AuthController>().getZoneList();
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? selectedZoneName;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedZone();

    widget.scrollController.addListener(() {
      if (widget.scrollController.position.pixels >=
          widget.scrollController.position.maxScrollExtent - 200) {
        final controller = Get.find<CategoryController>();

        if (!controller.isPaginating && !controller.isLastPage) {
          controller.getCategoryProductList(
            0,
            controller.subCategoryList != null &&
                controller.subCategoryList!.isNotEmpty
                ? controller.subCategoryList![controller.subCategoryIndex].id
                .toString()
                : "0",
            0,
            '0',
            '0',
            '0',
            '0',
            arPath: 0,
            sv: 0,
            type: '',
          );
        }
      }
    });
  }

  @override
  void dispose() {
    widget.scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadSavedZone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedZoneName = prefs.getString('zone_name');
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';

    final GlobalKey<ScaffoldState> key = GlobalKey();

    return Scaffold(
      key: key,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  // Back button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: Theme.of(context).primaryColor,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Title
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "عقارات متاحة",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                        Text(
                          selectedZoneName != null && selectedZoneName!.isNotEmpty
                              ? selectedZoneName!
                              : "جميع المناطق",
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Filter button
                  GetBuilder<ZoneController>(
                    builder: (zoneController) {
                      return GestureDetector(
                        onTap: () => Get.dialog(FiltersScreen()),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).cardColor,
      body: GetBuilder<CategoryController>(
        builder: (categoryController) {
          List<Estate> products = [];
          if (!categoryController.isSearching) {
            products.addAll(
              (categoryController.categoryProductList ?? []) as Iterable<Estate>,
            );
          }

          return categoryController.subCategoryList != null
              ? SingleChildScrollView(
            controller: widget.scrollController,
            child: Padding(
              padding: const EdgeInsets.only(right: 5, left: 5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 9),
                  Center(
                    child: SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount:
                        categoryController.subCategoryList!.length,
                        padding: EdgeInsets.only(
                          left: Dimensions.PADDING_SIZE_SMALL,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                              right: 6,
                              left: 6,
                            ),
                            child: InkWell(
                              onTap: () async {
                                SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                                int? savedZoneId =
                                prefs.getInt('zone_id');

                                categoryController.setSubCategoryIndex(
                                  index,
                                  savedZoneId ?? 0,
                                );

                                _loadSavedZone();
                              },
                              child: Container(
                                padding: EdgeInsets.only(
                                  left: index ==
                                      categoryController
                                          .subCategoryList!
                                          .length -
                                          1
                                      ? Dimensions.PADDING_SIZE_LARGE
                                      : Dimensions.PADDING_SIZE_SMALL,
                                  right: index ==
                                      categoryController
                                          .subCategoryList!
                                          .length -
                                          1
                                      ? Dimensions.PADDING_SIZE_LARGE
                                      : Dimensions.PADDING_SIZE_SMALL,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: index ==
                                        categoryController
                                            .subCategoryIndex
                                        ? Theme.of(context).primaryColor
                                        : Colors.black12,
                                    width: 2,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(8.0),
                                  color: Colors.white30,
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      isArabic
                                          ? categoryController
                                          .subCategoryList![index]
                                          .nameAr ??
                                          ""
                                          : categoryController
                                          .subCategoryList![index]
                                          .name ??
                                          'all',
                                      style: index ==
                                          categoryController
                                              .subCategoryIndex
                                          ? robotoMedium.copyWith(
                                        fontSize: Dimensions
                                            .fontSizeDefault,
                                        color: Theme.of(context)
                                            .primaryColor,
                                      )
                                          : robotoRegular.copyWith(
                                        fontSize: Dimensions
                                            .fontSizeDefault,
                                        color: Theme.of(context)
                                            .disabledColor,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    index == 0
                                        ? Container()
                                        : CustomImage(
                                      image:
                                      '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.subCategoryList![index].image}',
                                      height: 25,
                                      width: 25,
                                      colors: index ==
                                          categoryController
                                              .subCategoryIndex
                                          ? Theme.of(context)
                                          .primaryColor
                                          : Colors.black12,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  selectedZoneName != null && selectedZoneName!.isNotEmpty
                      ? Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedZoneName ?? "KSA",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 5),
                        InkWell(
                          onTap: () async {
                            SharedPreferences prefs =
                            await SharedPreferences
                                .getInstance();
                            await prefs.remove('zone_name');
                            await prefs.remove('zone_id');
                            setState(() {
                              selectedZoneName = "";
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 18,
                          ),
                        )
                      ],
                    ),
                  )
                      : const SizedBox.shrink(),
                  products.isNotEmpty
                      ? ListView.builder(
                    key: UniqueKey(),
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      return PropertyCard(products[index]);
                    },
                  )
                      : categoryController.isLoading
                      ? const SizedBox()
                      : Center(
                    child: NoDataScreen(
                      text: 'no_data_available',
                    ),
                  ),
                  categoryController.isLoading && products.isEmpty
                      ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(
                        Dimensions.PADDING_SIZE_SMALL,
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                      : const SizedBox(),
                  categoryController.isPaginating
                      ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(
                        Dimensions.PADDING_SIZE_SMALL,
                      ),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                      : const SizedBox(),
                ],
              ),
            ),
          )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

}