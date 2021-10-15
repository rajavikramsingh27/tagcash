class RedEnvelope {
  int id;
  String title;
  int randomize;
  String voucherReceipient;
  double voucherAmount;
  int voucherWalletType;
  DateTime createdAt;
  int expiresAt;
  int expirationType;
  String textId;
  int voucherStatus;
  int voucherType;
  int voucherCount;
  int redemptionPerUser;
  String currencyCode;

  RedEnvelope({
    this.id,
    this.title,
    this.randomize,
    this.voucherReceipient,
    this.voucherAmount,
    this.voucherWalletType,
    this.createdAt,
    this.expiresAt,
    this.expirationType,
    this.textId,
    this.voucherStatus,
    this.voucherType,
    this.voucherCount,
    this.redemptionPerUser,
    this.currencyCode
  });

  RedEnvelope.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    randomize = json['randomize'];
    voucherReceipient = json['voucher_receipient'];
    voucherAmount = json['voucher_amount'].toDouble();
    voucherWalletType = json['voucher_wallet_type'];
    createdAt = DateTime.parse(json['created_at']);
    expiresAt = json['expires_at'];
    expirationType = json['expiration_type'];
    textId = json['text_id'];
    voucherStatus = json['voucher_status'];
    voucherType = json['voucher_type'];
    voucherCount = json['voucher_count'];
    redemptionPerUser = json['redemption_per_user'];
    currencyCode = json['currency_code'];
  }
}