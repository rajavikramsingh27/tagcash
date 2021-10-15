class MyModule {
  int id;
  String moduleName;
  String moduleType;
  String shortDescription;
  String icon;
  String stages;

  MyModule(
      {this.id,
      this.moduleName,
      this.moduleType,
      this.shortDescription,
      this.icon,
      this.stages});

  MyModule.fromJson(Map<String, dynamic> json) {
    id = int.parse(json['id']);
    moduleName = json['module_name'];
    moduleType = json['module_type'].toString();
    shortDescription = json['short_description'].toString();
    icon = json['icon'] ?? '';
    stages = json['stages'];
  }
}
