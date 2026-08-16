import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/favourite/controller/wishlist_controller.dart';
import 'package:abaad_flutter/shared/widgets/estate_item.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:abaad_flutter/shared/widgets/details_dilog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<WishListController>().getWishList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    if (!authController.isLoggedIn()) {
      return const NotLoggedInScreen();
    }

    return Scaffold(
      body: GetBuilder<WishListController>(
        builder: (wishController) {
          final estates = wishController.wishRestList ?? [];

          if (estates.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                await wishController.getWishList();
              },
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 300),
                  Center(
                    child: Text(
                      'لا توجد عقارات في المفضلة',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await wishController.getWishList();
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              itemCount: estates.length,
              itemBuilder: (context, index) {
                final estate = estates[index];

                return EstateItem(
                  estate: estate,
                  fav: true,
                  isMyProfile: 0,
                  onPressed: () {
                    Get.dialog(
                      DettailsDilog(
                        estate: estate,
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}