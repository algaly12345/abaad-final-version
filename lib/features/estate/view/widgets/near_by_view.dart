import 'dart:async';
import 'dart:convert';
import 'dart:typed_data' show ByteData;
import 'dart:ui' as ui;

import 'package:abaad_flutter/shared/data/models/estate_model.dart';
import 'package:abaad_flutter/shared/data/models/nearby_places_model.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:abaad_flutter/shared/utils/images.dart';
import 'package:abaad_flutter/shared/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import '../../../../controller/splash_controller.dart';

class NearByView extends StatefulWidget {
  final Estate esate;
  const NearByView({super.key, required this.esate});

  @override
  State<NearByView> createState() => _NearByViewState();
}

class _NearByViewState extends State<NearByView> {
  final Completer<GoogleMapController> _controller = Completer();
  final List<Marker> _markers = [];

  NearbyPlacesResponse? nearbyPlacesResponse;

  double currentLat = 0.0;
  double currentLng = 0.0;
  String type = 'restaurant';

  // 🔥 غير هذا الرقم للتحكم بالحجم
  final int markerSize = 60;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor hospitalIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor restIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor mosqueIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor schoolIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor pharmacyIcon = BitmapDescriptor.defaultMarker;

  List<RadioModel> sampleData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    currentLat = double.parse(widget.esate.latitude ?? "0");
    currentLng = double.parse(widget.esate.longitude ?? "0");

    initFilters();
    setCustomMarkerIcons();
    getNearbyPlaces(type);
  }

  void initFilters() {
    sampleData = [
      RadioModel(true, 'restaurant'.tr, Images.restaurant),
      RadioModel(false, 'mosque'.tr, Images.mosque),
      RadioModel(false, 'hospital'.tr, Images.hosptial),
      RadioModel(false, 'schools'.tr, Images.hosptial),
      RadioModel(false, 'pharmacies'.tr, Images.heart),
    ];
  }

  // ✅ تصغير الأيقونة
  Future<BitmapDescriptor> getResizedMarker(String path) async {
    final ByteData data = await DefaultAssetBundle.of(context).load(path);

    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: markerSize,
    );

    final frame = await codec.getNextFrame();
    final byteData =
    await frame.image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<void> setCustomMarkerIcons() async {
    sourceIcon = await getResizedMarker(Images.near);
    restIcon = await getResizedMarker(Images.mark_restaurant);
    hospitalIcon = await getResizedMarker(Images.mark_hosiptal);
    mosqueIcon = await getResizedMarker(Images.mark_mosque);
    schoolIcon = await getResizedMarker(Images.mark_school);
    pharmacyIcon = await getResizedMarker(Images.mark_pharmcy);

    setState(() {});
  }

  Future<void> getNearbyPlaces(String type) async {
    setState(() => isLoading = true);

    _markers.clear();

    // Marker العقار
    _markers.add(
      Marker(
        markerId: const MarkerId('estate'),
        icon: sourceIcon,
        position: LatLng(currentLat, currentLng),
      ),
    );

    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$currentLat,$currentLng&radius=1500&type=$type&key=${Get.find<SplashController>().configModel?.googleMapKey ?? ""}');

    final response = await http.post(url);

    nearbyPlacesResponse =
        NearbyPlacesResponse.fromJson(jsonDecode(response.body));

    if (nearbyPlacesResponse?.results != null) {
      for (int i = 0; i < nearbyPlacesResponse!.results!.length; i++) {
        final result = nearbyPlacesResponse!.results![i];

        _markers.add(
          Marker(
            markerId: MarkerId(i.toString()),
            position: LatLng(
              result.geometry!.location!.lat,
              result.geometry!.location!.lng,
            ),
            icon: getMarkerIcon(),
            infoWindow: InfoWindow(title: result.name),
          ),
        );
      }
    }

    setState(() => isLoading = false);
  }

  BitmapDescriptor getMarkerIcon() {
    switch (type) {
      case 'restaurant':
        return restIcon;
      case 'mosque':
        return mosqueIcon;
      case 'hospital':
        return hospitalIcon;
      case 'school':
        return schoolIcon;
      case 'pharmacy':
        return pharmacyIcon;
      default:
        return sourceIcon;
    }
  }

  String getTypeFromSelection(String text) {
    if (text == 'restaurant'.tr) return 'restaurant';
    if (text == 'hospital'.tr) return 'hospital';
    if (text == 'mosque'.tr) return 'mosque';
    if (text == 'schools'.tr) return 'school';
    if (text == 'pharmacies'.tr) return 'pharmacy';
    return 'restaurant';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'neighboring_facilities'.tr),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final controller = await _controller.future;
          controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: LatLng(currentLat, currentLng),
                zoom: 14.5,
              ),
            ),
          );
        },
        child: const Icon(Icons.my_location),
      ),
      body: Stack(
        children: [
      GoogleMap(
      initialCameraPosition: CameraPosition(
      zoom: 14.5,
        target: LatLng(currentLat, currentLng),
      ),
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false, // 🔥 أضف هذا
      compassEnabled: false,
      markers: Set<Marker>.of(_markers),
      onMapCreated: (controller) {
        _controller.complete(controller);
      },

          ),

          if (isLoading)
            const Center(child: CircularProgressIndicator()),

          Positioned(
            bottom: 60,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: () {
                        setState(() {
                          for (var element in sampleData) {
                            element.isSelected = false;
                          }
                          sampleData[index].isSelected = true;
                        });

                        type =
                            getTypeFromSelection(sampleData[index].buttonText);
                        getNearbyPlaces(type);
                      },
                      child: RadioItem(sampleData[index]),
                    );
                  },
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 10),
                  itemCount: sampleData.length,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RadioModel {
  bool isSelected;
  final String buttonText;
  final String iconPath;

  RadioModel(this.isSelected, this.buttonText, this.iconPath);
}

class RadioItem extends StatelessWidget {
  final RadioModel item;
  const RadioItem(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: item.isSelected
            ? Theme.of(context).primaryColor
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Image.asset(
            item.iconPath,
            height: 20,
            width: 20,
            color: item.isSelected ? Colors.white : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            item.buttonText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color:
              item.isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}