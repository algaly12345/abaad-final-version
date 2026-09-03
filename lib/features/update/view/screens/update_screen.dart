import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/update/view/widgets/update_illustration.dart';
import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/widgets/custom_button.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatelessWidget {
  /// `true`  -> forced-update screen (new mandatory version available).
  /// `false` -> maintenance screen (server is temporarily down).
  final bool isUpdate;

  const UpdateScreen({super.key, required this.isUpdate});

  // Store identifiers, kept in sync with the rest of the app (settings / share).
  static const String _androidPackage = 'sa.pdm.abaad.abaad';
  static const String _iosAppId = '6470352371';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.primaryColor;

    // Both states are terminal: the user must update or wait, not swipe away.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.PADDING_SIZE_EXTRA_LARGE,
                vertical: Dimensions.PADDING_SIZE_LARGE,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Illustration ───────────────────────────────────────────
                    Align(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 260),
                        child: UpdateIllustration(isUpdate: isUpdate),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Title ─────────────────────────────────────────────────
                    Text(
                      isUpdate
                          ? 'update_required'.tr
                          : 'we_are_under_maintenance'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Body ──────────────────────────────────────────────────
                    Text(
                      isUpdate
                          ? 'your_app_is_deprecated'.tr
                          : 'we_will_be_right_back'.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 15,
                        height: 1.6,
                        color: theme.hintColor,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Primary action ────────────────────────────────────────
                    if (isUpdate)
                      CustomButton(
                        buttonText: 'update_now'.tr,
                        icon: Icons.system_update_rounded,
                        margin: EdgeInsets.zero,
                        onPressed: _openStore,
                      )
                    else
                      CustomButton(
                        buttonText: 'retry'.tr,
                        icon: Icons.refresh_rounded,
                        transparent: true,
                        margin: EdgeInsets.zero,
                        onPressed: () =>
                            Get.offAllNamed('${RouteHelper.splash}?data=null'),
                      ),
                    const SizedBox(height: 16),

                    // ── Current version ───────────────────────────────────────
                    Text(
                      '${'version'.tr} ${AppConstants.APP_VERSION}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        color: theme.disabledColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Opens the app's store page. Tries, in order:
  ///  1. the URL provided by the server config (if any),
  ///  2. the native store deep link (`market://` / `itms-apps://`),
  ///  3. the plain https store URL as a last resort.
  Future<void> _openStore() async {
    final String? configuredUrl = _configuredStoreUrl();
    final List<String> candidates = [
      if (configuredUrl != null) configuredUrl,
      if (GetPlatform.isIOS) ...[
        'itms-apps://itunes.apple.com/app/id$_iosAppId',
        'https://apps.apple.com/app/id$_iosAppId',
      ] else ...[
        'market://details?id=$_androidPackage',
        'https://play.google.com/store/apps/details?id=$_androidPackage',
      ],
    ];

    for (final String url in candidates) {
      try {
        if (await launchUrlString(url, mode: LaunchMode.externalApplication)) {
          return;
        }
      } catch (_) {
        // Try the next candidate.
      }
    }

    showCustomSnackBar('can_not_launch'.tr);
  }

  /// Store URL coming from the backend config, or `null` when it is missing/empty.
  String? _configuredStoreUrl() {
    try {
      final config = Get.find<SplashController>().configModel;
      final String? url = GetPlatform.isIOS
          ? config?.appUrlIos
          : config?.appUrlAndroid;
      return (url != null && url.trim().isNotEmpty) ? url.trim() : null;
    } catch (_) {
      return null;
    }
  }
}
