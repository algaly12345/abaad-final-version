import 'dart:collection';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/location_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/screen/map/widget/location_search_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationView extends StatefulWidget {
  final bool? fromView;
  final GoogleMapController? mapController;
  const SelectLocationView({
    super.key,
    this.fromView,
    this.mapController
  });

  @override
  State<SelectLocationView> createState() => _SelectLocationViewState();
}

class _SelectLocationViewState extends State<SelectLocationView> {

  CameraPosition? _cameraPosition;
  final Set<Polygon> _polygons = HashSet<Polygon>();
  GoogleMapController? _mapController;
  GoogleMapController? _screenMapController;
  MapType _currentMapType = MapType.normal;
  LatLng? _currentPosition;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Get.find<AuthController>().getZoneList();
  }

  Future<void> getAddressFromLatLang(double lat, double log) async {
    //print("omeromer");
    List<Placemark> placemark =
    await placemarkFromCoordinates(lat, log);
    Placemark place = placemark[0];
    String  address= 'Address : ${place.locality},${place.country}';

    showCustomSnackBar("message${place.subLocality}");
    //print("adress-------------------------------------${place.locality},${place.country}");
  }
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (authController) {
      List<int> zoneIndexList = [];
      if(authController.zoneList != null && authController.zoneIds != null) {
        for(int index=0; index < (authController.zoneList?.length ?? 140); index++) {
          if( ( authController.zoneIds?.contains( (authController.zoneList?[index].id ?? 0) ) ?? false ) ) {
            zoneIndexList.add(index);
          }
        }
      }

      return GetBuilder<UserController>(builder: (userController) {
         return Card(
          elevation: 0,
          child: SizedBox(width: Dimensions.WEB_MAX_WIDTH, child: Padding(
            padding: EdgeInsets.all((widget.fromView ?? false) ? 0 : Dimensions.PADDING_SIZE_SMALL),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text(
                'zone'.tr,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),

              InkWell(
                onTap: () async {
                  var p = await Get.dialog(LocationSearchDialog(mapController: (widget.fromView ?? false) ? _mapController! : _screenMapController!));
                  Position position = p;
                  _cameraPosition = CameraPosition(target: LatLng(position.latitude, position.longitude), zoom: 16);
                  // if(!widget.fromView) {
                  widget.mapController?.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition!));


                  // }
                                },
                child: Container(
                  height: 50,
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL)),
                  child: Row(children: [
                    Icon(Icons.location_on, size: 25, color: Theme.of(context).primaryColor),
                    SizedBox(width: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                    Expanded(
                      child: GetBuilder<LocationController>(builder: (locationController) {
                        return Text(
                          locationController.pickAddress.isEmpty ? 'search'.tr : locationController.pickAddress,
                          style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge), maxLines: 1, overflow: TextOverflow.ellipsis,
                        );
                      }),
                    ),
                    SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                    Icon(Icons.search, size: 25, color: Theme.of(context).textTheme.bodyLarge?.color),
                  ]),
                ),
              ),
              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

              Container(
                height: (widget.fromView ?? false) ? 200 : (context.height * 0.55),
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  border: Border.all(width: 2, color: Theme.of(context).primaryColor),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
                  child: Stack(clipBehavior: Clip.none, children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(
                          double.parse(  userController.latitude.toString()?? '0'),
                          double.parse(  userController.longitude.toString() ?? '0'),
                        ), zoom: 16,
                      ),
                      minMaxZoomPreference: MinMaxZoomPreference(0, 30),
                      zoomControlsEnabled: true,
                      compassEnabled: false,
                      indoorViewEnabled: true,
                      mapToolbarEnabled: false,
                      myLocationEnabled: false,
                      zoomGesturesEnabled: true,


                      polygons: _polygons,
                      mapType: MapType.satellite,

                      onCameraIdle: () {

                        if(!(widget.fromView ?? false)) {
                          //showCustomSnackBar("${_cameraPosition.target}");

                          widget.mapController?.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition!));

                        }
                      },
                      onCameraMove: ((position) {
                        _cameraPosition = position;
                        setState(() {
                          authController.setLocation((_cameraPosition?.target ?? LatLng(0, 0)));
                        });

                        //     showCustomSnackBar("lat${_cameraPosition.target.latitude}");
                      }),
                      onMapCreated: (GoogleMapController controller) {

                        if((widget.fromView ?? false)) {
                          _mapController = controller;


                        }else {
                          _screenMapController = controller;

                        }

                      },
                    ),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: SizedBox(
                        height: 200,
                        child: Column(
                          children: [
                            Container(
                              height: 60,
                              width: 60,
                              padding: const EdgeInsets.all(10.0),
                              child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                heroTag: 'recenterr',
                                onPressed:_onMapTypeButtonPressed,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: const BorderSide(color: Color(0xFFECEDF1))),
                                child:  Icon(
                                  Icons.layers_outlined,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(child: Image.asset(Images.pick_marker, height: 50, width: 50)),
                    (widget.fromView ?? false) ? Positioned(
                      top: 10, right: 0,
                      child: InkWell(
                        onTap: () {

                          Get.to(SelectLocationView(fromView: false, mapController: _mapController));
                        },
                        child: Container(
                          width: 30, height: 30,
                          margin: EdgeInsets.only(right: Dimensions.PADDING_SIZE_LARGE),
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL), color: Colors.white),
                          child: Icon(Icons.fullscreen, color: Theme.of(context).primaryColor, size: 20),
                        ),
                      ),
                    ) : SizedBox(),
                  ]),
                ),
              ) ,
              SizedBox(height: (authController.zoneList?.length ?? 0) > 0 ? Dimensions.PADDING_SIZE_SMALL : 0),

              SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

              // authController.zoneIds != null ? Container(
              //   padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_SMALL),
              //   decoration: BoxDecoration(
              //     color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.RADIUS_SMALL),
              //     boxShadow: [BoxShadow(color: Colors.grey[Get.isDarkMode ? 800 : 200], spreadRadius: 2, blurRadius: 5, offset: Offset(0, 5))],
              //   ),
              //   child: DropdownButton<int>(
              //     value: authController.selectedZoneIndex,
              //     items: _zoneIndexList.map((int value) {
              //       return DropdownMenuItem<int>(
              //         value: value,
              //         child: Text(authController.zoneList[value].name),
              //       );
              //     }).toList(),
              //     onChanged: (value) {
              //       _polygons = HashSet();
              //       _polygons.add(Polygon(
              //         polygonId: PolygonId("0"),
              //         points: authController.zoneList[value].coordinates.coordinates,
              //         fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
              //         strokeColor: Theme.of(context).primaryColor,
              //         strokeWidth: 1,
              //       ));
              //       Get.find<LocationController>().zoomToFit(_mapController, authController.zoneList[value].coordinates.coordinates);
              //       authController.setZoneIndex(value);
              //     },
              //     isExpanded: true,
              //     underline: SizedBox(),
              //   ),
              // ) : Center(child: Text('service_not_available_in_this_area'.tr)),
              // SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

              !(widget.fromView ?? false) ? CustomButton(
                buttonText: 'set_location'.tr,
                onPressed: () {
                  getAddressFromLatLang((authController.estateLocation?.latitude ?? 0), (authController.estateLocation?.longitude ?? 0));
                 // widget.mapController.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
                  Get.back();
                },
              ) : SizedBox()

            ]),
          )),
        );
      });
  });
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }



}
