import 'package:abaad_flutter/controller/theme_controller.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'app_settings'.tr,
          style: robotoBold.copyWith(fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          children: [
            // ── App preferences ──────────────────────────────────────────
            _SectionCard(
              title: 'language'.tr,
              icon: Icons.tune_rounded,
              primary: primary,
              items: [
                _TileItem(
                  icon: Icons.language_rounded,
                  color: const Color(0xFF9C27B0),
                  title: 'language'.tr,
                  onTap: () =>
                      Get.toNamed(RouteHelper.getLanguageRoute('menu')),
                ),
                _DarkModeTile(primary: primary),
              ],
            ),

            const SizedBox(height: 14),

            // ── About & support ───────────────────────────────────────────
            _SectionCard(
              title: 'support_and_info'.tr,
              icon: Icons.info_outline_rounded,
              primary: primary,
              items: [
                _TileItem(
                  icon: Icons.list_alt_rounded,
                  color: const Color(0xFF607D8B),
                  title: 'terms_conditions'.tr,
                  onTap: () => Get.toNamed(
                      RouteHelper.getHtmlRoute('terms_conditions')),
                ),
                _TileItem(
                  icon: Icons.star_outline_rounded,
                  color: const Color(0xFFFFC107),
                  title: 'your_rating'.tr,
                  onTap: _openPlayStore,
                ),
                _TileItem(
                  icon: Icons.share_outlined,
                  color: const Color(0xFF00BCD4),
                  title: 'share_app'.tr,
                  onTap: _shareApp,
                ),
              ],
            ),

            const SizedBox(height: 28),

            // ── Version ───────────────────────────────────────────────────
            Text(
              '${'version'.tr} ${AppConstants.APP_VERSION}',
              style: robotoRegular.copyWith(
                fontSize: 12,
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPlayStore() async {
    const appId = 'sa.pdm.abaad.abaad';
    final market = Uri.parse('market://details?id=$appId');
    final fallback =
        Uri.parse('https://play.google.com/store/apps/details?id=$appId');
    if (!await launchUrl(market, mode: LaunchMode.externalApplication)) {
      await launchUrl(fallback, mode: LaunchMode.externalApplication);
    }
  }

  void _shareApp() {
    Share.share(
      'https://play.google.com/store/apps/details?id=sa.pdm.abaad.abaad',
      subject: 'Abaad App',
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
          ...List.generate(
            items.length,
            (i) => Column(children: [
              items[i],
              if (i < items.length - 1)
                const Divider(height: 1, indent: 72, endIndent: 16),
            ]),
          ),
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

// ─── Dark mode toggle ─────────────────────────────────────────────────────────

class _DarkModeTile extends StatelessWidget {
  final Color primary;
  const _DarkModeTile({required this.primary});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (themeCtrl) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF607D8B).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.dark_mode_outlined,
                    color: Color(0xFF607D8B), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'dark_mode'.tr,
                  style: robotoMedium.copyWith(
                    fontSize: 14,
                    color: const Color(0xFF1A2340),
                  ),
                ),
              ),
              Switch(
                value: Get.isDarkMode,
                onChanged: (_) => themeCtrl.toggleTheme(),
                activeThumbColor: primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        );
      },
    );
  }
}
