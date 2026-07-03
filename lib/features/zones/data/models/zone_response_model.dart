class ZoneResponseModel {
  final bool _isSuccess;
  final List<int>? _zoneIds;
  final String _message;
  final List<ZoneData>? _zoneData;
  ZoneResponseModel( this._isSuccess, this._message, this._zoneIds, this._zoneData);

  String get message => _message;
  List<int>? get zoneIds => _zoneIds;
  bool get isSuccess => _isSuccess;
  List<ZoneData>? get zoneData => _zoneData;
}

class ZoneData {
  int? id = 0;
  int? status = 0;
  double? minimumShippingCharge = 0;
  double? perKmShippingCharge = 0;

  ZoneData({
    required this.id,
    required this.status,
    required this.minimumShippingCharge,
    required this.perKmShippingCharge
  });

  ZoneData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    status = json['status'];
    minimumShippingCharge = json['minimum_shipping_charge']?.toDouble();
    perKmShippingCharge = json['per_km_shipping_charge']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['status'] = status;
    data['minimum_shipping_charge'] = minimumShippingCharge;
    data['per_km_shipping_charge'] = perKmShippingCharge;
    return data;
  }
}

