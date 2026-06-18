import 'dart:convert';

import 'package:abaad_flutter/data/model/response/conversation_model.dart';
class MessageModel {
  int totalSize = 0;
  int limit = 0;
  int offset = 0;
  int status = 0;
  Conversation? conversation;
  List<Message>? messages;
  String estate_id = "";

  MessageModel({required this.totalSize, required this.limit, required this.offset, required this.status, required this.conversation, required this.messages,required this.estate_id});

  MessageModel.fromJson(Map<String, dynamic> json) {
    totalSize = json['total_size'];
    limit = json['limit'];
    offset = json['offset'];
    status = json['status'];
    estate_id = json['estate_id'];
    conversation = json['conversation'] != null ? Conversation.fromJson(json['conversation']) : null;
    if (json['messages'] != null) {
      messages = <Message>[];
      json['messages'].forEach((v) {
        messages?.add(Message.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_size'] = totalSize;
    data['limit'] = limit;
    data['offset'] = offset;
    data['status'] = status;
    data['estate_id']=estate_id;
    data['conversation'] = conversation?.toJson();
      data['messages'] = messages?.map((v) => v.toJson()).toList();
      return data;
  }
}

class Message {
  int id = 0;
  int conversationId = 0;
  int senderId = 0;
  String message = "";
  List<String>? files;
  int isSeen = 0;
  String createdAt = "";
  String updatedAt = "";

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    required this.files,
    required this.isSeen,
    required this.createdAt,
    required this.updatedAt
  });

  Message.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    conversationId = json['conversation_id'];
    senderId = json['sender_id'];
    message = json['message'];
    files = (json['file'] != 'null' && json['file'] != null) ? jsonDecode(json['file']).cast<String>() : [];
    isSeen = json['is_seen'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['conversation_id'] = conversationId;
    data['sender_id'] = senderId;
    data['message'] = message;
    data['file'] = files;
    data['is_seen'] = isSeen;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
