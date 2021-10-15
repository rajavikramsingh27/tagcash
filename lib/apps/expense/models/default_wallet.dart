class DefaultWallet {
  int walletId;
  String currencyCode;

  DefaultWallet(
      {this.walletId,
      this.currencyCode});

  DefaultWallet.fromJson(Map<String, dynamic> json) {
    walletId = json['wallet_id'];
    currencyCode = json['currency_code'];
   
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['wallet_id'] = this.walletId;
    data['currency_code'] = this.currencyCode;
    return data;
  }
}