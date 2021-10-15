class Files {
  String path;
  var dateAdded;
  var size;
  String displayName;
  var duration;

  Files(
      {this.path, this.dateAdded, this.size, this.displayName, this.duration});

  Files.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    dateAdded = json['dateAdded'];
    size = json['size'];
    displayName = json['displayName'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['path'] = this.path;
    data['dateAdded'] = this.dateAdded;
    data['size'] = this.size;
    data['displayName'] = this.displayName;
    data['duration'] = this.duration;
    return data;
  }
}