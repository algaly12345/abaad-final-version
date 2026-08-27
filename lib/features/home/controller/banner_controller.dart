import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/features/home/data/models/banner_model.dart';
import 'package:abaad_flutter/features/home/data/repositories/banner_repo.dart';
import 'package:get/get.dart';

class BannerController extends GetxController implements GetxService {
  final BannerRepo bannerRepo;
  BannerController({required this.bannerRepo});

  List<String>? _bannerImageList;
  List<dynamic>? _bannerDataList;
  int _currentIndex = 0;

  List<String>? get bannerImageList => _bannerImageList;
  List<dynamic>? get bannerDataList => _bannerDataList;
  int get currentIndex => _currentIndex;

  /// ملاحظة: نفس المنطق والاسم الأصلي، مع إصلاحين:
  /// 1) معالجة آمنة (null-safe) لكل قيمة ممكن تيجي null من السيرفر (كانت
  ///    سبب كراش صامت يمنع وصول الكود لسطر update()).
  /// 2) الأهم: _bannerDataList كانت بتتخزّن فيها عناصر campaigns بس، مش
  ///    banners — يعني index الصورة في _bannerImageList ما كانش متوافق
  ///    مع index البيانات في _bannerDataList لأي بانر (Banner) بعد أول
  ///    campaign. دلوقتي كل صورة وبياناتها بيتضافوا مع بعض كزوج واحد،
  ///    وبعدين بيتفلتروا الصور الفارغة مع بياناتها معًا — فهذا يضمن إن
  ///    index واحد في القائمتين يشير دايمًا لنفس البانر بالظبط، وهو ما
  ///    يسمح بعرض عنوان كل بانر بشكل صحيح فوق صورته.
  Future<void> getBannerList(bool reload, int zoneId) async {
    if (_bannerImageList == null || reload) {
      try {
        Response response = await bannerRepo.getBannerList(zoneId);
        if (response.statusCode == 200) {
          BannerModel bannerModel = BannerModel.fromJson(response.body);

          final List<MapEntry<String, dynamic>> pairs = [];

          for (var campaign in bannerModel.campaigns ?? []) {
            pairs.add(MapEntry(campaign.image ?? "", campaign));
          }

          for (var banner in bannerModel.banners ?? []) {
            pairs.add(MapEntry(banner.image, banner));
          }

          // نشيل أي زوج (صورة فاضية) — من غير ما نكسر التوافق بين
          // القائمتين، لأن الفلترة بتحصل على الزوج نفسه مرة واحدة.
          pairs.removeWhere((entry) => entry.key.trim().isEmpty);

          _bannerImageList = pairs.map((e) => e.key).toList();
          _bannerDataList = pairs.map((e) => e.value).toList();
        } else {
          ApiChecker.checkApi(response, showToaster: true);
        }
      } catch (e, stackTrace) {
        debugPrintBannerError(e, stackTrace);
      }
      update();
    }
  }

  void debugPrintBannerError(Object e, StackTrace stackTrace) {
    // ignore: avoid_print
    print('❌ BannerController.getBannerList error: $e');
    // ignore: avoid_print
    print('$stackTrace');
  }

  void setCurrentIndex(int index, bool notify) {
    _currentIndex = index;
    if (notify) {
      update();
    }
  }
}