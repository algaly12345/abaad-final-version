class PlaceDetailsModel {
  Result? result;
  String status = "";

  PlaceDetailsModel({required this.result, required this.status});

  PlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    result =
    json['result'] != null ? Result.fromJson(json['result']) : null;
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['result'] = result?.toJson();
      data['status'] = status;
    return data;
  }
}

class Result {
  List<AddressComponents>? addressComponents;
  String adrAddress = "";
  String formattedAddress = "";
  Geometry? geometry;
  String icon = "";
  String iconBackgroundColor = "";
  String iconMaskBaseUri = "";
  String name = "";
  List<Photos>? photos;
  String placeId = "";
  String reference = "";
  List<String>? types;
  String url = "";
  int utcOffset = 0;
  String website = "";

  Result({
    required this.addressComponents,
    required this.adrAddress,
    required this.formattedAddress,
    required this.geometry,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconMaskBaseUri,
    required this.name,
    required this.photos,
    required this.placeId,
    required this.reference,
    required this.types,
    required this.url,
    required this.utcOffset,
    required this.website
  });

  Result.fromJson(Map<String, dynamic> json) {
    if (json['address_components'] != null) {
      addressComponents = [];
      json['address_components'].forEach((v) {
        addressComponents?.add(AddressComponents.fromJson(v));
      });
    }
    adrAddress = json['adr_address'];
    formattedAddress = json['formatted_address'];
    geometry = json['geometry'] != null
        ? Geometry.fromJson(json['geometry'])
        : null;
    icon = json['icon'];
    iconBackgroundColor = json['icon_background_color'];
    iconMaskBaseUri = json['icon_mask_base_uri'];
    name = json['name'];
    if (json['photos'] != null) {
      photos = [];
      json['photos'].forEach((v) {
        photos?.add(Photos.fromJson(v));
      });
    }
    placeId = json['place_id'];
    reference = json['reference'];
    types = json['types'].cast<String>();
    url = json['url'];
    utcOffset = json['utc_offset'];
    website = json['website'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address_components'] =
        addressComponents?.map((v) => v.toJson()).toList();
      data['adr_address'] = adrAddress;
    data['formatted_address'] = formattedAddress;
    data['geometry'] = geometry?.toJson();
      data['icon'] = icon;
    data['icon_background_color'] = iconBackgroundColor;
    data['icon_mask_base_uri'] = iconMaskBaseUri;
    data['name'] = name;
    data['photos'] = photos?.map((v) => v.toJson()).toList();
      data['place_id'] = placeId;
    data['reference'] = reference;
    data['types'] = types;
    data['url'] = url;
    data['utc_offset'] = utcOffset;
    data['website'] = website;
    return data;
  }
}

class AddressComponents {
  String longName = "";
  String shortName = "";
  List<String>? types;

  AddressComponents({required this.longName, required this.shortName, required this.types});

  AddressComponents.fromJson(Map<String, dynamic> json) {
    longName = json['long_name'];
    shortName = json['short_name'];
    types = json['types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['long_name'] = longName;
    data['short_name'] = shortName;
    data['types'] = types;
    return data;
  }
}

class Geometry {
  Location? location;
  Viewport? viewport;

  Geometry({required this.location, required this.viewport});

  Geometry.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null
        ? Location.fromJson(json['location'])
        : null;
    viewport = json['viewport'] != null
        ? Viewport.fromJson(json['viewport'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['location'] = location?.toJson();
      data['viewport'] = viewport?.toJson();
      return data;
  }
}

class Location {
  double lat = 0;
  double lng = 0;

  Location({required this.lat, required this.lng});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

class Viewport {
  Location? northeast;
  Location? southwest;

  Viewport({required this.northeast, required this.southwest});

  Viewport.fromJson(Map<String, dynamic> json) {
    northeast = json['northeast'] != null
        ? Location.fromJson(json['northeast'])
        : null;
    southwest = json['southwest'] != null
        ? Location.fromJson(json['southwest'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['northeast'] = northeast?.toJson();
      data['southwest'] = southwest?.toJson();
      return data;
  }
}

class Photos {
  int height =  0;
  List<String>? htmlAttributions;
  String photoReference = "";
  int width = 0;

  Photos({required this.height, required this.htmlAttributions, required this.photoReference, required this.width});

  Photos.fromJson(Map<String, dynamic> json) {
    height = json['height'];
    htmlAttributions = json['html_attributions'].cast<String>();
    photoReference = json['photo_reference'];
    width = json['width'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['height'] = height;
    data['html_attributions'] = htmlAttributions;
    data['photo_reference'] = photoReference;
    data['width'] = width;
    return data;
  }
}
