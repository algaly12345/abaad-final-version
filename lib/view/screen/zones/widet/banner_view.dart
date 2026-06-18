import 'package:abaad_flutter/controller/banner_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/theme_controller.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerView extends StatelessWidget {
  const BannerView({super.key});

  @override
  Widget build(BuildContext context) {

    return GetBuilder<BannerController>(builder: (bannerController) {
      return (bannerController.bannerImageList != null && bannerController.bannerImageList?.length == 0) ?
      SizedBox() :
      Container(
        width: MediaQuery.of(context).size.width,
        height: GetPlatform.isDesktop ? 500 : MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
        child: bannerController.bannerImageList != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: CarouselSlider.builder(
                options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: true,
                  disableCenter: true,
                  autoPlayInterval: Duration(seconds: 7),
                  onPageChanged: (index, reason) {
                    bannerController.setCurrentIndex(index, true);
                  },
                ),
                itemCount: bannerController.bannerImageList?.length == 0 ? 1 : bannerController.bannerImageList?.length,
                itemBuilder: (context, index, _) {
                  String? baseUrl = Get.find<SplashController>().configModel?.baseUrls?.banners;
                  print("---------------anner----------$baseUrl");
                  return InkWell(
                    onTap: (){

                      print("------${bannerController.bannerImageList?[index]}");;

                  //    showCustomSnackBar("${ bannerController.bannerImageList?.length}");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200 ]! , spreadRadius: 1, blurRadius: 5)],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        child: GetBuilder<SplashController>(builder: (splashController) {
                          return CustomImage(
                            image: '$baseUrl/${bannerController.bannerImageList?[index]}',
                            fit: BoxFit.cover,
                          );
                        },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: bannerController.bannerImageList!.map((bnr) {
                int? index = bannerController.bannerImageList?.indexOf(bnr);
                return TabPageSelectorIndicator(
                  backgroundColor: index == bannerController.currentIndex ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.5),
                  borderColor: Theme.of(context).colorScheme.surface,
                  size: index == bannerController.currentIndex ? 10 : 7,
                );
              }).toList(),
            ),
          ],
        ) : Shimmer(
          duration: Duration(seconds: 2),
          enabled: bannerController.bannerImageList == null,
          child: Container(margin: EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
            color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
          )),
        ),
      );
    });
  }

}

extension on Type {
  get grey => null;
}
