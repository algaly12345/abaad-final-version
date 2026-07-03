import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ServiceOfferPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String subscriptionNumber;

  const ServiceOfferPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.subscriptionNumber,
  });

  @override
  State<ServiceOfferPaymentScreen> createState() =>
      _ServiceOfferPaymentScreenState();
}

class _ServiceOfferPaymentScreenState extends State<ServiceOfferPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => _isLoading = true);
            _checkIfCallback(url);
          },
          onPageFinished: (url) {
            setState(() => _isLoading = false);
            _checkIfCallback(url);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  // رابط الـ callback القادم من الباكند يحتوي على "/callback" دائمًا
  void _checkIfCallback(String url) {
    if (url.contains('/callback') && !_isChecking) {
      _isChecking = true;
      Future.delayed(const Duration(milliseconds: 800), _confirmStatus);
    }
  }

  Future<void> _confirmStatus() async {
    final controller = Get.find<ServiceOfferController>();
    final isPaid = await controller.checkSubscriptionStatus(
      widget.subscriptionNumber,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isPaid ? 'تم الدفع بنجاح' : 'تعذر تأكيد الدفع'),
        content: Text(
          isPaid
              ? 'تم تفعيل اشتراكك بنجاح، وسيظهر العرض داخل العقار قريبًا.'
              : 'لم نتمكن من تأكيد عملية الدفع، يمكنك المحاولة مرة أخرى من قائمة اشتراكاتي.',
          style: robotoRegular.copyWith(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Get.until((route) => route.isFirst);
            },
            child: Text(
              'حسناً',
              style: robotoMedium.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'الدفع'),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
