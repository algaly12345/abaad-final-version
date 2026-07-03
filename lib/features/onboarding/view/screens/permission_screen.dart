import 'dart:ui';

import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  final VoidCallback onDone;
  const PermissionScreen({super.key, required this.onDone});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fade;

  bool _isRequesting = false;
  bool _anyPermanentlyDenied = false;
  Map<Permission, PermissionStatus> _statuses = {};

  List<_PermItem> get _items => [
        _PermItem(
          permission: Permission.locationWhenInUse,
          icon: Icons.location_on_rounded,
          color: const Color(0xFF2196F3),
          title: 'permission_location_title'.tr,
          desc: 'permission_location_desc'.tr,
        ),
        _PermItem(
          permission: Permission.camera,
          icon: Icons.camera_alt_rounded,
          color: const Color(0xFF9C27B0),
          title: 'permission_camera_title'.tr,
          desc: 'permission_camera_desc'.tr,
        ),
        _PermItem(
          permission: Permission.photos,
          icon: Icons.photo_library_rounded,
          color: const Color(0xFF4CAF50),
          title: 'permission_storage_title'.tr,
          desc: 'permission_storage_desc'.tr,
        ),
        _PermItem(
          permission: Permission.notification,
          icon: Icons.notifications_rounded,
          color: const Color(0xFFFF9800),
          title: 'permission_notification_title'.tr,
          desc: 'permission_notification_desc'.tr,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadStatuses();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatuses() async {
    try {
      final map = <Permission, PermissionStatus>{};
      for (final item in _items) {
        map[item.permission] = await item.permission.status;
      }
      if (!mounted) return;
      setState(() {
        _statuses = map;
        _anyPermanentlyDenied = map.values.any((s) => s.isPermanentlyDenied);
      });
    } catch (_) {
      if (mounted) setState(() => _statuses = {});
    }
  }

  bool get _allGranted =>
      _items.every((i) => _statuses[i.permission]?.isGranted ?? false);

  Future<void> _requestAll() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    try {
      bool hasPermaDenied = false;

      for (final item in _items) {
        final current = _statuses[item.permission] ?? PermissionStatus.denied;
        if (current.isGranted) continue;
        if (current.isPermanentlyDenied) {
          hasPermaDenied = true;
          continue;
        }
        final result = await item.permission.request();
        if (mounted) {
          setState(() => _statuses[item.permission] = result);
          if (result.isPermanentlyDenied) hasPermaDenied = true;
        }
      }

      if (mounted) {
        setState(() {
          _isRequesting = false;
          _anyPermanentlyDenied = hasPermaDenied;
        });
      }

      if (_allGranted) {
        await Future.delayed(const Duration(milliseconds: 350));
        widget.onDone();
      }
    } catch (_) {
      if (mounted) setState(() => _isRequesting = false);
      widget.onDone();
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
    await Future.delayed(const Duration(milliseconds: 800));
    await _loadStatuses();
    if (_allGranted && mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: FadeTransition(
        opacity: _fade,
        // ── Simple Column: header → scrollable cards → bottom bar ──────────
        child: Column(
          children: [
            // ── Fixed gradient header ───────────────────────────────────────
            _Header(primary: primary),

            // ── Scrollable cards (takes all remaining space) ─────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  children: _items.map((item) {
                    return _PermCard(
                      item: item,
                      status: _statuses[item.permission],
                    );
                  }).toList(),
                ),
              ),
            ),

            // ── Bottom buttons (not Positioned — part of the Column flow) ────
            _BottomBar(
              primary: primary,
              bottomInset: bottomInset,
              isRequesting: _isRequesting,
              allGranted: _allGranted,
              anyPermanentlyDenied: _anyPermanentlyDenied,
              onGrant: _requestAll,
              onSkip: widget.onDone,
              onOpenSettings: _openSettings,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final Color primary;
  const _Header({required this.primary});

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return SizedBox(
      height: 220 + topInset,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(Images.background, fit: BoxFit.cover),
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  primary.withValues(alpha: 0.88),
                  primary.withValues(alpha: 0.70),
                  primary.withValues(alpha: 0.40),
                ],
              ),
            ),
          ),
          // Content centered, respecting status bar
          Padding(
            padding: EdgeInsets.only(top: topInset),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glass logo card
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Image.asset(
                        Images.logo_an,
                        width: 52,
                        height: 52,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'permission_screen_title'.tr,
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    'permission_screen_subtitle'.tr,
                    textAlign: TextAlign.center,
                    style: robotoRegular.copyWith(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Permission card ──────────────────────────────────────────────────────────

class _PermCard extends StatelessWidget {
  final _PermItem item;
  final PermissionStatus? status;

  const _PermCard({required this.item, required this.status});

  @override
  Widget build(BuildContext context) {
    final isGranted = status?.isGranted ?? false;
    final isDenied = status?.isDenied ?? false;
    final isPermanentlyDenied = status?.isPermanentlyDenied ?? false;
    final isLoading = status == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isGranted
                ? item.color.withValues(alpha: 0.10)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isGranted
              ? item.color.withValues(alpha: 0.25)
              : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isGranted
                  ? item.color.withValues(alpha: 0.12)
                  : const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              item.icon,
              color: isGranted ? item.color : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: robotoMedium.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF1A2340),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  item.desc,
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status badge
          _StatusBadge(
            isLoading: isLoading,
            isGranted: isGranted,
            isDenied: isDenied || isPermanentlyDenied,
            color: item.color,
          ),
        ],
      ),
    );
  }
}

// ─── Status badge ─────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isLoading;
  final bool isGranted;
  final bool isDenied;
  final Color color;

  const _StatusBadge({
    required this.isLoading,
    required this.isGranted,
    required this.isDenied,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Colors.grey.shade400,
        ),
      );
    }

    if (isGranted) {
      return _Chip(
        icon: Icons.check_circle_rounded,
        label: 'permission_granted'.tr,
        color: color,
        bg: color.withValues(alpha: 0.12),
      );
    }

    if (isDenied) {
      return _Chip(
        icon: Icons.cancel_rounded,
        label: 'permission_denied'.tr,
        color: Colors.red.shade600,
        bg: Colors.red.withValues(alpha: 0.10),
      );
    }

    return _Chip(
      icon: Icons.hourglass_empty_rounded,
      label: 'permission_pending'.tr,
      color: Colors.orange.shade700,
      bg: Colors.orange.withValues(alpha: 0.10),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _Chip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: robotoMedium.copyWith(fontSize: 10, color: color)),
        ],
      ),
    );
  }
}

// ─── Bottom bar ───────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final Color primary;
  final double bottomInset;
  final bool isRequesting;
  final bool allGranted;
  final bool anyPermanentlyDenied;
  final VoidCallback onGrant;
  final VoidCallback onSkip;
  final VoidCallback onOpenSettings;

  const _BottomBar({
    required this.primary,
    required this.bottomInset,
    required this.isRequesting,
    required this.allGranted,
    required this.anyPermanentlyDenied,
    required this.onGrant,
    required this.onSkip,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, 14 + bottomInset),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Permanently denied warning
          if (anyPermanentlyDenied && !allGranted) ...[
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Colors.red.shade600, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'permission_permanently_denied_msg'.tr,
                      style: robotoRegular.copyWith(
                        fontSize: 11,
                        color: Colors.red.shade700,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Primary button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isRequesting
                  ? null
                  : allGranted
                      ? onSkip
                      : anyPermanentlyDenied
                          ? onOpenSettings
                          : onGrant,
              style: ElevatedButton.styleFrom(
                backgroundColor: allGranted ? Colors.green.shade600 : primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: isRequesting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      allGranted
                          ? 'continue_to_app'.tr
                          : anyPermanentlyDenied
                              ? 'open_settings'.tr
                              : 'grant_permissions'.tr,
                      style: robotoBold.copyWith(fontSize: 14),
                    ),
            ),
          ),

          // Skip button
          if (!allGranted) ...[
            const SizedBox(height: 4),
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
              ),
              child: Text(
                'skip_permissions'.tr,
                style: robotoRegular.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _PermItem {
  final Permission permission;
  final IconData icon;
  final Color color;
  final String title;
  final String desc;

  const _PermItem({
    required this.permission,
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
  });
}
