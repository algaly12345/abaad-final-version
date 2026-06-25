import 'package:abaad_flutter/controller/services_controller.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_app_bar.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ServiceDetailsScreen extends StatefulWidget {
  final int serviceId;

  const ServiceDetailsScreen({Key? key, required this.serviceId})
    : super(key: key);

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<ServicesController>().getServiceDetails(widget.serviceId);
    });
  }

  Future<void> _launchApp(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'تفاصيل الخدمة'),
      body: GetBuilder<ServicesController>(
        builder: (controller) {
          if (controller.isDetailsLoading ||
              controller.serviceDetails == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final service = controller.serviceDetails!;
          final provider = (service.providers?.isNotEmpty ?? false)
              ? service.providers!.first
              : null;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomImage(
                  image: service.image ?? '',
                  width: double.infinity,
                  height: 250,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              service.title ?? '',
                              style: robotoBold.copyWith(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: service.offerType == 'discount'
                                  ? Colors.red
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              service.offerType == 'discount'
                                  ? '${service.discount}% خصم'
                                  : '${service.servicePrice} ريال',
                              style: robotoBold.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(service.serviceType?.name ?? ''),
                            backgroundColor: Colors.blue.withOpacity(0.1),
                          ),
                          if (service.categories != null &&
                              service.categories!.isNotEmpty)
                            ...service.categories!.map(
                              (c) => Chip(
                                label: Text(c.nameAr ?? ''),
                                backgroundColor: Colors.orange.withOpacity(0.1),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'تفاصيل الخدمة',
                        style: robotoBold.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        service.description ?? '',
                        style: robotoRegular.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      Text(
                        'مزود الخدمة',
                        style: robotoBold.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      if (provider != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 25,
                                    child: Icon(Icons.business),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          provider.name ?? '',
                                          style: robotoBold,
                                        ),
                                        Text(
                                          provider.phone ?? '',
                                          style: robotoRegular.copyWith(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.call,
                                      color: Colors.blue,
                                    ),
                                    onPressed: provider.phone == null
                                        ? null
                                        : () => _launchApp(
                                            'tel:${provider.phone}',
                                          ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.chat,
                                      color: Colors.green,
                                    ),
                                    onPressed: provider.phone == null
                                        ? null
                                        : () => _launchApp(
                                            'https://wa.me/${provider.phone}',
                                          ),
                                  ),
                                  if (provider.twitter != null &&
                                      provider.twitter!.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.public,
                                        color: Colors.lightBlue,
                                      ),
                                      onPressed: () => _launchApp(
                                        'https://twitter.com/${provider.twitter}',
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else
                        const Text('لا يوجد مزود خدمة متاح'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
