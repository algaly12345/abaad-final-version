import 'package:abaad_flutter/data/api/api_client.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:get/get_connect/http/src/response/response.dart';

class CategoryRepo {
  final ApiClient apiClient;
  CategoryRepo({required this.apiClient});

  Future<Response> getCategoryList() async {
    return await apiClient.getData(AppConstants.CATEGORIES, query: {}, headers: {});
  }

  // Future<Response> getCategoryProductList(int zoneId,String categoryID,int userId,String city,String districts,String space,typeAdd, String offset,int arPath,int sv,String type) async {
  //   return await apiClient.getData(
  //     '${AppConstants.CATEGORY_ESTATEURI}/all?zone_id=$zoneId&category_id=$categoryID&user_id=$userId&city=$city&districts=$districts&space=$space&type_add=$typeAdd&offset=$offset&ar_path=$arPath&sv=$sv&type=$type',
  //   );
  // }

  Future<Response> getCategoryProductList(
      int zoneId,
      String categoryID,
      int userId,
      String city,
      String districts,
      String space,
      String typeAdd,
      int limit,
      int offset,
      int arPath,
      int sv,
      String type,
      ) async {
    return await apiClient.getData(
      '${AppConstants.CATEGORY_ESTATEURI}/all'
          '?zone_id=$zoneId'
          '&category_id=$categoryID'
          '&user_id=$userId'
          '&city=$city'
          '&districts=$districts'
          '&space=$space'
          '&type_add=$typeAdd'
          '&limit=$limit'
          '&offset=$offset'
          '&ar_path=$arPath'
          '&sv=$sv'
          '&type=$type',
    );
  }



  Future<Response> getCategoryRestaurantList(String categoryID, int offset, String type) async {
    return await apiClient.getData('${AppConstants.CATEGORY_ESTATEURI}limit=10&offset=$offset&type=$type');
  }


  Future<Response> getProperties(int categoryID) async {
    return await apiClient.getData('${AppConstants.PROPERTIES_URI}?category_id=$categoryID');
  }

  Future<Response> getFacilities() async {
    return await apiClient.getData(AppConstants.FACILITIES);
  }



  Future<Response> getAdvantages() async {
    return await apiClient.getData(AppConstants.ADVANTAGES);
  }


  Future<Response> getMapEstateList(
      int zoneId,
      String categoryID,
      int userId,
      String city,
      String districts,
      String space,
      String typeAdd,
      int limit,
      int offset,
      int arPath,
      int sv,
      String type,
      double northEastLat,
      double northEastLng,
      double southWestLat,
      double southWestLng,
      ) async {
    return await apiClient.getData(
      '${AppConstants.MAP_ESTATE_URI}/all'
          '?zone_id=$zoneId'
          '&category_id=$categoryID'
          '&user_id=$userId'
          '&city=$city'
          '&districts=$districts'
          '&space=$space'
          '&limit=$limit'
          '&offset=$offset'
          '&ar_path=$arPath'
          '&sv=$sv'
          '&type=$type'
          '&north_east_lat=$northEastLat'
          '&north_east_lng=$northEastLng'
          '&south_west_lat=$southWestLat'
          '&south_west_lng=$southWestLng',
    );
  }
}