class TemplateModule {
  String id;
  String name;
  String code;
  String amount;
  String walletId;

  TemplateModule({this.id, this.name, this.code, this.amount, this.walletId});

  TemplateModule.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    amount = json['amount'];
    walletId = json['wallet_id'];
  }
}
