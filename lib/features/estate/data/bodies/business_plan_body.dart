class BusinessPlanBody {
  String? businessPlan;
  String? estateId;
  String? packageId;
  String? payment;

  BusinessPlanBody({required this.businessPlan, required this.estateId, required this.packageId, required this.payment});

  BusinessPlanBody.fromJson(Map<String, dynamic> json) {
    businessPlan = json['business_plan'];
    estateId = json['restaurant_id'];
    packageId = json['package_id'];
    payment = json['payment'];
  }

  Map<String, String> toJson() {
    final Map<String, String> data = <String, String>{};
    data['business_plan'] = businessPlan!;
    data['restaurant_id'] = estateId!;
    data['package_id'] = packageId!;
    data['payment'] = payment!;
    return data;
  }
}
