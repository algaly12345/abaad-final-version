

import 'package:abaad_flutter/data/model/response/estate_model.dart';
import 'package:abaad_flutter/data/model/response/message_model.dart';
import 'package:abaad_flutter/data/model/response/userinfo_model.dart';

class ConversationsModel {
  int? totalSize = 0;
  int? limit = 0;
  int? offset = 0;
//  String categoryNmae
  List<Conversation>? conversations;

  ConversationsModel({ required this.totalSize, this.limit,  this.offset,  this.conversations});

  ConversationsModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    if (json['conversations'] != null) {
      conversations = <Conversation>[];
      json['conversations'].forEach((v) {
        conversations?.add(Conversation.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['conversations'] = conversations?.map((v) => v.toJson()).toList();
      return data;
  }

}

class Conversation {
  int? id = 0;
  int? senderId = 0;
  String? senderType = "";
  int? receiverId = 0;
  String? receiverType = "";
  int unreadMessageCount = 0;
  int? lastMessageId = 0;
  String? lastMessageTime = "";
  String? createdAt = "";
  String? updatedAt = "";
  int? estate_id = 0;
  Userinfo? sender;
  Userinfo? receiver;
  Estate? estate;
  Message? lastMessage;

  Conversation({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.receiverId,
    required this.receiverType,
    required this.unreadMessageCount,
    required this.lastMessageId,
    required this.lastMessageTime,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    required this.receiver,
    required this.lastMessage,
    required this.estate_id,
    required this.estate
  });

  Conversation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    senderType = json['sender_type'];
    receiverId = json['receiver_id'];
    receiverType = json['receiver_type'];
    unreadMessageCount = json['unread_message_count'];
    lastMessageId = json['last_message_id'];
    lastMessageTime = json['last_message_time'];
    estate_id = json['estate_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    sender = (json['sender'] != null ? Userinfo.fromJson(json['sender']) : null)!;
    receiver = (json['receiver'] != null ? Userinfo.fromJson(json['receiver']) : null)!;
    lastMessage = (json['last_message'] != null ? Message.fromJson(json['last_message']) : null)!;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['sender_id'] = senderId;
    data['sender_type'] = senderType;
    data['receiver_id'] = receiverId;
    data['receiver_type'] = receiverType;
    data['unread_message_count'] = unreadMessageCount;
    data['last_message_id'] = lastMessageId;
    data['last_message_time'] = lastMessageTime;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['estate'] = estate_id;
    data['sender'] = sender?.toJson();
      data['receiver'] = receiver?.toJson();
      data['last_message'] = lastMessage?.toJson();
  
    data['estate'] = estate?.toJson();
      return data;
  }
}
