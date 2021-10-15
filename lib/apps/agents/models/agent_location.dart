class AgentLocation {
  int id;
  String name;

  AgentLocation({this.id,
    this.name,
  });

  AgentLocation.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['location_name'];
  }
}
