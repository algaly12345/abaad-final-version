import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/features/referrals/data/models/referral_model.dart';
import 'package:abaad_flutter/features/referrals/data/repositories/referral_repo.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:get/get.dart';

class ReferralController extends GetxController implements GetxService {
  final ReferralRepo referralRepo;
  ReferralController({required this.referralRepo});

  ReferralLinkModel? _link;
  ReferralSummaryModel? _summary;
  List<ReferralItemModel>? _referrals;
  List<WithdrawalRequestModel>? _withdrawals;
  bool _isLoading = false;
  bool _isRequestingWithdrawal = false;

  ReferralLinkModel? get link => _link;
  ReferralSummaryModel? get summary => _summary;
  List<ReferralItemModel>? get referrals => _referrals;
  List<WithdrawalRequestModel>? get withdrawals => _withdrawals;
  bool get isLoading => _isLoading;
  bool get isRequestingWithdrawal => _isRequestingWithdrawal;

  Future<void> loadAll() async {
    _isLoading = true;
    update();

    await Future.wait([getMyLink(), getSummary(), getReferralList(), getWithdrawals()]);

    _isLoading = false;
    update();
  }

  Future<void> getMyLink() async {
    Response response = await referralRepo.getMyLink();
    if (response.statusCode == 200) {
      _link = ReferralLinkModel.fromJson(response.body);
      update();
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
  }

  Future<void> getSummary() async {
    Response response = await referralRepo.getSummary();
    if (response.statusCode == 200) {
      _summary = ReferralSummaryModel.fromJson(response.body);
      update();
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
  }

  Future<void> getReferralList() async {
    Response response = await referralRepo.getReferralList();
    if (response.statusCode == 200) {
      _referrals = (response.body['data'] as List).map((e) => ReferralItemModel.fromJson(e)).toList();
      update();
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
  }

  Future<void> getWithdrawals() async {
    Response response = await referralRepo.getWithdrawals();
    if (response.statusCode == 200) {
      _withdrawals = (response.body['data'] as List).map((e) => WithdrawalRequestModel.fromJson(e)).toList();
      update();
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
  }

  Future<bool> requestWithdrawal(double amount) async {
    _isRequestingWithdrawal = true;
    update();

    Response response = await referralRepo.requestWithdrawal(amount: amount);
    bool isSuccess = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      isSuccess = true;
      showCustomSnackBar('withdrawal_request_submitted'.tr, isError: false);
      await Future.wait([getSummary(), getWithdrawals()]);
    } else {
      final errors = response.body is Map ? response.body['errors'] : null;
      final message = (errors is List && errors.isNotEmpty) ? errors.first['message'] : null;
      showCustomSnackBar(message ?? 'something_went_wrong'.tr);
    }

    _isRequestingWithdrawal = false;
    update();
    return isSuccess;
  }
}
