class HackathonList {
  String id;
  String hackathonName;
  String hackathonCountry;
  String fromDate;
  String fromTime;
  String duration;
  String startTime;
  String endTime;
  String restriction;
  String maxTeamMembers;
  String hackathonStatus;

  HackathonList(
      {this.id,
      this.hackathonName,
      this.hackathonCountry,
      this.fromDate,
      this.fromTime,
      this.duration,
      this.startTime,
      this.endTime,
      this.restriction,
      this.maxTeamMembers,
      this.hackathonStatus});

  HackathonList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hackathonName = json['hackathon_name'];
    hackathonCountry = json['hackathon_country'];
    fromDate = json['from_date'];
    fromTime = json['from_time'];
    duration = json['duration'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    restriction = json['restriction'];
    maxTeamMembers = json['max_team_members'];
    hackathonStatus = json['hackathon_status'];
  }
}
