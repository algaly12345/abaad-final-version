
import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/wishlist_controller.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/button_view.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/estate_image_view.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/service%20_provider_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:url_launcher/url_launcher.dart';

class EstateView extends StatefulWidget {
  final bool? fromView;
  final Estate? estate;


  const EstateView({super.key, required this.fromView,this.estate});

  @override
  State<EstateView> createState() => _EstateViewState();
}

class _EstateViewState extends State<EstateView> {



  List<RadioModel> sampleData = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    sampleData.add( RadioModel(1,false, 'images'.tr, Images.estate_images));
    sampleData.add( RadioModel(2,false, 'virtual_ture'.tr, Images.vt));
    sampleData.add( RadioModel(3,false, 'street_view'.tr,Images.street_view));
    sampleData.add( RadioModel(4,false, 'planned'.tr, Images.planed));
    sampleData.add( RadioModel(5,false, 'sky_view'.tr, Images.street_view));
    sampleData.add( RadioModel(6,false, 'video'.tr, Images.video));
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<AuthController>(builder: (authController) {
      List<int> zoneIndexList = [];
      if(authController.zoneList != null && authController.zoneIds != null) {
        for(int index=0; index < (authController.zoneList?.length ?? 40); index++) {
          if(authController.zoneIds!.contains(authController.zoneList?[index].id)) {
            zoneIndexList.add(index);
          }
        }
      }

      return SingleChildScrollView(
        child: Card(
          // elevation: 2,
          child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Padding(
            padding: EdgeInsets.all((widget.fromView ?? false) ? 0 : 4),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, children: [
           //   const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),



              Padding(
                padding: const EdgeInsets.all(0.1),
                child: Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.grey,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 6.0,
                      ),
                    ], ),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            GestureDetector(
                              onTap: (){
                                Get.back();
                              },
                              child: Container(
                              height: 27,
                              width: 27,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4,left: 4),
                                child: Icon(Icons.arrow_back_ios,size: 23),
                              )),
                            ),
                              SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              Row(
                                children: [

                                  Icon(Icons.remove_red_eye_outlined),
                                  SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                                  Text("${widget.estate?.view}",style: robotoBlack.copyWith(fontSize: 11),),

                                  Text("views".tr,style: robotoBlack.copyWith(fontSize: 11),),
                                ],
                              ),
                              SizedBox(width: Dimensions.PADDING_SIZE_SMALL),

                              GestureDetector(
                                onTap: ()async {
                                  final String estateLink = 'https://app.abaadapp.sa/details/${widget.estate?.id}'; // ضع رابط العقار هنا
                                  final String message = 'شاهد هذا العقار: $estateLink';

                                  final Uri whatsappUrl = Uri.parse("https://wa.me/?text=${Uri.encodeComponent(message)}");

                                  if (await canLaunchUrl(whatsappUrl)) {
                                  await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                                  } else {
                                  // التعامل مع الخطأ
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                  content: Text("لا يمكن فتح واتساب"),
                                  ));
                                  }
                                },
                                  child: Icon(Icons.share, size: 23, color: Theme.of(context).textTheme.bodyLarge?.color)),
                            ]),
                      ),
                    Container(
                      height: (widget.fromView ?? false) ? 340 : (context.height * 0.70),

                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white,
                                offset: Offset(0.0, 1.0), //(x,y)
                                blurRadius: 6.0,
                              ),
                            ]

                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          child: Stack(clipBehavior: Clip.none, children: [
                               EstateImageView(estate_id: widget.estate?.id,fromView: widget.fromView,),
                            (widget.fromView ?? false) ? Positioned(
                              top: 10, right: 0,
                              child: InkWell(
                                onTap: () {
                                  Get.to(EstateView(fromView: false,estate: widget.estate,));
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      width: 30, height: 30,
                                      margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.white),
                                      child: Icon(Icons.fullscreen, color: Theme.of(context).primaryColor, size: 20),
                                    ),

                                    SizedBox(height: 10,),

                                    Container(
                                      width: 30, height: 30,
                                      margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.white),
                                      child:      GetBuilder<WishListController>(builder: (wishController) {
                                     //   bool _isWished =  wishController.wishRestList.contains(widget.EstateId);
                                        return InkWell(
                                          onTap: () {
                                            if(Get.find<AuthController>().isLoggedIn()) {
                                              wishController.wishRestIdList.contains(widget.estate?.id) ? wishController.removeFromWishList(widget.estate!.id ?? 0)
                                                  : wishController.addToWishList(widget.estate!, false);
                                            }else {
                                              showCustomSnackBar('you_are_not_logged_in'.tr);
                                            }
                                          },
                                            child: Icon(
                                              wishController.wishRestIdList.contains(widget.estate?.id ) ? Icons.favorite : Icons.favorite_border,
                                              color: wishController.wishRestIdList.contains(widget.estate?.id) ? Theme.of(context).primaryColor
                                                  : Theme.of(context).disabledColor,
                                            ),
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                            ) : SizedBox(),


                          ]),
                        ),
                      ) ,



                    ],
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
              SizedBox(
                height: 43   ,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: sampleData.length,
                  itemBuilder: (BuildContext context, int index) {
                    return  InkWell(
                      //highlightColor: Colors.red,
                      splashColor: Colors.blueAccent,
                      onTap: () {
                        setState(() {
                          for (var element in sampleData) {
                            element.isSelected = false;
                          }
                          sampleData[index].isSelected = true;
                          // if(sampleData[index].buttonText=="تجوال افتراضي"){
                          //   Get.toNamed(RouteHelper.getWebViewRoute(widget.estate.arPath));
                          // }else {
                            Get.toNamed(RouteHelper.getFeatureRoute(
                                widget.estate?.id ?? 0,
                                "${sampleData[index].id}",
                                widget.estate?.arPath ?? "" ,
                                widget.estate?.videoUrl ?? "",
                                widget.estate?.latitude ?? "",
                                widget.estate?.longitude ?? "",
                                widget.estate?.skyView ?? ""

                            ));
                          // }
                        });
                      },
                      child:RadioItem(sampleData[index]),
                    );
                  },
                ),
              ),

              (widget.estate?.serviceOffers?.isNotEmpty ?? false)?  ServiceProivderView(estate: widget.estate!,fromView: (widget.fromView ?? false)):Container(),



              !(widget.fromView ?? false) ? CustomButton(
                buttonText: 'back'.tr,
                onPressed: () {
               //   widget.mapController.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                  Get.back();
                },
              ) : SizedBox()

            ]),
          )),
        ),
      );
    });
  }
  //
  // buildDynamicLinks(String title,String image,String docId) async {
  //   String url = "https://abaadapp.page.link";
  //   final DynamicLinkParameters parameters = DynamicLinkParameters(
  //     uriPrefix: url,
  //     link: Uri.parse('$url/$docId'),
  //     androidParameters: AndroidParameters(
  //       packageName: "sa.pdm.abaad.abaad",
  //       minimumVersion: 0,
  //     ),
  //     iosParameters: IOSParameters(
  //       bundleId: "Bundle-ID",
  //       minimumVersion: '0',
  //     ),
  //     socialMetaTagParameters: SocialMetaTagParameters(
  //         description: '',
  //         imageUrl:
  //         Uri.parse(image),
  //         title: title),
  //   );
  //   // final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
  //
  //   // 1. Get FirebaseDynamicLinks instance
  //   final dynamicLinks = FirebaseDynamicLinks.instance;
  //
  //   // 2. Build short link
  //   final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(
  //     parameters,  // Your DynamicLinkParameters object
  //   );
  //
  //   // 3. Get the URL
  //   final dynamicUrl = shortLink.shortUrl;
  //
  //   String desc = dynamicUrl.toString();
  //
  //   await Share.share(desc, subject: title,);
  //
  // }
}
class RadioModel {
  bool isSelected;
  final String buttonText;
  final int id ;
  final String text;

  RadioModel(this.id,this.isSelected, this.buttonText, this.text);
}