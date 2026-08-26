import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_button.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/features/estate/view/widgets/button_view.dart';
import 'package:abaad_flutter/features/estate/view/widgets/estate_image_view.dart';
import 'package:abaad_flutter/features/estate/view/widgets/service _provider_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:url_launcher/url_launcher.dart';

/// ملاحظة: تم الإبقاء على نفس أسماء الكلاسات الأصلية بالضبط
/// (EstateView, _EstateViewState, RadioModel) دون إضافة أي كلاس جديد،
/// وكل التحسينات البصرية أُضيفت كدوال مساعدة خاصة داخل _EstateViewState.
class EstateView extends StatefulWidget {
  final bool? fromView;
  final Estate? estate;

  const EstateView({super.key, required this.fromView, this.estate});

  @override
  State<EstateView> createState() => _EstateViewState();
}

class _EstateViewState extends State<EstateView> {
  List<RadioModel> sampleData = [];

  @override
  void initState() {
    super.initState();

    sampleData.add(RadioModel(1, false, 'images'.tr, Images.estate_images));
    sampleData.add(RadioModel(2, false, 'virtual_ture'.tr, Images.vt));
    sampleData.add(RadioModel(3, false, 'street_view'.tr, Images.street_view));
    sampleData.add(RadioModel(4, false, 'planned'.tr, Images.planed));
    sampleData.add(RadioModel(5, false, 'sky_view'.tr, Images.street_view));
    sampleData.add(RadioModel(6, false, 'video'.tr, Images.video));
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      List<int> zoneIndexList = [];
      if (authController.zoneList != null && authController.zoneIds != null) {
        for (int index = 0;
        index < (authController.zoneList?.length ?? 40);
        index++) {
          if (authController.zoneIds!
              .contains(authController.zoneList?[index].id)) {
            zoneIndexList.add(index);
          }
        }
      }

      final bool fromView = widget.fromView ?? false;

      final Widget content = SingleChildScrollView(
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          margin: EdgeInsets.zero,
          child: SizedBox(
            width: Dimensions.WEB_MAX_WIDTH,
            child: Padding(
              padding: EdgeInsets.all(fromView ? 0 : 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ============ بطاقة الصور + الشريط العلوي ============
                  // في وضع البطاقة المصغّرة (fromView=true): الشريط العلوي
                  // يأخذ مساحته الخاصة فوق الصورة كما كان.
                  // في وضع العرض الكامل (fromView=false, بعد الضغط على زر
                  // التكبير): الشريط العلوي يطفو فوق الصورة نفسها (overlay)
                  // بدل أن يدفعها للأسفل، حتى تبقى أزرار الرجوع/المشاركة
                  // ظاهرة دائمًا فوق الصورة الكبيرة.
                  Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius:
                      BorderRadius.circular(Dimensions.RADIUS_LARGE),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          offset: const Offset(0, 3),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: fromView
                        ? Column(
                      children: [
                        _buildTopBar(context),
                        _buildImageStack(context, fromView),
                      ],
                    )
                        : Stack(
                      children: [
                        _buildImageStack(context, fromView),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: _buildTopBar(context, floating: true),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                  // ============ صف أزرار العرض (صور/جولة/فيديو..) ============
                  _buildRadioRow(context),

                  const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                  // ============ عروض مزود الخدمة ============
                  (widget.estate?.serviceOffers?.isNotEmpty ?? false)
                      ? ServiceProivderView(
                    estate: widget.estate!,
                    fromView: fromView,
                  )
                      : Container(),

                  if (!fromView) ...[
                    const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        buttonText: 'back'.tr,
                        onPressed: () => Get.back(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );

      // في وضع العرض الكامل (fromView=false) يُفتح هذا الودجت كصفحة مستقلة
      // عبر Get.to(...) بدون Scaffold خاص به، فيظهر فوق خلفية Material
      // الافتراضية (سوداء) بدل خلفية التطبيق. لذلك نُغلّفه هنا بـ Scaffold
      // بخلفية متناسقة. أما في وضع البطاقة المصغّرة (fromView=true) فيبقى
      // الودجت كما هو، لأنه مُضمّن أصلًا داخل صفحة تملك Scaffold خاصًا بها.
      if (fromView) return content;

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(child: content),
      );
    });
  }

  /// الشريط العلوي: زر الرجوع + عدّاد المشاهدات + زر المشاركة.
  ///
  /// [floating] عند true يُرسم الشريط كطبقة عائمة فوق الصورة (خلفية داكنة
  /// متدرّجة بدل خلفية البطاقة) بدل أن يأخذ مساحة خاصة به فوقها — يُستخدم
  /// في وضع العرض الكامل بعد الضغط على زر التكبير حتى لا تختفي/تُدفع هذه
  /// العناصر لأعلى الشاشة بشكل منفصل عن الصورة.
  Widget _buildTopBar(BuildContext context, {bool floating = false}) {
    final Color iconBg =
    floating ? Colors.white.withOpacity(0.18) : Theme.of(context).primaryColor.withOpacity(0.08);
    final Color iconColor = floating ? Colors.white : Theme.of(context).primaryColor;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.PADDING_SIZE_SMALL,
      ),
      decoration: floating
          ? BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.55),
            Colors.transparent,
          ],
        ),
      )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زر الرجوع
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Get.back(),
            child: Container(
              height: 32,
              width: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: iconColor,
              ),
            ),
          ),

          // عدّاد المشاهدات + زر المشاركة
          Row(
            children: [
              _buildChip(
                context,
                icon: Icons.remove_red_eye_outlined,
                label: "${widget.estate?.view ?? 0} ${'views'.tr}",
                floating: floating,
              ),
              const SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final String estateLink =
                      'https://app.abaadapp.sa/details/${widget.estate?.id}';
                  final String message = 'شاهد هذا العقار: $estateLink';

                  final Uri whatsappUrl = Uri.parse(
                      "https://wa.me/?text=${Uri.encodeComponent(message)}");

                  if (await canLaunchUrl(whatsappUrl)) {
                    await launchUrl(whatsappUrl,
                        mode: LaunchMode.externalApplication);
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("لا يمكن فتح واتساب")),
                    );
                  }
                },
                child: Container(
                  height: 32,
                  width: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.share_rounded,
                    size: 17,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// شارة صغيرة (Chip) تُستخدم لعدّاد المشاهدات.
  ///
  /// [floating] عند true تُرسم بخلفية بيضاء شفافة ونص أبيض لتبقى مقروءة
  /// فوق أي صورة في وضع العرض العائم؛ وإلا تُرسم بالستايل الرمادي العادي.
  Widget _buildChip(
      BuildContext context, {
        required IconData icon,
        required String label,
        bool floating = false,
      }) {
    final Color bg = floating
        ? Colors.white.withOpacity(0.18)
        : Theme.of(context).disabledColor.withOpacity(0.08);
    final Color fg = floating
        ? Colors.white
        : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: robotoMedium.copyWith(
              fontSize: 11,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  /// كومة الصور: صورة/معرض العقار + زر تكبير + زر المفضّلة العائم.
  Widget _buildImageStack(BuildContext context, bool fromView) {
    return Container(
      height: fromView ? 340 : (context.height * 0.70),
      width: MediaQuery.of(context).size.width,
      clipBehavior: Clip.antiAlias,
      decoration: const BoxDecoration(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          EstateImageView(
            estate_id: widget.estate?.id,
            fromView: widget.fromView,
          ),

          // تدرّج لوني خفيف أسفل الصورة لإبراز الأزرار العائمة — يظهر فقط
          // في وضع البطاقة المصغّرة، لأن وضع العرض الكامل أصبح له تدرّجه
          // الخاص ضمن الشريط العلوي العائم (_buildTopBar floating).
          if (fromView)
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 70,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.28),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

          if (fromView)
            Positioned(
              top: 12,
              right: 12,
              child: Column(
                children: [
                  _buildFloatingIconButton(
                    context,
                    icon: Icons.fullscreen_rounded,
                    onTap: () {
                      Get.to(EstateView(
                        fromView: false,
                        estate: widget.estate,
                      ));
                    },
                  ),
                  const SizedBox(height: 10),
                  GetBuilder<WishListController>(builder: (wishController) {
                    final bool isWished = wishController.wishRestIdList
                        .contains(widget.estate?.id);
                    return _buildFloatingIconButton(
                      context,
                      icon: isWished
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      iconColor: isWished
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).disabledColor,
                      onTap: () {
                        if (Get.find<AuthController>().isLoggedIn()) {
                          isWished
                              ? wishController
                              .removeFromWishList(widget.estate!.id ?? 0)
                              : wishController.addToWishList(
                              widget.estate!, false);
                        } else {
                          showCustomSnackBar('you_are_not_logged_in'.tr);
                        }
                      },
                    );
                  }),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// زر دائري عائم أبيض بظل خفيف، يُستخدم لأزرار التكبير والمفضّلة.
  Widget _buildFloatingIconButton(
      BuildContext context, {
        required IconData icon,
        required VoidCallback onTap,
        Color? iconColor,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).primaryColor,
          size: 19,
        ),
      ),
    );
  }

  /// صف أزرار طرق العرض (صور / جولة افتراضية / بانوراما شارع / مخطط / فيديو).
  Widget _buildRadioRow(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sampleData.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
            splashColor: Colors.blueAccent,
            onTap: () {
              setState(() {
                for (var element in sampleData) {
                  element.isSelected = false;
                }
                sampleData[index].isSelected = true;

                Get.toNamed(RouteHelper.getFeatureRoute(
                  widget.estate?.id ?? 0,
                  "${sampleData[index].id}",
                  widget.estate?.arPath ?? "",
                  widget.estate?.videoUrl ?? "",
                  widget.estate?.latitude ?? "",
                  widget.estate?.longitude ?? "",
                  widget.estate?.skyView ?? "",
                ));
              });
            },
            child: RadioItem(sampleData[index]),
          );
        },
      ),
    );
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
  final int id;
  final String text;

  RadioModel(this.id, this.isSelected, this.buttonText, this.text);
}