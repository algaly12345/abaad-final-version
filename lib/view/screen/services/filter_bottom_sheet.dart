import 'package:abaad_flutter/controller/services_controller.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterBottomSheet extends StatelessWidget {
  const FilterBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GetBuilder<ServicesController>(
        builder: (controller) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text('فلترة الخدمات', style: robotoBold.copyWith(fontSize: 18)),
                const Divider(),

                // Offer Type
                Text('نوع العرض', style: robotoMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  children: ServicesController.offerTypeOptions.map((type) {
                    bool isSelected = controller.selectedOfferType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      onSelected: (val) {
                        if (val) controller.setOfferType(type);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 15),

                // Sort By
                Text('ترتيب حسب', style: robotoMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: ServicesController.sortOptions.map((sort) {
                    bool isSelected = controller.sortBy == sort;
                    return ChoiceChip(
                      label: Text(sort),
                      selected: isSelected,
                      selectedColor: Theme.of(context).primaryColor,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                      onSelected: (val) {
                        if (val) controller.setSortBy(sort);
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 15),

                // Service Types
                Text('نوع الخدمة', style: robotoMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (controller.filtersData?.serviceTypes ?? []).map((
                    type,
                  ) {
                    bool isSelected = controller.selectedServiceTypes.contains(
                      type.id,
                    );
                    return FilterChip(
                      label: Text(type.name ?? ''),
                      selected: isSelected,
                      // إصلاح تحذير withOpacity الخاص بتحديث فلاتر الجديد
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.2),
                      onSelected: (val) =>
                          controller.toggleServiceType(type.id!),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 15),

                // مزود الخدمة (Service Provider) - فلتر جديد متصل بالباكند الجديد
                Text('مزود الخدمة', style: robotoMedium),
                const SizedBox(height: 8),
                (controller.filtersData?.providers == null ||
                        controller.filtersData!.providers!.isEmpty)
                    ? Text(
                        'لا يوجد مزودو خدمة متاحون حاليًا',
                        style: robotoRegular.copyWith(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.filtersData!.providers!.map((
                          provider,
                        ) {
                          bool isSelected = controller.selectedProviders
                              .contains(provider.id);
                          return FilterChip(
                            avatar:
                                provider.image != null &&
                                    provider.image!.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                      provider.image!,
                                    ),
                                  )
                                : const Icon(
                                    Icons.storefront_outlined,
                                    size: 18,
                                  ),
                            label: Text(provider.name ?? ''),
                            selected: isSelected,
                            selectedColor: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.2),
                            onSelected: (val) =>
                                controller.toggleProvider(provider.id!),
                          );
                        }).toList(),
                      ),

                const SizedBox(height: 25),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        buttonText: 'تطبيق الفلترة',
                        onPressed: () => controller.applyFilters(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButton(
                        buttonText: 'مسح الفلاتر',
                        color: Colors.grey,
                        onPressed: () => controller.clearFilters(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
