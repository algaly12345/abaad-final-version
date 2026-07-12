import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/category/controller/category_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/controllers/localization_controller.dart';
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
import 'package:abaad_flutter/features/estate/view/widgets/interface.dart';
import 'package:abaad_flutter/features/estate/view/widgets/near_by_view.dart';
import 'package:abaad_flutter/features/estate/view/widgets/network_type.dart';
import 'package:clipboard/clipboard.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/estate_view.dart';
import '../widgets/report_widget.dart';

class EstateDetails extends StatefulWidget {
  final Estate estate;

  const EstateDetails({super.key, required this.estate});

  @override
  State<EstateDetails> createState() => _EstateDetailsState();
}

class _EstateDetailsState extends State<EstateDetails> {
  final ScrollController scrollController = ScrollController();
  final bool _ltr = Get.find<LocalizationController>().isLtr;

  late bool _isLoggedIn;
  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();

    Get.find<EstateController>().getEstateDetails(Estate(id: widget.estate.id));
  }

  @override
  Widget build(BuildContext context) {
    List<Estate>? restaurants;
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    bool isNull = true;
    int length = 0;

    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';
    return Scaffold(
      body: SingleChildScrollView(
        child: GetBuilder<EstateController>(builder: (estateController) {
          isNull = restaurants == null;
          if (!isNull) {
            length = restaurants!.length!;
          }
          return GetBuilder<UserController>(builder: (userController) {
            return (Get.find<AuthController>().isLoggedIn() &&
                    userController.agentInfoModel == null &&
                    estateController.isLoading)
                ? Center(child: CircularProgressIndicator())
                : GetBuilder<CategoryController>(builder: (categoryController) {
                    Estate estate;

                    estate = estateController.estate!;
                    estateController.setCategoryList();

                    return (estateController.estate != null)
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              EstateView(
                                  fromView: true,
                                  estate: estateController.estate),
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                padding: EdgeInsets.only(right: 5, left: 5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(
                                      Dimensions.RADIUS_SMALL),
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
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // 📌 التصنيف - المنطقة - الحي
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.blue, // 🎨 خلفية زرقاء
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      8), // حواف دائرية ناعمة
                                            ),
                                            child: Text(
                                              isArabic
                                                  ? "${estateController.estate!.categoryNameAr} - ${estateController.estate!.zoneNameAr} - ${estateController.estate!.districts ?? ''} - ${estateController.estate!.advertisementType}"
                                                  : "${estateController.estate!.categoryName} - ${estateController.estate!.zoneName ?? ''}",
                                              textAlign: isArabic
                                                  ? TextAlign.right
                                                  : TextAlign.left,
                                              style: robotoMedium.copyWith(
                                                fontSize:
                                                    Dimensions.fontSizeLarge,
                                                color: Colors
                                                    .white, // ✅ لون الخط أبيض
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 4),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  color: Colors.blue,
                                                ),
                                                child: Row(
                                                  children: [
                                                    // عنوان السعر
                                                    Text(
                                                      estateController.estate!
                                                                  .categoryName !=
                                                              "ارض"
                                                          ? "price".tr
                                                          : "سعر المتر",
                                                      style: robotoRegular
                                                          .copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        color: Theme.of(context)
                                                            .cardColor,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 4),

                                                    // السعر
                                                    Text(
                                                      formatPrice(
                                                          estateController
                                                                  .estate!
                                                                  .price ??
                                                              "0"),
                                                      style: robotoRegular
                                                          .copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                        color: Theme.of(context)
                                                            .cardColor,
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
                                                    if (estateController.estate!
                                                            .categoryName ==
                                                        "ارض") ...[
                                                      const SizedBox(width: 12),
                                                      if (estateController
                                                              .estate!
                                                              .totalPrice !=
                                                          "undefined")
                                                        Text(
                                                          "إجمالي السعر",
                                                          style: robotoRegular
                                                              .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeDefault,
                                                            color: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                          ),
                                                        ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        formatPrice(
                                                            estateController
                                                                    .estate!
                                                                    .totalPrice ??
                                                                "0"),
                                                        style: robotoRegular
                                                            .copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeDefault,
                                                          color:
                                                              Theme.of(context)
                                                                  .cardColor,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Image.asset(
                                                        'assets/image/riyals.png',
                                                        width: 16,
                                                        height: 16,
                                                        color: Theme.of(context)
                                                            .cardColor,
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
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          estateController
                                                  .estate!.shortDescription ??
                                              '',
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
                                            color:
                                                Theme.of(context).primaryColor,
                                          ),
                                        ),

                                        const SizedBox(height: 6),

                                        Text(
                                          estateController
                                                  .estate!.longDescription ??
                                              '',
                                          style: robotoRegular.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeDefault,
                                            height: 1.5,
                                            color: Colors.black87,
                                          ),
                                        ),

                                        const SizedBox(height: 20),

                                        // 📝 العنوان: وصف قصير
                                      ],
                                    )
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
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.RADIUS_SMALL),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.grey,
                                        offset: Offset(0.0, 0.2), //(x,y)
                                        blurRadius: 1.0,
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                fontSize:
                                                    Dimensions.fontSizeSmall),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10),
                                      Divider(
                                        height: 1,
                                      ),
                                      estateController.estate!.category != "5"
                                          ? Center(
                                              child: estate!.property!=null?SizedBox(
                                                height: 35,
                                                child:
                                                    estate!.property!.length>0?  ListView.builder(
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  itemCount: estateController
                                                      .estate!.property!.length??0,
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  // ignore: missing_return
                                                  itemBuilder:
                                                      (context, index) {
                                                    return !estateController
                                                            .isLoading
                                                        ? estateController
                                                                    .estate!
                                                                    .property![
                                                                        index]
                                                                    .name ==
                                                                "حمام"
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
                                                                    EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: <Widget>[
                                                                    SizedBox(
                                                                      height:
                                                                          23.0,
                                                                      width:
                                                                          23.0,
                                                                      child:
                                                                          Container(
                                                                        padding: const EdgeInsets
                                                                            .all(
                                                                            2),
                                                                        child: Image.asset(
                                                                            Images
                                                                                .bathroom,
                                                                            height:
                                                                                24,
                                                                            color:
                                                                                Theme.of(context).primaryColor,
                                                                            width: 24),
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      children: [
                                                                        Text("bathroom"
                                                                            .tr),
                                                                        Container(
                                                                          margin: const EdgeInsets
                                                                              .only(
                                                                              left: 10.0),
                                                                          child:
                                                                              Text(" ${estateController.estate!.property![index].number ?? ""}"),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  ],
                                                                ),
                                                              )
                                                            : estateController
                                                                        .estate!
                                                                        .property![
                                                                            index]
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
                                                                              Dimensions.RADIUS_SMALL),
                                                                      boxShadow: const [
                                                                        BoxShadow(
                                                                          color:
                                                                              Colors.grey,
                                                                          offset: Offset(
                                                                              0.0,
                                                                              0.2), //(x,y)
                                                                          blurRadius:
                                                                              6.0,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    margin: EdgeInsets
                                                                        .all(
                                                                            5.0),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: <Widget>[
                                                                        SizedBox(
                                                                          height:
                                                                              24.0,
                                                                          width:
                                                                              24.0,
                                                                          child:
                                                                              Container(
                                                                            padding:
                                                                                EdgeInsets.all(3),
                                                                            child: Image.asset(Images.kitchen,
                                                                                height: 24,
                                                                                color: Theme.of(context).primaryColor,
                                                                                width: 24),
                                                                          ),
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Text("kitchen".tr),
                                                                            Container(
                                                                              child: Text(" ${estateController.estate!.property![index].number ?? ""}"),
                                                                            ),
                                                                          ],
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                : estateController
                                                                            .estate!
                                                                            .property![
                                                                                index]
                                                                            .name ==
                                                                        "غرف نوم"
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
                                                                                child: Image.asset(Images.bed, height: 24, color: Theme.of(context).primaryColor, width: 24),
                                                                              ),
                                                                            ),
                                                                            Row(
                                                                              children: [
                                                                                Text("bedrooms".tr),
                                                                                Container(
                                                                                  margin: const EdgeInsets.only(left: 10.0),
                                                                                  child: Text(" ${estateController.estate!.property![index].number}"),
                                                                                ),
                                                                              ],
                                                                            )
                                                                          ],
                                                                        ),
                                                                      )
                                                                    : estateController.estate!.property![index].name ==
                                                                            "مطبخ"
                                                                        ? Container(
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: Theme.of(context).cardColor,
                                                                              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                                                              boxShadow: const [
                                                                                BoxShadow(
                                                                                  color: Colors.grey,
                                                                                  offset: Offset(0.0, 0.2), //(x,y)
                                                                                  blurRadius: 6.0,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            margin:
                                                                                const EdgeInsets.all(5.0),
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: <Widget>[
                                                                                SizedBox(
                                                                                  height: 40.0,
                                                                                  width: 40.0,
                                                                                  child: Container(
                                                                                    padding: const EdgeInsets.all(6),
                                                                                    child: Image.asset(Images.kitchen, height: 24, color: Theme.of(context).primaryColor, width: 24),
                                                                                  ),
                                                                                ),
                                                                                Row(
                                                                                  children: [
                                                                                    Text("kitchen".tr),
                                                                                    Container(
                                                                                      child: Text(" ${estateController.estate!.property![index].number} "),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )
                                                                        : estateController.estate!.property![index].name ==
                                                                                "صلات"
                                                                            ? Container(
                                                                                decoration: BoxDecoration(
                                                                                  color: Theme.of(context).cardColor,
                                                                                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                                                                  boxShadow: const [
                                                                                    BoxShadow(
                                                                                      color: Colors.grey,
                                                                                      offset: Offset(0.0, 0.2), //(x,y)
                                                                                      blurRadius: 6.0,
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                margin: const EdgeInsets.all(5.0),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                  children: <Widget>[
                                                                                    SizedBox(
                                                                                      height: 40.0,
                                                                                      width: 40.0,
                                                                                      child: Container(
                                                                                        padding: const EdgeInsets.all(6),
                                                                                        child: Image.asset(Images.setroom, height: 24, color: Theme.of(context).primaryColor, width: 24),
                                                                                      ),
                                                                                    ),
                                                                                    Row(
                                                                                      children: [
                                                                                        Text("lounges".tr),
                                                                                        Container(
                                                                                          child: Text(" ${estateController.estate!.property![index].number}"),
                                                                                        ),
                                                                                      ],
                                                                                    )
                                                                                  ],
                                                                                ),
                                                                              )
                                                                            : estateController.estate!.property![index].name == "صلات"
                                                                                ? Container(
                                                                                    decoration: BoxDecoration(
                                                                                      color: Theme.of(context).cardColor,
                                                                                      borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                                                                                      boxShadow: const [
                                                                                        BoxShadow(
                                                                                          color: Colors.grey,
                                                                                          offset: Offset(0.0, 0.2), //(x,y)
                                                                                          blurRadius: 6.0,
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                    margin: const EdgeInsets.all(5.0),
                                                                                    child: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                                                          child: Text(" ${estateController.estate!.property![index].number} صالات"),
                                                                                        )
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                : Container()
                                                        : Container();
                                                  },
                                                ):Container(),
                                              ):Container(),
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
                                        style:
                                            robotoBlack.copyWith(fontSize: 14),
                                      ),
                                      SizedBox(
                                        height: 10,
                                      ),
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
                                      //           padding: EdgeInsets.all(10),child:  Text("type_property!".tr))),
                                      //       VerticalDivider(width: 1.0),
                                      //       Expanded(flex: 1,
                                      //           child: Container(
                                      //               padding: EdgeInsets.all(10),child:  Text( widget.estate.estate_type=="1"?"residential".tr:"commercial".tr,  style: robotoBlack.copyWith(fontSize: 14)))),
                                      //     ],
                                      //   ),
                                      // ),

                                      Container(
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
                                                    padding: EdgeInsets.all(10),
                                                    child: Text("نوع العقار"))),
                                            VerticalDivider(width: 1.0),
                                            Expanded(
                                                flex: 1,
                                                child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    child: Text(
                                                        estateController.estate!
                                                                .categoryName ??
                                                            "",
                                                        style: robotoBlack
                                                            .copyWith(
                                                                fontSize:
                                                                    14)))),
                                          ],
                                        ),
                                      ),
                                      // estateController.estate.space!=null?  Container(
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
                                      //       Expanded(flex: 1,
                                      //           child: Container(
                                      //           padding: EdgeInsets.all(10),child:    Text("space".tr))),
                                      //       VerticalDivider(width: 1.0),
                                      //       Expanded(flex: 1,
                                      //           child: Container(
                                      //           padding: EdgeInsets.all(10),child: Text("${estateController.estate.space}",  style: robotoBlack.copyWith(fontSize: 14)))),
                                      //     ],
                                      //   ),
                                      // ):Container(),
                                      //

                                      estateController.estate!.space != null
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
                                                              "space".tr))),
                                                  VerticalDivider(width: 1.0),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              estateController
                                                                  .estate!
                                                                  .space!,
                                                              style: robotoBlack
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14)))),
                                                ],
                                              ),
                                            )
                                          : Container(),

                                      estateController.estate!.streetSpace !=
                                              null
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
                                                              "width_street"
                                                                  .tr))),
                                                  VerticalDivider(width: 1.0),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              estateController
                                                                  .estate!
                                                                  .streetSpace!,
                                                              style: robotoBlack
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14)))),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      estateController.estate!.documentNumber !=
                                              null
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
                                                          child: Row(
                                                            children: [
                                                              Text(
                                                                  "document_number"
                                                                      .tr),
                                                            ],
                                                          ))),
                                                  VerticalDivider(width: 1.0),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              estateController
                                                                  .estate!
                                                                  .documentNumber!,
                                                              style: robotoBlack
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14)))),
                                                ],
                                              ),
                                            )
                                          : Container(),

                                      estateController
                                                  .estate!.priceNegotiation !=
                                              null
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
                                                          child: Row(
                                                            children: [
                                                              Text("price".tr),
                                                            ],
                                                          ))),
                                                  VerticalDivider(width: 1.0),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              widget.estate
                                                                          .priceNegotiation ==
                                                                      "قابل للتفاوض"
                                                                  ? "negotiate"
                                                                      .tr
                                                                  : "non_negotiable"
                                                                      .tr,
                                                              style: robotoBlack
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14)))),
                                                ],
                                              ),
                                            )
                                          : Container(),

                                      estateController.estate!.buildSpace !=
                                              null
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
                                                              "build_space"
                                                                  .tr))),
                                                  VerticalDivider(width: 1.0),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              estateController
                                                                  .estate!
                                                                  .buildSpace!,
                                                              style: robotoBlack
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14)))),
                                                ],
                                              ),
                                            )
                                          : Container(),

                                      estateController.estate!.ownershipType !=
                                              null
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
                                                              "advertiser_phone"
                                                                  .tr))),
                                                  VerticalDivider(width: 1.0),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              estateController
                                                                  .estate!
                                                                  .users!
                                                                  .phone!,
                                                              style: robotoBlack
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14)))),
                                                ],
                                              ),
                                            )
                                          : Container(),

                                      // estateController.estate.nationalAddress!=null?    Container(
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
                                      //           Text("${ estateController.estate.nationalAddress}",  style: robotoBlack.copyWith(fontSize: 14)),
                                      //           IconButton(onPressed:(){
                                      //             FlutterClipboard.copy(estateController.estate.nationalAddress.toString()).then(( value ) {
                                      //               showCustomSnackBar('copied'.tr, isError: false);
                                      //             });
                                      //           }, icon: Icon(Icons.copy,color: Theme.of(context).primaryColor,size: 15,)),
                                      //         ],
                                      //       ))),
                                      //     ],
                                      //   ),
                                      // ):Container(),
                                      //
                                      //

                                      Column(
                                        children: [
                                          SizedBox(height: 13),
                                          // تاريخ الإنشاء
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 7, vertical: 7),
                                              decoration: BoxDecoration(
                                                color: Color(
                                                    0xFF2252A1), // كحلي غامق، يمكنك تغييره لأي درجة
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "معلومات ترخيص الإعلان",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .white, // لون النص أبيض
                                                ),
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: 13),
                                          buildInfoTile(context,
                                              label: "ad_license_number".tr,
                                              value: widget
                                                  .estate.adLicenseNumber??""),

                                          // // تاريخ الإنشاء
                                          // if (widget.estate.creationDate != null)
                                          //   buildInfoTile(context, label: "creation_date".tr, value: widget.estate.creationDate),

                                          // تاريخ الانتهاء
                                          widget.estate.endDate==null?Container(

                                          ) :  buildInfoTile(context,
                                              label: "end_date".tr,
                                              value: widget.estate.endDate!??""),

                                          //   buildInfoTile(context, label: "end_date".tr, value: widget.estate.endDate),
                                    estate!.zoneNameAr==null?Container():   buildInfoTile(
                                            context,
                                            label: "المنطقة",
                                            value: categoryController
                                                .estate!.zoneNameAr??"",
                                          ),

                                    estate.city==null?Container(): buildInfoTile(
                                            context,
                                            label: "المدينة",
                                            value: categoryController
                                                .estate!.city!,
                                          ),
                                          buildInfoTile(context,
                                              label: "الحي",
                                              value: widget
                                                  .estate.districts??""),

                                          buildColoredInfoRow(
                                            context,
                                            label: "تاريخ الانتهاء",
                                            value: widget.estate.endDate??"",
                                            isExpired: DateTime.tryParse(
                                                        widget.estate.endDate??"")
                                                    ?.isBefore(
                                                        DateTime.now()) ??
                                                false,
                                          ),

                                          buildEndDateWithStatusBadge(
                                            context,
                                            label: "تاريخ الانتهاء",
                                            value: widget.estate.endDate??"",
                                            isExpired: DateTime.tryParse(
                                                        widget.estate.endDate??"")
                                                    ?.isBefore(
                                                        DateTime.now()) ??
                                                false,
                                          ),

                                          // رقم رخصة الإعلان
                                          buildInfoTile(context,
                                              label: "ad_license_number".tr,
                                              value: widget
                                                  .estate.adLicenseNumber??""),

                                          // رقم ترخيص الوساطة والتسويق
                                          buildInfoTile(context,
                                              label:
                                                  "brokerage_marketing_license"
                                                      .tr,
                                              value: widget.estate
                                                  .brokerageAndMarketingLicenseNumber??""),

                                          // نوع الصك
                                          buildInfoTile(context,
                                              label: "title_deed_type_name".tr,
                                              value: widget
                                                  .estate.titleDeedTypeName??""),

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
                                          // if (widget.estate.streetWidth != null)
                                          //   buildInfoTile(context, label: "street_width".tr, value: widget.estate.streetWidth.toString()),
                                          //
                                          // // الواجهة
                                          // if (widget.estate.propertyFace != null)
                                          //   buildInfoTile(context, label: "property_face".tr, value: widget.estate.propertyFace),

                                          // نوع الإعلان

                                          // رقم الترخيص
                                          buildInfoTile(context,
                                              label: "رقم رخصة فال".tr,
                                              value: widget
                                                  .estate.licenseNumber??""),

                                          // رقم المخطط
                                          buildInfoTile(context,
                                              label: "plan_number".tr,
                                              value:
                                                  widget.estate.planNumber??""),

                                          buildInfoTile(context,
                                              label: "تاريح إنشاء الإعلان",
                                              value: widget.estate.createdAt??""),

                                          // estateController

                                          widget.estate
                                                      .obligationsOnTheProperty !=
                                                  null
                                              ? buildInfoTile(context,
                                                  label: "الالتزامات ",
                                                  value: widget.estate
                                                      .obligationsOnTheProperty!)
                                              : SizedBox(),

                                          widget.estate
                                                      .guaranteesAndTheirDuration !=
                                                  null
                                              ? buildInfoTile(context,
                                                  label: "الضمانات ",
                                                  value: widget.estate
                                                      .guaranteesAndTheirDuration!)
                                              : SizedBox(),

                                          widget.estate.locationDescriptionOnMOJDeed !=
                                                  null
                                              ? buildInfoTile(context,
                                                  label:
                                                      "وصف العقار حسب صك  :	",
                                                  value: widget.estate
                                                      .locationDescriptionOnMOJDeed!)
                                              : SizedBox(),

                                          widget.estate.numberOfRooms != null
                                              ? buildInfoTile(context,
                                                  label: "عدد الغرف",
                                                  value: widget
                                                      .estate.numberOfRooms!)
                                              : SizedBox(),

                                          widget.estate!.mainLandUseTypeName !=
                                                  null
                                              ? buildInfoTile(context,
                                                  label: "الاستخدام ",
                                                  value: widget.estate!
                                                      .mainLandUseTypeName!)
                                              : SizedBox(),

                                          widget.estate.landNumber != null
                                              ? buildInfoTile(context,
                                                  label: "رقم القطعة",
                                                  value:
                                                      widget.estate.landNumber!)
                                              : SizedBox(),

                                          widget.estate.propertyUtilities !=
                                                  null
                                              ? Container(
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
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
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                  "خدمات العقار"
                                                                      .tr))),
                                                      VerticalDivider(
                                                          width: 1.0),
                                                      Expanded(
                                                          flex: 1,
                                                          child: Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Text(
                                                                  "${widget.estate.propertyUtilities}",
                                                                  style: robotoBlack
                                                                      .copyWith(
                                                                          fontSize:
                                                                              9)))),
                                                    ],
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                      estateController.estate!.deedNumber !=
                                              null
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
                                                              "deed_number"
                                                                  .tr))),
                                                  VerticalDivider(width: 1.0),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  10),
                                                          child: Text(
                                                              estateController
                                                                  .estate!
                                                                  .deedNumber!,
                                                              style: robotoBlack
                                                                  .copyWith(
                                                                      fontSize:
                                                                          14)))),
                                                ],
                                              ),
                                            )
                                          : Container(),

                                      Column(
                                        children: [
                                          // تاريخ الإنشاء
                                          // if (estateController.estate.creationDate != null)
                                          //   buildInfoTile(context, label: "creation_date".tr, value: estateController.estate.creationDate),
                                          //
                                          // // تاريخ الانتهاء
                                          // if (estateController.estate.endDate != null)
                                          //   buildInfoTile(context, label: "end_date".tr, value: estateController.estate.endDate),

                                          // رقم رخصة الإعلان
                                          buildInfoTile(context,
                                              label: "ad_license_number".tr,
                                              value: estateController
                                                  .estate!.adLicenseNumber??""),

                                          // رقم الصك

                                          // رقم ترخيص الوساطة والتسويق
                                          buildInfoTile(context,
                                              label:
                                                  "brokerage_marketing_license"
                                                      .tr,
                                              value: estateController.estate!
                                                  .brokerageAndMarketingLicenseNumber??""),

                                          SizedBox(
                                              height: 10), // مسافة بين العنوان
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: double.infinity,
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 7, vertical: 7),
                                              decoration: BoxDecoration(
                                                color:
                                                    Color(0xFF2252A1), // كحلي
                                                border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1.5),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                "معلومات حدود العقار",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),

                                          SizedBox(
                                              height: 10), // مسافة بين العنوان
                                          // نوع الصك
                                          buildInfoTile(context,
                                              label: "title_deed_type_name".tr,
                                              value: estateController
                                                  .estate!.titleDeedTypeName??""),

                                          // الحد الشمالي
                                          buildInfoTile(context,
                                              label: "north_limit".tr,
                                              value: estateController
                                                  .estate!.northLimit??""),

                                          // الحد الشرقي
                                          buildInfoTile(context,
                                              label: "east_limit".tr,
                                              value: estateController
                                                  .estate!.eastLimit??""),

                                          // الحد الغربي
                                          buildInfoTile(context,
                                              label: "west_limit".tr,
                                              value: estateController
                                                  .estate!.westLimit??""),

                                          // الحد الجنوبي
                                          buildInfoTile(context,
                                              label: "south_limit".tr,
                                              value: estateController
                                                  .estate!.southLimit??""),

                                          // عرض الشارع
                                          buildInfoTile(context,
                                              label: "street_width".tr,
                                              value: estateController
                                                  .estate!.streetWidth??""
                                                  .toString()),

                                          // الواجهة
                                          buildInfoTile(context,
                                              label: "property_face".tr,
                                              value: estateController
                                                  .estate!.propertyFace??""),

                                          // نوع الإعلان
                                          buildInfoTile(context,
                                              label: "advertisement_type".tr,
                                              value: estateController
                                                  .estate!.advertisementType??""),

                                          // رقم الترخيص
                                          buildInfoTile(context,
                                              label: "license_number".tr,
                                              value: estateController
                                                  .estate!.licenseNumber??""),

                                          // رقم المخطط
                                          buildInfoTile(context,
                                              label: "plan_number".tr,
                                              value: estateController
                                                  .estate!.planNumber??""),
                                        ],
                                      ),

                                      // estateController.estate!.networkType!
                                      //             .isNotEmpty &&
                                      //         estateController
                                      //                 .estate!.networkType ==
                                      //             null
                                      //     ? NetworkTypeItem(
                                      //         estate: estateController.estate!,
                                      //         restaurants: estateController
                                      //             .estate!.networkType!)
                                      //     : Container(),
                                      // estateController.estate!.interface! !=
                                      //         null
                                      //     ? InterfaceItem(
                                      //         estate: estateController.estate,
                                      //         restaurants: estateController
                                      //             .estate!.interface)
                                      //     : Container(),
                                      // const MapDetailsView(fromView: true),
                                      // estateController.isLoading! &&  estateController.estate!.otherAdvantages! ==  null
                                      //     ? Container() :
                                      // SizedBox(
                                      //         height: estateController.estate!.otherAdvantages! ==
                                      //                 null
                                      //             ? 0
                                      //             : 120,
                                      //         child: GridView.builder(
                                      //           physics:
                                      //               BouncingScrollPhysics(),
                                      //           itemCount: estateController
                                      //               .estate!
                                      //               .otherAdvantages!
                                      //               .length,
                                      //           gridDelegate:
                                      //               SliverGridDelegateWithFixedCrossAxisCount(
                                      //             crossAxisCount: 3,
                                      //             childAspectRatio: (1 / 0.50),
                                      //           ),
                                      //           itemBuilder: (context, index) {
                                      //             return InkWell(
                                      //               child: Container(
                                      //                 margin: const EdgeInsets
                                      //                     .all(Dimensions
                                      //                         .PADDING_SIZE_EXTRA_SMALL),
                                      //                 padding: const EdgeInsets
                                      //                     .symmetric(
                                      //                   vertical: Dimensions
                                      //                       .PADDING_SIZE_EXTRA_SMALL,
                                      //                   horizontal: Dimensions
                                      //                       .PADDING_SIZE_SMALL,
                                      //                 ),
                                      //                 decoration: BoxDecoration(
                                      //                   color: Theme.of(context)
                                      //                       .cardColor,
                                      //                   borderRadius: BorderRadius
                                      //                       .circular(Dimensions
                                      //                           .RADIUS_SMALL),
                                      //                   boxShadow: [
                                      //                     BoxShadow(
                                      //                         color: Colors
                                      //                                 .grey[
                                      //                             Get.isDarkMode
                                      //                                 ? 800
                                      //                                 : 200]!,
                                      //                         blurRadius: 5,
                                      //                         spreadRadius: 1)
                                      //                   ],
                                      //                 ),
                                      //                 alignment:
                                      //                     Alignment.center,
                                      //                 child: Row(
                                      //                   children: [
                                      //                     SizedBox(
                                      //                         width: Dimensions
                                      //                             .PADDING_SIZE_EXTRA_SMALL),
                                      //                     Flexible(
                                      //                         flex: 1,
                                      //                         child: Text(
                                      //                           estateController
                                      //                               .estate!
                                      //                               .otherAdvantages![index]!
                                      //                               .name!,
                                      //                           style:
                                      //                               robotoMedium
                                      //                                   .copyWith(
                                      //                             fontSize:
                                      //                                 Dimensions
                                      //                                     .fontSizeLarge,
                                      //                             color: Theme.of(
                                      //                                     context)
                                      //                                 .textTheme
                                      //                                 .bodyLarge!
                                      //                                 .color,
                                      //                           ),
                                      //                           maxLines: 2,
                                      //                           overflow:
                                      //                               TextOverflow
                                      //                                   .ellipsis,
                                      //                         )),
                                      //                   ],
                                      //                 ),
                                      //               ),
                                      //             );
                                      //           },
                                      //         )),
                                      //
                                      // Divider(
                                      //   height: 1,
                                      // ),
                                      // Text("other_information".tr,
                                      //     style: robotoBlack.copyWith(
                                      //         fontSize: 14)),
                                      // Container(
                                      //   padding: EdgeInsets.all(10),
                                      //   child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.spaceAround,
                                      //       children: <Widget>[
                                      //         GestureDetector(
                                      //           onTap: () {
                                      //             showDialog(
                                      //               context: context,
                                      //               builder:
                                      //                   (BuildContext context) {
                                      //                 return Get.find<
                                      //                             AuthController>()
                                      //                         .isLoggedIn()
                                      //                     ? Container(child: GetBuilder<
                                      //                             EstateController>(
                                      //                         builder:
                                      //                             (wishController) {
                                      //                         return ReportWidget(key: null, estate_id: estate!.id ?? 0);
                                      //                       }))
                                      //                     : NotLoggedInScreen();
                                      //               },
                                      //             );
                                      //           },
                                      //           child: Container(
                                      //             padding: EdgeInsets.all(10),
                                      //             decoration: BoxDecoration(
                                      //               color: Colors.white,
                                      //               borderRadius:
                                      //                   BorderRadius.circular(
                                      //                       10.0),
                                      //               boxShadow: [
                                      //                 BoxShadow(
                                      //                   color: Theme.of(context)
                                      //                       .primaryColor,
                                      //                   spreadRadius: 1,
                                      //                   blurRadius: 2,
                                      //                   offset: Offset(0,
                                      //                       0.5), // changes position of shadow
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //             child:
                                      //                 Column(children: <Widget>[
                                      //               Image.asset(
                                      //                 Images.space,
                                      //                 height: 70,
                                      //                 width: 70,
                                      //               ),
                                      //               Text('report_the_ad'.tr,
                                      //                   style: robotoBlack
                                      //                       .copyWith(
                                      //                           fontSize: 12)),
                                      //             ]),
                                      //           ),
                                      //         ),
                                      //         GestureDetector(
                                      //           onTap: () {
                                      //             Get.dialog(NearByView(
                                      //               esate: estate,
                                      //             ));
                                      //           },
                                      //           child: Container(
                                      //             padding: EdgeInsets.all(8),
                                      //             decoration: BoxDecoration(
                                      //               color: Colors.white,
                                      //               borderRadius:
                                      //                   BorderRadius.circular(
                                      //                       10.0),
                                      //               boxShadow: [
                                      //                 BoxShadow(
                                      //                   color: Theme.of(context)
                                      //                       .primaryColor,
                                      //                   spreadRadius: 1,
                                      //                   blurRadius: 2,
                                      //                   offset: Offset(0,
                                      //                       0.5), // changes position of shadow
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //             child:
                                      //                 Column(children: <Widget>[
                                      //               Image.asset(
                                      //                 Images.estate_type,
                                      //                 height: 70,
                                      //                 width: 70,
                                      //               ),
                                      //               Text('near_by'.tr,
                                      //                   style: robotoBlack
                                      //                       .copyWith(
                                      //                           fontSize: 13)),
                                      //             ]),
                                      //           ),
                                      //         ),
                                      //         GestureDetector(
                                      //           onTap: () {
                                      //             Get.dialog(OfferList(
                                      //                 estate: estateController
                                      //                     .estate));
                                      //           },
                                      //           child: Container(
                                      //             padding: EdgeInsets.all(10),
                                      //             decoration: BoxDecoration(
                                      //               color: Colors.white,
                                      //               borderRadius:
                                      //                   BorderRadius.circular(
                                      //                       10.0),
                                      //               boxShadow: [
                                      //                 BoxShadow(
                                      //                   color: Theme.of(context)
                                      //                       .primaryColor,
                                      //                   spreadRadius: 1,
                                      //                   blurRadius: 2,
                                      //                   offset: Offset(0,
                                      //                       0.5), // changes position of shadow
                                      //                 ),
                                      //               ],
                                      //             ),
                                      //             child:
                                      //                 Column(children: <Widget>[
                                      //               Image.asset(
                                      //                 Images.space,
                                      //                 height: 70,
                                      //                 width: 70,
                                      //               ),
                                      //               Text(
                                      //                   'deals_with_the_property'
                                      //                       .tr,
                                      //                   style: robotoBlack
                                      //                       .copyWith(
                                      //                           fontSize: 12)),
                                      //             ]),
                                      //           ),
                                      //         )
                                      //       ]),
                                      // ),
                                      //
                                      // SizedBox(height: 10),
                                      // Divider(
                                      //   height: 1,
                                      // ),
                                      // SizedBox(height: 6),
                                      // Container(
                                      //   padding: EdgeInsets.only(
                                      //       right: 20, left: 20),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.white,
                                      //     borderRadius:
                                      //         BorderRadius.circular(4.0),
                                      //     boxShadow: [
                                      //       BoxShadow(
                                      //         color: Theme.of(context)
                                      //             .colorScheme
                                      //             .surface,
                                      //         spreadRadius: 1,
                                      //         blurRadius: 2,
                                      //         offset: Offset(0,
                                      //             0.5), // changes position of shadow
                                      //       ),
                                      //     ],
                                      //   ),
                                      //   child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.spaceBetween,
                                      //       children: <Widget>[
                                      //         Text('رقم رخصة الإعلان'.tr),
                                      //         SizedBox(width: 20),
                                      //         Text(estateController
                                      //             .estate!.adLicenseNumber
                                      //             .toString()),
                                      //         IconButton(
                                      //             onPressed: () {
                                      //               FlutterClipboard.copy(
                                      //                       estateController
                                      //                           .estate!
                                      //                           .adLicenseNumber
                                      //                           .toString())
                                      //                   .then((value) {
                                      //                 showCustomSnackBar(
                                      //                     'copied'.tr,
                                      //                     isError: false);
                                      //               });
                                      //             },
                                      //             icon: Icon(
                                      //               Icons.copy,
                                      //               color: Theme.of(context)
                                      //                   .primaryColor,
                                      //             )),
                                      //       ]),
                                      // ),
                                      //
                                      // SizedBox(height: 6),
                                      // Divider(
                                      //   height: 1,
                                      // ),
                                      //
                                      // Container(
                                      //   padding: EdgeInsets.only(
                                      //       right: 20, left: 20),
                                      //   decoration: BoxDecoration(
                                      //     color: Colors.white,
                                      //     borderRadius:
                                      //         BorderRadius.circular(4.0),
                                      //     boxShadow: [
                                      //       BoxShadow(
                                      //         color: Theme.of(context)
                                      //             .colorScheme
                                      //             .surface,
                                      //         spreadRadius: 1,
                                      //         blurRadius: 2,
                                      //         offset: Offset(0,
                                      //             0.5), // changes position of shadow
                                      //       ),
                                      //     ],
                                      //   ),
                                      //   child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.spaceBetween,
                                      //       children: <Widget>[
                                      //         Text('رقم وثيقة الملكية'.tr),
                                      //         Text(estateController
                                      //             .estate!.deedNumber!),
                                      //         IconButton(
                                      //             onPressed: () {
                                      //               FlutterClipboard.copy(
                                      //                       estateController
                                      //                           .estate!
                                      //                           .deedNumber!)
                                      //                   .then((value) {
                                      //                 showCustomSnackBar(
                                      //                     'copied'.tr,
                                      //                     isError: false);
                                      //               });
                                      //             },
                                      //             icon: Icon(
                                      //               Icons.copy,
                                      //               color: Theme.of(context)
                                      //                   .primaryColor,
                                      //             )),
                                      //       ]),
                                      // ),
                                      //
                                      // SizedBox(height: 6),
                                      // Divider(
                                      //   height: 1,
                                      // ),
                                      // SizedBox(height: 6),
                                      // GestureDetector(
                                      //   onTap: () async {
                                      //     await Get.toNamed(
                                      //         RouteHelper.getProfileAgentRoute(
                                      //             estateController
                                      //                 .estate!.userId!,
                                      //             0));
                                      //   },
                                      //   child: Container(
                                      //     margin: EdgeInsets.only(
                                      //         bottom: Dimensions
                                      //             .PADDING_SIZE_SMALL),
                                      //     padding: EdgeInsets.all(
                                      //         Dimensions.PADDING_SIZE_SMALL),
                                      //     decoration: BoxDecoration(
                                      //       color: Theme.of(context).cardColor,
                                      //       borderRadius: BorderRadius.circular(
                                      //           Dimensions.RADIUS_SMALL),
                                      //       boxShadow: [
                                      //         BoxShadow(
                                      //             color: Colors.grey[
                                      //                 Get.isDarkMode
                                      //                     ? 700
                                      //                     : 300]!,
                                      //             spreadRadius: 1,
                                      //             blurRadius: 5)
                                      //       ],
                                      //     ),
                                      //     child: Row(children: [
                                      //       ClipOval(
                                      //           child: CustomImage(
                                      //         image:
                                      //             '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}'
                                      //             '/${(isLoggedIn) ? userController.agentInfoModel!.image : ''}',
                                      //         height: 100,
                                      //         width: 100,
                                      //         fit: BoxFit.cover,
                                      //       )),
                                      //       SizedBox(
                                      //           width: Dimensions
                                      //               .PADDING_SIZE_SMALL),
                                      //       Expanded(
                                      //           flex: 1,
                                      //           child: Column(
                                      //               crossAxisAlignment:
                                      //                   CrossAxisAlignment
                                      //                       .start,
                                      //               mainAxisAlignment:
                                      //                   MainAxisAlignment
                                      //                       .center,
                                      //               children: [
                                      //                 //  Text("${ _isLoggedIn ? '${userController.agentInfoModel.name}' : 'guest'.tr}", style: robotoMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                                      //                 Text(
                                      //                   estateController
                                      //                       .estate!.users!.name!,
                                      //                   style: robotoMedium.copyWith(
                                      //                       fontSize: Dimensions
                                      //                           .fontSizeDefault),
                                      //                 ),
                                      //                 SizedBox(
                                      //                     height: Dimensions
                                      //                         .PADDING_SIZE_EXTRA_SMALL),
                                      //
                                      //                 Row(children: [
                                      //                   Container(
                                      //                     height: 25,
                                      //                     alignment:
                                      //                         Alignment.center,
                                      //                     padding:
                                      //                         EdgeInsets.only(
                                      //                             right: 4,
                                      //                             left: 4),
                                      //                     decoration:
                                      //                         BoxDecoration(
                                      //                       color: Theme.of(
                                      //                               context)
                                      //                           .primaryColor,
                                      //                       borderRadius:
                                      //                           BorderRadius.circular(
                                      //                               Dimensions
                                      //                                   .RADIUS_SMALL),
                                      //                     ),
                                      //                     child: Center(
                                      //                       child: Text(
                                      //                           estateController
                                      //                               .estate!
                                      //                               .users!
                                      //                               .membershipType!,
                                      //                           style: robotoBold
                                      //                               .copyWith(
                                      //                             color: Theme.of(
                                      //                                     context)
                                      //                                 .cardColor,
                                      //                             fontSize:
                                      //                                 Dimensions
                                      //                                     .fontSizeDefault,
                                      //                           )),
                                      //                     ),
                                      //                   ),
                                      //                   Expanded(
                                      //                       flex: 1,
                                      //                       child: SizedBox()),
                                      //                 ]),
                                      //                 SizedBox(height: 4),
                                      //                 Row(
                                      //                   children: [
                                      //                     Text(
                                      //                       "advertiser_no".tr,
                                      //                       style: robotoRegular.copyWith(
                                      //                           fontSize: Dimensions
                                      //                               .fontSizeLarge,
                                      //                           color: Theme.of(
                                      //                                   context)
                                      //                               .disabledColor),
                                      //                     ),
                                      //                     SizedBox(width: 20),
                                      //                     Text(
                                      //                       estateController
                                      //                           .estate!
                                      //                           .users!
                                      //                           .phone!,
                                      //                       style: robotoRegular.copyWith(
                                      //                           fontSize: Dimensions
                                      //                               .fontSizeLarge,
                                      //                           color: Theme.of(
                                      //                                   context)
                                      //                               .disabledColor),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //                 Row(
                                      //                   children: [
                                      //                     Text(
                                      //                       "date_of_publication"
                                      //                           .tr,
                                      //                       style: robotoRegular.copyWith(
                                      //                           fontSize: Dimensions
                                      //                               .fontSizeLarge,
                                      //                           color: Theme.of(
                                      //                                   context)
                                      //                               .disabledColor),
                                      //                     ),
                                      //                     SizedBox(width: 20),
                                      //                     Text(
                                      //                       estateController
                                      //                               .estate!
                                      //                               .createdAt ??
                                      //                           "",
                                      //                       style: robotoRegular.copyWith(
                                      //                           fontSize: Dimensions
                                      //                               .fontSizeDefault,
                                      //                           color: Theme.of(
                                      //                                   context)
                                      //                               .disabledColor),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //               ])),
                                      //     ]),
                                      //   ),
                                      // ),
                                      // !userController.isLoading
                                      //     ? CustomButton(
                                      //         onPressed: () async {
                                      //           await Get.toNamed(
                                      //               RouteHelper.getChatRoute(
                                      //                   notificationBody:
                                      //                       NotificationBody(
                                      //                           orderId:
                                      //                               estateController
                                      //                                   .estate!
                                      //                                   .id,
                                      //                           restaurantId:
                                      //                               estateController
                                      //                                   .estate!
                                      //                                   .userId),
                                      //                   user: Userinfo(
                                      //                     id: estateController
                                      //                         .estate!.userId,
                                      //                     name: userController
                                      //                         .agentInfoModel!
                                      //                         .name,
                                      //                     image: userController
                                      //                         .agentInfoModel!
                                      //                         .image,
                                      //                   ),
                                      //                   estate_id:
                                      //                       widget.estate.id));
                                      //         },
                                      //         buttonText:
                                      //             'contact_the_advertiser'.tr,
                                      //       )
                                      //     : Center(child: Container()),
                                    ],
                                  ))
                            ],
                          )
                        : const SizedBox();
                  });
          });
        }),
      ),
    );
  }

  // buildDynamicLinks(
  //     String title, String image, String docId, String phone) async {
  //   String url = "https://abaad.page.link";
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

  __launchWhatsapp(String number) async {
    var whatsapp = number;
    var whatsappAndroid = Uri.parse(
        "whatsapp://send?phone=$whatsapp&text=مرحبا  لديك عرض  في تطبيق ابعاد");
    if (await canLaunchUrl(whatsappAndroid)) {
      await launchUrl(whatsappAndroid);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("WhatsApp is not installed on the device"),
        ),
      );
    }
  }
}

Widget buildInfoTile(BuildContext context,
    {String? label, required String value}) {
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
            child: Text(label!),
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
                    value,
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
                    color: isExpired! ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isExpired! ? "غير نشط" : "نشط",
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
  String? label,
  String? value,
  bool? isExpired,
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
            child: Text(label!, style: TextStyle(fontWeight: FontWeight.w500)),
          ),
        ),
        VerticalDivider(width: 1.0),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.all(10),
            child: Text(
              value!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isExpired! ? Colors.red : Colors.green,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

String formatPrice(String priceStr) {
  final num? price = num.tryParse(priceStr!);

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
