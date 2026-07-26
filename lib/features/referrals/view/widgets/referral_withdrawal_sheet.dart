import 'package:abaad_flutter/features/referrals/controller/referral_controller.dart';
import 'package:abaad_flutter/shared/helpers/price_converter.dart';
import 'package:abaad_flutter/shared/utils/dimensions.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_button.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:abaad_flutter/shared/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ReferralWithdrawalSheet extends StatefulWidget {
  final double availableBalance;
  const ReferralWithdrawalSheet({super.key, required this.availableBalance});

  @override
  State<ReferralWithdrawalSheet> createState() => _ReferralWithdrawalSheetState();
}

class _ReferralWithdrawalSheetState extends State<ReferralWithdrawalSheet> {
  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 550,
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.RADIUS_LARGE)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'available_for_withdrawal'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
            Text(
              PriceConverter.convertPrice(widget.availableBalance),
              style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).primaryColor),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                border: Border.all(color: Theme.of(context).primaryColor, width: 0.3),
              ),
              child: CustomTextField(
                hintText: '0',
                controller: _amountController,
                inputType: const TextInputType.numberWithOptions(decimal: true),
                maxLines: 1,
              ),
            ),
            SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            GetBuilder<ReferralController>(
              builder: (referralController) {
                return !referralController.isRequestingWithdrawal
                    ? CustomButton(
                        width: 140,
                        height: 40,
                        buttonText: 'request_withdrawal'.tr,
                        onPressed: () async {
                          final double? amount = double.tryParse(_amountController.text.trim());

                          if (amount == null || amount <= 0) {
                            showCustomSnackBar('input_field_is_empty'.tr);
                            return;
                          }

                          if (amount > widget.availableBalance) {
                            showCustomSnackBar('amount_exceeds_available_balance'.tr);
                            return;
                          }

                          final bool success = await referralController.requestWithdrawal(amount);
                          if (success) {
                            Get.back();
                          }
                        },
                      )
                    : const Center(child: CircularProgressIndicator());
              },
            ),
          ],
        ),
      ),
    );
  }
}
