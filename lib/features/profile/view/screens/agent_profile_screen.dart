// import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
// import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
// import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
// import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
// import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
// import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
// import 'package:abaad_flutter/core/routes/route_helper.dart';
// import 'package:abaad_flutter/shared/utils/dimensions.dart';
// import 'package:abaad_flutter/shared/utils/styles.dart';
// import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
// import 'package:abaad_flutter/shared/widgets/custom_image.dart';
// import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
// import 'package:abaad_flutter/shared/widgets/estate_item.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:url_launcher/url_launcher.dart';
//
// import '../../../util/images.dart';
// import '../../base/details_dilog.dart';
// import '../profile/widget/profile_bg_widget.dart';
//
//
// class AgentProfileScreen extends StatefulWidget {
//   final Userinfo? userInfo;
//   final int?  isMyProfile;
//    const AgentProfileScreen({  Key? key,  this.userInfo ,this.isMyProfile}) : super(key: key);
//
//   @override
//   State<AgentProfileScreen> createState() => _AgentProfileScreenState();
// }
//
// class _AgentProfileScreenState extends State<AgentProfileScreen> {
//   bool? _isLoggedIn;
//
//   @override
//   void initState() {
//     super.initState();
//      _isLoggedIn = Get.find<AuthController>().isLoggedIn();
//
//     Get.find<AuthController>().getZoneList();
//     Get.find<UserController>().getEstateByUser(1, false,widget.userInfo!.id ?? 0);
//
//
//
//
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             Get.offAllNamed(RouteHelper.getInitialRoute());
//           },
//         ),
//         title: Text('الملف الشخصي'),
//       ),
//       backgroundColor: Theme.of(context).cardColor,
//       body: GetBuilder<UserController>(builder: (userController) {
//     return   GetBuilder<UserController>(builder: (restController) {
//
//
//       // Get.find<UserController>().getUserInfoByID(userController.userInfoModel?.id ?? 0 );
//       // Get.find<UserController>().getEstateByUser(1, false,userController.userInfoModel?.id ?? 0 );
//       // Get.toNamed(RouteHelper.getProfileRoute());
//         return (_isLoggedIn! && userController.agentInfoModel == null ) ? Center(child: CircularProgressIndicator()) :( restController.estateModel!.estates != null) ?  Padding(
//           padding: const EdgeInsets.only(right: 0.0,left: 0.0),
//           child: ProfileBgWidget(
//
//             backButton: true,
//
//             circularImage: Container(
//               decoration:  BoxDecoration(
//                   image:  DecorationImage(
//                     image:  AssetImage(Images.background),
//                     fit: BoxFit.cover,
//                   )
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Row(
//                       children: [
//                          Stack(
//                           children: [
//                             Container(
//                               height: 80,
//                               width: 80,
//                               padding: EdgeInsets.all(7),
//                               child:  Container   (
//                                 decoration: BoxDecoration(
//                                   border: Border.all(width: 2, color: Theme.of(context).primaryColor),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 alignment: Alignment.topRight,
//                                 child: ClipOval(child: CustomImage(
//                                   image: '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}''/${userController.agentInfoModel!.image }',
//                                   height: 80, width: 80, fit: BoxFit.cover,
//                                 )),
//                               ),
//                             ),
//                             Positioned(
//                               right: 0,
//                               child: Container(
//                                 height: 22,
//                                 width: 22,
//                                 decoration: BoxDecoration(
//                                   color: Colors.blue,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(color: Colors.white, width: 2),
//                                 ),
//                                 child: const Icon(
//                                   Icons.online_prediction_sharp,
//                                   color: Colors.white,
//                                   size: 15,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         Expanded(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children:  [
//                               Column(
//                                 children: [
//                                   Text(
//                                     "advertiser_type".tr,
//                                     style:   robotoMedium.copyWith(
//                                         fontSize: Dimensions.fontSizeSmall),
//                                   ),
//                           Text(
//                              userController.agentInfoModel!.membershipType ?? '',
//                             style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),)
//
//
//                                 ],
//                               ),
//                               Column(
//                                 children: [
//                                   Text(
//                                     "number_of_ads".tr,
//                                       style:  robotoRegular.copyWith(
//                                           fontSize: Dimensions.fontSizeSmall),
//                                   ),
//                                   Text("${restController.estateModel!.totalSize}", style:  robotoRegular.copyWith(
//                                       fontSize: Dimensions.fontSizeSmall)),
//                                 ],
//                               ),
//
//                             ],
//                           ),
//                         ),
//                       ],
//                   ),
//
//                    Padding(
//                      padding: const EdgeInsets.only(right: 5,left: 5,top: 5,bottom: 5),
//                      child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                      Text(
//                      userController.agentInfoModel!.name!,
//                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeDefault),
//                      ),
//                         SizedBox(height: 4),
//                         widget.isMyProfile==1? Text(   userController.agentInfoModel!.phone!,
//                           style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
//                         ):Container(),
//                         SizedBox(height: 4),
// // RatingBar(rating: 4, ratingCount: 4)     ,
// //                       Text(
// //                        '${userController.agentInfoModel.userinfo.membershipType!=null?userController.agentInfoModel.userinfo.membershipType:''}',
// //                        style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall),
// //                      ),
// //
//
//                         Row(
//                           children: [
//                             Text(
//                               "رقم رخصة فال ".tr,
//                               style:  robotoRegular.copyWith(
//                                   fontSize: Dimensions.fontSizeSmall),
//                             ),
//                             SizedBox(width: 7,),
//                             Text(
//                                 userController.agentInfoModel!.agent!.falLicenseNumber??'' ,
//                                 style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall)),
//                           ],
//                         ),
//                         SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Expanded(
//                                 child:ElevatedButton.icon(
//                                     style: ButtonStyle(
//                                       backgroundColor: WidgetStateProperty.all(Colors.blue),
//                                     ),
//                                     onPressed: ()async{
//                                       // __launchWhatsapp(userController.agentInfoModel!.phone!, userController.agentInfoModel!.name!);
//                                       final Uri whatsappUrl = Uri.parse("https://wa.me/${userController.agentInfoModel!.phone!}?text=${Uri.encodeFull("")}");
//
//     if (await canLaunchUrl(whatsappUrl)) {
//     await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
//
//
//                                       } else {
//                                       // التعامل مع الخطأ
//                                       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//                                       content: Text("لا يمكن فتح واتساب"),
//                                       ));
//                                       }
//                                     }, icon: Icon(Icons.whatshot_rounded,color: Colors.white), label: Text("whatsapp".tr,style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.white))),
//                             ),
//                             const SizedBox(width:5),
//                             Expanded(
//                               child:ElevatedButton.icon(
//                                   style: ButtonStyle(
//                                     backgroundColor: WidgetStateProperty.all(Colors.blue),
//                                   ),
//                                   onPressed: ()async{
//                                     showCustomSnackBar("غير متاحة حاليا");
//                                     // await Get.toNamed(RouteHelper.getChatRoute(
//                                     //     notificationBody: NotificationBody(orderId: 1 ,restaurantId:userController.agentInfoModel!.id),
//                                     //     user: Userinfo(id: userController.agentInfoModel!.id, name: userController.agentInfoModel!.name,  image: userController.agentInfoModel!.image,),estate_id: 0
//                                     //
//                                     // ));
//                                   }, icon: Icon(Icons.chat,color: Colors.white), label: Text("conversation".tr,style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.white))),
//                             ),
//                              SizedBox(width:5),
//                             Expanded(
//                               child:ElevatedButton.icon(
//                                   style: ButtonStyle(
//                                     backgroundColor: WidgetStateProperty.all(Colors.blue),
//                                   ),
//                                   onPressed: () async{
//                                     final urlScheme = 'tel:${userController.agentInfoModel!.phone}';
//
//                                     if (await canLaunch(urlScheme)) {
//                                     await launch(urlScheme);
//                                     } else {
//                                     throw 'Could not make a phone call.';
//                                     }
//
//                               }, icon: Icon(Icons.call,color: Colors.white), label: Text("call".tr,style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeSmall,color: Colors.white))),
//                             ),
//                           ],
//                         ),
//
//                         SizedBox(height: 4,),
//
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: <Widget>[
//                             // SocialIcon(
//                             //   color: Color(0xFF102397),
//                             //   iconData:Images.facebook,
//                             //   onPressed: () {
//                             //     _launchURL(userController.agentInfoModel.);
//                             //   },
//                             // ),
//
//                             SocialIcon(
//                               color: Color(0xFF102397),
//                               iconData:Images.tiktok,
//                               onPressed: () async{
//
//                                 String tiktokProfileUrl = 'https://www.tiktok.com/@${userController.agentInfoModel!.tiktok}'; // Replace 'username' with the desired username
//                                 if (await canLaunch(tiktokProfileUrl)) {
//                                 await launch(tiktokProfileUrl);
//                                 } else {
//                                 throw 'Could not launch $tiktokProfileUrl';
//                                 }
//
//                               },
//                             ),
//                             SocialIcon(
//                               color: Color(0xff58b3f5),
//                               iconData:Images.snap,
//                               onPressed: () async{
//
//
//                                 String tiktokProfileUrl = userController.agentInfoModel?.snapchat ?? ""; // Replace 'username' with the desired username
//
//                                 if (await canLaunch(tiktokProfileUrl)) {
//                                   await launch(tiktokProfileUrl);
//                                 } else {
//                                   throw 'Could not launch Snapchat.';
//                                 }
//                               },
//                             ),
//                             SocialIcon(
//                               color: Color(0xFF38A1F3),
//                               iconData:Images.website,
//                               onPressed: () {
//                                 _launchURL(userController.agentInfoModel?.website ?? "");
//                               },
//                             ),
//                             SocialIcon(
//                               color: Color(0xFF2867B2),
//                               iconData:Images.twiter,
//                               onPressed: () {
//                                 _launchURL(userController.agentInfoModel?.twitter ?? "");
//                               },
//                             ),
//                             SocialIcon(
//                               color: Color(0xFF38A1F3),
//                               iconData:Images.instgram,
//                               onPressed: () {
//                                 _launchURL(userController.agentInfoModel?.instagram ?? "");
//                               },
//                             ),
//                             SocialIcon(
//                               color: Color(0xFF146522),
//                               iconData:Images.youtube,
//                               onPressed: () {
//                                 _launchURL(userController.agentInfoModel?.youtube ?? "");
//                               },
//                             ),
//
//                           ],
//                         )
//
//
//                       ],
//                   ),
//                    )
//                 ],
//               ),
//             ),
//             mainWidget: Scrollbar( child: Center(child:ListView.builder(
//               physics: BouncingScrollPhysics(),
//               itemCount:  restController.estateModel?.estates?.length,
//               scrollDirection: Axis.vertical,
//
//               itemBuilder: (context, index) {
//                 return  GetBuilder<EstateController>(builder: (wishController) {
//                   return  Padding(
//                     padding: const EdgeInsets.only(top: 2,bottom: 2),
//                     child: EstateItem(estate: restController.estateModel!.estates![index],onPressed: (){
//                       Get.dialog(DettailsDilog(estate:restController.estateModel!.estates![index]));
//                     //  showCustomSnackBar("-------${restController.estateModel!.estates![index].id!}");
//                     //  Get.toNamed(RouteHelper.getDetailsRoute( restController.estateModel!.estates![index].id!));
//                     },fav: false,isMyProfile: widget!.isMyProfile!),
//                   );
//                 });
//               },
//             ))),
//
//           ),
//         ): const Center(child: CircularProgressIndicator());
//       });
//       }),
//     );
//   }
//
//   __launchWhatsapp(String  number,String name) async {
//     var whatsapp = number;
//     var whatsappAndroid =Uri.parse("whatsapp://send?phone=$whatsapp&text=مرحبا  $name");
//     if (await canLaunchUrl(whatsappAndroid)) {
//       await launchUrl(whatsappAndroid);
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("WhatsApp is not installed on the device"),
//         ),
//       );
//     }
//   }
//
// }
//
//
//
// class SocialIcon extends StatelessWidget {
//   final Color? color;
//   final String?  iconData;
//   final Function? onPressed;
//
//   const SocialIcon({super.key, this.color, this.iconData, this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(left: 12.0),
//       child: Container(
//         width: 40.0,
//         height: 40.0,
//         decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             border: Border.all(width: 1, color: Colors.blue)
//         ),
//         child: RawMaterialButton(
//           shape: CircleBorder(),
//           onPressed: onPressed as VoidCallback?,
//           child:Image.asset(iconData ?? "",height: 30,width: 30),
//         ),
//       ),
//     );
//   }
// }
//
//
// _launchURL( String link) async {
//   //showCustomSnackBar(link);
//   final url = Uri.parse(
//     link,
//   );
//   if (await canLaunchUrl(url)) {
//     launchUrl(url);
//   } else {
//     // ignore: avoid_print
//     showCustomSnackBar("لايوجد رابط");
//   }
//
//
// }




import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/estate_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../util/images.dart';
import '../../base/details_dilog.dart';

class AgentProfileScreen extends StatefulWidget {
  final Userinfo? userInfo;
  final int? isMyProfile;

  const AgentProfileScreen({Key? key, this.userInfo, this.isMyProfile}) : super(key: key);

  @override
  State<AgentProfileScreen> createState() => _AgentProfileScreenState();
}

class _AgentProfileScreenState extends State<AgentProfileScreen> {
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Get.find<AuthController>().getZoneList();
    Get.find<UserController>().getEstateByUser(1, false, widget.userInfo?.id ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F9FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text("الملف الشخصي"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Get.offAllNamed(RouteHelper.getInitialRoute());
          },
        ),
      ),
      body: GetBuilder<UserController>(
        builder: (userController) {
          return GetBuilder<UserController>(
            builder: (restController) {
              if (_isLoggedIn == true && userController.agentInfoModel == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (restController.estateModel?.estates == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final agent = userController.agentInfoModel;
              final estates = restController.estateModel?.estates ?? [];

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildHeader(context, userController, restController),
                        const SizedBox(height: 16),
                        _buildStatsSection(restController, agent),
                        const SizedBox(height: 16),
                        _buildActionButtons(agent),
                        const SizedBox(height: 16),
                        _buildSocialSection(agent),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const Icon(Icons.real_estate_agent, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                "إعلانات المعلن",
                                style: robotoMedium.copyWith(
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GetBuilder<EstateController>(
                              builder: (wishController) {
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: EstateItem(
                                      estate: estates[index],
                                      onPressed: () {
                                        Get.dialog(
                                          DettailsDilog(estate: estates[index]),
                                        );
                                      },
                                      fav: false,
                                      isMyProfile: widget.isMyProfile ?? 0,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        childCount: estates.length,
                      ),
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserController userController, UserController restController) {
    final agent = userController.agentInfoModel;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xff0F4C81),
            Color(0xff3A7BD5),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: CustomImage(
                        image:
                        '${Get.find<SplashController>().configModel!.baseUrls!.customerImageUrl}/${agent?.image ?? ''}',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agent?.name ?? "",
                      style: robotoMedium.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        agent?.membershipType ?? "معلن عقاري",
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.isMyProfile == 1)
                      Text(
                        agent?.phone ?? "",
                        style: robotoRegular.copyWith(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _infoChip(
                  icon: Icons.verified_user_outlined,
                  title: "رقم رخصة فال",
                  value: agent?.agent?.falLicenseNumber ?? "--",
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(UserController restController, dynamic agent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              "عدد الإعلانات",
              "${restController.estateModel?.totalSize ?? 0}",
              Icons.campaign_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _statCard(
              "نوع المعلن",
              agent?.membershipType ?? "--",
              Icons.badge_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(dynamic agent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              title: "واتساب",
              icon: Icons.chat,
              color: const Color(0xff25D366),
              onTap: () async {
                final Uri whatsappUrl = Uri.parse(
                  "https://wa.me/${agent?.phone ?? ''}?text=${Uri.encodeFull("")}",
                );

                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
                } else {
                  showCustomSnackBar("لا يمكن فتح واتساب");
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              title: "اتصال",
              icon: Icons.call,
              color: const Color(0xff0F4C81),
              onTap: () async {
                final Uri phoneUri = Uri.parse("tel:${agent?.phone ?? ''}");
                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  showCustomSnackBar("تعذر إجراء الاتصال");
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _actionButton(
              title: "محادثة",
              icon: Icons.message_outlined,
              color: Colors.orange,
              onTap: () {
                showCustomSnackBar("غير متاحة حاليا");
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(dynamic agent) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.public, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                "روابط التواصل",
                style: robotoMedium.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SocialIcon(
                iconData: Images.tiktok,
                onPressed: () async {
                  final link = 'https://www.tiktok.com/@${agent?.tiktok ?? ''}';
                  _launchURL(link);
                },
              ),
              SocialIcon(
                iconData: Images.snap,
                onPressed: () => _launchURL(agent?.snapchat ?? ""),
              ),
              SocialIcon(
                iconData: Images.website,
                onPressed: () => _launchURL(agent?.website ?? ""),
              ),
              SocialIcon(
                iconData: Images.twiter,
                onPressed: () => _launchURL(agent?.twitter ?? ""),
              ),
              SocialIcon(
                iconData: Images.instgram,
                onPressed: () => _launchURL(agent?.instagram ?? ""),
              ),
              SocialIcon(
                iconData: Images.youtube,
                onPressed: () => _launchURL(agent?.youtube ?? ""),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(height: 10),
          Text(
            title,
            style: robotoRegular.copyWith(fontSize: 13, color: Colors.grey[700]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: robotoMedium.copyWith(fontSize: 15, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            "$title: ",
            style: robotoRegular.copyWith(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(
          title,
          style: robotoMedium.copyWith(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class SocialIcon extends StatelessWidget {
  final String? iconData;
  final VoidCallback? onPressed;

  const SocialIcon({super.key, this.iconData, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xffF4F7FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Center(
          child: Image.asset(
            iconData ?? "",
            height: 24,
            width: 24,
          ),
        ),
      ),
    );
  }
}

_launchURL(String link) async {
  if (link.trim().isEmpty) {
    showCustomSnackBar("لا يوجد رابط");
    return;
  }

  final url = Uri.parse(link);

  if (await canLaunchUrl(url)) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
  } else {
    showCustomSnackBar("لا يوجد رابط صالح");
  }
}