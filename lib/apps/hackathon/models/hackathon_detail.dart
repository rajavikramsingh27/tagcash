class HackathonDetail {
  String id;
  String hackathonName;
  String hackathonCountry;
  String fromDate;
  String fromTime;
  String duration;
  String startTime;
  String endTime;
  String restriction;
  String roleId;
  String maxTeamMembers;
  Owner owner;
  List prize;
  List<SponsorPrize> sponsorPrize;
  String hackathonDescription;
  String hackathonUrl;
  List<ScoringCriteria> scoringCriteria;
  String registrationOpenFrom;

  HackathonDetail(
      {this.id,
      this.hackathonName,
      this.hackathonCountry,
      this.fromDate,
      this.fromTime,
      this.duration,
      this.startTime,
      this.endTime,
      this.restriction,
      this.roleId,
      this.maxTeamMembers,
      this.owner,
      this.prize,
      this.sponsorPrize,
      this.hackathonDescription,
      this.hackathonUrl,
      this.scoringCriteria,
      this.registrationOpenFrom});

  HackathonDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    hackathonName = json['hackathon_name'];
    hackathonCountry = json['hackathon_country'];
    fromDate = json['from_date'];
    fromTime = json['from_time'];
    duration = json['duration'];
    startTime = json['startTime'];
    endTime = json['endTime'];
    restriction = json['restriction'];
    roleId = json['role_id'];
    maxTeamMembers = json['max_team_members'];
    owner = json['owner'] != null ? new Owner.fromJson(json['owner']) : null;
    prize = json['prize'] ?? [];

    if (json['sponsor_prize'] != null) {
      sponsorPrize = new List<SponsorPrize>();
      json['sponsor_prize'].forEach((v) {
        sponsorPrize.add(new SponsorPrize.fromJson(v));
      });
    }
    hackathonDescription = json['hackathon_description'];
    hackathonUrl = json['hackathon_url'];

    if (json['scoring_criteria'] != null) {
      scoringCriteria = new List<ScoringCriteria>();
      json['scoring_criteria'].forEach((v) {
        scoringCriteria.add(new ScoringCriteria.fromJson(v));
      });
    }

    registrationOpenFrom = json['registration_open_from'];
  }
}

class Owner {
  String id;
  String name;
  String type;
  String email;

  Owner({this.id, this.name, this.type, this.email});

  Owner.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    email = json['email'] ?? '';
  }
}

class SponsorPrize {
  String prize;
  String sponsorId;
  String sponsorName;

  SponsorPrize({this.prize, this.sponsorId, this.sponsorName});

  SponsorPrize.fromJson(Map<String, dynamic> json) {
    prize = json['prize'];
    sponsorId = json['sponsor_id'];
    sponsorName = json['sponsor_name'];
  }
}

class ScoringCriteria {
  String scoringId;
  String percentage;
  String description;

  ScoringCriteria({this.scoringId, this.percentage, this.description});

  ScoringCriteria.fromJson(Map<String, dynamic> json) {
    scoringId = json['scoring_id'].toString();
    percentage = json['percentage'].toString();
    description = json['description'];
  }
}
