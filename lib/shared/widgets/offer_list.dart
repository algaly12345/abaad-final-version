import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/features/map/view/widgets/service_offer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/utils/images.dart';

class OfferList extends StatefulWidget {
  final Estate? estate;

  const OfferList({Key? key, this.estate}) : super(key: key);

  @override
  State<OfferList> createState() => _OfferListState();
}

class _OfferListState extends State<OfferList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'offers'.tr),
      body: widget.estate?.serviceOffers != null && widget.estate!.serviceOffers!.isNotEmpty
          ? ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: widget.estate!.serviceOffers!.length,
        itemBuilder: (context, index) {
          final offer = widget.estate!.serviceOffers![index];
          return _OfferCard(
            offer: offer,
            index: index,
            onWhatsAppTap: () async {
              final phoneNumber = offer.phoneProvider;
              final estateId = widget.estate?.id;
              final estateUrl = '${AppConstants.BASE_URL}/details/$estateId';
              final message = Uri.encodeComponent(
                "عرض داخل العقار مقدم من منصة أبعاد\n$estateUrl",
              );
              final url = "https://wa.me/$phoneNumber?text=$message";

              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("لا يمكن فتح واتساب")),
                );
              }
            },
            onCallTap: () => openDialPad(offer.phoneProvider ?? ""),
          );
        },
      )
          : Center(
        child: Text(
          'لا توجد عروض متاحة',
          style: robotoRegular.copyWith(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  openDialPad(String phoneNumber) async {
    Uri url = Uri(scheme: "tel", path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لا يمكن فتح لوحة الاتصال")),
      );
    }
  }
}

class _OfferCard extends StatelessWidget {
  final ServiceOffers offer;
  final int index;
  final VoidCallback onWhatsAppTap;
  final VoidCallback onCallTap;

  const _OfferCard({
    required this.offer,
    required this.index,
    required this.onWhatsAppTap,
    required this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with image, title and provider info
          Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GetBuilder<SplashController>(
                    builder: (splashController) {
                      final baseUrl = Get.find<SplashController>().configModel?.baseUrls?.provider ?? "";
                      return CustomImage(
                        image: '$baseUrl/${offer.image}',
                        fit: BoxFit.cover,
                        height: 60,
                        width: 60,
                      );
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer.title ?? '',
                        style: robotoBold.copyWith(
                          fontSize: 14,
                          color: Colors.red,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      _buildPriceSection(),
                      SizedBox(height: 8),
                      // Provider information
                      if (offer.provider_name != null && offer.provider_name!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: Colors.blue),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                offer.provider_name ?? '',
                                style: robotoRegular.copyWith(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      if (offer.phoneProvider != null && offer.phoneProvider!.isNotEmpty)
                        Row(
                          children: [
                            Icon(Icons.phone, size: 14, color: Colors.green),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                offer.phoneProvider ?? '',
                                style: robotoRegular.copyWith(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.paddingSizeDefault,
            ),
            child: Text(
              offer.description ?? '',
              style: robotoRegular.copyWith(
                fontSize: 12,
                color: Colors.black54,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Expiry date
          if (offer.expiryDate != null && offer.expiryDate!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeDefault,
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.red),
                  SizedBox(width: 6),
                  Text(
                    'expiry_date'.tr,
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    offer.expiryDate ?? '',
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

          // Contact buttons
          Padding(
            padding: EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Row(
              children: [
                Expanded(
                  child: _ContactButton(
                    icon: Icons.whatshot_rounded,
                    label: 'واتساب',
                    color: Colors.green,
                    onTap: onWhatsAppTap,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _ContactButton(
                    icon: Icons.call,
                    label: 'إتصال',
                    color: Colors.blue,
                    onTap: onCallTap,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    return Row(
      children: [
        if (offer.discount != null && offer.discount!.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(Icons.percent, size: 12, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  "${offer.discount}%",
                  style: robotoBold.copyWith(
                    fontSize: 11,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        if (offer.discount != null && offer.discount!.isNotEmpty) SizedBox(width: 8),
        if (offer.servicePrice != null && offer.servicePrice!.isNotEmpty)
          Text(
            "${offer.servicePrice} ريال",
            style: robotoBold.copyWith(
              fontSize: 12,
              color: Colors.black87,
            ),
          ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 6),
            Text(
              label,
              style: robotoMedium.copyWith(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}