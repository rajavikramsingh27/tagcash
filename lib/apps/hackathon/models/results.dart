class Results {
  String hackathonId;
  String projectId;
  String projectName;
  String teamName;
  Prize prize;

  Results(
      {this.hackathonId,
      this.projectId,
      this.projectName,
      this.teamName,
      this.prize});

  Results.fromJson(Map<String, dynamic> json) {
    hackathonId = json['hackathon_id'];
    projectId = json['project_id'];
    projectName = json['project_name'];
    teamName = json['team_name'];
    prize = json['prize'] != null ? new Prize.fromJson(json['prize'][0]) : null;
  }
}

class Prize {
  String rank;
  String prize;
  String name;
  String id;
  String prizeType;
  String isAwarded;

  Prize(
      {this.rank,
      this.prize,
      this.name,
      this.id,
      this.prizeType,
      this.isAwarded});

  Prize.fromJson(Map<String, dynamic> json) {
    rank = json['rank'];
    name = json['name'];
    id = json['id'];
    prizeType = json['prize_type'];
    isAwarded = json['is_awarded'];
    prize = json['prize'];
  }
}
