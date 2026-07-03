import 'package:abaad_flutter/features/auth/controller/auth_controller.dart';
import 'package:abaad_flutter/features/estate/controller/estate_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_button.dart';
import 'package:abaad_flutter/shared/widgets/app_dropdown.dart';
import 'package:abaad_flutter/shared/widgets/my_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReportWidget extends StatefulWidget {
  final int estate_id;
  const ReportWidget({required Key? key, required this.estate_id})
      : super(key: key);

  @override
  State<ReportWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportWidget>
    with SingleTickerProviderStateMixin {
  final TextEditingController _longDescController = TextEditingController();
  final FocusNode _longDescFocus = FocusNode();
  late bool _isLoggedIn;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    Get.find<EstateController>().setReportIndex(
      Get.find<EstateController>().reportList[0],
      false,
    );

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if (_isLoggedIn && Get.find<UserController>().userInfoModel == null) {
      Get.find<UserController>().getUserInfo();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _longDescController.dispose();
    _longDescFocus.dispose();
    super.dispose();
  }

  String? _documentTypeValue;

  final List<Map<String, String>> reasonItems = [
    {'key': 'place_wrong', 'label': 'place_wrong'.tr},
    {
      'key': 'contradicting_terms',
      'label': 'contradicting_the_terms_o_the_real_estate_authority'.tr,
    },
    {'key': 'another_reason', 'label': 'another_reason'.tr},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = Get.isDarkMode;

    return GetBuilder<EstateController>(
      builder: (estateController) {
        return FadeTransition(
          opacity: _fadeAnim,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ─── Header ───────────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.flag_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'report_the_ad'.tr,
                            style: robotoMedium.copyWith(
                              fontSize: Dimensions.fontSizeLarge,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // ── زر الإغلاق ──
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ─── Body ─────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label
                        Row(
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 16,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'document_type'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Dropdown
                        AppDropdown<String>(
                          value: _documentTypeValue,
                          hintText: 'please_select_reason'.tr,
                          leadingIcon: Icons.flag_outlined,
                          items: reasonItems
                              .map<DropdownMenuItem<String>>((item) =>
                                  DropdownMenuItem<String>(
                                    value: item['key'],
                                    child: Text(item['label']!),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _documentTypeValue = value),
                        ),

                        const SizedBox(height: 16),

                        // Label
                        Row(
                          children: [
                            Icon(
                              Icons.edit_note_rounded,
                              size: 16,
                              color: theme.primaryColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'text_of_the_communication'.tr,
                              style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeSmall,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Text Field
                        MyTextField(
                          hintText: 'text_of_the_communication'.tr,
                          controller: _longDescController,
                          focusNode: _longDescFocus,
                          size: 17,
                          maxLines: 4,
                          inputType: TextInputType.text,
                          capitalization: TextCapitalization.sentences,
                          showBorder: true,
                        ),

                        const SizedBox(height: 20),

                        // ─── Action Buttons ────────────────────────
                        Row(
                          children: [
                            // Cancel
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                                  side: BorderSide(
                                    color: Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'cancel'.tr,
                                  style: robotoMedium.copyWith(
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Send
                            Expanded(
                              flex: 2,
                              child: estateController.isLoading
                                  ? Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: theme.primaryColor
                                      .withOpacity(0.1),
                                  borderRadius:
                                  BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: theme.primaryColor,
                                    ),
                                  ),
                                ),
                              )
                                  : ElevatedButton(
                                onPressed: _documentTypeValue == null
                                    ? null
                                    : () {
                                  estateController.insertEstate(
                                    _documentTypeValue!,
                                    _longDescController.text,
                                    widget.estate_id,
                                    context,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.primaryColor,
                                  disabledBackgroundColor:
                                  theme.primaryColor.withOpacity(0.4),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.send_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'send'.tr,
                                      style: robotoMedium.copyWith(
                                        color: Colors.white,
                                        fontSize:
                                        Dimensions.fontSizeDefault,
                                      ),
                                    ),
                                  ],
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
      },
    );
  }
}