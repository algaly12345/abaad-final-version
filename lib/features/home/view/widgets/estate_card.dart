import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/details_dilog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PropertyCard extends StatelessWidget {
  final Estate estate;

  const PropertyCard(this.estate, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.dialog(DettailsDilog(estate: estate)),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              spreadRadius: 0,
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(context),
            _buildPropertyDetails(context),
            if (estate.category != "5" && estate.property != null)
              _buildPropertyFeatures(context),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        // Main image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: CustomImage(
            image: estate.images != null && estate.images!.isNotEmpty
                ? "${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${estate.images![0]}"
                : null,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 190,
            placeholder: "assets/image/logo.png",
          ),
        ),
        // Subtle bottom gradient for readability
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Favorite button
        Positioned(
          top: 12,
          right: 12,
          child: _buildFavoriteButton(context),
        ),
        // Offer badge
        if (estate.serviceOffers != null && estate.serviceOffers!.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            child: _buildBadge(
              label: "it_includes_offers".tr,
              color: const Color(0xFFE07B2A),
            ),
          ),
        // 3D Tour badge
        if (estate.arPath != null)
          Positioned(
            bottom: 10,
            left: 12,
            child: _build3DBadge(),
          ),
        // Advertisement type chip (bottom-right)
        if (estate.advertisementType != null &&
            estate.advertisementType!.isNotEmpty)
          Positioned(
            bottom: 10,
            right: 12,
            child: _buildBadge(
              label: estate.advertisementType!,
              color: Theme.of(context).primaryColor,
            ),
          ),
      ],
    );
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return GetBuilder<WishListController>(builder: (wishController) {
      final bool isWished = wishController.wishRestIdList.contains(estate.id);
      return GestureDetector(
        onTap: () {
          if (Get.find<AuthController>().isLoggedIn()) {
            isWished
                ? wishController.removeFromWishList(estate.id!)
                : wishController.addToWishList(estate, false);
          } else {
            showCustomSnackBar('you_are_not_logged_in'.tr);
          }
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isWished ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isWished ? Colors.red[400] : Colors.grey[400],
            size: 20,
          ),
        ),
      );
    });
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Tajawal',
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _build3DBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            estate.serviceOffers != null && estate.serviceOffers!.isEmpty
                ? Images.vt
                : Images.vt_offer,
            height: 14,
            width: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          const Text(
            "3D",
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    estate.categoryName == "ارض"
                        ? formatPrice(estate.totalPrice ?? "0")
                        : formatPrice(estate.price ?? "0"),
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "currency".tr,
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              // Views count
              Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined,
                      size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    "${estate.view ?? 0}",
                    style: TextStyle(
                      fontFamily: 'Tajawal',
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Title
          Text(
            estate.title ?? "",
            style: const TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Location row
          Row(
            children: [
              Icon(Icons.location_on_rounded,
                  size: 14, color: Theme.of(context).primaryColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  estate.title ?? "",
                  style: TextStyle(
                    fontFamily: 'Tajawal',
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Divider
          Divider(height: 1, color: Colors.grey[100]),
          const SizedBox(height: 8),
          // License number
          Row(
            children: [
              Icon(Icons.verified_outlined,
                  size: 13, color: Colors.grey[400]),
              const SizedBox(width: 4),
              Text(
                "رقم الإعلان: ",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  color: Colors.grey[500],
                ),
              ),
              Text(
                estate.adLicenseNumber ?? "",
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          // Short description for category 5
          if (estate.category == "5" &&
              estate.shortDescription != null &&
              estate.shortDescription!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                estate.shortDescription!,
                style: TextStyle(
                  fontFamily: 'Tajawal',
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPropertyFeatures(BuildContext context) {
    final features = estate.property!
        .where((p) => p.number != null && p.number.toString() != '0')
        .toList();
    if (features.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: features.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final prop = features[index];
            return _buildFeatureChip(
              context,
              icon: _getFeatureIcon(prop.name),
              label: _getFeatureLabel(prop.name, prop.number?.toString()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context,
      {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Theme.of(context).primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Tajawal',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFeatureIcon(String? name) {
    switch (name) {
      case "حمام":
        return Icons.bathtub_outlined;
      case "مطبخ":
      case "مطلبخ":
        return Icons.kitchen_outlined;
      case "غرف نوم":
        return Icons.bed_outlined;
      case "صلات":
        return Icons.weekend_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  String _getFeatureLabel(String? name, String? number) {
    switch (name) {
      case "حمام":
        return "$number حمام";
      case "مطبخ":
      case "مطلبخ":
        return "$number مطبخ";
      case "غرف نوم":
        return "$number غرف";
      case "صلات":
        return "$number صالة";
      default:
        return "$number $name";
    }
  }

  String formatPrice(String priceStr) {
    final num? price = num.tryParse(priceStr);
    if (price == null) return priceStr;
    if (price >= 1000000) {
      return "${(price / 1000000).toStringAsFixed(1)} مليون";
    } else if (price >= 1000) {
      return "${(price / 1000).toStringAsFixed(1)} ألف";
    }
    return price.toString();
  }
}
