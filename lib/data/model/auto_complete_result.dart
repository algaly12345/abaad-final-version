class AutoCompleteResult {
  String? description;
  List<MatchedSubstrings>? matchedSubstrings;
  String? placeId;
  String? reference;
  StructuredFormatting? structuredFormatting;
  List<Terms>? terms;
  List<String>? types;

  AutoCompleteResult(
      {required this.description,
      required this.matchedSubstrings,
      required this.placeId,
      required this.reference,
      required this.structuredFormatting,
      required this.terms,
      required this.types});

  AutoCompleteResult.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    if (json['matched_substrings'] != null) {
      matchedSubstrings = <MatchedSubstrings>[];
      json['matched_substrings'].forEach((v) {
        matchedSubstrings?.add(MatchedSubstrings.fromJson(v));
      });
    }
    placeId = json['place_id'];
    reference = json['reference'];
    structuredFormatting = json['structured_formatting'] != null
        ? StructuredFormatting.fromJson(json['structured_formatting'])
        : null;
    if (json['terms'] != null) {
      terms = <Terms>[];
      json['terms'].forEach((v) {
        terms?.add(Terms.fromJson(v));
      });
    }
    types = json['types'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['matched_substrings'] =
        matchedSubstrings?.map((v) => v.toJson()).toList();
      data['place_id'] = placeId;
    data['reference'] = reference;
    data['structured_formatting'] = structuredFormatting?.toJson();
      data['terms'] = terms?.map((v) => v.toJson()).toList();
      data['types'] = types;
    return data;
  }
}

class MatchedSubstrings {
  int? length;
  int? offset;

  MatchedSubstrings({required this.length, required this.offset});

  MatchedSubstrings.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['length'] = length;
    data['offset'] = offset;
    return data;
  }
}

class StructuredFormatting {
  String? mainText;
  List<MainTextMatchedSubstrings>? mainTextMatchedSubstrings;
  String? secondaryText;

  StructuredFormatting(
      {required this.mainText, required this.mainTextMatchedSubstrings, required this.secondaryText});

  StructuredFormatting.fromJson(Map<String, dynamic> json) {
    mainText = json['main_text'];
    if (json['main_text_matched_substrings'] != null) {
      mainTextMatchedSubstrings = <MainTextMatchedSubstrings>[];
      json['main_text_matched_substrings'].forEach((v) {
        mainTextMatchedSubstrings
            ?.add(MainTextMatchedSubstrings.fromJson(v));
      });
    }
    secondaryText = json['secondary_text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['main_text'] = mainText;
    data['main_text_matched_substrings'] =
        mainTextMatchedSubstrings?.map((v) => v.toJson()).toList();
      data['secondary_text'] = secondaryText;
    return data;
  }
}

class Terms {
  int? offset;
  String? value;

  Terms({required this.offset, required this.value});

  Terms.fromJson(Map<String, dynamic> json) {
    offset = json['offset'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['offset'] = offset;
    data['value'] = value;
    return data;
  }
}

class SecondaryTextMatchedSubstrings {
  int? length;
  int? offset;

  SecondaryTextMatchedSubstrings({required this.length, required this.offset});

  SecondaryTextMatchedSubstrings.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['length'] = length;
    data['offset'] = offset;
    return data;
  }
}

class MainTextMatchedSubstrings {
  int? length;
  int? offset;

  MainTextMatchedSubstrings({required this.length, required this.offset});

  MainTextMatchedSubstrings.fromJson(Map<String, dynamic> json) {
    length = json['length'];
    offset = json['offset'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['length'] = length;
    data['offset'] = offset;
    return data;
  }
}
