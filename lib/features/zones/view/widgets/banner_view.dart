import 'package:abaad_flutter/features/home/controller/banner_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ملاحظة: نفس اسم الكلاس (BannerView) وكل المنطق الأصلي — الإضافة هنا:
/// عنوان كل بانر (title) يظهر الآن فوق الصورة بتصميم واضح (تدرّج لوني +
/// ظل نص)، بدل عرض الصورة مجردة بدون أي نص. العنوان يُقرأ من
/// bannerDataList بنفس index الصورة (بعد إصلاح BannerController ليبقيا
/// متوافقين).
class BannerView extends StatelessWidget {
  const BannerView({super.key});

  /// يستخرج نص العنوان من كائن البانر (Banner أو BasicCampaignModel) بشكل
  /// آمن تمامًا — لو الكائن مش عنده حقل title لأي سبب، يرجع نص فاضي بدل
  /// أي كراش.
  String _extractTitle(dynamic item) {
    try {
      final dynamic value = item?.title;
      if (value is String) return value.trim();
      return '';
    } catch (_) {
      return '';
    }
  }

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
                final String imageUrl =
                    '$baseUrl/${bannerController.bannerImageList![index]}';

                final dynamic bannerData =
                (bannerController.bannerDataList != null &&
                    index < bannerController.bannerDataList!.length)
                    ? bannerController.bannerDataList![index]
                    : null;
                final String title = _extractTitle(bannerData);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomImage(
                      image: imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),

                    // 🔹 تدرّج لوني في أسفل الصورة عشان النص يبان واضح
                    // بغض النظر عن ألوان الصورة خلفه.
                    if (title.isNotEmpty)
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.15),
                                Colors.black.withOpacity(0.72),
                              ],
                              stops: const [0.0, 0.55, 1.0],
                            ),
                          ),
                        ),
                      ),

                    // 🔹 نص العنوان نفسه — خط عريض أبيض بظل واضح، مع
                    // شريط رفيع ملوّن جنبه كعنصر تصميمي بسيط.
                    if (title.isNotEmpty)
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 3,
                              height: 22,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black87,
                                      blurRadius: 6,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
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