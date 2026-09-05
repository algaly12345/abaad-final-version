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

import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/widgets/details_dilog.dart';

/// ملاحظة: نفس أسماء الكلاسات الأصلية (AgentProfileScreen،
/// _AgentProfileScreenState، SocialIcon) بلا أي تغيير، ونفس كل الدوال
/// والمنطق. التعديل الجديد: ملء الفجوة الفاضية اللي كانت موجودة بين
/// الترويسة وأزرار الاتصال بعداد إعلانات المعلن (كان مكانها فاضي — دالة
/// _statCard كانت معرّفة أصلًا بس مش مستخدمة خالص).
const Color kAgentColor = Color(0xff0F4C81);
const Color kAgentColorLight = Color(0xff3A7BD5);

class AgentProfileScreen extends StatefulWidget {
  final Userinfo? userInfo;
  final int? isMyProfile;

  const AgentProfileScreen({Key? key, this.userInfo, this.isMyProfile})
      : super(key: key);

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
    Get.find<UserController>()
        .getEstateByUser(1, false, widget.userInfo?.id ?? 0);
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
        title: Text(
          "الملف الشخصي",
          style: robotoBold.copyWith(fontSize: 17, color: Colors.black87),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: kAgentColor),
          onPressed: () => Get.back(),
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
              final int totalAdsCount =
                  restController.estateModel?.totalSize ?? estates.length;

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        _buildHeader(context, userController, restController),
                        const SizedBox(height: 14),

                        // 🔹 عداد إعلانات المعلن — يملأ الفجوة الفاضية
                        // اللي كانت هنا قبل كده.
                        Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                          child: _statCard(
                            "عدد الإعلانات",
                            totalAdsCount.toString(),
                            Icons.real_estate_agent_rounded,
                          ),
                        ),

                        const SizedBox(height: 14),
                        _buildActionButtons(agent),
                        const SizedBox(height: 14),
                        _buildSocialSection(agent),
                        const SizedBox(height: 20),
                        _sectionBanner(
                          title: "إعلانات المعلن",
                          icon: Icons.real_estate_agent_rounded,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                    border: Border.all(
                                      color: kAgentColor.withOpacity(0.06),
                                    ),
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
                                          DettailsDilog(
                                              estate: estates[index]),
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
                    child: SizedBox(height: 24),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ==========================================================================
  // عناصر تصميم موحّدة
  // ==========================================================================

  /// شريط عنوان قسم كامل العرض بلون التطبيق الأساسي، متسق عبر كل أقسام
  /// الصفحة بدل عناوين متفرقة الشكل.
  Widget _sectionBanner({required String title, required IconData icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: kAgentColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              title,
              style: robotoBold.copyWith(fontSize: 15, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserController userController,
      UserController restController) {
    final agent = userController.agentInfoModel;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [kAgentColorLight, kAgentColor],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: kAgentColor.withOpacity(0.25),
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                        color: const Color(0xFF2E9E5B),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoBold.copyWith(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 13, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            agent?.membershipType ?? "معلن عقاري",
                            style: robotoMedium.copyWith(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isMyProfile == 1) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone_rounded,
                              size: 13, color: Colors.white.withOpacity(0.85)),
                          const SizedBox(width: 5),
                          Text(
                            agent?.phone ?? "",
                            style: robotoRegular.copyWith(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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



  Widget _buildActionButtons(dynamic agent) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              title: "اتصال",
              icon: Icons.call,
              color: kAgentColor,
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
              title: "واتساب",
              icon: Icons.chat,
              color: const Color(0xff25D366),
              onTap: () async {
                final Uri whatsappUrl = Uri.parse(
                  "https://wa.me/${agent?.phone ?? ''}?text=${Uri.encodeFull("")}",
                );

                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl,
                      mode: LaunchMode.externalApplication);
                } else {
                  showCustomSnackBar("لا يمكن فتح واتساب");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(dynamic agent) {
    final List<_SocialLink> allLinks = [
      _SocialLink(icon: Images.instgram, url: agent?.instagram),
      _SocialLink(icon: Images.twiter, url: agent?.twitter),
      _SocialLink(icon: Images.website, url: agent?.website),
      _SocialLink(icon: Images.snap, url: agent?.snapchat),
      _SocialLink(icon: Images.tiktok, url: agent?.tiktok),
      _SocialLink(icon: Images.youtube, url: agent?.youtube),
    ];

    final List<_SocialLink> availableLinks = allLinks
        .where((e) => (e.url ?? '').trim().isNotEmpty)
        .toList();

    if (availableLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAgentColor.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public_rounded, color: kAgentColor, size: 19),
              const SizedBox(width: 8),
              Text(
                "روابط التواصل",
                style: robotoBold.copyWith(fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: availableLinks
                .map(
                  (link) => SocialIcon(
                iconData: link.icon,
                onPressed: () => _launchURL(link.url ?? ""),
              ),
            )
                .toList(),
          ),
        ],
      ),
    );
  }

  /// بطاقة إحصائية أفقية (أيقونة + عنوان + قيمة) — تُستخدم حاليًا لعرض
  /// عدد إعلانات المعلن، وقابلة لإعادة الاستخدام لأي إحصائية مستقبلية.
  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kAgentColor.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kAgentColor.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: kAgentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: robotoRegular.copyWith(
                  fontSize: 13, color: Colors.grey[600]),
            ),
          ),
          Text(
            value,
            style: robotoBold.copyWith(fontSize: 20, color: kAgentColor),
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
        border: Border.all(color: Colors.white.withOpacity(0.16)),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: robotoBold.copyWith(
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
          style: robotoBold.copyWith(
            fontSize: 13.5,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// عنصر بيانات بسيط يربط أيقونة برابط، يُستخدم لفلترة روابط التواصل
/// الفارغة قبل عرضها في _buildSocialSection.
class _SocialLink {
  final String icon;
  final String? url;

  const _SocialLink({required this.icon, required this.url});
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