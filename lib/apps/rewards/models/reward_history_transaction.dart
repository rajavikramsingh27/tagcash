import 'package:intl/intl.dart';

class RewardHistoryTransaction {
  String date;
  String amountSum;
  List<Transaction> transactions;

  RewardHistoryTransaction({this.date, this.amountSum, this.transactions});

  RewardHistoryTransaction.fromJson(Map<String, dynamic> json) {
    DateFormat formatter = DateFormat('MMM d, yyyy (EEEE)');
    var parsedDate = DateTime.parse(json['date']);
    date = formatter.format(parsedDate);

    amountSum = json['amount_sum'].toString();
    print(json['transactions'].toString());
    var list = json['transactions'] as List;
    transactions = list.map((i) => Transaction.fromJson(i)).toList();
    print("Transactions");
    for (var i = 0; i < transactions.length; i++) {
      print(transactions[i].rewardWalletId.toString());
    }
  }
}

class Transaction {
  String id;
  String fromUserId;
  String fromUserType;
  String toUserId;
  String toUserType;
  String toUserName;
  String ruleId;
  String rewardWalletId;
  String amount;
  String createdDate;
  String createdDateCountry;

  Transaction(
      {this.id,
      this.fromUserId,
      this.fromUserType,
      this.toUserId,
      this.toUserType,
      this.toUserName,
      this.ruleId,
      this.rewardWalletId,
      this.amount,
      this.createdDate,
      this.createdDateCountry});

  Transaction.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    fromUserId = json['from_user_id'];
    fromUserType = json['from_user_type'];
    toUserId = json['to_user_id'];
    toUserType = json['to_user_type'];
    toUserName = json['to_user_name'];
    ruleId = json['rule_id'];
    rewardWalletId = json['reward_wallet_id'];
    amount = json['amount'];
    //createdDate = json['created_date'];
    DateFormat formatter = DateFormat('HH:mm');
    var parsedDate = DateTime.parse(json['created_date']);
    createdDate = formatter.format(parsedDate);
    createdDateCountry = json['created_date_country'];
  }
}
