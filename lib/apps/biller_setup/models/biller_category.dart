class BillerCategory {
  int id;
  String name;

  BillerCategory({this.id, this.name});

  BillerCategory.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
