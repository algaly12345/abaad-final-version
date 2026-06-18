import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/wishlist_controller.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/view/base/estate_item.dart';
import 'package:abaad_flutter/view/base/not_logged_in_screen.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../base/details_dilog.dart';


class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  _FavouriteScreenState createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    Get.find<WishListController>().getWishList();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Get.find<AuthController>().isLoggedIn() ? Container(child:      GetBuilder<WishListController>(builder: (wishController) {
        return RefreshIndicator(
          onRefresh: () async {
            await wishController.getWishList();
          },
          child:ListView.builder(
            physics: BouncingScrollPhysics(),
            itemCount:  wishController.wishRestList?.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              return  GetBuilder<WishListController>(builder: (wishController) {
                return  EstateItem(estate: wishController.wishRestList?[index],onPressed: (){
                  // Get.find<UserController>().getUserInfoByID(wishController.wishRestList[index].userId);
                Get.dialog(DettailsDilog(estate:wishController.wishRestList![index]));
               //   showCustomSnackBar("${wishController.wishRestList[index].estate_id}");
            //
                  //  Get.toNamed(RouteHelper.getDetailsRoute( (wishController.wishRestList![index].estate_id ?? 0) ));
                },fav: true,isMyProfile: 0);
              });
            },
          ),
        );
      })) : NotLoggedInScreen(),
    );
  }
}













