class CredPlans {
  String id;
  String name;
  String walletTypeId;
  String walletTypeIdAmount;
  String credAmount;
  String currencyCode;

  CredPlans(
      {this.id,
      this.name,
      this.walletTypeId,
      this.walletTypeIdAmount,
      this.credAmount,
      this.currencyCode});

  CredPlans.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    walletTypeId = json['wallet_type_id'];
    walletTypeIdAmount = json['wallet_type_id_amount'];
    credAmount = json['cred_amount'];
    currencyCode = json['currency_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['wallet_type_id'] = this.walletTypeId;
    data['wallet_type_id_amount'] = this.walletTypeIdAmount;
    data['cred_amount'] = this.credAmount;
    data['currency_code'] = this.currencyCode;
    return data;
  }
}
