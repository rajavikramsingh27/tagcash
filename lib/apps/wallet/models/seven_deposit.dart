class SevenDeposit {
  int id;
  String referenceId;
  int userId;
  int userType;
  int walletId;
  var amount;
  var fee;
  String payId;
  String expiryDate;
  String status;
  bool removing = false;

  SevenDeposit(
      {this.id,
      this.referenceId,
      this.userId,
      this.userType,
      this.walletId,
      this.amount,
      this.fee,
      this.payId,
      this.expiryDate,
      this.status});

  SevenDeposit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceId = json['reference_id'].toString();
    userId = json['user_id'];
    userType = json['user_type'];
    walletId = json['wallet_id'];
    amount = json['amount'];
    fee = json['fee'];
    payId = json['pay_id'];
    expiryDate = json['expiry_date'];
    status = json['status'];
  }
}
