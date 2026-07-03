import 'package:abaad_flutter/features/home/controller/banner_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BannerView extends StatelessWidget {
  const BannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      if (bannerController.bannerImageList != null &&
          bannerController.bannerImageList!.isEmpty) {
        return const SizedBox();
      }

      return Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: bannerController.bannerImageList != null
                ? CarouselSlider.builder(
                    options: CarouselOptions(
                      height: 160,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      viewportFraction: 1.0,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayCurve: Curves.easeInOut,
                      onPageChanged: (index, reason) {
                        bannerController.setCurrentIndex(index, true);
                      },
                    ),
                    itemCount: bannerController.bannerImageList!.isEmpty
                        ? 1
                        : bannerController.bannerImageList!.length,
                    itemBuilder: (context, index, _) {
                      final String? baseUrl = Get.find<SplashController>()
                          .configModel
                          ?.baseUrls
                          ?.banners;
                      return CustomImage(
                        image:
                            '$baseUrl/${bannerController.bannerImageList![index]}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  )
                : Container(
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
          ),
          if (bannerController.bannerImageList != null &&
              bannerController.bannerImageList!.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  bannerController.bannerImageList!.length,
                  (index) {
                    final bool isActive =
                        index == bannerController.currentIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isActive ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: isActive
                            ? Theme.of(context).primaryColor
                            : Theme.of(context)
                                .primaryColor
                                .withValues(alpha: 0.25),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      );
    });
  }
}
