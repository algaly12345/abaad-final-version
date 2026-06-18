class LandModel {
  bool exceededTransferLimit = false;
  List<Features>? features;
  List<Fields>? fields;
  String geometryType = "";
  SpatialReference? spatialReference;
  String objectIdFieldName = "";
  bool hasZ = false;
  bool hasM = false;

  LandModel ({
    required this.exceededTransferLimit,
    required this.features,
    required this.fields,
    required this.geometryType,
    required this.spatialReference,
    required this.objectIdFieldName,
    required this.hasZ,
    required this.hasM
  });

  LandModel .fromJson(Map<String, dynamic> json) {
    exceededTransferLimit = json['exceededTransferLimit'];
    if (json['features'] != null) {
      features = <Features>[];
      json['features'].forEach((v) {
        features?.add(Features.fromJson(v));
      });
    }
    if (json['fields'] != null) {
      fields = <Fields>[];
      json['fields'].forEach((v) {
        fields?.add(Fields.fromJson(v));
      });
    }
    geometryType = json['geometryType'];
    spatialReference = json['spatialReference'] != null
        ? SpatialReference.fromJson(json['spatialReference'])
        : null;
    objectIdFieldName = json['objectIdFieldName'];
    hasZ = json['hasZ'];
    hasM = json['hasM'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['exceededTransferLimit'] = exceededTransferLimit;
    data['features'] = features?.map((v) => v.toJson()).toList();
      data['fields'] = fields?.map((v) => v.toJson()).toList();
      data['geometryType'] = geometryType;
    data['spatialReference'] = spatialReference?.toJson();
      data['objectIdFieldName'] = objectIdFieldName;
    data['hasZ'] = hasZ;
    data['hasM'] = hasM;
    return data;
  }
}

class Features {
  Attributes? attributes;
  Geometry? geometry;

  Features({required this.attributes, required this.geometry});

  Features.fromJson(Map<String, dynamic> json) {
    attributes = json['attributes'] != null
        ? Attributes.fromJson(json['attributes'])
        : null;
    geometry = json['geometry'] != null
        ? Geometry.fromJson(json['geometry'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['attributes'] = attributes?.toJson();
      data['geometry'] = geometry?.toJson();
      return data;
  }
}

class Attributes {
  String systemId = "";

  Attributes({required this.systemId});

  Attributes.fromJson(Map<String, dynamic> json) {
    systemId = json['system_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['system_id'] = systemId;
    return data;
  }
}

class Geometry {
  double x = 0;
  double y = 0;

  Geometry({required this.x, required this.y});

  Geometry.fromJson(Map<String, dynamic> json) {
    x = json['x'];
    y = json['y'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['x'] = x;
    data['y'] = y;
    return data;
  }
}

class Fields {
  String name = "";
  String type = "";
  String alias = "";
  int length = 0;
  Null defaultValue;
  String modelName = "";
  bool visible = false;

  Fields({
    required this.name,
    required this.type,
    required this.alias,
    required this.length,
    required this.defaultValue,
    required this.modelName,
    required this.visible
  });

  Fields.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    alias = json['alias'];
    length = json['length'];
    defaultValue = json['defaultValue'];
    modelName = json['modelName'];
    visible = json['visible'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['type'] = type;
    data['alias'] = alias;
    data['length'] = length;
    data['defaultValue'] = defaultValue;
    data['modelName'] = modelName;
    data['visible'] = visible;
    return data;
  }
}

class SpatialReference {
  int wkid = 0;
  int latestWkid = 0;

  SpatialReference({required this.wkid, required this.latestWkid});

  SpatialReference.fromJson(Map<String, dynamic> json) {
    wkid = json['wkid'];
    latestWkid = json['latestWkid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['wkid'] = wkid;
    data['latestWkid'] = latestWkid;
    return data;
  }
}