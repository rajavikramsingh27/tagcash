class Stat {
  String state_id;
  String name;

  Stat(
      {this.state_id,
        this.name});

  Stat.fromJson(Map<String, dynamic> json) {
    state_id = json['state_id'];
    name = json['name'];
  }
}
