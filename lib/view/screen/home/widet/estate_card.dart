import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/wishlist_controller.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/details_dilog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


// class PropertyCard extends StatelessWidget {
//   Estate estate;
//   PropertyCard(this.estate, {super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return  GestureDetector(
//       onTap: (){
//         Get.dialog(DettailsDilog(estate:estate));
//         // Get.toNamed(RouteHelper.getDetailsRoute(estate.id,estate.userId));
//       },
//       child:
//
//
//       Padding(
//         padding: const EdgeInsets.only(bottom: 6,top: 6),
//         child: Container(
//           height: 260,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(4), //border corner radius
//             boxShadow:[
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.5), //color of shadow
//                 spreadRadius: 1, //spread radius
//                 blurRadius: 7, // blur radius
//                 offset: Offset(0, 1.5), // changes position of shadow
//                 //first paramerter of offset is left-right
//                 //second parameter is top to down
//               ),
//               //you can set more BoxShadow() here
//             ],
//           ),
//           child: Column(
//             children: [
//               Expanded(
//                 child: Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     CustomImage(
//                       image: estate.images != null && estate.images!.isNotEmpty
//                           ? "${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${estate.images![0]}"
//                           : null, // إذا ما في صورة نخليها null
//                       fit: BoxFit.cover,
//                       width: MediaQuery.of(context).size.width,
//                       placeholder: "assets/image/logo.png", // الصورة الافتراضية
//                       //errorImage: "assets/images/default_estate.png", // إذا حصل خطأ
//                     ),
//
//                     Positioned(
//                       top: 10.0,
//                       right: 2.0,
//                       child:        Container(
//                         width: 30, height: 30,
//                         margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
//                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.white),
//                         child:      GetBuilder<WishListController>(builder: (wishController) {
//                        //   bool _isWished =  wishController.wishRestList.contains(estate.id);
//                           return InkWell(
//                             onTap: () {
//                               if(Get.find<AuthController>().isLoggedIn()) {
//                                 wishController.wishRestIdList.contains(estate.id) ? wishController.removeFromWishList(estate.id!)
//                                     : wishController.addToWishList(estate, false);
//                               }else {
//                                 showCustomSnackBar('you_are_not_logged_in'.tr);
//                               }
//                             },
//                             child: Icon(
//                               wishController.wishRestIdList.contains(estate.id) ? Icons.favorite : Icons.favorite_border,
//                               color: wishController.wishRestIdList.contains(estate.id) ? Theme.of(context).primaryColor
//                                   : Theme.of(context).disabledColor,
//                             ),
//                           );
//                         }),
//                       ),
//                     ),
//                     estate.serviceOffers!.isNotEmpty?  Positioned(
//                       top: 10.0,
//                       left: 10.0,
//                       child:        Container(
//                         margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
//
//                         decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Colors.orange),
//                         child: Row(
//                           children: [
//
//                             Padding(
//                               padding: const EdgeInsets.only(right: 4,left: 4),
//                               child: Text("it_includes_offers".tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.surface),),
//                             ),
//
//                           ],
//                         ),
//                       ),
//                     ):Container() ,
//
//                     estate.arPath !=null?   Positioned(
//                       bottom: 1.0,
//                       left: 10.0,
//                       child:    Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           children: [
//                             Container(
//                               decoration: BoxDecoration(
//                                 border: Border.all(width: 1, color: Theme.of(context).primaryColor),
//                                 shape: BoxShape.circle,
//                               ),
//                               alignment: Alignment.topRight,
//                               child: ClipOval(child:
//                               Image.asset(estate.serviceOffers!.isEmpty?Images.vt:Images.vt_offer, height: 20, width: 20),),
//                             ),
//                             Container(
//
//                               decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), color: Colors.orange),
//                               child: Row(
//                                 children: [
//
//                                   Padding(
//                                     padding: const EdgeInsets.only(right: 4,left: 4),
//                                     child: Text("3D", style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).colorScheme.surface),),
//                                   ),
//
//                                 ],
//                               ),
//                             )
//                           ],
//                         ),
//                       ),
//
//                     ):Container()
//                   ],
//                 ),
//               ),
//               SizedBox(height: 6),
//               Container(
//
//                 child: Column(
//                   crossAxisAlignment:
//                   CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment:
//                       MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Row(
//                             children: [
//                               Text(
//                                 estate.categoryName == "ارض"
//                                     ? formatPrice(estate!.totalPrice!)
//                                     : formatPrice(estate!.price!),
//                                 style: robotoBlack.copyWith(fontSize: 14),
//                               ),
//                               SizedBox(width: 2.0),
//                               Text(
//                                 "currency".tr,
//                                 style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeExtraSmall),
//                               ),
//                             ],
//                           ),
//                         ),
//
//
//
//
//
//                         Container(
//                           padding: const EdgeInsets.only(right: 4,left: 4),
//                           decoration:  BoxDecoration(
//                               borderRadius: BorderRadius.circular(
//                                   4),
//                               color:  Colors.blue),
//                           child:  Row(
//                             children: [
//                               Text(
//                                   "${estate.view}",
//                                   style: robotoRegular.copyWith(
//                                     fontSize: Dimensions.fontSizeExtraSmall, color: Theme.of(context).cardColor,
//                                   )
//                               ),
//                               SizedBox(width: 2,),
//                               Icon(Icons.remove_red_eye_outlined,color:Colors.white,size: 20,),
//                             ],
//                         ),
//                         )
//                       ],
//                     ),
//                     Text(
//                       estate!.title!,
//                         style: robotoRegular.copyWith(
//                           fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).hintColor,
//                         )
//                     ),
//
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.edit_location,
//                           size: 15.0,
//                           color:Theme.of(context).primaryColor,
//                         ),
//                         SizedBox(
//                           width: 5.0,
//                         ),
//                         Text(
//                           estate!.title!,
//                           style: robotoBlack.copyWith(fontSize: 12),
//                         ),
//                         SizedBox(
//                           width: 20.0,
//                         ),
//
//                         Container(
//                           child: Row(
//                             children: [
//                               Text("رقم رخصة الإعلان",style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
//                               SizedBox(
//                                 width: 4.0,
//                               ),
//                               Text(estate!.adLicenseNumber!,style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).primaryColor)),
//                               // IconButton(onPressed:(){
//                               //   FlutterClipboard.copy(estate.adNumber.toString()).then(( value ) {
//                               //     showCustomSnackBar('تم النسخ'.tr, isError: false);
//                               //   });
//                               // }, icon: Icon(Icons.copy,color: Theme.of(context).primaryColor,size: 11,)),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     estate.category=="5"?     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(estate!.shortDescription!, style: robotoBlack.copyWith(fontSize: 12)),
//                     ):Container(),
//                   ],
//                 ),
//               ),
//               estate.category!="5"?     estate.property  != null ?Container(
//                 child: SizedBox(
//                   height: 35,
//
//                   child:ListView.builder(
//                     physics: BouncingScrollPhysics(),
//                     itemCount:  estate.property!.length,
//                     scrollDirection: Axis.horizontal,
//                     // ignore: missing_return
//                     itemBuilder: (context, index) {
//
//                       return  estate.property![index].name=="حمام"? Container(
//                         decoration: BoxDecoration(color: Theme
//                             .of(context)
//                             .cardColor,
//                           borderRadius: BorderRadius.circular(
//                             2),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.grey,
//                               offset: Offset(0.0, 0.2), //(x,y)
//                               blurRadius: 1.0,
//                             ),
//                           ],),
//                         margin: EdgeInsets.only(top: 8,bottom: 5,right: 2,left: 2),
//                         child: Row(
//
//                           children: <Widget>[
//                             SizedBox(
//                               height: 22.0,
//                               width: 22.0,
//
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 child: Image.asset(
//                                     Images.bathroom, height: 15,
//                                     color: Theme.of(context).primaryColor,
//                                     width: 15),
//                               ),
//                             ),
//                             Container(
//                               margin: const EdgeInsets.only(left: 5.0,right: 5.0),
//                               child: Text(" ${estate.property![index].number ?? ""} حمام  ", style: robotoRegular.copyWith(
//                                 fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
//                             )),
//                           ],
//                         ),
//                       ): estate.property![index].name=="مطبخ"? Container(
//                         decoration: BoxDecoration(color: Theme
//                             .of(context)
//                             .cardColor,
//                           borderRadius: BorderRadius.circular(
//                               2),
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Colors.grey,
//                               offset: Offset(0.0, 0.2), //(x,y)
//                               blurRadius: 1.0,
//                             ),
//                           ],),
//                         margin: EdgeInsets.only(top: 8,bottom: 5,right: 2,left: 2),
//                         child: Row(
//
//                           children: <Widget>[
//                             SizedBox(
//                               height: 22.0,
//                               width: 22.0,
//
//                               child: Container(
//                                 padding: const EdgeInsets.all(4),
//                                 child: Image.asset(
//                                     Images.kitchen, height: 15,
//                                     color: Theme.of(context).primaryColor,
//                                     width: 15),
//                               ),
//                             ),
//                             Container(
//                                 margin: const EdgeInsets.only(left: 5.0,right: 5.0),
//                                 child: Text(" ${estate.property![index].number ?? ""} مطبخ  ", style: robotoRegular.copyWith(
//                                     fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
//                                 )),
//                           ],
//                         ),
//                       ):  estate.property![index].name=="مطلبخ"?Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(2), boxShadow: const [
//                             BoxShadow(
//                               color: Colors.grey,
//                               offset: Offset(0.0, 0.1), //(x,y)
//                               blurRadius: 1.0,
//                             ),
//                           ],),
//                         margin: EdgeInsets.only(top: 6,bottom: 6,right: 2,left: 2),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment
//                               .spaceBetween,
//                           children: <Widget>[
//                             SizedBox(
//                               height: 22.0,
//                               width: 22.0,
//
//                               child: Container(
//                                 padding: EdgeInsets.all(3),
//                                 child: Image.asset(
//                                     Images.kitchen, height: 20,
//                                     color: Theme.of(context).primaryColor,
//                                     width: 20),
//                               ),
//                             ),
//                             Container(
//                               margin: EdgeInsets.only(left: 8.0,right: 8.0),
//                               child: Text(" ${ estate.property![index].number ?? "  "} مطبخ ", style: robotoRegular.copyWith(
//                                   fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
//                               ),
//                             )
//                           ],
//                         ),
//                       ):estate.property![index].name=="غرف نوم"?Container(decoration: BoxDecoration(color: Theme
//                           .of(context)
//                           .cardColor,
//                         borderRadius: BorderRadius.circular(
//                           2),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.grey,
//                             offset: Offset(0.0, 0.1), //(x,y)
//                             blurRadius: 1.0,
//                           ),
//                         ],), margin: const EdgeInsets.all(5.0), child: Row(
//                         mainAxisAlignment: MainAxisAlignment
//                             .spaceBetween,
//                         children: <Widget>[
//                           SizedBox(
//                             height: 25.0,
//                             width: 25.0,
//
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               child: Image.asset(
//                                   Images.bed, height: 22,
//                                   color: Theme.of(context).primaryColor,
//                                   width: 22),
//                             ),
//                           ),
//                           Container(
//                             margin: const EdgeInsets.only(left: 7.0),
//                             child: Text(" ${ estate
//                                 .property![index]
//                                 .number} غرف النوم ", style: robotoRegular.copyWith(
//                                 fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor),
//                             ),
//                           )
//                         ],
//                       ),):estate.property![index].name=="صلات"?Container(decoration: BoxDecoration(color: Theme
//                           .of(context)
//                           .cardColor,
//                         borderRadius: BorderRadius.circular(
//                         2),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.grey,
//                             offset: Offset(0.0, 0.1), //(x,y)
//                             blurRadius: 1.0,
//                           ),
//                         ],),   margin: EdgeInsets.only(top: 6,bottom: 6,right: 2,left: 2), child: Row(
//                         mainAxisAlignment: MainAxisAlignment
//                             .spaceBetween,
//                         children: <Widget>[
//                           SizedBox(
//                             height: 25.0,
//                             width: 25.0,
//
//                             child: Container(
//                               padding: const EdgeInsets.all(6),
//                               child: Image.asset(
//                                   Images.setroom, height: 20,
//                                   color: Theme.of(context).primaryColor,
//                                   width: 20),
//                             ),
//                           ),
//                           Container(
//                             margin: const EdgeInsets.only(left: 10.0),
//                             child: estate
//                                 .property![index]
//                                 .number!=0?Text("${estate
//                                 .property![index]
//                                 .number} صالات ",style: robotoRegular.copyWith(
//                                 fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)):Text("الصالات 0",style: robotoBlack.copyWith(fontSize: 9,)),
//                           )
//                         ],
//                       ),):Container();
//
//
//
//
//                     },
//                   ),
//                 ),
//               ):Container():   Container(),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//
//   String formatPrice(String priceStr) {
//     final num? price = num.tryParse(priceStr); // في حال لم يكن رقمًا صالحًا
//
//     if (price! >= 1000000) {
//       return "${(price / 1000000).toStringAsFixed(1)} مليون";
//     } else if (price >= 1000) {
//       return "${(price / 1000).toStringAsFixed(1)} ألف";
//     } else {
//       return price.toString();
//     }
//   }
//
//
// }


class PropertyCard extends StatelessWidget {
  final Estate estate;

  const PropertyCard(this.estate, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.dialog(DettailsDilog(estate: estate));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section with overlays
            _buildImageSection(context),

            // Property details section
            _buildPropertyDetails(context),

            // Property features section
            if (estate.category != "5" && estate.property != null)
              _buildPropertyFeatures(context),
          ],
        ),
      ),
    );
  }

  // Image section with overlays
  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Property image
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: CustomImage(
            image: estate.images != null && estate.images!.isNotEmpty
                ? "${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${estate.images![0]}"
                : null,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 180,
            placeholder: "assets/image/logo.png",
          ),
        ),

        // Favorite button
        Positioned(
          top: 12,
          right: 12,
          child: _buildFavoriteButton(context),
        ),

        // Offer badge
        if (estate.serviceOffers!.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            child: _buildOfferBadge(context),
          ),

        // 3D Tour badge
        if (estate.arPath != null)
          Positioned(
            bottom: 12,
            left: 12,
            child: _build3DTourBadge(context),
          ),
      ],
    );
  }

  // Favorite button
  Widget _buildFavoriteButton(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GetBuilder<WishListController>(
        builder: (wishController) {
          return IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              wishController.wishRestIdList.contains(estate.id)
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: wishController.wishRestIdList.contains(estate.id)
                  ? Colors.red
                  : Colors.grey,
              size: 20,
            ),
            onPressed: () {
              if (Get.find<AuthController>().isLoggedIn()) {
                wishController.wishRestIdList.contains(estate.id)
                    ? wishController.removeFromWishList(estate.id!)
                    : wishController.addToWishList(estate, false);
              } else {
                showCustomSnackBar('you_are_not_logged_in'.tr);
              }
            },
          );
        },
      ),
    );
  }

  // Offer badge
  Widget _buildOfferBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.orange,
      ),
      child: Text(
        "it_includes_offers".tr,
        style: robotoRegular.copyWith(
          fontSize: 12,
          color: Colors.white,
        ),
      ),
    );
  }

  // 3D Tour badge
  Widget _build3DTourBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black.withOpacity(0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            estate.serviceOffers!.isEmpty ? Images.vt : Images.vt_offer,
            height: 16,
            width: 16,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            "3D",
            style: robotoRegular.copyWith(
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Property details section
  Widget _buildPropertyDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price and views row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    estate.categoryName == "ارض"
                        ? formatPrice(estate.totalPrice!)
                        : formatPrice(estate.price!),
                    style: robotoBlack.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "currency".tr,
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.blue.withOpacity(0.1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${estate.view}",
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.remove_red_eye_outlined,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ],
                ),
              ),


            ],
          ),

          const SizedBox(height: 8),

          // Property title
          Text(
            estate.title!,
            style: robotoRegular.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // Location and license row
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 14,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  estate.title!,
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),



              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.15),
                      Colors.blue.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.campaign_rounded, // You can choose another icon
                      color: Colors.blue,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      estate?.advertisementType ?? "",
                      style: robotoRegular.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue.shade700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              )

            ],
          ),

          const SizedBox(height: 4),

          // License number
          Row(
            children: [
              Text(
                "رقم رخصة الإعلان: ",
                style: robotoMedium.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Text(
                estate.adLicenseNumber!,
                style: robotoMedium.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),

          // Short description for land category
          if (estate.category == "5")
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                estate.shortDescription!,
                style: robotoRegular.copyWith(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // Property features section
  Widget _buildPropertyFeatures(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: estate.property!.length,
          separatorBuilder: (context, index) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final property = estate.property![index];
            if (property.number == 0) return const SizedBox.shrink();

            return _buildFeatureChip(
              context,
              icon: _getFeatureIcon(property!.name),
              label: _getFeatureLabel(property.name, property!.number),
            );
          },
        ),
      ),
    );
  }

  // Feature chip
  Widget _buildFeatureChip(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: 12,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // Get appropriate icon for feature
  IconData _getFeatureIcon(String? featureName) {
    switch (featureName) {
      case "حمام":
        return Icons.bathtub;
      case "مطبخ":
      case "مطلبخ":
        return Icons.kitchen;
      case "غرف نوم":
        return Icons.bed;
      case "صلات":
        return Icons.weekend;
      default:
        return Icons.home;
    }
  }

  // Format feature label
  String _getFeatureLabel(String ?featureName, String  ? number) {
    switch (featureName) {
      case "حمام":
        return "$number حمام";
      case "مطبخ":
      case "مطلبخ":
        return "$number مطبخ";
      case "غرف نوم":
        return "$number غرف نوم";
      case "صلات":
        return "$number صالات";
      default:
        return "$number $featureName";
    }
  }

  // Format price
  String formatPrice(String priceStr) {
    final num? price = num.tryParse(priceStr);

    if (price! >= 1000000) {
      return "${(price / 1000000).toStringAsFixed(1)} مليون";
    } else if (price >= 1000) {
      return "${(price / 1000).toStringAsFixed(1)} ألف";
    } else {
      return price.toString();
    }
  }
}