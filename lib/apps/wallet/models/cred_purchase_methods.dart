class CredPurchaseMethods {
  String id;
  String method;
  String title;

  CredPurchaseMethods({this.id, this.method, this.title});

  CredPurchaseMethods.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    method = json['method'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['method'] = this.method;
    data['title'] = this.title;
    return data;
  }
}
