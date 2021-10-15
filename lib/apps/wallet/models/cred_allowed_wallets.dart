class CredAllowedWallets {
  String id;
  String currencyCode;

  CredAllowedWallets({this.id, this.currencyCode});

  CredAllowedWallets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    currencyCode = json['currency_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['currency_code'] = this.currencyCode;
    return data;
  }
}
