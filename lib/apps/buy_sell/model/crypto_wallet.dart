class CryptoWallet {
  String id;
  String walletName;
  String currencyCode;
  String balanceAmount;
  String balancePromised;
  String decimal;

  CryptoWallet(
      {this.id,
        this.walletName,
        this.currencyCode,
        this.balanceAmount,
        this.balancePromised,
        this.decimal});

  CryptoWallet.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    walletName = json['wallet_name'];
    currencyCode = json['currency_code'];
    balanceAmount = json['balance_amount'];
    balancePromised = json['balance_promised'];
    decimal = json['decimal'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['wallet_name'] = this.walletName;
    data['currency_code'] = this.currencyCode;
    data['balance_amount'] = this.balanceAmount;
    data['balance_promised'] = this.balancePromised;
    data['decimal'] = this.decimal;
    return data;
  }
}