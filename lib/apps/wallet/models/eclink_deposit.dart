class EclinkDeposit {
  int id;
  int referenceId;
  int userId;
  int userType;
  int walletId;
  var amount;
  var fee;
  int payId;
  String initializeDate;
  String expiryDate;
  String paidDate;
  String status;
  bool removing = false;

  EclinkDeposit(
      {this.id,
      this.referenceId,
      this.userId,
      this.userType,
      this.walletId,
      this.amount,
      this.fee,
      this.payId,
      this.initializeDate,
      this.expiryDate,
      this.paidDate,
      this.status});

  EclinkDeposit.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    referenceId = json['reference_id'];
    userId = json['user_id'];
    userType = json['user_type'];
    walletId = json['wallet_id'];
    amount = json['amount'];
    fee = json['fee'];
    payId = json['pay_id'] ?? 0;
    initializeDate = json['initialize_date'] ?? '';
    expiryDate = json['expiry_date'] ?? '';
    paidDate = json['paid_date'] ?? '';
    status = json['status'];
  }
}
