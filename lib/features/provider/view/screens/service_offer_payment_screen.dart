import 'package:abaad_flutter/core/routes/route_helper.dart';
import 'package:abaad_flutter/features/provider/controller/service_offer_controller.dart';
import 'package:abaad_flutter/features/services/view/screens/service_details_screen.dart';
import 'package:abaad_flutter/shared/theme/design_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ServiceOfferPaymentScreen extends StatefulWidget {
  final String paymentUrl;
  final String subscriptionNumber;

  // معرّف العرض (offer_id) الذي يُدفَع اشتراكه — يُمرَّر من معالج "إضافة خدمة"
  // (StoreOfferResponseModel.offerId) ومن زر "ادفع الآن" في تفاصيل الخدمة
  // (service.id). يُستخدم لإعادة المستخدم إلى صفحة تفاصيل هذه الخدمة نفسها
  // بعد نتيجة الدفع بدل السقوط للجذر/تسجيل الدخول. 0 = غير معروف (يسقط
  // لسلوك "خدماتي").
  final int serviceId;

  const ServiceOfferPaymentScreen({
    super.key,
    required this.paymentUrl,
    required this.subscriptionNumber,
    this.serviceId = 0,
  });

  @override
  State<ServiceOfferPaymentScreen> createState() =>
      _ServiceOfferPaymentScreenState();
}

class _ServiceOfferPaymentScreenState extends State<ServiceOfferPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isChecking = false;

  // صفحة الدفع نفسها (نموذج Moyasar + صفحة النتيجة) يقدّمها الباكند كـ HTML
  // عبر WebView — لا يمكن التحكم بملفاتها من هنا. بدل تعديل الباكند، نحقن CSS
  // تعيد تلوين/تشكيل نفس عناصرها (بأسماء أصنافها الفعلية من moyasar.css
  // ومن قالب الباكند) لتطابق نظام تصميم التطبيق، بالكامل من كود فلاتر.
  static const String _themeOverrideCss = '''
    body { background:#F6F8FD !important; font-family: -apple-system, 'Segoe UI', Tahoma, Arial, sans-serif !important; }
    .pay-amount { color:#1A2340 !important; font-weight:800 !important; }
    .pay-sub { color:#64748B !important; }
    .mysr-form-moyasarForm { background:#FFFFFF; border-radius:16px; box-shadow:0 4px 16px rgba(15,30,60,.06); padding:16px; }
    .mysr-form-label { color:#1A2340 !important; font-weight:600 !important; font-size:13px !important; }
    .mysr-form-input, .mysr-form-cardInfoElement {
      border:1px solid #E8ECF0 !important; border-radius:12px !important;
      background:#FFFFFF !important; box-shadow:none !important;
    }
    .mysr-form-input:focus, .mysr-form-cardInfoElement:focus-within { border-color:#1A3C5E !important; }
    .mysr-form-button { background:#1A3C5E !important; border-radius:12px !important; font-weight:700 !important; box-shadow:none !important; }
    .mysr-form-methodButton { border-radius:12px !important; }
    .box { background:#FFFFFF; border-radius:16px; box-shadow:0 4px 16px rgba(15,30,60,.06); padding:32px 24px; }
    .icon { display:inline-flex; align-items:center; justify-content:center; width:64px; height:64px; border-radius:50%; }
    body[data-status="paid"] .icon { background:rgba(31,170,89,.1); }
    body[data-status="failed"] .icon { background:rgba(229,57,53,.1); }
    .msg { color:#1A2340 !important; }
  ''';

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
            _injectThemeOverride();
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _injectThemeOverride() {
    _controller.runJavaScript('''
      (function() {
        if (document.getElementById('app-theme-override')) return;
        var s = document.createElement('style');
        s.id = 'app-theme-override';
        s.innerHTML = `$_themeOverrideCss`;
        document.head.appendChild(s);
      })();
    ''');
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
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DialogSpec.radius)),
        contentPadding: const EdgeInsets.fromLTRB(
            DialogSpec.padding, 20, DialogSpec.padding, Spacing.sm),
        actionsPadding: const EdgeInsets.fromLTRB(
            Spacing.md, 0, Spacing.md, Spacing.sm),
        title: Text(
          isPaid ? 'تم الدفع بنجاح' : 'تعذر تأكيد الدفع',
          style: AppTypography.title.copyWith(color: AppColors.textPrimary(context)),
        ),
        content: Text(
          isPaid
              ? 'تم الدفع بنجاح. طلبك الآن قيد المراجعة من الإدارة، وستصلك رسالة عند الموافقة على عرضك وتفعيل حسابك كمزود خدمة.'
              : 'لم نتمكن من تأكيد عملية الدفع، يمكنك المحاولة مرة أخرى من قائمة اشتراكاتي.',
          style: AppTypography.small.copyWith(color: AppColors.textSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _goToServiceDetails();
            },
            child: Text(
              'حسناً',
              style: AppTypography.smallBold.copyWith(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // زر الرجوع من صفحة الدفع (وزر رجوع الجهاز) يعيد المستخدم لشاشة "خدماتي"
  // (بتبويباتها: نشط/قيد المراجعة/غير مدفوعة/مرفوض/منتهية). يُستخدم Get.until
  // بدل Get.offAllNamed عمداً: Get.offAllNamed كان يمسح المكدّس بالكامل
  // ويجعل "خدماتي" جذراً جديداً بلا أي صفحة قبله، فيتعطّل زرّ رجوعها هي
  // نفسها لاحقاً (لا شيء تحته لتـPop إليه) — نفس الخطأ المُوثَّق ومُصلَح
  // سابقاً في agent_profile_screen.dart. Get.until بدلاً من ذلك يُفرغ فقط
  // الصفحات فوق "خدماتي" (تفاصيل الخدمة وصفحة الدفع) ويُبقي كل ما تحتها
  // (لوحة التحكم) سليماً، فيعمل زر رجوع "خدماتي" طبيعياً بعدها. إن لم تكن
  // "خدماتي" ضمن المكدّس أصلاً (الدخول من معالج إضافة خدمة جديدة بدل زر
  // "ادفع الآن" لعرض قائم) يتوقف عند أول صفحة (route.isFirst) بدل حلقة بلا
  // نهاية، فلا يعلق المستخدم داخل خطوات المعالج.
  void _goToMyServices() {
    Get.until((route) =>
    route.settings.name == RouteHelper.myServices || route.isFirst);
  }

  // بعد ظهور نتيجة الدفع (نجاح أو فشل) نُعيد المستخدم إلى صفحة تفاصيل هذه
  // الخدمة نفسها — لا للجذر ولا لتسجيل الدخول (الخطأ السابق: زر "حسناً" كان
  // ينادي Get.until((r) => r.isFirst) فيمسح المكدّس بالكامل وصولاً لأول
  // صفحة، وهي في تدفّق "زائر ← تسجيل دخول ← معالج" شاشة مصادَقة، فيهبط
  // المستخدم عليها). Get.offUntil عملية Navigator واحدة ذرّية (دفع الصفحة
  // الجديدة + إزالة ما تحتها معاً) فتتفادى وميض إعادة بناء الشجرة الذي منع
  // سابقاً نهج "انتقالين متتاليين" (راجع تعليق _goToMyServices). المُسند
  // يُبقي كل شيء حتى "خدماتي" إن كانت بالمكدّس وإلا حتى أول صفحة، ثم يضع
  // التفاصيل فوقها فيبقى زر رجوعها سليماً. لو لم يصل serviceId (0) نسقط
  // لسلوك "خدماتي" الافتراضي.
  void _goToServiceDetails() {
    if (widget.serviceId <= 0) {
      _goToMyServices();
      return;
    }
    Get.offUntil(
      GetPageRoute(
        page: () => ServiceDetailsScreen(serviceId: widget.serviceId),
        transition: Transition.cupertino,
      ),
      (route) =>
      route.settings.name == RouteHelper.myServices || route.isFirst,
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            InkWell(
              onTap: _goToMyServices,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Icon(Icons.arrow_back_ios_new_rounded,
                    size: 18, color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'الدفع',
                style: AppTypography.title
                    .copyWith(color: AppColors.textPrimary(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return WillPopScope(
      onWillPop: () async {
        _goToMyServices();
        return false;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: Stack(
                children: [
                  WebViewWidget(controller: _controller),
                  if (_isLoading)
                    Container(
                      color: AppColors.background(context),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: primary),
                            const SizedBox(height: Spacing.lg),
                            Text('جاري تحميل صفحة الدفع...',
                                style: AppTypography.small.copyWith(
                                    color: AppColors.textSecondary(context))),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
