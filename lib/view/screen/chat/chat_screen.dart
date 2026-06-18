import 'dart:async';
import 'package:abaad_flutter/controller/auth_controller.dart';
import 'package:abaad_flutter/controller/chat_controller.dart';
import 'package:abaad_flutter/controller/splash_controller.dart';
import 'package:abaad_flutter/controller/user_controller.dart';
import 'package:abaad_flutter/data/model/body/notification_body.dart';
import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/data/model/response/userinfo_model.dart';
import 'package:abaad_flutter/helper/responsive_helper.dart';
import 'package:abaad_flutter/helper/route_helper.dart';
import 'package:abaad_flutter/helper/user_type.dart';
import 'package:abaad_flutter/util/app_constants.dart';
import 'package:abaad_flutter/util/dimensions.dart';
import 'package:abaad_flutter/util/images.dart';
import 'package:abaad_flutter/util/styles.dart';
import 'package:abaad_flutter/view/base/custom_image.dart';
import 'package:abaad_flutter/view/base/not_logged_in_screen.dart';
import 'package:abaad_flutter/view/base/paginated_list_view.dart';
import 'package:abaad_flutter/view/screen/chat/widget/message_bubble.dart';
import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChatScreen extends StatefulWidget {
  final NotificationBody notificationBody;
  final Userinfo  user;
  final int? conversationID;
  final int? index;
  final String?  estate_id;
  final String? link;
  final Estate? estate;
  const ChatScreen({super.key, required this.notificationBody, required this.user, this.conversationID, this.index,this.estate_id,this.link,this.estate});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputMessageController = TextEditingController();
  bool? _isLoggedIn;
  StreamSubscription? _stream;
  String? url;
  var data;
  final String _errorImage = "https://i.ytimg.com/vi/z8wrRRR7_qU/maxresdefault.jpg";
  Timer? _timer;
  @override
  void initState() {
    super.initState();

    //print('-------------------------------estate_id${widget.estate_id}');

    initCall();

    if(widget.link=="null"){

      _inputMessageController.text="";

      // _inputMessageController.text=widget.link;
    }else{
      setState(() {
      });
      Get.find<ChatController>().toggleSendButtonActivity();
      _inputMessageController.text=widget.link!;
    }
    //
    startFetchingMessages();



  }

  @override
  void dispose() {
    super.dispose();
    _stream?.cancel();
  }



  void startFetchingMessages() {
    // Define the interval for refreshing data
    const duration = Duration(seconds: 30); // Adjust the duration as needed

    // Fetch messages immediately
    Get.find<ChatController>().getMessages(1, widget.notificationBody, widget.user, widget.conversationID, firstLoad: true);

    // Start the timer
    _timer = Timer.periodic(duration, (Timer t) {
      Get.find<ChatController>().getMessages(1, widget.notificationBody, widget.user, widget.conversationID);
    });
  }

  void initCall(){
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if(Get.find<AuthController>().isLoggedIn()) {
      Get.find<ChatController>().getMessages(1, widget.notificationBody, widget.user, widget.conversationID, firstLoad: true);
    }
  }



  @override
  Widget build(BuildContext context) {

    return GetBuilder<ChatController>(builder: (chatController) {
      String baseUrl = '';
      baseUrl = Get.find<SplashController>().configModel?.baseUrls?.customerImageUrl ?? "";
    
      return Scaffold(


      //   appBar: (ResponsiveHelper.isDesktop(context) ?  WebMenuBar() : AppBar(
      //   leading: IconButton(
      //     // onPressed: () {
      //     //   if(widget.fromNotification) {
      //     //     Get.offAllNamed(RouteHelper.getInitialRoute());
      //     //   }else {
      //     //     Get.back();
      //     //   }
      //     // },
      //     icon: const Icon(Icons.arrow_back_ios),
      //   ),
      //   title: Text(chatController.messageModel != null ? '${chatController.messageModel.conversation.receiver.name}'
      //       ' ${chatController.messageModel.conversation.receiver.name}' : 'receiver_name'.tr),
      //   backgroundColor: Theme.of(context).primaryColor,
      //   actions: <Widget>[
      //     Padding(
      //       padding: const EdgeInsets.all(8.0),
      //       child: Container(
      //         width: 40, height: 40, alignment: Alignment.center,
      //         decoration: BoxDecoration(
      //           borderRadius: BorderRadius.circular(50),
      //           border: Border.all(width: 2,color: Theme.of(context).cardColor),
      //           color: Theme.of(context).cardColor,
      //         ),
      //         child: ClipOval(child: CustomImage(
      //           image:'${AppConstants.BASE_URL}'
      //               '/${chatController.messageModel != null ? chatController.messageModel.conversation.receiver.image : ''}',
      //           fit: BoxFit.cover, height: 40, width: 40,
      //         )),
      //       ),
      //     )
      //   ],
      // )),

        body: (_isLoggedIn ?? false) ?
        GetBuilder<UserController>(builder: (userController) {
      return  SafeArea(
          child: Center(
            child: SizedBox(
              width: ResponsiveHelper.isDesktop(context) ? Dimensions.WEB_MAX_WIDTH : MediaQuery.of(context).size.width,
              child: Column(children: [
                widget.link != "null"?   SizedBox(
                  height: 60.0,
                  child: Stack(
                    children: <Widget>[
                      Container(
                        color: Colors.red,
                        height: 60.0,
                        child: Container(

                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(1.0),
                              border: Border.all(
                                  color: Colors.grey.withOpacity(0.5), width: 1.0),
                              color: Theme.of(context).primaryColor,),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if(  (widget.index ?? 1) == 1){// fromNotification ?? false ) {
                                      Get.offAllNamed(RouteHelper.getInitialRoute());
                                    }else {
                                      Get.back();
                                    }
                                  },
                                  icon: const Icon(Icons.arrow_back_ios)
                                ),

                                Text(chatController.messageModel != null ? '${chatController.messageModel?.conversation?.receiver?.name ?? ""}'
                                    ' ${(chatController.messageModel?.conversation?.receiver?.name ?? "")}' : 'receiver_name'.tr,style: TextStyle(color: Theme.of(context).disabledColor,),),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    width: 40, height: 40, alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(50),
                                      border: Border.all(width: 2,color: Theme.of(context).cardColor),
                                      color: Theme.of(context).cardColor,
                                    ),
                                    child: ClipOval(child: CustomImage(
                                      image:'${AppConstants.BASE_URL}'
                                          '/${chatController.messageModel != null ? chatController.messageModel?.conversation?.receiver?.image : ''}',
                                      fit: BoxFit.cover, height: 40, width: 40,
                                    )),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ):Container(
                  // child:   Text(widget.estate.shortDescription),
                ),
                GetBuilder<ChatController>(builder: (chatController) {
                  return Expanded(child: chatController.messageModel != null ? (chatController.messageModel?.messages?.isNotEmpty ?? false) ? SingleChildScrollView(
                    controller: _scrollController,
                    reverse: true,
                    child: PaginatedListView(
                      scrollController: _scrollController,
                      reverse: true,
                      totalSize: chatController.messageModel?.totalSize,
                      offset: chatController.messageModel?.offset,
                      onPaginate: (int offset) async => await chatController.getMessages(
                        offset, widget.notificationBody, widget.user, widget.conversationID,
                      ),
                      productView: ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        reverse: true,
                        itemCount: (chatController.messageModel?.messages?.length ?? 40),
                        itemBuilder: (context, index) {
                          return MessageBubble(
                            message: chatController.messageModel?.messages?[index],
                            user: chatController.messageModel?.conversation?.receiver,
                            userType: widget.notificationBody.adminId != null ? UserType.admin
                                : widget.notificationBody.deliverymanId != null ? UserType.delivery_man : UserType.vendor,
                          );
                        },
                      ),
                    ),
                  ) : Center(child: Container()) : Center(child: CircularProgressIndicator()));
                }),

                (chatController.messageModel != null) ? Container(
                  color: Theme.of(context).cardColor,
                  child: Column(children: [

                    GetBuilder<ChatController>(builder: (chatController) {

                      return (chatController.chatImage?.isNotEmpty ?? false) ? SizedBox(height: 100,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: chatController.chatImage?.length,
                            itemBuilder: (BuildContext context, index){
                              return  (chatController.chatImage?.isNotEmpty ?? false) ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(children: [

                                  Container(width: 100, height: 100,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(20))),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(Radius.circular(Dimensions.PADDING_SIZE_DEFAULT)),
                                      child: Image.memory(
                                        chatController.chatRawImage![index], width: 100, height: 100, fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  Positioned(top:0, right:0,
                                    child: InkWell(
                                      onTap : () => chatController.removeImage(index, _inputMessageController.text.trim()),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(Radius.circular(Dimensions.PADDING_SIZE_DEFAULT))
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Icon(Icons.clear, color: Colors.red, size: 15),
                                        ),
                                      ),
                                    ),
                                  )],
                                ),
                              ) : SizedBox();
                            }),
                      ) : SizedBox();
                    }),
                    AnyLinkPreview(

                      link: widget.link ?? "",
                      displayDirection: UIDirection.uiDirectionHorizontal,
                      cache: Duration(hours: 1),
                      backgroundColor: Colors.grey[300],
                      errorWidget: SizedBox(),
                      errorImage: _errorImage,
                    ),
                    Row(children: [

                      InkWell(
                        onTap: () async {
                          Get.find<ChatController>().pickImage(false);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                          child: Image.asset(Images.image, width: 25, height: 25, color: Theme.of(context).hintColor),
                        ),
                      ),

                      SizedBox(
                        height: 25,
                        child: VerticalDivider(width: 0, thickness: 1, color: Theme.of(context).hintColor),
                      ),
                      SizedBox(width: Dimensions.PADDING_SIZE_DEFAULT),

                      Expanded(
                        child: TextField(
                          inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.MESSAGE_INPUT_LENGTH)],
                          controller: _inputMessageController,
                          textCapitalization: TextCapitalization.sentences,
                          style: robotoRegular,
                          keyboardType: TextInputType.multiline,
                          maxLines: null,

                          decoration: InputDecoration(
                            border: InputBorder.none,

                            hintText: 'type_here'.tr,
                            hintStyle: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeLarge),
                          ),
                          onSubmitted: (String newText) {
                            if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                              Get.find<ChatController>().toggleSendButtonActivity();
                            }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                              Get.find<ChatController>().toggleSendButtonActivity();
                            }
                          },
                          onChanged: (String newText) {

                            if(newText.trim().isNotEmpty && !Get.find<ChatController>().isSendButtonActive) {
                              Get.find<ChatController>().toggleSendButtonActivity();
                            }else if(newText.isEmpty && Get.find<ChatController>().isSendButtonActive) {
                              Get.find<ChatController>().toggleSendButtonActivity();
                            }
                          },
                        ),
                      ),

                      GetBuilder<ChatController>(builder: (chatController) {
                        return chatController.isLoading ? Padding(
                          padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                          child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator()),
                        ) : InkWell(
                          onTap: () async {

                            // if(chatController.isSendButtonActive ||  widget.estate_id==null) {
                              await chatController.sendMessage(
                                message: _inputMessageController.text, notificationBody: widget.notificationBody,
                                conversationID: widget.conversationID ?? 0, index: widget.index ?? 0,estate_id: widget.estate_id ?? ""
                              );
                              _inputMessageController.clear();
                            // }else {
                            //   showCustomSnackBar('write_something'.tr);
                            // }
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: Dimensions.PADDING_SIZE_DEFAULT),
                            child: Image.asset(
                              Images.send, width: 25, height: 25,
                              color: chatController.isSendButtonActive ? Theme.of(context).primaryColor : Theme.of(context).hintColor,
                            ),
                          ),
                        );
                      }
                      ),

                    ]),
                  ]),
                ) : SizedBox(),
              ],
              ),
            ),
          ),
        );
        })

            : NotLoggedInScreen(),
      );
    });
  }

  // void _getMetadata(String url) async {
  //   bool _isValid = _getUrlValid(url);
  //   if (_isValid) {
  //     Metadata _metadata = await AnyLinkPreview.getMetadata(
  //       link: url,
  //       cache: Duration(days: 7),
  //       proxyUrl: "https://cors-anywhere.herokuapp.com/", // Needed for web app
  //     );
  //     debugPrint("URL6 => ${_metadata?.title}");
  //     debugPrint(_metadata?.desc);
  //   } else {
  //     debugPrint("URL is not valid");
  //   }
  // }


  bool _getUrlValid(String url) {
    bool isUrlValid = AnyLinkPreview.isValidLink(
      url,
      protocols: ['http', 'https'],
      hostWhitelist: ['https://youtube.com/'],
      hostBlacklist: ['https://facebook.com/'],
    );
    return isUrlValid;
  }

}
