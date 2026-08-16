import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const Color _brandDark = Color(0xFF1A3C5E);
  static const Color _brandLight = Color(0xFF2E6DA4);

  @override
  Widget build(BuildContext context) {
    final splashCtrl = Get.find<SplashController>();
    final config = splashCtrl.configModel;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: CustomAppBar(title: 'help_support'.tr),
      body: Scrollbar(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Center(
            child: SizedBox(
              width: Dimensions.WEB_MAX_WIDTH,
              child: Column(
                children: [
                  // ── رأس بتدرّج ألوان العلامة التجارية مع زخرفة دائرية ناعمة ──
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_brandLight, _brandDark],
                        ),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            top: -30,
                            right: -30,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: -40,
                            left: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Image.asset(Images.logo, width: 56),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'help_support'.tr,
                                style: robotoBold.copyWith(
                                  fontSize: 21,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'we_are_here_to_help_you'.tr,
                                textAlign: TextAlign.center,
                                style: robotoRegular.copyWith(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.85),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        _ContactCard(
                          icon: Icons.location_on_rounded,
                          color: const Color(0xFF3B82F6),
                          title: 'address'.tr,
                          value: "  المملكة العربية السعودية ",
                          onTap: () {},
                        ),
                        const SizedBox(height: 12),
                        _ContactCard(
                          icon: Icons.call_rounded,
                          color: const Color(0xFFEF4444),
                          title: 'call'.tr,
                          value: config?.phone ?? "",
                          onTap: () async {
                            final phone = config?.phone;
                            if (await canLaunchUrlString('tel:$phone')) {
                              launchUrlString('tel:$phone',
                                  mode: LaunchMode.externalApplication);
                            } else {
                              showCustomSnackBar(
                                  '${'can_not_launch'.tr} $phone');
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _ContactCard(
                          icon: Icons.mail_outline_rounded,
                          color: const Color(0xFF22C55E),
                          title: 'email_us'.tr,
                          value: config?.email ?? "",
                          onTap: () {
                            final Uri emailLaunchUri = Uri(
                              scheme: 'mailto',
                              path: config?.email,
                            );
                            launchUrlString(emailLaunchUri.toString(),
                                mode: LaunchMode.externalApplication);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'follow_us_on'.tr,
                          style: robotoMedium.copyWith(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      const SizedBox(width: 20),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Padding(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20),
                  //   child: Wrap(
                  //     alignment: WrapAlignment.center,
                  //     spacing: 18,
                  //     runSpacing: 14,
                  //     children: [
                  //       if ((config?.whatsapp ?? '').isNotEmpty)
                  //         _SocialButton(
                  //           icon: Icons.chat_rounded,
                  //           backgroundColor: const Color(0xFF25D366),
                  //           label: 'WhatsApp',
                  //           onTap: () => _launchSocial(
                  //             'https://wa.me/${config?.whatsapp}',
                  //           ),
                  //         ),
                  //       if ((config?.twitter ?? '').isNotEmpty)
                  //         _SocialButton(
                  //           icon: Icons.alternate_email_rounded,
                  //           backgroundColor: const Color(0xFF0F1419),
                  //           label: 'X',
                  //           onTap: () => _launchSocial(config!.twitter!),
                  //         ),
                  //       if ((config?.instagram ?? '').isNotEmpty)
                  //         _SocialButton(
                  //           icon: Icons.camera_alt_rounded,
                  //           backgroundColor: const Color(0xFFDD2A7B),
                  //           label: 'Instagram',
                  //           onTap: () => _launchSocial(config!.instagram!),
                  //         ),
                  //       if ((config?.facebook ?? '').isNotEmpty)
                  //         _SocialButton(
                  //           icon: Icons.facebook_rounded,
                  //           backgroundColor: const Color(0xFF1877F2),
                  //           label: 'Facebook',
                  //           onTap: () => _launchSocial(config!.facebook!),
                  //         ),
                  //       if ((config?.snapchat ?? '').isNotEmpty)
                  //         _SocialButton(
                  //           icon: Icons.photo_camera_front_rounded,
                  //           backgroundColor: const Color(0xFFFFFC00),
                  //           iconColor: Colors.black,
                  //           label: 'Snapchat',
                  //           onTap: () => _launchSocial(config!.snapchat!),
                  //         ),
                  //     ],
                  //   ),
                  // ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchSocial(String url) async {
    if (await canLaunchUrlString(url)) {
      launchUrlString(url, mode: LaunchMode.externalApplication);
    } else {
      showCustomSnackBar('${'can_not_launch'.tr} $url');
    }
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ContactCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: robotoRegular.copyWith(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: robotoMedium.copyWith(
                        fontSize: 14,
                        color: const Color(0xFF1A2340),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;

  const _SocialButton({
    required this.icon,
    required this.backgroundColor,
    required this.label,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: backgroundColor,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 3,
          shadowColor: backgroundColor.withOpacity(0.4),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 54,
              height: 54,
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: robotoRegular.copyWith(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}