import 'dart:io';

import 'package:abaad_flutter/controller/service_offer_controller.dart';
import 'package:abaad_flutter/data/model/response/service_offer_setup_model.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_app_bar.dart';
import 'package:abaad_flutter/view/base/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddPropertyServiceOfferScreen extends StatefulWidget {
  const AddPropertyServiceOfferScreen({super.key});

  @override
  State<AddPropertyServiceOfferScreen> createState() =>
      _AddPropertyServiceOfferScreenState();
}

class _AddPropertyServiceOfferScreenState
    extends State<AddPropertyServiceOfferScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Get.find<ServiceOfferController>().resetAll();
    Get.find<ServiceOfferController>().loadSetupData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      appBar: const CustomAppBar(title: 'إضافة خدمة داخل عقار'),
      body: GetBuilder<ServiceOfferController>(
        builder: (offerController) {
          if (offerController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.PADDING_SIZE_SMALL,
                  Dimensions.PADDING_SIZE_SMALL,
                  Dimensions.PADDING_SIZE_SMALL,
                  120,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context),
                    const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                    _buildImagePicker(context, offerController),
                    const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                    _buildServiceInfo(context, offerController),
                    const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                    _buildPlans(context, offerController),
                    const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                    _buildZonesAndCategories(context, offerController),
                    const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                    _buildDuration(context, offerController),
                    const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                    _buildExpiryDate(context, offerController),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBar(context, offerController),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback? onPressed,
    double height = 46,
  }) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: robotoMedium.copyWith(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1628), Color(0xFF1B3A63)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_LARGE),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'خدمة داخل عقار',
              style: robotoMedium.copyWith(fontSize: 11, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'إضافة خدمة داخل عقار',
            style: robotoBold.copyWith(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            'أنشئ عرض الخدمة، اختر نوع العرض والوصف، ثم ارتبه بالباقة والمناطق وأنواع العقار المناسبة.',
            style: robotoRegular.copyWith(
              fontSize: 12,
              color: Colors.white.withOpacity(0.85),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dimensions.PADDING_SIZE_DEFAULT),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: robotoBold.copyWith(fontSize: 15)),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: robotoRegular.copyWith(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePicker(
    BuildContext context,
    ServiceOfferController offerController,
  ) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'صورة العرض',
            subtitle: 'أضف صورة احترافية تعلن عن الخدمة',
          ),
          GestureDetector(
            onTap: offerController.pickImage,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FB),
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                border: Border.all(color: Colors.grey.withOpacity(0.25)),
              ),
              child: offerController.pickedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(
                        Dimensions.RADIUS_DEFAULT,
                      ),
                      child: Image.file(
                        File(offerController.pickedImage!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    )
                  : Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.image_outlined,
                            size: 40,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'لا توجد صورة',
                            style: robotoRegular.copyWith(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
          const SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
          _primaryButton(
            text: 'اختيار صورة العرض',
            onPressed: offerController.pickImage,
            height: 42,
          ),
        ],
      ),
    );
  }

  Widget _buildServiceInfo(
    BuildContext context,
    ServiceOfferController offerController,
  ) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'معلومات الخدمة',
            subtitle: 'أدخل البيانات الأساسية التي ستظهر داخل العقار',
          ),

          Text(
            'اختر الخدمة',
            style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                isExpanded: true,
                value: offerController.selectedServiceTypeIndex >= 0
                    ? offerController.selectedServiceTypeIndex
                    : null,
                hint: Text(
                  'اختر نوع الخدمة',
                  style: robotoRegular.copyWith(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                items: List.generate(offerController.serviceTypes.length, (i) {
                  return DropdownMenuItem(
                    value: i,
                    child: Text(offerController.serviceTypes[i].name ?? ''),
                  );
                }),
                onChanged: (v) {
                  if (v != null) offerController.selectServiceType(v);
                },
              ),
            ),
          ),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          Text(
            'عنوان العرض',
            style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          MyTextField(
            hintText: 'اكتب عنوان العرض',
            controller: _titleController,
            showBorder: true,
          ),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          Text(
            'نوع العرض',
            style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _offerTypeCard(
                  context,
                  offerController,
                  type: 'price',
                  icon: Icons.attach_money,
                  title: 'سعر مباشر',
                  subtitle: 'يظهر العرض بسعر ثابت ومحدد',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _offerTypeCard(
                  context,
                  offerController,
                  type: 'discount',
                  icon: Icons.percent,
                  title: 'خصم %',
                  subtitle: 'يظهر العرض بنسبة خصم على السعر',
                ),
              ),
            ],
          ),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          Text(
            offerController.offerType == 'discount'
                ? 'نسبة الخصم (%)'
                : 'السعر (ريال)',
            style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          MyTextField(
            hintText: offerController.offerType == 'discount'
                ? 'مثال: 20'
                : 'مثال: 500',
            controller: _valueController,
            inputType: TextInputType.number,
            showBorder: true,
          ),
          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          Text(
            'وصف الخدمة',
            style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 6),
          MyTextField(
            hintText: 'اكتب وصفاً واضحاً للخدمة...',
            controller: _descController,
            maxLines: 4,
            showBorder: true,
          ),
        ],
      ),
    );
  }

  Widget _offerTypeCard(
    BuildContext context,
    ServiceOfferController offerController, {
    required String type,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool selected = offerController.offerType == type;
    return InkWell(
      onTap: () => offerController.setOfferType(type),
      borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withOpacity(0.08)
              : const Color(0xFFF8FAFC),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.2),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected
                  ? Theme.of(context).primaryColor
                  : Colors.grey[500],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: robotoBold.copyWith(
                fontSize: 13,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: robotoRegular.copyWith(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _planFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Text(text, style: robotoRegular.copyWith(fontSize: 10)),
    );
  }

  Widget _buildPlans(
    BuildContext context,
    ServiceOfferController offerController,
  ) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'اختر الباقة المناسبة',
            subtitle: 'حدد الباقة أولاً لتفعيل خيارات المناطق وأنواع العقار',
          ),
          ...List.generate(offerController.servicePlans.length, (index) {
            final ServicePlanModel plan = offerController.servicePlans[index];
            final bool selected = index == offerController.selectedPlanIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => offerController.selectPlan(index),
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_DEFAULT),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).primaryColor.withOpacity(0.06)
                        : const Color(0xFFF8FAFC),
                    border: Border.all(
                      color: selected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.2),
                      width: selected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(
                      Dimensions.RADIUS_DEFAULT,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            plan.name ?? '',
                            style: robotoBold.copyWith(fontSize: 14),
                          ),
                          if (selected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'تم الاختيار',
                                style: robotoMedium.copyWith(
                                  fontSize: 9,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${plan.price?.toStringAsFixed(0)} ريال / شهر',
                        style: robotoBold.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _planFeatureChip('${plan.numberOfAds ?? 0} إعلانات'),
                          _planFeatureChip(
                            '${plan.numberOfCategories ?? 0} أنواع عقار',
                          ),
                          _planFeatureChip('${plan.numberOfZone ?? 0} مناطق'),
                          if (plan.featuredDisplay ?? false)
                            _planFeatureChip('ظهور مميز'),
                          if (plan.interactiveReports ?? false)
                            _planFeatureChip('تقارير تفاعلية'),
                          if (plan.crmSystem ?? false)
                            _planFeatureChip('نظام CRM'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor
              : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : Colors.grey.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: robotoMedium.copyWith(
            fontSize: 12,
            color: selected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildZonesAndCategories(
    BuildContext context,
    ServiceOfferController offerController,
  ) {
    final plan = offerController.selectedPlan;
    final allowedCategories = plan?.numberOfCategories ?? 0;
    final allowedZones = plan?.numberOfZone ?? 0;

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            'اختر المناطق وأنواع العقار',
            subtitle:
                'حدد المناطق التي تريد إظهار الخدمة فيها وأنواع العقار المناسبة',
          ),

          Text(
            'المناطق',
            style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: offerController.zones.map((zone) {
              final selected = offerController.selectedZoneIds.contains(
                zone.id,
              );
              return _chip(
                context,
                label: (zone.nameAr?.isNotEmpty ?? false)
                    ? zone.nameAr!
                    : (zone.name ?? ''),
                selected: selected,
                onTap: () => offerController.toggleZone(zone.id ?? 0),
              );
            }).toList(),
          ),
          if (allowedZones > 0 &&
              offerController.selectedZoneIds.length > allowedZones)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'الحد المتاح في باقتك: $allowedZones منطقة (زيادة 50 ريال على كل منطقة إضافية)',
                  style: robotoRegular.copyWith(
                    fontSize: 11,
                    color: Colors.orange[800],
                  ),
                ),
              ),
            ),

          const SizedBox(height: Dimensions.PADDING_SIZE_DEFAULT),

          Text(
            'أنواع العقار',
            style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey[700]),
          ),
          const SizedBox(height: 4),
          Text(
            'الحد المتاح: ${allowedCategories == 0 ? 'غير محدد' : '$allowedCategories أنواع'}',
            style: robotoRegular.copyWith(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: offerController.categories.map((category) {
              final selected = offerController.selectedCategoryIds.contains(
                category.id,
              );
              return _chip(
                context,
                label: (category.nameAr?.isNotEmpty ?? false)
                    ? category.nameAr!
                    : (category.name ?? ''),
                selected: selected,
                onTap: () => offerController.toggleCategory(category.id ?? 0),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDuration(
    BuildContext context,
    ServiceOfferController offerController,
  ) {
    final durations = [
      {'value': 1, 'label': 'شهر'},
      {'value': 3, 'label': '3 أشهر'},
      {'value': 6, 'label': '6 أشهر'},
      {'value': 12, 'label': 'سنة'},
    ];
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('مدة الاشتراك'),
          Row(
            children: durations.map((d) {
              final selected = offerController.selectedDuration == d['value'];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () =>
                        offerController.selectDuration(d['value'] as int),
                    borderRadius: BorderRadius.circular(
                      Dimensions.RADIUS_DEFAULT,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).primaryColor
                            : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(
                          Dimensions.RADIUS_DEFAULT,
                        ),
                        border: Border.all(
                          color: selected
                              ? Theme.of(context).primaryColor
                              : Colors.grey.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        d['label'] as String,
                        style: robotoMedium.copyWith(
                          fontSize: 11,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryDate(
    BuildContext context,
    ServiceOfferController offerController,
  ) {
    return _sectionCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'تاريخ الانتهاء المتوقع',
            style: robotoMedium.copyWith(fontSize: 12, color: Colors.grey[700]),
          ),
          Text(
            offerController.expiryDateText,
            style: robotoBold.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    ServiceOfferController offerController,
  ) {
    final total =
        offerController.priceCalculation?.totalPrice ??
        offerController.selectedPlan?.price ??
        0;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        Dimensions.PADDING_SIZE_DEFAULT,
        10,
        Dimensions.PADDING_SIZE_DEFAULT,
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإجمالي النهائي',
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: Colors.grey[600],
                    ),
                  ),
                  offerController.isPriceLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '${total.toStringAsFixed(0)} ريال',
                          style: robotoBold.copyWith(
                            fontSize: 18,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 170,
              height: 46,
              child: offerController.isSubmitting
                  ? const Center(child: CircularProgressIndicator())
                  : _primaryButton(
                      text: 'إكمال والدفع',
                      onPressed: () => _submit(offerController),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(ServiceOfferController offerController) async {
    final result = await offerController.submitOffer(
      title: _titleController.text,
      description: _descController.text,
      priceOrDiscountValue: _valueController.text,
    );
    if (result != null && result.paymentUrl != null) {
      Get.toNamed(
        RouteHelper.getServiceOfferPaymentRoute(),
        arguments: {
          'url': result.paymentUrl,
          'number': result.subscriptionNumber,
        },
      );
    }
  }
}
