class Template {
  String id;
  String index;
  String path;
  String layout;
  String name;
  String label;

  Template(
      {this.id,
        this.index,
        this.path,
        this.layout,
        this.name,
        this.label});

  Template.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    index = json['index'];
    path = json['path'];
    layout = json['layout'];
    name = json['name'];
    label = json['label'];
  }
}
