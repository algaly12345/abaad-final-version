
class WalletModel {

  int totalSize = 0;
  String limit = "";
  String offset = "";
  List<Transaction>? data;

  WalletModel({required this.totalSize, required this.limit, required this.offset, required this.data});

  WalletModel.fromJson(Map<String, dynamic> json) {
     totalSize = json["total_size"];
     limit = json["limit"].toString();
     offset = json["offset"].toString();
     if (json['data'] != null) {
       data = [];
     json['data'].forEach((v) {
       data?.add(Transaction.fromJson(v));
     });
     }
  }

  Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = <String, dynamic>{};
      data['total_size'] = totalSize;
      data['limit'] = limit;
      data['offset'] = offset;
      data['data'] = this.data?.map((v) => v.toJson()).toList();
      return data;
  }
}

class Transaction {

  int userId = 0;
  String transactionId = "";
  double credit =0;
  double debit =0;
  double adminBonus = 0;
  double balance = 0;
  String transactionType = "";
  DateTime? createdAt;
  DateTime? updatedAt;

  Transaction({
    required this.userId,
    required this.transactionId,
    required this.credit,
    required this.debit,
    required this.adminBonus,
    required this.balance,
    required this.transactionType,
    required this.createdAt,
    required this.updatedAt,
  });


  Transaction.fromJson(Map<String, dynamic> json) {
    userId = json["user_id"];
    transactionId = json["transaction_id"];
    credit = json["credit"].toDouble();
    debit = json["debit"].toDouble();
    if(json["admin_bonus"] != null){
      adminBonus = json["admin_bonus"].toDouble();
    }
    balance = json["balance"].toDouble();
    transactionType = json["transaction_type"];
    createdAt = DateTime.parse(json["created_at"]);
    updatedAt = DateTime.parse(json["updated_at"]);
  }

  Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = <String, dynamic>{};
    data["user_id"] = userId;
    data["transaction_id"] = transactionId;
    data["credit"] = credit;
    data["debit"] = debit;
    data["admin_bonus"] = adminBonus;
    data["balance"] = balance;
    data["transaction_type"] = transactionType;
    data["created_at"] = createdAt?.toIso8601String();
    data["updated_at"] = updatedAt?.toIso8601String();
  return data;
  }
}
