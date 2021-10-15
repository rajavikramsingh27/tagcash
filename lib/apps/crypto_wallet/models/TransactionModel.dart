class TransactionModel {
  String id;
  String balance = "0";
  String createDate = "";
  dynamic nextPage = 0;
  bool spent = false;

  TransactionModel(
      this.id, this.balance, this.createDate, this.nextPage, this.spent);

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(json['_id'], json['balance'], json['createDate'],
        json['nextPage'], json['spent']);
  }

  bool isSpent() {
    if (spent != null && spent) return true;
    return false;
  }

  static Future<List<TransactionModel>> transactionList(
      Map<String, dynamic> json) async {
    var txn = json['txn'] as List;
    List<TransactionModel> listTxn =
        txn.map((e) => TransactionModel.fromJson(e)).toList();
    return listTxn;
  }
}
