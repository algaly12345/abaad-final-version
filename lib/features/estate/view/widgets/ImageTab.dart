// import 'dart:convert';
// import 'dart:io';
//
// import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
// import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
// import 'package:abaad_flutter/shared/utils/app_constants.dart';
// import 'package:flutter/material.dart';
//
//
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:http/http.dart' as http;
// import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
//
// import '../../../../helper/route_helper.dart' show RouteHelper;
//
// class ImageTab extends StatefulWidget {
//   final int estateId;
//
//    const ImageTab({super.key,  required this.estateId});
//
//   @override
//   State<ImageTab> createState() => _ImageTabState();
// }
//
// class _ImageTabState extends State<ImageTab> {
//   List<XFile> _imageFiles = [];
//
//   List<String> _existingImageUrls = [];
//
//  // int _currentIndex = 0;
//
//
//   Future<void> _fetchExistingImages(int id) async {
//     final response = await http.get(Uri.parse('${AppConstants.BASE_URL}/api/v1/estate/etch-existing-images/$id'));
//
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       setState(() {
//         _existingImageUrls = List<String>.from(data['image_data']);
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     //print("--------------------------${widget.estateId}");
//     _fetchExistingImages(widget.estateId);
//
//   }
//
//   Future<void> _pickImages() async {
//     final List<XFile> selectedImages = await ImagePicker().pickMultiImage();
//     setState(() {
//       _imageFiles = selectedImages;
//     });
//   }
//
//   Future<void> _uploadImages(int id) async {
//     if (_imageFiles.isEmpty) return;
//
//     final ProgressDialog pr = ProgressDialog(context);
//     pr.style(message: 'Uploading Images...');
//
//     await pr.show();
//
//     try {
//       List<http.MultipartFile> imageFiles = [];
//       for (var imageFile in _imageFiles) {
//         List<int> imageBytes = await imageFile.readAsBytes();
//         imageFiles.add(http.MultipartFile.fromBytes('images[]', imageBytes, filename: imageFile.name));
//       }
//
//       final Uri uploadUri = Uri.parse('${AppConstants.BASE_URL}/api/v1/estate/upload-images/$id');
//       var request = http.MultipartRequest('POST', uploadUri);
//       request.files.addAll(imageFiles);
//
//       var response = await request.send();
//       if (response.statusCode == 200) {
//         //print('Images uploaded successfully');
//         _imageFiles.clear();
//         Get.find<UserController>().getEstateByUser(1, false,widget.estateId);
//         _fetchExistingImages(widget.estateId);
//         _fetchExistingImages(widget.estateId);
//       } else {
//         //print('Image upload failed');
//       }
//     } catch (e) {
//       // Handle error
//     } finally {
//       pr.hide();
//     }
//   }
//
//   Future<void> _deleteImage(String imageUrl, int id) async {
//     final ProgressDialog pr = ProgressDialog(context);
//     pr.style(message: 'Deleting Image...');
//
//     await pr.show();
//
//     try {
//       final response = await http.delete(Uri.parse('${AppConstants.BASE_URL}/api/v1/estate/delete-image/$id/$imageUrl'));
//
//       if (response.statusCode == 200) {
//         setState(() {
//           _existingImageUrls.remove(imageUrl);
//         });
//       }
//     } catch (e) {
//       // Handle error
//     } finally {
//       pr.hide();
//     }
//   }
//   //
//   // Widget _buildTabButton(String title, int index) {
//   //   return GestureDetector(
//   //     onTap: () {
//   //       //print('Tab tapped: $index');
//   //       setState(() {
//   //         _currentIndex = index;
//   //       });
//   //     },
//   //     child: Container(
//   //       padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//   //       color: _currentIndex == index ? Colors.blue : Colors.transparent,
//   //       child: Text(
//   //         title,
//   //         style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//   //       ),
//   //     ),
//   //   );
//   // }
//
//   Widget _buildImageTile(String imageUrl, int id) {
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(16),
//       child: Stack(
//         children: [
//           SizedBox.expand(
//             child: Image.network(
//               '${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${Uri.encodeComponent(imageUrl)}',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             child:ColoredBox(
//               color: Color.fromARGB(155, 0, 0, 0),
//               child: Container(
//                 child: IconButton(
//                   icon: Icon(Icons.delete,color: Colors.white,),
//                   onPressed: () => _deleteImage(imageUrl, id),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return     GestureDetector(
//       onTap: () {
//         //print('Tab tapped: ${widget.estateId}');
//       },
//       child: Center(child:Column(
//         children: [
//           Padding(
//             padding:  EdgeInsets.all(4.0),
//             child: SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                   onPressed: _pickImages,style: ElevatedButton.styleFrom(
//                   backgroundColor: Theme.of(context).primaryColor),
//                   child:  Text('browse_and_add_photos'.tr)),),
//           ),
//           SizedBox(
//             height: 130,
//
//             child: GridView.builder(
//               gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//               ),
//               itemCount: _imageFiles.length ?? 0,
//               itemBuilder: (context, index) {
//                 final imageFile = _imageFiles[index];
//                 return Image.file(File(imageFile.path));
//               },
//             ),
//           ),
//
//           Container(
//             padding:  EdgeInsets.all(4.0),
//             width: double.infinity,
//             color: Colors.transparent,
//             child: OutlinedButton.icon(
//                 onPressed:()=>_uploadImages(widget.estateId),
//                 icon:Icon(Icons.drive_folder_upload,color:Theme.of(context).primaryColor ),
//                 label:  Text("upload_images".tr)),
//           ),
//           SizedBox(height: 10),
//           _existingImageUrls.isNotEmpty
//               ? Expanded(
//             child:GridView.builder(
//               padding: const EdgeInsets.all(16),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 16,
//                 crossAxisSpacing: 16,
//               ),
//               itemCount: _existingImageUrls.length,
//               itemBuilder: (context, index) {
//                 final imageUrl = _existingImageUrls[index];
//                 return _buildImageTile(imageUrl, widget.estateId); // Replace 123 with the actual id
//               },
//             ),
//           )
//               : Container(),
//
//
//
//           // ... باقي الكود ...
//
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _imageFiles.isNotEmpty ? () {
//                     Navigator.of(context).pop();
//                     final userController = Get.find<UserController>();
//                     userController.getUserInfoByID(userController.userInfoModel?.id ?? 0);
//                     Get.toNamed(
//                       RouteHelper.getProfileAgentRoute(userController.userInfoModel?.id ?? 0, 1),
//                     );
//                   } : null, // تعطيل الزر إذا لم يتم اختيار صور
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _imageFiles.isNotEmpty ? Colors.indigo[800] : Colors.grey,
//                     padding: const EdgeInsets.symmetric(vertical: 14),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                   ),
//                   child: const Text(
//                     'إنهاء',
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
// // ... باقي الكود ...
//
//         ],
//       ),),
//     );
//   }
//
// }




import 'dart:convert';
import 'dart:io';

import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/shared/utils/app_constants.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

import 'package:abaad_flutter/core/routes/route_helper.dart' show RouteHelper;

class ImageTab extends StatefulWidget {
  final int estateId;

  const ImageTab({super.key, required this.estateId});

  @override
  State<ImageTab> createState() => _ImageTabState();
}

class _ImageTabState extends State<ImageTab> {
  List<XFile> _imageFiles = [];
  List<String> _existingImageUrls = [];
  bool _imagesUploaded = false; // متغير جديد لتتبع حالة تحميل الصور

  Future<void> _fetchExistingImages(int id) async {
    final response = await http.get(Uri.parse('${AppConstants.BASE_URL}/api/v1/estate/etch-existing-images/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _existingImageUrls = List<String>.from(data['image_data']);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchExistingImages(widget.estateId);
  }

  Future<void> _pickImages() async {
    final List<XFile> selectedImages = await ImagePicker().pickMultiImage();
    setState(() {
      _imageFiles = selectedImages;
      _imagesUploaded = false; // إعادة تعيين الحالة عند اختيار صور جديدة
    });
  }

  Future<void> _uploadImages(int id) async {
    if (_imageFiles.isEmpty) return;

    final ProgressDialog pr = ProgressDialog(context);
    pr.style(message: 'Uploading Images...');

    await pr.show();

    try {
      List<http.MultipartFile> imageFiles = [];
      for (var imageFile in _imageFiles) {
        List<int> imageBytes = await imageFile.readAsBytes();
        imageFiles.add(http.MultipartFile.fromBytes('images[]', imageBytes, filename: imageFile.name));
      }

      final Uri uploadUri = Uri.parse('${AppConstants.BASE_URL}/api/v1/estate/upload-images/$id');
      var request = http.MultipartRequest('POST', uploadUri);
      request.files.addAll(imageFiles);

      var response = await request.send();
      if (response.statusCode == 200) {
        _imageFiles.clear();
        Get.find<UserController>().getEstateByUser(1, false, widget.estateId);
        _fetchExistingImages(widget.estateId);
        _fetchExistingImages(widget.estateId);

        // تحديث الحالة عند نجاح التحميل
        setState(() {
          _imagesUploaded = true;
        });
      } else {
        setState(() {
          _imagesUploaded = false;
        });
      }
    } catch (e) {
      setState(() {
        _imagesUploaded = false;
      });
    } finally {
      pr.hide();
    }
  }

  Future<void> _deleteImage(String imageUrl, int id) async {
    final ProgressDialog pr = ProgressDialog(context);
    pr.style(message: 'Deleting Image...');

    await pr.show();

    try {
      final response = await http.delete(Uri.parse('${AppConstants.BASE_URL}/api/v1/estate/delete-image/$id/$imageUrl'));

      if (response.statusCode == 200) {
        setState(() {
          _existingImageUrls.remove(imageUrl);
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      pr.hide();
    }
  }

  Widget _buildImageTile(String imageUrl, int id) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          SizedBox.expand(
            child: Image.network(
              '${Get.find<SplashController>().configModel!.baseUrls!.estateImageUrl}/${Uri.encodeComponent(imageUrl)}',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ColoredBox(
              color: Color.fromARGB(155, 0, 0, 0),
              child: Container(
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.white),
                  onPressed: () => _deleteImage(imageUrl, id),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //print('Tab tapped: ${widget.estateId}');
      },
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(4.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  child: Text('browse_and_add_photos'.tr),
                ),
              ),
            ),
            SizedBox(
              height: 130,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: _imageFiles.length ?? 0,
                itemBuilder: (context, index) {
                  final imageFile = _imageFiles[index];
                  return Image.file(File(imageFile.path));
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(4.0),
              width: double.infinity,
              color: Colors.transparent,
              child: OutlinedButton.icon(
                onPressed: () => _uploadImages(widget.estateId),
                icon: Icon(Icons.drive_folder_upload, color: Theme.of(context).primaryColor),
                label: Text("upload_images".tr),
              ),
            ),
            SizedBox(height: 10),
            _existingImageUrls.isNotEmpty
                ? Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _existingImageUrls.length,
                itemBuilder: (context, index) {
                  final imageUrl = _existingImageUrls[index];
                  return _buildImageTile(imageUrl, widget.estateId);
                },
              ),
            )
                : Container(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _imagesUploaded // استخدام المتغير للتحكم في تفعيل الزر
                        ? () {
                      Navigator.of(context).pop();
                      final userController = Get.find<UserController>();
                      userController.getUserInfoByID(userController.userInfoModel?.id ?? 0);
                      Get.offAllNamed(
                        RouteHelper.getProfileAgentRoute(userController.userInfoModel?.id ?? 0, 1),
                      );
                    }
                        : null, // تعطيل الزر إذا لم يتم تحميل الصور
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _imagesUploaded ? Colors.indigo[800] : Colors.grey, // تغيير اللون حسب الحالة
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'إنهاء',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}