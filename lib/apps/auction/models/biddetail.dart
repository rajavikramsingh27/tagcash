class BidDetail {
  String user_id;
  String user_type;
  String name;
  String bid_amount;
  String bid_amount_per_unit;
  String time;

  BidDetail(
      this.user_id,
      this.user_type, this.name, this.bid_amount, this.bid_amount_per_unit, this.time);

  BidDetail.fromJson(Map<String, dynamic> json) {
    user_id = json['user_id'].toString();
    user_type = json['user_type'].toString();
    name = json['name'].toString();
    bid_amount = json['bid_amount'].toString();
    bid_amount_per_unit = json['bid_amount_per_unit'].toString();
    time = json['time'].toString();
  }
}
