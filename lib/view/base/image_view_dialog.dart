import 'package:abaad_flutter/controller/estate_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/theme_controller.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ImageViewDiloag extends StatelessWidget {
  Estate? estate;
   ImageViewDiloag({super.key, this.estate});

  @override
  Widget build(BuildContext context) {
      return GetBuilder<EstateController>(builder: (estateController) {
      return (estate?.planned!= null) ?
    Container(


      padding: EdgeInsets.only(top: 2),
      child: (estate?.planned != null)  != null ? Stack(

        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:CarouselSlider.builder(

              options: CarouselOptions(
                viewportFraction: 1,
                autoPlay: true,
                height: 340 ,

                autoPlayInterval: Duration(seconds: 7),
                onPageChanged: (index, reason) {
                  estateController.setCurrentIndex(index, true);
                },
              ),
              itemCount:estate?.planned?.isEmpty ?? false ? 1 :  estate?.planned?.length,
              itemBuilder: (context, index, _) {
                String baseUrl = Get.find<SplashController>().configModel?.baseUrls?.estateImageUrl ?? "";
                //print("---------------anner----------$baseUrl");
                return GestureDetector(
                  onTap: (){


                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200]!, spreadRadius: 1, blurRadius: 5)],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                      child:  GetBuilder<SplashController>(builder: (splashController) {
                        return  CustomImage(
                          image: '$baseUrl/${estate?.planned?[index]}',
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


          Positioned(
            bottom: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: estate!.images!.asMap().entries.map((entry) {
                int index = entry.key;
                return TabPageSelectorIndicator(
                  backgroundColor: index == estateController.currentIndex
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).primaryColor.withOpacity(0.5),
                  borderColor: Theme.of(context).colorScheme.surface,
                  size: index == estateController.currentIndex ? 10 : 7,
                );
              }).toList(),
            ),
          ),

        ],
      ) : Shimmer(
        duration: Duration(seconds: 2),
        enabled: estate?.images == null,
        child: Container(margin: EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
        )),
      ),
    ) : const Center(child: CircularProgressIndicator());
    });
  }
}
