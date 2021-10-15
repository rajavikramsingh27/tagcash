class BillerMerchant {
  int id;
  var name;

  BillerMerchant({this.id, this.name});

  BillerMerchant.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }

  static Map<String, dynamic> toMap(BillerMerchant merchant) => {
    'id': merchant.id,
    'name': merchant.name,
  };

}
