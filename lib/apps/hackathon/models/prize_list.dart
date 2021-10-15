class PrizeList {
  String rank;
  String prize;
  String name;
  String id;
  String prizeType;
  String isAwarded;
  Map prizeData;

  PrizeList(
      {this.rank,
      this.prize,
      this.name,
      this.id,
      this.prizeType,
      this.isAwarded,
      this.prizeData});

  PrizeList.fromJsonAdmin(Map<String, dynamic> json) {
    rank = json['rank'];
    prize = json['prize'];
    name = json['name'];
    id = json['id'];
    prizeType = json['prize_type'];
    isAwarded = json['is_awarded'];
    prizeData = json;
  }

  PrizeList.fromJsonSponsor(Map<String, dynamic> json) {
    rank = json['rank'];
    prize = json['prize'];
    name = json['name'];
    id = json['id'];
    prizeType = json['prize_type'];
    isAwarded = json['is_awarded'];
    prizeData = json;
  }
}
