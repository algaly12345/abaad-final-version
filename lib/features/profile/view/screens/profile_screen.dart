import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/confirmation_dialog.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (Get.find<AuthController>().isLoggedIn() &&
        Get.find<UserController>().userInfoModel == null &&
        !Get.find<UserController>().isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Get.find<UserController>().getUserInfo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.find<AuthController>().isLoggedIn()) {
      return const NotLoggedInScreen();
    }

    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: GetBuilder<UserController>(
        builder: (userCtrl) {
          if (userCtrl.isLoading && userCtrl.userInfoModel == null) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: primary,
                title: Text('profile'.tr,
                    style: robotoBold.copyWith(color: Colors.white)),
                centerTitle: true,
                elevation: 0,
                foregroundColor: Colors.white,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          final user = userCtrl.userInfoModel;
          final imageUrl =
              '${Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl ?? ''}/${user?.image ?? ''}';

          final String membershipType = user?.membershipType ?? '';
          final bool showMembership = membershipType.isNotEmpty &&
              membershipType != 'string' &&
              membershipType != 'null';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Gradient SliverAppBar ────────────────────────────────────
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                backgroundColor: primary,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  'profile'.tr,
                  style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [primary, primary.withValues(alpha: 0.72)],
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),

                          // Avatar
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 12,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: CustomImage(
                                    image: imageUrl,
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Get.toNamed(
                                    RouteHelper.getUpdateProfileRoute()),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.15),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Icon(Icons.edit_rounded,
                                      size: 14, color: primary),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Name
                          Text(
                            user?.name ?? '',
                            style: robotoBold.copyWith(
                                fontSize: 18, color: Colors.white),
                          ),

                          // Phone
                          if ((user?.phone ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                user!.phone!,
                                style: robotoRegular.copyWith(
                                  fontSize: 13,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ),

                          // Membership badge
                          if (showMembership)
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  membershipType,
                                  style: robotoMedium.copyWith(
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Body ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    children: [
                      // My Account section
                      _SectionCard(
                        title: 'my_account'.tr,
                        icon: Icons.person_outline_rounded,
                        primary: primary,
                        items: [
                          _TileItem(
                            icon: Icons.home_work_outlined,
                            color: const Color(0xFF2196F3),
                            title: 'my_ads'.tr,
                            onTap: () {
                              Get.find<UserController>()
                                  .getUserInfoByID(user?.id ?? 0);
                              Get.toNamed(RouteHelper.getProfileAgentRoute(
                                  user?.id ?? 0, 1));
                            },
                          ),
                          _TileItem(
                            icon: Icons.account_balance_wallet_outlined,
                            color: const Color(0xFF4CAF50),
                            title: 'wallet'.tr,
                            onTap: () =>
                                Get.toNamed(RouteHelper.getWalletRoute(true)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Settings shortcut
                      _SingleTile(
                        icon: Icons.settings_outlined,
                        color: primary,
                        title: 'app_settings'.tr,
                        primary: primary,
                        onTap: () =>
                            Get.toNamed(RouteHelper.getSettingsRoute()),
                      ),

                      const SizedBox(height: 28),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: _confirmLogout,
                          icon: Icon(Icons.logout_rounded,
                              color: Colors.red.shade600, size: 20),
                          label: Text(
                            'logout'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: 15,
                              color: Colors.red.shade600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Delete account
                      TextButton(
                        onPressed: () => _confirmDeleteAccount(userCtrl),
                        child: Text(
                          'delete_account'.tr,
                          style: robotoRegular.copyWith(
                            fontSize: 13,
                            color: Colors.red.shade400,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.red.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout() {
    Get.dialog(
      ConfirmationDialog(
        icon: Images.support,
        description: 'are_you_sure_to_logout'.tr,
        isLogOut: true,
        onYesPressed: () {
          Get.find<AuthController>().clearSharedData();
          Get.offAllNamed(RouteHelper.getSignInRoute(RouteHelper.splash));
        },
      ),
      useSafeArea: false,
    );
  }

  void _confirmDeleteAccount(UserController userCtrl) {
    Get.dialog(
      ConfirmationDialog(
        icon: Images.support,
        title: 'are_you_sure_to_delete_account'.tr,
        description: 'it_will_remove_your_all_information'.tr,
        isLogOut: true,
        onYesPressed: () => userCtrl.removeUser(),
      ),
      useSafeArea: false,
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color primary;
  final List<Widget> items;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.primary,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Row(
              children: [
                Icon(icon, size: 15, color: primary),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: robotoMedium.copyWith(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...List.generate(items.length, (i) => Column(children: [
            items[i],
            if (i < items.length - 1)
              const Divider(height: 1, indent: 72, endIndent: 16),
          ])),
        ],
      ),
    );
  }
}

// ─── Tile item ────────────────────────────────────────────────────────────────

class _TileItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _TileItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF1A2340),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ─── Single tile (settings shortcut) ─────────────────────────────────────────

class _SingleTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color primary;
  final String title;
  final VoidCallback onTap;

  const _SingleTile({
    required this.icon,
    required this.color,
    required this.primary,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: robotoMedium.copyWith(
                  fontSize: 14,
                  color: const Color(0xFF1A2340),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
