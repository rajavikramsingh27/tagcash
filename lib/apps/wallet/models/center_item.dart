class CenterItem {
  int id;
  String name;

  CenterItem({
    this.id,
    this.name,
  });

  CenterItem.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
