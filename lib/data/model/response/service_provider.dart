class ServiceProvider {
  int id = 0;
  String name = "";
  String phone = "";
  String email = "";
  String identityNumber = "";
  String identityType = "";
  int serviceTypeId =0;
  String image = "";
  String password = "";
  String address = "";
  int zoneId = 0;
  String job = "";
  String authToken = "";
  String fcmToken = "";
  String status = "";
  String active = "";
  String createdAt = "";
  String updatedAt = "";

  ServiceProvider({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.identityNumber,
    required this.identityType,
    required this.serviceTypeId,
    required this.image,
    required this.password,
    required this.address,
    required this.zoneId,
    required this.job,
    required this.authToken,
    required this.fcmToken,
    required this.status,
    required this.active,
    required this.createdAt,
    required this.updatedAt
  });

  ServiceProvider.fromJson(Map<String, dynamic> json) {
  id = json['id'];
  name = json['name'];
  phone = json['phone'];
  email = json['email'];
  identityNumber = json['identity_number'];
  identityType = json['identity_type'];
  serviceTypeId = json['service_type_id'];
  image = json['image'];
  password = json['password'];
  address = json['address'];
  zoneId = json['zone_id'];
  job = json['job'];
  authToken = json['auth_token'];
  fcmToken = json['fcm_token'];
  status = json['status'];
  active = json['active'];
  createdAt = json['created_at'];
  updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = id;
  data['name'] = name;
  data['phone'] = phone;
  data['email'] = email;
  data['identity_number'] = identityNumber;
  data['identity_type'] = identityType;
  data['service_type_id'] = serviceTypeId;
  data['image'] = image;
  data['password'] = password;
  data['address'] = address;
  data['zone_id'] = zoneId;
  data['job'] = job;
  data['auth_token'] = authToken;
  data['fcm_token'] = fcmToken;
  data['status'] = status;
  data['active'] = active;
  data['created_at'] = createdAt;
  data['updated_at'] = updatedAt;
  return data;
  }
}