class Voucher {
  double amount;
  String code;
  String emailTo;
  String expireIn;
  String expiry;
  String expiryDate;
  int id;
  String mobileNo;
  String reciepient;
  String status;
  String type;
  int voucherBalance;
  int voucherStatus;
  int voucherType;
  String walletType;

  Voucher({
    this.amount,
    this.code,
    this.emailTo,
    this.expireIn,
    this.expiry,
    this.expiryDate,
    this.id,
    this.mobileNo,
    this.reciepient,
    this.status,
    this.type,
    this.voucherBalance,
    this.voucherStatus,
    this.voucherType,
    this.walletType
  });

  Voucher.fromJson(Map<String, dynamic> json) {
    amount = json['amount'].toDouble();
    code = json['code'];
    emailTo = json['email_to'];
    expireIn = json['expire_in'];
    expiry = json['expiry'];
    expiryDate = json['expiry_date'];
    id = json['id'];
    mobileNo = json['mobile_no'];
    reciepient = json['reciepient'];
    status = json['status'];
    type = json['type'];
    voucherBalance = json['voucher_balance'];
    voucherStatus = json['voucher_status'];
    voucherType = json['voucher_type'];
    walletType = json['wallet_type'];
  }
}

class ReceivedVoucher {
  int id;
  String code;
  double amount;
  String type;
  int voucherType;
  String walletType;

  ReceivedVoucher({
    this.id,
    this.amount,
    this.code,
    this.type,
    this.voucherType,
  });

  ReceivedVoucher.fromJson(Map<String, dynamic> json) {
    amount = json['amount'].toDouble();
    code = json['code'];
    id = json['id'];
    type = json['type'];
    voucherType = json['voucher_type'];
    walletType = json['wallet_type'];
  }
}