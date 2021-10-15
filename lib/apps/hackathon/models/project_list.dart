class ProjectList {
  String id;
  String hackathonId;
  String teamName;
  String projectName;
  String projectType;
  String projectPresentation;
  String projectDescription;
  Owner owner;
  List<int> miniApps;

  ProjectList(
      {this.id,
      this.hackathonId,
      this.teamName,
      this.projectName,
      this.projectType,
      this.projectPresentation,
      this.projectDescription,
      this.owner,
      this.miniApps});

  ProjectList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hackathonId = json['hackathon_id'];
    teamName = json['team_name'];
    projectName = json['project_name'];
    projectType = json['project_type'];
    projectPresentation = json['project_presentation'];
    projectDescription = json['project_description'];
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
    miniApps = json['mini_apps'].cast<int>();
  }
}

class Owner {
  String id;
  String name;
  String type;
  String email;
  String verified;

  Owner({this.id, this.name, this.type, this.email, this.verified});

  Owner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    email = json['email'] ?? '';
    verified = json['verified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['type'] = this.type;
    data['email'] = this.email;
    data['verified'] = this.verified;
    return data;
  }
}
