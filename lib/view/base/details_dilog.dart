import 'dart:convert';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/estate_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/data/model/body/notification_body.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/data/model/response/userinfo_model.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/map_details_view.dart';
import 'package:abaad_flutter/view/base/not_logged_in_screen.dart';
import 'package:abaad_flutter/view/base/offer_list.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/estate_view.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/interface.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/near_by_view.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/network_type.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/report_widget.dart';
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

class DettailsDilog extends StatefulWidget {
  Estate? estate;

  // Generate some dummy data

  DettailsDilog({Key? key, this.estate}) : super(key: key);

  @override
  State<DettailsDilog> createState() => _DettailsDilogState();
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

      print(body);

      return body['success'] == true;

    } catch (e) {

      print(e);

      return false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    Get.find<UserController>().getUserInfoByID(widget.estate!.userId!);


    WidgetsBinding.instance.addPostFrameCallback((_) async {

      final isValid = await validateAdvertisement(

        adLicenseNumber:
        widget.estate?.adLicenseNumber ?? "",

        advertiserId:
        widget.estate?.identityUnified ?? "",

        idType:
        widget.estate?.estate_type ?? "",

      );

      // طباعة القيم قبل الإرسال
      print("رقم الترخيص: ${     widget.estate?.adLicenseNumber ?? ""}");
      print("رقم الهوية: ${ widget.estate?.identityUnified ?? ""}");
      print("نوع الهوية: ${ widget.estate?.estate_type ?? ""}");

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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: const Text(
              "لا يمكن عرض تفاصيل هذا العقار لأن الإعلان غير صالح أو منتهي.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop(); // إغلاق الديالوق
                  Navigator.of(context).pop(); // الرجوع من صفحة التفاصيل
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
    final lat = double.tryParse(widget. estate?.latitude ?? '');
    final lng = double.tryParse(widget. estate?.longitude ?? '');

    if (lat == null || lng == null) {
      return Center(child: Text("الموقع غير متوفر"));
    }
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';
    return Scaffold(
      body: SingleChildScrollView(
          child: (widget.estate != null)
              ? Column(
                  children: [
                    EstateView(fromView: true, estate: widget.estate!),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      padding: EdgeInsets.only(right: 5, left: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius:
                            BorderRadius.circular(Dimensions.RADIUS_SMALL),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.grey,
                            offset: Offset(0.0, 0.2), //(x,y)
                            blurRadius: 6.0,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text(
                          //   'title'.tr,
                          //   style:  robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault),
                          // ),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 📌 التصنيف - المنطقة - الحي
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue, // 🎨 خلفية زرقاء
                                    borderRadius: BorderRadius.circular(
                                        8), // حواف دائرية ناعمة
                                  ),
                                  child: Text(
                                    isArabic
                                        ? "${widget.estate!.categoryNameAr} - ${widget.estate!.zoneNameAr} - ${widget.estate!.districts ?? ''} - ${widget.estate!.advertisementType}"
                                        : "${widget.estate!.categoryName} - ${widget.estate!.zoneName ?? ''}",
                                    textAlign: isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: robotoMedium.copyWith(
                                      fontSize: Dimensions.fontSizeLarge,
                                      color: Colors.white, // ✅ لون الخط أبيض
                                    ),
                                  ),
                                ),
                              ),

                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        color: Colors.blue,
                                      ),
                                      child: Row(
                                        children: [
                                          // عنوان السعر
                                          Text(
                                            widget.estate!.categoryName != "ارض"
                                                ? "price".tr
                                                : "سعر المتر",
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color:
                                                  Theme.of(context).cardColor,
                                            ),
                                          ),
                                          const SizedBox(width: 4),

                                          // السعر
                                          Text(
                                            formatPrice(
                                                widget.estate!.price ?? "0"),
                                            style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeDefault,
                                              color:
                                                  Theme.of(context).cardColor,
                                            ),
                                          ),

                                          const SizedBox(width: 4),

                                          // صورة شعار الريال
                                          Image.asset(
                                            'assets/image/riyals.png',
                                            width: 16,
                                            height: 16,
                                            color: Theme.of(context)
                                                .cardColor, // لإعطاء نفس لون النص إن رغبت
                                          ),

                                          // إجمالي السعر إذا كان "أرض"
                                          if (widget.estate!.categoryName ==
                                              "ارض") ...[
                                            const SizedBox(width: 12),
                                            if (widget.estate!.totalPrice !=
                                                "undefined")
                                              Text(
                                                "إجمالي السعر",
                                                style: robotoRegular.copyWith(
                                                  fontSize: Dimensions
                                                      .fontSizeDefault,
                                                  color: Theme.of(context)
                                                      .cardColor,
                                                ),
                                              ),
                                            const SizedBox(width: 4),
                                            Text(
                                              formatPrice(
                                                  widget.estate!.totalPrice ??
                                                      "0"),
                                              style: robotoRegular.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeDefault,
                                                color:
                                                    Theme.of(context).cardColor,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Image.asset(
                                              'assets/image/riyals.png',
                                              width: 16,
                                              height: 16,
                                              color:
                                                  Theme.of(context).cardColor,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              Text(
                                'shot_description'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                widget.estate!.shortDescription ?? '',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeSmall,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 12),

                              // 📝 العنوان: وصف طويل
                              Text(
                                'long_description'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Text(
                                widget.estate!.longDescription ?? '',
                                style: robotoRegular.copyWith(
                                  fontSize: Dimensions.fontSizeDefault,
                                  height: 1.5,
                                  color: Colors.black87,
                                ),
                              ),

                              const SizedBox(height: 20),

                              // 📝 العنوان: وصف قصير
                            ],
                          )

                          //
                          // Row(
                          //   children: [
                          //     Text(isArabic ? "${widget.estate.categoryNameAr} -${widget.estate.zoneNameAr} -${widget.estate.districts??''}":"${widget.estate.categoryName} -${widget.estate.zoneName??''} ",
                          //         style:  robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                          //   ],
                          // ),
                          // Text(
                          //   'long_description'.tr,
                          //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                          // ),
                          //
                          // Text("${widget.estate.longDescription}",
                          //     style:  robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                          //
                          // Text(
                          //   'shot_description'.tr,
                          //   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
                          // ),
                          //
                          // Text("${widget.estate.shortDescription}",
                          //     style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault)),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        padding: EdgeInsets.only(
                            right: 5, left: 5, bottom: 5, top: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius:
                              BorderRadius.circular(Dimensions.RADIUS_SMALL),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 0.2), //(x,y)
                              blurRadius: 1.0,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Text(
                                //   estateController.address,
                                //   style: TextStyle(
                                //     color: Colors.black,
                                //     fontSize: 25,
                                //   ),
                                // )

                                Text(
                                  'it_contains'.tr,
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Divider(
                              height: 1,
                            ),
                            widget.estate!.category != "5"
                                ? Center(
                                    child: SizedBox(
                                      height: 35,
                                      child: ListView.builder(
                                        physics: BouncingScrollPhysics(),
                                        itemCount:
                                            widget.estate!.property!.length,
                                        scrollDirection: Axis.horizontal,
                                        // ignore: missing_return
                                        itemBuilder: (context, index) {
                                          return widget.estate != null
                                              ? widget.estate!.property![index]
                                                          .name ==
                                                      "حمام"
                                                  ? Container(
                                                      decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .cardColor,
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .RADIUS_SMALL),
                                                        boxShadow: const [
                                                          BoxShadow(
                                                            color: Colors.grey,
                                                            offset: Offset(0.0,
                                                                0.2), //(x,y)
                                                            blurRadius: 6.0,
                                                          ),
                                                        ],
                                                      ),
                                                      margin:
                                                          EdgeInsets.all(5.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: <Widget>[
                                                          SizedBox(
                                                            height: 23.0,
                                                            width: 23.0,
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2),
                                                              child: Image.asset(
                                                                  Images
                                                                      .bathroom,
                                                                  height: 24,
                                                                  color: Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                                  width: 24),
                                                            ),
                                                          ),
                                                          Row(
                                                            children: [
                                                              Text("bathroom"
                                                                  .tr),
                                                              Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10.0),
                                                                child: Text(
                                                                    " ${widget.estate!.property![index].number ?? ""}"),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  : widget
                                                              .estate!
                                                              .property![index]
                                                              .name ==
                                                          "مطلبخ"
                                                      ? Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    Dimensions
                                                                        .RADIUS_SMALL),
                                                            boxShadow: const [
                                                              BoxShadow(
                                                                color:
                                                                    Colors.grey,
                                                                offset: Offset(
                                                                    0.0,
                                                                    0.2), //(x,y)
                                                                blurRadius: 6.0,
                                                              ),
                                                            ],
                                                          ),
                                                          margin:
                                                              EdgeInsets.all(
                                                                  5.0),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: <Widget>[
                                                              SizedBox(
                                                                height: 24.0,
                                                                width: 24.0,
                                                                child:
                                                                    Container(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              3),
                                                                  child: Image.asset(
                                                                      Images
                                                                          .kitchen,
                                                                      height:
                                                                          24,
                                                                      color: Theme.of(
                                                                              context)
                                                                          .primaryColor,
                                                                      width:
                                                                          24),
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Text("kitchen"
                                                                      .tr),
                                                                  Container(
                                                                    child: Text(
                                                                        " ${widget.estate!.property![index].number ?? ""}"),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      : widget
                                                                  .estate!
                                                                  .property![
                                                                      index]
                                                                  .name ==
                                                              "غرف نوم"
                                                          ? Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Theme.of(
                                                                        context)
                                                                    .cardColor,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        Dimensions
                                                                            .RADIUS_SMALL),
                                                                boxShadow: const [
                                                                  BoxShadow(
                                                                    color: Colors
                                                                        .grey,
                                                                    offset: Offset(
                                                                        0.0,
                                                                        0.2), //(x,y)
                                                                    blurRadius:
                                                                        6.0,
                                                                  ),
                                                                ],
                                                              ),
                                                              margin:
                                                                  const EdgeInsets
                                                                      .all(5.0),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: <Widget>[
                                                                  SizedBox(
                                                                    height:
                                                                        40.0,
                                                                    width: 40.0,
                                                                    child:
                                                                        Container(
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              6),
                                                                      child: Image.asset(
                                                                          Images
                                                                              .bed,
                                                                          height:
                                                                              24,
                                                                          color: Theme.of(context)
                                                                              .primaryColor,
                                                                          width:
                                                                              24),
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Text("bedrooms"
                                                                          .tr),
                                                                      Container(
                                                                        margin: const EdgeInsets
                                                                            .only(
                                                                            left:
                                                                                10.0),
                                                                        child: Text(
                                                                            " ${widget.estate!.property![index].number}"),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          : widget
                                                                      .estate!
                                                                      .property![
                                                                          index]
                                                                      .name ==
                                                                  "مطبخ"
                                                              ? Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            Dimensions.RADIUS_SMALL),
                                                                    boxShadow: const [
                                                                      BoxShadow(
                                                                        color: Colors
                                                                            .grey,
                                                                        offset: Offset(
                                                                            0.0,
                                                                            0.2), //(x,y)
                                                                        blurRadius:
                                                                            6.0,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          5.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: <Widget>[
                                                                      SizedBox(
                                                                        height:
                                                                            40.0,
                                                                        width:
                                                                            40.0,
                                                                        child:
                                                                            Container(
                                                                          padding: const EdgeInsets
                                                                              .all(
                                                                              6),
                                                                          child: Image.asset(
                                                                              Images.kitchen,
                                                                              height: 24,
                                                                              color: Theme.of(context).primaryColor,
                                                                              width: 24),
                                                                        ),
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Text("kitchen"
                                                                              .tr),
                                                                          Container(
                                                                            child:
                                                                                Text(" ${widget.estate!.property![index].number} "),
                                                                          ),
                                                                        ],
                                                                      )
                                                                    ],
                                                                  ),
                                                                )
                                                              : widget
                                                                          .estate!
                                                                          .property![
                                                                              index]
                                                                          .name ==
                                                                      "صلات"
                                                                  ? Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: Theme.of(context)
                                                                            .cardColor,
                                                                        borderRadius:
                                                                            BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                                                        boxShadow: const [
                                                                          BoxShadow(
                                                                            color:
                                                                                Colors.grey,
                                                                            offset:
                                                                                Offset(0.0, 0.2), //(x,y)
                                                                            blurRadius:
                                                                                6.0,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      margin: const EdgeInsets
                                                                          .all(
                                                                          5.0),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: <Widget>[
                                                                          SizedBox(
                                                                            height:
                                                                                40.0,
                                                                            width:
                                                                                40.0,
                                                                            child:
                                                                                Container(
                                                                              padding: const EdgeInsets.all(6),
                                                                              child: Image.asset(Images.setroom, height: 24, color: Theme.of(context).primaryColor, width: 24),
                                                                            ),
                                                                          ),
                                                                          Row(
                                                                            children: [
                                                                              Text("lounges".tr),
                                                                              Container(
                                                                                child: Text(" ${widget.estate!.property![index].number}"),
                                                                              ),
                                                                            ],
                                                                          )
                                                                        ],
                                                                      ),
                                                                    )
                                                                  : widget.estate!.property![index]
                                                                              .name ==
                                                                          "صلات"
                                                                      ? Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Theme.of(context).cardColor,
                                                                            borderRadius:
                                                                                BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                                                            boxShadow: const [
                                                                              BoxShadow(
                                                                                color: Colors.grey,
                                                                                offset: Offset(0.0, 0.2), //(x,y)
                                                                                blurRadius: 6.0,
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          margin: const EdgeInsets
                                                                              .all(
                                                                              5.0),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: <Widget>[
                                                                              SizedBox(
                                                                                height: 40.0,
                                                                                width: 40.0,
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.all(6),
                                                                                  child: Image.asset(Images.setroom, height: 24, color: Theme.of(context).primaryColor, width: 24),
                                                                                ),
                                                                              ),
                                                                              Container(
                                                                                margin: const EdgeInsets.only(left: 10.0),
                                                                                child: Text(" ${widget.estate!.property![index].number} صالات"),
                                                                              )
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : Container()
                                              : Container();
                                        },
                                      ),
                                    ),
                                  )
                                : Container(),
                            Divider(
                              height: 1,
                            ),

                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'details'.tr,
                              style: robotoBlack.copyWith(fontSize: 14),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(height: 13),
                            // تاريخ الإنشاء
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2252A1),
                                  // كحلي غامق، يمكنك تغييره لأي درجة
                                  border: Border.all(
                                      color: Colors.grey, width: 1.5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "معلومات الإعلان",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white, // لون النص أبيض
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 13),
                            // Container(
                            //   height: 50,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(4.0),
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Theme.of(context).backgroundColor,
                            //         spreadRadius: 1,
                            //         blurRadius: 2,
                            //         offset: Offset(0, 0.5), // changes position of shadow
                            //       ),
                            //
                            //     ],
                            //
                            //   ),
                            //   child: Row(
                            //
                            //     children: [
                            //       Expanded( flex: 1,
                            //           child: Container(
                            //               padding: EdgeInsets.all(10),child:  Text("type_property".tr))),
                            //       VerticalDivider(width: 1.0),
                            //       Expanded(flex: 1,
                            //           child: Container(
                            //               padding: EdgeInsets.all(10),child:  Text( widget.estate.estate_type=="1"?"residential".tr:"commercial".tr,  style: robotoBlack.copyWith(fontSize: 14)))),
                            //     ],
                            //   ),
                            // ),

                            // نوع الإعلان
                            buildInfoTile(context,
                                label: "advertisement_type".tr,
                                value: widget.estate!.advertisementType ?? ""),

                            buildInfoTile(context,
                                label: "استخدام العقار",
                                value: widget.estate!. propertyUsages?? ""),

                            // نوع الصك
                            buildInfoTile(context,
                                label: "نوع وثيقة الملكية".tr,
                                value: widget.estate!.titleDeedTypeName ?? ""),

                            // رقم رخصة الإعلان
                            buildInfoTile(context,
                                label: "ad_license_number".tr,
                                value: widget.estate!.adLicenseNumber ?? ""),

                            buildInfoTile(context,
                                label: "تاريح ترخيص الإعلان",
                                value: widget.estate!.creationDate ?? ""),

                            buildColoredInfoRow(
                              context,
                              label: "تاريخ إنتهاء ترخيص الإعلان",
                              value: widget.estate?.endDate ?? "",
                              isExpired: DateTime.tryParse(
                                          widget.estate!.endDate ?? "")
                                      ?.isBefore(DateTime.now()) ??
                                  false,
                            ),

                            widget.estate?.categoryName != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text("نوع العقار".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate
                                                            ?.categoryName ??
                                                        "",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 14)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            // رقم المخطط
                            buildInfoTile(context,
                                label: "plan_number".tr,
                                value: widget.estate?.planNumber ?? ""),

                            widget.estate?.property_type != "ارض"
                                ? Column(
                                    children: [
                                      widget.estate?.ageEstate != null
                                          ? Container(
                                              height: 50,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .surface,
                                                    spreadRadius: 1,
                                                    blurRadius: 2,
                                                    offset: Offset(0,
                                                        0.5), // changes position of shadow
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              "age_of_the_property"
                                                                  .tr))),
                                                  VerticalDivider(width: 1.0),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              widget.estate!
                                                                      .ageEstate ??
                                                                  "",
                                                              style: robotoBlack
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14)))),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  )
                                : Container(),

                            widget.estate?.guaranteesAndTheirDuration != null
                                ? buildInfoRow(
                                    context,
                                    "الضمانات ",
                                    widget.estate?.guaranteesAndTheirDuration ??
                                        "لا يوجد")
                                : SizedBox(),
                            widget.estate?.mainLandUseTypeName  != null?
                            buildInfoTile(context,
                                label: "استخدام العقار".tr,
                                value:
                                    widget.estate?.mainLandUseTypeName ?? ""):Container(),

                            widget.estate?.landNumber != null
                                ? buildInfoRow(context, "رقم القطعة",
                                    widget.estate?.landNumber ?? "")
                                : SizedBox(),

                            widget.estate?.numberOfRooms != null
                                ? buildInfoRow(context, "عدد الغرف",
                                    widget.estate?.numberOfRooms ?? "")
                                : SizedBox(),

                            widget.estate?.obligationsOnTheProperty != null&&widget.estate?.obligationsOnTheProperty != "-"
                                ? buildInfoRow(
                                    context,
                                    "الالتزامات ",
                                    widget.estate?.obligationsOnTheProperty ??
                                        "")
                                : SizedBox(),

                            widget.estate?.space != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text("space".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate?.space ?? "",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 14)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            // الواجهة
                            buildInfoTile(context,
                                label: "property_face".tr,
                                value: widget.estate?.propertyFace ?? ""),

                            // buildInfoTile(context,
                            //     label: "street_width".tr,
                            //     value: widget.estate!.streetWidth.toString()),

                            widget.estate?.propertyUtilities != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child:
                                                    Text("خدمات العقار".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    "${widget.estate?.propertyUtilities}",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 8)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            widget.estate?.locationDescriptionOnMOJDeed != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    "وصف العقار حسب الصك".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate
                                                            ?.locationDescriptionOnMOJDeed ??
                                                        "",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 8)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            buildInfoTile(
                              context,
                              label: "المنطقة",
                              value: widget.estate?.zoneNameAr ?? "",
                            ),

                            buildInfoTile(
                              context,
                              label: "المدينة",
                              value: widget.estate?.city ?? "",
                            ),
                            buildInfoTile(context,
                                label: "الحي",
                                value: widget.estate?.districts ?? ""),

                            widget.estate?.streetSpace != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child:
                                                    Text("width_street".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate
                                                            ?.streetSpace ??
                                                        "",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 14)))),
                                      ],
                                    ),
                                  )
                                : Container(),
                            widget.estate?.documentNumber != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    "document_number".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate
                                                            ?.documentNumber ??
                                                        "",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 14)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            widget.estate?.priceNegotiation != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text("price".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate
                                                                ?.priceNegotiation ==
                                                            "قابل للتفاوض"
                                                        ? "negotiate".tr
                                                        : "non_negotiable".tr,
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 14)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            widget.estate?.buildSpace != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text("build_space".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate?.buildSpace ??
                                                        "",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 14)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            widget.estate?.users?.name != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    "advertiser_phone".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate?.users
                                                            ?.phone ??
                                                        "",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 14)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            widget.estate?.deedNumber != null
                                ? Container(
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          spreadRadius: 1,
                                          blurRadius: 2,
                                          offset: Offset(0,
                                              0.5), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text("deed_number".tr))),
                                        VerticalDivider(width: 1.0),
                                        Expanded(
                                            flex: 1,
                                            child: Container(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    widget.estate!.deedNumber ??
                                                        "",
                                                    style: robotoBlack.copyWith(
                                                        fontSize: 14)))),
                                      ],
                                    ),
                                  )
                                : Container(),

                            SizedBox(height: 10),
                            // مسافة بين العنوان

                            SizedBox(height: 10),
                            // مسافة بين العنوان

                            Column(
                              children: [
                                SizedBox(height: 13),
                                // تاريخ الإنشاء

                                SizedBox(height: 13),

                                // // تاريخ الإنشاء
                                // if (widget.estate.creationDate != null)
                                //   buildInfoTile(context, label: "creation_date".tr, value: widget.estate.creationDate),

                                // تاريخ الانتهاء
                                // if (widget.estate.endDate != null)
                                //   buildInfoTile(context, label: "end_date".tr, value: widget.estate.endDate),

                                // رقم ترخيص الوساطة والتسويق
                                // buildInfoTile(context,
                                //     label: "brokerage_marketing_license".tr,
                                //     value: widget.estate
                                //             ?.brokerageAndMarketingLicenseNumber ??
                                //         ""),

                                // نوع الصك

                                // الحد الشمالي
                                // if (widget.estate.northLimit != null)
                                //   buildInfoTile(context, label: "north_limit".tr, value: widget.estate.northLimit),
                                //
                                // // الحد الشرقي
                                // if (widget.estate.eastLimit != null)
                                //   buildInfoTile(context, label: "east_limit".tr, value: widget.estate.eastLimit),
                                //
                                // // الحد الغربي
                                // if (widget.estate.westLimit != null)
                                //   buildInfoTile(context, label: "west_limit".tr, value: widget.estate.westLimit),
                                //
                                // // الحد الجنوبي
                                // if (widget.estate.southLimit != null)
                                //   buildInfoTile(context, label: "south_limit".tr, value: widget.estate.southLimit),

                                // عرض الشارع

                                // نوع الإعلان

                                // رقم الترخيص
                                buildInfoTile(context,
                                    label: "رقم رخصة فال".tr,
                                    value: widget.estate?.licenseNumber ?? ""),

                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 7),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2252A1),
                                      // كحلي غامق، يمكنك تغييره لأي درجة
                                      border: Border.all(
                                          color: Colors.grey, width: 1.5),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      "معلومات  حدود العقار",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // لون النص أبيض
                                      ),
                                    ),
                                  ),
                                ),

                                // الحد الشمالي
                                widget.estate?.northLimit != null
                                    ? buildInfoRow(context, "الحد الشمالي",
                                        widget.estate?.northLimit ?? "")
                                    : SizedBox(),

// الحد الجنوبي
                                widget.estate?.southLimit != null
                                    ? buildInfoRow(context, "الحد الجنوبي",
                                        widget.estate?.southLimit ?? "")
                                    : SizedBox(),

// الحد الشرقي
                                widget.estate?.eastLimit != null
                                    ? buildInfoRow(context, "الحد الشرقي",
                                        widget.estate?.eastLimit ?? "")
                                    : SizedBox(),

// الحد الغربي
                                widget.estate?.westLimit != null
                                    ? buildInfoRow(context, "الحد الغربي",
                                        widget.estate?.westLimit ?? "")
                                    : SizedBox(),

// // عرض الشارع
//                               widget.estate.streetWidth != null
//                                   ? buildInfoRow(context, "عرض الشارع", widget.estate.streetWidth)
//                                   : SizedBox(),

// واجهة العقار
//                               widget.estate.propertyFace != null
//                                   ? buildInfoRow(context, "واجهة العقار", widget.estate.propertyFace)
//                                   : SizedBox(),

                                // widget.estate.mainLandUseTypeName != null
                                //     ? buildInfoRow(context, "الاستخدام ", widget.estate.mainLandUseTypeName)
                                //     : SizedBox(),
                              ],
                            ),
                            // widget.estate.nationalAddress!=null?    Container(
                            //   height: 50,
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     borderRadius: BorderRadius.circular(4.0),
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Theme.of(context).backgroundColor,
                            //         spreadRadius: 1,
                            //         blurRadius: 2,
                            //         offset: Offset(0, 0.5), // changes position of shadow
                            //       ),
                            //
                            //     ],
                            //
                            //   ),
                            //   child: Row(
                            //
                            //     children: [
                            //       Expanded(flex: 1,child: Container(
                            //           padding: EdgeInsets.all(10),child:  Text("short_national_code".tr))),
                            //       VerticalDivider(width: 1.0),
                            //       Expanded(flex: 1,child: Container(
                            //           padding: EdgeInsets.all(10),child: Row(
                            //         children: [
                            //           Text("${ widget.estate.nationalAddress}",  style: robotoBlack.copyWith(fontSize: 14)),
                            //           IconButton(onPressed:(){
                            //             FlutterClipboard.copy(widget.estate.nationalAddress.toString()).then(( value ) {
                            //               showCustomSnackBar('copied'.tr, isError: false);
                            //             });
                            //           }, icon: Icon(Icons.copy,color: Theme.of(context).primaryColor,size: 15,)),
                            //         ],
                            //       ))),
                            //     ],
                            //   ),
                            // ):Container(),

                            widget.estate!.networkType!.isNotEmpty
                                ? NetworkTypeItem(
                                    estate: widget.estate!,
                                    restaurants: widget.estate!.networkType!)
                                : Container(),
                            widget.estate?.interface != null
                                ? InterfaceItem(
                                    estate: widget.estate!,
                                    restaurants: widget.estate!.interface!)
                                : Container(),
                           // const MapDetailsView(fromView: true),



                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2252A1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "معلومات المعلن",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 10),

                            /// اسم المعلن
                            if (widget.estate?.advertiserName != null)
                              buildInfoRowEnhanced(
                                context,
                                label: "اسم المعلن",
                                value: widget.estate!.advertiserName!,
                                icon: Icons.person,
                              ),

                            /// رقم الجوال + زر اتصال
                            if (widget.estate?.phoneNumber != null)
                              buildInfoRowEnhanced(
                                context,
                                label: "رقم الجوال",
                                value: widget.estate!.phoneNumber!,
                                icon: Icons.phone,
                                trailing: buildCallButton(widget.estate!.phoneNumber!),
                              ),

                            /// حالة الإعلان
                            if (widget.estate?.isValid != null)
                              buildInfoRowEnhanced(
                                context,
                                label: "حالة الإعلان",
                                value: getAdStatusText(widget.estate!.isValid),
                                valueColor: getAdStatusColor(widget.estate!.isValid),
                                icon: Icons.verified,
                              ),


                            adLicenseQr(context),



                            Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// النص فوق الخريطة
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              padding: EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blueGrey.shade100),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.15),
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// العنوان الرئيسي مع الأيقونة
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.blue, size: 22),
                                      SizedBox(width: 6),
                                      Text(
                                        "الموقع حسب الصك من وزارة العدل",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),

                                  /// كل تفاصيل العقار في نص واحد
                                  Text(  widget.estate
                                      ?.locationDescriptionOnMOJDeed ??
                                      "",

                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                      height: 1.6,
                                    ),
                                    textAlign: TextAlign.start,
                                  ),

                                  SizedBox(height: 10),
                                  Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.blue.shade100),
                                    ),
                                    child: Text(
                                      "نأمل مطابقة الموقع أدناه مع الموقع المذكور في وصف عنوان العقار المكتوب.",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.red, // 🔴 تغيير لون النص إلى الأحمر
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )


                                ],
                              ),
                            ),

                            /// الخريطة
                            Container(
                              height: 300,
                              margin: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Builder(
                                builder: (context) {
                                  final lat = double.tryParse(widget.estate?.latitude ?? '');
                                  final lng = double.tryParse(widget.estate?.longitude ?? '');

                                  if (lat == null || lng == null) {
                                    return Center(
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
                                          markerId: MarkerId("estate_location"),
                                          position: LatLng(lat, lng),
                                          icon: BitmapDescriptor.defaultMarker,
                                        ),
                                      },
                                      minMaxZoomPreference: MinMaxZoomPreference(5, 20),
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


                        // Container(
                            //   height: 300,
                            //   margin: EdgeInsets.all(12),
                            //   decoration: BoxDecoration(
                            //     borderRadius: BorderRadius.circular(15),
                            //     boxShadow: [
                            //       BoxShadow(
                            //         color: Colors.grey.withOpacity(0.3),
                            //         blurRadius: 8,
                            //         offset: Offset(0, 4),
                            //       ),
                            //     ],
                            //   ),
                            //   clipBehavior: Clip.antiAlias,
                            //   child: Builder(
                            //     builder: (context) {
                            //       final lat = double.tryParse(widget.estate?.latitude ?? '');
                            //       final lng = double.tryParse(widget.estate?.longitude ?? '');
                            //
                            //       if (lat == null || lng == null) {
                            //         return Center(
                            //           child: Text(
                            //             'خطأ في إحداثيات الموقع',
                            //             style: TextStyle(color: Colors.red),
                            //           ),
                            //         );
                            //       }
                            //
                            //       return ClipRRect(
                            //         borderRadius: BorderRadius.circular(15),
                            //         child: GoogleMap(
                            //           initialCameraPosition: CameraPosition(
                            //             target: LatLng(lat, lng),
                            //             zoom: 16,
                            //           ),
                            //           markers: {
                            //             Marker(
                            //               markerId: MarkerId("estate_location"),
                            //               position: LatLng(lat, lng),
                            //               icon: BitmapDescriptor.defaultMarker,
                            //             ),
                            //           },
                            //           minMaxZoomPreference: MinMaxZoomPreference(5, 20),
                            //           zoomControlsEnabled: true,
                            //           compassEnabled: true,
                            //           indoorViewEnabled: false,
                            //           mapToolbarEnabled: true,
                            //           myLocationEnabled: true,
                            //           myLocationButtonEnabled: true,
                            //           zoomGesturesEnabled: true,
                            //           scrollGesturesEnabled: true,
                            //           tiltGesturesEnabled: true,
                            //           rotateGesturesEnabled: true,
                            //         ),
                            //       );
                            //     },
                            //   ),
                            // )



                            widget.estate?.otherAdvantages == null ||
                                    widget.estate!.otherAdvantages!.isEmpty
                                ? Container()
                                : SizedBox(
                                    height: 120,
                                    child: GridView.builder(
                                      physics: BouncingScrollPhysics(),
                                      itemCount: widget
                                          .estate!.otherAdvantages!.length,
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 1 / 0.50,
                                      ),
                                      itemBuilder: (context, index) {
                                        final advantage = widget
                                            .estate!.otherAdvantages![index];
                                        return InkWell(
                                          child: Container(
                                            margin: const EdgeInsets.all(
                                                Dimensions
                                                    .PADDING_SIZE_EXTRA_SMALL),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: Dimensions
                                                  .PADDING_SIZE_EXTRA_SMALL,
                                              horizontal:
                                                  Dimensions.PADDING_SIZE_SMALL,
                                            ),
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      Dimensions.RADIUS_SMALL),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.grey[
                                                      Get.isDarkMode
                                                          ? 800
                                                          : 200]!,
                                                  blurRadius: 5,
                                                  spreadRadius: 1,
                                                )
                                              ],
                                            ),
                                            alignment: Alignment.center,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                    width: Dimensions
                                                        .PADDING_SIZE_EXTRA_SMALL),
                                                Flexible(
                                                  flex: 1,
                                                  child: Text(
                                                    advantage.name ?? '',
                                                    style:
                                                        robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeLarge,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge!
                                                          .color,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                            Divider(
                              height: 1,
                            ),
                            Text("other_information".tr,
                                style: robotoBlack.copyWith(fontSize: 14)),
                            Container(
                              padding: EdgeInsets.all(10),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return Get.find<AuthController>()
                                                    .isLoggedIn()
                                                ? Container(child: GetBuilder<
                                                        EstateController>(
                                                    builder: (wishController) {
                                                    return ReportWidget(
                                                      estate_id: widget.estate?.id ?? 0,
                                                      key: null,
                                                    );
                                                  }))
                                                : NotLoggedInScreen();
                                          },
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: Offset(0,
                                                  0.5), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(children: <Widget>[
                                          Image.asset(
                                            Images.space,
                                            height: 70,
                                            width: 70,
                                          ),
                                          Text('report_the_ad'.tr,
                                              style: robotoBlack.copyWith(
                                                  fontSize: 12)),
                                        ]),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.dialog(NearByView(
                                          esate: widget.estate ?? Estate(),
                                        ));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: Offset(0,
                                                  0.5), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(children: <Widget>[
                                          Image.asset(
                                            Images.estate_type,
                                            height: 70,
                                            width: 70,
                                          ),
                                          Text('near_by'.tr,
                                              style: robotoBlack.copyWith(
                                                  fontSize: 13)),
                                        ]),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.dialog(
                                            OfferList(estate: widget.estate ?? Estate()));
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              spreadRadius: 1,
                                              blurRadius: 2,
                                              offset: Offset(0,
                                                  0.5), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                        child: Column(children: <Widget>[
                                          Image.asset(
                                            Images.space,
                                            height: 70,
                                            width: 70,
                                          ),
                                          Text('deals_with_the_property'.tr,
                                              style: robotoBlack.copyWith(
                                                  fontSize: 12)),
                                        ]),
                                      ),
                                    ),
                                  ]),
                            ),





                            SizedBox(height: 10),
                            Divider(
                              height: 1,
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.only(right: 20, left: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(
                                        0, 0.5), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('رقم رخصة الإعلان'),
                                    SizedBox(width: 20),
                                    Text(widget.estate?.adLicenseNumber ?? ""
                                        .toString()),
                                    IconButton(
                                        onPressed: () {
                                          FlutterClipboard.copy(widget.estate?.adLicenseNumber ?? "".toString())
                                              .then((value) {
                                            showCustomSnackBar('copied'.tr,
                                                isError: false);
                                          });
                                        },
                                        icon: Icon(
                                          Icons.copy,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                  ]),
                            ),

                            SizedBox(height: 6),
                            Divider(
                              height: 1,
                            ),

                            Container(
                              padding: EdgeInsets.only(right: 20, left: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4.0),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: Offset(
                                        0, 0.5), // changes position of shadow
                                  ),
                                ],
                              ),
                              child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text('رقم وثيقة الملكية'.tr),
                                    Text(widget.estate?.deedNumber ?? ""),
                                    IconButton(
                                        onPressed: () {
                                          FlutterClipboard.copy(
                                                  widget.estate?.deedNumber ?? "")
                                              .then((value) {
                                            showCustomSnackBar('copied'.tr,
                                                isError: false);
                                          });
                                        },
                                        icon: Icon(
                                          Icons.copy,
                                          color: Theme.of(context).primaryColor,
                                        )),
                                  ]),
                            ),

                            SizedBox(height: 6),
                            Divider(
                              height: 1,
                            ),
                            SizedBox(height: 6),

                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    //print("-------------------------------");
                                    Get.toNamed(
                                        RouteHelper.getProfileAgentRoute(
                                            widget.estate?.users?.id ?? 0, 0));
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        bottom: Dimensions.PADDING_SIZE_SMALL),
                                    padding: EdgeInsets.all(
                                        Dimensions.PADDING_SIZE_SMALL),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(
                                          Dimensions.RADIUS_SMALL),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                            spreadRadius: 1,
                                            blurRadius: 5)
                                      ],
                                    ),
                                    child: Row(children: [
                                      ClipOval(
                                          child: CustomImage(
                                        image:
                                            '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                                            '/${widget.estate!.users!.image ?? ''}',
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      )),
                                      SizedBox(
                                          width: Dimensions.PADDING_SIZE_SMALL),
                                      Expanded(
                                          flex: 1,
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                //  Text("${ _isLoggedIn ? '${userController.agentInfoModel.name}' : 'guest'.tr}", style: robotoMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                                Text(
                                                  widget.estate!.users!.name ?? "",
                                                  style: robotoMedium.copyWith(
                                                      fontSize: Dimensions
                                                          .fontSizeDefault),
                                                ),
                                                SizedBox(
                                                    height: Dimensions
                                                        .PADDING_SIZE_EXTRA_SMALL),

                                                Row(children: [
                                                  Container(
                                                    height: 25,
                                                    alignment: Alignment.center,
                                                    padding: EdgeInsets.only(
                                                        right: 4, left: 4),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      borderRadius: BorderRadius
                                                          .circular(Dimensions
                                                              .RADIUS_SMALL),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                          widget.estate?.users?.membershipType ?? '',
                                                          style: robotoBold
                                                              .copyWith(
                                                            color: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                            fontSize: Dimensions
                                                                .fontSizeDefault,
                                                          )),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: SizedBox()),
                                                ]),
                                                SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "advertiser_no".tr,
                                                      style: robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor),
                                                    ),
                                                    SizedBox(width: 20),
                                                    Text(
                                                      widget.estate?.users?.phone ?? "",
                                                      style: robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text(
                                                      "date_of_publication".tr,
                                                      style: robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeLarge,
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor),
                                                    ),
                                                    // SizedBox(width: 20),
                                                    Text(
                                                      widget.estate?.createdAt ??
                                                          "",
                                                      style: robotoRegular.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor),
                                                    ),
                                                  ],
                                                ),
                                              ])),
                                    ]),
                                  ),
                                ),
                                CustomButton(
                                  height: 40,
                                  width: 100,
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Get.find<AuthController>()
                                                .isLoggedIn()
                                            ? Container(child:
                                                GetBuilder<EstateController>(
                                                    builder: (wishController) {
                                                return ConctactWidget(
                                                    widget.estate?.title ?? "",
                                                    "",
                                                    widget.estate?.shortDescription ?? "",
                                                    widget.estate?.users?.phone ?? ""
                                                );
                                              }))
                                            : NotLoggedInScreen();
                                      },
                                    );
                                  },

                                  // async {

                                  buttonText: 'contact_the_advertiser'.tr,
                                ),
                              ],
                            ),
                          ],
                        ))
                  ],
                )
              : const SizedBox()),
    );
  }


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

    return Container(
      // تصغير الهوامش الخارجية والداخلية
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(16.0), // كان 20.0
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12), // كان 16
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8, // كان 12
            offset: const Offset(0, 2), // كان 4
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // العنوان مع حجم خط أصغر
          Text(
            "رابط الإعلان في هيئة العقار",
            style: TextStyle(
              fontSize: 16, // كان 18
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16), // كان 20

          // حاوية كود QR الأصغر حجماً
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10), // كان 12
            elevation: 2.0, // كان 3.0
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
                padding: const EdgeInsets.all(12.0), // كان 16.0
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    QrImageView(
                      data: url,
                      size: 150, // كان 200 (الحجم الرئيسي)
                      backgroundColor: Colors.white,
                    ),
                    // تصغير الأيقونة وحاويتها
                    Container(
                      width: 36, // كان 44
                      height: 36, // كان 44
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3, // كان 4
                          )
                        ],
                      ),
                      child: Icon(
                        Icons.open_in_new,
                        color: Theme.of(context).primaryColor,
                        size: 20, // كان 24
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12), // كان 16
          Text(
            "اضغط على الرمز لفتح الرابط",
            style: TextStyle(
              fontSize: 12, // كان 13
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          const SizedBox(height: 16), // كان 24

          // أزرار الإجراءات مع أيقونات أصغر
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
                icon: const Icon(Icons.copy_outlined, size: 18), // كان 20
                label: const Text('نسخ الرابط'),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  if (widget.estate?.id != null) {
                    final url =
                        "https://app.abaadapp.sa/details/${widget.estate!.id}";

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
          if (icon != null)
            Icon(icon, color: Colors.blueGrey, size: 22),

          if (icon != null) const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
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
    final url =
        "https://app.abaadapp.sa/details/$id";

    final message =
        "شاهد تفاصيل العقار:\n$url";

    final whatsappUrl =
        "https://wa.me/?text=${Uri.encodeComponent(message)}";

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(
        Uri.parse(whatsappUrl),
        mode: LaunchMode.externalApplication,
      );
    }
  }
  Widget ConctactWidget(String title, String image, String disc, String phone) {
    return AlertDialog(
      title: Text('contact_the_advertiser'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_SMALL),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey[Get.isDarkMode ? 800 : 200]!,
                    spreadRadius: 2,
                    blurRadius: 1,
                    offset: Offset(0, 2))
              ],
            ),
          ),
          GestureDetector(
             onTap: () async{
               final advertiserPhone = phone ;// رقم المعلن بدون "+" وبصيغة دولية

               final Uri callUri = Uri(scheme: 'tel', path: advertiserPhone);

               if (await canLaunchUrl(callUri)) {
               await launchUrl(callUri);
               } else {
               showCustomSnackBar("لا يمكن إجراء المكالمة");
               }

    },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: GetBuilder<SplashController>(
                            builder: (splashController) {
                              String baseUrl = Get.find<SplashController>()
                                  .configModel!
                                  .baseUrls!
                                  .provider;
                              //   //print("------------${'$_baseUrl/${estateController.estate.serviceOffers[index].imageCover}'}");
                              return const ClipOval(
                                child: Icon(
                                  Icons.phone,
                                  size: 40,
                                  color: Colors.green,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                'call_the_advertiser'.tr,
                                style: robotoBlack.copyWith(fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 3.0),
                            // const RatingStars(
                            //   value: 3* 1.0,
                            //   starCount: 5,
                            //   starSize: 7,
                            //   valueLabelColor: Color(0xff9b9b9b),
                            //   valueLabelTextStyle: TextStyle(
                            //       color: Colors.white,
                            //       fontFamily: 'WorkSans',
                            //       fontWeight: FontWeight.w400,
                            //       fontStyle: FontStyle.normal,
                            //       fontSize: 9.0),
                            //   valueLabelRadius: 7,
                            //   maxValue: 5,
                            //   starSpacing: 2,
                            //   maxValueVisibility: false,
                            //   valueLabelVisibility: true,
                            //   animationDuration: Duration(milliseconds: 1000),
                            //   valueLabelPadding:
                            //   EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                            //   valueLabelMargin: EdgeInsets.only(right: 4),
                            //   starOffColor: Color(0xffe7e8ea),
                            //   starColor: Colors.yellow,
                            // )
                          ])
                    ],
                  ),

                  // Divider(color: Colors.grey.shade600, height: 1.0)
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              final estateId = widget.estate!.id; // اجلبه من model
              final advertiserPhone = widget.estate!.users!.phone; // اجلب رقم المعلن الحقيقي بدون "+" وبالدولة
              final estateUrl = "https://app.abaadapp.sa/details/$estateId";
              final message = "السلام عليكم، أرغب في الاستفسار عن هذا العقار:\n$estateUrl";

              final whatsappUrl = "https://wa.me/$advertiserPhone?text=${Uri.encodeComponent(message)}";

              launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);

            },
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 3,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: GetBuilder<SplashController>(
                          builder: (splashController) {
                            String baseUrl = Get.find<SplashController>()
                                .configModel!
                                .baseUrls!
                                .provider;
                            //   //print("------------${'$_baseUrl/${estateController.estate.serviceOffers[index].imageCover}'}");
                            return ClipOval(
                              child: Icon(
                                Icons.whatshot_rounded,
                                size: 40,
                                color: Colors.green,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 4.0),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                'contact_whatsApp'.tr,
                                style: robotoBlack.copyWith(fontSize: 11),
                              ),
                            ),
                            const SizedBox(height: 3.0),
                            // const RatingStars(
                            //   value: 3* 1.0,
                            //   starCount: 5,
                            //   starSize: 7,
                            //   valueLabelColor: Color(0xff9b9b9b),
                            //   valueLabelTextStyle: TextStyle(
                            //       color: Colors.white,
                            //       fontFamily: 'WorkSans',
                            //       fontWeight: FontWeight.w400,
                            //       fontStyle: FontStyle.normal,
                            //       fontSize: 9.0),
                            //   valueLabelRadius: 7,
                            //   maxValue: 5,
                            //   starSpacing: 2,
                            //   maxValueVisibility: false,
                            //   valueLabelVisibility: true,
                            //   animationDuration: Duration(milliseconds: 1000),
                            //   valueLabelPadding:
                            //   EdgeInsets.symmetric(vertical: 1, horizontal: 4),
                            //   valueLabelMargin: EdgeInsets.only(right: 4),
                            //   starOffColor: Color(0xffe7e8ea),
                            //   starColor: Colors.yellow,
                            // )
                          ])
                    ],
                  ),

                  // Divider(color: Colors.grey.shade600, height: 1.0)
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          // Container(
          //   padding: const EdgeInsets.all(10.0),
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(3),
          //     color: Colors.white,
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.grey.withOpacity(0.2),
          //         spreadRadius: 5,
          //         blurRadius: 3,
          //         offset: Offset(0, 2),
          //       ),
          //     ],
          //   ),
          //   child: Column(
          //     children: [
          //       Row(
          //         children: [
          //           GestureDetector(
          //             onTap: () async {
          //               try {
          //                 String url = "https://abaadapp.page.link";
          //                 // final DynamicLinkParameters parameters =
          //                 //     DynamicLinkParameters(
          //                 //   uriPrefix: url,
          //                 //   link: Uri.parse(
          //                 //       '$url/${widget.estate?.id.toString()}'),
          //                 //   androidParameters: AndroidParameters(
          //                 //     packageName: "sa.pdm.abaad.abaad",
          //                 //     minimumVersion: 0,
          //                 //   ),
          //                 //   iosParameters: IOSParameters(
          //                 //     bundleId: "Bundle-ID",
          //                 //     minimumVersion: '0',
          //                 //   ),
          //                 // );
          //                 //
          //                 // // final ShortDynamicLink dynamicUrl = await parameters.buildShortLink();
          //                 //
          //                 // // 1. Get FirebaseDynamicLinks instance
          //                 // final dynamicLinks = FirebaseDynamicLinks.instance;
          //                 //
          //                 // // 2. Build short link
          //                 // final ShortDynamicLink shortLink = await dynamicLinks.buildShortLink(
          //                 //   parameters,  // Your DynamicLinkParameters object
          //                 // );
          //
          //                 // 3. Get the URL
          //                 final dynamicUrl = "";
          //
          //                 String desc = dynamicUrl.toString();
          //
          //                 await Get.toNamed(RouteHelper.getChatRoute(
          //                   notificationBody: NotificationBody(
          //                     orderId: widget.estate?.id,
          //                     restaurantId: widget.estate?.userId,
          //                   ),
          //                   user: Userinfo(
          //                     id: widget.estate?.userId,
          //                     name: widget.estate?.users?.name ?? "",
          //                     image: widget.estate?.users?.image ?? "",
          //                   ),
          //                   estate_id: widget.estate?.id,
          //                   link: desc,
          //                 ));
          //               } catch (e) {
          //                 //print("Error building short dynamic link: $e");
          //                 // Handle the error as needed, e.g., show an error message to the user.
          //               }
          //             },
          //             child: GetBuilder<SplashController>(
          //               builder: (splashController) {
          //                 String baseUrl = Get.find<SplashController>()
          //                     .configModel!
          //                     .baseUrls!
          //                     .provider!;
          //                 //   //print("------------${'$_baseUrl/${estateController.estate.serviceOffers[index].imageCover}'}");
          //                 return const ClipOval(
          //                   child: Icon(
          //                     Icons.chat,
          //                     size: 35,
          //                     color: Colors.green,
          //                   ),
          //                 );
          //               },
          //             ),
          //           ),
          //           const SizedBox(width: 4.0),
          //           Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Container(
          //                   child: Text(
          //                     'Chat_inside_the_app'.tr,
          //                     style: robotoBlack.copyWith(fontSize: 11),
          //                   ),
          //                 ),
          //                 const SizedBox(height: 3.0),
          //                 // const RatingStars(
          //                 //   value: 3* 1.0,
          //                 //   starCount: 5,
          //                 //   starSize: 7,
          //                 //   valueLabelColor: Color(0xff9b9b9b),
          //                 //   valueLabelTextStyle: TextStyle(
          //                 //       color: Colors.white,
          //                 //       fontFamily: 'WorkSans',
          //                 //       fontWeight: FontWeight.w400,
          //                 //       fontStyle: FontStyle.normal,
          //                 //       fontSize: 9.0),
          //                 //   valueLabelRadius: 7,
          //                 //   maxValue: 5,
          //                 //   starSpacing: 2,
          //                 //   maxValueVisibility: false,
          //                 //   valueLabelVisibility: true,
          //                 //   animationDuration: Duration(milliseconds: 1000),
          //                 //   valueLabelPadding:
          //                 //   EdgeInsets.symmetric(vertical: 1, horizontal: 4),
          //                 //   valueLabelMargin: EdgeInsets.only(right: 4),
          //                 //   starOffColor: Color(0xffe7e8ea),
          //                 //   starColor: Colors.yellow,
          //                 // )
          //               ])
          //         ],
          //       ),
          //
          //       // Divider(color: Colors.grey.shade600, height: 1.0)
          //     ],
          //   ),
          // ),
        ],
      ),
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
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surface,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 0.5),
          ),
        ],
      ),
      child: Row(
        children: [
          // اسم الحقل (مثل: تاريخ الانتهاء)
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(label!, style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),

          VerticalDivider(width: 1.0),

          // التاريخ + الملصق
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  // التاريخ
                  Expanded(
                    child: Text(
                      value!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // الملصق
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpired ?? false ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isExpired ?? false ? "غير نشط" : "نشط",
                      style: TextStyle(
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
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surface,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 0.5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(label ?? "", style: TextStyle(fontWeight: FontWeight.w500)),
            ),
          ),
          VerticalDivider(width: 1.0),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                value ?? "",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isExpired ?? false ? Colors.red : Colors.green,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoTile(BuildContext context,
      {String? label = "",  String? value = ""}) {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 8), // مسافة بسيطة بين الحقول
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surface,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 0.5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(label ?? ""),
            ),
          ),
          VerticalDivider(width: 1.0),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      value ?? "",
                      style: robotoBlack.copyWith(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      FlutterClipboard.copy(value ?? "").then((v) {
                        showCustomSnackBar('copied'.tr, isError: false);
                      });
                    },
                    icon: Icon(
                      Icons.copy,
                      color: Theme.of(context).primaryColor,
                      size: 15,
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

  // buildDynamicLinks(
  //     String title, String image, String docId, String phone) async {
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
  //         description: '', imageUrl: Uri.parse(image), title: title),
  //   );
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
  //   var whatsapp = phone;
  //   var whatsappAndroid = Uri.parse(
  //       "whatsapp://send?phone=$whatsapp&text=$desc \n مرحبا لديك عرض في  تطبيق ابعاد ");
  //   if (await canLaunchUrl(whatsappAndroid)) {
  //     await launchUrl(whatsappAndroid);
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(
  //         content: Text("WhatsApp is not installed on the device"),
  //       ),
  //     );
  //   }
  //   // await Share.share(desc, subject: title,);
  // }
}

Widget buildInfoRow(BuildContext context, String label, String value) {
  return Container(
    height: 50,
    margin: EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(4.0),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.surface,
          spreadRadius: 1,
          blurRadius: 2,
          offset: Offset(0, 0.5),
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
        VerticalDivider(width: 1.0),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(8),
            child: Text(value,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
        Icon(Icons.phone, color: Colors.green),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            phoneNumber,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {
            // لاحقاً تضيف launchUrl للاتصال
            // launchUrl(Uri.parse("tel:$phoneNumber"));
          },
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
        if (icon != null)
          Icon(icon, color: Colors.blueGrey, size: 22),

        if (icon != null) const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
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

  if (price! >= 1000000) {
    return "${(price / 1000000).toStringAsFixed(2)} مليون";
  } else if (price >= 1000) {
    return "${(price / 1000).toStringAsFixed(2)} ألف";
  } else {
    return price.toString();
  }
}

openDialPad(String phoneNumber) async {
  Uri url = Uri(scheme: "tel", path: phoneNumber);
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    //print("Can't open dial pad.");
  }
}
