// import 'dart:async';
// import 'dart:collection';
// import 'dart:typed_data';
//
// import 'package:abaad_flutter/controller/category_controller.dart';
// import 'package:abaad_flutter/controller/localization_controller.dart';
// import 'package:abaad_flutter/controller/location_controller.dart';
// import 'package:abaad_flutter/controller/splash_controller.dart';
// import 'package:abaad_flutter/controller/user_controller.dart';
// import 'package:abaad_flutter/data/model/response/estate_model.dart';
// import 'package:abaad_flutter/data/model/response/zone_model.dart';
// import 'package:abaad_flutter/util/dimensions.dart';
// import 'dart:ui' as ui;
// import 'package:abaad_flutter/util/styles.dart';
// import 'package:abaad_flutter/view/base/custom_image.dart';
// import 'package:abaad_flutter/view/base/custom_snackbar.dart';
// import 'package:abaad_flutter/view/base/details_dilog.dart';
// import 'package:abaad_flutter/view/base/drawer_menu.dart';
// import 'package:abaad_flutter/view/base/estate_item.dart';
// import 'package:abaad_flutter/view/base/no_data_screen.dart';
// import 'package:abaad_flutter/view/screen/fillter/fillter_estate_sheet.dart';
// import 'package:abaad_flutter/view/base/web_menu_bar.dart';
// import 'package:custom_map_markers/custom_map_markers.dart';
// import 'package:flip_card/flip_card.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:abaad_flutter/util/images.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import 'widget/location_search_dialog.dart';
// import 'widget/permission_dialog.dart';
// import 'widget/service_provider.dart';
//
// class MapScreen extends StatefulWidget {
//   ZoneModel mainCategory;
//   final bool fromSignUp;
//   final bool fromAddAddress;
//   final bool canRoute;
//   final String route;
//   final GoogleMapController? googleMapController;
//   MapScreen({
//     Key? key,
//     required this.mainCategory,
//     required this.fromSignUp,
//     required this.fromAddAddress,
//     required this.canRoute,
//     required this.route,
//     this.googleMapController
//   }) : super(key: key);
//
//   @override
//   State<MapScreen> createState() => _MapViewScreenState();
// }
//
// class _MapViewScreenState extends State<MapScreen> {
//   late GoogleMapController _controller;
//   List<MarkerData> _customMarkers = [];
//   late CameraPosition _cameraPosition;
//   final ScrollController scrollController = ScrollController();
//   late Uint8List imageDataBytes;
//   var markerIcon;
//   // GlobalKey iconKey = GlobalKey();
//   String selectedOption = 'بيع';
//
//
//   int _reload = 0;
//   final Set<Polygon> _polygon = HashSet<Polygon>();
//   bool cardTapped = false;
//   bool card = false;
//   bool searchToggle = false;
//   final Set<Circle> _circles = <Circle>{};
//   bool radiusSlider = false;
//   bool backProider= false;
//
//   late LatLng _initialPosition;
//   var photoGalleryIndex = 0;
//   final bool _ltr = Get.find<LocalizationController>().isLtr;
//   MapType _currentMapType = MapType.satellite;
//   // Set<Marker> _markers = Set<Marker>();
//
//   var tappedPoint;
//
//    Estate? estate;
//
//
//
//   // final GlobalKey _floatingButtonKey = GlobalKey();
//   // final GlobalKey _editButtonKey = GlobalKey();
//   // final GlobalKey _settingsButtonKey = GlobalKey();
//   void _onMapTypeButtonPressed() {
//     setState(() {
//       _currentMapType = _currentMapType == MapType.normal
//           ? MapType.satellite
//           : MapType.normal;
//     });
//   }
//
//   late PageController _pageController;
//   int prevPage = 0;
//   bool showBlankCard = false;
//   bool pressedNear = false;
//
//   var radiusValue = 3000.0;
//   late Timer _debounce;
//   String tokenKey = '';
//   late int index;
//   void _onScroll() {
//     if (_pageController.page!.toInt() != prevPage) {
//       prevPage = _pageController.page!.toInt();
//       cardTapped = false;
//       photoGalleryIndex = 1;
//       showBlankCard = false;
//       card=false;
//       // goToTappedPlace();
//       // fetchImage();
//     }
//   }
//   int selectedIndex = 0;
//
//
//
//
//   void _setCircle(LatLng point) async {
//
//
//
//     _controller.animateCamera(CameraUpdate.newCameraPosition(
//         CameraPosition(target: point, zoom: 12)));
//     setState(() {
//       _circles.add(Circle(
//           circleId: CircleId('raj'),
//           center: point,
//           fillColor: Colors.blue.withOpacity(0.1),
//           radius: radiusValue,
//           strokeColor: Colors.blue,
//           strokeWidth: 1));
//       //  getDirections = false;
//       searchToggle = false;
//       radiusSlider = true;
//     });
//   }
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     _pageController = PageController(initialPage: 1, viewportFraction: 0.85)
//       ..addListener(_onScroll);
//
//     // Get.find<AuthController>().getZoneList();
//     // if(Get.find<CategoryController>().categoryList == null) {
//     //   Get.find<CategoryController>().getCategoryList(true);
//     // }
//     // Get.find<CategoryController>().getSubCategoryList("0");
//     int offset = 1;
//     // Get.find<ZoneController>().geZonesList();
//     // scrollController?.addListener(() {
//     //   if (scrollController.position.pixels == scrollController.position.maxScrollExtent
//     //       && Get.find<CategoryController>().categoryProductList != null
//     //       && !Get.find<CategoryController>().isLoading) {
//     //     int pageSize = (Get.find<CategoryController>().pageSize / 10).ceil();
//     //     if (offset < pageSize) {
//     //       offset++;
//     //       //print('end of the page');
//     //       Get.find<CategoryController>().showBottomLoader();
//     //       //      Get.find<CategoryController>().getCategoryProductList("${widget.mainCategory.id}", 0,'0',"0","0","0", offset.toString());
//     //     }
//     //   }
//     // });
//     cardTapped = false;
//     // if(widget.fromAddAddress) {
//     //   Get.find<LocationController>().setPickData();
//     // }
//     // if(Get.find<CategoryController>().categoryList == null) {
//     //   Get.find<CategoryController>().getCategoryList(true);
//     // }
//
//
//     // getUserCurrentLocation().then((value) async {
//     //   CameraPosition cameraPosition = new CameraPosition(
//     //     target: LatLng(value.latitude, value.longitude),
//     //     zoom: 14,
//     //   );
//     //   _initialPosition = LatLng(
//     //       value.latitude,
//     //       value.longitude
//     //   );
//     //
//     //   _controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
//     //   setState(() {});
//     // });
//
//     _initialPosition = LatLng(
//         26.451363,
//         50.109046
//     );
//
//
//   }
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
//
//   get borderRadius => BorderRadius.circular(8.0);
//
//   Future<void> getCustomMarkerIcon(GlobalKey iconKey) async {
//     RenderRepaintBoundary? boundary = iconKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
//     ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
//     ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     var pngBytes = byteData!.buffer.asUint8List();
//     setState(() {
//       markerIcon = BitmapDescriptor.fromBytes(pngBytes);
//     });
//   }
//
//   final GlobalKey<ScaffoldState> _key = GlobalKey();
//   final cardKey = GlobalKey<FlipCardState>();
//   @override
//   Widget build(BuildContext context) {
//
//     final currentLocale = Get.locale;
//     bool isArabic = currentLocale?.languageCode == 'ar';
//     bool isNull = true;
//     int length = 0;
//     var width = MediaQuery
//         .of(context)
//         .size
//         .width;
//     var height = MediaQuery
//         .of(context)
//         .size
//         .height;
//
//     return Scaffold(
//         key: _key,
//         appBar: WebMenuBar(ontop:()=>     _key.currentState!.openDrawer(),fromPage: "main"),
//         drawer: DrawerMenu(),
//         body:
//         GetBuilder<CategoryController>(builder: (categoryController) {
//
//           return GetBuilder<LocationController>(builder: (locationController) {
//
//             List<Estate> products;
//             products = [];
//             if (categoryController.isSearching) {
//
//             } else {
//               //products.addAll(categoryController.categoryProductList as Iterable<Estate>);
//               if (categoryController.categoryProductList != null) {
//                 products.addAll(categoryController.categoryProductList!);
//               }
//             }
//
//
//             isNull = products == null;
//             if(!isNull) {
//               length = products.length;
//             }
//
//             if(categoryController.subCategoryIndex==0){
//               _setMarkers(products);
//             }
//
//
//
//             return       CustomGoogleMapMarkerBuilder (
//               customMarkers: _customMarkers,
//               builder: (context, markers) {
//
//                 if (markers == null) {
//
//                   return              Stack(children: [
//                     !isNull ?products.isNotEmpty?
//
//                     GoogleMap(
//                       initialCameraPosition:  CameraPosition(zoom: 10, target: LatLng(
//                         // double.parse(Get.find<LocationController>().getUserAddress().latitude),
//                         // double.parse(Get.find<LocationController>().getUserAddress().longitude),
//                         double.parse(widget.mainCategory.longitude),
//                         double.parse(widget.mainCategory.latitude),
//                       )),
//                       // markers: markers,
//                       // myLocationEnabled: false,
//                       // compassEnabled: false,
//                        zoomControlsEnabled: false,
//                       mapType: _currentMapType,
//                       onTap: (point) {
//                         tappedPoint = point;
//                         _setCircle(point);
//                       },
//                       minMaxZoomPreference: MinMaxZoomPreference(0, 40),
//                       onMapCreated: (GoogleMapController controller) {
//
//                         _controller = controller;
//
//                         // if(_products.length > 0) {
//                         //   _setMarkers(_products);
//                         // }
//
//                       },
//                     ):Center(
//                       child: NoDataScreen(
//                         text: 'no_data_available',
//                       ),
//                     ):  GoogleMap(
//                       initialCameraPosition:  CameraPosition(zoom: 10, target: LatLng(
//                         // double.parse(Get.find<LocationController>().getUserAddress().latitude),
//                         // double.parse(Get.find<LocationController>().getUserAddress().longitude),
//                         double.parse(widget.mainCategory.longitude),
//                         double.parse(widget.mainCategory.latitude),
//                       )),
//                       // markers: markers,
//                       // myLocationEnabled: false,
//                       // compassEnabled: false,
//                       zoomControlsEnabled: false,
//                       mapType: _currentMapType,
//                       onTap: (point) {
//                         tappedPoint = point;
//                         _setCircle(point);
//                       },
//                       minMaxZoomPreference: MinMaxZoomPreference(0, 40),
//                       onMapCreated: (GoogleMapController controller) {
//
//                         _controller = controller;
//
//                         // if(_products.length > 0) {
//                         //   _setMarkers(_products);
//                         // }
//
//                       },
//                     ),
//
//                     categoryController.isLoading ? Center(child: Padding(
//                       padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
//                       child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
//                     )) : SizedBox(),
//
//
//
//                     SafeArea(
//                       child: Align(
//                         alignment: Alignment.topCenter,
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 7.0),
//                           child: Container(
//                             margin: const EdgeInsets.only(left: 10.0, right: 7.0),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//
//                               children: <Widget>[
//                                 Row(
//                                   children: [
//
//                                     InkWell(
//                                       onTap: () => Get.dialog(LocationSearchDialog(mapController: _controller)),
//                                       child: Container(
//                                         height: 43,
//                                         padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
//                                         decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
//                                         width: width-130,
//                                         child:  Row(children: [
//                                           Icon(Icons.location_on, size: 25, color: Theme.of(context).primaryColor),
//                                           SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                                           Container(
//                                             child: Expanded(
//                                               child: Text(
//                                                 locationController.pickAddress,
//                                                 style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
//                                           Icon(Icons.search, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
//                                         ]),
//                                       ),
//                                     ),
//                                     Container(
//                                       margin: const EdgeInsets.only(
//                                           left: 4.0, right: 4.0),
//                                       padding: const EdgeInsets.all(7),
//                                       decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(5),
//                                           border: Border.all(
//                                             width: 1,
//                                             color: Colors.blue,
//                                           )),
//
//
//                                       child: const Icon(Icons.qr_code, size: 25,
//                                         color: Colors.blue,),
//                                     ),
//                                     GestureDetector(
//                                       onTap: (){
//                                         cardTapped=true;
//                                         Get.dialog(FiltersScreen());
//                                       },
//                                       child: Container(
//                                         padding: const EdgeInsets.all(7),
//                                         margin: const EdgeInsets.only(
//                                             left: 4.0, right: 4.0),
//                                         decoration: BoxDecoration(
//                                             color: Colors.blue,
//                                             borderRadius: BorderRadius.circular(5),
//                                             border: Border.all(
//                                               width: 1,
//                                               color: Colors.white,
//                                             )),
//
//
//                                         child: const Icon(
//                                           Icons.filter_list_alt, size: 25,
//                                           color: Colors.white,),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,),
//
//
//
//                                   SizedBox(
//                                     child:
//                                     (categoryController.subCategoryList != null ) ? Center(child: SizedBox(
//                                         height: 40,
//
//                                         child:
//                                         ListView.builder(
//                                           scrollDirection: Axis.horizontal,
//                                           itemCount: categoryController.subCategoryList!.length,
//                                           padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
//                                           physics: BouncingScrollPhysics(),
//                                           itemBuilder: (context, index) {
//
//                                             return Padding(
//                                               padding: const EdgeInsets.only(right: 6,left: 6),
//                                               child: InkWell(
//                                                 onTap: (){
//                                                   _customMarkers=[];
//                                                   // _customMarkers.clear();
//
//                                                   //     categoryController.setFilterIndex(0,index,"0","0",0,"0");
//                                                   categoryController.setSubCategoryIndex(index,widget.mainCategory.id);
//
//                                                   setState(() {
//
//
//
//
//                                                     _setMarkers(products);
//
//
//
//
//                                                   });
//
//
//
//                                                 },
//                                                 child: Container(
//
//                                                   padding: EdgeInsets.only(
//                                                     left: index == 0 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
//                                                     right: index == categoryController.subCategoryList!.length-1 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
//                                                     //   top: Dimensions.PADDING_SIZE_SMALL,
//                                                   ),
//
//
//                                                   decoration:
//                                                   BoxDecoration(
//                                                     border: Border.all(
//                                                         color:index == categoryController.subCategoryIndex ? Theme.of(
//                                                             context)
//                                                             .primaryColor
//                                                             : Colors
//                                                             .black12,
//                                                         width: 2),
//                                                     borderRadius:
//                                                     BorderRadius
//                                                         .circular(
//                                                         8.0),
//                                                     color: Colors.white,
//                                                   ),
//
//
//                                                   child: Row(children: [
//                                                     Text(
//                                                      isArabic? categoryController.subCategoryList![index].nameAr ?? "":categoryController.subCategoryList![index].name ??"all",
//                                                       style: index == categoryController.subCategoryIndex
//                                                           ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)
//                                                           : robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
//                                                     ),
//
//                                                     SizedBox(width: 5),
//                                                     index==0?Container():  CustomImage(
//                                                         image:
//                                                         '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.subCategoryList![index].image}',
//                                                         height: 25,
//                                                         width: 25,
//                                                         colors:index ==
//                                                             categoryController.subCategoryIndex  ? Theme.of(
//                                                             context)
//                                                             .primaryColor
//                                                             : Colors
//                                                             .black12),
//
//                                                   ]),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         )  )) : SizedBox(),
//
//
//                                   ),
//
//
//
//
//
//
//
//                                 SizedBox(
//                                     height: 200,
//                                     child: Column(
//                                       children: [
//                                         Container(
//                                           height: 60,
//                                           width: 60,
//                                           padding: const EdgeInsets.all(10.0),
//                                           child:  FloatingActionButton(
//                                             mini: true, backgroundColor: Theme.of(context).cardColor,
//                                             onPressed: () => _checkPermission(() {
//                                               Get.find<LocationController>().getCurrentLocation(false, mapController: _controller, defaultLatLng: LatLng(0, 0));
//                                             }),
//                                             child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
//                                           ),
//                                         ),
//                                         Container(
//                                           height: 60,
//                                           width: 60,
//                                           padding: const EdgeInsets.all(10.0),
//                                           child: FloatingActionButton(
//                                             backgroundColor: Colors.white,
//                                             heroTag: 'recenterr',
//                                             onPressed:_onMapTypeButtonPressed,
//                                             shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(10.0),
//                                                 side: const BorderSide(color: Color(0xFFECEDF1))),
//                                             child:  Icon(
//                                               Icons.layers_outlined,
//                                               color: Theme.of(context).primaryColor,
//                                             ),
//                                           ),
//                                         ),
//                                         Container(
//                                           height: 60,
//                                           width: 60,
//                                           padding: const EdgeInsets.all(10.0),
//                                           child: FloatingActionButton(
//                                             backgroundColor: Colors.white,
//                                             heroTag: 'recenterr',
//                                             onPressed: () {
//
//                                             },
//                                             shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(10.0),
//                                                 side: const BorderSide(color: Color(0xFFECEDF1))),
//                                             child: const Icon(
//                                               Icons.my_location,
//                                               color: Colors.grey,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     )),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // Align(
//                     //           alignment: Alignment.bottomCenter,
//                     //           child:
//                     //           Container(height: 200,
//                     //             child:   nearbyPlacesList(_products))
//                     //         ),
//
//                     // pressedNear
//                     //     ? Positioned(
//                     //     bottom: 20.0,
//                     //     child: Container(
//                     //       // height: 300.0,
//                     //       width: MediaQuery.of(context).size.width,
//                     //       child:nearbyPlacesList(_products),
//                     //     ))
//                     //     : Container(),
//
//
//                     // Positioned(
//                     //   bottom: 5,
//                     //   right: 5,
//                     //   child: GestureDetector(
//                     //     onTap: () {
//                     //       if(cardTapped==true){
//                     //
//                     //         cardTapped=false;
//                     //       }else if(cardTapped==false){
//                     //         cardTapped=true;
//                     //       }
//                     //
//                     //       setState(() {
//                     //
//                     //       });
//                     //     },
//                     //     child: Container(
//                     //       decoration: BoxDecoration(
//                     //         color: Colors.grey.shade300,
//                     //         shape: BoxShape.circle,
//                     //       ),
//                     //       padding: const EdgeInsets.all(4),
//                     //       child: const Icon(
//                     //         Icons.close,
//                     //         size: 16,
//                     //         color: Colors.black,
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                     cardTapped
//                         ? Positioned(
//                         top: 100.0,
//                         left: 15.0,
//                         child: FlipCard(
//                           key: cardKey,
//                           front: Container(
//                             height: 180.0,
//                             width: 175.0,
//                             decoration: const BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius:
//                                 BorderRadius.all(Radius.circular(8.0))),
//                             child:SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   // 移除 Positioned，改用其他布局方式
//                                   Align(
//                                     alignment: Alignment.bottomRight,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         if(cardTapped == true) {
//                                           cardTapped = false;
//                                         } else if(cardTapped == false) {
//                                           cardTapped = true;
//                                         }
//                                         setState(() {});
//                                       },
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.red,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         padding: const EdgeInsets.all(4),
//                                         child: const Icon(
//                                           Icons.close,
//                                           size: 16,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 100.0,
//                                     width: 175.0,
//                                     decoration: const BoxDecoration(
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(8.0),
//                                           topRight: Radius.circular(8.0),
//                                         ),
//                                         image: DecorationImage(
//                                           image: AssetImage(Images.offer),
//                                           fit: BoxFit.cover,
//                                         )
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
//                                     width: 175.0,
//                                     child: Row(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           width: 150,
//                                           child: Text(
//                                             "this_offer_includes_offers_and_discounts".tr,
//                                             style: robotoBlack.copyWith(fontSize: 10),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           back: Container(
//                             // height: 300.0,
//                               width: 225.0,
//                               decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.95),
//                                   borderRadius: BorderRadius.circular(8.0)),
//                               child:Column(
//                                 children: [
//                                   estate == null
//                                       ? SizedBox() // أو أي Widget بديل
//                                       : ServiceProviderItem(estate: estate!),
//                                 ],
//                               )
//
//                           ),
//                           autoFlipDuration: const Duration(seconds: 1),
//
//
//                         ))
//                         : Container(),
//
//                     Align(
//                       alignment: Alignment.bottomCenter,
//                       child:
//                       !isNull ?products.isNotEmpty?            SizedBox(
//                         height: 200,
//                         child: GetBuilder<SplashController>(builder: (splashController) {
//                           for (int i = 0; i < products.length; i++) {
//                             Estate currentCoordinate = products[i];
//                             //print('Coordinate ${i+1}: (${currentCoordinate.id}, ${currentCoordinate.title})');
//                             selectedIndex = i;
//
//                           }
//                           return nearbyPlacesList(products);
//                         }),
//                       ):Text(""):Text(""),
//                     ),
//
//                   ]);
//                 }
//                 return
//                   Stack(children: [
//                     !isNull ?products.isNotEmpty?
//
//                     GoogleMap(
//                       initialCameraPosition:  CameraPosition(zoom: 12, target: LatLng(
//                         // double.parse(Get.find<LocationController>().getUserAddress().latitude),
//                         // double.parse(Get.find<LocationController>().getUserAddress().longitude),
//                         double.parse(widget.mainCategory.longitude),
//                         double.parse(widget.mainCategory.latitude),
//                       )),
//                       markers: markers,
//                       // myLocationEnabled: false,
//                       // compassEnabled: false,
//                       zoomControlsEnabled: false,
//                       mapType: _currentMapType,
//                       onTap: (point) {
//                         tappedPoint = point;
//                         _setCircle(point);
//                       },
//                       minMaxZoomPreference: MinMaxZoomPreference(0, 40),
//                       onMapCreated: (GoogleMapController controller) {
//                         _controller = controller;
//                         // if(_products.length > 0) {
//                           _setMarkers(products);
//                         // }
//
//                       },
//                     ):Center(
//                       child: NoDataScreen(
//                         text: 'no_data_available',
//                       ),
//                     ):  GoogleMap(
//                       initialCameraPosition:  CameraPosition(zoom: 12, target: LatLng(
//                         // double.parse(Get.find<LocationController>().getUserAddress().latitude),
//                         // double.parse(Get.find<LocationController>().getUserAddress().longitude),
//                         double.parse(widget.mainCategory.longitude),
//                         double.parse(widget.mainCategory.latitude),
//                       )),
//                       // markers: markers,
//                       // myLocationEnabled: false,
//                       // compassEnabled: false,
//                       zoomControlsEnabled: false,
//                       mapType: _currentMapType,
//                       onTap: (point) {
//                         tappedPoint = point;
//                         _setCircle(point);
//                       },
//                       minMaxZoomPreference: MinMaxZoomPreference(0, 40),
//                       onMapCreated: (GoogleMapController controller) {
//
//                         _controller = controller;
//
//                         // if(_products.length > 0) {
//                         //   _setMarkers(_products);
//                         // }
//
//                       },
//                     ),
//
//                     categoryController.isLoading ? Center(child: Padding(
//                       padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
//                       child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
//                     )) : SizedBox(),
//
//
//
//                     SafeArea(
//                       child: Align(
//                         alignment: Alignment.topCenter,
//                         child: Padding(
//                           padding: const EdgeInsets.only(top: 7.0),
//                           child: Container(
//                             margin: const EdgeInsets.only(left: 10.0, right: 7.0),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               crossAxisAlignment: CrossAxisAlignment.end,
//
//                               children: <Widget>[
//                                 Row(
//                                   children: [
//
//                                     InkWell(
//                                       onTap: () => Get.dialog(LocationSearchDialog(mapController: _controller)),
//                                       child: Container(
//                                         height: 43,
//                                         padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
//                                         decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
//                                         width: width-130,
//                                         child:  Row(children: [
//                                           Icon(Icons.location_on, size: 25, color: Theme.of(context).primaryColor),
//                                           SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
//                                           Container(
//                                             child: Expanded(
//                                               child: Text(
//                                                 locationController.pickAddress,
//                                                 style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
//                                           Icon(Icons.search, size: 25, color: Theme.of(context).textTheme.bodyLarge!.color),
//                                         ]),
//                                       ),
//                                     ),
//                                     Container(
//                                       margin: const EdgeInsets.only(
//                                           left: 4.0, right: 4.0),
//                                       padding: const EdgeInsets.all(7),
//                                       decoration: BoxDecoration(
//                                           color: Colors.white,
//                                           borderRadius: BorderRadius.circular(5),
//                                           border: Border.all(
//                                             width: 1,
//                                             color: Colors.blue,
//                                           )),
//
//
//                                       child: const Icon(Icons.qr_code, size: 25,
//                                         color: Colors.blue,),
//                                     ),
//                                     GestureDetector(
//                                       onTap: (){
//
//                                         Get.dialog(FiltersScreen());
//                                       },
//                                       child: Container(
//                                         padding: const EdgeInsets.all(7),
//                                         margin: const EdgeInsets.only(
//                                             left: 4.0, right: 4.0),
//                                         decoration: BoxDecoration(
//                                             color: Colors.blue,
//                                             borderRadius: BorderRadius.circular(5),
//                                             border: Border.all(
//                                               width: 1,
//                                               color: Colors.white,
//                                             )),
//
//
//                                         child: const Icon(
//                                           Icons.filter_list_alt, size: 25,
//                                           color: Colors.white,),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     // زر بيع
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           selectedOption = 'بيع';
//                                           Get.find<CategoryController>().setFilterIndex(
//                                             widget.mainCategory.id, 0, "0", "0", 0, 0, 0, selectedOption,
//                                           );
//                                         });
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: selectedOption == 'بيع' ? Colors.blue : Colors.white,
//                                         foregroundColor: selectedOption == 'بيع' ? Colors.white : Colors.black,
//                                         shape: RoundedRectangleBorder(
//                                           side: BorderSide(color: Colors.blue),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                       ),
//                                       child: Text('بيع'),
//                                     ),
//
//                                     SizedBox(width: 10),
//
//                                     // زر إيجار
//                                     ElevatedButton(
//                                       onPressed: () {
//                                         setState(() {
//                                           selectedOption = 'إيجار';
//                                           Get.find<CategoryController>().setFilterIndex(
//                                             widget.mainCategory.id, 0, "0", "0", 0, 0, 0, selectedOption,
//                                           );
//                                         });
//                                       },
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: selectedOption == 'إيجار' ? Colors.blue : Colors.white,
//                                         foregroundColor: selectedOption == 'إيجار' ? Colors.white : Colors.black,
//                                         shape: RoundedRectangleBorder(
//                                           side: BorderSide(color: Colors.blue),
//                                           borderRadius: BorderRadius.circular(8),
//                                         ),
//                                       ),
//                                       child: Text('إيجار'),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 5,),
//
//                                   SizedBox(
//                                     child:
//                                     (categoryController.subCategoryList != null ) ? Center(child: SizedBox(
//                                         height: 40,
//
//                                         child:
//                                         ListView.builder(
//                                           scrollDirection: Axis.horizontal,
//                                           itemCount: categoryController.subCategoryList!.length,
//                                           padding: EdgeInsets.only(left: Dimensions.PADDING_SIZE_SMALL),
//                                           physics: BouncingScrollPhysics(),
//                                           itemBuilder: (context, index) {
//
//                                             return Padding(
//                                               padding: const EdgeInsets.only(right: 6,left: 6),
//                                               child: InkWell(
//                                                 onTap: (){
//                                                   _customMarkers=[];
//                                                   // _customMarkers.clear();
//
//
//                                                   categoryController.setSubCategoryIndex(index,widget.mainCategory.id);
//                                                   //categoryController.setFilterIndex(0,index,"0","0",0,"0");
//                                                   setState(() {
//
//                                                     _setMarkers(products);
//
//                                                   });
//
//
//
//                                                 },
//                                                 child: Container(
//
//                                                   padding: EdgeInsets.only(
//                                                     left: index == 0 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
//                                                     right: index == categoryController.subCategoryList!.length-1 ? Dimensions.PADDING_SIZE_LARGE : Dimensions.PADDING_SIZE_SMALL,
//                                                     //   top: Dimensions.PADDING_SIZE_SMALL,
//                                                   ),
//
//
//                                                   decoration:
//                                                   BoxDecoration(
//                                                     border: Border.all(
//                                                         color:index == categoryController.subCategoryIndex ? Theme.of(
//                                                             context)
//                                                             .primaryColor
//                                                             : Colors
//                                                             .black12,
//                                                         width: 2),
//                                                     borderRadius:
//                                                     BorderRadius
//                                                         .circular(
//                                                         8.0),
//                                                     color: Colors.white,
//                                                   ),
//
//
//                                                   child: Row(children: [
//                                                     Text(
//                                                       isArabic? categoryController.subCategoryList![index].nameAr ?? "" : categoryController.subCategoryList![index].name??"all",
//                                                       style: index == categoryController.subCategoryIndex
//                                                           ? robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)
//                                                           : robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).disabledColor),
//                                                     ),
//
//                                                     SizedBox(width: 5),
//                                                     index==0?Container():  CustomImage(
//                                                         image:
//                                                         '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.subCategoryList![index].image}',
//                                                         height: 25,
//                                                         width: 25,
//                                                         colors:index ==
//                                                             categoryController.subCategoryIndex  ? Theme.of(
//                                                             context)
//                                                             .primaryColor
//                                                             : Colors
//                                                             .black12),
//
//                                                   ]),
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         )  )) : SizedBox(),
//
//
//                                   ),
//
//                                 SizedBox(
//                                     height: 200,
//                                     child: Column(
//                                       children: [
//                                         Container(
//                                           height: 60,
//                                           width: 60,
//                                           padding: const EdgeInsets.all(10.0),
//                                           child:  FloatingActionButton(
//                                             mini: true, backgroundColor: Theme.of(context).cardColor,
//                                             onPressed: () => _checkPermission(() {
//                                               Get.find<LocationController>().getCurrentLocation(false, mapController: _controller, defaultLatLng: LatLng(0, 0));
//                                             }),
//                                             child: Icon(Icons.my_location, color: Theme.of(context).primaryColor),
//                                           ),
//                                         ),
//                                         Container(
//                                           height: 60,
//                                           width: 60,
//                                           padding: const EdgeInsets.all(10.0),
//                                           child: FloatingActionButton(
//                                             backgroundColor: Colors.white,
//                                             heroTag: 'recenterr',
//                                             onPressed:_onMapTypeButtonPressed,
//                                             shape: RoundedRectangleBorder(
//                                                 borderRadius: BorderRadius.circular(10.0),
//                                                 side: const BorderSide(color: Color(0xFFECEDF1))),
//                                             child:  Icon(
//                                               Icons.layers_outlined,
//                                               color: Theme.of(context).primaryColor,
//                                             ),
//                                           ),
//                                         ),
//                                         // Container(
//                                         //   height: 60,
//                                         //   width: 60,
//                                         //   padding: const EdgeInsets.all(10.0),
//                                         //   child: FloatingActionButton(
//                                         //     backgroundColor: Colors.white,
//                                         //     heroTag: 'recenterr',
//                                         //     onPressed: () {
//                                         //
//                                         //     },
//                                         //     shape: RoundedRectangleBorder(
//                                         //         borderRadius: BorderRadius.circular(10.0),
//                                         //         side: const BorderSide(color: Color(0xFFECEDF1))),
//                                         //     child: const Icon(
//                                         //       Icons.my_location,
//                                         //       color: Colors.grey,
//                                         //     ),
//                                         //   ),
//                                         // ),
//                                       ],
//                                     )),
//
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//
//
//
//                     cardTapped
//                         ? Positioned(
//                         top: 100.0,
//                         left: 15.0,
//                         child: FlipCard(
//                           key: cardKey,
//                           front: Container(
//                             height: 180.0,
//                             width: 175.0,
//                             decoration: const BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius:
//                                 BorderRadius.all(Radius.circular(8.0))),
//                             child: SingleChildScrollView(
//                               child: Column(
//                                 children: [
//                                   // 移除 Positioned，改用其他布局方式
//                                   Align(
//                                     alignment: Alignment.bottomRight,
//                                     child: GestureDetector(
//                                       onTap: () {
//                                         if(cardTapped == true) {
//                                           cardTapped = false;
//                                         } else if(cardTapped == false) {
//                                           cardTapped = true;
//                                         }
//                                         setState(() {});
//                                       },
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: Colors.red,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         padding: const EdgeInsets.all(4),
//                                         child: const Icon(
//                                           Icons.close,
//                                           size: 16,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     height: 100.0,
//                                     width: 175.0,
//                                     decoration: const BoxDecoration(
//                                         borderRadius: BorderRadius.only(
//                                           topLeft: Radius.circular(8.0),
//                                           topRight: Radius.circular(8.0),
//                                         ),
//                                         image: DecorationImage(
//                                           image: AssetImage(Images.offer),
//                                           fit: BoxFit.cover,
//                                         )
//                                     ),
//                                   ),
//                                   Container(
//                                     padding: const EdgeInsets.fromLTRB(7.0, 0.0, 7.0, 0.0),
//                                     width: 175.0,
//                                     child: Row(
//                                       crossAxisAlignment: CrossAxisAlignment.center,
//                                       children: [
//                                         SizedBox(
//                                           width: 150,
//                                           child: Text(
//                                             "this_offer_includes_offers_and_discounts".tr,
//                                             style: robotoBlack.copyWith(fontSize: 10),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                           back: Container(
//                             // height: 300.0,
//                               width: 225.0,
//                               decoration: BoxDecoration(
//                                   color: Colors.white.withOpacity(0.95),
//                                   borderRadius: BorderRadius.circular(8.0)),
//                               child:Column(
//                                 children: [
//                                   estate == null
//                                       ? SizedBox() // أو أي Widget بديل
//                                       : ServiceProviderItem(estate: estate!),
//                                 ],
//                               )
//
//                           ),
//                           autoFlipDuration: const Duration(seconds: 1),
//
//
//                         ))
//                         : Container(),
//
//                     !isNull ?products.isNotEmpty?        Align(
//                       alignment: Alignment.bottomCenter,
//                       child:
//                       SizedBox(
//                         height: 200,
//                         child: GetBuilder<SplashController>(builder: (splashController) {
//                           for (int i = 0; i < products.length; i++) {
//                             Estate currentCoordinate = products[i];
//                             //print('Coordinate ${i+1}: (${currentCoordinate.id}, ${currentCoordinate.title})');
//                             selectedIndex = i;
//
//                           }
//                           return nearbyPlacesList(products);
//
//                         }),
//                       ),
//                     ):Text(""):Text(""),
//
//                   ]);
//
//               },
//             );
//
//
//
//           });
//         })
//     );
//   }
//   void _checkPermission(Function onTap) async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if(permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }
//     if(permission == LocationPermission.denied) {
//       showCustomSnackBar('you_have_to_allow'.tr);
//     }else if(permission == LocationPermission.deniedForever) {
//       Get.dialog(PermissionDialog());
//     }else {
//       onTap();
//     }
//   }
//
//   void _setMarkers(List<Estate> estate) async {
//     List<LatLng> latLngs = [];
//     _customMarkers=[];
//     _customMarkers.clear();
//
//
//
//     _customMarkers.add(MarkerData(
//       marker: const Marker(markerId: MarkerId('id-0'), position: LatLng(
//         // double.parse(Get.find<LocationController>().getUserAddress().latitude),
//         // double.parse(Get.find<LocationController>().getUserAddress().longitude),
//           26.451363,
//           50.109046
//       )),
//       child: Image.asset(Images.estate_default, height: 32, width: 20),
//     ));
//     for (int i = 0; i < estate.length; i++) {
//       Estate currentCoordinate = estate[i];
//       LatLng latLng = LatLng(double.parse(currentCoordinate.latitude!), double.parse(currentCoordinate.longitude!));
//       latLngs.add(latLng);
//
//
//       _customMarkers.add(MarkerData(
//
//           marker: Marker(
//               infoWindow: InfoWindow( //popup info
//                 title: estate[i].title,
//                 snippet: ' المساحة ${estate[i].space}',
//               ),
//
//
//               markerId: MarkerId('id-$i'), position: latLng, onTap: () {
//             selectedIndex = i;
//             // pressedNear=true;
//
//
//
//             // _pageController.animateToPage(i, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut,);
//             //print("-----------------------------------------omeromer----");
//
//             _pageController.animateToPage(selectedIndex, duration: const Duration(milliseconds: 800), curve: Curves.easeInOut,);
//
//
//
//           }),
//           child: Column(
//             children: [
//               GestureDetector(
//                 onTap: (){
//
//                 },
//                 child:  Container(
//
//
//                   padding:   const EdgeInsets.only(right: 1,left: 1),
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                         color: Theme.of(context).secondaryHeaderColor
//                     ),
//                     borderRadius: BorderRadius.circular(2.0),
//                     color: Colors.white,
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         formatPrice(
//                             currentCoordinate.categoryName == "ارض"
//                                 ? currentCoordinate.totalPrice!
//                                 : currentCoordinate.price!
//                         ),
//                         style: robotoBlack.copyWith(fontSize: 9),
//                       ),
//
//
//                       Image.asset(currentCoordinate.serviceOffers!.isEmpty?Images.image:Images.vt_offer, height: 8, width: 8),
//                     ],
//
//                   ),
//                 ),
//               ),
//
//               selectedIndex==i?         Stack(
//                 children: [
//                   Image.asset(Images.location_marker, height: 40, width: 40,color:currentCoordinate.serviceOffers!.isEmpty?Colors.red:Colors.orange),
//                   Positioned(top: 3, left: 0, right: 0, child: Center(
//                     child: ClipOval(child: CustomImage(image:currentCoordinate.images!.isNotEmpty?"${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${currentCoordinate.images![0]}":Images.estate_type, placeholder: Images.placeholder, height: 20, width: 20, fit: BoxFit.cover)),
//                   )),
//                 ],
//               ): Stack(
//                 children: [
//                   Image.asset(Images.location_marker, height: 35, width: 35,color:currentCoordinate.serviceOffers!.isEmpty?Theme.of(context).primaryColor:Colors.orange),
//                   Positioned(top: 3, left: 0, right: 0, child: Center(
//                     child: ClipOval(child: CustomImage(  image:currentCoordinate.images!.isNotEmpty?"${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${currentCoordinate.images![0]}":Images.estate_type, placeholder: Images.placeholder, height: 18, width: 18, fit: BoxFit.cover)),
//                   )),
//                 ],
//               ),
//             ],
//           )
//
//
//       ));
//
//
//
//
//     }
//
//
//
//     await Future.delayed(const Duration(milliseconds: 500));
//     if (_reload == 0) {
//       setState(() {});
//       _reload = 1;
//     }
//
//     // await Future.delayed(const Duration(seconds: 3));
//     // if (_reload == 1) {
//     //   setState(() {});
//     //   _reload = 2;
//     // }
//   }
//
//
//
//
//
//   Future<Position> getUserCurrentLocation() async {
//     await Geolocator.requestPermission().then((value) {
//       //print(value);
//     }).onError((error, stackTrace) async {
//       await Geolocator.requestPermission();
//       //print("ERROR$error");
//     });
//     return await Geolocator.getCurrentPosition();
//   }
//   nearbyPlacesList(List<Estate> products) {
//
//     return  PageView.builder(
//
//         controller: _pageController,
//         itemCount: products.length,
//         onPageChanged:(int value) {
//           _setMarkers(products);
//           selectedIndex = value;
//           _controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
//               target: LatLng(
//                   double.parse( products[selectedIndex].latitude!)??0  ,
//                   double.parse( products[selectedIndex].longitude!)??0),
//               zoom: 25.0,
//               bearing: 45.0,
//               tilt: 45.0)));
//
//
//
//           if(products[selectedIndex].serviceOffers!.isNotEmpty){
//            estate= products[selectedIndex];
//           // _createTutorial();
//             cardTapped=true;
//             setState(() {
//
//             });
//           }else{
//             cardTapped=false ;
//             setState(() {
//
//             });
//           }
//
//
//         },
//         itemBuilder: (BuildContext context, int index) {
//
//           return AnimatedBuilder(
//             animation: _pageController,
//
//             builder: (BuildContext? context, Widget? widget) {
//
//               double value = 1;
//               if (_pageController.position.haveDimensions) {
//                 value = (_pageController.page! - index);
//                 value = (1 - (value.abs() * 0.3) + 0.06).clamp(0.0, 1.0);
//
//               }
//
//
//
//               Timer(Duration(seconds: 4), () {
//
//                // cardKey.currentState.toggleCard();
//              //  cardTapped=false ;
//               });
//
//
//
//
//               return Center(
//                 child: SizedBox(
//                   // height: Curves.easeInOut.transform(value) * 125.0,
//                   // width: Curves.easeInOut.transform(value) * 100.0,
//                   child: widget,
//                 ),
//               );
//             },
//             child: InkWell(
//               onTap: () async {
//
//
// if(cardTapped==true){
//
//   cardTapped=false;
// }else if(cardTapped==false){
//   cardTapped=true;
// }
//
//                 setState(() {
//
//                 });
//
//
//
//
//               },
//               child:      Column(
//                 children: [
//                   SizedBox(
//
//                     width: context.width,
//                     child: products[index].serviceOffers!.isNotEmpty? SizedBox(
//                       height: 35,
//
//                       child: Container(
//
//                         padding: const EdgeInsets.all(3),
//                         decoration: BoxDecoration(
//                           border: Border.all(width: 2, color: Colors.orangeAccent),
//                           color: Colors.white,
//                         ),
//                         child: GestureDetector(
//                           onTap: () async {
//
//                           },
//
//                           child: Row(
//
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Row(
//                                 children: [
//                                   Image.asset(Images.offer_icon, height: 35, width: 40),
//                                   Text(
//                                       "offer_included".tr,style: robotoBlack.copyWith(fontSize: 11)),
//                                 ],
//                               ),
//                               Center(
//                                 child:      SizedBox(
//
//                                   child: Row(
//                                     children: [
//                                       for (var i = 0; i < 1; i++)
//
//                                         Container(
//                                           decoration: BoxDecoration(
//                                             border: Border.all(width: 1, color: Theme.of(context).primaryColor),
//                                             shape: BoxShape.circle,
//                                           ),
//                                           alignment: Alignment.topRight,
//                                           child: ClipOval(child: CustomImage(
//
//                                             image: '${Get.find<SplashController>().configModel!.baseUrls!.provider}'
//                                                 '/${(products[index].serviceOffers![i].image!=null)? products[index].serviceOffers![i].image:Images.image}',
//                                             height: 27, width: 27, fit: BoxFit.cover,
//                                           )),
//                                         ),
//                                       Container(
//                                         decoration: BoxDecoration(
//                                           border: Border.all(width: 1, color: Theme.of(context).primaryColor),
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: Center(child: Padding(
//                                           padding: const EdgeInsets.all(3.0),
//                                           child: (Text("${ products[index].serviceOffers!.length}+")),
//                                         ),),)
//
//
//
//
//                                     ],
//                                   ),
//                                 ),
//                               ),
//
//                             ],
//                           ),
//                         ),
//                       ),
//                     ):SizedBox(
//                       height: 20,
//                     ),
//                   ),
//                   Center(
//                     child:   EstateItem(estate: products[index],onPressed: (){
//                       Get.find<UserController>().getUserInfoByID( products[index].userId! );
//                       Get.find<UserController>().getEstateByUser(1, false,products[index].userId! );
//                       Get.dialog(DettailsDilog(estate:products[index]));
//                       // Get.toNamed(RouteHelper.getDetailsRoute( _products[index].id,_products[index].userId));
//                     },fav: false,isMyProfile: 0),
//                   ),
//                 ],
//               ),
//             ),
//           );
//
//         });
//   }
//
//
//
//   String formatPrice(String priceStr) {
//     final num? price = num.tryParse(priceStr);
//
//     if (price! >= 1000000) {
//       return "${(price / 1000000).toStringAsFixed(2)} مليون";
//     } else if (price >= 1000) {
//       return "${(price / 1000).toStringAsFixed(2)} ألف";
//     } else {
//       return price.toString();
//     }
//   }
//
//
//
//
// }
//
//
// class SliverDelegate extends SliverPersistentHeaderDelegate {
//   Widget child;
//
//   SliverDelegate({required this.child});
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
//     return oldDelegate.maxExtent != 50 || oldDelegate.minExtent != 50 || child != oldDelegate.child;
//   }
//
//
// }



import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:abaad_flutter/controller/category_controller.dart';
import 'package:abaad_flutter/controller/localization_controller.dart';
import 'package:abaad_flutter/controller/location_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/data/model/response/zone_model.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/details_dilog.dart';
import 'package:abaad_flutter/view/base/drawer_menu.dart';
import 'package:abaad_flutter/view/base/estate_item.dart';
import 'package:abaad_flutter/view/base/no_data_screen.dart';
import 'package:abaad_flutter/view/screen/fillter/fillter_estate_sheet.dart';
import 'package:abaad_flutter/view/base/web_menu_bar.dart';
import 'package:custom_map_markers/custom_map_markers.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widget/location_search_dialog.dart';
import 'widget/permission_dialog.dart';
import 'widget/service_provider.dart';

class MapScreen extends StatefulWidget {
  ZoneModel mainCategory;
  final bool fromSignUp;
  final bool fromAddAddress;
  final bool canRoute;
  final String route;
  final GoogleMapController? googleMapController;

  MapScreen({
    Key? key,
    required this.mainCategory,
    required this.fromSignUp,
    required this.fromAddAddress,
    required this.canRoute,
    required this.route,
    this.googleMapController,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapScreen> {
  late GoogleMapController _controller;
  List<MarkerData> _customMarkers = [];
  late CameraPosition _cameraPosition;
  late Uint8List imageDataBytes;
  var markerIcon;
  String selectedOption = 'all';

  final Set<Polygon> _polygon = HashSet<Polygon>();
  final Set<Circle> _circles = <Circle>{};

  bool cardTapped = false;
  bool card = false;
  bool searchToggle = false;
  bool radiusSlider = false;
  bool backProider = false;

  late LatLng _initialPosition;
  var photoGalleryIndex = 0;
  final bool _ltr = Get.find<LocalizationController>().isLtr;
  MapType _currentMapType = MapType.satellite;

  var tappedPoint;
  Estate? estate;

  bool _didInitialLoad = false;

  late PageController _pageController;
  int prevPage = 0;
  bool showBlankCard = false;
  bool pressedNear = false;

  var radiusValue = 3000.0;
  String tokenKey = '';
  late int index;
  int selectedIndex = 0;

  final GlobalKey<ScaffoldState> _key = GlobalKey();
  final cardKey = GlobalKey<FlipCardState>();




  bool _mapReady = false;
  bool _isFetchingBounds = false;

  String _lastBoundsKey = '';
  int _lastMarkersHash = -1;
  late double lat;
  late double lot;

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType =
      _currentMapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  void _onScroll() {
    if (_pageController.hasClients && _pageController.page != null) {
      if (_pageController.page!.toInt() != prevPage) {
        prevPage = _pageController.page!.toInt();
        cardTapped = false;
        photoGalleryIndex = 1;
        showBlankCard = false;
        card = false;
      }
    }
  }

  Future<void> _loadInitialEstatesFromPoint() async {
    final categoryController = Get.find<CategoryController>();

    // مساحة أكبر حول الزون
    const double latDelta = 0.50;
    const double lngDelta = 0.50;

    final double northEastLat = lat + latDelta;
    final double northEastLng = lot + lngDelta;
    final double southWestLat = lat - latDelta;
    final double southWestLng = lot - lngDelta;

    await categoryController.getMapCategoryProductListByBounds(
      widget.mainCategory.id,
      categoryController.subCategoryList != null &&
          categoryController.subCategoryList!.isNotEmpty
          ? categoryController
          .subCategoryList![categoryController.subCategoryIndex].id
          .toString()
          : "0",
      0,
      "0",
      "0",
      "0",
      "0",
      northEastLat,
      northEastLng,
      southWestLat,
      southWestLng,
      reload: true,
      arPath: 0,
      sv: 0,
      type: selectedOption,
    );
  }
  // Future<void> _loadInitialEstatesFromPoint() async {
  //   final categoryController = Get.find<CategoryController>();
  //
  //   // مربع صغير حول إحداثيات المنطقة
  //   const double latDelta = 0.08;
  //   const double lngDelta = 0.08;
  //
  //   final double northEastLat = lat + latDelta;
  //   final double northEastLng = lot + lngDelta;
  //   final double southWestLat = lat - latDelta;
  //   final double southWestLng = lot - lngDelta;
  //
  //   await categoryController.getMapCategoryProductListByBounds(
  //     widget.mainCategory.id,
  //     categoryController.subCategoryList != null &&
  //         categoryController.subCategoryList!.isNotEmpty
  //         ? categoryController
  //         .subCategoryList![categoryController.subCategoryIndex].id
  //         .toString()
  //         : "0",
  //     0,
  //     "0",
  //     "0",
  //     "0",
  //     "0",
  //     northEastLat,
  //     northEastLng,
  //     southWestLat,
  //     southWestLng,
  //     reload: true,
  //     arPath: 0,
  //     sv: 0,
  //     type: selectedOption,
  //   );
  // }


  Future<void> _moveToZoneAndLoadFirstTime() async {
    await _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(lat, lot),
          zoom: 9,
        ),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 700));

    _cameraPosition = CameraPosition(
      target: LatLng(lat, lot),
      zoom: 9,
    );

    await _loadInitialEstatesFromPoint();
    _didInitialLoad = true;
  }

  void _setCircle(LatLng point) async {
    _controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: point, zoom: 12),
      ),
    );
    setState(() {
      _circles.clear();
      _circles.add(
        Circle(
          circleId: const CircleId('raj'),
          center: point,
          fillColor: Colors.blue.withOpacity(0.1),
          radius: radiusValue,
          strokeColor: Colors.blue,
          strokeWidth: 1,
        ),
      );
      searchToggle = false;
      radiusSlider = true;
    });
  }

  @override
  void initState() {
    super.initState();
    // lat=widget.mainCategory.latitude as double;
    // lot=widget.mainCategory.longitude as double;

    _pageController = PageController(initialPage: 1, viewportFraction: 0.85)
      ..addListener(_onScroll);
    lat = double.parse(widget.mainCategory.latitude);
    lot = double.parse(widget.mainCategory.longitude);

    print("lat=======$lat---$lot");




    _initialPosition = LatLng(
      lot,
      lat,
    );

    _cameraPosition = CameraPosition(
      target: _initialPosition,
      zoom: 13,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller.dispose();
    super.dispose();
  }

  BorderRadius get borderRadius => BorderRadius.circular(8.0);

  Future<void> getCustomMarkerIcon(GlobalKey iconKey) async {
    return;
  }

  String _makeBoundsKey(LatLngBounds b) {
    return '${b.northeast.latitude.toStringAsFixed(4)}_${b.northeast.longitude.toStringAsFixed(4)}_${b.southwest.latitude.toStringAsFixed(4)}_${b.southwest.longitude.toStringAsFixed(4)}';
  }

  Future<void> _loadMapEstatesByBounds({bool reload = true}) async {
    if (!_mapReady || _isFetchingBounds) return;

    _isFetchingBounds = true;
    try {
      final bounds = await _controller.getVisibleRegion();
      final boundsKey = _makeBoundsKey(bounds);

      if (!reload && boundsKey == _lastBoundsKey) {
        return;
      }


      _lastBoundsKey = boundsKey;

      final categoryController = Get.find<CategoryController>();

      await categoryController.getMapCategoryProductListByBounds(
        widget.mainCategory.id,
        categoryController.subCategoryList != null &&
            categoryController.subCategoryList!.isNotEmpty
            ? categoryController
            .subCategoryList![categoryController.subCategoryIndex].id
            .toString()
            : "0",
        0,
        "0",
        "0",
        "0",
        "0",
        bounds.northeast.latitude,
        bounds.northeast.longitude,
        bounds.southwest.latitude,
        bounds.southwest.longitude,
        reload: reload,
        arPath: 0,
        sv: 0,
        type: selectedOption,
      );
    } finally {
      _isFetchingBounds = false;
    }
  }


  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';
    var width = MediaQuery.of(context).size.width;



    return Scaffold(
      key: _key,
      appBar: WebMenuBar(
        ontop: () => _key.currentState!.openDrawer(),
        fromPage: "main",
      ),
      drawer: DrawerMenu(),
      body: GetBuilder<CategoryController>(
        builder: (categoryController) {
          return GetBuilder<LocationController>(
            builder: (locationController) {
              List<Estate> products = [];
              if (!categoryController.isSearching) {
                if (categoryController.mapEstateList != null) {
                  products.addAll(categoryController.mapEstateList!);
                }
              }

              final currentHash = products.length;
              if (_lastMarkersHash != currentHash) {
                _lastMarkersHash = currentHash;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _setMarkers(products);
                  }
                });
              }

              return CustomGoogleMapMarkerBuilder(
                customMarkers: _customMarkers,
                builder: (context, markers) {
                  final googleMap = GoogleMap(
                    initialCameraPosition: CameraPosition(
                      zoom: 13,
                      target: LatLng(lat, lot),
                    ),
                    markers: markers ?? {},
                    zoomControlsEnabled: false,
                    mapType: _currentMapType,
                    onTap: (point) {
                      tappedPoint = point;
                      _setCircle(point);
                    },
                    onCameraMove: (position) {
                      _cameraPosition = position;
                    },
                    onCameraIdle: () async {
                      if (_mapReady && _didInitialLoad) {
                        await _loadMapEstatesByBounds(reload: true);
                      }
                    },
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 40),
                    circles: _circles,
                    polygons: _polygon,
                    onMapCreated: (GoogleMapController controller) async {
                      _controller = controller;
                      _mapReady = true;
                      await _moveToZoneAndLoadFirstTime();
                    },
                  );

                  return Stack(
                    children: [
                      googleMap,

                      categoryController.isMapLoading
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

                      // if (!categoryController.isMapLoading &&
                      //     products.isEmpty)
                      //   const Center(
                      //     child: NoDataScreen(
                      //       text: 'no_data_available',
                      //     ),
                      //   ),

                      SafeArea(
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7.0),
                            child: Container(
                              margin: const EdgeInsets.only(
                                left: 10.0,
                                right: 7.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          if (_mapReady) {
                                            Get.dialog(
                                              LocationSearchDialog(
                                                mapController: _controller,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          height: 43,
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                            Dimensions.PADDING_SIZE_SMALL,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius:
                                            BorderRadius.circular(
                                              Dimensions.RADIUS_SMALL,
                                            ),
                                          ),
                                          width: width - 130,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                size: 25,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              SizedBox(
                                                width: Dimensions
                                                    .PADDING_SIZE_EXTRA_SMALL,
                                              ),
                                              Expanded(
                                                child: Text(
                                                  locationController.pickAddress,
                                                  style:
                                                  robotoRegular.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeLarge,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                ),
                                              ),
                                              SizedBox(
                                                width: Dimensions
                                                    .PADDING_SIZE_SMALL,
                                              ),
                                              Icon(
                                                Icons.search,
                                                size: 25,
                                                color: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge!
                                                    .color,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: const EdgeInsets.only(
                                            left: 4.0, right: 4.0),
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          border: Border.all(
                                            width: 1,
                                            color: Colors.blue,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.qr_code,
                                          size: 25,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          cardTapped = true;
                                          Get.dialog(FiltersScreen());
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(7),
                                          margin: const EdgeInsets.only(
                                              left: 4.0, right: 4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            border: Border.all(
                                              width: 1,
                                              color: Colors.white,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.filter_list_alt,
                                            size: 25,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),

                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            selectedOption = 'بيع';
                                          });
                                          await _loadMapEstatesByBounds(
                                            reload: true,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          selectedOption == 'بيع'
                                              ? Colors.blue
                                              : Colors.white,
                                          foregroundColor:
                                          selectedOption == 'بيع'
                                              ? Colors.white
                                              : Colors.black,
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                color: Colors.blue),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('بيع'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            selectedOption = 'إيجار';
                                          });
                                          await _loadMapEstatesByBounds(
                                            reload: true,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          selectedOption == 'إيجار'
                                              ? Colors.blue
                                              : Colors.white,
                                          foregroundColor:
                                          selectedOption == 'إيجار'
                                              ? Colors.white
                                              : Colors.black,
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                color: Colors.blue),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('إيجار'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            selectedOption = 'all';
                                          });
                                          await _loadMapEstatesByBounds(
                                            reload: true,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          selectedOption == 'all'
                                              ? Colors.blue
                                              : Colors.white,
                                          foregroundColor:
                                          selectedOption == 'all'
                                              ? Colors.white
                                              : Colors.black,
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(
                                                color: Colors.blue),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('الكل'),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 5),

                                  SizedBox(
                                    child: categoryController.subCategoryList !=
                                        null
                                        ? Center(
                                      child: SizedBox(
                                        height: 40,
                                        child: ListView.builder(
                                          scrollDirection:
                                          Axis.horizontal,
                                          itemCount: categoryController
                                              .subCategoryList!.length,
                                          padding: EdgeInsets.only(
                                            left: Dimensions
                                                .PADDING_SIZE_SMALL,
                                          ),
                                          physics:
                                          const BouncingScrollPhysics(),
                                          itemBuilder:
                                              (context, index) {
                                            return Padding(
                                              padding:
                                              const EdgeInsets.only(
                                                right: 6,
                                                left: 6,
                                              ),
                                              child: InkWell(
                                                onTap: () async {
                                                  categoryController
                                                      .setSubCategoryIndex(
                                                    index,
                                                    widget.mainCategory.id,
                                                  );
                                                  await _loadMapEstatesByBounds(
                                                    reload: true,
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                  EdgeInsets.only(
                                                    left: index == 0
                                                        ? Dimensions
                                                        .PADDING_SIZE_LARGE
                                                        : Dimensions
                                                        .PADDING_SIZE_SMALL,
                                                    right: index ==
                                                        categoryController
                                                            .subCategoryList!
                                                            .length -
                                                            1
                                                        ? Dimensions
                                                        .PADDING_SIZE_LARGE
                                                        : Dimensions
                                                        .PADDING_SIZE_SMALL,
                                                  ),
                                                  decoration:
                                                  BoxDecoration(
                                                    border: Border.all(
                                                      color: index ==
                                                          categoryController
                                                              .subCategoryIndex
                                                          ? Theme.of(
                                                          context)
                                                          .primaryColor
                                                          : Colors
                                                          .black12,
                                                      width: 2,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        8.0),
                                                    color: Colors.white,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Text(
                                                        isArabic
                                                            ? categoryController
                                                            .subCategoryList![
                                                        index]
                                                            .nameAr ??
                                                            ""
                                                            : categoryController
                                                            .subCategoryList![
                                                        index]
                                                            .name ??
                                                            "all",
                                                        style: index ==
                                                            categoryController
                                                                .subCategoryIndex
                                                            ? robotoMedium
                                                            .copyWith(
                                                          fontSize:
                                                          Dimensions.fontSizeDefault,
                                                          color: Theme.of(context)
                                                              .primaryColor,
                                                        )
                                                            : robotoRegular
                                                            .copyWith(
                                                          fontSize:
                                                          Dimensions.fontSizeDefault,
                                                          color: Theme.of(context)
                                                              .disabledColor,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 5),
                                                      index == 0
                                                          ? Container()
                                                          : CustomImage(
                                                        image:
                                                        '${Get.find<SplashController>().configModel!.baseUrls!.categoryImageUrl}/${categoryController.subCategoryList![index].image}',
                                                        height: 25,
                                                        width: 25,
                                                        colors: index ==
                                                            categoryController.subCategoryIndex
                                                            ? Theme.of(context)
                                                            .primaryColor
                                                            : Colors
                                                            .black12,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                        : const SizedBox(),
                                  ),

                                  SizedBox(
                                    height: 200,
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 60,
                                          width: 60,
                                          padding:
                                          const EdgeInsets.all(10.0),
                                          child: FloatingActionButton(
                                            mini: true,
                                            backgroundColor:
                                            Theme.of(context).cardColor,
                                            onPressed: () => _checkPermission(
                                                  () {
                                                Get.find<LocationController>()
                                                    .getCurrentLocation(
                                                  false,
                                                  mapController: _controller,
                                                  defaultLatLng:
                                                  const LatLng(0, 0),
                                                );
                                              },
                                            ),
                                            child: Icon(
                                              Icons.my_location,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          height: 60,
                                          width: 60,
                                          padding:
                                          const EdgeInsets.all(10.0),
                                          child: FloatingActionButton(
                                            backgroundColor: Colors.white,
                                            heroTag: 'recenterr',
                                            onPressed: _onMapTypeButtonPressed,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                              side: const BorderSide(
                                                color: Color(0xFFECEDF1),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.layers_outlined,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // cardTapped
                      //     ? Positioned(
                      //   top: 100.0,
                      //   left: 15.0,
                      //   child: FlipCard(
                      //     key: cardKey,
                      //     front: Container(
                      //       height: 180.0,
                      //       width: 175.0,
                      //       decoration: const BoxDecoration(
                      //         color: Colors.white,
                      //         borderRadius: BorderRadius.all(
                      //           Radius.circular(8.0),
                      //         ),
                      //       ),
                      //       child: SingleChildScrollView(
                      //         child: Column(
                      //           children: [
                      //             Align(
                      //               alignment: Alignment.bottomRight,
                      //               child: GestureDetector(
                      //                 onTap: () {
                      //                   setState(() {
                      //                     cardTapped = !cardTapped;
                      //                   });
                      //                 },
                      //                 child: Container(
                      //                   decoration:
                      //                   const BoxDecoration(
                      //                     color: Colors.red,
                      //                     shape: BoxShape.circle,
                      //                   ),
                      //                   padding:
                      //                   const EdgeInsets.all(4),
                      //                   child: const Icon(
                      //                     Icons.close,
                      //                     size: 16,
                      //                     color: Colors.white,
                      //                   ),
                      //                 ),
                      //               ),
                      //             ),
                      //             Container(
                      //               height: 100.0,
                      //               width: 175.0,
                      //               decoration: const BoxDecoration(
                      //                 borderRadius: BorderRadius.only(
                      //                   topLeft: Radius.circular(8.0),
                      //                   topRight: Radius.circular(8.0),
                      //                 ),
                      //                 image: DecorationImage(
                      //                   image:
                      //                   AssetImage(Images.offer),
                      //                   fit: BoxFit.cover,
                      //                 ),
                      //               ),
                      //             ),
                      //             Container(
                      //               padding:
                      //               const EdgeInsets.fromLTRB(
                      //                 7.0,
                      //                 0.0,
                      //                 7.0,
                      //                 0.0,
                      //               ),
                      //               width: 175.0,
                      //               child: Row(
                      //                 crossAxisAlignment:
                      //                 CrossAxisAlignment.center,
                      //                 children: [
                      //                   SizedBox(
                      //                     width: 150,
                      //                     child: Text(
                      //                       "this_offer_includes_offers_and_discounts"
                      //                           .tr,
                      //                       style: robotoBlack.copyWith(
                      //                         fontSize: 10,
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ],
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //     back: Container(
                      //       width: 225.0,
                      //       decoration: BoxDecoration(
                      //         color: Colors.white.withOpacity(0.95),
                      //         borderRadius:
                      //         BorderRadius.circular(8.0),
                      //       ),
                      //       child: Column(
                      //         children: [
                      //           estate == null
                      //               ? const SizedBox()
                      //               : ServiceProviderItem(
                      //             estate: estate!,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //     autoFlipDuration:
                      //     const Duration(seconds: 1),
                      //   ),
                      // )
                      //     : Container(),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: products.isNotEmpty
                            ? SizedBox(
                          height: 200,
                          child: nearbyPlacesList(products),
                        )
                            : const Text(""),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _checkPermission(Function onTap) async {
    onTap();
  }

  void _setMarkers(List<Estate> estate) {
    _customMarkers = [];
    _customMarkers.clear();

    for (int i = 0; i < estate.length; i++) {
      Estate currentCoordinate = estate[i];

      if (currentCoordinate.latitude == null ||
          currentCoordinate.longitude == null ||
          currentCoordinate.latitude!.isEmpty ||
          currentCoordinate.longitude!.isEmpty) {
        continue;
      }

      LatLng latLng = LatLng(
        double.parse(currentCoordinate.latitude!),
        double.parse(currentCoordinate.longitude!),
      );

      _customMarkers.add(
        MarkerData(
          marker: Marker(
            infoWindow: InfoWindow(
              title: estate[i].title,
              snippet: ' المساحة ${estate[i].space}',
            ),
            markerId: MarkerId('id-$i'),
            position: latLng,
            onTap: () {
              selectedIndex = i;
              _pageController.animateToPage(
                selectedIndex,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
              );
            },
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 1, left: 1),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                  borderRadius: BorderRadius.circular(2.0),
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatPrice(
                        currentCoordinate.categoryName == "ارض"
                            ? currentCoordinate.totalPrice!
                            : currentCoordinate.price!,
                      ),
                      style: robotoBlack.copyWith(fontSize: 9),
                    ),
                    Image.asset(
                      currentCoordinate.serviceOffers!.isEmpty
                          ? Images.image
                          : Images.vt_offer,
                      height: 8,
                      width: 8,
                    ),
                  ],
                ),
              ),
              selectedIndex == i
                  ? Stack(
                children: [
                  Image.asset(
                    Images.location_marker,
                    height: 40,
                    width: 40,
                    color: currentCoordinate.serviceOffers!.isEmpty
                        ? Colors.red
                        : Colors.orange,
                  ),
                  Positioned(
                    top: 3,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ClipOval(
                        child: CustomImage(
                          image: currentCoordinate.images!.isNotEmpty
                              ? "${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${currentCoordinate.images![0]}"
                              : Images.estate_type,
                          placeholder: Images.placeholder,
                          height: 20,
                          width: 20,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Stack(
                children: [
                  Image.asset(
                    Images.location_marker,
                    height: 35,
                    width: 35,
                    color: currentCoordinate.serviceOffers!.isEmpty
                        ? Theme.of(context).primaryColor
                        : Colors.orange,
                  ),
                  Positioned(
                    top: 3,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: ClipOval(
                        child: CustomImage(
                          image: currentCoordinate.images!.isNotEmpty
                              ? "${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${currentCoordinate.images![0]}"
                              : Images.estate_type,
                          placeholder: Images.placeholder,
                          height: 18,
                          width: 18,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool _isDiscountOffer(ServiceOffers offer) {
    return (offer.discount ?? '').isNotEmpty && offer.discount != '0';
  }

  String _offerMainValue(ServiceOffers offer) {
    if (_isDiscountOffer(offer)) {
      return '${offer.discount}% خصم';
    }

    if ((offer.servicePrice ?? '').isNotEmpty && offer.servicePrice != '0') {
      return '${offer.servicePrice} ر.س';
    }

    return 'عرض خاص';
  }

  Widget _offerInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.grey.shade700,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: 11,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }

  Widget nearbyPlacesList(List<Estate> products) {
    return PageView.builder(
      controller: _pageController,
      itemCount: products.length,
      onPageChanged: (int value) {
        selectedIndex = value;
        // _controller.animateCamera(
        //   CameraUpdate.newCameraPosition(
        //     CameraPosition(
        //       target: LatLng(
        //         double.parse(products[selectedIndex].latitude!),
        //         double.parse(products[selectedIndex].longitude!),
        //       ),
        //       zoom: 25.0,
        //       bearing: 45.0,
        //       tilt: 45.0,
        //     ),
        //   ),
        // );

        // if (products[selectedIndex].serviceOffers!.isNotEmpty) {
        //   estate = products[selectedIndex];
        //   cardTapped = true;
        // } else {
        //   cardTapped = false;
        // }

        setState(() {});
      },
      itemBuilder: (BuildContext context, int index) {
        return AnimatedBuilder(
          animation: _pageController,
          builder: (BuildContext? context, Widget? widget) {
            return Center(child: SizedBox(child: widget));
          },
          child: InkWell(
            onTap: () async {
              setState(() {
                // cardTapped = !cardTapped;
              });
            },
            child: Column(
              children: [
                SizedBox(
                  width: context.width,
                  child: products[index].serviceOffers!.isNotEmpty
                      ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.96, end: 1.04),
                    duration: const Duration(milliseconds: 1100),
                    curve: Curves.easeInOut,
                    builder: (context, scale, child) {
                      final bool hasDiscount = products[index]
                          .serviceOffers!
                          .any((e) => _isDiscountOffer(e));

                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          _showServiceOffersDialog(products[index]);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          height: 34,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: hasDiscount
                                ? const Color(0xFFFFF7ED)
                                : const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasDiscount
                                  ? const Color(0xFFFDBA74)
                                  : const Color(0xFF93C5FD),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (hasDiscount
                                    ? const Color(0xFFEA580C)
                                    : const Color(0xFF2563EB))
                                    .withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.scale(
                                scale: scale,
                                child: Icon(
                                  hasDiscount
                                      ? Icons.discount_rounded
                                      : Icons.local_offer_rounded,
                                  size: 15,
                                  color: hasDiscount
                                      ? const Color(0xFFEA580C)
                                      : const Color(0xFF2563EB),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                hasDiscount ? "خصومات وخدمات" : "خدمات مرفقة",
                                style: robotoMedium.copyWith(
                                  fontSize: 11,
                                  color: hasDiscount
                                      ? const Color(0xFF9A3412)
                                      : const Color(0xFF1E3A8A),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Row(
                                children: [
                                  for (var i = 0;
                                  i <
                                      (products[index].serviceOffers!.length > 3
                                          ? 3
                                          : products[index].serviceOffers!.length);
                                  i++)
                                    Container(
                                      margin:
                                      const EdgeInsetsDirectional.only(start: 3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.08),
                                            blurRadius: 3,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: ClipOval(
                                        child: CustomImage(
                                          image:
                                          '${Get.find<SplashController>().configModel!.baseUrls!.provider}'
                                              '/${products[index].serviceOffers![i].image ?? Images.image}',
                                          height: 20,
                                          width: 20,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  if (products[index].serviceOffers!.length > 3)
                                    Container(
                                      margin:
                                      const EdgeInsetsDirectional.only(start: 4),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 5,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: hasDiscount
                                            ? const Color(0xFFEA580C)
                                            : const Color(0xFF2563EB),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '+${products[index].serviceOffers!.length - 3}',
                                        style: robotoMedium.copyWith(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.keyboard_arrow_up_rounded,
                                size: 16,
                                color: hasDiscount
                                    ? const Color(0xFF9A3412)
                                    : const Color(0xFF1E3A8A),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                      : const SizedBox(height: 12),
                ),
                Center(
                  child: EstateItem(
                    estate: products[index],
                    onPressed: () {
                      Get.find<UserController>()
                          .getUserInfoByID(products[index].userId!);
                      Get.find<UserController>().getEstateByUser(
                        1,
                        false,
                        products[index].userId!,
                      );
                      Get.dialog(DettailsDilog(estate: products[index]));
                    },
                    fav: false,
                    isMyProfile: 0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String formatPrice(String priceStr) {
    final num? price = num.tryParse(priceStr);
    if (price == null) return "0";

    if (price >= 1000000) {
      return "${(price / 1000000).toStringAsFixed(2)} مليون";
    } else if (price >= 1000) {
      return "${(price / 1000).toStringAsFixed(2)} ألف";
    } else {
      return price.toString();
    }
  }
}
void _showServiceOffersDialog(Estate estate) {
  Get.bottomSheet(
    Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 45,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: Color(0xFFEA580C),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'الخدمات المرفقة',
                  style: robotoBold.copyWith(
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.black87,
                  ),
                  splashRadius: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: estate.serviceOffers?.length ?? 0,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final offer = estate.serviceOffers![i];
                final bool isDiscount = _isDiscountOffer(offer);

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDiscount
                        ? const Color(0xFFFFFBEB)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isDiscount
                          ? const Color(0xFFF59E0B).withOpacity(0.35)
                          : const Color(0xFF3B82F6).withOpacity(0.18),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDiscount
                            ? const Color(0xFFF59E0B)
                            : const Color(0xFF3B82F6))
                            .withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CustomImage(
                              image:
                              '${Get.find<SplashController>().configModel!.baseUrls!.provider}'
                                  '/${offer.image ?? Images.image}',
                              height: 52,
                              width: 52,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  offer.title?.isNotEmpty == true
                                      ? offer.title!
                                      : 'عرض مرفق',
                                  style: robotoBold.copyWith(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  offer.provider_name?.isNotEmpty == true
                                      ? offer.provider_name!
                                      : 'مزود خدمة',
                                  style: robotoMedium.copyWith(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: isDiscount
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isDiscount ? 'خصم' : 'سعر خاص',
                              style: robotoBold.copyWith(
                                fontSize: 10,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDiscount
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isDiscount
                                  ? Icons.discount_rounded
                                  : Icons.payments_outlined,
                              size: 18,
                              color: isDiscount
                                  ? const Color(0xFFEA580C)
                                  : const Color(0xFF1D4ED8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _offerMainValue(offer),
                              style: robotoBold.copyWith(
                                fontSize: 14,
                                color: isDiscount
                                    ? const Color(0xFF9A3412)
                                    : const Color(0xFF1E3A8A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((offer.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          offer.description!,
                          style: robotoRegular.copyWith(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if ((offer.expiryDate ?? '').isNotEmpty)
                            _offerInfoChip(
                              icon: Icons.event_outlined,
                              label: 'ينتهي: ${offer.expiryDate}',
                            ),
                          if ((offer.offerType ?? '').isNotEmpty)
                            _offerInfoChip(
                              icon: isDiscount
                                  ? Icons.local_offer_outlined
                                  : Icons.sell_outlined,
                              label: offer.offerType!,
                            ),
                        ],
                      ),
                      if ((offer.phoneProvider ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _makePhoneCall(offer.phoneProvider!);
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFBFDBFE),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.call_outlined,
                                        size: 18,
                                        color: Color(0xFF1D4ED8),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'اتصال',
                                        style: robotoBold.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFF1E3A8A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _openWhatsApp(
                                    phoneNumber: offer.phoneProvider!,
                                    estate: estate,
                                    offer: offer,
                                  );
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: const Color(0xFFA7F3D0),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.chat_bubble_outline_rounded,
                                        size: 18,
                                        color: Color(0xFF059669),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'واتساب',
                                        style: robotoBold.copyWith(
                                          fontSize: 12,
                                          color: const Color(0xFF065F46),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          offer.phoneProvider!,
                          style: robotoMedium.copyWith(
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}
bool _isDiscountOffer(ServiceOffers offer) {
  return (offer.discount ?? '').isNotEmpty && offer.discount != '0';
}

String _offerMainValue(ServiceOffers offer) {
  if (_isDiscountOffer(offer)) {
    return '${offer.discount}% خصم';
  }

  if ((offer.servicePrice ?? '').isNotEmpty && offer.servicePrice != '0') {
    return '${offer.servicePrice} ر.س';
  }

  return 'عرض خاص';
}

Widget _offerInfoChip({
  required IconData icon,
  required String label,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 7,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.shade200,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade700,
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: 11,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    ),
  );
}

String _buildEstateShareMessage(Estate estate, {ServiceOffers? offer}) {
  final String title =
  estate.title?.isNotEmpty == true ? estate.title! : 'عقار';
  final String category =
  estate.categoryName?.isNotEmpty == true ? estate.categoryName! : 'عقار';
  final String space =
  estate.space?.isNotEmpty == true ? estate.space! : '-';
  final String price =
  estate.price?.isNotEmpty == true ? estate.price! : '-';
  final String city =
  estate.city?.isNotEmpty == true ? estate.city! : '-';
  final String districts =
  estate.districts?.isNotEmpty == true ? estate.districts! : '-';
  final String provider =
  offer?.provider_name?.isNotEmpty == true ? offer!.provider_name! : '-';
  final String offerTitle =
  offer?.title?.isNotEmpty == true ? offer!.title! : 'عرض مرفق';

  return '''
السلام عليكم
وجدت هذا العرض في تطبيق العقار وأرغب بالاستفسار عنه.

بيانات العقار:
العنوان: $title
النوع: $category
المدينة: $city
الحي: $districts
المساحة: $space
السعر: $price

بيانات العرض:
$offerTitle
مزود الخدمة: $provider

أرجو التواصل معي، شكرًا.
''';
}

Future<void> _makePhoneCall(String phoneNumber) async {
  final String cleaned = phoneNumber
      .replaceAll(' ', '')
      .replaceAll('-', '');

  final Uri phoneUri = Uri(
    scheme: 'tel',
    path: cleaned,
  );

  if (await canLaunchUrl(phoneUri)) {
    await launchUrl(phoneUri);
  } else {
    showCustomSnackBar('تعذر فتح الاتصال', isError: true);
  }
}

Future<void> _openWhatsApp({
  required String phoneNumber,
  required Estate estate,
  required ServiceOffers offer,
}) async {
  final String cleaned = phoneNumber
      .replaceAll(' ', '')
      .replaceAll('+', '')
      .replaceAll('-', '');

  final String message = _buildEstateShareMessage(
    estate,
    offer: offer,
  );

  final Uri waUri = Uri.parse(
    'https://wa.me/$cleaned?text=${Uri.encodeComponent(message)}',
  );

  if (await canLaunchUrl(waUri)) {
    await launchUrl(
      waUri,
      mode: LaunchMode.externalApplication,
    );
  } else {
    showCustomSnackBar('تعذر فتح واتساب', isError: true);
  }
}





class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;

  SliverDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 50;

  @override
  double get minExtent => 50;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != 50 ||
        oldDelegate.minExtent != 50 ||
        child != oldDelegate.child;
  }
}