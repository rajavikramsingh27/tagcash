class WalletTypes {
  String walletId;
  String walletType;
  String walletTypeNumeric;
  String walletName;
  String currencyCode;
  String currencyName;

  WalletTypes(
      {this.walletId,
      this.walletType,
      this.walletTypeNumeric,
      this.walletName,
      this.currencyCode,
      this.currencyName});

  WalletTypes.fromJson(Map<String, dynamic> json) {
    walletId = json['wallet_id'];
    walletType = json['wallet_type'];
    walletTypeNumeric = json['wallet_type_numeric'];
    walletName = json['wallet_name'];
    currencyCode = json['currency_code'];
    currencyName = json['currency_name'];
  }
}
