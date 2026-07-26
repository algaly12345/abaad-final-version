class ReferralLinkModel {
  String referralCode = "";
  String referralLink = "";
  String shareText = "";

  ReferralLinkModel({required this.referralCode, required this.referralLink, required this.shareText});

  ReferralLinkModel.fromJson(Map<String, dynamic> json) {
    referralCode = json['referral_code'] ?? "";
    referralLink = json['referral_link'] ?? "";
    shareText = json['share_text'] ?? "";
  }
}

class ReferralSummaryModel {
  int referredCount = 0;
  double pendingTotal = 0;
  double approvedTotal = 0;
  double availableTotal = 0;
  double withdrawnTotal = 0;
  double availableBalance = 0;

  ReferralSummaryModel({
    required this.referredCount,
    required this.pendingTotal,
    required this.approvedTotal,
    required this.availableTotal,
    required this.withdrawnTotal,
    required this.availableBalance,
  });

  ReferralSummaryModel.fromJson(Map<String, dynamic> json) {
    referredCount = json['referred_count'] ?? 0;
    pendingTotal = double.tryParse(json['pending_total'].toString()) ?? 0;
    approvedTotal = double.tryParse(json['approved_total'].toString()) ?? 0;
    availableTotal = double.tryParse(json['available_total'].toString()) ?? 0;
    withdrawnTotal = double.tryParse(json['withdrawn_total'].toString()) ?? 0;
    availableBalance = double.tryParse(json['available_balance'].toString()) ?? 0;
  }
}

class ReferralItemModel {
  String? referredName;
  String? referredPhone;
  String? packageName;
  double? transactionAmount;
  double? commissionAmount;
  String? commissionStatus;
  String referralStatus = "";
  DateTime? availableAt;
  DateTime? createdAt;

  ReferralItemModel({
    this.referredName,
    this.referredPhone,
    this.packageName,
    this.transactionAmount,
    this.commissionAmount,
    this.commissionStatus,
    required this.referralStatus,
    this.availableAt,
    this.createdAt,
  });

  ReferralItemModel.fromJson(Map<String, dynamic> json) {
    referredName = json['referred_name'];
    referredPhone = json['referred_phone'];
    packageName = json['package_name'];
    transactionAmount = json['transaction_amount'] != null
        ? double.tryParse(json['transaction_amount'].toString())
        : null;
    commissionAmount = json['commission_amount'] != null
        ? double.tryParse(json['commission_amount'].toString())
        : null;
    commissionStatus = json['commission_status'];
    referralStatus = json['referral_status'] ?? "";
    availableAt = json['available_at'] != null ? DateTime.tryParse(json['available_at']) : null;
    createdAt = json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null;
  }
}

class WithdrawalRequestModel {
  int? id;
  double amount = 0;
  String status = "";
  DateTime? requestedAt;
  DateTime? processedAt;

  WithdrawalRequestModel({this.id, required this.amount, required this.status, this.requestedAt, this.processedAt});

  WithdrawalRequestModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = double.tryParse(json['amount'].toString()) ?? 0;
    status = json['status'] ?? "";
    requestedAt = json['requested_at'] != null ? DateTime.tryParse(json['requested_at']) : null;
    processedAt = json['processed_at'] != null ? DateTime.tryParse(json['processed_at']) : null;
  }
}
