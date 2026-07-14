import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/utils/styles.dart';
import 'package:abaad_flutter/shared/widgets/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// بطاقة توثيق الوسيط العقاري (نمط بيوت): صورة + اسم + شارة عضوية، ثم
/// معلومات موثوقة من الهيئة العامة للعقار (رقم رخصة فال، رقم ترخيص الإعلان،
/// تاريخ الإصدار والانتهاء)، وأخيراً رمز QR لرابط الإعلان على منصة الهيئة.
/// تختفي البطاقة بالكامل لو لا يوجد وسيط مرتبط بالعقار.
class EstateBrokerVerificationCard extends StatelessWidget {
  final Estate estate;

  const EstateBrokerVerificationCard({super.key, required this.estate});

  @override
  Widget build(BuildContext context) {
    final broker = estate.users;
    if (broker == null) return const SizedBox.shrink();

    final primary = Theme.of(context).primaryColor;
    final membership = broker.membershipType ?? '';
    final falLicense = broker.falLicenseNumber ?? '';
    final adLicense = estate.adLicenseNumber ?? '';
    final issueDate = estate.creationDate ?? '';
    final expiryDate = estate.endDate ?? '';
    final qrUrl = estate.adLicenseUrl ?? '';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رأس البطاقة: خلفية متدرجة + صورة الوسيط + اسمه
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withValues(alpha: 0.75)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipOval(
                    child: (broker.image != null && broker.image!.isNotEmpty)
                        ? CustomImage(
                            image: broker.image!,
                            fit: BoxFit.cover,
                            width: 56,
                            height: 56,
                          )
                        : const Icon(
                            Icons.person_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        broker.name ?? '',
                        style: robotoBold.copyWith(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (membership.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              membership,
                              style: robotoMedium.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // معلومات موثوقة من الهيئة العامة للعقار
          if (falLicense.isNotEmpty ||
              adLicense.isNotEmpty ||
              issueDate.isNotEmpty ||
              expiryDate.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Colors.green,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'verified_info'.tr,
                        style: robotoBold.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (falLicense.isNotEmpty)
                    _VerifiedRow(
                      label: 'fal_license_number'.tr,
                      value: falLicense,
                    ),
                  if (adLicense.isNotEmpty)
                    _VerifiedRow(
                      label: 'ad_license_number'.tr,
                      value: adLicense,
                    ),
                  if (issueDate.isNotEmpty)
                    _VerifiedRow(
                      label: 'creation_date'.tr,
                      value: issueDate,
                    ),
                  if (expiryDate.isNotEmpty)
                    _VerifiedRow(label: 'end_date'.tr, value: expiryDate),
                ],
              ),
            ),

          // رمز QR لرابط الإعلان على منصة الهيئة العامة للعقار
          if (qrUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _QrBlock(url: qrUrl),
            ),
        ],
      ),
    );
  }
}

class _VerifiedRow extends StatelessWidget {
  final String label;
  final String value;

  const _VerifiedRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 14,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: robotoRegular.copyWith(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Text(value, style: robotoBold.copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _QrBlock extends StatelessWidget {
  final String url;

  const _QrBlock({required this.url});

  Future<void> _open() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            'scan_ad_license_qr'.tr,
            textAlign: TextAlign.center,
            style: robotoMedium.copyWith(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _open,
            child: QrImageView(data: url, size: 120, backgroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}
