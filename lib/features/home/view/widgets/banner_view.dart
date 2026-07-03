import 'package:abaad_flutter/features/home/controller/banner_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/controllers/theme_controller.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
class BannerView extends StatelessWidget {
  const BannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BannerController>(builder: (bannerController) {
      // Return empty if no banners
      if (bannerController.bannerImageList != null &&
          bannerController.bannerImageList!.isEmpty) {
        return const SizedBox();
      }

      return Container(
        width: MediaQuery.of(context).size.width,
        height: GetPlatform.isDesktop
            ? 500
            : MediaQuery.of(context).size.width * 0.4,
        padding: EdgeInsets.only(top: Dimensions.PADDING_SIZE_DEFAULT),
        child: bannerController.bannerImageList != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner carousel with enhanced design
            Expanded(
              child: Stack(
                children: [
                  // Main carousel
                  CarouselSlider.builder(
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      disableCenter: true,
                      autoPlayInterval: const Duration(seconds: 7),
                      viewportFraction: 0.9,
                      aspectRatio: 16/9,
                      enableInfiniteScroll: bannerController.bannerImageList!.length > 1,
                      onPageChanged: (index, reason) {
                        bannerController.setCurrentIndex(index, true);
                      },
                    ),
                    itemCount: bannerController.bannerImageList!.isEmpty
                        ? 1
                        : bannerController.bannerImageList!.length,
                    itemBuilder: (context, index, _) {
                      String baseUrl = Get.find<SplashController>()
                          .configModel!.baseUrls!.banners;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              Dimensions.RADIUS_SMALL),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Banner image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  Dimensions.RADIUS_SMALL),
                              child: GetBuilder<SplashController>(
                                builder: (splashController) {
                                  return CustomImage(
                                    image: '$baseUrl/${bannerController.bannerImageList![index]}',
                                    fit: BoxFit.cover,
                                  );
                                },
                              ),
                            ),

                            // Gradient overlay for better readability
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_SMALL),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),

                            // Touch area with ripple effect
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(
                                    Dimensions.RADIUS_SMALL),
                                onTap: () {
                                  // Handle banner tap
                                  _handleBannerTap(context, index);
                                },
                                splashColor: Colors.white.withOpacity(0.3),
                                highlightColor: Colors.white.withOpacity(0.1),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Side shadows for depth effect
                  if (bannerController.bannerImageList!.length > 1)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                Dimensions.RADIUS_SMALL),
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.black.withOpacity(0.1),
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

            // Enhanced indicators with animation
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildIndicators(context, bannerController),
              ),
            ),
          ],
        )
            : _buildShimmerEffect(context, bannerController), // MODIFIED: Pass controller here
      );
    });
  }

  // Build enhanced indicators
  List<Widget> _buildIndicators(BuildContext context, BannerController bannerController) {
    return bannerController.bannerImageList!.asMap().entries.map((entry) {
      int index = entry.key;
      bool isActive = index == bannerController.currentIndex;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isActive ? 24.0 : 8.0,
        height: 8.0,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).primaryColor.withOpacity(0.4),
          boxShadow: isActive
              ? [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.5),
              blurRadius: 4.0,
              spreadRadius: 1.0,
            )
          ]
              : null,
        ),
      );
    }).toList();
  }

  // CORRECTED: Shimmer effect using the original constructor
  Widget _buildShimmerEffect(BuildContext context, BannerController bannerController) {
    return Shimmer(
      duration: const Duration(seconds: 2),
      enabled: bannerController.bannerImageList == null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          color: Colors.grey[Get.find<ThemeController>().darkTheme ? 700 : 300],
        ),
      ),
    );
  }

  // Handle banner tap with navigation
  void _handleBannerTap(BuildContext context, int index) {
    // Add your navigation logic here
    // For example, navigate to a product page or open a web view
    HapticFeedback.lightImpact();

    // Example:
    // final banner = Get.find<BannerController>().bannerList[index];
    // if (banner.productId != null) {
    //   Get.toNamed(RouteHelper.getProductRoute(banner.productId));
    // } else if (banner.url != null && banner.url!.isNotEmpty) {
    //   Get.toNamed(RouteHelper.getHtmlRoute(banner.url));
    // }
  }
}