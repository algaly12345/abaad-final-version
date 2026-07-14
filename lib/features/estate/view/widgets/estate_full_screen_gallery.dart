import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

/// معرض صور بملء الشاشة لتفاصيل العقار (نمط بيوت): صور بالتمرير الأفقي +
/// أزرار دائرية عائمة (رجوع، مفضلة، مشاركة) + عداد الصورة الحالية. يوضع خلف
/// [DraggableScrollableSheet] في `estate_details.dart`.
class EstateFullScreenGallery extends StatefulWidget {
  final Estate estate;

  const EstateFullScreenGallery({super.key, required this.estate});

  @override
  State<EstateFullScreenGallery> createState() =>
      _EstateFullScreenGalleryState();
}

class _EstateFullScreenGalleryState extends State<EstateFullScreenGallery> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _share() {
    final link = 'https://app.abaadapp.sa/details/${widget.estate.id}';
    Share.share('${'check_this_property'.tr}: $link', subject: 'Abaad');
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.estate.images ?? [];
    final baseUrl =
        Get.find<SplashController>().configModel?.baseUrls?.estateImageUrl ??
        '';

    return Stack(
      fit: StackFit.expand,
      children: [
        images.isEmpty
            ? Container(
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.image_outlined,
                  size: 80,
                  color: Colors.grey.shade500,
                ),
              )
            : PageView.builder(
                controller: _pageController,
                itemCount: images.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) => CustomImage(
                  image: '$baseUrl/${images[index]}',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

        // تدرج أعلى الصورة لإبراز الأزرار العائمة
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 130,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _CircleIconButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Get.back(),
                    ),
                    const SizedBox(width: 10),
                    GetBuilder<WishListController>(
                      builder: (wishController) {
                        final isWished = wishController.wishRestIdList
                            .contains(widget.estate.id);
                        return _CircleIconButton(
                          icon: isWished
                              ? Icons.favorite
                              : Icons.favorite_border,
                          iconColor: isWished ? Colors.red : Colors.black87,
                          onTap: () {
                            if (!Get.find<AuthController>().isLoggedIn()) {
                              showCustomSnackBar('you_are_not_logged_in'.tr);
                              return;
                            }
                            isWished
                                ? wishController.removeFromWishList(
                                    widget.estate.id ?? 0,
                                  )
                                : wishController.addToWishList(
                                    widget.estate,
                                    false,
                                  );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _CircleIconButton(
                      icon: Icons.share_outlined,
                      onTap: _share,
                    ),
                  ],
                ),
                if (images.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex + 1}/${images.length}',
                      style: robotoMedium.copyWith(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.black87,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(icon, size: 19, color: iconColor),
        ),
      ),
    );
  }
}
