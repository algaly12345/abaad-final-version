//import 'dart:ui_web' as ui;
import 'package:flutter/widgets.dart';

import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/html_type.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';
import 'package:universal_html/html.dart' as html;
//import 'package:universal_ui/universal_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HtmlViewerScreen extends StatelessWidget {
  final HtmlType htmlType;
    const HtmlViewerScreen({super.key, required this.htmlType});

  @override
  Widget build(BuildContext context) {
    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';
    String? data = htmlType == HtmlType.TERMS_AND_CONDITION ? Get.find<SplashController>().configModel!.termsAndConditions
        : htmlType == HtmlType.ABOUT_US ? Get.find<SplashController>().configModel!.aboutUs
        : htmlType == HtmlType.PRIVACY_POLICY ? Get.find<SplashController>().configModel!.privacyPolicy
        : null;

    if (data?.isNotEmpty == true) {
      data = data!.replaceAll('href=', 'target="_blank" href=');
    }


    String viewID = htmlType.toString();

    // TODO: fix this code 2025
    if(GetPlatform.isWeb) {
      // try{
      //   ui.platformViewRegistry.registerViewFactory(viewID, (int viewId) {
      //     html.IFrameElement ife = html.IFrameElement();
      //     ife.width = Dimensions.WEB_MAX_WIDTH.toString();
      //     ife.height = MediaQuery.of(context).size.height.toString();
      //     ife.srcdoc = data;
      //     ife.contentEditable = 'false';
      //     ife.style.border = 'none';
      //     ife.allowFullscreen = true;
      //     return ife;
      //   });
      // }catch(e) {}
    }
    return Scaffold(
      appBar: CustomAppBar(title: htmlType == HtmlType.TERMS_AND_CONDITION ? 'terms_conditions'.tr
          : htmlType == HtmlType.ABOUT_US ? 'about_us'.tr : htmlType == HtmlType.PRIVACY_POLICY
          ? 'privacy_policy'.tr :  htmlType == HtmlType.SHIPPING_POLICY ? 'shipping_policy'.tr
          : htmlType == HtmlType.REFUND_POLICY ? 'refund_policy'.tr :  htmlType == HtmlType.CANCELLATION_POLICY
          ? 'cancellation_policy'.tr  : 'no_data_found'.tr),
      body: Center(
        child: Container(
          width: Dimensions.WEB_MAX_WIDTH,
          height: MediaQuery.of(context).size.height,
          color: GetPlatform.isWeb ? Colors.white : Theme.of(context).cardColor,
          child: GetPlatform.isWeb ? Column(
            children: [
              Container(
                height: 50, alignment: Alignment.center,
                child: SelectableText(htmlType == HtmlType.TERMS_AND_CONDITION ? 'terms_conditions'.tr
                    : htmlType == HtmlType.ABOUT_US ? 'about_us'.tr : htmlType == HtmlType.PRIVACY_POLICY
                    ? 'privacy_policy'.tr : htmlType == HtmlType.SHIPPING_POLICY ? 'shipping_policy'.tr
                    : htmlType == HtmlType.REFUND_POLICY ? 'refund_policy'.tr :  htmlType == HtmlType.CANCELLATION_POLICY
                    ? 'cancellation_policy'.tr  : 'no_data_found'.tr,
                  style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Colors.black),
                ),
              ),
              Expanded(child: IgnorePointer(child: HtmlElementView(viewType: viewID, key: Key(htmlType.toString())))),
            ],
          ) :  htmlType == HtmlType.TERMS_AND_CONDITION ?  DefaultTabController(
            length: 2, // Number of tabs
            child:
            Scaffold(
              body: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).primaryColor, Theme.of(context).primaryColor],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 6),
                      ],
                    ),
                    child: SafeArea(
                      child: TabBar(
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(width: 4, color: Colors.white),
                        ),
                        labelStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        unselectedLabelStyle: TextStyle(fontSize: 16),
                        tabs: [
                          Tab(text: 'advertising_terms'.tr),
                          Tab(text: 'terms_use'.tr),

                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        buildTabContent(isArabic ? (Get.find<SplashController>().configModel?.termsConditionsAr ?? "") : (Get.find<SplashController>().configModel?.termsConditions ?? "")),
                        buildTabContent(isArabic ? (Get.find<SplashController>().configModel?.termsConditionsAr ?? "") : (Get.find<SplashController>().configModel?.termsConditions ?? "")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ):htmlType == HtmlType.ABOUT_US ?   buildTabContent(isArabic ? (Get.find<SplashController>().configModel?.aboutUsAr ?? "") : (Get.find<SplashController>().configModel?.aboutUs ?? "")) :buildTabContent(isArabic ? (Get.find<SplashController>().configModel?.privacyPolicyAr ?? "") : (Get.find<SplashController>().configModel?.privacyPolicy ?? "")),
        ),
      ),
    );
  }


  Widget buildTabContent(String text) {
    return  SingleChildScrollView(
      child: HtmlWidget(text),
    );
  }
}