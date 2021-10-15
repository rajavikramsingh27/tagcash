class ScoreList {
  String scoringId;
  String percentage;
  String description;
  String scoreCount;

  ScoreList(
      {this.scoringId, this.percentage, this.description, this.scoreCount});

  ScoreList.fromJson(Map<String, dynamic> json) {
    scoringId = json['scoring_id'];
    percentage = json['percentage'];
    description = json['description'];
    scoreCount = json['score_count'];
  }
}
