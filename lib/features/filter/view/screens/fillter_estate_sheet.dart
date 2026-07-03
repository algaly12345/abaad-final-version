// import 'package:abaad_flutter/features/category/controller/category_controller.dart';
// import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
// import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
// import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
// import 'package:abaad_flutter/features/zones/controller/zone_controller.dart';
// import 'package:abaad_flutter/shared/utils/dimensions.dart';
// import 'package:abaad_flutter/shared/utils/styles.dart';
// import 'package:abaad_flutter/shared/widgets/custom_image.dart';
// import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
// import 'package:abaad_flutter/view/screen/draw.dart';
// import 'package:abaad_flutter/features/filter/view/widgets/slider_view.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:dropdown_search/dropdown_search.dart';
//
// import '../../../data/model/response/district_model.dart';
// import 'widgets/popular_filter_list.dart';
//
//
// class FiltersScreen extends StatefulWidget {
//   const FiltersScreen({super.key});
//
//   @override
//   _FiltersScreenState createState() => _FiltersScreenState();
// }
//
// class _FiltersScreenState extends State<FiltersScreen> {
//   final ScrollController scrollController = ScrollController();
//   final bool _ltr = Get.find<LocalizationController>().isLtr;
//
//   List<PopularFilterListData> accomodationListData = PopularFilterListData.accomodationList;
//   late String type_properties;
//    String? ctiy_name;
//    String? districts;
//   late int zone_id;
//   late String zone_name;
//
//   final RangeValues _values = const RangeValues(100, 600);
//   double distValue = 0;
//   final ScrollController _scrollController = ScrollController();
//   int _value1=0;
//
//   List<String> selectedFilters = [];
//   String selectedPropertyType = 'بيع';
//
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     Get.find<ZoneController>().getCategoryList();
//     Get.find<CategoryController>().getSubCategoryList("0");
//     int offset = 1;
//     ctiy_name = ""; // أو أي قيمة افتراضية منطقية
//     scrollController.addListener(() {
//       if (scrollController.position.pixels == scrollController.position.maxScrollExtent
//           && !Get.find<CategoryController>().isLoading) {
//         int pageSize = (Get.find<CategoryController>().pageSize! / 10).ceil();
//         if (offset < pageSize) {
//           offset++;
//           //print('end of the page');
//           Get.find<CategoryController>().showBottomLoader();
//           Get.find<CategoryController>().getCategoryProductList(
//             0,
//             "0",
//             0,
//             '0',
//             "0",
//             "0",
//             "0",
//             reload: false,
//             arPath: 0,
//             sv: 0,
//             type: "",
//           );
//           // Get.find<CategoryController>().getCategoryProductList(0,"0", 0,'0',"0","0","0", offset.toString(),0,0,"");
//         }
//       }
//     });
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     List<String> filters = ['it_includes_offers'.tr, 'virtual_ture'.tr,];
//
//     final currentLocale = Get.locale;
//     bool isArabic = currentLocale?.languageCode == 'ar';
//      return GetBuilder<EstateController>(builder: (restController) {
//       return GetBuilder<ZoneController>(builder: (zoneController) {
//
//
//         return GetBuilder<CategoryController>(builder: (categoryController) {
//         return   zoneController.subCategoryList!=null ? Container(
//       color: Theme.of(context).primaryColor,
//       child: Scaffold(
//         body: Column(
//           children: <Widget>[
//             getAppBarUI(),
//             Expanded(
//               child: SingleChildScrollView(
//                 child: Column(
//                   children: <Widget>[
//                     // priceBarFilter(),
//                     const Divider(
//                       height: 1,
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//
//
//                           (categoryController.subCategoryList != null)
//                               ? Center(
//                               child: SizedBox(
//                                   height: 40,
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     itemCount: categoryController
//                                         .subCategoryList!.length,
//                                     padding: EdgeInsets.only(
//                                         left: Dimensions.PADDING_SIZE_SMALL),
//                                     physics: BouncingScrollPhysics(),
//                                     itemBuilder: (context, index) {
//                                       return Padding(
//                                         padding: const EdgeInsets.only(
//                                             right: 6, left: 6),
//                                         child: InkWell(
//                                           onTap: () async {
//                                             SharedPreferences prefs = await SharedPreferences.getInstance();
//                                             int? savedZoneId = prefs.getInt('zone_id');
//
//
//
//
//                                             categoryController
//                                                 .setSubCategoryIndex(
//                                                 index, savedZoneId!);
//                                             //  categoryController.subCategoryIndex==index;
//                                             int selectedSubCategoryId = categoryController.subCategoryList![index].id!;
//                                             await prefs.setInt('sub_category_id', selectedSubCategoryId);
//
//                                             //_loadSavedZone();
//
//                                             // Get.find<CategoryController>().setFilterIndex(savedZoneId,categoryController.categoryList[index].id,"0","0",0,0,0,"0");
//                                           },
//                                           child: Container(
//                                             padding: EdgeInsets.only(
//                                               left: index ==
//                                                   categoryController
//                                                       .subCategoryList!
//                                                       .length -
//                                                       1
//                                                   ? Dimensions
//                                                   .PADDING_SIZE_LARGE
//                                                   : Dimensions
//                                                   .PADDING_SIZE_SMALL,
//                                               right: index ==
//                                                   categoryController
//                                                       .subCategoryList!
//                                                       .length -
//                                                       1
//                                                   ? Dimensions
//                                                   .PADDING_SIZE_LARGE
//                                                   : Dimensions
//                                                   .PADDING_SIZE_SMALL,
//                                               //   top: Dimensions.PADDING_SIZE_SMALL,
//                                             ),
//                                             decoration: BoxDecoration(
//                                               border: Border.all(
//                                                   color: index ==
//                                                       categoryController
//                                                           .subCategoryIndex
//                                                       ? Theme.of(context)
//                                                       .primaryColor
//                                                       : Colors.black12,
//                                                   width: 2),
//                                               borderRadius:
//                                               BorderRadius.circular(8.0),
//                                               color: Colors.white30,
//                                             ),
//                                             child: Row(children: [
//                                               Text(
//                                                 isArabic
//                                                     ? categoryController
//                                                     .subCategoryList![
//                                                 index]
//                                                     .nameAr ?? ""
//                                                     : categoryController
//                                                     .subCategoryList![
//                                                 index]
//                                                     .name ??
//                                                     'all',
//                                                 style: index ==
//                                                     categoryController
//                                                         .subCategoryIndex
//                                                     ? robotoMedium.copyWith(
//                                                     fontSize: Dimensions
//                                                         .fontSizeDefault,
//                                                     color:
//                                                     Theme.of(context)
//                                                         .primaryColor)
//                                                     : robotoRegular.copyWith(
//                                                     fontSize: Dimensions
//                                                         .fontSizeDefault,
//                                                     color: Theme.of(
//                                                         context)
//                                                         .disabledColor),
//                                               ),
//                                               SizedBox(width: 10),
//                                               index == 0
//                                                   ? Container()
//                                                   : CustomImage(
//                                                   image:
//                                                   '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.subCategoryList![index].image}',
//                                                   height: 25,
//                                                   width: 25,
//                                                   colors: index ==
//                                                       categoryController
//                                                           .subCategoryIndex
//                                                       ? Theme.of(context)
//                                                       .primaryColor
//                                                       : Colors.black12),
//                                             ]),
//                                           ),
//                                         ),
//                                       );
//                                     },
//                                   )))
//                               : SizedBox(),
//
//                           Row(
//                             children: [
//                               // زر البيع
//                               ElevatedButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     selectedPropertyType = 'بيع';
//                                     // Get.find<CategoryController>().setFilterIndex(
//                                     //   0, 0, "0", "0", 0, 0, 0, selectedPropertyType,
//                                     // );
//                                   });
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: selectedPropertyType == 'بيع' ? Colors.blue : Colors.white,
//                                   foregroundColor: selectedPropertyType == 'بيع' ? Colors.white : Colors.black,
//                                   shape: RoundedRectangleBorder(
//                                     side: BorderSide(color: Colors.blue),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: Text('بيع'),
//                               ),
//
//
//                               SizedBox(width: 10),
//
//                               // زر الإيجار
//                               ElevatedButton(
//                                 onPressed: () {
//                                   setState(() {
//                                     selectedPropertyType = 'إيجار';
//                                     // Get.find<CategoryController>().setFilterIndex(
//                                     //   0, 0, "0", "0", 0, 0, 0, selectedPropertyType,
//                                     // );
//                                   });
//                                 },
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: selectedPropertyType == 'إيجار' ? Colors.blue : Colors.white,
//                                   foregroundColor: selectedPropertyType == 'إيجار' ? Colors.white : Colors.black,
//                                   shape: RoundedRectangleBorder(
//                                     side: BorderSide(color: Colors.blue),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                 ),
//                                 child: Text('إيجار'),
//                               ),
//
//                             ],
//                           ),
//                           SizedBox(height: 7),
//                           Text("type_property".tr, style: robotoRegular.copyWith(
//                               fontSize: Dimensions.fontSizeDefault, color: Theme
//                               .of(context)
//                               .hintColor),),
//                           SizedBox(height: 7),
//                           GetBuilder<CategoryController>(
//                               builder: (categoryController) {
//                                 return (categoryController.categoryList != null) ?
//                                 SizedBox(
//                                   height: 40,
//                                   child: ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: categoryController.categoryList!
//                                           .length,
//                                       padding: EdgeInsets.only(
//                                           left: Dimensions.PADDING_SIZE_SMALL),
//                                       physics: BouncingScrollPhysics(),
//                                       itemBuilder: (context, index) {
//                                         String baseUrl = Get
//                                             .find<SplashController>()
//                                             .configModel!
//                                             .baseUrls!
//                                             .categoryImageUrl;
//                                         return Column(
//                                           children: [
//
//                                             Padding(
//                                               padding: const EdgeInsets.only(
//                                                   right: 5, left: 5),
//                                               child: InkWell(
//                                                 onTap: () {
//                                                   restController
//                                                       .setCategoryIndex(categoryController.categoryList![index].id ?? 0);
//                                                   restController
//                                                       .setCategoryPostion(int.parse(categoryController.categoryList?[index].position ?? "0"));
//                                                   setState(() {
//                                                     type_properties=categoryController.categoryList![index].name ?? "";
//                                                   });
//
//                                                 },
//                                                 child: Container(
//                                                   height: 40,
//                                                   padding: const EdgeInsets.only(
//                                                       left: 4.0, right: 4.0),
//                                                   decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         color: categoryController.categoryList![index].id ==
//                                                             restController
//                                                                 .categoryIndex
//                                                             ? Theme
//                                                             .of(context)
//                                                             .primaryColor : Colors
//                                                             .white
//                                                     ),
//                                                     borderRadius: BorderRadius
//                                                         .circular(2.0),
//                                                     color: Colors.white,
//
//                                                   ),
//                                                   child: Row(
//                                                     children: [
//                                                       Container(
//                                                         height: 26,
//                                                         color: Colors.white,
//                                                         child: Text(
//                                                           isArabic?  categoryController.categoryList![index].nameAr ?? "": categoryController.categoryList![index].name ?? "",
//                                                           style: categoryController.categoryList![index].id ==
//                                                               restController
//                                                                   .categoryIndex
//                                                               ? robotoBlack
//                                                               .copyWith(
//                                                               fontSize: 17)
//                                                               : robotoRegular
//                                                               .copyWith(
//                                                               fontSize: Dimensions
//                                                                   .fontSizeDefault,
//                                                               fontStyle: FontStyle
//                                                                   .normal,
//                                                               color: Theme
//                                                                   .of(context)
//                                                                   .disabledColor),),
//                                                       ),
//                                                       SizedBox(width: 5),
//
//                                                       CustomImage(
//                                                           image: '$baseUrl/${categoryController
//                                                               .categoryList![index]
//                                                               .image}',
//                                                           height: 25,
//                                                           width: 25,
//                                                           colors: categoryController.categoryList![index].id ==
//                                                               restController
//                                                                   .categoryIndex
//                                                               ? Theme
//                                                               .of(context)
//                                                               .primaryColor
//                                                               : Colors.black12),
//                                                     ],
//                                                   ),
//                                                 ),
//                                               ),
//                                             )
//                                           ],
//                                         );
//                                       }),
//                                 )
//
//                                     : Container();
//                               }),
//                         ],
//                       ),
//                     ),
//                     Row(children: [
//
//                       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text(
//                           'zone'.tr,
//                           style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
//                         ),
//                         SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
//                             boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
//                           ),
//                           child: DropdownButton<int>(
//                             value: _value1,
//
//                             items: zoneController.zoneIds.map((int value) {
//                               return DropdownMenuItem<int>(
//                                 value: zoneController.zoneIds.indexOf(value),
//                                 child: isArabic? Text(value != 0 ? zoneController.categoryList![(zoneController.zoneIds.indexOf(value)-1)].nameAr : 'اختر المنطقة'): Text(value != 0 ? zoneController.categoryList![(zoneController.zoneIds.indexOf(value)-1)].nameEn : 'select zone'),
//                               );
//                             }).toList(),
//                             onChanged: (int? value) async {
//                               setState(() {
//                                 _value1 = value!;
//                                 zone_id = value;
//                               });
//
//                               zoneController.setCategoryIndex(value!, true);
//                               zoneController.getSubCategoryList(
//                                   value != 0 ? zoneController.categoryList![value - 1].regionId : 0
//                               );
//
//                               // حفظ الاسم والمعرف في SharedPreferences
//                               SharedPreferences prefs = await SharedPreferences.getInstance();
//
//                               if (value != 0) {
//                                 String zoneName = isArabic
//                                     ? zoneController.categoryList![value - 1].nameAr
//                                     : zoneController.categoryList![value - 1].nameEn;
//                                 int zoneId = zoneController.categoryList![value - 1].regionId;
//
//                                 await prefs.setString('zone_name', zoneName);
//                                 await prefs.setInt('zone_id', zoneId);
//                               } else {
//                                 await prefs.remove('zone_name');
//                                 await prefs.remove('zone_id');
//                               }
//
//
//                               //  HomeScreen.loadData(false);
//                             },
//
//
//                             isExpanded: true,
//                             underline: SizedBox(),
//                           ),
//                         ),
//
//
//
//                       ])),
//                       SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
//
//                       Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                         Text(
//                           'city'.tr,
//                           style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
//                         ),
//                         SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
//                             boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
//                           ),
//                           child: DropdownButton<int>(
//                             value: zoneController.subCategoryIndex,
//                             items: zoneController.cityIds.map((int value) {
//                               return DropdownMenuItem<int>(
//                                 value: zoneController.cityIds.indexOf(value),
//                                 child: isArabic? Text(value != 0 ? zoneController.subCategoryList![(zoneController.cityIds.indexOf(value)-1)].nameAr : 'اختر المدينة'):Text(value != 0 ? zoneController.subCategoryList![(zoneController.cityIds.indexOf(value)-1)].nameEn : 'select city'),
//                               );
//                             }).toList(),
//                             onChanged: (int? value) {
//                               zoneController.setSubCategoryIndex(value!, true);
//                               zoneController.getSubSubCategoryList(value != 0 ? zoneController.subCategoryList![value-1].cityId : 0);
//                               ctiy_name=zoneController.subCategoryList![value-1].nameAr ;
//                             },
//                             isExpanded: true,
//                             underline: SizedBox(),
//                           ),
//                         ),
//                       ])),
//
//                     ]),
//
//
//
//
//                     Row(children: [
//
//
//
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'district '.tr,
//                               style: robotoRegular.copyWith(
//                                 fontSize: Dimensions.fontSizeSmall,
//                                 color: Theme.of(context).disabledColor,
//                               ),
//                             ),
//                             SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                             GestureDetector(
//                               onTap: () async {
//                                 final selected = await showModalBottomSheet<DistrictModel>(
//                                   context: context,
//                                   isScrollControlled: true,
//                                   backgroundColor: Theme.of(context).cardColor,
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//                                   ),
//                                   builder: (context) {
//                                     TextEditingController searchController = TextEditingController();
//                                     List<DistrictModel> filteredList = List.from(zoneController.subSubCategoryList ?? []);
//
//                                     return StatefulBuilder(
//                                       builder: (context, setState) => Padding(
//                                         padding: const EdgeInsets.all(16),
//                                         child: SizedBox(
//                                           // تحديد طول النافذة نصف الشاشة
//                                           height: MediaQuery.of(context).size.height * 0.5,
//                                           child: Column(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               TextField(
//                                                 controller: searchController,
//                                                 decoration: InputDecoration(
//                                                   hintText: 'ابحث عن الحي',
//                                                   prefixIcon: Icon(Icons.search),
//                                                   border: OutlineInputBorder(
//                                                     borderRadius: BorderRadius.circular(12),
//                                                   ),
//                                                 ),
//                                                 onChanged: (query) {
//                                                   setState(() {
//                                                     filteredList = (zoneController.subSubCategoryList ?? []).where((district) {
//                                                       return district.nameAr.toLowerCase().contains(query.toLowerCase());
//                                                     }).toList();
//                                                   });
//                                                 },
//                                               ),
//                                               SizedBox(height: 10),
//                                               Expanded(
//                                                 child: ListView.builder(
//                                                   shrinkWrap: true,
//                                                   itemCount: filteredList.length,
//                                                   itemBuilder: (context, index) {
//                                                     final item = filteredList[index];
//                                                     return ListTile(
//                                                       title: Text(item.nameAr),
//                                                       onTap: () => Navigator.pop(context, item),
//                                                     );
//                                                   },
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     );
//                                   },
//                                 );
//
//                                 if (selected != null) {
//                                   final index = zoneController.subSubCategoryList!
//                                       .indexWhere((e) => e.districtId == selected.districtId);
//                                   if (index != -1) {
//                                     zoneController.setSubSubCategoryIndex(index + 1, true);
//                                     districts = selected.nameAr;
//                                   }
//                                 }
//                               },
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL, vertical: 12),
//                                 decoration: BoxDecoration(
//                                   color: Theme.of(context).cardColor,
//                                   borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
//                                       spreadRadius: 2,
//                                       blurRadius: 5,
//                                       offset: Offset(0, 5),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         ((districts ?? '').isNotEmpty) ? districts! : 'اختر الحي',
//                                         overflow: TextOverflow.ellipsis,
//                                         style: TextStyle(
//                                           color: ((districts ?? '').isEmpty)
//                                               ? Colors.grey
//                                               : Theme.of(context).textTheme.bodyLarge?.color,
//                                         ),
//                                       ),
//                                     ),
//                                     Icon(Icons.arrow_drop_down),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//
//
//
//                       // Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                       //   Text(
//                       //     'district '.tr,
//                       //     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
//                       //   ),
//                       //   SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                       //   Container(
//                       //     padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
//                       //     decoration: BoxDecoration(
//                       //       color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
//                       //       boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
//                       //     ),
//                       //     child: DropdownButton<int>(
//                       //       value: zoneController.subSubCategoryIndex,
//                       //       items: zoneController.subSubCategoryIds.map((int value) {
//                       //         return DropdownMenuItem<int>(
//                       //           value: zoneController.subSubCategoryIds.indexOf(value),
//                       //           child: isArabic? Text(value != 0 ? zoneController.subSubCategoryList![(zoneController.subSubCategoryIds.indexOf(value)-1)].nameAr : 'اختر الحي'):Text(value != 0 ? zoneController.subSubCategoryList![(zoneController.subSubCategoryIds.indexOf(value)-1)].nameEn : 'select district'),
//                       //         );
//                       //       }).toList(),
//                       //       onChanged: (int? value) {
//                       //         zoneController.setSubSubCategoryIndex(value!, true);
//                       //         districts= zoneController.subSubCategoryList![value-1].nameAr ;
//                       //       },
//                       //       isExpanded: true,
//                       //       underline: SizedBox(),
//                       //     ),
//                       //   ),
//                       // ])),
//
//                     ]),
//
//                     // popularFilter(),
//                     const Divider(
//                       height: 1,
//                     ),
//                     SizedBox(height: 30,),
//                     spaceViewUI(),
//                     const Divider(
//                       height: 1,
//                     ),
//                     Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: filters.map((filter) {
//                         final isSelected = selectedFilters.contains(filter);
//
//                         return FilterSwitch(
//                           label: filter,
//                           initialValue: isSelected,
//                           onChanged: (bool newValue) {
//                             setState(() {
//                               if (newValue) {
//                                 selectedFilters.add(filter);
//                               } else {
//                                 selectedFilters.remove(filter);
//                               }
//                             });
//                           },
//                         );
//                       }).toList(),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const Divider(
//               height: 1,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(
//                   left: 16, right: 16, bottom: 16, top: 8),
//               child: Container(
//                 height: 48,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor,
//                   borderRadius: const BorderRadius.all(Radius.circular(24.0)),
//                   boxShadow: <BoxShadow>[
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.6),
//                       blurRadius: 8,
//                       offset: const Offset(4, 4),
//                     ),
//                   ],
//                 ),
//                 child: Material(
//                   color: Colors.transparent,
//                   child: InkWell(
//                     borderRadius: const BorderRadius.all(Radius.circular(24.0)),
//                     highlightColor: Colors.transparent,
//                     onTap: () async{
//                       //
//                       //    String value;
//                       //    for (int i = 0; i < accomodationListData.length; i++) {
//                       //      final PopularFilterListData date = accomodationListData[i];
//                       // showCustomSnackBar(date.titleTxt);
//                       //    }
//
//                       int  arValue=0;
//                       if(selectedFilters.join(', ')=="virtual_ture".tr){
//                         arValue=1;
//                       }else
//                       {
//                         arValue=0;
//                       }
//
//                       showCustomSnackBar(selectedFilters.join(', '));
//
//
//                       SharedPreferences prefs = await SharedPreferences.getInstance();
//                       int? savedZoneId = prefs.getInt('zone_id');       // قد تكون null
//                       int? category_id = prefs.getInt('sub_category_id'); // قد تكون null
//
//                       print('zone_id: $savedZoneId');
//                       print('sub_category_id: $category_id');
//
// // استدعاء setFilterIndex مع دعم null
//                       Get.find<CategoryController>().setFilterIndex(
//                         savedZoneId ?? 0,        // إذا كانت null، استخدم 0 أو أي قيمة افتراضية مناسبة
//                         category_id ?? 0,        // إذا كانت null، استخدم 0
//                         ctiy_name ?? "",
//                         districts ?? "",
//                         distValue ~/ 10,
//                         selectedFilters.join(', ') == 'virtual_ture'.tr ? 1 : 0,
//                         selectedFilters.join(', ') == 'it_includes_offers'.tr ? 1 : 0,
//                         selectedPropertyType,
//                       );
//
//                       Navigator.pop(context);
//
//
//                       // int? category_id = prefs.getInt('sub_category_id');
//                       //
//                       // Get.find<CategoryController>().setFilterIndex(savedZoneId!,category_id!,ctiy_name??"",districts??"",distValue~/10,selectedFilters.join(', ')=='virtual_ture'.tr?1:0,selectedFilters.join(', ')=='it_includes_offers'.tr?1:0,selectedPropertyType);
//                       // Navigator.pop(context);
//                     },
//                     child: const Center(
//                       child: Text(
//                         'Apply',
//                         style: TextStyle(
//                             fontWeight: FontWeight.w500,
//                             fontSize: 18,
//                             color: Colors.white),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     ): Center(child: CircularProgressIndicator());
//       });
//     });
//      });
//   }
//
//   Widget allAccommodationUI() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Padding(
//           padding:
//           const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
//           child: Text(
//             'search_properties'.tr,
//             textAlign: TextAlign.left,
//             style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
//                 fontWeight: FontWeight.normal),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(right: 16, left: 16),
//           child: Column(
//             // children: getAccomodationListUI(),
//           ),
//         ),
//         const SizedBox(
//           height: 8,
//         ),
//       ],
//     );
//   }
//
//
//
//   void checkAppPosition(int index) {
//     if (index == 0) {
//       if (accomodationListData[0].isSelected) {
//         for (var d in accomodationListData) {
//           d.isSelected = false;
//         }
//       } else {
//         for (var d in accomodationListData) {
//           d.isSelected = true;
//         }
//       }
//     } else {
//       accomodationListData[index].isSelected =
//       !accomodationListData[index].isSelected;
//
//       int count = 0;
//       for (int i = 0; i < accomodationListData.length; i++) {
//         if (i != 0) {
//           final PopularFilterListData data = accomodationListData[i];
//           if (data.isSelected) {
//             count += 1;
//           }
//         }
//       }
//
//       if (count == accomodationListData.length - 1) {
//         accomodationListData[0].isSelected = true;
//       } else {
//         accomodationListData[0].isSelected = false;
//       }
//     }
//     showCustomSnackBar(accomodationListData[index].titleTxt);
//   }
//
//   Widget spaceViewUI() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: <Widget>[
//         Padding(
//           padding:
//           const EdgeInsets.only(left: 16, right: 16),
//           child: Text(
//             'space'.tr,
//             textAlign: TextAlign.left,
//             style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 16,
//                 fontWeight: FontWeight.normal),
//           ),
//         ),
//         SliderView(
//           distValue: distValue,
//           onChangedistValue: (double value) {
//             distValue = value;
//           },
//         ),
//         const SizedBox(
//           height: 8,
//         ),
//       ],
//     );
//   }
//
//   Widget getAppBarUI() {
//     return Container(
//       decoration: BoxDecoration(
//         color:Theme.of(context).primaryColor,
//         boxShadow: <BoxShadow>[
//           BoxShadow(
//               color: Colors.grey.withOpacity(0.2),
//               offset: const Offset(0, 2),
//               blurRadius: 4.0),
//         ],
//       ),
//       child: Padding(
//         padding: EdgeInsets.only(
//             top: MediaQuery.of(context).padding.top, left: 8, right: 8),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: <Widget>[
//             Container(
//
//               child: Material(
//                 color: Colors.transparent,
//                 child: InkWell(
//                   borderRadius: const BorderRadius.all(
//                     Radius.circular(32.0),
//                   ),
//                   onTap: () {
//                     Navigator.pop(context);
//                   },
//                   child: const Padding(
//                     padding: EdgeInsets.all(8.0),
//                     child: Icon(Icons.close,color: Colors.white,),
//                   ),
//                 ),
//               ),
//             ),
//             Text(
//               'filter'.tr,
//               style: const TextStyle(
//                   fontWeight: FontWeight.w600,
//                   fontSize: 22,
//                   color: Colors.white
//               ),
//             ),
//             SizedBox(
//               width: AppBar().preferredSize.height + 20,
//               height: AppBar().preferredSize.height,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/zones/controller/zone_controller.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/features/filter/view/widgets/slider_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/model/response/district_model.dart';
import 'widgets/popular_filter_list.dart';

class FiltersScreen extends StatefulWidget {
  const FiltersScreen({super.key});

  @override
  _FiltersScreenState createState() => _FiltersScreenState();
}

class _FiltersScreenState extends State<FiltersScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController scrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;

  List<PopularFilterListData> accomodationListData =
      PopularFilterListData.accomodationList;

  late String type_properties;
  String? ctiy_name;
  String? districts;
  late int zone_id;
  late String zone_name;

  double distValue = 0;
  int _value1 = 0;
  List<String> selectedFilters = [];
  String selectedPropertyType = 'بيع';

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get isArabic =>
      Get.find<LocalizationController>().isLtr == false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    Get.find<ZoneController>().getCategoryList();
    Get.find<CategoryController>().getSubCategoryList("0");
    ctiy_name = "";

    int offset = 1;
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent &&
          !Get.find<CategoryController>().isLoading) {
        int pageSize =
        (Get.find<CategoryController>().pageSize! / 10).ceil();
        if (offset < pageSize) {
          offset++;
          Get.find<CategoryController>().showBottomLoader();
          Get.find<CategoryController>().getCategoryProductList(
            0, "0", 0, '0', "0", "0", "0",
            reload: false, arPath: 0, sv: 0, type: "",
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;
    final primaryColor = theme.primaryColor;

    List<String> filters = ['it_includes_offers'.tr, 'virtual_ture'.tr];

    return GetBuilder<EstateController>(builder: (restController) {
      return GetBuilder<ZoneController>(builder: (zoneController) {
        return GetBuilder<CategoryController>(builder: (categoryController) {
          if (zoneController.subCategoryList == null) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: primaryColor),
              ),
            );
          }

          return Scaffold(
            backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF5F6FA),
            body: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                children: [
                  // ─── AppBar ─────────────────────────────────────
                  _buildAppBar(primaryColor),

                  // ─── Body ───────────────────────────────────────
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── نوع العملية (بيع / إيجار) ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  isArabic ? 'نوع العملية' : 'Operation Type',
                                  Icons.swap_horiz_rounded,
                                  primaryColor,
                                ),
                                const SizedBox(height: 12),
                                _buildToggleButtons(primaryColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── نوع العقار ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  'type_property'.tr,
                                  Icons.home_work_rounded,
                                  primaryColor,
                                ),
                                const SizedBox(height: 12),

                                // Sub categories
                                if (categoryController.subCategoryList != null)
                                  _buildHorizontalChips(
                                    items: categoryController.subCategoryList!
                                        .map((e) => isArabic
                                        ? e.nameAr ?? ''
                                        : e.name ?? 'all')
                                        .toList(),
                                    images: categoryController.subCategoryList!
                                        .map((e) =>
                                    '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${e.image}')
                                        .toList(),
                                    selectedIndex:
                                    categoryController.subCategoryIndex,
                                    primaryColor: primaryColor,
                                    onTap: (index) async {
                                      SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                      int? savedZoneId =
                                      prefs.getInt('zone_id');
                                      categoryController.setSubCategoryIndex(
                                          index, savedZoneId ?? 0);
                                      int selectedId = categoryController
                                          .subCategoryList![index].id!;
                                      await prefs.setInt(
                                          'sub_category_id', selectedId);
                                    },
                                    showImage: true,
                                  ),

                                const SizedBox(height: 12),

                                // Main categories
                                if (categoryController.categoryList != null)
                                  _buildHorizontalChips(
                                    items: categoryController.categoryList!
                                        .map((e) => isArabic
                                        ? e.nameAr ?? ''
                                        : e.name ?? '')
                                        .toList(),
                                    images: categoryController.categoryList!
                                        .map((e) =>
                                    '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${e.image}')
                                        .toList(),
                                    selectedIndex: categoryController
                                        .categoryList!
                                        .indexWhere((e) =>
                                    e.id ==
                                        restController.categoryIndex),
                                    primaryColor: primaryColor,
                                    onTap: (index) {
                                      restController.setCategoryIndex(
                                          categoryController
                                              .categoryList![index].id ?? 0);
                                      restController.setCategoryPostion(
                                          int.parse(categoryController
                                              .categoryList?[index].position ??
                                              "0"));
                                      setState(() {
                                        type_properties = categoryController
                                            .categoryList![index].name ?? "";
                                      });
                                    },
                                    showImage: true,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── الموقع ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  isArabic ? 'الموقع' : 'Location',
                                  Icons.location_on_rounded,
                                  primaryColor,
                                ),
                                const SizedBox(height: 12),

                                // المنطقة و المدينة جنباً إلى جنب
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStyledDropdown(
                                        label: 'zone'.tr,
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        child: DropdownButton<int>(
                                          value: _value1,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          dropdownColor: isDark
                                              ? const Color(0xFF2A2A3C)
                                              : Colors.white,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 14,
                                          ),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: primaryColor,
                                          ),
                                          items: zoneController.zoneIds
                                              .map((int value) {
                                            final idx = zoneController.zoneIds
                                                .indexOf(value);
                                            return DropdownMenuItem<int>(
                                              value: idx,
                                              child: Text(
                                                value != 0
                                                    ? (isArabic
                                                    ? zoneController
                                                    .categoryList![
                                                idx - 1]
                                                    .nameAr
                                                    : zoneController
                                                    .categoryList![
                                                idx - 1]
                                                    .nameEn)
                                                    : (isArabic
                                                    ? 'اختر المنطقة'
                                                    : 'Select Region'),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (int? value) async {
                                            setState(
                                                    () => _value1 = value!);
                                            zoneController.setCategoryIndex(
                                                value!, true);
                                            zoneController.getSubCategoryList(
                                                value != 0
                                                    ? zoneController
                                                    .categoryList![
                                                value - 1]
                                                    .regionId
                                                    : 0);
                                            SharedPreferences prefs =
                                            await SharedPreferences
                                                .getInstance();
                                            if (value != 0) {
                                              await prefs.setString(
                                                  'zone_name',
                                                  isArabic
                                                      ? zoneController
                                                      .categoryList![
                                                  value - 1]
                                                      .nameAr
                                                      : zoneController
                                                      .categoryList![
                                                  value - 1]
                                                      .nameEn);
                                              await prefs.setInt(
                                                  'zone_id',
                                                  zoneController
                                                      .categoryList![
                                                  value - 1]
                                                      .regionId);
                                            } else {
                                              await prefs.remove('zone_name');
                                              await prefs.remove('zone_id');
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _buildStyledDropdown(
                                        label: 'city'.tr,
                                        isDark: isDark,
                                        primaryColor: primaryColor,
                                        child: DropdownButton<int>(
                                          value:
                                          zoneController.subCategoryIndex,
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          dropdownColor: isDark
                                              ? const Color(0xFF2A2A3C)
                                              : Colors.white,
                                          style: TextStyle(
                                            color: isDark
                                                ? Colors.white
                                                : Colors.black87,
                                            fontSize: 14,
                                          ),
                                          icon: Icon(
                                            Icons.keyboard_arrow_down_rounded,
                                            color: primaryColor,
                                          ),
                                          items: zoneController.cityIds
                                              .map((int value) {
                                            final idx = zoneController.cityIds
                                                .indexOf(value);
                                            return DropdownMenuItem<int>(
                                              value: idx,
                                              child: Text(
                                                value != 0
                                                    ? (isArabic
                                                    ? zoneController
                                                    .subCategoryList![
                                                idx - 1]
                                                    .nameAr
                                                    : zoneController
                                                    .subCategoryList![
                                                idx - 1]
                                                    .nameEn)
                                                    : (isArabic
                                                    ? 'اختر المدينة'
                                                    : 'Select City'),
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (int? value) {
                                            zoneController
                                                .setSubCategoryIndex(
                                                value!, true);
                                            zoneController
                                                .getSubSubCategoryList(
                                                value != 0
                                                    ? zoneController
                                                    .subCategoryList![
                                                value - 1]
                                                    .cityId
                                                    : 0);
                                            ctiy_name = zoneController
                                                .subCategoryList![value - 1]
                                                .nameAr;
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // الحي
                                Text(
                                  'district'.tr,
                                  style: robotoRegular.copyWith(
                                    fontSize: Dimensions.fontSizeSmall,
                                    color: theme.hintColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                GestureDetector(
                                  onTap: () => _showDistrictPicker(
                                      context, zoneController, primaryColor),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF2A2A3C)
                                          : Colors.grey[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: (districts ?? '').isNotEmpty
                                            ? primaryColor.withOpacity(0.5)
                                            : (isDark
                                            ? Colors.white12
                                            : Colors.grey.shade200),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          (districts ?? '').isNotEmpty
                                              ? districts!
                                              : (isArabic
                                              ? 'اختر الحي'
                                              : 'Select District'),
                                          style: TextStyle(
                                            color: (districts ?? '').isEmpty
                                                ? Colors.grey[400]
                                                : (isDark
                                                ? Colors.white
                                                : Colors.black87),
                                            fontSize: 14,
                                          ),
                                        ),
                                        Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── المساحة ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  'space'.tr,
                                  Icons.square_foot_rounded,
                                  primaryColor,
                                ),
                                SliderView(
                                  distValue: distValue,
                                  onChangedistValue: (double value) {
                                    setState(() => distValue = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── خيارات إضافية ──
                          _buildSectionCard(
                            isDark: isDark,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _sectionTitle(
                                  isArabic ? 'خيارات إضافية' : 'Extra Options',
                                  Icons.tune_rounded,
                                  primaryColor,
                                ),
                                const SizedBox(height: 8),
                                ...filters.map((filter) {
                                  final isSelected =
                                  selectedFilters.contains(filter);
                                  return _buildModernSwitch(
                                    label: filter,
                                    value: isSelected,
                                    primaryColor: primaryColor,
                                    isDark: isDark,
                                    onChanged: (bool val) {
                                      setState(() {
                                        if (val) {
                                          selectedFilters.add(filter);
                                        } else {
                                          selectedFilters.remove(filter);
                                        }
                                      });
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),

                  // ─── Apply Button ────────────────────────────────
                  _buildApplyButton(primaryColor, categoryController),
                ],
              ),
            ),
          );
        });
      });
    });
  }

  // ─── AppBar ─────────────────────────────────────────────────────────────────
  Widget _buildAppBar(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // زر الإغلاق
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 18),
                ),
              ),

              // العنوان
              Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'filter'.tr,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),

              // زر إعادة الضبط
              TextButton(
                onPressed: () {
                  setState(() {
                    _value1 = 0;
                    ctiy_name = "";
                    districts = null;
                    distValue = 0;
                    selectedFilters.clear();
                    selectedPropertyType = isArabic ? 'بيع' : 'Sale';
                  });
                },
                child: Text(
                  isArabic ? 'إعادة' : 'Reset',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section Card ────────────────────────────────────────────────────────────
  Widget _buildSectionCard({required bool isDark, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  // ─── Section Title ───────────────────────────────────────────────────────────
  Widget _sectionTitle(String title, IconData icon, Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryColor, size: 16),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: Dimensions.fontSizeDefault,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  // ─── Toggle Buttons (بيع / إيجار) ───────────────────────────────────────────
  Widget _buildToggleButtons(Color primaryColor) {
    final options = isArabic
        ? [('بيع', 'بيع'), ('إيجار', 'إيجار')]
        : [('Sale', 'Sale'), ('Rent', 'Rent')];

    return Row(
      children: options.map((opt) {
        final isSelected = selectedPropertyType == opt.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedPropertyType = opt.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  left: opt.$1 == options[0].$1 ? 0 : 6,
                  right: opt.$1 == options[0].$1 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : primaryColor.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  opt.$2,
                  style: robotoMedium.copyWith(
                    color: isSelected ? Colors.white : primaryColor,
                    fontSize: Dimensions.fontSizeDefault,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Horizontal Chips ────────────────────────────────────────────────────────
  Widget _buildHorizontalChips({
    required List<String> items,
    required List<String> images,
    required int selectedIndex,
    required Color primaryColor,
    required Function(int) onTap,
    bool showImage = false,
  }) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor
                    : primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? primaryColor
                      : primaryColor.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    items[index],
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: isSelected ? Colors.white : primaryColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (showImage && index != 0) ...[
                    const SizedBox(width: 6),
                    CustomImage(
                      image: images[index],
                      height: 20,
                      width: 20,
                      colors: isSelected ? Colors.white : primaryColor,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Styled Dropdown Wrapper ─────────────────────────────────────────────────
  Widget _buildStyledDropdown({
    required String label,
    required bool isDark,
    required Color primaryColor,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Colors.grey[500],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2A2A3C) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.white12 : Colors.grey.shade200,
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  // ─── Modern Switch ───────────────────────────────────────────────────────────
  Widget _buildModernSwitch({
    required String label,
    required bool value,
    required Color primaryColor,
    required bool isDark,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: isDark ? Colors.white70 : Colors.grey[700],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }

  // ─── District Picker ─────────────────────────────────────────────────────────
  Future<void> _showDistrictPicker(
      BuildContext context,
      dynamic zoneController,
      Color primaryColor,
      ) async {
    final selected = await showModalBottomSheet<DistrictModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        TextEditingController searchController = TextEditingController();
        List<DistrictModel> filteredList =
        List.from(zoneController.subSubCategoryList ?? []);

        return StatefulBuilder(
          builder: (context, setModalState) => Container(
            decoration: BoxDecoration(
              color: Get.isDarkMode
                  ? const Color(0xFF1E1E2C)
                  : Colors.white,
              borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Row(
                    children: [
                      Icon(Icons.location_city_rounded,
                          color: primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        isArabic ? 'اختر الحي' : 'Select District',
                        style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeLarge,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: isArabic
                          ? 'ابحث عن الحي...'
                          : 'Search district...',
                      prefixIcon:
                      Icon(Icons.search_rounded, color: primaryColor),
                      filled: true,
                      fillColor: Get.isDarkMode
                          ? const Color(0xFF2A2A3C)
                          : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: primaryColor, width: 1.5),
                      ),
                    ),
                    onChanged: (query) {
                      setModalState(() {
                        filteredList =
                            (zoneController.subSubCategoryList ?? [])
                                .where((d) => d.nameAr
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                                .toList();
                      });
                    },
                  ),
                  const SizedBox(height: 8),

                  // List
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredList.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: Colors.grey.withOpacity(0.1),
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredList[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                            primaryColor.withOpacity(0.1),
                            radius: 16,
                            child: Text(
                              item.nameAr.isNotEmpty
                                  ? item.nameAr[0]
                                  : '',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Text(
                            isArabic ? item.nameAr : item.nameEn,
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeDefault,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                          onTap: () =>
                              Navigator.pop(context, item),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (selected != null) {
      final index = zoneController.subSubCategoryList!
          .indexWhere((e) => e.districtId == selected.districtId);
      if (index != -1) {
        zoneController.setSubSubCategoryIndex(index + 1, true);
        setState(() => districts = isArabic
            ? selected.nameAr
            : selected.nameEn);
      }
    }
  }

  // ─── Apply Button ────────────────────────────────────────────────────────────
  Widget _buildApplyButton(
      Color primaryColor, dynamic categoryController) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Get.isDarkMode
            ? const Color(0xFF1E1E2C)
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ElevatedButton(
          onPressed: () async {
            SharedPreferences prefs =
            await SharedPreferences.getInstance();
            int? savedZoneId = prefs.getInt('zone_id');
            int? categoryId = prefs.getInt('sub_category_id');

            Get.find<CategoryController>().setFilterIndex(
              savedZoneId ?? 0,
              categoryId ?? 0,
              ctiy_name ?? "",
              districts ?? "",
              distValue ~/ 10,
              selectedFilters.join(', ') == 'virtual_ture'.tr ? 1 : 0,
              selectedFilters.join(', ') == 'it_includes_offers'.tr
                  ? 1
                  : 0,
              selectedPropertyType,
            );
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                isArabic ? 'تطبيق الفلتر' : 'Apply Filter',
                style: robotoMedium.copyWith(
                  color: Colors.white,
                  fontSize: Dimensions.fontSizeLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}