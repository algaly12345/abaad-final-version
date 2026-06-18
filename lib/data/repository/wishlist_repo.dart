import 'package:abaad_flutter/data/api/api_client.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class WishListRepo {
  final ApiClient apiClient;
  WishListRepo({required this.apiClient});

  // Future<Response> getWishList() async {
  //   return await apiClient.getData(AppConstants.WISH_LIST_GET_URI,);
  // }


  Future<Response> getWishList() async {
    return await apiClient.getData(AppConstants.WISH_LIST_GET_URI);
  }


  // Future<Response> addWishList(int id, bool isRestaurant) async {
  //   return await apiClient.postData('${AppConstants.ADD_WISH_L  // Future<Response> addWishList(int id, bool isRestaurant) async {
  //   //   return await apiClient.postData('${AppConstants.ADD_WISH_LIST_URI}estate_id=$id', null, headers: {});
  //   // }IST_URI}estate_id=$id', null, headers: {});
  // }


  Future<Response> addWishList(int? id, bool isRestaurant) async {
    return await apiClient.postData('${AppConstants.ADD_WISH_LIST_URI}${isRestaurant ? 'estate_id=' : 'estate_id='}$id', null);
  }

  // Future<Response> removeWishList(int id) async {
  //
  //   return await apiClient.deleteData( '${AppConstants.REMOVE_WISH_LIST_URI}?estate_id=$id', headers: {});
  // }


  Future<Response> removeWishList(int? id) async {
    return await apiClient.deleteData('${AppConstants.REMOVE_WISH_LIST_URI}${ '?estate_id='}$id');
  }


}
