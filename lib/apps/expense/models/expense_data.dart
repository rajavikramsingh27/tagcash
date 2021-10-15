class ExpenseData {
  int amount, claimuserId, merchantId, requestId, typeId, userId, walletId;
  String approveDate,
      currencyCode,
      approveRequest,
      communityName,
      description,
      message,
      receipt,
      requestDate,
      typeDescription,
      typeDetails;

  ExpenseData(
      {this.amount,
      this.claimuserId,
      this.merchantId,
      this.requestId,
      this.typeId,
      this.userId,
      this.walletId,
      this.approveDate,
      this.currencyCode,
      this.approveRequest,
      this.communityName,
      this.description,
      this.message,
      this.receipt,
      this.requestDate,
      this.typeDescription,
      this.typeDetails});

  ExpenseData.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    claimuserId = json['claimuser_id'];
    merchantId = json['merchant_id'];
    requestId = json['request_id'];
    typeId = json['type_id'];
    userId = json['user_id'];
    walletId = json['wallet_id'];
    approveDate = json['approve_date'];
    currencyCode = json['currency_code'];
    approveRequest = json['approve_request'];
    communityName = json['community_name'];
    description = json['description'];
    message = json['message'];
    receipt = json['receipt'];
    requestDate = json['request_date'];
    typeDescription = json['type_description'] ?? '';
    typeDetails = json['type_details'];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['amount'] = this.amount;
    data['claimuser_id'] = this.claimuserId;
    data['merchant_id'] = this.merchantId;
    data['request_id'] = this.requestId;
    data['type_id'] = this.typeId;
    data['user_id'] = this.userId;
    data['wallet_id'] = this.walletId;
    data['approve_date'] = this.approveDate;
    data['currency_code'] = this.currencyCode;
    data['approve_request'] = this.approveRequest;
    data['community_name'] = this.communityName;
    data['description'] = this.description;
    data['message'] = this.message;
    data['receipt'] = this.receipt;
    data['request_date'] = this.requestDate;
    data['type_description'] = this.typeDescription;
    data['type_details'] = this.typeDetails;
    return data;
  }
}
