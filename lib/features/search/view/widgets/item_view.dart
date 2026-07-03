// import 'package:abaad_flutter/features/search/controller/search_controller.dart';
// import 'package:abaad_flutter/shared/utils/dimensions.dart';
// import 'package:abaad_flutter/features/favourite/view/widgets/favourite_view.dart';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// class ItemView extends StatelessWidget {
//   final bool isRestaurant;
//   ItemView({required this.isRestaurant});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GetBuilder<SearchController>(builder: (searchController) {
//         return SingleChildScrollView(
//           child: Center(child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: ProductView( restaurants: searchController.searchRestList,
//           ))),
//         );
//       }),
//     );
//   }
// }
