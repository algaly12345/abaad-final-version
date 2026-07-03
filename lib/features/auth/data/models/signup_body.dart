class SignUpBody {
  String? fName;
  String? phone;
  String? email;
  String? password;
  String? refCode;
  int? zone_id;
  int? city_id;
  String? membershipType;
  String? userType;
  String? unifiedNumber;

  SignUpBody({
    required this.fName,
    required this.phone,
    this.email = '',
    required this.password,
    this.refCode = '',
    required this.zone_id,
    required this.city_id,
    required this.membershipType,
    required this.unifiedNumber
  });

  SignUpBody.fromJson(Map<String, dynamic> json) {
    fName = json['name'];
    phone = json['phone'];
    email = json['email'];
    password = json['password'];
    refCode = json['ref_code'];
    zone_id = json['zone_id'];
    city_id = json['city_id'];
    membershipType = json['membership_type'];
    unifiedNumber=json['unified_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = fName;
    data['phone'] = phone;
    data['email'] = email;
    data['password'] = password;
    data['ref_code'] = refCode;
    data['zone_id'] = zone_id;
    data['city_id'] = refCode;
    data['membership_type'] = membershipType;
    data['unified_number']=unifiedNumber;
    return data;
  }
}
