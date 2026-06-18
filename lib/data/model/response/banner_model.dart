import 'package:abaad_flutter/data/model/response/basic_campaign_model.dart';
import 'package:abaad_flutter/data/model/response/service_provider.dart';

class BannerModel {
  List<BasicCampaignModel>? campaigns;
  List<Banner>? banners;

  BannerModel({this.campaigns, this.banners});

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      campaigns: json['campaigns'] != null
          ? (json['campaigns'] as List)
          .map((v) => BasicCampaignModel.fromJson(v))
          .toList()
          : null,
      banners: json['banners'] != null
          ? (json['banners'] as List)
          .map((v) => Banner.fromJson(v))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaigns': campaigns?.map((v) => v.toJson()).toList(),
      'banners': banners?.map((v) => v.toJson()).toList(),
    };
  }
}

class Banner {
  int id;
  String title;
  String type;
  String image;
  ServiceProvider? restaurant;

  Banner({
    required this.id,
    required this.title,
    required this.type,
    required this.image,
    this.restaurant,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      image: json['image'] ?? '',
      restaurant: json['providers'] != null
          ? ServiceProvider.fromJson(json['providers'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'image': image,
      'providers': restaurant?.toJson(),
    };
  }
}