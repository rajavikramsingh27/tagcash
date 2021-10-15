class tamplate {
  String index;
  String path;
  String layout;
  String name;
  String label;

  tamplate(
      {this.index,
        this.path,
        this.layout,
        this.name,
        this.label});

  tamplate.fromJson(Map<String, dynamic> json) {
    index = json['index'];
    path = json['path'];
    layout = json['layout'];
    name = json['name'];
    label = json['label'];
  }
}
