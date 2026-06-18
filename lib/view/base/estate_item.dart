// import 'package:abaad_flutter/controller/auth_controller.dart';
// import 'package:abaad_flutter/controller/estate_controller.dart';
// import 'package:abaad_flutter/controller/splash_controller.dart';
// import 'package:abaad_flutter/controller/wishlist_controller.dart';
// import 'package:abaad_flutter/data/model/response/estate_model.dart';
// import 'package:abaad_flutter/util/dimensions.dart';
// import 'package:abaad_flutter/util/images.dart';
// import 'package:abaad_flutter/util/styles.dart';
// import 'package:abaad_flutter/view/base/confirmation_dialog.dart';
// import 'package:abaad_flutter/view/base/custom_image.dart';
// import 'package:abaad_flutter/view/base/custom_snackbar.dart';
// import 'package:abaad_flutter/view/base/view_image_dilog.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../helper/route_helper.dart';
// import '../screen/profile/edit_dilog.dart';
//
// class EstateItem extends StatelessWidget {
//  final Estate? estate;
//  final bool? fav;
//  final int? isMyProfile ;
//  final void Function()? onPressed;
//
//
//   const EstateItem({super.key, required this.estate,this.onPressed,this.fav = false, this.isMyProfile = 0});
//
//   @override
//   Widget build(BuildContext context) {
//     final currentLocale = Get.locale;
//     bool isArabic = currentLocale?.languageCode == 'ar';
//     //print("-------------------------------------------$isMyProfile");
//     return  InkWell(
//       onTap:onPressed,
//       child: Container(
//         width: context.width,
//         padding: EdgeInsets.only(right: 5,left: 5,top: 3),
//         // decoration: BoxDecoration(
//         //   color: Theme.of(context).cardColor,
//         //
//         // ),
//         child: Container(
//           alignment: Alignment.bottomCenter,
//           padding:  isMyProfile==1? const EdgeInsets.all(8 ):const EdgeInsets.all(0),
//           child:Container(
//             // height:fav?150: 155,
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(4), //border corner radius
//               boxShadow:[
//                 BoxShadow(
//                   color: Colors.grey.withOpacity(0.5), //color of shadow
//                   spreadRadius: 5, //spread radius
//                   blurRadius: 7, // blur radius
//                   offset: Offset(0, 2), // changes position of shadow
//                   //first paramerter of offset is left-right
//                   //second parameter is top to down
//                 ),
//                 //you can set more BoxShadow() here
//               ],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: <Widget>[
//
//                 Expanded(
//                   child: Column(
//                     children: <Widget>[
//
//                       Row(
//                         children: <Widget>[
//
//                           SizedBox(
//                             width: 155,
//                             height: 155,
//
//                             child:   Container(child:   Container(
//                               decoration: BoxDecoration(
//                                 color: Theme.of(context).cardColor,
//                                 borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
//                                 boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
//                                 child:  GetBuilder<SplashController>(builder: (splashController) {
//                                   String baseUrl = Get.find<SplashController>().configModel?.baseUrls?.estateImageUrl ?? "";
//                                   return         CustomImage(
//                                     image: (estate?.images != null && estate!.images!.isNotEmpty)
//                                         ? "$baseUrl/${estate!.images![0]}"
//                                         : Images.estate_type
//                                     ,
//                                     fit:  BoxFit.cover,
//                                     placeholder: "assets/image/logo.png",
//                                     width: MediaQuery.of(context).size.width,
//
//
//                                   );
//                                 },
//                                 ),
//                               ),
//                             )),
//                           ),
//                           SizedBox(width: 11.0),
//
//                           isMyProfile==1?Column(
//                             children: [
//                               IconButton(
//                                 onPressed: () {
//                                   Get.dialog(ConfirmationDialog(icon: Images.support,
//                                     title: 'do_you_really_want_to_delete_this_offer'.tr,
//                                     description: 'you_will_remove_all_your_information_from_the_offer'.tr, isLogOut: true,
//                                     onYesPressed: () => Get.find<EstateController>().deleteEstate(estate?.id ?? 0),
//                                   ), useSafeArea: false);
//                                 },
//                                 icon: Icon(Icons.delete_forever, color: Colors.red ,size: 20,),
//                               ),
//                               IconButton(
//                                 onPressed: ()async {
//                                   Get.find<EstateController>().currentIndex==0;
//                                   Get.find<EstateController>().categoryIndex==0;
//                                   await       Get.toNamed(RouteHelper.getEditEstatRoute(estate));
//
//                                   Get.dialog(EditDialog(estate:estate));
//                                 },
//                                 icon: Icon(Icons.edit_note_rounded, color: Colors.orange),
//                               ),
//                               IconButton(
//                                 onPressed: ()async {
//                                   Get.find<EstateController>().currentIndex==0;
//                                   Get.find<EstateController>().categoryIndex==0;
//                                   await    Get.dialog(ViewImageUploadScreen(estate!));
//                                 },
//                                 icon: Icon(Icons.image_sharp, color: Colors.blue),
//                               ),
//                             ],
//
//                           ):       Container( ),
//                           Flexible(
//                             flex: 5,
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: <Widget>[
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                    Row(
//                                      children: [
//
//                                        Text("price".tr  , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
//                                        SizedBox(width: 11.0),
//                                        Text(
//                                          formatPrice( (estate?.categoryName ?? "") == "ارض"  ? estate?.totalPrice ?? "" : estate?.price ?? "" ),
//                                          style: robotoBlack.copyWith(fontSize: 11),
//                                        ),
//
//                                        SizedBox(width: 2.0),
//                                      // Text("currency".tr  , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall))
//                                      ],
//                                    )
// ,
//                                     Container(
//                                       // height: 60,
//
//                                       child: Column(
//                                         children: [
//                                           (fav ?? false) ?
//                                           Container(
//                                             width: 30, height: 30,
//                                             margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
//                                             decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.white),
//                                             child:     GetBuilder<WishListController>(builder: (wishController) {
//                                               bool isWished = wishController.wishRestIdList.contains(estate?.estate_id);
//                                               return InkWell(
//                                                 onTap: () {
//                                                   if(Get.find<AuthController>().isLoggedIn()) {
//
//                                                     //print("removed id ------------------omer-------${estate?.id}");
//                                                     isWished ? wishController.removeFromWishList(estate?.estate_id ?? 0) : wishController.addToWishList(estate!, true);
//                                                   }else {
//                                                     showCustomSnackBar('you_are_not_logged_in'.tr);
//                                                   }
//                                                 },
//                                                 child: Padding(
//                                                   padding: EdgeInsets.symmetric(vertical:  Dimensions.PADDING_SIZE_SMALL ),
//                                                   child: Icon(
//                                                     isWished ? Icons.favorite : Icons.favorite_border,  size:25,
//                                                     color: isWished ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
//                                                   ),
//                                                 ),
//                                               );
//                                             }),
//                                           ) :Container(),
//
//                                           Container(
//                                             padding: const EdgeInsets.only(right: 4,left: 4),
//                                             decoration:  BoxDecoration(
//                                                 borderRadius: BorderRadius.circular(
//                                                     4),
//                                                 color:  Colors.blue),
//                                             child:  Row(
//                                               children: [
//                                                 Text(
//                                                     "${estate?.view}",
//                                                     style: robotoRegular.copyWith(
//                                                       fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor,
//                                                     )
//                                                 ),
//                                                 SizedBox(width: 2,),
//                                                 Icon(Icons.remove_red_eye_outlined,color:Colors.white,size: 20,),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 3.0,
//                                 ),
//                                 Row(
//                                   children: [
//                                     Text(   isArabic ? "${estate?.categoryNameAr} -${estate?.city} -${estate?.districts??''}":"${estate?.categoryName} -${estate?.zoneName} -${estate?.districts}",
//                                         style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
//                                     Container(
//                                       padding: const EdgeInsets.only(right: 4,left: 4),
//                                       decoration:  BoxDecoration(
//                                           borderRadius: BorderRadius.circular(
//                                               4),
//                                           color:  Colors.blue),
//                                       child:  Row(
//                                         children: [
//                                           Text(
//                                               estate?.advertisementType ?? "",
//                                               style: robotoRegular.copyWith(
//                                                 fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor,
//                                               )
//                                           ),
//                                           SizedBox(width: 2,),
//
//                                         ],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(
//                                   height: 3.0,
//                                 ),
//
//
//                                 Row(
//                                   children: [
//                                     Text("رقم ترخيض الإعلان".tr,
//                                         style: robotoBlack.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.black26)),
//
//                                   ],
//
//                                 ),
//                                 Container(
//                                   child: Row(
//                                     children: [
//                      // /
//                                       SizedBox(
//                                         width: 4.0,
//                                       ),
//                                       Text(" ${estate?.adLicenseNumber}",style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
//                                       // IconButton(onPressed:(){
//                                       //   FlutterClipboard.copy(estate.adNumber.toString()).then(( value ) {
//                                       //     showCustomSnackBar('تم النسخ'.tr, isError: false);
//                                       //   });
//                                       // }, icon: Icon(Icons.copy,color: Theme.of(context).primaryColor,size: 11,)),
//                                     ],
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 7.0,
//                                 ),
// estate?.category != "5"? estate?.property  != null ?Center(
//   child: SizedBox(
//     height: 35,
//
//     child:ListView.builder(
//       physics: BouncingScrollPhysics(),
//       itemCount:  estate?.property?.length,
//       scrollDirection: Axis.horizontal,
//       // ignore: missing_return
//       itemBuilder: (context, index) {
//
//         return  estate?.property?[index].name=="حمام"? Container(
//           decoration: BoxDecoration(color: Theme
//               .of(context)
//               .cardColor,
//             borderRadius: BorderRadius.circular(
//                 Dimensions.RADIUS_SMALL),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.grey,
//                 offset: Offset(0.0, 0.2), //(x,y)
//                 blurRadius: 6.0,
//               ),
//             ],),
//           margin: EdgeInsets.only(top: 5,bottom: 5,right: 2,left: 2),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment
//                 .spaceBetween,
//             children: <Widget>[
//               SizedBox(
//                 height: 22.0,
//                 width: 22.0,
//
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   child: Image.asset(
//                       Images.bathroom, height: 15,
//                       color: Theme.of(context).primaryColor,
//                       width: 15),
//                 ),
//               ),
//
//               Container(
//
//                 child: Row(
//                   children: [
//                     Text("bathroom".tr,style: robotoBlack.copyWith(fontSize: 9,)),
//
//                     Container(
//                       child: Text(" ${estate?.property?[index].number ?? ""}",style: robotoBlack.copyWith(fontSize: 9,)),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ):estate?.property?[index].name=="مطبخ"? Container(
//           decoration: BoxDecoration(color: Theme
//               .of(context)
//               .cardColor,
//             borderRadius: BorderRadius.circular(
//                 Dimensions.RADIUS_SMALL),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.grey,
//                 offset: Offset(0.0, 0.2), //(x,y)
//                 blurRadius: 6.0,
//               ),
//             ],),
//           margin: EdgeInsets.only(top: 5,bottom: 5,right: 2,left: 2),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment
//                 .spaceBetween,
//             children: <Widget>[
//               SizedBox(
//                 height: 22.0,
//                 width: 22.0,
//
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   child: Image.asset(
//                       Images.kitchen, height: 15,
//                       color: Theme.of(context).primaryColor,
//                       width: 15),
//                 ),
//               ),
//               Row(
//                 children: [
//                   Text("kitchen".tr,style: robotoBlack.copyWith(fontSize: 9,)),
//                   Container(
//
//                     child: Text(" ${estate?.property?[index].number ?? ""}",style: robotoBlack.copyWith(fontSize: 9,)),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ): estate?.property?[index].name=="مطلبخ"?Container(
//           decoration: BoxDecoration(color: Theme
//               .of(context)
//               .cardColor,
//             borderRadius: BorderRadius.circular(
//                 Dimensions.RADIUS_SMALL),
//             boxShadow: const [
//               BoxShadow(
//                 color: Colors.grey,
//                 offset: Offset(0.0, 0.2), //(x,y)
//                 blurRadius: 6.0,
//               ),
//             ],),
//           margin: EdgeInsets.only(top: 5,bottom: 5,right: 2,left: 2),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment
//                 .spaceBetween,
//             children: <Widget>[
//               SizedBox(
//                 height: 22.0,
//                 width: 22.0,
//
//                 child: Container(
//                   padding: EdgeInsets.all(3),
//                   child: Image.asset(
//                       Images.kitchen, height: 20,
//                       color: Theme.of(context).primaryColor,
//                       width: 20),
//                 ),
//               ),
//               Row(
//                 children: [
//               Text("kitchen".tr,style: robotoBlack.copyWith(fontSize: 9,)),
//                   Container(
//                     child: Text(" ${ estate?.property?[index].number ?? ""}",style: robotoBlack.copyWith(fontSize: 9,)),
//                   ),
//                 ],
//               )
//             ],
//           ),
//         ):estate?.property?[index].name=="غرف نوم"?Container(decoration: BoxDecoration(color: Theme
//             .of(context)
//             .cardColor,
//           borderRadius: BorderRadius.circular(
//               Dimensions.RADIUS_SMALL),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.grey,
//               offset: Offset(0.0, 0.2), //(x,y)
//               blurRadius: 6.0,
//             ),
//           ],), margin: const EdgeInsets.all(5.0), child: Row(
//           mainAxisAlignment: MainAxisAlignment
//               .spaceBetween,
//           children: <Widget>[
//             SizedBox(
//               height: 25.0,
//               width: 25.0,
//
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 child: Image.asset(
//                     Images.bed, height: 22,
//                     color: Theme.of(context).primaryColor,
//                     width: 22),
//               ),
//             ),
//             Row(
//               children: [
//                 Text("bedrooms".tr,style: robotoBlack.copyWith(fontSize: 9,)),
//                 Container(
//                   child: Text(" ${ estate?.property?[index].number}",style: robotoBlack.copyWith(fontSize: 9,)),
//                 ),
//               ],
//             )
//           ],
//         ),):estate?.property?[index].name=="صلات"?Container(decoration: BoxDecoration(color: Theme
//             .of(context)
//             .cardColor,
//           borderRadius: BorderRadius.circular(
//               Dimensions.RADIUS_SMALL),
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.grey,
//               offset: Offset(0.0, 0.2), //(x,y)
//               blurRadius: 6.0,
//             ),
//           ],),   margin: EdgeInsets.only(top: 5,bottom: 5,right: 2,left: 2), child: Row(
//           mainAxisAlignment: MainAxisAlignment
//               .spaceBetween,
//           children: <Widget>[
//             SizedBox(
//               height: 25.0,
//               width: 25.0,
//
//               child: Container(
//                 padding: const EdgeInsets.all(6),
//                 child: Image.asset(
//                     Images.setroom, height: 20,
//                     color: Theme.of(context).primaryColor,
//                     width: 20),
//               ),
//             ),
//             Row(
//               children: [
//                 Text("lounges".tr,style: robotoBlack.copyWith(fontSize: 9,)),
//                 Container(
//
//                   child: estate
//                       ?.property?[index]
//                       .number!=0?Text(estate?.property?[index].number ?? "",
//                       style: robotoBlack.copyWith(fontSize: 9,)):Text("0",style: robotoBlack.copyWith(fontSize: 9,)),
//                 ),
//               ],
//             )
//           ],
//         ),):Container();
//
//
//
//
//       },
//     ),
//   ),
// ):Container():        Text(estate?.shortDescription ?? "",
//     style: robotoBlack.copyWith(fontSize: 12)),
//
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//
//
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//
//   }
//
//
//  String formatPrice(String priceStr) {
//    final num? price = num.tryParse(priceStr);
//
//    if ((price ?? 0) >= 1000000) {
//      return "${((price ?? 0) / 1000000).toStringAsFixed(2)} مليون";
//    } else if ((price ?? 0) >= 1000) {
//      return "${((price ?? 0) / 1000).toStringAsFixed(2)} ألف";
//    } else {
//      return price.toString();
//    }
//  }
//
// }



import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/estate_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/wishlist_controller.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/confirmation_dialog.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/view_image_dilog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../helper/route_helper.dart';
import '../screen/profile/edit_dilog.dart';

class EstateItem extends StatelessWidget {
  final Estate? estate;
  final bool? fav;
  final int? isMyProfile ;
  final void Function()? onPressed;

  const EstateItem({super.key, required this.estate,this.onPressed,this.fav = false, this.isMyProfile = 0});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: context.width,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Estate Image
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GetBuilder<SplashController>(
                    builder: (splashController) {
                      String baseUrl = Get.find<SplashController>().configModel?.baseUrls?.estateImageUrl ?? "";
                      return CustomImage(
                        image: (estate?.images != null && estate!.images!.isNotEmpty)
                            ? "$baseUrl/${estate!.images![0]}"
                            : Images.estate_type,
                        fit: BoxFit.cover,
                        placeholder: "assets/image/logo.png",
                        width: 120,
                        height: 120,
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Estate Details - wrapped in Expanded to prevent overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Important to prevent overflow
                  children: <Widget>[
                    // Header with price and actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Price
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "price".tr,
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatPrice((estate?.categoryName ?? "") == "ارض" ? estate?.totalPrice ?? "" : estate?.price ?? ""),
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action buttons
                        Row(
                          mainAxisSize: MainAxisSize.min, // Prevent overflow
                          children: [
                            // View count
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    color: Theme.of(context).primaryColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${estate?.view}",
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeExtraSmall,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Favorite button
                            if (fav ?? false) ...[
                              const SizedBox(width: 8),
                              GetBuilder<WishListController>(
                                builder: (wishController) {
                                  bool isWished = wishController.wishRestIdList.contains(estate?.estate_id);
                                  return Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        if (Get.find<AuthController>().isLoggedIn()) {
                                          isWished
                                              ? wishController.removeFromWishList(estate?.estate_id ?? 0)
                                              : wishController.addToWishList(estate!, true);
                                        } else {
                                          showCustomSnackBar('you_are_not_logged_in'.tr);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(16),
                                      child: Icon(
                                        isWished ? Icons.favorite : Icons.favorite_border,
                                        size: 18,
                                        color: isWished ? Colors.red : Theme.of(context).hintColor,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Location and type
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isArabic
                                ? "${estate?.categoryNameAr} - ${estate?.city} - ${estate?.districts ?? ''}"
                                : "${estate?.categoryName} - ${estate?.zoneName} - ${estate?.districts}",
                            style: robotoRegular.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).hintColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              estate?.advertisementType ?? "",
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeExtraSmall,
                                color: Theme.of(context).primaryColor,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // License number
                    Row(
                      children: [
                        Icon(
                          Icons.verified_outlined,
                          size: 16,
                          color: Theme.of(context).hintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "رقم ترخيص الإعلان".tr,
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeSmall,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            "${estate?.adLicenseNumber}",
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeSmall,
                              color: Theme.of(context).primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Property features or description - IMPROVED SECTION
                    Flexible(
                      child: estate?.category != "5"
                          ? estate?.property != null
                          ? SizedBox(
                        height: 20, // Reduced height
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: estate?.property?.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return _buildPropertyFeature(context, index);
                          },
                        ),
                      )
                          : const SizedBox.shrink()
                          : Text(
                        estate?.shortDescription ?? "",
                        style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).hintColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile actions (edit, delete, etc.)
              if (isMyProfile == 1)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Important to prevent overflow
                    children: [
                      _buildActionButton(
                        context,
                        Icons.delete_forever,
                        Colors.red,
                            () {
                          Get.dialog(
                            ConfirmationDialog(
                              icon: Images.support,
                              title: 'do_you_really_want_to_delete_this_offer'.tr,
                              description: 'you_will_remove_all_your_information_from_the_offer'.tr,
                              isLogOut: true,
                              onYesPressed: () => Get.find<EstateController>().deleteEstate(estate?.id ?? 0),
                            ),
                            useSafeArea: false,
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        context,
                        Icons.edit_note_rounded,
                        Colors.orange,
                            () async {
                          Get.find<EstateController>().currentIndex == 0;
                          Get.find<EstateController>().categoryIndex == 0;
                          await Get.toNamed(RouteHelper.getEditEstatRoute(estate));
                          Get.dialog(EditDialog(estate: estate));
                        },
                      ),
                      const SizedBox(height: 8),
                      _buildActionButton(
                        context,
                        Icons.image_sharp,
                        Colors.blue,
                            () async {
                          Get.find<EstateController>().currentIndex == 0;
                          Get.find<EstateController>().categoryIndex == 0;
                          await Get.dialog(ViewImageUploadScreen(estate!));
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropertyFeature(BuildContext context, int index) {
    final property = estate?.property?[index];
    final propertyName = property?.name ?? "";

    // Define property type configurations
    final Map<String, Map<String, dynamic>> propertyConfigs = {
      "حمام": {
        "icon": Images.bathroom,
        "label": "bathroom".tr,
      },
      "مطبخ": {
        "icon": Images.kitchen,
        "label": "kitchen".tr,
      },
      "مطلبخ": {
        "icon": Images.kitchen,
        "label": "kitchen".tr,
      },
      "غرف نوم": {
        "icon": Images.bed,
        "label": "bedrooms".tr,
      },
      "صلات": {
        "icon": Images.setroom,
        "label": "lounges".tr,
      },
    };

    if (!propertyConfigs.containsKey(propertyName)) {
      return const SizedBox.shrink();
    }

    final config = propertyConfigs[propertyName]!;
    final icon = config["icon"] as String;
    final label = config["label"] as String;

    return Container(
      margin: const EdgeInsets.only(right: 6), // Reduced margin
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reduced padding
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.08), // More subtle background
        borderRadius: BorderRadius.circular(15), // Adjusted border radius
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            icon,
            height: 14, // Reduced icon size
            width: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 3), // Reduced spacing
          Text(
            "$label ${property?.number ?? 0}",
            style: robotoMedium.copyWith(
              fontSize: 10, // Smaller font size
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Icon(
          icon,
          color: color,
          size: 20,
        ),
      ),
    );
  }

  String formatPrice(String priceStr) {
    final num? price = num.tryParse(priceStr);

    if ((price ?? 0) >= 1000000) {
      return "${((price ?? 0) / 1000000).toStringAsFixed(2)} مليون";
    } else if ((price ?? 0) >= 1000) {
      return "${((price ?? 0) / 1000).toStringAsFixed(2)} ألف";
    } else {
      return price.toString();
    }
  }
}