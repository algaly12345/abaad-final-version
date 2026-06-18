
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/wallet_controller.dart';
import 'package:abaad_flutter/helper/price_converter.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WalletBottomSheet extends StatefulWidget {
  final bool fromWallet;
  const WalletBottomSheet({required Key key, required this.fromWallet}) : super(key: key);

  @override
  State<WalletBottomSheet> createState() => _WalletBottomSheetState();
}

class _WalletBottomSheetState extends State<WalletBottomSheet> {

  final TextEditingController _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    //print(widget.fromWallet);

    int? exchangePointRate = Get.find<SplashController>().configModel?.loyaltyPointExchangeRate;
    int? minimumExchangePoint = Get.find<SplashController>().configModel?.minimumPointToTransfer;

    return Container(
      width: 550,
      padding: EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.RADIUS_LARGE)),
      ),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          Text('your_loyalty_point_will_convert_to_currency_and_transfer_to_your_wallet'.tr,
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall, color: Theme.of(context).disabledColor),
              maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
          SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

          Text('$exchangePointRate ${'points'.tr}= ${PriceConverter.convertPrice(1)}',
              style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeDefault, color: Theme.of(context).primaryColor)),
          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), border: Border.all(color: Theme.of(context).primaryColor,width: 0.3)),
            child: CustomTextField(
              hintText: '0',
              controller: _amountController,
              inputType: TextInputType.phone,
              maxLines: 1,
              // textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: Dimensions.PADDING_SIZE_LARGE),

          GetBuilder<WalletController>(
            builder: (walletController) {
              return !walletController.isLoading ? CustomButton(
                width: 100,
                  height: 40,
                  buttonText: 'convert'.tr,
                  onPressed: () {
                    if(_amountController.text.isEmpty) {
                      showCustomSnackBar('input_field_is_empty'.tr);
                    }else{
                      int amount = int.parse(_amountController.text.trim());
                      //print(amount);

                      if(amount <minimumExchangePoint!){
                        showCustomSnackBar('${'please_exchange_more_then'.tr} $minimumExchangePoint ${'points'.tr}');
                      } else {
                          walletController.pointToWallet(amount, widget.fromWallet);
                        }
                    }
                },
              ) : Center(child: CircularProgressIndicator());
            }
          ),
        ]),
      ),
    );
  }
}
