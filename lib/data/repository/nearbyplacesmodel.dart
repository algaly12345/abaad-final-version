class NearbyPlacesResponse {
  String? nextPageToken;
  List<Results>? results = [];
  String status = "";

  NearbyPlacesResponse({this.nextPageToken, this.results, required this.status});

  NearbyPlacesResponse.fromJson(Map<String, dynamic> json) {
    nextPageToken = json['next_page_token'];
    if (json['results'] != null) {
      results = <Results>[];
      json['results'].forEach((v) {
        results!.add(Results.fromJson(v));
      });
    }
    status = json['status'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['next_page_token'] = nextPageToken;
    data['results'] = results?.map((v) => v.toJson()).toList();
    data['status'] = status;
    return data;
  }
}

class Results {
  Geometry? geometry;
  String icon = "";
  String iconBackgroundColor = "";
  String iconMaskBaseUri = "";
  String name = "";
  List<Photos> photos = [];
  String placeId = "";
  String reference = "";
  String scope = "";
  List<String> types = [];
  String vicinity = "";
  String businessStatus = "";
  OpeningHours? openingHours;
  dynamic rating;
  int? userRatingsTotal;
  PlusCode? plusCode;
  int? priceLevel;

  Results({
    this.geometry,
    this.icon = "",
    this.iconBackgroundColor = "",
    this.iconMaskBaseUri = "",
    this.name = "",
    this.photos = const [],
    this.placeId = "",
    this.reference = "",
    this.scope = "",
    this.types = const [],
    this.vicinity = "",
    this.businessStatus = "",
    this.openingHours,
    this.rating,
    this.userRatingsTotal,
    this.plusCode,
    this.priceLevel,
  });

  Results.fromJson(Map<String, dynamic> json) {
    // ✅ كل حقل String يستخدم ?? '' لتجنب null
    geometry = json['geometry'] != null ? Geometry.fromJson(json['geometry']) : null;
    icon = json['icon'] ?? '';
    iconBackgroundColor = json['icon_background_color'] ?? '';
    iconMaskBaseUri = json['icon_mask_base_uri'] ?? '';
    name = json['name'] ?? '';

    if (json['photos'] != null) {
      photos = <Photos>[];
      json['photos'].forEach((v) {
        photos.add(Photos.fromJson(v));
      });
    }

    placeId = json['place_id'] ?? '';
    reference = json['reference'] ?? '';
    scope = json['scope'] ?? '';

    // ✅ cast مع null-check
    types = json['types'] != null ? List<String>.from(json['types']) : [];

    vicinity = json['vicinity'] ?? '';
    businessStatus = json['business_status'] ?? '';

    openingHours = json['opening_hours'] != null
        ? OpeningHours.fromJson(json['opening_hours'])
        : null;

    rating = json['rating'];
    userRatingsTotal = json['user_ratings_total'];

    plusCode = json['plus_code'] != null
        ? PlusCode.fromJson(json['plus_code'])
        : null;

    priceLevel = json['price_level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['geometry'] = geometry?.toJson();
    data['icon'] = icon;
    data['icon_background_color'] = iconBackgroundColor;
    data['icon_mask_base_uri'] = iconMaskBaseUri;
    data['name'] = name;
    data['photos'] = photos.map((v) => v.toJson()).toList();
    data['place_id'] = placeId;
    data['reference'] = reference;
    data['scope'] = scope;
    data['types'] = types;
    data['vicinity'] = vicinity;
    data['business_status'] = businessStatus;
    data['opening_hours'] = openingHours?.toJson();
    data['rating'] = rating;
    data['user_ratings_total'] = userRatingsTotal;
    data['plus_code'] = plusCode?.toJson();
    data['price_level'] = priceLevel;
    return data;
  }
}

class Geometry {
  Location? location;
  Viewport? viewport;

  Geometry({this.location, this.viewport});

  Geometry.fromJson(Map<String, dynamic> json) {
    location = json['location'] != null ? Location.fromJson(json['location']) : null;
    viewport = json['viewport'] != null ? Viewport.fromJson(json['viewport']) : null;
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
    // ✅ toDouble() لتجنب مشكلة int/double
    lat = (json['lat'] ?? 0).toDouble();
    lng = (json['lng'] ?? 0).toDouble();
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

  Viewport({this.northeast, this.southwest});

  Viewport.fromJson(Map<String, dynamic> json) {
    northeast = json['northeast'] != null ? Location.fromJson(json['northeast']) : null;
    southwest = json['southwest'] != null ? Location.fromJson(json['southwest']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['northeast'] = northeast?.toJson();
    data['southwest'] = southwest?.toJson();
    return data;
  }
}

class Photos {
  int height = 0;
  List<String> htmlAttributions = [];
  String photoReference = "";
  int width = 0;

  Photos({required this.height, required this.htmlAttributions,
    required this.photoReference, required this.width});

  Photos.fromJson(Map<String, dynamic> json) {
    height = json['height'] ?? 0;
    htmlAttributions = json['html_attributions'] != null
        ? List<String>.from(json['html_attributions'])
        : [];
    photoReference = json['photo_reference'] ?? '';
    width = json['width'] ?? 0;
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

class OpeningHours {
  bool openNow = false;

  OpeningHours({required this.openNow});

  OpeningHours.fromJson(Map<String, dynamic> json) {
    openNow = json['open_now'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['open_now'] = openNow;
    return data;
  }
}

class PlusCode {
  String compoundCode = "";
  String globalCode = "";

  PlusCode({required this.compoundCode, required this.globalCode});

  PlusCode.fromJson(Map<String, dynamic> json) {
    compoundCode = json['compound_code'] ?? '';
    globalCode = json['global_code'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['compound_code'] = compoundCode;
    data['global_code'] = globalCode;
    return data;
  }
}