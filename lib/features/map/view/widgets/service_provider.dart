import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/features/map/view/widgets/service_offer.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:abaad_flutter/shared/utils/images.dart';
class ServiceProviderItem extends StatelessWidget {
  final Estate estate;

  const ServiceProviderItem({Key? key,required this.estate}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    bool isNull = true;
    int length = 0;

    isNull = estate == null;
    if(!isNull) {
      //print("---------------------------------------4${estate.id}");
      length = estate.serviceOffers!.length;
    return
      !isNull ? length > 0 ? Container(
      height: 270,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.surface,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 0.5), // changes position of shadow
          ),

        ],

      ),
      child:  ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: estate.serviceOffers! .length,
        itemBuilder: (context, index) {
          return
            Container(
            padding: const EdgeInsets.only(right: 4,bottom: 5),
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
                          border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                          shape: BoxShape.circle,
                        ),
                        child:  GetBuilder<SplashController>(builder: (splashController) {
                          String baseUrl = Get.find<SplashController>().configModel!.baseUrls!.provider;
                          //   //print("------------${'$_baseUrl/${estateController.estate.serviceOffers[index].imageCover}'}");
                          return ClipOval(
                            child: CustomImage(
                              image: '$baseUrl/${estate.serviceOffers![index].image}',
                              fit: BoxFit.cover,
                              height: 35,
                              width: 35,
                            ),
                          );
                        },
                        ),
                      ),
                      const SizedBox(width: 3.0),
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [




                        Container(

                          child: Text(
                            (estate.serviceOffers![index].title ?? "").length > 30
                                ? (estate.serviceOffers![index].title ?? "").substring(0, 30) + "..."
                                : (estate.serviceOffers![index].title ?? ""),
                            style: robotoBlack.copyWith(fontSize: 11),
                          ),


                        ),
                        Container(

                          child:  Text(
                            estate.serviceOffers![index].provider_name ?? "",
                            style: robotoBlack.copyWith(fontSize: 11),
                          ),
                        ),



                        const SizedBox(height: 3.0),
                        Row(
                          children: [
                           estate.serviceOffers![index].servicePrice!=null?Text("price".tr  , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge)):Text("discount".tr  , style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge)),
                            SizedBox(width: 11.0),
                           estate.serviceOffers![index].discount!=null?  SizedBox(
                              height: 16,
                              width: 44,
                              child: CustomPaint(
                                painter: PriceTagPaint(),
                                child: Center(
                                  child: Text(
                                      "${estate.serviceOffers![index].discount}%",
                                      style: robotoBlack.copyWith(fontSize: 10,color: Colors.white)
                                  ),
                                ),
                              ),
                            ):Text(" ${estate.serviceOffers![index].servicePrice} ريال "  ,style: robotoBlack.copyWith(fontSize: 11)),

                            const SizedBox(width: 8),
                            // أيقونة الاتصال
                            InkWell(
                              onTap: () async{
                                final phoneNumber = estate.serviceOffers![index].phoneProvider;
                               // //print("----------${phoneNumber}");// رقم الهاتف بدون "+" وبصيغة دولية
                                final estateId = estate.id; // تأكد أن الـ ID موجود لديك
                                final estateUrl = '${AppConstants.BASE_URL}/details/$estateId';
                                final message = Uri.encodeComponent(
                                  "عرض داخل العقار مقدم من منصة أبعاد\n$estateUrl",
                                );
                                final url = "https://wa.me/$phoneNumber?text=$message";

                                if (await canLaunchUrl(Uri.parse(url))) {
                                await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                                } else {
                                //print("لا يمكن فتح واتساب");
                                }

                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade700,
                                  shape: BoxShape.circle,
                                ),
                                child:      Image.asset(Images.whatsapp, height: 12, width: 12),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // أيقونة الواتساب
                            InkWell(
                              onTap: () async{
                                final phoneNumber = estate.serviceOffers![index].phoneProvider;
                                final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

                                if (await canLaunchUrl(phoneUri)) {
                                await launchUrl(phoneUri);
                                } else {
                                //print("لا يمكن فتح الاتصال");
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.phone, color: Colors.white, size: 12),
                              ),
                            ),

                          ],
                        ),


                      ])
                    ],
                  ),

                // Divider(color: Colors.grey.shade600, height: 1.0)
              ],
            ),
          );
        },
      ),
    ):Text(""):Text("");
  }

    return Text("No content");
}}
