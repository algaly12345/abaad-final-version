
import 'package:abaad_flutter/controller/banner_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/theme_controller.dart';
import 'package:abaad_flutter/data/model/response/basic_campaign_model.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/product_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WebBannerView extends StatelessWidget {
  final BannerController bannerController;
  const WebBannerView({super.key, required this.bannerController});

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    return Container(
      color: Color(0xFF171A29),
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      alignment: Alignment.center,
      child: SizedBox(width: 1210, height: 220, child: bannerController.bannerImageList != null ? Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [

          Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
            child: PageView.builder(
              controller: pageController,
              itemCount: (bannerController.bannerImageList!.length/2).ceil(),
              itemBuilder: (context, index) {
                int index1 = index * 2;
                int index2 = (index * 2) + 1;
                bool hasSecond = index2 < bannerController.bannerImageList!.length;
                String? baseUrl1 = bannerController.bannerDataList?[index1] is BasicCampaignModel ? Get.find<SplashController>()
                    .configModel?.baseUrls?.banners : Get.find<SplashController>().configModel?.baseUrls?.banners;
                String baseUrl2 = '';

                if (hasSecond) {
                  final item = bannerController.bannerDataList?[index2];

                  if (item is BasicCampaignModel) {
                    baseUrl2 = Get.find<SplashController>().configModel?.baseUrls?.banners ?? '';
                  } else {
                    baseUrl2 = Get.find<SplashController>().configModel?.baseUrls?.banners ?? '';
                  }
                }
                return Row(children: [

                  Expanded(child: InkWell(
                    onTap: () => _onTap(index1, context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      child: CustomImage(
                        image: '$baseUrl1/${bannerController.bannerImageList?[index1]}', fit: BoxFit.cover, height: 220,
                      ),
                    ),
                  )),

                  SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

                  Expanded(child: hasSecond ? InkWell(
                    onTap: () => _onTap(index2, context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      child: CustomImage(
                        image: '$baseUrl2/${bannerController.bannerImageList?[index2]}', fit: BoxFit.cover, height: 220,
                      ),
                    ),
                  ) : SizedBox()),

                ]);
              },
              onPageChanged: (int index) => bannerController.setCurrentIndex(index, true),
            ),
          ),

          bannerController.currentIndex != 0 ? Positioned(
            top: 0, bottom: 0, left: 0,
            child: InkWell(
              onTap: () => pageController.previousPage(duration: Duration(seconds: 1), curve: Curves.easeInOut),
              child: Container(
                height: 40, width: 40, alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Theme.of(context).cardColor,
                ),
                child: Icon(Icons.arrow_back),
              ),
            ),
          ) : SizedBox(),

          bannerController.currentIndex != ((bannerController.bannerImageList!.length/2).ceil()-1) ? Positioned(
            top: 0, bottom: 0, right: 0,
            child: InkWell(
              onTap: () => pageController.nextPage(duration: Duration(seconds: 1), curve: Curves.easeInOut),
              child: Container(
                height: 40, width: 40, alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Theme.of(context).cardColor,
                ),
                child: Icon(Icons.arrow_forward),
              ),
            ),
          ) : SizedBox(),

        ],
      ) : WebBannerShimmer(bannerController: bannerController)),
    );
  }

  void _onTap(int index, BuildContext context) {
    if(bannerController.bannerDataList?[index] is Estate) {
      Estate product = bannerController.bannerDataList?[index];
      ResponsiveHelper.isMobile(context) ? showModalBottomSheet(
        context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
        builder: (con) => ProductBottomSheet(product: product),
      ) : showDialog(context: context, builder: (con) => Dialog(
          child: ProductBottomSheet(product: product)),
      );
    }else if(bannerController.bannerDataList?[index] is Estate) {
      Estate restaurant = bannerController.bannerDataList?[index];
      // Get.toNamed(
      //   RouteHelper.getRestaurantRoute(_restaurant.id),
      //   arguments: RestaurantScreen(restaurant: _restaurant),
      // );
    }else if(bannerController.bannerDataList?[index] is BasicCampaignModel) {
      BasicCampaignModel campaign = bannerController.bannerDataList?[index];
      // Get.toNamed(RouteHelper.getBasicCampaignRoute(_campaign));
    }
  }
}

class WebBannerShimmer extends StatelessWidget {
  final BannerController bannerController;
  const WebBannerShimmer({super.key, required this.bannerController});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      duration: Duration(seconds: 2),
      enabled: bannerController.bannerImageList == null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_LARGE),
        child: Row(children: [

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
          )),

          SizedBox(width: Dimensions.PADDING_SIZE_LARGE),

          Expanded(child: Container(
            height: 220,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300]),
          )),

        ]),
      ),
    );
  }
}

