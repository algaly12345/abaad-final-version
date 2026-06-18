
import 'dart:io';

import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/category_controller.dart';
import 'package:abaad_flutter/controller/estate_controller.dart';
import 'package:abaad_flutter/controller/location_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/data/model/body/estate_body.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_button.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/custom_snackbar.dart';
import 'package:abaad_flutter/view/base/data_view.dart';
import 'package:abaad_flutter/view/base/my_text_field.dart';
import 'package:abaad_flutter/view/screen/map/pick_map_screen.dart';
import 'package:abaad_flutter/view/screen/map/widget/permission_dialog.dart';
import 'package:abaad_flutter/view/screen/qr.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../base/custom_app_bar.dart';

class EditDialog extends StatefulWidget {
  Estate? estate;
  // Generate some dummy data


  EditDialog({Key? key, required this.estate}) : super(key: key);

  @override
  State<EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  late bool _isLoggedIn;
  late String like;
  int zone_id=0;

  List<String> selectedAdvantages = [];
 // List<String> alreadySelectedAdvantages = [];
  bool isLoading = false;

  int zone_value=0;
  var isSelected2 = [true, false];
  late LatLng _initialPosition;
  late CameraPosition _cameraPosition;
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _userTypeController = TextEditingController();
  final TextEditingController _authorizedController = TextEditingController();
  final TextEditingController _widthStreetController = TextEditingController();
  final TextEditingController _buildSpaceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _spaceController = TextEditingController();
  final TextEditingController _shortDescController = TextEditingController();
  final TextEditingController _longDescController = TextEditingController();
  final TextEditingController _documentNumberController  = TextEditingController();
  final TextEditingController _addNumberController = TextEditingController();



  final TextEditingController _northController = TextEditingController();
  final TextEditingController _westController = TextEditingController();
  final TextEditingController _eastController = TextEditingController();
  final TextEditingController _southController = TextEditingController();



  final FocusNode _northFocus = FocusNode();

  final FocusNode _westDesFocus = FocusNode();

  final FocusNode _eastFocus = FocusNode();

  final FocusNode _southFocus = FocusNode();


  final FocusNode _priceFocus = FocusNode();

  final FocusNode _shorDesFocus = FocusNode();

  final FocusNode _vatFocus = FocusNode();
  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _longDescFocus = FocusNode();
  final FocusNode _spaceFocus = FocusNode();
  final FocusNode _buildSpaceFocus = FocusNode();
  final FocusNode _documentNumberFocus = FocusNode();
  final FocusNode _minTimeFocus = FocusNode();
  late int _typeProperties ;
  late int category_id;


  late String district;
  late String city;



  static const _locale = 'en';
  String _formatNumber(String s) => NumberFormat.decimalPattern(_locale).format(double.parse(s));
  String get _currency => NumberFormat.compactSimpleCurrency(locale: _locale).currencySymbol;
  final List<String> _loungeList=[
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
  ];
  final List<String> _roomList = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
  ];
  final List<String> _bathroomsList = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
  ];
  final List<String> _kitchenList = [
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
  ];
  int _selectedRoomIndex = 0;
  int _selectedBathroomsIndex = 0;
  int _selectedLounge=0;
  int _selectedkitchen=0;
  int _djectivePresenter=0;



  late String _ageValue;

  bool isButtonEnabled = false;

  final TextEditingController _textEditingController = TextEditingController();
  _onSelected(int index) {
    setState(() => _selectedRoomIndex = index);
  }
  late String item;
  late List<String> images;
   late String initialValue;
  _onSelectedBathrooms(int index) {
    setState(() => _selectedBathroomsIndex = index);
  }


  int _selectionTypeEstate = 1;


  selectTypeEstate(int? timeSelected) {
    setState(() {
      _selectionTypeEstate = timeSelected!;
    });
  }

  _onSelectedlounge(int index) {
    setState(() => _selectedLounge = index);
  }

  _onSelectedkitchen(int index) {
    setState(() => _selectedkitchen = index);
  }

  int _selection = 0;



  final List<String> _interfaceist = [   "الواجهة الشمالية",
    "الواجهة الشرقية",
    "الواجهة الغربية",
    "الواجهة الجنوبية",];
  late int east, west,north,south=0;
  late String east_st, west_st,north_st,south_st;
  final List<String> _selectedInterfaceistItems = [];

  selectTime(int? timeSelected) {
    setState(() {
      _selection = timeSelected!;
    });
  }
  late String network_type;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();


    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Get.find<CategoryController>().getFacilitiesList(true);
    Get.find<UserController>().getEstateByUser(1, false,widget.estate!.userId ?? 0 );
    Get.find<CategoryController>().getAdvantages(true);

   // widget.estate.priceNegotiation=="غير قابل للتفاوض"?   isSelected2.first=false: isSelected2.first=false;




    Get.find<AuthController>().getZoneList();

    Get.find<LocationController>().getCategoryList();

    _initialPosition = LatLng(
      double.parse(widget.estate!.latitude ?? '0'),
      double.parse(widget.estate!.longitude ?? '0'),
    );




    // if(widget.estate.interface.length > 0){
    //   north_st=widget.estate.interface[0].name;
    //   // west_st=widget.estate.interface[1].name??'';
    // }


 
    // north_st=widget.estate.interface[0].name;
    // west_st=widget.estate.interface[1].name;

    // input.split('').forEach((ch) => //print(ch));

    //print("----------------------------categore${widget.estate.authorization_number}");
    // zone_id=widget.estate.zoneId;
   // widget.estate.priceNegotiation=="غير قابل للتفاوض"?   isSelected2.first=false: widget.estate.priceNegotiation=="قابل للتفاوض"? isSelected2.first=true:true;

    Get.find<UserController>().getUserInfoByID(widget.estate!.userId ?? 0);


    _firstNameController.text = widget.estate!.users?.name ?? '';



    _shortDescController.text = widget.estate!.shortDescription ?? '';
    _longDescController.text = widget.estate!.longDescription ?? '';

    _textEditingController.text =  widget.estate!.arPath?? '';





    // _websiteController.text = userController.userInfoModel.website ?? '';
    // _instagramController.text = userController.userInfoModel.instagram?? '';

    //_typeProperties==0?"for_rent".tr:"for_sell".tr;


  
  }










  @override
  Widget build(BuildContext context) {


    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    final currentLocale = Get.locale;
    bool isArabic = currentLocale?.languageCode == 'ar';
    return Scaffold(
      appBar:  CustomAppBar(title: 'update_estate'.tr),
      body: SingleChildScrollView(
        child: (widget.estate != null) ?
    GetBuilder<AuthController>(builder: (authController) {
      return
        GetBuilder<CategoryController>(
            builder: (categoryController) {

      return   Column(

                children: [
                  // EstateView(fromView: true,estate:widget.estate ) ,



          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [



    GetBuilder<EstateController>(builder: (restController) {
      void updateColorBack(int index) {
        setState(() {
          categoryController.advanSelectedList![index] = !    Get.find<CategoryController>().advanSelectedList![index];
        });
      }
             return (restController.isLoading==false)? Container(
               padding: const EdgeInsets.only(right: 7.0,left: 7.0),
               child:    GetBuilder<LocationController>(builder: (locationController) {
              return   Column(
                   crossAxisAlignment: CrossAxisAlignment.start, children: [


                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [





                   ],
                 ),
                 SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),



                 SizedBox(height: Dimensions.PADDING_SIZE_LARGE),




                 SizedBox(height: Dimensions.PADDING_SIZE_SMALL),


                 SizedBox(height: Dimensions.PADDING_SIZE_SMALL),





                 Text(
                   'shot_description'.tr,
                   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                 ),
                 SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                 MyTextField(
                   hintText: 'enter_shot_description'.tr,
                   controller: _shortDescController,
                   focusNode: _shorDesFocus,
                   nextFocus: _longDescFocus ,
                   inputType: TextInputType.text,
                   size: 17,
                   capitalization: TextCapitalization.sentences,
                   showBorder: true,
                 ),
                 SizedBox(height: Dimensions.PADDING_SIZE_SMALL),


                 Text(
                   'long_description'.tr,
                   style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeLarge, color: Theme.of(context).disabledColor),
                 ),
                 SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                 MyTextField(
                   hintText: 'enter_long_desc'.tr,
                   controller: _longDescController,
                   focusNode: _longDescFocus,
                   // nextFocus: _vatFocus,
                   size: 17,

                   maxLines: 4,
                   inputType: TextInputType.text,
                   capitalization: TextCapitalization.sentences,
                   showBorder: true,
                 ),
                 SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                 SizedBox(height: Dimensions.PADDING_SIZE_SMALL),

                SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                SizedBox(
                  height: 200,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialPosition,
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId("estate_location"),
                        position: _initialPosition,
                        infoWindow: const InfoWindow(title: "موقع العقار"),
                      ),
                    },
                  ),
                ),



              Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [




                      SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_LARGE),















                      SizedBox(height: Dimensions.PADDING_SIZE_SMALL),
                      Row(children: [
                        Expanded(

                            child:Column(children: [

                              SizedBox(height: Dimensions.PADDING_SIZE_EXTRA_SMALL),
                              MyTextField(
                                hintText: 'enter_virtual_tour_link'.tr,
                                size: 20,
                                controller: _textEditingController,
                                onChanged: (value) {
                                  setState(() {
                                    isButtonEnabled = value.isNotEmpty;
                                  });
                                },
                                inputType: TextInputType.text,
                                showBorder: true,

                                capitalization: TextCapitalization.words,
                              ),



                            ],)
                        ),




                        SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
                        Container(
                          height: 70,
                          padding: EdgeInsets.only(
                              right: 4, left: 4, top: 16,bottom: 4),
                          child:    ElevatedButton(
                            onPressed: isButtonEnabled
                                ? () {
                              String url = _textEditingController.text;
                              if (url.isNotEmpty) {
                                _showWebViewDialog(context, url);
                              } else {
                                // Handle empty URL input
                                //print('URL is empty');
                              }
                            }
                                : null,
                            child: Text('View'),
                          ),
                        ),

                      ]),





                      SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
                      CustomButton(
                        onPressed: () async {

                          String price;
                          String shortDesc;
                          String space;
                          String authorized;
                          String adNumber;
                          authorized=_authorizedController.text.trim();
                          price = _priceController.text.trim();
                          shortDesc = _shortDescController.text.trim();
                          space = _spaceController.text.trim();
                          String  property ='[{"name":"حمام", "number":"$_selectedBathroomsIndex"},{"name":"غرف نوم", "number":"$_selectedRoomIndex"},{"name":"صلات", "number":"$_selectedLounge"},{"name":"مطبخ", "number":"$_selectedkitchen"}]';
                          List<Map<String, dynamic >> interface= [];

                            setState(() {
                              for (final item in _selectedInterfaceistItems) {
                                interface.add({'"' "name" '"':'"$item"','"' "space" '"':   item=="الواجهة الشمالية"? '"${_northController.text.toString()}"':  item=="الواجهة الشرقية"? '"${_eastController.text.toString()}"': item=="الواجهة الغربية"?'"${_westController.text.toString()}"':item=="الواجهة الجنوبية"?'"${_southController.text.toString()}"':""  });

                              }
                            });



                          List<Map<String, dynamic >> interests = [];
                          for(int index=0; index<categoryController.facilitiesList!.length; index++) {
                            if(categoryController.interestSelectedList![index]) {

                              interests.add ({'"' "name" '"':'"${categoryController.facilitiesList![index].name}"','"' "image" '"':'"${categoryController.facilitiesList![index].image}"'});
                            }
                          }









                  // showCustomSnackBar(     jsonEncode({widget.estate.otherAdvantages}));



                          List<Map<String, dynamic >> advan= [];
                          for(int index=0; index<categoryController.advanList!.length; index++) {
                            if(categoryController.advanSelectedList![index]) {

                              //   showCustomSnackBar("${categoryController.advanList[index].name }");
                              advan.add ({'"' "name" '"':'"${categoryController.advanList![index].name}"'});
                            }
                          }










                          restController.updatEstate(
                              EstateBody (

                                 id: widget.estate!.id.toString(),

                                  longDescription: _longDescController.text,
                                  shortDescription: shortDesc,

                                  arPath: _textEditingController.text,

                                  user_id: widget.estate!.userId.toString(),



                              )
                              );


                          Get.offAllNamed(RouteHelper.getProfileRoute());

                        },
                        margin: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                        buttonText: 'update'.tr,
                      ),


                    ]),


               ])  ;   }),): Center(child: CircularProgressIndicator());

    })
            ],
          ),



                ],

              );



            })
      ;   })
                  : const SizedBox()


      ),
    );

  }






  void _showWebViewDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadRequest(Uri.parse(url));

        return AlertDialog(
          title: Text('Web View'),
          content: SizedBox(
            width: double.maxFinite,
            height: 300, // Adjust the height as needed
            child: WebViewWidget(controller: controller) ,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }





  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if(permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    }else if(permission == LocationPermission.deniedForever) {
      Get.dialog(PermissionDialog());
    }else {
      onTap();
    }
  }

}



