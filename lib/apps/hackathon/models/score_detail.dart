class ScoreDetail {
  String id;
  String name;
  String type;
  String overallScore;
  List<Scoring> scoring;

  ScoreDetail({this.id, this.name, this.type, this.overallScore, this.scoring});

  ScoreDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    type = json['type'];
    overallScore = json['overall_score'];
    if (json['scoring'] != null) {
      scoring = new List<Scoring>();
      json['scoring'].forEach((v) {
        scoring.add(new Scoring.fromJson(v));
      });
    }
  }
}

class Scoring {
  String scoringId;
  String percentage;
  String description;
  String scoreCount;
  String role;

  Scoring(
      {this.scoringId,
      this.percentage,
      this.description,
      this.scoreCount,
      this.role});

  Scoring.fromJson(Map<String, dynamic> json) {
    scoringId = json['scoring_id'];
    percentage = json['percentage'];
    description = json['description'];
    scoreCount = json['score_count'];
    role = json['role'];
  }
}
