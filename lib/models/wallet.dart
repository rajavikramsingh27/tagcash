class Wallet {
  var balanceAmount;
  var promisedAmount;
  var familyBalanceAmount;
  int walletId;
  String walletType;
  int walletTypeNumeric;
  String walletName;
  String currencyCode;
  String walletDescription;
  String stellarIssuerAddress;
  bool bankDepositWithdraw;
  List<int> subSetTokenTypeId;

  Wallet(
      {this.balanceAmount,
      this.promisedAmount,
      this.familyBalanceAmount,
      this.walletId,
      this.walletType,
      this.walletTypeNumeric,
      this.walletName,
      this.currencyCode,
      this.walletDescription,
      this.stellarIssuerAddress,
      this.bankDepositWithdraw,
      this.subSetTokenTypeId});

  Wallet.fromJson(Map<String, dynamic> json) {
    balanceAmount = json['balance_amount'];
    promisedAmount = json['promised_amount'];
    walletId = int.parse(json['wallet_id']);
    walletType = json['wallet_type'];
    walletTypeNumeric = int.parse(json['wallet_type_numeric']);
    walletName = json['wallet_name'];
    currencyCode = json['currency_code'];
    walletDescription = json['wallet_description'];
    stellarIssuerAddress = json['stellar_issuer_address'] ?? '';
    bankDepositWithdraw = json['bank_deposit_withdraw'];
    subSetTokenTypeId = json['sub_set_token_type_id'].cast<int>();
    if (json['family_account_balance'] != null) {
      familyBalanceAmount = json['family_account_balance']['balance'];
    } else {
      familyBalanceAmount = 0;
    }
  }
}
