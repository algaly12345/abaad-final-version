import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OffersWebView extends StatefulWidget {
  const OffersWebView({super.key});

  @override
  State<OffersWebView> createState() => _OffersWebViewState();
}

class _OffersWebViewState extends State<OffersWebView> {
  late final WebViewController controller;

  bool isLoading = true; // 👈 حالة التحميل

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)

    // 👇 يبدأ التحميل
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() => isLoading = true);
          },
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
        ),
      )

      ..loadRequest(
        Uri.parse('https://app.abaadapp.sa/website-offers/step-one'),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('العروض')),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),

          // 👇 اللودينق
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}