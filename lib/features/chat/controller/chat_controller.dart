
import 'dart:typed_data';

import 'package:abaad_flutter/shared/controllers/splash_controller.dart';
import 'package:abaad_flutter/features/profile/controller/user_controller.dart';
import 'package:abaad_flutter/core/api/api_checker.dart';
import 'package:abaad_flutter/core/api/api_client.dart';
import 'package:abaad_flutter/features/notification/data/models/notification_body.dart';
import 'package:abaad_flutter/features/chat/data/models/conversation_model.dart';
import 'package:abaad_flutter/features/chat/data/models/message_model.dart';
import 'package:abaad_flutter/features/profile/data/models/userinfo_model.dart';
import 'package:abaad_flutter/features/chat/data/repositories/chat_repo.dart';
import 'package:abaad_flutter/shared/helpers/date_converter.dart';
import 'package:abaad_flutter/shared/helpers/responsive_helper.dart';
import 'package:abaad_flutter/shared/helpers/user_type.dart';
import 'package:abaad_flutter/shared/widgets/custom_snackbar.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
// import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:image_picker/image_picker.dart';

// import 'package:image_compression_flutter/image_compression_flutter.dart';


class ChatController extends GetxController implements GetxService {
  final ChatRepo chatRepo;
  ChatController({required this.chatRepo});

  List<bool>? _showDate;
  bool _isSendButtonActive = false;
  final bool _isSeen = false;
  final bool _isSend = true;
  bool _isMe = false;
  bool _isLoading= false;
  final List<Message>  _deliveryManMessage = [];
  final List<Message>  _adminManMessage = [];
  List <XFile>? _chatImage = [];
  List <Uint8List>?_chatRawImage = [];
  MessageModel?  _messageModel;
  ConversationsModel? _conversationModel;
  ConversationsModel? _searchConversationModel;
  bool _hasAdmin = true;

  bool get isLoading => _isLoading;
  List<bool>? get showDate => _showDate;
  bool get isSendButtonActive => _isSendButtonActive;
  bool get isSeen => _isSeen;
  bool get isSend => _isSend;
  bool get isMe => _isMe;
  List<Message> get deliveryManMessage => _deliveryManMessage;
  List<Message> get adminManMessages => _adminManMessage;
  List<XFile>? get chatImage => _chatImage;
  List<Uint8List>? get chatRawImage => _chatRawImage;
  MessageModel? get messageModel => _messageModel;
  ConversationsModel? get conversationModel => _conversationModel;
  ConversationsModel? get searchConversationModel => _searchConversationModel;
  bool get hasAdmin => _hasAdmin;

  Future<void> getConversationList(int offset, {String type = ''}) async {
    _hasAdmin = true;
    _searchConversationModel = null;
    Response response = await chatRepo.getConversationList(offset, type);
    if(response.statusCode == 200) {
      if(offset == 1) {
        _conversationModel = ConversationsModel.fromJson(response.body);
      }else {
        _conversationModel?.totalSize = ConversationsModel.fromJson(response.body).totalSize;
        _conversationModel?.offset = ConversationsModel.fromJson(response.body).offset;
        _conversationModel?.conversations?.addAll(ConversationsModel.fromJson(response.body).conversations as Iterable<Conversation>);
      }
      int index0 = -1;
       bool sender = false;
      for(int index=0 ; index<_conversationModel!.conversations!.length; index++) {
        if(_conversationModel!.conversations?[index].receiverType == UserType.admin.name) {
          index0 = index;
          sender = false;
          break;
        }else if(_conversationModel!.conversations?[index].receiverType == UserType.admin.name) {
          index0 = index;
          sender = true;
          break;
        }
      }
      _hasAdmin = false;
      if(index0 != -1 && !ResponsiveHelper.isDesktop(Get.context)) {
        _hasAdmin = true;
        if(sender) {
          _conversationModel!.conversations?[index0].sender = Userinfo(
            id: 0, name: Get.find<SplashController>().configModel!.businessName,
            phone: Get.find<SplashController>().configModel!.phone,
            image: Get.find<SplashController>().configModel!.logo, identity: '', commercialRegisterionNo: '', userId: '', advertiserNo: '', membershipType: '', identityType: '', createdAt: '', updatedAt: '', falLicenseNumber: '',
          );
        }else {


        }
      }
    }else {
      ApiChecker.checkApi(response, showToaster: true);
    }
    update();
  }


  Future<void> searchConversation(String name) async {
    _searchConversationModel = ConversationsModel(totalSize: 0, limit: 100, offset: 0, conversations: null);
    update();
    Response response = await chatRepo.searchConversationList(name);
    if(response.statusCode == 200) {
      _searchConversationModel = ConversationsModel.fromJson(response.body);
      int index0 = -1;
      bool sender = false;
      for(int index=0; index<_searchConversationModel!.conversations!.length; index++) {
        if(_searchConversationModel!.conversations?[index].receiverType == UserType.admin.name) {
          index0 = index;
          sender = false;
          break;
        }else if(_searchConversationModel!.conversations?[index].receiverType == UserType.admin.name) {
          index0 = index;
          sender = true;
          break;
        }
      }
      if(index0 != -1) {
        if(sender) {
          _searchConversationModel!.conversations?[index0].sender = Userinfo(
            id: 0, name: Get.find<SplashController>().configModel!.businessName,
            phone: Get.find<SplashController>().configModel!.phone,
            image: Get.find<SplashController>().configModel!.logo, identity: '', commercialRegisterionNo: '', userId: '', advertiserNo: '', membershipType: '', identityType: '', createdAt: '', updatedAt: '', falLicenseNumber: '',
          );
        }else {
          _searchConversationModel!.conversations?[index0].receiver = Userinfo(
            id: 0, name: Get.find<SplashController>().configModel!.businessName,
            phone: Get.find<SplashController>().configModel!.phone,
            image: Get.find<SplashController>().configModel!.logo, identity: '', commercialRegisterionNo: '', userId: '', advertiserNo: '', membershipType: '', identityType: '', createdAt: '', updatedAt: '', falLicenseNumber: '',
          );
        }
      }
    }else {
      ApiChecker.checkApi(response, showToaster: true);
    }
    update();
  }

  void removeSearchMode() {
    _searchConversationModel = null;
    update();
  }

  Future<void> getMessages(int offset, NotificationBody notificationBody, Userinfo? user, int? conversationID, {bool firstLoad = false}) async {
    Response response;
    if(firstLoad) {
      _messageModel = null;
      _isSendButtonActive = false;
      _isLoading = false;
    }
    response = await chatRepo.getMessages(offset, 0, UserType.admin, 0);
    

    if (response.body['messages'] != {} && response.statusCode == 200) {
      if (offset == 1) {

        /// Unread-read
        int index0 = -1;
        for(int index=0; index<_conversationModel!.conversations!.length; index++) {
          if(conversationID == _conversationModel!.conversations?[index].id) {
            index0 = index;
            break;
          }
        }
        if(index0 != -1) {
          _conversationModel!.conversations?[index0].unreadMessageCount = 0;
        }
              /// Manage Receiver
        _messageModel = MessageModel.fromJson(response.body);
        _messageModel?.conversation;
      }else {
        _messageModel?.totalSize = MessageModel.fromJson(response.body).totalSize;
        _messageModel?.offset = MessageModel.fromJson(response.body).offset;
        _messageModel?.messages?.addAll(MessageModel.fromJson(response.body).messages as Iterable<Message>);
        _messageModel?.messages?.addAll(MessageModel.fromJson(response.body).messages as Iterable<Message>);
      }
    } else {
      ApiChecker.checkApi(response, showToaster: true);
    }
    update();
  }



  void pickImage(bool isRemove) async {
    if(isRemove) {
      _chatImage = [];
      _chatRawImage = [];
    }else {
      List<XFile> imageFiles = await ImagePicker().pickMultiImage(imageQuality: 40);
      for(XFile xFile in imageFiles) {
        if(_chatImage!.length >= 3) {
          showCustomSnackBar('can_not_add_more_than_3_image'.tr);
          break;
        }else {
          // XFile xFile = await compressImage(xFile);
          // _chatImage.add(xFile);
          // _chatRawImage.add(await xFile.readAsBytes());
        }
      }
      _isSendButtonActive = true;
        }
    update();
  }

  void removeImage(int index, String messageText){
    _chatImage?.removeAt(index);
    _chatRawImage?.removeAt(index);
    if(_chatImage!.isEmpty && messageText.isEmpty) {
      _isSendButtonActive = false;
    }
    update();
  }

  Future<Response> sendMessage({required String message, required NotificationBody notificationBody,
    required int conversationID, required int index,required String  estate_id}) async {
    //print("omeromeromer");
    Response response;
    _isLoading = true;
    update();

    List<MultipartBody> myImages = [];
    for (var image in _chatImage!) {
      myImages.add(MultipartBody('image[]', image));
    }

    response = await chatRepo.sendMessage(message, myImages, 0, UserType.admin, 0,estate_id);
      if (response.statusCode == 200) {
      _chatImage = [];
      _chatRawImage = [];
      _isSendButtonActive = false;
      _isLoading = false;
      ////print("---------------------------------${response.body}");
      _messageModel = MessageModel.fromJson(response.body);
      _searchConversationModel!.conversations?[index].lastMessageTime = DateConverter.isoStringToLocalString(_messageModel!.messages![0].createdAt);
          if(!_hasAdmin && (_messageModel?.conversation?.senderType == UserType.admin.name || _messageModel?.conversation?.receiverType == UserType.admin.name)) {
        _conversationModel?.conversations?.add(_messageModel!.conversation!);
        _hasAdmin = true;
      }
      _sortMessage(notificationBody.adminId!);
      Future.delayed(Duration(seconds: 2),() {
        getMessages(1, notificationBody, Userinfo(id: 0, name: '', phone: '', identity: '', image: '', commercialRegisterionNo: '', userId: '', advertiserNo: '', membershipType: '', identityType: '', createdAt: '', updatedAt: '', falLicenseNumber: ''), conversationID);
      });
    }
    update();
    return response;
  }

  void _sortMessage(int adminId) {
    if((_messageModel?.conversation?.receiverType == UserType.user.name
        || _messageModel?.conversation?.receiverType == UserType.customer.name)) {
      Userinfo? receiver = _messageModel?.conversation?.receiver;
      _messageModel?.conversation?.receiver = _messageModel!.conversation?.sender;
      _messageModel?.conversation?.sender = receiver!;
    }
    _messageModel?.conversation?.receiver = Userinfo(
      id: 0,
      name: Get.find<SplashController>().configModel!.businessName,
      image: Get.find<SplashController>().configModel!.logo,
      phone: '',
      identity: '',
      commercialRegisterionNo: '',
      userId: '',
      advertiserNo: '',
      membershipType: '',
      identityType: '',
      createdAt: '',
      updatedAt: '',
      falLicenseNumber: '',
    );
    }

  void toggleSendButtonActivity() {
    _isSendButtonActive = !_isSendButtonActive;
    update();
  }

  void setIsMe(bool value) {
    _isMe = value;
  }

  void reloadConversationWithNotification(int conversationID) {
    int index0 = -1;
    Conversation? conversation;
    for(int index=0; index<_conversationModel!.conversations!.length; index++) {
      if(_conversationModel!.conversations?[index].id == conversationID) {
        index0 = index;
        conversation = _conversationModel!.conversations?[index];
        break;
      }
    }
    if(index0 != -1) {
      _conversationModel?.conversations?.removeAt(index0);
    }
    conversation?.unreadMessageCount++;
    _conversationModel?.conversations?.insert(0, conversation!);
    update();
  }

  void reloadMessageWithNotification(Message message) {
    _messageModel?.messages?.insert(0, message);
    update();
  }

  // Future<XFile> compressImage(XFile file) async {
  //   final ImageFile input = ImageFile(filePath: file.path, rawBytes: await file.readAsBytes());
  //   final Configuration config = Configuration(
  //     outputType: ImageOutputType.webpThenPng,
  //     useJpgPngNativeCompressor: false,
  //     quality: (input.sizeInBytes/1048576) < 2 ? 50 : (input.sizeInBytes/1048576) < 5
  //         ? 30 : (input.sizeInBytes/1048576) < 10 ? 2 : 1,
  //   );
  //   final ImageFile output = await compressor.compress(ImageFileConfiguration(input: input, config: config));
  //   if(kDebugMode) {
  //     //print('Input size : ${input.sizeInBytes / 1048576}');
  //     //print('Output size : ${output.sizeInBytes / 1048576}');
  //   }
  //   return XFile.fromData(output.rawBytes);
  // }

}