class ModuleCategory {
  int id;
  String name;
  String icon;

  ModuleCategory({this.id, this.name, this.icon});

  ModuleCategory.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    name = json['name'];
    icon = json['icon'];
  }
}
