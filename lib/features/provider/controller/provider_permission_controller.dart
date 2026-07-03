import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/features/provider/data/repositories/provider_permission_repo.dart';
import 'package:get/get.dart';

class ProviderPermissionController extends GetxController
    implements GetxService {
  final ProviderPermissionRepo repo;
  ProviderPermissionController({required this.repo});

  List<String> _permissions = [];
  List<String> get permissions => _permissions;

  // هل عاد الـ API بصلاحيات صريحة من الأدمن؟
  bool _hasExplicitPermissions = false;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── Permission checks ────────────────────────────────────────────────────
  //
  // المنطق:
  //  1. إذا عيّن الأدمن صلاحيات صريحة → نتحقق منها حصراً.
  //  2. إذا لم يعيّن الأدمن أي صلاحية بعد (مصفوفة فارغة) →
  //     نرجع إلى user_type: أي مستخدم من نوع "provider" يملك
  //     صلاحيات المزود كاملة بشكل افتراضي حتى يقيّدها الأدمن.

  bool get _isProviderByType {
    try {
      final userType =
          Get.find<UserController>().userInfoModel?.userType ?? '';
      return userType == 'provider';
    } catch (_) {
      return false;
    }
  }

  bool _check(String permission) {
    if (_hasExplicitPermissions) {
      return _permissions.contains(permission);
    }
    // لم يُعيَّن شيء صريح بعد → يعتمد على نوع المستخدم
    return _isProviderByType;
  }

  bool get canCreateServices => _check('services.create');
  bool get canViewServices => _check('services.view');
  bool get canUpdateServices => _check('services.update');
  bool get canViewReports => _check('reports.view-own');
  bool get isProvider =>
      canCreateServices || canViewServices || canUpdateServices;

  // ─── Load from API ────────────────────────────────────────────────────────

  Future<void> loadPermissions() async {
    _isLoading = true;
    _hasExplicitPermissions = false;
    update();

    try {
      final response = await repo.getPermissions();

      if (response.statusCode == 200 &&
          response.body is Map &&
          response.body['data'] != null) {
        final data = response.body['data'];
        final raw = data['permissions'];
        if (raw is List) {
          _permissions = raw.map((e) => e.toString()).toList();
          // الأدمن عيّن صلاحيات صريحة (ولو كانت فارغة = لا شيء مسموح)
          _hasExplicitPermissions = true;
        }
        // إذا كانت المصفوفة فارغة لكن الـ status 200 → الأدمن لم يُعيَّن بعد
        // نتركها false ليُفعَّل الـ fallback
        if (_permissions.isEmpty) {
          _hasExplicitPermissions = false;
        }
      } else if (response.statusCode == 403 ||
          response.statusCode == 401) {
        // المستخدم ليس مزود خدمة أو غير مصرّح له — نُوقف الـ fallback أيضاً
        _permissions = [];
        _hasExplicitPermissions = true; // نُعامل الرفض كقيد صريح
      }
    } catch (_) {
      // خطأ في الشبكة → نُبقي الـ fallback فعّالاً (user_type)
      _hasExplicitPermissions = false;
    } finally {
      _isLoading = false;
      update();
    }
  }

  /// يُستدعى عند تسجيل الخروج لمسح الصلاحيات المخزّنة
  void clearPermissions() {
    _permissions = [];
    _hasExplicitPermissions = false;
    update();
  }
}
