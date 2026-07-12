import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/features/favourite/data/repositories/wishlist_repo.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class WishListController extends GetxController implements GetxService {
  final WishListRepo wishListRepo;
  WishListController({required this.wishListRepo});


  List<Estate>? _wishRestList;
  List<int> _wishProductIdList = [];
  List<int> _wishRestIdList = [];


  List<Estate>? get wishRestList => _wishRestList;
  List<int> get wishProductIdList => _wishProductIdList;
  List<int> get wishRestIdList => _wishRestIdList;

  void addToWishList( Estate restaurant, bool isRestaurant) async {
    Response? response = await wishListRepo?.addWishList( restaurant.id ?? 0, isRestaurant);
    if (response?.statusCode == 200) {
        _wishRestIdList.add(restaurant.id ?? 0);
        _wishRestList?.add(restaurant);

      showCustomSnackBar(response?.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response! , showToaster: true);
    }
    update();
  }

  void removeFromWishList(int id) async {
    Response? response = await wishListRepo?.removeWishList(id);

    if (response!.statusCode == 200) {
      int idIndex = -1;


        idIndex = _wishRestIdList.indexOf(id);
        _wishRestIdList.removeAt(idIndex);
        _wishRestList?.removeAt(idIndex);

      showCustomSnackBar(response.body['message'], isError: false);
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
    update();
  }

  Future<void> getWishList() async {
    _wishRestList = [];
    _wishRestIdList = [];
    Response? response = await wishListRepo?.getWishList();
    if (response?.statusCode == 200 && response?.body is List) {
      update();

      response?.body.forEach((restaurant) async {
        //Estate restaurant = Estate();
        try{
          restaurant = Estate.fromJson(restaurant);
        }catch(e){
          showCustomSnackBar("$e");

        }
        _wishRestList?.add(restaurant);
        if (restaurant.estate_id != null) {
          _wishRestIdList.add(restaurant.estate_id!);
        }

      });
    } else {
      ApiChecker.checkApi(response! , showToaster: true);
    }
    update();
  }

  void removeWishes() {
    _wishProductIdList = [];
    _wishRestIdList = [];
  }
}
