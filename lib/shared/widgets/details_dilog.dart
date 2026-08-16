import 'dart:convert';

import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_button.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/map_details_view.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:abaad_flutter/shared/widgets/offer_list.dart';
import 'package:abaad_flutter/features/estate/view/widgets/estate_view.dart';
import 'package:abaad_flutter/features/estate/view/widgets/interface.dart';
import 'package:abaad_flutter/features/estate/view/widgets/near_by_view.dart';
import 'package:abaad_flutter/features/estate/view/widgets/network_type.dart';
import 'package:abaad_flutter/features/estate/view/widgets/report_widget.dart';
import 'package:clipboard/clipboard.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:http/http.dart' as http;

import 'package:url_launcher/url_launcher.dart';

/// ملاحظة: تم الإبقاء على نفس أسماء الكلاسات (DettailsDilog، _DettailsDilogState)
/// وكل الدوال العامة الموجودة أصلًا في الملف الأصلي (buildInfoRow،
/// buildPhoneRow، buildInfoRowEnhanced، formatPrice، openDialPad) بدون حذف
/// أي منها. كل البيانات المعروضة سابقًا لا تزال معروضة بنفس القيم — التغيير
/// اقتصر على شكل العرض (بطاقات موحّدة، عناوين أقسام بأيقونات، شارات ملونة،
/// أزرار إجراءات دائرية أنيقة) دون حذف أي حقل.
class DettailsDilog extends StatefulWidget {
  Estate? estate;

  DettailsDilog({Key? key, this.estate}) : super(key: key);

  @override
  State<DettailsDilog> createState() => _DettailsDilogState();
}

/// لون الهوية الأساسي المستخدم في عناوين الأقسام (نفس اللون الكحلي
/// المستخدم أصلًا في التصميم القديم) — تم توحيده في متغير واحد بدل تكراره
/// كقيمة hex في عدة أماكن.
const Color kSectionColor = Color(0xFF2252A1);

/// عنصر بيانات صف واحد داخل جدول [_infoTable]: تسمية + قيمة، مع لون
/// اختياري للقيمة (يُستخدم لصف "تاريخ إنتهاء الترخيص" الملوّن أحمر/أخضر).
class _InfoRowData {
  final String label;
  final String value;
  final Color? valueColor;

  _InfoRowData(this.label, this.value, {this.valueColor});
}

class _DettailsDilogState extends State<DettailsDilog> {
  bool? _isLoggedIn;
  String? like;

  Future<bool> validateAdvertisement({
    required String adLicenseNumber,
    required String advertiserId,
    required String idType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          'https://app.abaadapp.sa/api/v1/banners/advertisement/validate',
        ),
        body: {
          'adLicenseNumber': adLicenseNumber,
          'advertiserId': advertiserId,
          'idType': idType,
        },
      );

      final body = jsonDecode(response.body);
      return body['success'] == true;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    if (widget.estate?.userId != null) {
      Get.find<UserController>().getUserInfoByID(widget.estate!.userId!);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final isValid = await validateAdvertisement(
        adLicenseNumber: widget.estate?.adLicenseNumber ?? "",
        advertiserId: widget.estate?.identityUnified ?? "",
        idType: widget.estate?.estate_type ?? "",
      );

      if (!isValid && mounted) {
        showInvalidAdDialog();
      }
    });
  }

  void showInvalidAdDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 60,
                ),
                SizedBox(height: 12),
                Text(
                  "تنبيه",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: const Text(
              "لا يمكن عرض تفاصيل هذا العقار لأن الإعلان غير صالح أو منتهي.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, height: 1.6),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back),
                label: const Text("رجوع"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lat = double.tryParse(widget.estate?.latitude ?? '');
    final lng = double.tryParse(widget.estate?.longitude ?? '');

    if (lat == null || lng == null) {
      return const Center(child: Text("الموقع غير متوفر"));
    }

    final currentLocale = Get.locale;
    final bool isArabic = currentLocale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        child: widget.estate == null
            ? const SizedBox()
            : Column(
          children: [
            EstateView(fromView: true, estate: widget.estate!),

            // ============ بطاقة العنوان + السعر + الوصف ============
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _categoryChip(context, isArabic),
                  const SizedBox(height: 10),
                  _priceRow(context),
                  const SizedBox(height: 16),
                  _subHeader('shot_description'.tr, Icons.short_text),
                  const SizedBox(height: 6),
                  Text(
                    widget.estate?.shortDescription ?? '',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _subHeader('long_description'.tr, Icons.notes_rounded),
                  const SizedBox(height: 6),
                  Text(
                    widget.estate?.longDescription ?? '',
                    style: robotoRegular.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ============ بطاقة المرافق + معلومات الإعلان + الحدود ============
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subHeader('it_contains'.tr, Icons.category_rounded),
                  const SizedBox(height: 10),
                  widget.estate?.category != "5"
                      ? _propertyFeaturesRow(context)
                      : const SizedBox(),
                  const SizedBox(height: 4),
                  const Divider(height: 24),

                  _sectionBanner("معلومات الإعلان", Icons.campaign_rounded),
                  const SizedBox(height: 10),

                  _infoTable(context, [
                    _InfoRowData("advertisement_type".tr,
                        widget.estate?.advertisementType ?? ""),
                    _InfoRowData(
                        "استخدام العقار", widget.estate?.propertyUsages ?? ""),
                    _InfoRowData("نوع وثيقة الملكية".tr,
                        widget.estate?.titleDeedTypeName ?? ""),
                    _InfoRowData("ad_license_number".tr,
                        widget.estate?.adLicenseNumber ?? ""),
                    _InfoRowData("تاريح ترخيص الإعلان",
                        widget.estate?.creationDate ?? ""),
                    _InfoRowData(
                      "تاريخ إنتهاء ترخيص الإعلان",
                      widget.estate?.endDate ?? "",
                      valueColor: (DateTime.tryParse(
                          widget.estate?.endDate ?? "")
                          ?.isBefore(DateTime.now()) ??
                          false)
                          ? Colors.red
                          : Colors.green,
                    ),
                    if (widget.estate?.categoryName != null)
                      _InfoRowData(
                          "نوع العقار".tr, widget.estate?.categoryName ?? ""),
                    _InfoRowData(
                        "plan_number".tr, widget.estate?.planNumber ?? ""),
                    if (widget.estate?.property_type != "ارض" &&
                        widget.estate?.ageEstate != null)
                      _InfoRowData("age_of_the_property".tr,
                          widget.estate?.ageEstate ?? ""),
                    if (widget.estate?.guaranteesAndTheirDuration != null)
                      _InfoRowData("الضمانات ",
                          widget.estate?.guaranteesAndTheirDuration ??
                              "لا يوجد"),
                    if (widget.estate?.mainLandUseTypeName != null)
                      _InfoRowData("استخدام العقار".tr,
                          widget.estate?.mainLandUseTypeName ?? ""),
                    if (widget.estate?.landNumber != null)
                      _InfoRowData(
                          "رقم القطعة", widget.estate?.landNumber ?? ""),
                    if (widget.estate?.numberOfRooms != null)
                      _InfoRowData(
                          "عدد الغرف", widget.estate?.numberOfRooms ?? ""),
                    if (widget.estate?.obligationsOnTheProperty != null &&
                        widget.estate?.obligationsOnTheProperty != "-")
                      _InfoRowData("الالتزامات ",
                          widget.estate?.obligationsOnTheProperty ?? ""),
                    if (widget.estate?.space != null)
                      _InfoRowData("space".tr, widget.estate?.space ?? ""),
                    _InfoRowData("property_face".tr,
                        widget.estate?.propertyFace ?? ""),
                    if (widget.estate?.propertyUtilities != null)
                      _InfoRowData("خدمات العقار".tr,
                          "${widget.estate?.propertyUtilities}"),
                    if (widget.estate?.locationDescriptionOnMOJDeed != null)
                      _InfoRowData(
                          "وصف العقار حسب الصك".tr,
                          widget.estate?.locationDescriptionOnMOJDeed ??
                              ""),
                    _InfoRowData("المنطقة", widget.estate?.zoneNameAr ?? ""),
                    _InfoRowData("المدينة", widget.estate?.city ?? ""),
                    _InfoRowData("الحي", widget.estate?.districts ?? ""),
                    if (widget.estate?.streetSpace != null)
                      _InfoRowData("width_street".tr,
                          widget.estate?.streetSpace ?? ""),
                    if (widget.estate?.documentNumber != null)
                      _InfoRowData("document_number".tr,
                          widget.estate?.documentNumber ?? ""),
                    if (widget.estate?.priceNegotiation != null)
                      _InfoRowData(
                          "price".tr,
                          widget.estate?.priceNegotiation == "قابل للتفاوض"
                              ? "negotiate".tr
                              : "non_negotiable".tr),
                    if (widget.estate?.buildSpace != null)
                      _InfoRowData("build_space".tr,
                          widget.estate?.buildSpace ?? ""),
                    if (widget.estate?.users?.name != null)
                      _InfoRowData("advertiser_phone".tr,
                          widget.estate?.users?.phone ?? ""),
                    if (widget.estate?.deedNumber != null)
                      _InfoRowData(
                          "deed_number".tr, widget.estate?.deedNumber ?? ""),
                    _InfoRowData(
                        "رقم رخصة فال".tr, widget.estate!.brokerageAndMarketingLicenseNumber ?? ""),
                  ]),

                  const SizedBox(height: 6),
                  _sectionBanner(
                      "معلومات حدود العقار", Icons.crop_square_rounded),
                  const SizedBox(height: 10),

                  _infoTable(context, [
                    if (widget.estate?.northLimit != null)
                      _InfoRowData(
                          "الحد الشمالي", widget.estate?.northLimit ?? ""),
                    if (widget.estate?.southLimit != null)
                      _InfoRowData(
                          "الحد الجنوبي", widget.estate?.southLimit ?? ""),
                    if (widget.estate?.eastLimit != null)
                      _InfoRowData(
                          "الحد الشرقي", widget.estate?.eastLimit ?? ""),
                    if (widget.estate?.westLimit != null)
                      _InfoRowData(
                          "الحد الغربي", widget.estate?.westLimit ?? ""),
                  ]),

                  (widget.estate?.networkType?.isNotEmpty ?? false)
                      ? NetworkTypeItem(
                    estate: widget.estate!,
                    restaurants: widget.estate!.networkType!,
                  )
                      : Container(),
                  widget.estate?.interface != null
                      ? InterfaceItem(
                    estate: widget.estate!,
                    restaurants: widget.estate?.interface!,
                  )
                      : Container(),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ============ بطاقة معلومات المعلن + رمز الاستجابة ============
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionBanner("معلومات المعلن", Icons.person_rounded),
                  const SizedBox(height: 14),

                  if (widget.estate?.advertiserName != null)
                    _advertiserFieldRow(
                      icon: Icons.person_rounded,
                      label: "اسم المعلن",
                      value: widget.estate!.advertiserName!,
                      trailing: widget.estate?.isValid != null
                          ? _statusBadge(widget.estate?.isValid)
                          : null,
                    ),

                  if (widget.estate?.advertiserName != null &&
                      widget.estate?.phoneNumber != null)
                    const SizedBox(height: 10),

                  if (widget.estate?.phoneNumber != null)
                    _advertiserFieldRow(
                      icon: Icons.phone_rounded,
                      label: "رقم الجوال",
                      value: widget.estate!.phoneNumber!,
                      trailing:
                      buildCallButton(widget.estate!.phoneNumber!),
                    ),

                  // في حال عدم وجود اسم المعلن أصلًا، تُعرض حالة
                  // الإعلان في صف مستقل حتى لا تُفقد هذه المعلومة.
                  if (widget.estate?.isValid != null &&
                      widget.estate?.advertiserName == null) ...[
                    if (widget.estate?.phoneNumber != null)
                      const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "حالة الإعلان",
                          style: robotoRegular.copyWith(
                            fontSize: Dimensions.fontSizeDefault,
                            color: Theme.of(context).disabledColor,
                          ),
                        ),
                        const Spacer(),
                        _statusBadge(widget.estate?.isValid),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 10),

            adLicenseQr(context),

            const SizedBox(height: 10),

            // ============ بطاقة الموقع على الخريطة ============
            _card(
              context,
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border:
                        Border.all(color: Colors.blueGrey.shade100),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.blue, size: 22),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "الموقع حسب الصك من وزارة العدل",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.estate
                                ?.locationDescriptionOnMOJDeed ??
                                "",
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                            textAlign: TextAlign.start,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.blue.shade100),
                            ),
                            child: const Text(
                              "نأمل مطابقة الموقع أدناه مع الموقع المذكور في وصف عنوان العقار المكتوب.",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.red,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                    margin: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Builder(
                      builder: (context) {
                        final lat =
                        double.tryParse(widget.estate?.latitude ?? '');
                        final lng = double.tryParse(
                            widget.estate?.longitude ?? '');

                        if (lat == null || lng == null) {
                          return const Center(
                            child: Text(
                              'خطأ في إحداثيات الموقع',
                              style: TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        return ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(lat, lng),
                              zoom: 16,
                            ),
                            markers: {
                              Marker(
                                markerId:
                                const MarkerId("estate_location"),
                                position: LatLng(lat, lng),
                                icon: BitmapDescriptor.defaultMarker,
                              ),
                            },
                            minMaxZoomPreference:
                            const MinMaxZoomPreference(5, 20),
                            zoomControlsEnabled: true,
                            compassEnabled: true,
                            indoorViewEnabled: false,
                            mapToolbarEnabled: true,
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomGesturesEnabled: true,
                            scrollGesturesEnabled: true,
                            tiltGesturesEnabled: true,
                            rotateGesturesEnabled: true,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ============ المزايا الإضافية ============
            if ((widget.estate?.otherAdvantages ?? []).isNotEmpty)
              _card(
                context,
                child: SizedBox(
                  height: 120,
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.estate!.otherAdvantages!.length,
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1 / 0.50,
                    ),
                    itemBuilder: (context, index) {
                      final advantage =
                      widget.estate!.otherAdvantages![index];
                      return InkWell(
                        child: Container(
                          margin: const EdgeInsets.all(
                              Dimensions.PADDING_SIZE_EXTRA_SMALL),
                          padding: const EdgeInsets.symmetric(
                            vertical:
                            Dimensions.PADDING_SIZE_EXTRA_SMALL,
                            horizontal: Dimensions.PADDING_SIZE_SMALL,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F6FB),
                            borderRadius: BorderRadius.circular(
                                Dimensions.RADIUS_SMALL),
                            border: Border.all(
                                color: kSectionColor.withOpacity(0.12)),
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  size: 16, color: kSectionColor),
                              const SizedBox(
                                  width: Dimensions
                                      .PADDING_SIZE_EXTRA_SMALL),
                              Flexible(
                                flex: 1,
                                child: Text(
                                  advantage.name ?? '',
                                  style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeLarge,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .color,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // ============ إجراءات إضافية (إبلاغ / قريب مني / عروض) ============
            _card(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _subHeader(
                      "other_information".tr, Icons.more_horiz_rounded),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          context,
                          icon: Icons.report_problem_rounded,
                          label: 'report_the_ad'.tr,
                          color: const Color(0xFFE8544A),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Get.find<AuthController>()
                                    .isLoggedIn()
                                    ? GetBuilder<EstateController>(
                                  builder: (wishController) {
                                    return ReportWidget(
                                      estate_id:
                                      widget.estate?.id ?? 0,
                                      key: null,
                                    );
                                  },
                                )
                                    : NotLoggedInScreen();
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          context,
                          icon: Icons.pin_drop_rounded,
                          label: 'near_by'.tr,
                          color: const Color(0xFF2E7DD1),
                          onTap: () {
                            Get.dialog(NearByView(
                              esate: widget.estate ?? Estate(),
                            ));
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _actionButton(
                          context,
                          icon: Icons.handshake_rounded,
                          label: 'deals_with_the_property'.tr,
                          color: const Color(0xFF8E5FD8),
                          onTap: () {
                            Get.dialog(OfferList(
                                estate: widget.estate ?? Estate()));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ============ أرقام قابلة للنسخ ============
            _card(
              context,
              child: Column(
                children: [
                  _copyableRow(
                    context,
                    label: 'رقم رخصة الإعلان',
                    value: widget.estate?.adLicenseNumber ?? "",
                  ),
                  const Divider(height: 20),
                  _copyableRow(
                    context,
                    label: 'رقم وثيقة الملكية'.tr,
                    value: widget.estate?.deedNumber ?? "",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ============ بطاقة المعلن (صورة + بيانات + زر تواصل) ============
            _card(
              context,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      Get.toNamed(RouteHelper.getProfileAgentRoute(
                          widget.estate?.users?.id ?? 0, 0));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(
                          Dimensions.PADDING_SIZE_SMALL),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9FC),
                        borderRadius: BorderRadius.circular(
                            Dimensions.RADIUS_SMALL),
                        border: Border.all(
                            color: kSectionColor.withOpacity(0.1)),
                      ),
                      child: Row(children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: kSectionColor.withOpacity(0.25),
                                width: 2),
                          ),
                          child: ClipOval(
                            child: CustomImage(
                              image:
                              '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                                  '/${widget.estate?.users?.image ?? ''}',
                              height: 90,
                              width: 90,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(
                            width: Dimensions.PADDING_SIZE_SMALL),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.estate?.users?.name ?? "",
                                style: robotoMedium.copyWith(
                                    fontSize: Dimensions.fontSizeDefault),
                              ),
                              const SizedBox(
                                  height: Dimensions
                                      .PADDING_SIZE_EXTRA_SMALL),
                              Row(children: [
                                Container(
                                  height: 25,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8),
                                  decoration: BoxDecoration(
                                    color: kSectionColor,
                                    borderRadius:
                                    BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Text(
                                      widget.estate?.users
                                          ?.membershipType ??
                                          '',
                                      style: robotoBold.copyWith(
                                        color: Colors.white,
                                        fontSize:
                                        Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.phone,
                                      size: 14,
                                      color: Theme.of(context)
                                          .disabledColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.estate?.users?.phone ?? "",
                                    style: robotoRegular.copyWith(
                                        fontSize:
                                        Dimensions.fontSizeLarge,
                                        color: Theme.of(context)
                                            .disabledColor),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.event_outlined,
                                      size: 14,
                                      color: Theme.of(context)
                                          .disabledColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.estate?.createdAt ?? "",
                                    style: robotoRegular.copyWith(
                                        fontSize:
                                        Dimensions.fontSizeDefault,
                                        color: Theme.of(context)
                                            .disabledColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      height: 44,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Get.find<AuthController>()
                                .isLoggedIn()
                                ? GetBuilder<EstateController>(
                              builder: (wishController) {
                                return ConctactWidget(
                                    widget.estate?.title ?? "",
                                    "",
                                    widget.estate
                                        ?.shortDescription ??
                                        "",
                                    widget.estate?.users?.phone ??
                                        "");
                              },
                            )
                                : NotLoggedInScreen();
                          },
                        );
                      },
                      buttonText: 'contact_the_advertiser'.tr,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // عناصر تصميم مشتركة (Design System) — دوال خاصة تُستخدم في كل الأقسام أعلاه
  // ==========================================================================

  /// بطاقة موحّدة (خلفية بيضاء + حواف دائرية + ظل ناعم) تُستخدم كإطار لكل
  /// قسم من أقسام الصفحة، بدل تكرار نفس الـ BoxDecoration في كل مكان.
  Widget _card(BuildContext context,
      {required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  /// عنوان قسم صغير بخط عريض وأيقونة (لعناوين مثل "الوصف القصير"،
  /// "يحتوي على"، "معلومات إضافية").
  Widget _subHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kSectionColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: robotoBold.copyWith(
            fontSize: Dimensions.fontSizeLarge,
            color: kSectionColor,
          ),
        ),
      ],
    );
  }

  /// شريط عنوان كامل العرض بخلفية كحلية (نفس الأقسام الرئيسية القديمة:
  /// "معلومات الإعلان"، "معلومات حدود العقار"، "معلومات المعلن") لكن الآن
  /// موحّد في دالة واحدة بدل تكرار نفس الكود ثلاث مرات، مع إضافة أيقونة.
  Widget _sectionBanner(String title, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: kSectionColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// شارة التصنيف/المنطقة/الحي/نوع الإعلان (نفس بيانات النص الأصلي بالضبط،
  /// isArabic يتحكم في الحقول المعروضة كما كان سابقًا).
  Widget _categoryChip(BuildContext context, bool isArabic) {
    final String text = isArabic
        ? "${widget.estate?.categoryNameAr} - ${widget.estate?.zoneNameAr} - ${widget.estate?.districts ?? ''} - ${widget.estate?.advertisementType}"
        : "${widget.estate?.categoryName} - ${widget.estate?.zoneName ?? ''}";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: kSectionColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_city_rounded,
              size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              textAlign: isArabic ? TextAlign.right : TextAlign.left,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// صف السعر (وسعر المتر/الإجمالي في حالة "أرض") — نفس منطق العرض الأصلي
  /// بالضبط، فقط بشكل شارات (Pills) مع أيقونة بدل صندوق مربع.
  Widget _priceRow(BuildContext context) {
    final bool isLand = widget.estate?.categoryName == "ارض";
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _pricePill(
          label: isLand ? "سعر المتر" : "price".tr,
          value: formatPrice(widget.estate?.price ?? "0"),
        ),
        if (isLand && widget.estate?.totalPrice != "undefined")
          _pricePill(
            label: "إجمالي السعر",
            value: formatPrice(widget.estate?.totalPrice ?? "0"),
          ),
      ],
    );
  }

  Widget _pricePill({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: kSectionColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: kSectionColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.payments_rounded, size: 14, color: kSectionColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: robotoRegular.copyWith(
              fontSize: Dimensions.fontSizeSmall,
              color: kSectionColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: robotoBold.copyWith(
              fontSize: Dimensions.fontSizeDefault,
              color: kSectionColor,
            ),
          ),
          const SizedBox(width: 2),
          Image.asset('assets/image/riyals.png',
              width: 14, height: 14, color: kSectionColor),
        ],
      ),
    );
  }

  /// صف المرافق الأفقي (حمام/مطبخ/غرف نوم/صالات) — نفس منطق العرض الأصلي
  /// حرفيًا (نفس شروط الأسماء العربية) بدون أي حذف، فقط مُستخرج في دالة
  /// مستقلة لتنظيم الكود.
  Widget _propertyFeaturesRow(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          itemCount: widget.estate?.property!.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return widget.estate != null
                ? widget.estate?.property![index].name == "حمام"
                ? _featureChip(
              context,
              icon: Images.bathroom,
              label: "bathroom".tr,
              count: widget.estate?.property![index].number ?? "",
            )
                : widget.estate!.property![index].name == "مطلبخ"
                ? _featureChip(
              context,
              icon: Images.kitchen,
              label: "kitchen".tr,
              count:
              widget.estate?.property![index].number ?? "",
            )
                : widget.estate!.property![index].name == "غرف نوم"
                ? _featureChip(
              context,
              icon: Images.bed,
              label: "bedrooms".tr,
              count:
              "${widget.estate?.property![index].number}",
            )
                : widget.estate!.property![index].name == "مطبخ"
                ? _featureChip(
              context,
              icon: Images.kitchen,
              label: "kitchen".tr,
              count:
              "${widget.estate?.property![index].number}",
            )
                : widget.estate!.property![index].name ==
                "صلات"
                ? _featureChip(
              context,
              icon: Images.setroom,
              label: "lounges".tr,
              count:
              "${widget.estate?.property![index].number}",
            )
                : Container()
                : Container();
          },
        ),
      ),
    );
  }

  Widget _featureChip(
      BuildContext context, {
        required String icon,
        required String label,
        required String count,
      }) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB),
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
        border: Border.all(color: kSectionColor.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(icon, height: 20, width: 20, color: kSectionColor),
          const SizedBox(width: 6),
          Text(label, style: robotoMedium.copyWith(fontSize: 12)),
          const SizedBox(width: 4),
          Text(" $count",
              style: robotoBold.copyWith(fontSize: 12, color: kSectionColor)),
        ],
      ),
    );
  }

  /// بطاقة إجراء (إبلاغ / قريب مني / عروض) — أيقونة داخل مربع دائري
  /// بلون مميّز لكل إجراء + تسمية أسفلها، داخل بطاقة خفيفة الخلفية بنفس
  /// اللون حتى تكون كل بطاقة مميّزة بصريًا عن الأخرى بدل الشكل الموحّد
  /// السابق (دوائر كحلية متطابقة).
  Widget _actionButton(
      BuildContext context, {
        required IconData icon,
        required String label,
        required VoidCallback onTap,
        required Color color,
      }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(fontSize: 11.5, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  /// صف نص قابل للنسخ (رقم رخصة الإعلان / رقم وثيقة الملكية) — نفس منطق
  /// FlutterClipboard.copy الأصلي بالضبط، فقط بشكل بصري موحّد.
  Widget _copyableRow(
      BuildContext context, {
        required String label,
        required String value,
      }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: robotoRegular.copyWith(
                  fontSize: 11,
                  color: Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: robotoBold.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            FlutterClipboard.copy(value).then((v) {
              showCustomSnackBar('copied'.tr, isError: false);
            });
          },
          icon: Icon(Icons.copy_rounded,
              color: Theme.of(context).primaryColor, size: 18),
        ),
      ],
    );
  }

  /// صف بيانات المعلن (اسم/جوال) بأيقونة دائرية ملوّنة على اليمين وتسمية
  /// صغيرة فوق القيمة — أنيق وواضح، ويقبل عنصرًا مُذيّلًا اختياريًا
  /// (زر اتصال أو شارة حالة).
  Widget _advertiserFieldRow({
    required IconData icon,
    required String label,
    required String value,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSectionColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kSectionColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kSectionColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: robotoBold.copyWith(fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  /// شارة ملوّنة لحالة الإعلان (ساري/ملغي) بأيقونة، تحل محل النص الملوّن
  /// البسيط السابق — تستخدم نفس دوال getAdStatusText/getAdStatusColor.
  Widget _statusBadge(String? isValid) {
    final Color color = getAdStatusColor(isValid);
    final String text = getAdStatusText(isValid);
    final bool active = isValid == "1";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: robotoBold.copyWith(fontSize: 11, color: color),
          ),
        ],
      ),
    );
  }

  /// جدول بيانات أنيق (Table حقيقي بخطوط فاصلة وصفوف متبادلة اللون) يعرض
  /// قائمة من [_InfoRowData] كصفوف: التسمية | القيمة | زر نسخ — وزر النسخ
  /// لا يظهر إلا إذا كانت القيمة تحتوي على رقم واحد على الأقل.
  Widget _infoTable(BuildContext context, List<_InfoRowData> items) {
    final List<_InfoRowData> visible =
    items.where((e) => e.value.trim().isNotEmpty).toList();

    if (visible.isEmpty) return const SizedBox();

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kSectionColor.withOpacity(0.15)),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FixedColumnWidth(38),
        },
        border: TableBorder(
          horizontalInside:
          BorderSide(color: kSectionColor.withOpacity(0.10)),
        ),
        children: List.generate(visible.length, (index) {
          final item = visible[index];
          final bool hasNumber = RegExp(r'[0-9٠-٩]').hasMatch(item.value);
          final bool isEven = index % 2 == 0;

          return TableRow(
            decoration: BoxDecoration(
              color: isEven ? Colors.white : const Color(0xFFF7F9FC),
            ),
            children: [
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Text(
                  item.label,
                  style: robotoRegular.copyWith(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Text(
                  item.value,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: robotoBold.copyWith(
                    fontSize: 13,
                    color: item.valueColor ?? Colors.black87,
                  ),
                ),
              ),
              hasNumber
                  ? IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  FlutterClipboard.copy(item.value).then((v) {
                    showCustomSnackBar('copied'.tr, isError: false);
                  });
                },
                icon: Icon(
                  Icons.copy_rounded,
                  size: 15,
                  color: kSectionColor,
                ),
              )
                  : const SizedBox(),
            ],
          );
        }),
      ),
    );
  }

  // ==========================================================================
  // دوال أصلية محافظ عليها كما هي (مع تحسين بصري بسيط) — لا حذف لأي بيانات
  // ==========================================================================

  Widget buildCallButton(String phoneNumber) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse("tel:$phoneNumber");
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.call,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  String getAdStatusText(String? isValid) {
    if (isValid == "1") return "ساري";
    return "ملغي";
  }

  Color getAdStatusColor(String? isValid) {
    if (isValid == "1") return Colors.green;
    return Colors.red;
  }

  Widget adLicenseQr(BuildContext context) {
    final url = widget.estate?.adLicenseUrl;

    if (url == null || url.isEmpty) return const SizedBox();

    return _card(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "رابط الإعلان في هيئة العقار",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            elevation: 2.0,
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final uri = Uri.parse(url);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('لا يمكن فتح الرابط'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    QrImageView(
                      data: url,
                      size: 150,
                      backgroundColor: Colors.white,
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.open_in_new,
                        color: Theme.of(context).primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "اضغط على الرمز لفتح الرابط",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton.icon(
                onPressed: () {
                  final message = "شاهد هذا العقار:\n$url";
                  final whatsappUrl =
                      "https://wa.me/?text=${Uri.encodeComponent(message)}";
                  launchUrl(Uri.parse(whatsappUrl));
                },
                icon: const Icon(Icons.copy_outlined, size: 18),
                label: const Text('نسخ الرابط'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  if (widget.estate?.id != null) {
                    shareToWhatsApp(widget.estate!.id!);
                  }
                },
                icon: const Icon(Icons.share_outlined, size: 18),
                label: const Text('مشاركة واتساب'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildInfoRowEnhanced(
      BuildContext context, {
        required String label,
        required String value,
        IconData? icon,
        Color? valueColor,
        Widget? trailing,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kSectionColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: kSectionColor, size: 22),
          if (icon != null) const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: valueColor ?? Colors.black,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void shareToWhatsApp(int id) async {
    final url = "https://app.abaadapp.sa/details/$id";
    final message = "شاهد تفاصيل العقار:\n$url";
    final whatsappUrl =
        "https://wa.me/?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  Widget ConctactWidget(
      String title, String image, String disc, String phone) {
    Widget buildContactOption({
      required IconData icon,
      required Color iconColor,
      required Color iconBg,
      required String label,
      required VoidCallback onTap,
    }) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: iconColor.withValues(alpha: 0.12),
          highlightColor: iconColor.withValues(alpha: 0.06),
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF7F9FC),
              border: Border.all(color: iconColor.withValues(alpha: 0.15)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: robotoBlack.copyWith(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: iconColor),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: kSectionColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent_rounded,
                color: kSectionColor, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'contact_the_advertiser'.tr,
              style: robotoBlack.copyWith(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          buildContactOption(
            icon: Icons.call_rounded,
            iconColor: const Color(0xFF2563EB),
            iconBg: const Color(0xFFE8EFFD),
            label: 'call_the_advertiser'.tr,
            onTap: () async {
              final Uri callUri = Uri(scheme: 'tel', path: phone);
              if (await canLaunchUrl(callUri)) {
                await launchUrl(callUri);
              } else {
                showCustomSnackBar("لا يمكن إجراء المكالمة");
              }
            },
          ),
          const SizedBox(height: 12),
          buildContactOption(
            icon: Icons.chat_rounded,
            iconColor: const Color(0xFF25D366),
            iconBg: const Color(0xFFE3FBEC),
            label: 'contact_whatsApp'.tr,
            onTap: () {
              final estateId = widget.estate?.id;
              final advertiserPhone = widget.estate?.users?.phone;
              final estateUrl = "https://app.abaadapp.sa/details/$estateId";
              final message =
                  "السلام عليكم، أرغب في الاستفسار عن هذا العقار:\n$estateUrl";
              final whatsappUrl =
                  "https://wa.me/$advertiserPhone?text=${Uri.encodeComponent(message)}";
              launchUrl(Uri.parse(whatsappUrl),
                  mode: LaunchMode.externalApplication);
            },
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.only(bottom: 10, left: 16, right: 16),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'close'.tr,
            style: robotoMedium.copyWith(color: Colors.black45, fontSize: 13),
          ),
        ),
      ],
    );
  }
  Widget buildEndDateWithStatusBadge(
      BuildContext context, {
        String? label,
        String? value,
        bool? isExpired,
      }) {
    return Container(
      height: 60,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kSectionColor.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Text(label!,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
          const VerticalDivider(width: 1.0),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired ?? false ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired ?? false ? "غير نشط" : "نشط",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildColoredInfoRow(
      BuildContext context, {
        String? label = "",
        String? value = "",
        bool? isExpired = false,
      }) {
    final Color statusColor = isExpired ?? false ? Colors.red : Colors.green;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kSectionColor.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label ?? "",
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? "",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isExpired ?? false ? "منتهي" : "ساري",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoTile(BuildContext context,
      {String? label = "", String? value = ""}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F9FC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: kSectionColor.withOpacity(0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label ?? "",
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: Theme.of(context).disabledColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value ?? "",
                  style: robotoBlack.copyWith(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              FlutterClipboard.copy(value ?? "").then((v) {
                showCustomSnackBar('copied'.tr, isError: false);
              });
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: kSectionColor.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.copy_rounded,
                color: Theme.of(context).primaryColor,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ==========================================================================
/// دوال عامّة (Top-level) — نفس الدوال الموجودة أصلًا في الملف، لم تُحذف.
/// ==========================================================================

Widget buildInfoRow(BuildContext context, String label, String value) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF7F9FC),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: kSectionColor.withOpacity(0.08)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

Widget buildPhoneRow(BuildContext context, {required String phoneNumber}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        const Icon(Icons.phone, color: Colors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            phoneNumber,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.call, size: 18),
          label: const Text("اتصال"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildInfoRowEnhanced(
    BuildContext context, {
      required String label,
      required String value,
      IconData? icon,
      Color? valueColor,
      Widget? trailing,
    }) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        if (icon != null) Icon(icon, color: Colors.blueGrey, size: 22),
        if (icon != null) const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: valueColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );
}

String formatPrice(String priceStr) {
  final num? price = num.tryParse(priceStr);
  final num safePrice = price ?? 0;

  if (safePrice >= 1000000) {
    return "${(safePrice / 1000000).toStringAsFixed(2)} مليون";
  } else if (safePrice >= 1000) {
    return "${(safePrice / 1000).toStringAsFixed(2)} ألف";
  } else {
    return safePrice.toString();
  }
}

openDialPad(String phoneNumber) async {
  Uri url = Uri(scheme: "tel", path: phoneNumber);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  }
}