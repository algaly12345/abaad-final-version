import 'dart:io';

import 'package:abaad_flutter/features/provider/data/models/service_offer_model.dart';
import 'package:abaad_flutter/features/services/controller/nearby_location_helper.dart';
import 'package:abaad_flutter/features/services/controller/services_controller.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/foundation.dart' show Factory, kIsWeb;
import 'package:flutter/gestures.dart'
    show EagerGestureRecognizer, OneSequenceGestureRecognizer;
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// تعديل بيانات الخدمة — صفحة واحدة بنفس تصميم الخطوة الأولى من شاشة الإضافة
/// (add_property_service_offer_screen.dart) لكن بلا تابات/خطوات.
/// نوع الخدمة والمناطق وأنواع العقار والمدة تُعرض للقراءة فقط ولا تُرسل
/// للباكند أصلاً (POST services/{id}/details).
class EditServiceDetailsScreen extends StatefulWidget {
  final ServiceOffer service;
  const EditServiceDetailsScreen({super.key, required this.service});

  @override
  State<EditServiceDetailsScreen> createState() =>
      _EditServiceDetailsScreenState();
}

class _EditServiceDetailsScreenState extends State<EditServiceDetailsScreen> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _valueCtrl; // سعر أو نسبة خصم حسب _offerType
  late String _contactType;
  late String _offerType;
  XFile? _newImage;
  // موقع الخدمة على الخارطة — يبدأ بالمحفوظ ويتحدّث بسحب الخارطة/زرّ موقعي.
  static const LatLng _fallbackCenter = LatLng(24.7136, 46.6753);
  double? _lat;
  double? _lng;
  GoogleMapController? _mapController;
  CameraPosition? _cameraPosition;
  bool _locating = false;
  // الخارطة مقفلة افتراضياً كي لا تلتهم سحب التمرير؛ تُفعَّل بزر "تعديل الموقع".
  bool _mapEditing = false;
  bool _resolvingAddress = false;
  bool _saving = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _titleCtrl = TextEditingController(text: s.title ?? '');
    _descCtrl = TextEditingController(text: s.description ?? '');
    _addressCtrl = TextEditingController(text: s.address ?? '');
    // رقم العرض نفسه له الأولوية، ويسقط للعروض القديمة (بلا contact_phone) على
    // رقم حساب المزوّد — نفس منطق شاشة التفاصيل، كي لا يبدأ الحقل فارغاً.
    final ownPhone = s.contactPhone?.trim() ?? '';
    final providerPhone =
        (s.providers?.isNotEmpty ?? false) ? s.providers!.first.phone : null;
    _phoneCtrl = TextEditingController(
        text: ownPhone.isNotEmpty ? ownPhone : (providerPhone ?? ''));
    _offerType = s.offerType == 'discount' ? 'discount' : 'price';
    _valueCtrl = TextEditingController(text: _initialValue(s));
    _lat = s.latitude;
    _lng = s.longitude;
    // الخدمات القديمة قد تحمل 'phone' أو null — نرجع للقيمة الافتراضية 'both'.
    _contactType = const ['whatsapp', 'call', 'both'].contains(s.contactType)
        ? s.contactType!
        : 'both';
  }

  String _initialValue(ServiceOffer s) {
    if (_offerType == 'price') return s.servicePrice ?? '';
    final d = s.discount;
    if (d == null) return '';
    return d % 1 == 0 ? d.toInt().toString() : d.toString();
  }

  LatLng get _initialCenter =>
      (_lat != null && _lng != null) ? LatLng(_lat!, _lng!) : _fallbackCenter;

  // يُستدعى عند توقّف الخارطة بعد تحريك المستخدم فقط (لا عند الإنشاء) كي لا
  // يُستبدل العنوان المحفوظ بنص مترجَم قبل أن يغيّر المستخدم الموقع فعلاً.
  Future<void> _onPinMoved(LatLng position) async {
    setState(() {
      _lat = position.latitude;
      _lng = position.longitude;
      _resolvingAddress = true;
    });
    String? address;
    try {
      final placemarks = await Geocoding().placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address = [
          p.subLocality,
          p.locality,
          p.administrativeArea,
        ].where((e) => e != null && e.trim().isNotEmpty).join('، ');
      }
    } catch (_) {
      // فشل الترميز العكسي لا يمنع حفظ الإحداثيات — هي مصدر الحقيقة.
    }
    if (!mounted) return;
    setState(() => _resolvingAddress = false);
    if ((address ?? '').trim().isNotEmpty) _addressCtrl.text = address!.trim();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    final position = await NearbyLocationHelper.resolveCurrentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (position == null) return;
    await _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(position.latitude, position.longitude)),
    );
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) setState(() => _newImage = image);
    } catch (_) {
      showCustomSnackBar('edit_svc_image_pick_failed'.tr);
    }
  }

  double? get _value => double.tryParse(_valueCtrl.text.trim());

  bool get _valid =>
      _titleCtrl.text.trim().isNotEmpty &&
      _descCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().isNotEmpty &&
      _value != null &&
      _value! >= 0 &&
      (_offerType != 'discount' || _value! <= 100);

  Future<void> _save() async {
    if (_saving) return;
    if (!_valid) {
      setState(() => _showErrors = true);
      return;
    }
    setState(() => _saving = true);
    final valueText = _valueCtrl.text.trim();
    final ok = await Get.find<ServicesController>().updateServiceDetails(
      widget.service.id!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      contactType: _contactType,
      offerType: _offerType,
      servicePrice: _offerType == 'price' ? valueText : null,
      discount: _offerType == 'discount' ? valueText : null,
      latitude: _lat,
      longitude: _lng,
      image: _newImage,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Listener(
      // إغلاق الكيبورد عند الضغط خارج الحقول — نفس سلوك شاشة الإضافة.
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F6FB),
        body: Column(
          children: [
            _buildTopBar(context, primary),
            Expanded(child: _buildForm(context, primary)),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  // ─── نفس الشريط العلوي لشاشة الإضافة، بدون شريط التقدّم ───────────────────
  Widget _buildTopBar(BuildContext context, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: AppShadows.soft(blur: 10, opacity: 0.05),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.sm,
            Spacing.xs,
            Spacing.pagePadding,
            Spacing.lg,
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: AppColors.textPrimary(context),
                  size: 18,
                ),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Text(
                  'edit_service'.tr,
                  style: AppTypography.title.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              Icon(Icons.edit_outlined, color: primary, size: IconSpec.large),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        boxShadow: AppShadows.soft(blur: 16, opacity: 0.08),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showErrors && !_valid) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 15,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      'complete_required_fields'.tr,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
              ],
              DSPrimaryButton(
                label: 'save'.tr,
                icon: Icons.check_rounded,
                loading: _saving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, Color primary) {
    final s = widget.service;
    final isDiscount = _offerType == 'discount';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            icon: Icons.miscellaneous_services_outlined,
            title: 'service_data'.tr,
            subtitle: 'edit_service_subtitle'.tr,
            primary: primary,
          ),
          const SizedBox(height: Spacing.xl),

          // Image
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(
                  'edit_svc_image_label'.tr,
                  icon: Icons.image_outlined,
                ),
                const SizedBox(height: Spacing.sm),
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 128,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.background(context),
                      borderRadius: BorderRadius.circular(AppRadius.medium),
                      border: Border.all(color: AppColors.border(context)),
                    ),
                    child: _newImage != null
                        ? (kIsWeb
                              ? Image.network(
                                  _newImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_newImage!.path),
                                  fit: BoxFit.cover,
                                ))
                        : CustomImage(
                            image: s.image ?? '',
                            width: double.infinity,
                            height: 128,
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(
                    Icons.swap_horiz_rounded,
                    size: IconSpec.small,
                  ),
                  label: Text(
                    'change_image'.tr,
                    style: AppTypography.smallMedium,
                  ),
                  style: TextButton.styleFrom(foregroundColor: primary),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Title
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(
                  'edit_svc_title_label'.tr,
                  icon: Icons.title_rounded,
                ),
                const SizedBox(height: Spacing.sm),
                _textField(
                  context,
                  hint: 'edit_svc_title_hint'.tr,
                  controller: _titleCtrl,
                ),
                if (_showErrors && _titleCtrl.text.trim().isEmpty)
                  _RequiredHint('edit_svc_title_required'.tr),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Contact phone + type
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel('contact_phone'.tr, icon: Icons.phone_outlined),
                const SizedBox(height: Spacing.sm),
                _textField(
                  context,
                  hint: '05XXXXXXXX',
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                ),
                if (_showErrors && _phoneCtrl.text.trim().isEmpty)
                  _RequiredHint('edit_svc_phone_required'.tr),
                const SizedBox(height: Spacing.md),
                _FieldLabel(
                  'contact_type_label'.tr,
                  icon: Icons.forum_outlined,
                ),
                const SizedBox(height: Spacing.sm),
                _contactTypeSelector(context, primary),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Offer type + value
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(
                  'edit_svc_offer_type_label'.tr,
                  icon: Icons.sell_outlined,
                ),
                const SizedBox(height: Spacing.md),
                Row(
                  children: [
                    _offerTypeCard(
                      context,
                      primary,
                      type: 'price',
                      icon: Icons.sell_outlined,
                      useRiyalIcon: true,
                      title: 'edit_svc_offer_price'.tr,
                      sub: 'edit_svc_offer_price_sub'.tr,
                    ),
                    const SizedBox(width: Spacing.sm),
                    _offerTypeCard(
                      context,
                      primary,
                      type: 'discount',
                      icon: Icons.percent_rounded,
                      title: 'edit_svc_offer_discount'.tr,
                      sub: 'edit_svc_offer_discount_sub'.tr,
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.md),
                _FieldLabel(
                  isDiscount
                      ? 'edit_svc_discount_label'.tr
                      : 'edit_svc_price_label'.tr,
                  icon: Icons.numbers_rounded,
                ),
                const SizedBox(height: Spacing.sm),
                _textField(
                  context,
                  hint: isDiscount
                      ? 'edit_svc_discount_hint'.tr
                      : 'edit_svc_price_hint'.tr,
                  controller: _valueCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
                if (_showErrors &&
                    (_value == null || (isDiscount && _value! > 100)))
                  _RequiredHint(
                    isDiscount
                        ? 'edit_svc_discount_invalid'.tr
                        : 'edit_svc_price_required'.tr,
                  ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          // Description
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(
                  'edit_svc_desc_label'.tr,
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: Spacing.sm),
                _textField(
                  context,
                  hint: 'edit_svc_desc_hint'.tr,
                  controller: _descCtrl,
                  maxLines: 4,
                ),
                if (_showErrors && _descCtrl.text.trim().isEmpty)
                  _RequiredHint('edit_svc_desc_required'.tr),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          _mapCard(context, primary),
          const SizedBox(height: Spacing.md),

          // Address
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FieldLabel(
                  'service_address_label'.tr,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: Spacing.sm),
                _textField(
                  context,
                  hint: 'edit_svc_address_hint'.tr,
                  controller: _addressCtrl,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),

          _lockedCard(context, primary),
          const SizedBox(height: Spacing.xxl),
        ],
      ),
    );
  }

  // ─── عناصر مطابقة لنظيراتها في شاشة الإضافة ────────────────────────────────

  Widget _textField(
    BuildContext context, {
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) {
        if (_showErrors) setState(() {});
      },
      style: AppTypography.body.copyWith(color: AppColors.textPrimary(context)),
      decoration: dsInputDecoration(context, hint: hint),
    );
  }

  Widget _offerTypeCard(
    BuildContext context,
    Color primary, {
    required String type,
    required IconData icon,
    bool useRiyalIcon = false,
    required String title,
    required String sub,
  }) {
    final selected = _offerType == type;
    final unselectedText = AppColors.textSecondary(context);
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_offerType == type) return;
          // يُفرَّغ الحقل عند التبديل كي لا يبقى رقم من النوع السابق ظاهراً
          // بمعنى مختلف (نفس سلوك شاشة الإضافة).
          setState(() {
            _offerType = type;
            _valueCtrl.clear();
          });
        },
        child: AnimatedContainer(
          duration: AnimSpec.button,
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: 0.08)
                : AppColors.background(context),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: selected ? primary : AppColors.border(context),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              useRiyalIcon
                  ? Image.asset(
                      'assets/image/riyals.png',
                      width: IconSpec.small,
                      height: IconSpec.small,
                      color: selected ? primary : unselectedText,
                    )
                  : Icon(
                      icon,
                      size: IconSpec.small,
                      color: selected ? primary : unselectedText,
                    ),
              const SizedBox(height: Spacing.sm),
              Text(
                title,
                style: AppTypography.smallBold.copyWith(
                  color: selected ? primary : AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                style: AppTypography.badge.copyWith(color: unselectedText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _contactTypeSelector(BuildContext context, Color primary) {
    const options = [
      ('whatsapp', 'contact_type_whatsapp', Icons.chat_rounded),
      ('call', 'contact_type_call', Icons.call_rounded),
      ('both', 'contact_type_both', Icons.contact_phone_rounded),
    ];
    final children = <Widget>[];
    for (final o in options) {
      final (type, labelKey, icon) = o;
      final selected = _contactType == type;
      if (children.isNotEmpty) children.add(const SizedBox(width: Spacing.sm));
      children.add(
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _contactType = type),
            child: AnimatedContainer(
              duration: AnimSpec.button,
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              decoration: BoxDecoration(
                color: selected
                    ? primary.withValues(alpha: 0.08)
                    : AppColors.background(context),
                borderRadius: BorderRadius.circular(AppRadius.medium),
                border: Border.all(
                  color: selected ? primary : AppColors.border(context),
                  width: selected ? 1.5 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: IconSpec.small,
                    color: selected
                        ? primary
                        : AppColors.textSecondary(context),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    labelKey.tr,
                    style:
                        (selected
                                ? AppTypography.captionMedium
                                : AppTypography.caption)
                            .copyWith(
                              color: selected
                                  ? primary
                                  : AppColors.textSecondary(context),
                            ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Row(children: children);
  }

  /// الموقع على الخارطة — دبّوس ثابت بالمنتصف تتحرّك الخارطة تحته (نفس خطوة
  /// الموقع في شاشة الإضافة) داخل بطاقة بارتفاع ثابت لأن الصفحة قابلة للتمرير.
  Widget _mapCard(BuildContext context, Color primary) {
    final hasLocation = _lat != null && _lng != null;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _FieldLabel(
                  'offer_location'.tr,
                  icon: Icons.pin_drop_outlined,
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _mapEditing = !_mapEditing),
                icon: Icon(
                  _mapEditing
                      ? Icons.check_rounded
                      : Icons.edit_location_alt_outlined,
                  size: IconSpec.small,
                ),
                label: Text(
                  (_mapEditing ? 'edit_location_done' : 'edit_location').tr,
                  style: AppTypography.smallMedium,
                ),
                style: TextButton.styleFrom(foregroundColor: primary),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: 260,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // IgnorePointer عند القفل: اللمس يمرّ للصفحة فيعمل التمرير
                  // بدل أن تلتقطه الخارطة.
                  IgnorePointer(
                    ignoring: !_mapEditing,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialCenter,
                        zoom: 15,
                      ),
                      scrollGesturesEnabled: _mapEditing,
                      zoomGesturesEnabled: _mapEditing,
                      rotateGesturesEnabled: _mapEditing,
                      tiltGesturesEnabled: _mapEditing,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      mapToolbarEnabled: false,
                      // الخارطة داخل ListView: بدون هذا يلتهم التمرير سحب الخارطة.
                      gestureRecognizers: _mapEditing
                          ? {
                              Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer(),
                              ),
                            }
                          : const {},
                      onMapCreated: (c) => _mapController = c,
                      onCameraMove: (p) => _cameraPosition = p,
                      onCameraIdle: () {
                        final p = _cameraPosition;
                        if (_mapEditing && p != null) _onPinMoved(p.target);
                      },
                    ),
                  ),
                  IgnorePointer(
                    child: Transform.translate(
                      offset: const Offset(0, -18),
                      child: Icon(Icons.location_on, size: 44, color: primary),
                    ),
                  ),
                  if (_mapEditing)
                    Positioned(
                      bottom: Spacing.md,
                      left: Spacing.md,
                      child: Material(
                        color: AppColors.surface(context),
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: _locating ? null : _useCurrentLocation,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: _locating
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primary,
                                    ),
                                  )
                                : Icon(
                                    Icons.my_location_rounded,
                                    color: primary,
                                    size: 22,
                                  ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: IconSpec.small,
                color: hasLocation ? primary : AppColors.textSecondary(context),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  _resolvingAddress
                      ? 'resolving_location'.tr
                      : (hasLocation
                            ? '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}'
                            : 'location_required_hint'.tr),
                  style: AppTypography.smallMedium.copyWith(
                    color: hasLocation
                        ? AppColors.textPrimary(context)
                        : AppColors.textSecondary(context),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// المناطق/الأنواع للقراءة فقط — نفس بطاقة النظام مع أيقونة قفل.
  Widget _lockedCard(BuildContext context, Color primary) {
    final s = widget.service;
    final zones = (s.zones ?? [])
        .map((z) => z.nameAr ?? z.name ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    final type = s.serviceType?.name ?? '';
    final cats = (s.categories ?? [])
        .map((c) => c.nameAr ?? c.name ?? '')
        .where((e) => e.isNotEmpty)
        .toList();

    Widget chips(List<String> items) => Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: [
        for (final i in items)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: AppColors.border(context)),
            ),
            child: Text(
              i,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
      ],
    );

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _FieldLabel(
            'edit_service_locked_title'.tr,
            icon: Icons.lock_outline_rounded,
          ),
          const SizedBox(height: Spacing.sm),
          if (type.isNotEmpty) ...[
            Text(
              'service_type'.tr,
              style: AppTypography.smallMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            chips([type]),
            const SizedBox(height: Spacing.md),
          ],
          if (zones.isNotEmpty) ...[
            Text(
              'zones_label'.tr,
              style: AppTypography.smallMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            chips(zones),
            const SizedBox(height: Spacing.md),
          ],
          if (cats.isNotEmpty) ...[
            Text(
              'categories_label'.tr,
              style: AppTypography.smallMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: Spacing.xs),
            chips(cats),
            const SizedBox(height: Spacing.md),
          ],
          Text(
            'edit_service_locked_hint'.tr,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── نسخ محلية مطابقة لعناصر شاشة الإضافة الخاصة (private هناك) ──────────────

class _StepHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color primary;
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Icon(icon, color: primary, size: IconSpec.defaultSize),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.title.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(CardSpec.padding),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(AppRadius.large),
        boxShadow: AppShadows.soft(blur: 10, opacity: 0.04),
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final IconData icon;
  const _FieldLabel(this.text, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: IconSpec.small, color: Theme.of(context).primaryColor),
        const SizedBox(width: Spacing.xs),
        Text(
          text,
          style: AppTypography.small.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}

class _RequiredHint extends StatelessWidget {
  final String text;
  const _RequiredHint(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: AppColors.danger),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
