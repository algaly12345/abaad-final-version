class ResponseModel {
  final bool _isSuccess;
  final String _message;
  final bool? _isPhoneVerified;
  final String? _token;

  // Existing call sites across the app construct this with just
  // ResponseModel(isSuccess, message) — that keeps working unchanged.
  // The two new fields are optional/named so nothing else breaks.
  ResponseModel(
    this._isSuccess,
    this._message, {
    bool? isPhoneVerified,
    String? token,
  }) : _isPhoneVerified = isPhoneVerified,
       _token = token;

  String get message => _message;
  bool get isSuccess => _isSuccess;

  /// True when the user does NOT need to go through the OTP screen
  /// (either already verified, or verification is disabled in business
  /// settings). Null when not applicable (most other ResponseModel uses).
  bool? get isPhoneVerified => _isPhoneVerified;

  /// The raw auth token returned by login()/registration(), when relevant.
  String? get token => _token;
}
