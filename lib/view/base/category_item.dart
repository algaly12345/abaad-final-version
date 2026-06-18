import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'dart:io';
import 'package:abaad_flutter/controller/category_controller.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/util/app_constants.dart';

import 'package:abaad_flutter/controller/estate_controller.dart';

class CategoryItem extends StatelessWidget {
  final int index;

  const CategoryItem({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EstateController>(builder: (restController) {
      return GetBuilder<CategoryController>(builder: (categoryController) {
        final category = categoryController.categoryList![index];
        final isSelected = category.id == restController.categoryIndex;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: InkWell(
            onTap: () {
              restController.setCategoryIndex(category.id ?? 0);
              restController.setCategoryPostion(
                int.tryParse(category.position ?? "0") ?? 0,
              );
            },
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.black12,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(2.0),
                color: Colors.white30,
              ),
              child: Row(
                children: [
                  Container(
                    height: 26,
                    color: Colors.white,
                    alignment: Alignment.center,
                    child: Text(
                      category.name ?? "",
                      style: isSelected
                          ? robotoBlack.copyWith(fontSize: 17)
                          : robotoRegular.copyWith(
                        fontSize: Dimensions.fontSizeDefault,
                        fontStyle: FontStyle.normal,
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  CustomImage(
                    image: '${AppConstants.BASE_URL}/${category.image}',
                    height: 25,
                    width: 25,
                    colors: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.black12,
                  ),
                ],
              ),
            ),
          ),
        );
      });
    });
  }
}
