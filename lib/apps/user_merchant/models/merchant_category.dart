class MerchantCategory {
  int id;
  String name;

  MerchantCategory({this.id, this.name});

  MerchantCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
