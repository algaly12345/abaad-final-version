import 'package:abaad_flutter/controller/services_controller.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_app_bar.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/no_data_screen.dart';
import 'package:abaad_flutter/view/base/paginated_list_view.dart';
import 'package:abaad_flutter/view/screen/services/filter_bottom_sheet.dart';
import 'package:abaad_flutter/view/screen/services/service_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ServicesCatalogScreen extends StatefulWidget {
  final bool showAppBar;

  const ServicesCatalogScreen({Key? key, this.showAppBar = true})
    : super(key: key);

  @override
  State<ServicesCatalogScreen> createState() => _ServicesCatalogScreenState();
}

class _ServicesCatalogScreenState extends State<ServicesCatalogScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ServicesController>().getServicesList(1, reload: true);
      Get.find<ServicesController>().getFilters();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildServiceCard(BuildContext context, dynamic service) {
    final providerName = (service.providers?.isNotEmpty ?? false)
        ? (service.providers!.first.name ?? 'مزود خدمة')
        : 'مزود خدمة';

    return InkWell(
      onTap: () => Get.to(() => ServiceDetailsScreen(serviceId: service.id!)),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CustomImage(
                  image: service.image ?? '',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service.title ?? '',
                      style: robotoBold.copyWith(fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      service.serviceType?.name ?? '',
                      style: robotoRegular.copyWith(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            providerName,
                            style: robotoMedium.copyWith(
                              fontSize: 12,
                              color: Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: service.offerType == 'discount'
                                ? Colors.red
                                : Colors.green,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            service.offerType == 'discount'
                                ? '${service.discount}% خصم'
                                : '${service.servicePrice} ريال',
                            style: robotoBold.copyWith(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppBar
          ? const CustomAppBar(title: 'دليل الخدمات العقارية')
          : null,
      body: GetBuilder<ServicesController>(
        builder: (controller) {
          final categories = controller.filtersData?.categories ?? [];
          final providers = controller.filtersData?.providers ?? [];
          final services = controller.servicesList ?? [];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => controller.searchServices(val),
                        decoration: InputDecoration(
                          hintText: 'ابحث عن خدمة...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              Dimensions.RADIUS_SMALL,
                            ),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    InkWell(
                      onTap: () {
                        Get.bottomSheet(
                          const FilterBottomSheet(),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.RADIUS_SMALL,
                          ),
                        ),
                        child: const Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (categories.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final isSelected = controller.selectedCategories.contains(
                        cat.id,
                      );

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: ChoiceChip(
                          label: Text(cat.nameAr ?? cat.name ?? ''),
                          selected: isSelected,
                          selectedColor: Theme.of(context).primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (val) {
                            if (cat.id == null) return;
                            controller.toggleCategory(cat.id!);
                            controller.getServicesList(1, reload: true);
                          },
                        ),
                      );
                    },
                  ),
                ),

              if (providers.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final provider = providers[index];
                        final isSelected = controller.selectedProviders
                            .contains(provider.id);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            avatar: const Icon(
                              Icons.storefront_outlined,
                              size: 16,
                            ),
                            label: Text(provider.name ?? ''),
                            selected: isSelected,
                            selectedColor: Theme.of(context).primaryColor,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                            onSelected: (val) {
                              if (provider.id == null) return;
                              controller.toggleProvider(provider.id!);
                              controller.getServicesList(1, reload: true);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

              Expanded(
                child: controller.servicesList == null
                    ? const Center(child: CircularProgressIndicator())
                    : services.isEmpty
                    ? const NoDataScreen(text: 'لا توجد خدمات متاحة')
                    : PaginatedListView(
                        scrollController: _scrollController,
                        totalSize: controller.pageSize,
                        offset: controller.offset,
                        onPaginate: (int offset) async {
                          await controller.getServicesList(offset);
                        },
                        productView: Column(
                          children: List.generate(
                            services.length,
                            (index) =>
                                _buildServiceCard(context, services[index]),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
