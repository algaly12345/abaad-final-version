
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/ImageTab.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/PlanImagesTab.dart';
import 'package:abaad_flutter/view/screen/estate/widgets/VideoTab.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UploadScreen extends StatefulWidget {
  final int estateId;

  const UploadScreen({super.key,  required this.estateId});

  @override
  State<UploadScreen> createState() => _MediaTabScreenState();
}

class _MediaTabScreenState extends State<UploadScreen>
    with TickerProviderStateMixin {
   TabController? _tabController;

   void _showUploadDialog() {
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return AlertDialog(
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(16),
           ),
           title: Center(
             child: Text(
               "تنبيه",
               style: TextStyle(
                 fontWeight: FontWeight.bold,
                 color: Color(0xFF003366),
                 fontSize: 20,
               ),
             ),
           ),
           content: Text(
             "هل تريد تحميل صور أو فيديوهات؟",
             textAlign: TextAlign.center,
             style: TextStyle(
               fontSize: 16,
             ),
           ),
           actionsAlignment: MainAxisAlignment.spaceEvenly,
           actions: [
             ElevatedButton(
               onPressed: () {
                 Navigator.of(context).pop(); // نعم: لا تفعل شيء
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: Color(0xFF003366),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
               ),
               child: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                 child: Text(
                   "نعم",
                   style: TextStyle(color: Colors.white),
                 ),
               ),
             ),
             ElevatedButton(
               onPressed: () {
                 Navigator.of(context).pop(); // أغلق الديالوج
                 final userController = Get.find<UserController>();
                 userController.getUserInfoByID(userController.userInfoModel?.id ?? 0);

                 // Get.offAllNamed(RouteHelper.getInitialRoute());
                 Get.offAllNamed(RouteHelper.getProfileAgentRoute(userController.userInfoModel?.id ?? 0, 1));
               },
               style: ElevatedButton.styleFrom(
                 backgroundColor: Color(0xFF003366),
                 shape: RoundedRectangleBorder(
                   borderRadius: BorderRadius.circular(12),
                 ),
               ),
               child: Padding(
                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                 child: Text(
                   "لا",
                   style: TextStyle(color: Colors.white),
                 ),
               ),
             ),
           ],
         );
       },
     );
   }


   @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
    Future.delayed(Duration.zero, () {
      _showUploadDialog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحميل وسائط'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'الصور'),
            Tab(text: 'الفيديوهات'),
            Tab(text: 'صور المخطط'), // 👈 التب الجديد
          ],
        ),
        backgroundColor: Colors.indigo[800],
      ),
        body: Column(
          children: [
            Expanded( // ✅ هذا سيمنع overflow
              child: TabBarView(
                controller: _tabController,
                children: [
                  ImageTab(estateId: widget.estateId),
                  VideoTab(estateId: widget.estateId),
                  PlanImagesTab(estateId: widget.estateId),
                ],
              ),
            ),

          ],
        ),

    );

  }
}

// Image Tab


// Video Tab




